// Based on: https://vericred.com/using-rust-to-speed-up-your-ruby-apps-part-2-how-to-use-rust-with-ruby/

#![allow(improper_ctypes_definitions)] // Hide the 'not FFI-safe' warnings!

#[macro_use]
extern crate rutie_serde;

use rayon::prelude::*;
use rutie::{class, Object, Thread};
use rutie_serde::rutie_serde_methods;

// Use this to deserialize Ruby objects
use serde_derive::Deserialize;

#[derive(Debug, Deserialize)]
pub struct ParentRubyObject {
    pub id: u64,
    pub children: Vec<ChildRubyObject>
}

#[derive(Debug, Deserialize)]
pub struct ChildRubyObject {
    pub hex_value: String
}

class!(RustLib);

rutie_serde_methods!(
    RustLib,
    _itself,
    ruby_class!(Exception),

    fn pub_calculate(parent_objects: Vec<ParentRubyObject>) -> u32 {
        parent_objects
            .iter()
            .flat_map(|parent| &parent.children)
            .map(|child| {
                child
                    .hex_value
                    .chars()
                    .map(|c| c.to_digit(10).unwrap_or_else(|| 0))
                    .sum::<u32>()
            })
        .sum()
    }

    fn pub_calculate_multi(parent_objects: Vec<ParentRubyObject>) -> u32 {
        Thread::call_without_gvl(
            move || {
                parent_objects
                    .par_iter()
                    .flat_map(|parent| &parent.children)
                    .map(|child| {
                        child.hex_value
                            .chars()
                            .map(|c| c.to_digit(10).unwrap_or_else(|| 0))
                            .sum::<u32>()
                    })
                    .sum()
            },
            Some(|| {})
        )
    }

    fn pub_hello_world() -> String {
        format!("Rust says 'Hi!'")
    }

    fn pub_reverse(array: Vec<String>) -> Vec<String> {
        array.into_iter().rev().collect()
    }

    fn pub_find_blocked_words(text_array: Vec<String>, blocked_words: Vec<String>) -> Vec<String> {
        // This method is slightly faster than that used in multi-thread version
        let mut found_words: Vec<String> = vec![];

        for word in text_array.iter() {
            if blocked_words.contains(&word) {
                found_words.push(word.to_string());
            }
        }

        found_words
    }

    fn pub_find_blocked_words_multi(text_array: Vec<String>, blocked_words: Vec<String>) -> Vec<String> {
        Thread::call_without_gvl(
            move || {
                text_array
                    .clone()
                    .into_par_iter()
                    .filter(|word| blocked_words.contains(&word))
                    .collect()
            },
            Some(|| {})
        )
    }
);

// Entrypoint function (that Ruby can call):
#[no_mangle]
pub extern "C" fn Init_rust_lib() {
    rutie::Class::new("RustLib", None).define(|itself| {
        itself.def_self("calculate", pub_calculate);
        itself.def_self("calculate_multi", pub_calculate_multi);
        itself.def_self("hello_world", pub_hello_world);
        itself.def_self("reverse", pub_reverse);
        itself.def_self("find_blocked_words", pub_find_blocked_words);
        itself.def_self("find_blocked_words_multi", pub_find_blocked_words_multi);
    });
}

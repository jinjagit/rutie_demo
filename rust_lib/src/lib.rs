#![allow(improper_ctypes_definitions)] // Hide the 'not FFI-safe' warnings!

#[macro_use]
extern crate rutie_serde;

use rayon::prelude::*;
use rutie::{class, Object, Thread};
use rutie_serde::rutie_serde_methods;

// Use this to deserialize Ruby objects
// use serde_derive::Deserialize;

class!(RustLib);

rutie_serde_methods!(
    RustLib,
    _itself,
    ruby_class!(Exception),

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
        itself.def_self("hello_world", pub_hello_world);
        itself.def_self("reverse", pub_reverse);
        itself.def_self("find_blocked_words", pub_find_blocked_words);
        itself.def_self("find_blocked_words_multi", pub_find_blocked_words_multi);
    });
}

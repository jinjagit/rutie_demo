# README
POC - Rust on Rails, using Rutie gem & crate.
  
<img width="672" alt="multi" src="https://user-images.githubusercontent.com/3944042/152689049-33f11d88-a265-4969-bba3-fc314e83080e.png">
<br>
  
This is a non-dockerized version, created to deploy to Heroku.  
Visit https://rutie-demo-simontharby.herokuapp.com/ for hello_world  
Visit: https://rutie-demo-simontharby.herokuapp.com/arrays/blocked_words for benchmarks  
Visit: https://rutie-demo-simontharby.herokuapp.com/vericred_example for Vericred example with objects (benchmarked)  
  
For dockerized version see [this repo](https://github.com/jinjagit/rutie_on_rails)  
  
## To add Rust to a Rails app
This is already done in this demo repo, but if you want to do it yourself...  
  
Assuming Ruby and Rust are both installed, and your rails app is created:  
  
Add the Rutie gem to the Gemfile  
`gem 'rutie', '~> 0.0.3'`  
and run `bundle install`  
  
Configure the `config/application.rb` file by adding
```ruby
...
require 'rutie'
...
module RutieOnRails
  class Application < Rails::Application
    ...
    Rutie
    .new(:rust_lib, lib_path: 'target/release')
    .init('Init_rust_lib', 'rust_lib')
  end
end
```

Add a directory, in this case `rust_lib` as specified in the above config, in the root of the repo.  
Change to that directory, `cd rust_lib`, and run `cargo init` to create a Rust library.  
Edit `cargo.toml` to be:
```rust
[package]
name = "rust_lib"
version = "0.1.0"
authors = ["Simon Tharby"]
edition = "2018"

[dependencies]
rayon = "1.2"
rutie = "0.5.5"
rutie-serde = "0.1.1"
serde = "1.0"
serde_derive = "1.0"

[lib]
name = "rust_lib"
crate-type = ["dylib"]
```
This provides a Rutie-specific serializer and other useful goodies.  
Rayon is only required if multi-threading is desired.  
  
Now Rust functions can be written in `lib.rs` and compiled using `cargo build --release`  
Only the resulting binary needs pushing upstream, in our case `rust_lib/target/release/librust_lib.so`  
  
When the Rust `lib.rs` is edited and recompiled to a release binary, the Docker container needs to be restarted for the changes to take effect.  
If compiling on Mac, cross-compilation to a Linux binary is needed (which is not covered here, and will involve the use of additional compilation libraries). This is because the Docker container runs a Linux image.  
  
The Rust functions written for this demo are in the file: [`rust_lib/src/lib.rs`](https://github.com/jinjagit/rutie_on_rails/blob/master/rust_lib/src/lib.rs)  
  
Based on the approach described in [Using Rust to Speed Up Your Ruby Apps: Part 2, by Vericred](https://vericred.com/using-rust-to-speed-up-your-ruby-apps-part-2-how-to-use-rust-with-ruby/)  
<br>

## Why is multi-threaded slower, or not much faster, than single-threaded?
_"[multi-threaded code] won’t run much faster when executed in parallel outside the GVL [Ruby Global Virtual Machine Lock]. But given a more complex real-life scenario where your Ruby app is running on hardware under load inside a web server like Puma you would very likely see meaningful performance gains."_, Vericred 2020  
  
TODO: Verify this with load testing. This is probably best done with the Rails app in production mode.

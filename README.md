# human-name-rb
Ruby bindings for the Rust crate [`human_name`](https://github.com/djudd/human-name), a library for parsing and comparing human names.

See the [`human_name` docs](djudd.github.io/human-name) for details.

# Examples

```ruby
  require 'humanname'

  name = HumanName.parse("Doe, Jane")
  name.surname
  => "Doe"
  name.given_name
  => "Jane"
  name.initials
  => "J"

  name = HumanName.parse("J. Doe")
  name.surname
  => "Doe"
  name.given_name
  => nil
  name.initials
  => "J"
```

# Supported environments

Without modification, 64-bit Linux. Depends on a `.so` dynamic library built on
Travis' container  infrastructure, which means Ubuntu 12.04.

In theory, anywhere where the nightly Rust compiler will run:

1. Build your own `libhuman_name.so` (or `libhuman_name.dylib` on OS X):
```bash
curl -s https://static.rust-lang.org/rustup.sh | sh -s -- --channel=nightly
git clone git@github.com:djudd/human-name.git
cd human-name
cargo build --release
```

2. Fork this `djudd/human-name.rb`, replace `libhuman_name.so` with the file
from `human-name/target/release`, and run `bundle exec rake` to ensure the
specs are passing.

Depends on the `ffi` gem.

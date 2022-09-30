# human-name-rb
Ruby bindings for the Rust crate [`human_name`](https://github.com/djudd/human-name), a library for parsing and comparing human names.

See the [`human_name` docs](http://djudd.github.io/human-name) for details.

# Examples

```ruby
  require 'humanname'

  doe_jane = HumanName.parse("Doe, Jane")
  doe_jane.surname
  => "Doe"
  doe_jane.given_name
  => "Jane"
  doe_jane.initials
  => "J"

  j_doe = HumanName.parse("J. Doe")
  j_doe.surname
  => "Doe"
  j_doe.given_name
  => nil
  j_doe.initials
  => "J"

  j_doe == doe_jane
  => true
  j_doe == HumanName.parse("John Doe")
  => true
  doe_jane == HumanName.parse("John Doe")
  => false
```

# Supported environments

Linux, MacOS, and Windows, as of the versions currently supported by GitHub Actions.
x86-64 or Apple Silicon. Ruby 2.7 or later.

If you have access to another environment which is supported by the Rust compiler,
it should be relatively straightforward to fork the library and add support. You'll need
to build [`human_name`](http://github.com/djudd/human-name), copy the resulting library
from `target/release/` in that repository to `lib/native/<arch>/` in this one,
and modify `native_lib_path` appropriately. If this environment is additionally supported
by GitHub Actions, I'm also happy to accept a PR.

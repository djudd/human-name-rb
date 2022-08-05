# human-name-rb
Ruby bindings for the Rust crate [`human_name`](https://github.com/djudd/human-name), a library for parsing and comparing human names.

[![Build Status](https://travis-ci.org/djudd/human-name-rb.svg?branch=master)](https://travis-ci.org/djudd/human-name-rb)

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

With just `bundle`/`gem install`, OS X 10.13+ & Ubuntu Trusty or later.

If you're willing to do a little more work, anywhere supported by the Rust compiler:
```sh
./build/update-rust.sh
```

That will give you a .gem file in pkg/ which should work in environments similar
to the one in which it was built.

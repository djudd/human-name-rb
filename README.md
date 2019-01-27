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

If you're willing to do a little more work, anywhere supported by [Helix](https://github.com/tildeio/helix)
and the nightly Rust compiler:
```bash
curl https://sh.rustup.rs -sSf | sh -s -- --channel=nightly
git clone git@github.com:djudd/human-name-rb.git
cd human-name-rb
bundle exec rake
```

That will give you a .gem file in pkg/ which should work in environments similar
to the one in which it was built.

# Benchmark results

Comparing to [`people`](https://github.com/academia-edu/people), [`namae`](https://github.com/berkmancenter/namae), and [`human_name_parser`](https://github.com/abachman/human_name_parser),
on 16k real examples taken mostly from PubMed author fields:

```
$ bundle exec rake benchmark
people gem:
  3.010000   0.030000   3.040000 (  3.032075)
namae gem:
  3.550000   0.080000   3.630000 (  3.630643)
human_name_parser gem:
  1.960000   0.030000   1.990000 (  1.991358)
this gem:
  0.100000   0.000000   0.100000 (  0.107794)
```

Our implementation uses a similar strategy to `people` and `human_name_parser`
but covers significantly more edge cases, and also supports comparison.
(`human_name_parser` also covers fewer edge cases than `people`, as of December
2015, which probably explains its speed advantage.)

`namae` uses a formal grammar, unlike this gem, and so probably captures some
cases this does not, although it certainly also misses some which this captures.

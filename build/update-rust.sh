#!/bin/bash

set -eou pipefail

if ! command -v cargo &> /dev/null
then
  curl https://sh.rustup.rs -sSf | sh -s
fi

mkdir tmp
pushd tmp
git clone https://github.com/djudd/human-name.git
cd human-name
cargo build --release
popd

cp tmp/human-name/target/release/libhuman_name.dylib lib/
rm -rf tmp


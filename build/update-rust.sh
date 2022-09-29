#!/bin/bash

set -eou pipefail

if ! command -v cargo &> /dev/null
then
  curl https://sh.rustup.rs -sSf | sh -s
fi

TMP=$(mktemp -d)
trap 'rm -rf -- "$TMP"' EXIT

pushd "$TMP"
git clone https://github.com/djudd/human-name.git
cd human-name
rustup target add x86_64-apple-darwin
cargo build --target x86_64-apple-darwin --release
rustup target add x86_64-unknown-linux-gnu
cargo build --target x86_64-unknown-linux-gnu --release
popd

cp "$TMP/human-name/target/release/libhuman_name.dylib" lib/
cp "$TMP/human-name/target/release/libhuman_name.so" lib/

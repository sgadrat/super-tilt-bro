#!/bin/bash

set -x
set -e

out_dir=$(readlink -f "$(dirname "$0")/..")

build_xa() {
	cd "$out_dir"
	rm -rf xa65-stb

	git clone https://github.com/sgadrat/xa65-stb.git
	cd xa65-stb/xa
	make -j
}

build_xa

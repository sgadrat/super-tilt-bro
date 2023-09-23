#!/bin/bash

set -x
set -e

out_dir=$(readlink -f "$(dirname "$0")/..")

#
# Huffmunch
#

build_huffmunch() {
	cd "$out_dir"
	rm -rf huffmunch

	git clone https://github.com/bbbradsmith/huffmunch.git

	cd huffmunch
	make -j
}

build_huffmunch

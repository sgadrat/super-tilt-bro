#!/bin/bash

set -x
set -e

out_dir=$(readlink -f "$(dirname "$0")/..")

get_cc65() {
	local cc_version=2.19

	cd "$out_dir"
	rm -rf cc65-$cc_version
	rm -rf cc65

	curl -L https://github.com/cc65/cc65/archive/refs/tags/V$cc_version.tar.gz | tar xz
	mv cc65-$cc_version cc65
	cd cc65/
	make # May fail with "-j" because conflicting temporary files
}

get_cc65

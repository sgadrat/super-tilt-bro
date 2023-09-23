#!/bin/bash

set -x
set -e

out_dir=$(readlink -f "$(dirname "$0")/..")

install_gcc_build_dependencies() {
	local dependencies="flex build-essential gcc git libboost-dev libboost-regex-dev libgmp-dev libmpfr-dev libmpc-dev"

	if [ "$UID" -eq 0 ]; then
		apt install -y $dependencies
	else
		if [ -z "$FORCE_INSTALLS" ] ; then
			echo "Skipped GCC build dependency installation: no root privilege"
		else
			sudo apt install -y $dependencies
		fi
	fi
}

build_gcc() {
	cd "$out_dir"
	rm -rf gcc-6502-bits

	git clone --recursive https://github.com/itszor/gcc-6502-bits.git
	cd gcc-6502-bits
	./build.sh
}

install_gcc_build_dependencies
build_gcc

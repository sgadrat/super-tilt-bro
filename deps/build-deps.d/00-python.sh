#!/bin/bash

set -x
set -e

out_dir=$(readlink -f "$(dirname "$0")/..")

if [ "$UID" -eq 0 -o ! -z "$FORCE_INSTALLS" ]; then
	if which apt > /dev/null 2>&1 ; then
		sudo apt install -y python3 python3-pip python-is-python3
		pip3 install -U pip

		if which pip > /dev/null 2>&1 ; then
			pip_cmd=pip
		else
			pip_cmd=pip3
		fi

		$pip_cmd install --upgrade pillow
	elif which apk > /dev/null 2>&1 ; then
		apk add python3 py3-pillow
	fi
fi

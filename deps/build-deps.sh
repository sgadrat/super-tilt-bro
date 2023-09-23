#!/bin/bash

set -x
set -e

out_dir=$(readlink -f "$(dirname "$0")")

cd "$out_dir"
for f in build-deps.d/* ; do
	$f
done

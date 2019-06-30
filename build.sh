#!/bin/bash

set -e
set -x

root_dir=`dirname "$0"`

#TODO check dependencies (python >= 3.2, xa, pillow)

# Clean generated files
# TODO do not hardcode character names here
rm -rf "${root_dir}"/game/data/characters/{sinbad,squareman,characters-index.asm}

# Compile game mod
PYTHONPATH="${root_dir}/tools:$PYTHONPATH" "${root_dir}/tools/compile-mod.py" "${root_dir}/game-mod/mod.json" "${root_dir}"

# Assemble the game
cd "${root_dir}"
xa tilt.asm -C -o tilt\(E\).nes

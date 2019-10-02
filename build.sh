#!/bin/bash

set -e

root_dir=`readlink -m $(dirname "$0")`
log_file="${root_dir}/build.log"

# Print a message in console and log file
say() {
	echo "$@"
	echo "$@" >> "$log_file"
}

# Print a message in log file
log() {
	echo "$@" >> "$log_file"
}

# Execute a command while logging its output
cmd() {
	echo >> "$log_file"
	echo "+ $@" >> "$log_file"
	$@ >> "$log_file" 2>&1
}

#TODO check dependencies (python >= 3.2, xa, pillow)

# Clean old build log
cd "${root_dir}"
rm -f "$log_file"

# Clean generated files
# TODO do not hardcode character names here
say "Clean ..."
log "========="
cmd rm -rf "${root_dir}"/game/data/characters/{sinbad,kiki,characters-index.asm} "${root_dir}"/game/data/tilesets/ruins.asm

# Compile game mod
log
say "Compile game mod ..."
log "===================="
PYTHONPATH="${root_dir}/tools:$PYTHONPATH" cmd "${root_dir}/tools/compile-mod.py" "${root_dir}/game-mod/mod.json" "${root_dir}"

# Assemble the game
log
say "Assemble the game ..."
log "====================="
cmd xa tilt.asm -C -o 'Super_Tilt_Bro_(E).nes'

say
say "======================="
say "Game built successfuly."
say "======================="

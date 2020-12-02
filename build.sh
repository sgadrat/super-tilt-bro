#!/bin/bash

set -e

xa_bin="${XA_BIN:-xa}"
cc_bin="${CC_BIN:-6502-gcc}"
perf_listings="${XA_LST:-0}"

root_dir=`readlink -m $(dirname "$0")`
log_file="${root_dir}/build.log"

c_optim="-Os"
c_warnings="-Wall -Wextra -Werror"
c_compat="-fdelete-null-pointer-checks -fno-isolate-erroneous-paths-dereference" # We may want to dereference address zero at times
c_flags="$c_optim $c_warnings $c_compat"

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

# Execute a command while logging its output only if it fails
exe() {
	echo "+ $@" >> "$log_file.err"
	$@ >> "$log_file.err" 2>&1
	rm "$log_file.err"
}

# Assemble the game with specific options
asm() {
	local log_dest="$1"
	local rom_name="$2"
	local asm_flags="$3"

	local listing_opts=""
	if [ $perf_listings -ne 0 ]; then
		listing_opts="-P /tmp/$rom_name.lst"
	fi

	"$log_dest" "$xa_bin" $asm_flags tilt.asm -C -o "$rom_name.nes" $listing_opts
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

for f in `find . -name '*.build.asm'`; do
	cmd rm "$f"
done

# Compile game mod
log
say "Compile game mod ..."
log "===================="
PYTHONPATH="${root_dir}/tools:$PYTHONPATH" cmd "${root_dir}/tools/compile-mod.py" "${root_dir}/game-mod/mod.json" "${root_dir}"

# Compile C files
log
say "Compile C files ..."
log "==================="

tools/c_constants_files.py

for c_source in `find . -name '*.c'`; do
	asm_source="`dirname "$c_source"`/`basename "$c_source" .c`.built.asm"
	"$cc_bin" $c_source -S -I game/ $c_flags -o "$asm_source"
	tools/asm_converter.py "$asm_source"
done

# Assemble the game
log
say "Assemble the game ..."
log "====================="
asm cmd 'Super_Tilt_Bro_(E)'           ''
asm exe 'server_bytecode'              '-DSERVER_BYTECODE -DNO_INES_HEADER'
asm exe 'tilt_ai_(E)'                  '-DNETWORK_AI'
asm exe 'tilt_no_network_(E)'          '-DNO_NETWORK'
asm exe 'tilt_rainbow512_(E)'          '-DMAPPER_RAINBOW512'
asm exe 'tilt_no_network_unrom512_(E)' '-DNO_NETWORK -DMAPPER_UNROM512'
asm exe 'tilt_no_network_unrom_(E)'    '-DNO_NETWORK -DMAPPER_UNROM'

say
say "======================="
say "Game built successfuly."
say "======================="

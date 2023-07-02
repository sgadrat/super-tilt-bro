#!/bin/bash

set -e

xa_bin="${XA_BIN:-xa}"
cc_bin="${CC_BIN:-6502-gcc}"
perf_listings="${XA_LST:-0}"
force_network="${FORCE_NETWORK:-0}"
local_login="${LOCAL_LOGIN:-0}"
skip_c="${SKIP_C:-0}" # 0 - build C files, 1 - Skip files older than their ASM, 2 - Skip ALL

root_dir=`readlink -m $(dirname "$0")`
log_file="${root_dir}/build.log"

no_network_flag='-DNO_NETWORK'
if [ $force_network -ne 0 ]; then
	no_network_flag='-DFORCE_NETWORK'
fi

c_optim="-Os"
c_warnings="-Wall -Wextra -Werror"
c_compat="-fdelete-null-pointer-checks -fno-isolate-erroneous-paths-dereference" # We may want to dereference address zero at times
c_defines="$no_network_flag"
if [ $local_login -ne 0 ]; then
	c_defines+=" -DLOCAL_LOGIN_SERVER"
fi
c_flags="$c_optim $c_warnings $c_compat $c_defines"

# Print a message in console and log file
say_color=0
say() {
	if [ $say_color -eq 0 ]; then
		echo "$@"
	else
		echo -e "\e[${say_color}m$@\e[0m"
		say_color=0
	fi
	echo "$@" >> "$log_file"
}

sayc() {
	say_color="$1"
	shift

	say $@
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

# Execute a command after logging it
run() {
	echo >> "$log_file"
	echo "+ $@" >> "$log_file"
	$@
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
say "Clean ..."
log "========="

cmd rm -rf "${root_dir}"/game/data/characters/{characters-data,characters-index.asm} "${root_dir}"/game/data/tilesets/ruins.asm

for f in `find . -name '*.build.asm'`; do
	cmd rm "$f"
done

# Compile game mod
log
say "Compile game mod ..."
log "===================="
PYTHONPATH="${root_dir}/tools:$PYTHONPATH" cmd "${root_dir}/tools/compile-mod.py" --tpl-dir "${root_dir}/game/templates" "${root_dir}/game-mod/mod.json" "${root_dir}"

# Pass pre-preprocessor
#TODO Remove: obsoleted by handling of *.tpl.asm which is more feature complete
#     (existing .pp.asm files must be converted to .tpl.asm)
log
say "Pre-preprocessor ..."
log "===================="

for ppp_source in `find . -name '*.pp.asm'`; do
	asm_source="`dirname "$ppp_source"`/`basename "$ppp_source" .pp.asm`.built.asm"
	run tools/slow_prepocessor.py "$ppp_source" > "$asm_source"
done

# Expand templates
log
say "Expand templates ..."
log "===================="

for tpl_source in `find . -name '*.tpl.asm'`; do
	asm_source="`dirname "$tpl_source"`/`basename "$tpl_source" .tpl.asm`.built.asm"
	run tools/expand_tpl.py --tpl-dir "$root_dir/game/templates" "$tpl_source" "$root_dir" > "$asm_source"
done

# Compile C files
if [ $skip_c -ne 2 ]; then
log
say "Compile C files ..."
log "==================="

tools/c_constants_files.py

for c_source in `find . -name '*.c'`; do
	asm_source="`dirname "$c_source"`/`basename "$c_source" .c`.built.asm"

	if [ -f "$asm_source" ]; then
		last_build_date=$(date -r "$asm_source" +%s)
	else
		last_build_date=0
	fi
	last_update_time=$(date -r "$c_source" +%s)

	if [ $skip_c -eq 0 -o $last_update_time -gt $last_build_date ]; then
		if [ $skip_c -ne 0 ]; then
			echo -e "\tBUILD $c_source"
		fi
		run "$cc_bin" $c_source -S -I game/ $c_flags -o "$asm_source"
		tools/asm_converter.py "$asm_source"
	fi
done
fi

# Check that rescue code can build without the rest of the game
#  It must bear absolutely no dependency from game code
log
say "Check rescue build ..."
log "======================"
cmd "$xa_bin" rescue.asm -C -o "rescue.prg" -P /tmp/rescue.lst

# Assemble the game
log
say "Assemble the game ..."
log "====================="
asm cmd 'Super_Tilt_Bro_(E)'           ""
asm exe 'server_bytecode'              "-DSERVER_BYTECODE -DNO_INES_HEADER"
asm exe 'tilt_no_network_(E)'          "$no_network_flag"
asm exe 'tilt_rainbow512_(E)'          "-DMAPPER_RAINBOW512"
asm exe 'tilt_no_network_unrom512_(E)' "$no_network_flag -DMAPPER_UNROM512"
asm exe 'tilt_no_network_unrom_(E)'    "$no_network_flag -DMAPPER_UNROM"

# Check that rescue code in ROM is exactly as built independently
#  We re-build it with the ROM, instead of including binaries, to have its code listed "Super_Tilt_Bro_(E).lst"
#  We want to be sure that assembling options or inclusion in larger code base did not modify the generated code
log
say "Check rescue integration ..."
log "============================"
rescue_hash=$(md5sum rescue.prg | grep -Eo '^[0-9a-f]+')
rescue_rom_hash=$(tail -c +17 'Super_Tilt_Bro_(E).nes' | head -c $((64*1024)) | md5sum - | grep -Eo '^[0-9a-f]+')
if [ "$rescue_rom_hash" != "$rescue_hash" ]; then
	say "ERROR: rescue code differs in ROM than built alone"
	say "rescue code built alone: cat rescue.prg"
	say 'rescue built in ROM: tail -c +17 "Super_Tilt_Bro_(E).nes" | head -c $((64*1024))'
	exit 1
fi

say
say "======================="
say "Game built successfuly."
say "======================="

# Check that rescue code did not change
#  Rescue code cannot be safely upgraded, and first published version shall work regardless of the rest of the ROM, so avoid modifying it.
#  Only a warning for ease of development, should be an error when carts are distributed to non-technical players.
if [ "$rescue_rom_hash" != '6f1c5ee2cdbe9c383013c7770a24df52' ]; then
	sayc 41 "WARNING: rescue code changed"
	sayc 41 "============================"
fi

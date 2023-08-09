#!/bin/bash

set -e

xa_bin="${XA_BIN:-xa}"
cc_bin="${CC_BIN:-6502-gcc}"
huffmunch_bin="${HUFFMUNCH_BIN:-huffmunch}"
perf_listings="${XA_LST:-0}"
force_network="${FORCE_NETWORK:-0}"
local_login="${LOCAL_LOGIN:-0}"
skip_c="${SKIP_C:-0}" # 0 - build C files, 1 - Skip files older than their ASM, 2 - Skip ALL
skip_rescue_img="${SKIP_RESCUE_IMG:-0}"

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

# Build rescue image
if [ "$skip_rescue_img" -ne 2 ]; then
	log
	say "Build rescue image ..."
	log "======================"

	# Numeric constants
	bank_size=$((16*1024))
	n_game_banks=32
	game_size=$((n_game_banks*bank_size))
	chunk_size=256
	ines_header_size=16
	n_rescue_banks=4
	segment_size=1024

	# Paths
	rescue_img_dir="rescue_img"

	# Build rescue image
	if [ "$skip_rescue_img" -eq 0 -o ! -f "$rescue_img_dir/rescue_img.bin" ]; then

		# Create output path
		rm -rf "$rescue_img_dir"
		mkdir -p "$rescue_img_dir"

		# Extract game banks from built ROM
		tail -c +$((ines_header_size + n_rescue_banks*bank_size + 1)) 'Super_Tilt_Bro_(E).nes' | head -c $game_size > "$rescue_img_dir/tilt_game.prg"

		# Compute CRC32 of segments
		python -c "$(cat <<EOF
import binascii
import struct
import sys
assert binascii.crc32(b'hello-world') == 2983461467, 'binascii.crc32 returns signed numbers (python2 behaviour)'
with open("$rescue_img_dir/tilt_game.prg", "rb") as prg:
	segment = prg.read($segment_size)
	while len(segment) > 0:
		assert len(segment) == $segment_size, f'unexpected end of tilt_game.prg: last segment is {len(segment)} bytes instead of {$segment_size}'
		sys.stdout.buffer.write(struct.pack('<I', binascii.crc32(segment)))
		segment = prg.read($segment_size)
EOF
		)
		" > "$rescue_img_dir/segments_crc.bin"

		# Compress game banks
		echo 0 $bank_size > "$rescue_img_dir/huffmunch.lst"
		for i in $(seq 0 $(((game_size/chunk_size)-1))); do
			echo $((i*chunk_size)) $(((i+1)*chunk_size)) "$rescue_img_dir/tilt_game.prg" >> "$rescue_img_dir/huffmunch.lst"
		done
		cmd "$huffmunch_bin" -L "$rescue_img_dir/huffmunch.lst" "$rescue_img_dir/rescue.hfm"
		n_compressed_banks=$(ls "$rescue_img_dir"/rescue0*.hfm | wc -l)

		# Make each compressed bank exactly 16K
		for f in "$rescue_img_dir"/rescue0*.hfm; do
			truncate -s 16K "$f";
		done

		# Build index bank
		index_table_size=$((2*n_compressed_banks))
		crc_size=$((4 * game_size / segment_size))
		footer_size=1
		free_size=$((bank_size - index_table_size - crc_size - footer_size))
		rm -f "$rescue_img_dir/rescue_index.bank"
		cat "$rescue_img_dir/segments_crc.bin" >> "$rescue_img_dir/rescue_index.bank"          # Segments CRCs
		head -c $free_size /dev/zero >> "$rescue_img_dir/rescue_index.bank"                    # Padding
		cat "$rescue_img_dir/rescue.hfm" >> "$rescue_img_dir/rescue_index.bank"                # Index
		echo -en "\x$(printf %02x $n_compressed_banks)" >> "$rescue_img_dir/rescue_index.bank" # Number of compressed banks

		# Build full rescue image
		rm -f "$rescue_img_dir/rescue_img.bin"
		cat "$rescue_img_dir/"rescue0*.hfm >> "$rescue_img_dir/rescue_img.bin"
		cat "$rescue_img_dir/rescue_index.bank" >> "$rescue_img_dir/rescue_img.bin"
	fi

	# Override last banks of Rainbow ROM with rescue image
	n_compressed_banks=$(ls "$rescue_img_dir"/rescue0*.hfm | wc -l) #NOTE: may have not been computed if partial skip
	nes_file_size=$((ines_header_size + 64 * bank_size))
	rescue_img_size=$(((n_compressed_banks+1) * bank_size))
	cp 'Super_Tilt_Bro_(E).nes' "$rescue_img_dir/tilt_rainbow.nes"
	truncate -s $((nes_file_size - rescue_img_size)) "$rescue_img_dir/tilt_rainbow.nes"
	cat "$rescue_img_dir/tilt_rainbow.nes" "$rescue_img_dir/rescue_img.bin" > 'Super_Tilt_Bro_(E).nes'
fi

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
if [ "$rescue_rom_hash" != 'bad33fb258f412c929d8afe45f4e11e6' ]; then
	sayc 41 "WARNING: rescue code changed"
	sayc 41 "============================"
fi

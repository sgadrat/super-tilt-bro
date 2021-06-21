#!/usr/bin/env python

"""
Read a ftm text export and convert it to a json structure closely matching stb binary format
"""

import copy
import ftmtxt
import ftmmanip
import json
import sys

# Parameters
if len(sys.argv) < 2 or sys.argv[1].lower in ['-h', '--help']:
	print('usage: {} source_file [max_optim]'.format(sys.argv[0]))
	print()
	print('\tsource_file\tFamitracker module text export')
	print('\tmax_optim\tMeximal number of optimization pass')
	sys.exit(1)

SOURCE_FILE_PATH = sys.argv[1]
MAX_OPTIM_PASSES = 0 if len(sys.argv) < 3 else int(sys.argv[2])

# Logging
def log(msg):
	sys.stderr.write('{}\n'.format(msg))
def info(msg):
	log('   INFO: {}'.format(msg))
def warn(msg):
	log('WARNING: {}'.format(msg))

ftmmanip.warn = warn
ftmtxt.warn = warn

# Read original file
with open(SOURCE_FILE_PATH, 'r') as f:
	music = ftmtxt.to_dict(f)

# Simplify structure
#  * pre-interpreting effects not handled by the engine
#  * standardizing things
#  * ... (whatever is a direct translation of the original with less things to handle)
music = ftmmanip.get_num_channels(music)
music = ftmmanip.flatten_orders(music)
music = ftmmanip.unroll_f_effect(music)
music = ftmmanip.cut_at_b_effect(music)
music = ftmmanip.apply_g_effect(music)
music = ftmmanip.apply_d_effect(music)
music = ftmmanip.apply_s_effect(music)
music = ftmmanip.apply_a_effect(music)
music = ftmmanip.remove_instruments(music)
music = ftmmanip.remove_useless_pitch_effects(music)
music = ftmmanip.apply_q_effect(music)
music = ftmmanip.apply_r_effect(music)
music = ftmmanip.repeat_3_effect(music)
music = ftmmanip.apply_3_effect(music)
music = ftmmanip.apply_4_effect(music)

# Compatibility checks
music = ftmmanip.warn_instruments(music)
music = ftmmanip.warn_effects(music)

# Transform to stb audio format
music = ftmmanip.remove_superfluous_volume(music)
music = ftmmanip.remove_superfluous_duty(music)
music = ftmmanip.std_empty_row(music)
music = ftmmanip.to_uncompressed_format(music)

music = ftmmanip.remove_duplicates(music)
music = ftmmanip.aggregate_lines(music)
music = ftmmanip.compute_note_length(music)
music = ftmmanip.to_mod_format(music)

# Optimize
music = ftmmanip.optim_pulse_opcodes_to_meta(music)

optimal = False
pass_num = 0
while not optimal and pass_num < MAX_OPTIM_PASSES:
	pass_num += 1
	info('optimization pass #{}'.format(pass_num))

	original_music_mod = copy.deepcopy(music['mod'])

	music = ftmmanip.split_samples(music)
	music = ftmmanip.reuse_samples(music)
	music = ftmmanip.remove_unused_samples(music)

	if music['mod'] == original_music_mod:
		optimal = True

# Transform to asm
music = ftmmanip.samples_to_source(music)

# Compute misc info
music = ftmmanip.compute_stats(music)

# Show result
print(json.dumps(music))

#!/usr/bin/env python

"""
Read a ftm text export and convert it to a json structure closely matching stb binary format
"""

import copy
import datetime
import debugtools
import ftmtxt
import ftmmanip
import json
import sys
import time

# Parameters
if len(sys.argv) < 2 or sys.argv[1].lower() in ['-h', '--help']:
	print('usage: {} source_file [max_optim] [out_file]'.format(sys.argv[0]))
	print()
	print('\tsource_file\tFamitracker module text export')
	print('\tmax_optim\tMaximal number of optimization pass')
	print('\tout_file\tOutput file, stdout by default')
	sys.exit(1)

SOURCE_FILE_PATH = sys.argv[1]
MAX_OPTIM_PASSES = 0 if len(sys.argv) < 3 else int(sys.argv[2])
OUT_FILE_PATH = None if len(sys.argv) < 4 else sys.argv[3]
VERBOSE = False

# Logging
def logdate():
	return datetime.datetime.fromtimestamp(time.time()).isoformat()
def log(msg):
	sys.stderr.write('{}\n'.format(msg))
def debug(msg):
	if VERBOSE:
		log('  DEBUG: [{}] {}'.format(logdate(), msg))
def info(msg):
	log('   INFO: [{}] {}'.format(logdate(), msg))
def notice(msg):
	log(' NOTICE: {}'.format(msg))
def warn(msg):
	log('WARNING: {}'.format(msg))

ftmmanip.debug = debug
ftmmanip.notice = notice
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
music = ftmmanip.unroll_speed(music)
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
music = ftmmanip.merge_pitch_slides(music)
#print(debugtools.human_readable_track(music['tracks'][0]))

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
total_size = -1
while not optimal and pass_num < MAX_OPTIM_PASSES:
	pass_num += 1
	info('optimization pass #{} (size={} bytes, index_filling=[{}])'.format(
		pass_num,
		total_size,
		[len(x) for x in music['mod']['channels']]
	))

	original_music_mod = copy.deepcopy(music['mod'])

	debug('optim: split_samples')
	music = ftmmanip.split_samples(music)
	debug('optim: reuse_samples')
	music = ftmmanip.reuse_samples(music)
	debug('optim: remove_unused_samples')
	music = ftmmanip.remove_unused_samples(music)

	debug('optim: save result')
	if OUT_FILE_PATH is not None:
		saved = copy.deepcopy(music)
		saved = ftmmanip.samples_to_source(saved)
		saved = ftmmanip.compute_stats(saved)
		total_size = saved['stats']['total_size']
		with open(OUT_FILE_PATH, 'w') as out_file:
			json.dump(saved, out_file)

	if music['mod'] == original_music_mod:
		optimal = True

# Transform to asm
music = ftmmanip.samples_to_source(music)

# Compute misc info
music = ftmmanip.compute_stats(music)

# Show result
if OUT_FILE_PATH is None:
	print(json.dumps(music))
elif MAX_OPTIM_PASSES == 0:
	with open(OUT_FILE_PATH, 'w') as out_file:
		json.dump(music, out_file)

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
	print('usage: {} source_file [track] [max_optim] [out_file]'.format(sys.argv[0]))
	print()
	print('\tsource_file\tFamitracker module text export')
	print('\ttrack\tIndex of the track to extract, begining at zero for the first track (default: 0, first track)')
	print('\tmax_optim\tMaximal number of optimization pass (default: 0, no optim)')
	print('\tout_file\tOutput file, stdout by default')
	sys.exit(1)

SOURCE_FILE_PATH = sys.argv[1]
TRACK_INDEX = 0 if len(sys.argv) < 3 else int(sys.argv[2])
MAX_OPTIM_PASSES = 0 if len(sys.argv) < 4 else int(sys.argv[3])
OUT_FILE_PATH = None if len(sys.argv) < 5 else sys.argv[4]
VERBOSE = False

if OUT_FILE_PATH == '-':
	OUT_FILE_PATH = None

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
def error(msg):
	log('  ERROR: {}'.format(msg))

ftmmanip.debug = debug
ftmmanip.notice = notice
ftmmanip.warn = warn
ftmmanip.error = error
ftmtxt.warn = warn

# Read original file
with open(SOURCE_FILE_PATH, 'r', encoding='latin1') as f:
	music = ftmtxt.to_dict(f)

# Simplify structure
#  * pre-interpreting effects not handled by the engine
#  * standardizing things
#  * ... (whatever is a direct translation of the original with less things to handle)
music = ftmmanip.annotate_chanrows_sources(music)
music = ftmmanip.isolate_track(music, TRACK_INDEX)
music = ftmmanip.get_num_channels(music)
music = ftmmanip.flatten_orders(music)
music = ftmmanip.annotate_chanrows_order(music)
music = ftmmanip.unroll_speed(music)
music = ftmmanip.apply_forward_b_effect(music)
music = ftmmanip.apply_backward_b_effect(music)
music = ftmmanip.apply_d_effect(music)
music = ftmmanip.apply_g_effect(music)
music = ftmmanip.apply_s_effect(music)
music = ftmmanip.apply_e_effect(music)
music = ftmmanip.apply_a_effect(music)
music = ftmmanip.apply_7_effect(music)
music = ftmmanip.remove_instruments(music) # May need arp_force_absolute_notes=True for some Famitracker tracks (see docstring)
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

#music = ftmmanip.big_samples(music)
music = ftmmanip.extend_empty_rows(music)
music = ftmmanip.adapt_tempo(music)

music = ftmmanip.remove_duplicates(music)
music = ftmmanip.aggregate_lines(music)
music = ftmmanip.compute_note_length(music)
music = ftmmanip.to_mod_format(music)

# Optimize
music = ftmmanip.optim_pulse_opcodes_to_meta(music)

saved = copy.deepcopy(music)
saved = ftmmanip.samples_to_source(saved)
saved = ftmmanip.compute_stats(saved)
total_size = saved['stats']['total_size']

optimal = False
pass_num = 0
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

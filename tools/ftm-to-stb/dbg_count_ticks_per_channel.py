#!/usr/bin/env python
import json
import sys

DEFAULT_NOTE_DUR = 5

# Opcodes info
timed_opcodes = {
    '2a03_pulse.PLAY_TIMED_FREQ': {"dur_field": 1, "adjust": 0},
    '2a03_pulse.PLAY_NOTE': lambda x: DEFAULT_NOTE_DUR,
    '2a03_pulse.PLAY_TIMED_NOTE': {"dur_field": 0, "adjust": 1},
    '2a03_pulse.WAIT': {"dur_field": 0, "adjust": 1},
    '2a03_pulse.LONG_WAIT': {"dur_field": 0, "adjust": 0},
    '2a03_pulse.HALT': {"dur_field": 0, "adjust": 1},
    '2a03_pulse.AUDIO_PULSE_FREQUENCY_ADD': {"dur_field": 1, "adjust": 0},
    '2a03_pulse.AUDIO_PULSE_FREQUENCY_SUB': {"dur_field": 1, "adjust": 0},
    '2a03_pulse.AUDIO_PULSE_META_NOTE': {"dur_field": 1, "adjust": 0},
    '2a03_pulse.AUDIO_PULSE_META_NOTE_VOL': {"dur_field": 1, "adjust": 0},
    '2a03_pulse.AUDIO_PULSE_META_NOTE_DUT': {"dur_field": 1, "adjust": 0},
    '2a03_pulse.AUDIO_PULSE_META_NOTE_DUT_VOL': {"dur_field": 1, "adjust": 0},
    '2a03_pulse.AUDIO_PULSE_META_NOTE_USLIDE': {"dur_field": 1, "adjust": 0},
    '2a03_pulse.AUDIO_PULSE_META_NOTE_DSLIDE': {"dur_field": 1, "adjust": 0},
    '2a03_pulse.AUDIO_PULSE_META_NOTE_VOL_USLIDE': {"dur_field": 1, "adjust": 0},
    '2a03_pulse.AUDIO_PULSE_META_NOTE_VOL_DSLIDE': {"dur_field": 1, "adjust": 0},
    '2a03_pulse.AUDIO_PULSE_META_NOTE_DUT_USLIDE': {"dur_field": 1, "adjust": 0},
    '2a03_pulse.AUDIO_PULSE_META_NOTE_DUT_DSLIDE': {"dur_field": 1, "adjust": 0},
    '2a03_pulse.AUDIO_PULSE_META_NOTE_DUT_VOL_USLIDE': {"dur_field": 1, "adjust": 0},
    '2a03_pulse.AUDIO_PULSE_META_NOTE_DUT_VOL_DSLIDE': {"dur_field": 1, "adjust": 0},
    '2a03_pulse.AUDIO_PULSE_META_WAIT': {"dur_field": 0, "adjust": 0},
    '2a03_pulse.AUDIO_PULSE_META_WAIT_VOL': {"dur_field": 0, "adjust": 0},
    '2a03_pulse.AUDIO_PULSE_META_WAIT_DUT': {"dur_field": 0, "adjust": 0},
    '2a03_pulse.AUDIO_PULSE_META_WAIT_DUT_VOL': {"dur_field": 0, "adjust": 0},
    '2a03_pulse.AUDIO_PULSE_META_WAIT_USLIDE': {"dur_field": 0, "adjust": 0},
    '2a03_pulse.AUDIO_PULSE_META_WAIT_DSLIDE': {"dur_field": 0, "adjust": 0},
    '2a03_pulse.AUDIO_PULSE_META_WAIT_VOL_USLIDE': {"dur_field": 0, "adjust": 0},
    '2a03_pulse.AUDIO_PULSE_META_WAIT_VOL_DSLIDE': {"dur_field": 0, "adjust": 0},
    '2a03_pulse.AUDIO_PULSE_META_WAIT_DUT_USLIDE': {"dur_field": 0, "adjust": 0},
    '2a03_pulse.AUDIO_PULSE_META_WAIT_DUT_DSLIDE': {"dur_field": 0, "adjust": 0},
    '2a03_pulse.AUDIO_PULSE_META_WAIT_DUT_VOL_USLIDE': {"dur_field": 0, "adjust": 0},
    '2a03_pulse.AUDIO_PULSE_META_WAIT_DUT_VOL_DSLIDE': {"dur_field": 0, "adjust": 0},
    '2a03_noise.PLAY_TIMED_FREQ': {"dur_field": 1, "adjust": 0},
    '2a03_noise.WAIT': {"dur_field": 0, "adjust": 1},
    '2a03_noise.LONG_WAIT': {"dur_field": 0, "adjust": 0},
    '2a03_noise.HALT': {"dur_field": 0, "adjust": 1},
}

# Utility functions
def ensure(cond, msg = None):
	"""
	assert-like to be used for fatal runtime errors

	assert should be used only for logical errors that should never occur (and are programmer's fault)
	ensure cannot be deactivated by compilation optimizations, and should be used to indicate a flaw in input data
	"""
	if not cond:
		raise Exception(msg)

def compute_sample_dur(sample):
	sample_type = sample['type']
	if sample_type == 'music_sample_2a03_triangle':
		sample_type = 'music_sample_2a03_pulse' # HACK triangle holds pulse opcodes. We don't care about the difference here.

	short_type = sample_type[13:]
	duration = 0
	for opcode in sample['opcodes']:
		ensure(opcode['type'] == sample_type + '_opcode', 'opcode type missmatch sample type: sample={} opcode={}'.format(sample_type, opcode['type']))
		opcode_full_name = '{}.{}'.format(short_type, opcode['name'])

		if opcode_full_name in timed_opcodes:
			opcode_info = timed_opcodes[opcode_full_name]
			if isinstance(opcode_info, dict):
				duration += opcode['parameters'][opcode_info['dur_field']] + opcode_info['adjust']
			else:
				duration += timed_opcodes['opcode_full_name'](opcode)

	return duration

# Load music
music_path = sys.argv[1]
music = None
with open(music_path, 'r') as music_file:
	music = json.load(music_file)

# Check that all channels' duration are the same
mod = music['mod']
for channel_idx in range(len(mod['channels'])):
	chan_samples_idx = mod['channels'][channel_idx]

	# Compute duration of each sample consituing the channel
	chan_samples_dur = []
	for sample_idx in chan_samples_idx:
		chan_samples_dur.append(compute_sample_dur(mod['samples'][sample_idx]))

	# Compute derived information
	total_dur = 0
	for sample_dur in chan_samples_dur:
		total_dur += sample_dur

	# Print information
	print('{} = {}'.format(total_dur, ' + '.join([str(x) for x in chan_samples_dur])))

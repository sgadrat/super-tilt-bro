import copy
import re
import sys

#
# Error handling functions
#

def debug(msg):
	"""
	Debugging messages that are highly situational and may sometimes help the developper
	"""
	sys.stderr.write('{}\n'.format(msg))

def notice(msg):
	"""
	Normal processing that may have audible impact but cannot be handled perfectly
	"""
	sys.stderr.write('{}\n'.format(msg))

def warn(msg):
	"""
	Possible inconsistency with what the original music
	"""
	sys.stderr.write('{}\n'.format(msg))

def error(msg):
	"""
	Non fatal, but highly impacting. The converted music will not sound like the original.
	"""
	sys.stderr.write('{}\n'.format(msg))

def ensure(cond, msg = None):
	"""
	assert-like to be used for fatal runtime errors

	assert should be used only for logical errors that should never occur (and are programmer's fault)
	ensure cannot be deactivated by compilation optimizations, and should be used to indicate a flaw in input data
	"""
	if not cond:
		raise Exception(msg)

#
# Common knowledge data
#

note_table_names = [
	'C-0', 'C#0', 'D-0', 'D#0', 'E-0', 'F-0', 'F#0', 'G-0', 'G#0', 'A-0', 'A#0', 'B-0',
	'C-1', 'C#1', 'D-1', 'D#1', 'E-1', 'F-1', 'F#1', 'G-1', 'G#1', 'A-1', 'A#1', 'B-1',
	'C-2', 'C#2', 'D-2', 'D#2', 'E-2', 'F-2', 'F#2', 'G-2', 'G#2', 'A-2', 'A#2', 'B-2',
	'C-3', 'C#3', 'D-3', 'D#3', 'E-3', 'F-3', 'F#3', 'G-3', 'G#3', 'A-3', 'A#3', 'B-3',
	'C-4', 'C#4', 'D-4', 'D#4', 'E-4', 'F-4', 'F#4', 'G-4', 'G#4', 'A-4', 'A#4', 'B-4',
	'C-5', 'C#5', 'D-5', 'D#5', 'E-5', 'F-5', 'F#5', 'G-5', 'G#5', 'A-5', 'A#5', 'B-5',
	'C-6', 'C#6', 'D-6', 'D#6', 'E-6', 'F-6', 'F#6', 'G-6', 'G#6', 'A-6', 'A#6', 'B-6',
	'C-7', 'C#7', 'D-7', 'D#7', 'E-7', 'F-7', 'F#7', 'G-7', 'G#7', 'A-7', 'A#7', 'B-7',
]

note_table_freqs = [
	0x7ff, 0x7ff, 0x7ff, 0x7ff, 0x7ff, 0x7ff, 0x7ff, 0x7ff, 0x7d1, 0x760, 0x6f6, 0x692,
	0x634, 0x5da, 0x586, 0x537, 0x4ec, 0x4a5, 0x462, 0x423, 0x3e8, 0x3b0, 0x37b, 0x349,
	0x319, 0x2ed, 0x2c3, 0x29b, 0x276, 0x252, 0x231, 0x211, 0x1f3, 0x1d7, 0x1bd, 0x1a4,
	0x18c, 0x176, 0x161, 0x14d, 0x13a, 0x129, 0x118, 0x108, 0x0f9, 0x0eb, 0x0de, 0x0d1,
	0x0c6, 0x0ba, 0x0b0, 0x0a6, 0x09d, 0x094, 0x08b, 0x084, 0x07c, 0x075, 0x06e, 0x068,
	0x062, 0x05d, 0x057, 0x052, 0x04e, 0x049, 0x045, 0x041, 0x03e, 0x03a, 0x037, 0x034,
	0x031, 0x02e, 0x02b, 0x029, 0x026, 0x024, 0x022, 0x020, 0x01e, 0x01d, 0x01b, 0x019,
	0x018, 0x016, 0x015, 0x014, 0x013, 0x012, 0x011, 0x010, 0x00f, 0x00e, 0x00d, 0x00c,
]

pitch_effects = ['0', '1', '2', '3', '4', 'Q', 'R']
volume_effects = ['7', 'A', 'E']

uctf_fields_by_type = {
	'2a03-pulse': ['note', 'frequency_adjust', 'volume', 'duty', 'pitch_slide'],
	'2a03-triangle': ['note', 'frequency_adjust', 'pitch_slide'],
	'2a03-noise': ['freq', 'frequency_adjust', 'volume', 'periodic', 'pitch_slide'],
}

timed_opcodes = [
	'2a03_pulse.PLAY_TIMED_FREQ',
	'2a03_pulse.PLAY_NOTE',
	'2a03_pulse.PLAY_TIMED_NOTE',
	'2a03_pulse.WAIT',
	'2a03_pulse.LONG_WAIT',
	'2a03_pulse.HALT',
	'2a03_pulse.AUDIO_PULSE_FREQUENCY_ADD',
	'2a03_pulse.AUDIO_PULSE_FREQUENCY_SUB',
	'2a03_pulse.AUDIO_PULSE_META_NOTE',
	'2a03_pulse.AUDIO_PULSE_META_NOTE_VOL',
	'2a03_pulse.AUDIO_PULSE_META_NOTE_DUT',
	'2a03_pulse.AUDIO_PULSE_META_NOTE_DUT_VOL',
	'2a03_pulse.AUDIO_PULSE_META_NOTE_USLIDE',
	'2a03_pulse.AUDIO_PULSE_META_NOTE_DSLIDE',
	'2a03_pulse.AUDIO_PULSE_META_NOTE_VOL_USLIDE',
	'2a03_pulse.AUDIO_PULSE_META_NOTE_VOL_DSLIDE',
	'2a03_pulse.AUDIO_PULSE_META_NOTE_DUT_USLIDE',
	'2a03_pulse.AUDIO_PULSE_META_NOTE_DUT_DSLIDE',
	'2a03_pulse.AUDIO_PULSE_META_NOTE_DUT_VOL_USLIDE',
	'2a03_pulse.AUDIO_PULSE_META_NOTE_DUT_VOL_DSLIDE',
	'2a03_pulse.AUDIO_PULSE_META_WAIT',
	'2a03_pulse.AUDIO_PULSE_META_WAIT_VOL',
	'2a03_pulse.AUDIO_PULSE_META_WAIT_DUT',
	'2a03_pulse.AUDIO_PULSE_META_WAIT_DUT_VOL',
	'2a03_pulse.AUDIO_PULSE_META_WAIT_USLIDE',
	'2a03_pulse.AUDIO_PULSE_META_WAIT_DSLIDE',
	'2a03_pulse.AUDIO_PULSE_META_WAIT_VOL_USLIDE',
	'2a03_pulse.AUDIO_PULSE_META_WAIT_VOL_DSLIDE',
	'2a03_pulse.AUDIO_PULSE_META_WAIT_DUT_USLIDE',
	'2a03_pulse.AUDIO_PULSE_META_WAIT_DUT_DSLIDE',
	'2a03_pulse.AUDIO_PULSE_META_WAIT_DUT_VOL_USLIDE',
	'2a03_pulse.AUDIO_PULSE_META_WAIT_DUT_VOL_DSLIDE',
	'2a03_noise.PLAY_TIMED_FREQ',
	'2a03_noise.WAIT',
	'2a03_noise.LONG_WAIT',
	'2a03_noise.HALT',
]

opcode_size = {
	'SAMPLE_END': 1,

	'2a03_pulse.CHAN_PARAMS': 3,
	'2a03_pulse.CHAN_VOLUME_LOW': 1,
	'2a03_pulse.CHAN_VOLUME_HIGH': 1,
	'2a03_pulse.CHAN_DUTY': 1,
	'2a03_pulse.PLAY_TIMED_FREQ': 3,
	'2a03_pulse.PLAY_NOTE': 2,
	'2a03_pulse.PLAY_TIMED_NOTE': 2,
	'2a03_pulse.WAIT': 1,
	'2a03_pulse.LONG_WAIT': 2,
	'2a03_pulse.HALT': 1,
	'2a03_pulse.PITCH_SLIDE': 2,
	'2a03_pulse.AUDIO_PULSE_FREQUENCY_ADD': 3,
	'2a03_pulse.AUDIO_PULSE_FREQUENCY_SUB': 3,
	#'2a03_pulse.AUDIO_PULSE_META_NOTE': 3, # Disabled for now as a poor man sanity check (should be avoided in most cases)
	'2a03_pulse.AUDIO_PULSE_META_NOTE_VOL': 4,
	'2a03_pulse.AUDIO_PULSE_META_NOTE_DUT': 4,
	'2a03_pulse.AUDIO_PULSE_META_NOTE_DUT_VOL': 4,
	'2a03_pulse.AUDIO_PULSE_META_NOTE_USLIDE': 4,
	'2a03_pulse.AUDIO_PULSE_META_NOTE_DSLIDE': 4,
	'2a03_pulse.AUDIO_PULSE_META_NOTE_VOL_USLIDE': 5,
	'2a03_pulse.AUDIO_PULSE_META_NOTE_VOL_DSLIDE': 5,
	'2a03_pulse.AUDIO_PULSE_META_NOTE_DUT_USLIDE': 5,
	'2a03_pulse.AUDIO_PULSE_META_NOTE_DUT_DSLIDE': 5,
	'2a03_pulse.AUDIO_PULSE_META_NOTE_DUT_VOL_USLIDE': 5,
	'2a03_pulse.AUDIO_PULSE_META_NOTE_DUT_VOL_DSLIDE': 5,
	#'2a03_pulse.AUDIO_PULSE_META_WAIT': 2, # Disabled for now as a poor man sanity check (should be avoided in most cases)
	'2a03_pulse.AUDIO_PULSE_META_WAIT_VOL': 3,
	'2a03_pulse.AUDIO_PULSE_META_WAIT_DUT': 3,
	'2a03_pulse.AUDIO_PULSE_META_WAIT_DUT_VOL': 3,
	'2a03_pulse.AUDIO_PULSE_META_WAIT_USLIDE': 3,
	'2a03_pulse.AUDIO_PULSE_META_WAIT_DSLIDE': 3,
	'2a03_pulse.AUDIO_PULSE_META_WAIT_VOL_USLIDE': 4,
	'2a03_pulse.AUDIO_PULSE_META_WAIT_VOL_DSLIDE': 4,
	'2a03_pulse.AUDIO_PULSE_META_WAIT_DUT_USLIDE': 4,
	'2a03_pulse.AUDIO_PULSE_META_WAIT_DUT_DSLIDE': 4,
	'2a03_pulse.AUDIO_PULSE_META_WAIT_DUT_VOL_USLIDE': 4,
	'2a03_pulse.AUDIO_PULSE_META_WAIT_DUT_VOL_DSLIDE': 4,

	'2a03_noise.SET_VOLUME': 1,
	'2a03_noise.SET PERIODIC': 1,
	'2a03_noise.PLAY_TIMED_FREQ': 2,
	'2a03_noise.WAIT': 1,
	'2a03_noise.LONG_WAIT': 2,
	'2a03_noise.HALT': 1,
	'2a03_noise.PITCH_SLIDE_UP': 1,
	'2a03_noise.PITCH_SLIDE_DOWN': 1,
	'2a03_noise.SET_PERIODIC': 1,
}


#
# Quality of life functions
#

def mod_opcode_name(opcode):
	return '{}.{}'.format(opcode['type'][13:-7], opcode['name'])

def get_opcode_size(opcode):
	return opcode_size[mod_opcode_name(opcode)]

def is_timed_opcode(opcode):
	return mod_opcode_name(opcode) in timed_opcodes

def row_identifier(track_idx, pattern_idx, row_idx, channel_idx):
	"""
	Return a human readable string indicating a location in the file
	"""
	return 'track:{:02x}-pattern:{:02x}-row:{:02x}-chan:{}'.format(
		track_idx, pattern_idx, row_idx, channel_idx
	)

def std_note_name(note):
	"""
	Return the same note as named in the table

	Notably E# becomes D, and B# becomes C.
	"""
	assert note not in ['...', '---', '==='], 'trying to standardize {}'.format(note)

	# Standardize modifier
	modifier_converter = {'+':'#', '.':'-', 'f':'b'}
	if note[1] in modifier_converter:
		note = '{}{}{}'.format(note[0], modifier_converter[note[1]], note[2])

	#TODO Convert flat to sharp
	ensure(note[1] not in ['b', 'f'], 'TODO convert flat to sharp')

	# Convert E# and B# do D and C
	if note[0:2] == 'E#':
		note = 'D-{}'.format(note[2])

	if note[0:2] == 'B#':
		note = 'C-{}'.format(int(note[2]) + 1)

	return note

def get_note_table_index(note):
	"""
	Index of a note in the notes table

	Giving better error messages than just searching the name in the notes table.
	"""
	original_note = note
	note = std_note_name(note)

	note_name = note[0]
	note_modifier = note[1]
	note_octave = int(note[2])

	note_names = ['C', 'D', 'E', 'F', 'G', 'A', 'B']
	note_modifiers = ['-', '#']

	original_indication = ' (original note was "{})"'.format(original_note) if original_note != note else ''
	ensure(0 <= note_octave and note_octave <= 7, 'invalid note "{}", octave = "{}"{}'.format(note, note_octave, original_indication))
	ensure(note_name in note_names, 'invalid note "{}", name = "{}"{}'.format(note, note_name, original_indication))
	ensure(note_modifier in note_modifiers, 'invalid note "{}", modifier = "{}"{}'.format(note, note_modifier, original_indication))

	return note_table_names.index(note)

def get_frequency_table_index(freq):
	"""
	Index of a frequency in the notes table

	Returns None if not found, 0x7ff returns G-0 (the lowest note with this frequency)
	"""
	for i in range(len(note_table_freqs)-1, -1, -1):
		if note_table_freqs[i] == freq:
			return i
	return None

def get_note_frequency(note):
	"""
	Return the frequency of a note designated by its name
	"""
	return note_table_freqs[get_note_table_index(note)]

def get_note_from_frequency(freq):
	"""
	Return the name of a note designated by its frequencty
	"""
	return note_table_names[get_frequency_table_index(freq)]

def get_row(music, track, pattern, chan, row):
	"""
	Return a row of a specific channel
	"""
	return music['tracks'][track]['patterns'][pattern]['rows'][row]['channels'][chan]

def is_pitch_slide_activation_effect(effect):
	return (
		effect[0] in pitch_effects and
		effect not in ['000', '100', '200', '300'] and
		effect[0:2] != '40'
	)

def place_extra_effect(chan_row, effect, replace, msg):
	"""
	Place an extra effect, creating the structure if needed
	"""
	# Ensure extra_effects field is present
	if 'extra_effects' not in chan_row:
		chan_row['extra_effects'] = []

	# Check conflicting effect
	existing_effect_idx = None
	for current_effect_idx in range(len(chan_row['extra_effects'])):
		current_effect = chan_row['extra_effects'][current_effect_idx]
		if current_effect['effect'] == effect['effect']:
			existing_effect_idx = current_effect_idx
			#TODO option to not warn if effects have the same value
			warn(msg)

	# Place
	if existing_effect_idx is not None:
		if replace:
			chan_row['extra_effects'][existing_effect_idx] = effect
	else:
		chan_row['extra_effects'].append(effect)

def get_extra_effect(chan_row, effect_name, default=None):
	"""
	Retrieve the value of an effect for a row.

	This is an ease of use function, not handling the case where multiple effects with the same name are on the same row.
	"""
	value = default
	found = False

	for current_effect in chan_row.get('extra_effects', []):
		if current_effect['effect'] == effect_name:
			assert found == False, "multiple '{}' effects present while retrieved by get_extra_effect"
			value = current_effect['value']
			found = True

	return value

def place_pitch_effect(chan_row, effect, effect_idx, replace, warn_on_stop=False, msg=None):
	"""
	Place a pitch effect in a row, taking care of existing conflicting effects

	If there is a conflicting pitch effect: it is replaced by the new one if `replace` is set, else the new one is not placed.

	msg will be output as a warning if there is a conflicting effect which is not equivalent to the new one.
	"""
	current_effect = chan_row['effects'][effect_idx]

	if msg is not None:
		if current_effect != '...' and current_effect != effect:
			if current_effect[0] not in pitch_effects:
				warn('place pitch effect over a non-pitch effect: {}'.format(msg))
			elif is_pitch_slide_activation_effect(effect) or is_pitch_slide_activation_effect(current_effect):
				if warn_on_stop or is_pitch_slide_activation_effect(current_effect):
					warn(msg)

	if current_effect == '...' or replace:
		chan_row['effects'][effect_idx] = effect

def get_pitch_effects(chan_row):
	res = []
	for current_effect_idx in range(len(chan_row['effects'])):
		current_effect = chan_row['effects'][current_effect_idx]
		if current_effect[0] in pitch_effects:
			res.append(current_effect_idx)
	return res

def get_pitch_effect(chan_row):
	"""
	Return the pitch effect in a row.

	If there is no pitch effect, return None.
	If there are multiple pitch effects, return the one that will be kept by remove_useless_pitch_effects.
	"""
	effects = get_pitch_effects(chan_row)
	final_effect = None
	for effect in effects:
		if final_effect is None:
			final_effect = effect
		elif is_pitch_slide_activation_effect(effect):
			final_effect = effect
			break
	return final_effect

def get_chan_type(music, chan_idx):
	"""
	Return the type of a channel
	"""
	#TODO handle other cases than VRC6 (checking extensions in music)
	return ['2a03-pulse', '2a03-pulse', '2a03-triangle', '2a03-noise', '2a03-pcm', 'vrc6-pulse', 'vrc6-pulse', 'vrc6-saw'][chan_idx]

def get_previous_note(music, track_idx, pattern_idx, chan_idx, row_idx, ignore_stop=True):
	"""
	Return the previous known note and if it is reliable to asume that it is still being played
	"""
	# Find original note position
	original_note_pattern = None
	original_note_row = None
	original_note = None
	def find_note_scanner(current_pattern_idx, current_row_idx):
		nonlocal music, track_idx, chan_idx, original_note_pattern, original_note_row, original_note
		current_row = music['tracks'][track_idx]['patterns'][current_pattern_idx]['rows'][current_row_idx]['channels'][chan_idx]
		if current_row['note'] not in ['...', '---', '==='] or (current_row['note'] in ['---', '==='] and not ignore_stop):
			original_note_pattern = current_pattern_idx
			original_note_row = current_row_idx
			original_note = current_row['note']
			return False
	scan_previous_chan_rows(find_note_scanner, music, track_idx, pattern_idx, chan_idx, row_idx-1)

	# No note found, abort now
	if original_note is None or original_note in ['---', '===']:
		return {
			'note': original_note,
			'reliable': True,
			'frequency': 0,
			'approximate_note': original_note,
			'unhandled_cases': []
		}

	# Compute impact of pitch effects on current row
	reliable = True
	frequency = get_note_frequency(original_note)
	unhandled_cases = []
	current_slide = {}
	found_destination = False
	def compute_slide_scanner(current_pattern_idx, current_row_idx):
		nonlocal music, track_idx, chan_idx, pattern_idx, row_idx, reliable, frequency, unhandled_cases, current_slide, found_destination
		current_row = music['tracks'][track_idx]['patterns'][current_pattern_idx]['rows'][current_row_idx]['channels'][chan_idx]

		# Stop when we came back to where we are searching the current frequency
		target_pattern_idx = pattern_idx
		target_row_idx = row_idx
		if (current_pattern_idx, current_row_idx) == (target_pattern_idx, target_row_idx):
			found_destination = True
			return False

		# Compute new slide value
		#TODO merge this code with merge_pitch_slides
		for effect_idx in range(len(current_row['effects'])):
			effect = current_row['effects'][effect_idx]
			if effect[0] == '1':
				current_slide[effect_idx] = -int(effect[1:], 16)
			elif effect[0] == '2':
				current_slide[effect_idx] = int(effect[1:], 16)
			elif effect[0] in pitch_effects:
				if is_pitch_slide_activation_effect(effect):
					unhandled_cases.append('non 1xx/2xx effect in {}'.format(
						row_identifier(track_idx, current_pattern_idx, current_row_idx, chan_idx)
					))
				else:
					current_slide[effect_idx] = 0

		# Update frequency
		merged_current_slide = 0
		for column in current_slide:
			merged_current_slide += current_slide[column]

		if merged_current_slide != 0:
			reliable = False
			frequency += merged_current_slide
	scan_next_chan_rows(compute_slide_scanner, music, track_idx, original_note_pattern, original_note_row)

	assert found_destination, 'never came back to where we are searching for previous note, original search point must exist'

	# Compute result
	approximate_note_index = sorted(note_table_freqs, key=lambda x: abs(x - frequency))[0]
	return {
		'note': original_note,
		'reliable': reliable and len(unhandled_cases) == 0,
		'frequency': frequency,
		'approximate_note': get_note_from_frequency(approximate_note_index),
		'unhandled_cases': unhandled_cases
	}

def get_current_pitch_effect(music, track_idx, pattern_idx, chan_idx, row_idx):
	"""
	Return the pitch effect impacting the current row (even if placed on a previous row)
	"""
	current_effect = None
	def effect_scanner(current_pattern_idx, current_row_idx):
		nonlocal current_effect
		current_row = music['tracks'][track_idx]['patterns'][current_pattern_idx]['rows'][current_row_idx]['channels'][chan_idx]
		current_effect_idx = get_pitch_effect(current_row)
		if current_effect_idx is not None:
			current_effect = current_row['effects'][current_effect_idx]
			return False
	scan_previous_chan_rows(effect_scanner, music, track_idx, pattern_idx, chan_idx, row_idx)
	return current_effect

def scan_previous_chan_rows(callback, music, track_idx, pattern_idx, chan_idx, start_row_idx):
	"""
	Invoke callback on all previous rows for the channel, ignoring pattern boundary.

	Stops after invoking the first row of the track or if callback returns False

	Notes:

		The callback can return None, this will not stop iteration. Ending without return statement works as expected.

		The callback is called also for the row at start_row_idx. If you want to begin before a specific row, pass "start_row_idx = row_idx - 1"
		If start_row_idx is lower than zero, it begins at the last row of the previous pattern.

	>>> music = {
	...   'tracks': [
	...     {
	...       'patterns':[
	...         {'rows': [{},{}]},
	...         {'rows': [{},{}]},
	...       ]
	...     },
	...   ]
	... }
	>>> scan_previous_chan_rows(
	...   lambda p, r: print(str((p, r))),
	...   music,
	...   0, 1, 'writing this test, I found that chan_idx is unused', 0
	... )
	(1, 0)
	(0, 1)
	(0, 0)
	>>> scan_previous_chan_rows(
	...   lambda p, r: print(str((p, r))),
	...   music,
	...   0, 1, 'writing this test, I found that chan_idx is unused', -1
	... )
	(0, 1)
	(0, 0)
	"""
	first_pattern = True
	for pattern_idx in range(pattern_idx, -1, -1):
		pattern = music['tracks'][track_idx]['patterns'][pattern_idx]

		current_row_idx = len(pattern['rows']) - 1
		if first_pattern:
			current_row_idx = start_row_idx
			first_pattern = False
		for current_row_idx in range(current_row_idx, -1, -1):
			if callback(pattern_idx, current_row_idx) == False:
				return

def scan_next_chan_rows(callback, music, track_idx, pattern_idx, start_row_idx):
	"""
	Invoke callback on all next rows, ignoring pattern boundary.

	Stops after invoking the very row line of the track or if callback returns False

	Notes:

		The callback can return None, this will not stop iteration. Ending without return statement works as expected.

		The callback is called also for the row at start_row_idx. If you want to begin after a specific row, pass "start_row_idx = row_idx + 1"
		If start_row_idx is higher than pattern's end, it begins at the first row of the next pattern.

	>>> music = {
	...   'tracks': [
	...     {
	...       'patterns':[
	...         {'rows': [{},{}]},
	...         {'rows': [{},{}]},
	...       ]
	...     },
	...   ]
	... }
	>>> scan_next_chan_rows(
	...   lambda p, r: print(str((p, r))),
	...   music,
	...   0, 0, 1
	... )
	(0, 1)
	(1, 0)
	(1, 1)
	>>> scan_next_chan_rows(
	...   lambda p, r: print(str((p, r))),
	...   music,
	...   0, 0, 2
	... )
	(1, 0)
	(1, 1)
	"""
	first_pattern = True
	track = music['tracks'][track_idx]
	for pattern_idx in range(pattern_idx, len(track['patterns'])):
		pattern = track['patterns'][pattern_idx]

		current_row_idx = 0
		if first_pattern:
			current_row_idx = start_row_idx
			first_pattern = False
		for current_row_idx in range(current_row_idx, len(pattern['rows'])):
			if callback(pattern_idx, current_row_idx) == False:
				return

#
# Music modifiers
#

def isolate_track(music, track_index):
	"""
	Remove all tracks except one.

	Other modifiers' behavior is wildly untested on multi-tracks context (but should be supported),
	and when the goal is to generate UCTF, there is only support for one track.
	"""
	assert len(music['tracks']) > track_index, "track #{} not found".format(track_index + 1)
	music['tracks'] = [music['tracks'][track_index]]
	return music

def get_num_channels(music):
	"""
	Count the number of channels in the music and stores it in global parameters

	Depends: none
	"""
	VRC6_MASK = 0b00000001

	n_channels = 5
	if music['params']['expansion'] & VRC6_MASK:
		n_channels += 3
	#TODO handle other expansion chips

	modified = copy.deepcopy(music)
	modified['params']['n_chan'] = n_channels
	return modified

def flatten_orders(music):
	"""
	Reconstruct straightforward patterns, according to orders

	Depends: none
	"""
	# Copy the music without its patterns
	modified = copy.deepcopy(music)
	for track in modified['tracks']:
		track['patterns'] = []

	# Reconstruct patterns, following orders
	for track_idx in range(len(music['tracks'])):
		original_track = music['tracks'][track_idx]
		modified_track = modified['tracks'][track_idx]
		for order in original_track['orders']:
			ensure(len(order) == music['params']['n_chan'], "wrong number of channels in order entries {} != {}".format(len(order), music['params']['n_chan']))

			# Craft a pattern corresponding to this page
			modified_pattern = {'rows': []}
			for row_idx in range(original_track['pattern']):
				modified_row = {'channels': []}
				for chan_idx in range(len(order)):
					#FIXME pattern may not exists, should return an empty row in this case
					modified_row['channels'].append(copy.deepcopy(get_row(music, track=track_idx, pattern=order[chan_idx], chan=chan_idx, row=row_idx)))
				modified_pattern['rows'].append(modified_row)

			modified_track['patterns'].append(modified_pattern)

		# Remove orders (they are now missleading)
		del modified_track['orders']

	# Sanity checks and return
	assert len(modified['tracks']) == len(music['tracks']), "modified version ended with a wrong number of tracks"
	for track_idx in range(len(modified['tracks'])):
		assert len(modified['tracks'][track_idx]['patterns']) == len(music['tracks'][track_idx]['orders']), "modified patterns do not match orders"

	return modified

#
# Obsolete: seems to be based on false assumptions
#  - Don't take module's original speed into account (While FXX and speed are interlinked)
#  - FXX effect impact only its row (While should change permanentely the module's speed)
#  - Considere all FXX equal (While XX >= 0x20 means tempo change)
#
#def unroll_f_effect(music):
#	"""
#	Remove FXX effect, place empty lines to compensate
#
#	Depends: get_num_channels
#	"""
#	# Copy the music without its patterns
#	modified = copy.deepcopy(music)
#	for track in modified['tracks']:
#		track['patterns'] = []
#
#	# Rewrite patterns with FXX effects unrolled
#	for track_idx in range(len(music['tracks'])):
#		for original_pattern in music['tracks'][track_idx]['patterns']:
#			modified['tracks'][track_idx]['patterns'].append({'rows': []})
#			for original_row in original_pattern['rows']:
#				# Copy the row without FXX effect, noting the number of dummy rows to add
#				modified_row = copy.deepcopy(original_row)
#				repeats = 0
#				for channel in modified_row['channels']:
#					for i in range(len(channel['effects'])):
#						if channel['effects'][i][0] == 'F':
#							repeats = int(channel['effects'][i][1:], 16) - 1
#							# F00 case:
#							#  It makes no sense. Maybe infinite beats per minute.
#							#  Famitracker wiki state that F00 is valid, without detail on what it does.
#							#  Famitracker chm states that it is invalid.
#							#  It seems to be equivalent to F01, until a proof is given, let's just crash.
#							ensure(repeats >= 0, 'unhandled effect F00')
#							channel['effects'][i] = '...'
#
#				# Store modified row and dummies to compensate the lack of FXX effect
#				modified['tracks'][track_idx]['patterns'][-1]['rows'].append(modified_row)
#
#				dummy_row = {'channels': []}
#				for n_effects in modified['tracks'][track_idx]['channels_effects']:
#					dummy_row['channels'].append({
#						'note': '...',
#						'instrument': '..',
#						'volume': '.',
#						'effects': ['...'] * n_effects
#					})
#				for i in range(repeats):
#					modified['tracks'][track_idx]['patterns'][-1]['rows'].append(copy.deepcopy(dummy_row))
#
#	# Sanity checks and return
#	assert len(modified['tracks']) == len(music['tracks']), 'number of tracks differs between modified and original (modified:{}, original:{})'.format(len(modified['tracks']), len(music['tracks']))
#	for track_id in range(len(music['tracks'])):
#		assert len(modified['tracks'][track_idx]['patterns']) == len(music['tracks'][track_idx]['patterns'])
#		for pattern_idx in range(len(music['tracks'][track_idx]['patterns'])):
#			assert len(modified['tracks'][track_idx]['patterns'][pattern_idx]) >= len(music['tracks'][track_idx]['patterns'][pattern_idx]), 'pattern {:02x}-{:02x} is shorted than original'.format(track_idx, pattern_idx)
#
#	return modified

def unroll_speed(music):
	"""
	Place empty lines to compensate track's speed. Also remove FXX effects impacting speed.

	Depends: get_num_channels
	"""
	# Copy the music without its patterns
	modified = copy.deepcopy(music)
	for track in modified['tracks']:
		track['patterns'] = []

	# Rewrite patterns with speed unrolled
	for track_idx in range(len(music['tracks'])):
		current_speed = modified['tracks'][track_idx]['speed']
		for pattern_idx in range(len(music['tracks'][track_idx]['patterns'])):
			original_pattern = music['tracks'][track_idx]['patterns'][pattern_idx]
			modified['tracks'][track_idx]['patterns'].append({'rows': []})
			for row_idx in range(len(original_pattern['rows'])):
				original_row = original_pattern['rows'][row_idx]

				# Copy the row without FXX effect, noting the number of dummy rows to add
				modified_row = copy.deepcopy(original_row)
				for channel in modified_row['channels']:
					for i in range(len(channel['effects'])):
						if channel['effects'][i][0] == 'F':
							new_speed = int(channel['effects'][i][1:], 16)
							# F00 case:
							#  It makes no sense. Maybe infinite beats per minute.
							#  Famitracker wiki state that F00 is valid, without detail on what it does.
							#  Famitracker chm states that it is invalid.
							#  It seems to be equivalent to F01, until a proof is given, let's just crash.
							ensure(new_speed > 0, 'unhandled effect F00')
							if new_speed < 0x20:
								channel['effects'][i] = '...'
								current_speed = new_speed

				# Store modified row and dummies to compensate the lack of FXX effect
				modified['tracks'][track_idx]['patterns'][-1]['rows'].append(modified_row)

				dummy_row = {'channels': []}
				for n_effects in modified['tracks'][track_idx]['channels_effects']:
					dummy_row['channels'].append({
						'note': '...',
						'instrument': '..',
						'volume': '.',
						'effects': ['...'] * n_effects
					})

				ensure(current_speed > 0, 'unhandled speed of {} in {}'.format(
					current_speed, row_identifier(track_idx, pattern_idx, row_idx, 0)
				));
				for i in range(current_speed - 1):
					modified['tracks'][track_idx]['patterns'][-1]['rows'].append(copy.deepcopy(dummy_row))

	# Sanity checks and return
	assert len(modified['tracks']) == len(music['tracks']), 'number of tracks differs between modified and original (modified:{}, original:{})'.format(len(modified['tracks']), len(music['tracks']))
	for track_id in range(len(music['tracks'])):
		assert len(modified['tracks'][track_idx]['patterns']) == len(music['tracks'][track_idx]['patterns'])
		for pattern_idx in range(len(music['tracks'][track_idx]['patterns'])):
			assert len(modified['tracks'][track_idx]['patterns'][pattern_idx]) >= len(music['tracks'][track_idx]['patterns'][pattern_idx]), 'pattern {:02x}-{:02x} is shorted than original'.format(track_idx, pattern_idx)

	return modified

def apply_forward_b_effect(music):
	"""
	Cut pages when a Bxx to a later page is encountered

	Depends: flatten_orders
	NotAfter: anything that makes pattern missmatch pages (currently nothing does that before UCTF conversion)
	"""
	modified = copy.deepcopy(music)

	for track_idx in range(len(music['tracks'])):
		original_track = music['tracks'][track_idx]
		modified_track = modified['tracks'][track_idx]
		for pattern_idx in range(len(original_track['patterns'])):
			original_pattern = original_track['patterns'][pattern_idx]
			modified_pattern = modified_track['patterns'][pattern_idx]
			for row_idx in range(len(original_pattern['rows'])):
				original_row = original_pattern['rows'][row_idx]
				modified_row = modified_pattern['rows'][row_idx]

				# Check for presence of a Bxx effect anywhere in the row
				bxx_location = None
				for chan_idx in range(len(original_row['channels'])):
					for effect_idx in range(len(original_row['channels'][chan_idx]['effects'])):
						effect = original_row['channels'][chan_idx]['effects'][effect_idx]
						if effect[0] == 'B':
							if bxx_location is not None:
								if effect != original_row['channels'][bxx_location['chan']]['effects'][bxx_location['effect']]:
									warn('multiple Bxx in {}: some are ignored'.format(
										row_identifier(track_idx, pattern_idx, row_idx, chan_idx)
									))
								modified_row['channels'][bxx_location['chan']]['effects'][bxx_location['effect']] = '...'
							bxx_location = {'chan':chan_idx, 'effect':effect_idx}

				# Handle special cases
				if bxx_location is None:
					# No BXX effect, nothing to do on this row
					continue

				effect = original_row['channels'][bxx_location['chan']]['effects'][bxx_location['effect']]
				destination_pattern_idx = int(effect[1:], 16)

				if destination_pattern_idx <= pattern_idx:
					# Ignore backward BXX, not handled by this modifier
					continue

				if destination_pattern_idx != pattern_idx + 1:
					#NOTE handling is may be not trivial, if a later backward BXX jump to a skipped pattern the only solution is to re-order patterns
					error('Forward BXX is not to the next pattern in {}: interpreted as if it was to next pattern'.format(
						row_identifier(track_idx, pattern_idx, row_idx, bxx_location['chan'])
					))

				# Remove Bxx effect from modified music
				modified_row['channels'][bxx_location['chan']]['effects'][bxx_location['effect']] = '...'

				# Truncate pattern after the current row
				modified_pattern['rows'] = modified_pattern['rows'][:row_idx+1]

				# Avoid iterating on removed rows
				break

	return modified

def apply_backward_b_effect(music):
	"""
	Cut each track at the first backward Bxx effect

	Note: only B00 is handled, anything else is interpreted as B00

	Depends: apply_forward_b_effect
	"""
	def bxx_scanner(current_pattern_idx, current_row_idx):
		nonlocal cut_position, track_idx
		current_row = music['tracks'][track_idx]['patterns'][current_pattern_idx]['rows'][current_row_idx]

		# Check for presence of a Bxx effect anywhere in the row
		bxx_location = None
		for chan_idx in range(len(current_row['channels'])):
			for effect_idx in range(len(current_row['channels'][chan_idx]['effects'])):
				effect = current_row['channels'][chan_idx]['effects'][effect_idx]
				if effect[0] == 'B':
					if bxx_location is not None:
						warn('multiple Bxx in {}: some are ignored'.format(
							row_identifier(track_idx, current_pattern_idx, current_row_idx, chan_idx)
						))
						current_row['channels'][bxx_location['chan']]['effects'][bxx_location['effect']] = '...'
					bxx_location = {'chan':chan_idx, 'effect':effect_idx}

		# If a backward BXX is found, note the row on which it appear and remove the BXX effect
		if bxx_location is not None:
			effect = current_row['channels'][bxx_location['chan']]['effects'][bxx_location['effect']]
			destination_pattern_idx = int(effect[1:], 16)
			if destination_pattern_idx <= current_pattern_idx:
				if destination_pattern_idx != 0:
					warn('Backward Bxx with "xx != 00" in {}: interpreted as B00'.format(
						row_identifier(track_idx, current_pattern_idx, current_row_idx, bxx_location['chan'])
					))

				cut_position = {'pattern': current_pattern_idx, 'row': current_row_idx}
				current_row['channels'][bxx_location['chan']]['effects'][bxx_location['effect']] = '...'
				return False

	# Search for a cut position in each track
	for track_idx in range(len(music['tracks'])):
		cut_position = None
		scan_next_chan_rows(bxx_scanner, music, track_idx, 0, 0)

		if cut_position is not None:
			track = music['tracks'][track_idx]
			pattern = track['patterns'][cut_position['pattern']]

			# Remove rows at the end of the pattern
			pattern['rows'] = pattern['rows'][:cut_position['row']+1]

			# Remove patterns after the one containing Bxx
			track['patterns'] = track['patterns'][:cut_position['pattern']+1]

	return music

def apply_d_effect(music):
	"""
	Cut pages when a Dxx is encountered
	"""
	modified = copy.deepcopy(music)

	for track_idx in range(len(music['tracks'])):
		original_track = music['tracks'][track_idx]
		modified_track = modified['tracks'][track_idx]
		for pattern_idx in range(len(original_track['patterns'])):
			original_pattern = original_track['patterns'][pattern_idx]
			modified_pattern = modified_track['patterns'][pattern_idx]
			for row_idx in range(len(original_pattern['rows'])):
				original_row = original_pattern['rows'][row_idx]
				modified_row = modified_pattern['rows'][row_idx]

				# Check for presence of a Dxx effect anywhere in the row
				dxx_location = None
				for chan_idx in range(len(original_row['channels'])):
					for effect_idx in range(len(original_row['channels'][chan_idx]['effects'])):
						effect = original_row['channels'][chan_idx]['effects'][effect_idx]
						if effect[0] == 'D':
							if dxx_location is not None:
								warn('multiple Dxx in {}: some are ignored'.format(
									row_identifier(track_idx, pattern_idx, row_idx, chan_idx)
								))
								modified_row['channels'][dxx_location['chan']]['effects'][dxx_location['effect']] = '...'
							dxx_location = {'chan':chan_idx, 'effect':effect_idx}

				# Handle special cases
				if dxx_location is None:
					continue

				if original_row['channels'][dxx_location['chan']]['effects'][dxx_location['effect']] != 'D00':
					warn('Dxx with xx != 00 in {}: interpreted as D00'.format(
						row_identifier(track_idx, pattern_idx, row_idx, dxx_location['chan'])
					))

				# Remove Dxx effect from modified music
				modified_row['channels'][dxx_location['chan']]['effects'][dxx_location['effect']] = '...'

				# Truncate pattern after the current row
				modified_pattern['rows'] = modified_pattern['rows'][:row_idx+1]

				# Avoid iterating on removed rows
				break

	return modified

def apply_g_effect(music):
	"""
	Move rows affected by a Gxx effects

	Depends: get_num_channels
	"""
	modified = copy.deepcopy(music)

	for track_idx in range(len(modified['tracks'])):
		track = modified['tracks'][track_idx]
		for pattern_idx in range(len(track['patterns'])):
			pattern = track['patterns'][pattern_idx]
			for chan_idx in range(modified['params']['n_chan']):
				for row_idx in range(len(pattern['rows'])):
					chan_row = pattern['rows'][row_idx]['channels'][chan_idx]

					# Find if current row has a G effect
					g_effect_idx = None
					for effect_idx in range(len(chan_row['effects'])):
						effect = chan_row['effects'][effect_idx]
						if effect[0] == 'G':
							if g_effect_idx is not None:
								warn('multiple GXX effects in {}: some will be ignored'.format(
									row_identifier(track_idx, pattern_idx, row_idx, chan_idx)
								))
							g_effect_idx = effect_idx

					# Do not process the row if it has no G effect
					if g_effect_idx is None:
						continue

					# Compute useful values
					g_effect = chan_row['effects'][g_effect_idx]
					distance = int(g_effect[1:], 16)

					# Special handling for G00 (which should do nothing, to be confirmed)
					ensure(distance >= 0, 'odd Gxx effect (negative xx)')
					if distance == 0:
						warn('useless GXX effect in {}: ignored'.format(
							row_identifier(track_idx, pattern_idx, row_idx, chan_idx)
						))
						chan_row['effects'][g_effect_idx] = '...'
						continue

					# Copy row to the destination (merging with non-conflicting things there)
					dest_row_idx = row_idx + distance
					if dest_row_idx >= len(pattern['rows']):
						warn('GXX effect goes falls beyond pattern end in {}: moved to end of pattern'.format(
							row_identifier(track_idx, pattern_idx, row_idx, chan_idx)
						))
						dest_row_idx = len(pattern['rows'] - 1)
					dest_chan_row = get_row(modified, track=track_idx, pattern=pattern_idx, chan=chan_idx, row=dest_row_idx)

					if chan_row['note'] != '...':
						if dest_chan_row['note'] != '...':
							warn('GXX effect modifies the note at destination in {} => {}: GXX note ignored'.format(
								row_identifier(track_idx, pattern_idx, row_idx, chan_idx),
								row_identifier(track_idx, pattern_idx, dest_row_idx, chan_idx)
							))
						else:
							dest_chan_row['note'] = chan_row['note']

					if chan_row['instrument'] != '..':
						if dest_chan_row['instrument'] != '..':
							warn('GXX effect modifies the instrument at destination in {} => {}: GXX instrument ignored'.format(
								row_identifier(track_idx, pattern_idx, row_idx, chan_idx),
								row_identifier(track_idx, pattern_idx, dest_row_idx, chan_idx)
							))
						else:
							dest_chan_row['instrument'] = chan_row['instrument']

					if chan_row['volume'] != '.':
						if dest_chan_row['volume'] != '.':
							warn('GXX effect modifies the volume at destination in {} => {}: GXX volume ignored'.format(
								row_identifier(track_idx, pattern_idx, row_idx, chan_idx),
								row_identifier(track_idx, pattern_idx, dest_row_idx, chan_idx)
							))
						else:
							dest_chan_row['volume'] = chan_row['volume']

					for effect in chan_row['effects']:
						if effect != '...' and effect[0] != 'G':
							dest_chan_row['effects'].append(effect) #TODO should use an empty effect column if possible

					# Clear origin row
					pattern['rows'][row_idx]['channels'][chan_idx] = {
						'note': '...',
						'instrument': '..',
						'volume': '.',
						'effects': ['...'] * track['channels_effects'][chan_idx]
					}

					del chan_row # This line is mainly here to explicit that we just rewrited the row (so chan_row keeps a reference to the obsolete value)

	return modified

def apply_s_effect(music):
	"""
	Place a halt according to SXX effects

	Depends: get_num_channels
	"""
	modified = copy.deepcopy(music)

	for track_idx in range(len(modified['tracks'])):
		track = modified['tracks'][track_idx]
		for pattern_idx in range(len(track['patterns'])):
			pattern = track['patterns'][pattern_idx]
			for chan_idx in range(modified['params']['n_chan']):
				for row_idx in range(len(pattern['rows'])):
					chan_row = pattern['rows'][row_idx]['channels'][chan_idx]

					# Find if current row has a S effect
					s_effect_idx = None
					for effect_idx in range(len(chan_row['effects'])):
						effect = chan_row['effects'][effect_idx]
						if effect[0] == 'S':
							if s_effect_idx is not None:
								warn('multiple GXX effects in {}: some will be ignored'.format(
									row_identifier(track_idx, pattern_idx, row_idx, chan_idx)
								))
							s_effect_idx = effect_idx

					# Do not process the row if it has no S effect
					if s_effect_idx is None:
						continue

					# Compute useful values
					s_effect = chan_row['effects'][s_effect_idx]
					distance = int(s_effect[1:], 16)

					# Special handling for S00 (avoid the mess of manipulating two references to the same row)
					ensure(distance >= 0, 'odd Sxx effect (negative xx)')
					if distance == 0:
						if chan_row['note'] != '...':
							warn('S00 effect conflict with a note in {}: note erased'.format(
								row_identifier(track_idx, pattern_idx, row_idx, chan_idx)
							))
						chan_row['note'] = '---'
						chan_row['effects'][s_effect_idx] = '...'
						continue

					# Place hard halt at the destination
					dest_row_idx = row_idx + distance
					if dest_row_idx >= len(pattern['rows']):
						warn('SXX effect goes falls beyond pattern end in {}: moved to end of pattern'.format(
							row_identifier(track_idx, pattern_idx, row_idx, chan_idx)
						))
						dest_row_idx = len(pattern['rows']) - 1
					dest_chan_row = get_row(modified, track=track_idx, pattern=pattern_idx, chan=chan_idx, row=dest_row_idx)

					if dest_chan_row['note'] != '...':
						warn('SXX effect conflict with a note in {} => {}: note erased'.format(
							row_identifier(track_idx, pattern_idx, row_idx, chan_idx),
							row_identifier(track_idx, pattern_idx, dest_row_idx, chan_idx)
						))
					dest_chan_row['note'] = '---'
					chan_row['effects'][s_effect_idx] = '...'

	return modified

def _apply_volume_sequence(seq_vol, ref_note, modified, instrument_idx, track_idx, pattern_idx, row_idx, chan_idx, effect_idx):
	ensure(len(seq_vol['sequence']) > 0, 'instrument {:X} has an empty volume sequence'.format(instrument_idx))

	# Common variables
	track = modified['tracks'][track_idx]

	# Handle volume envelope, triange is special: lacking volume control is can be mute when envelope is zero
	if get_chan_type(modified, chan_idx) == '2a03-triangle':
		# Until the next note, the channel is mute if the volume is zero
		sequence_step = 0
		last_envelope_value = None
		def scanner_vol_tri(current_pattern_idx, current_row_idx):
			nonlocal last_envelope_value, sequence_step, track
			current_chan_row = track['patterns'][current_pattern_idx]['rows'][current_row_idx]['channels'][chan_idx]

			# Stop on any row with a note
			if current_chan_row['note'] != '...' and (current_pattern_idx, current_row_idx) != (pattern_idx, row_idx):
				return False

			# Modify row according to the envelope
			envelope_value = seq_vol['sequence'][sequence_step]
			if envelope_value != last_envelope_value:
				# Place an halt if volume reaches zero
				if envelope_value == 0 and last_envelope_value != 0:
					current_chan_row['note'] = '---'

				# Place the original note if volume becomes non-zero
				if envelope_value != 0 and last_envelope_value == 0:
					current_chan_row['note'] = ref_note

				last_envelope_value = envelope_value

			# Advance sequence
			if seq_vol['loop'] == -1:
				sequence_step = min(sequence_step + 1, len(seq_vol['sequence']) - 1)
			else:
				sequence_step += 1
				if sequence_step >= len(seq_vol['sequence']):
					sequence_step = seq_vol['loop']
		scan_next_chan_rows(scanner_vol_tri, modified, track_idx, pattern_idx, row_idx)

		# Inform that the sequence is handled
		return True

	elif get_chan_type(modified, chan_idx) in ['2a03-pulse', '2a03-noise']:
		# Find initial reference volume (even if above the note)
		ref_volume = None
		def check_row_volume(curent_pattern_idx, current_row_idx):
			nonlocal ref_volume, track, chan_idx
			current_chan_row = track['patterns'][curent_pattern_idx]['rows'][current_row_idx]['channels'][chan_idx]
			if current_chan_row['volume'] != '.':
				ref_volume = int(current_chan_row['volume'], 16)
				return False
		scan_previous_chan_rows(check_row_volume, modified, track_idx, pattern_idx, chan_idx, row_idx)

		if ref_volume is None:
			ref_volume = 15

		# Until the next note, the volume is adjusted by the enveloppe
		sequence_step = 0
		stop_row = None
		def scanner_apply_volume(curent_pattern_idx, current_row_idx):
			nonlocal ref_volume, sequence_step, stop_row, track
			first_line = (curent_pattern_idx == pattern_idx and current_row_idx == row_idx)
			current_chan_row = track['patterns'][curent_pattern_idx]['rows'][current_row_idx]['channels'][chan_idx]

			if current_chan_row['note'] != '...' and not first_line:
				stop_row = current_chan_row
				return False

			if current_chan_row['volume'] != '.':
				ref_volume = int(current_chan_row['volume'], 16)

			enveloppe_volume = int(.5 + (ref_volume * (seq_vol['sequence'][sequence_step] / 15.)))
			enveloppe_volume = max(0, enveloppe_volume)
			enveloppe_volume = min(15, enveloppe_volume)
			current_chan_row['volume'] = '{:X}'.format(enveloppe_volume)

			# Advance sequence
			if seq_vol['loop'] == -1:
				sequence_step = min(sequence_step + 1, len(seq_vol['sequence']) - 1)
			else:
				sequence_step += 1
				if sequence_step >= len(seq_vol['sequence']):
					sequence_step = seq_vol['loop']
		scan_next_chan_rows(scanner_apply_volume, modified, track_idx, pattern_idx, row_idx)

		# On the next note, explicitely reset reference volume
		if stop_row is not None and stop_row['volume'] == '.':
			stop_row['volume'] = '{:X}'.format(ref_volume)

		# Inform that the sequence is handled
		return True

	# Unhandled channel type
	return False

def _apply_duty_sequence(seq_dut, ref_note, modified, instrument_idx, track_idx, pattern_idx, row_idx, chan_idx, effect_idx):
	ensure(len(seq_dut['sequence']) > 0)
	track = modified['tracks'][track_idx]

	# Find initial reference duty (even if above the note)
	ref_duty = None
	def check_row_duty(curent_pattern_idx, current_row_idx):
		nonlocal ref_duty, track, chan_idx
		current_chan_row = track['patterns'][curent_pattern_idx]['rows'][current_row_idx]['channels'][chan_idx]
		for current_effect in current_chan_row['effects']:
			if current_effect[0] == 'V':
				ref_duty = int(current_effect[1:], 16)
				return False
	scan_previous_chan_rows(check_row_duty, modified, track_idx, pattern_idx, chan_idx, row_idx)

	if ref_duty is None:
		warn('unable to find reference duty for instrument enveloppe in {}: considere it as V00'.format(
			row_identifier(track_idx, pattern_idx, row_idx, chan_idx)
		))
		ref_duty = 0

	# Until the next note, the duty is adjusted by the enveloppe
	sequence_step = 0
	stopped_on_track_end = True
	def scanner_dut(current_pattern_idx, current_row_idx):
		nonlocal ref_duty, sequence_step, stopped_on_track_end
		current_chan_row = track['patterns'][current_pattern_idx]['rows'][current_row_idx]['channels'][chan_idx]

		# Stop on any row with a note
		if current_chan_row['note'] != '...' and (current_pattern_idx, current_row_idx) != (pattern_idx, row_idx):

			# On the next note, explicitely reset reference duty
			has_duty_effect = False
			for current_effect in current_chan_row['effects']:
				if current_effect[0] == 'V':
					has_duty_effect = True
			if not has_duty_effect:
				current_chan_row['effects'].append('V{:02X}'.format(ref_duty)) #HACK don't use effect_idx, keep it for pitch effects

			# Stop iterating
			stopped_on_track_end = False
			return False

		# Check for new reference duty
		duty_effect_idx = None
		for current_effect_idx in range(len(current_chan_row['effects'])):
			current_effect = current_chan_row['effects'][current_effect_idx]
			if current_effect[0] == 'V':
				ref_duty = int(current_effect[1:], 16)
				duty_effect_idx = current_effect_idx

		# Compute value as impacted by the sequence
		enveloppe_duty = seq_dut['sequence'][sequence_step]
		if duty_effect_idx is not None:
			current_chan_row['effects'][duty_effect_idx] = 'V{:02X}'.format(enveloppe_duty)
		else:
			current_chan_row['effects'].append('V{:02X}'.format(enveloppe_duty)) #HACK don't use effect_idx, keep it for pitch effects

		# Advance sequence
		if seq_dut['loop'] == -1:
			sequence_step = min(sequence_step + 1, len(seq_dut['sequence']) - 1)
		else:
			sequence_step += 1
			if sequence_step >= len(seq_dut['sequence']):
				sequence_step = seq_dut['loop']
	scan_next_chan_rows(scanner_dut, modified, track_idx, pattern_idx, row_idx )

	# Warn if envelop goes past the end of the track, hoping there is an explicit VXX at the begining to reset duty
	if stopped_on_track_end:
		warn('duty envelope from {} goes beyond the end of the track'.format(
			row_identifier(track_idx, pattern_idx, row_idx, chan_idx)
		))

	# Inform that the sequence is handled
	return True

def _apply_arpeggio_sequence(seq_arp, ref_note, modified, instrument_idx, track_idx, pattern_idx, row_idx, chan_idx, effect_idx, force_absolute_notes):
	"""
	force_absolute_notes: if False and the enveloppe is impacted by pitch effect, a frequency_adjust effect will be placed to
	                      allow the arpeggio to be played alongside the pitch effect.
						  This is not famitracker's behaviour, but seems expected by famistudio's exports (and more intuitive behaviour)
	"""
	ensure(len(seq_arp['sequence']) > 0, 'instrument {:X} has an empty arpeggio sequence'.format(instrument_idx))
	ensure(seq_arp['setting'] == 0, 'instrument {:X} use a non-absolute arpeggio: TODO handle fixed and relative arpeggio'.format(instrument_idx))
	track = modified['tracks'][track_idx]

	# Get reference note in numerical form
	if get_chan_type(modified, chan_idx) == '2a03-noise':
		ref_note_idx = int(ref_note[0], 16)
	else:
		ref_note_idx = get_note_table_index(ref_note)
	last_note_idx = ref_note_idx

	# Check if there is an active pitch effect impacting the first row
	#TODO cannot check only one pitch effect, has_pitch_effect should be True if any column has an active pitch effect
	pitch_effect = get_current_pitch_effect(modified, track_idx, pattern_idx, chan_idx, row_idx)
	has_pitch_effect = pitch_effect is not None and is_pitch_slide_activation_effect(pitch_effect)

	# Until the next note, the note is adjusted by the enveloppe
	sequence_step = 0
	first_row = True
	def scanner_arp(current_pattern_idx, current_row_idx):
		nonlocal first_row, has_pitch_effect, last_note_idx, ref_note_idx, sequence_step, track
		current_chan_row = track['patterns'][current_pattern_idx]['rows'][current_row_idx]['channels'][chan_idx]

		# Stop on any row with a note
		if current_chan_row['note'] != '...' and (current_pattern_idx, current_row_idx) != (pattern_idx, row_idx):
			return False

		# Check if pitch effect starts or ends here
		if first_row:
			first_row = False
		else:
			pitch_effect_idx = get_pitch_effect(current_chan_row)
			if pitch_effect_idx is not None:
				has_pitch_effect = is_pitch_slide_activation_effect(current_chan_row['effects'][pitch_effect_idx])

		# Compute value as impacted by the sequence
		sequence_value = seq_arp['sequence'][sequence_step]
		enveloppe_note_idx = ref_note_idx + sequence_value

		# Bound computed value to valid values
		if get_chan_type(modified, chan_idx) == '2a03-noise':
			if enveloppe_note_idx > 0xf:
				enveloppe_note_idx %= 10
			while enveloppe_note_idx < 0:
				enveloppe_note_idx += 0x10
		else:
			#TODO check famitracker behaviour, is may be to loop through the table (strange behaviour, but consistent with what happens on noise)
			if enveloppe_note_idx >= len(note_table_names):
				warn('arpeggio enveloppe goes over the notes table in {}: last note of the table used'.format(
					row_identifier(track_idx, current_pattern_idx, current_row_idx, chan_idx)
				))
				enveloppe_note_idx = len(note_table_names) - 1
			elif enveloppe_note_idx < 0:
				warn('arpeggio enveloppe goes under the notes table in {}: first note of the table used'.format(
					row_identifier(track_idx, current_pattern_idx, current_row_idx, chan_idx)
				))
				enveloppe_note_idx = 0

		# Place computed value
		if force_absolute_notes or not has_pitch_effect or current_chan_row['note'] != '...':
			# There is not pitch effect, or we are on the first row (setting the note), so we can simply place the resulting note
			if get_chan_type(modified, chan_idx) == '2a03-noise':
				current_chan_row['note'] = '{:X}-#'.format(enveloppe_note_idx)
			else:
				current_chan_row['note'] = note_table_names[enveloppe_note_idx]

			# This is not a normal note in the pattern, prevent 3XX from moving it
			place_extra_effect(
				current_chan_row,
				{'effect': '3xx_skip', 'value': True},
				replace=True,
				msg='conflicting 3xx_skip caused by arpeggio instrument in {}: replacing existing effect, TODO avoid warn if exising is already True'.format(
					row_identifier(track_idx, current_pattern_idx, current_row_idx, chan_idx)
				)
			)
		else:
			# There is an active pitch effect that may impact the played frequency, place the wanted difference with current frequency
			if get_chan_type(modified, chan_idx) == '2a03-noise':
				pitch_diff = enveloppe_note_idx - last_note_idx
			else:
				pitch_diff = note_table_freqs[enveloppe_note_idx] - note_table_freqs[last_note_idx]

			if pitch_diff != 0:
				place_extra_effect(
					current_chan_row,
					{'effect': 'frequency_adjust', 'value': pitch_diff},
					replace=True,
					msg='conflicting frequency_adjust caused by arpeggio instrument in {}: replacing existing effect, TODO merge frequency_adjust effects'.format(
						row_identifier(track_idx, current_pattern_idx, current_row_idx, chan_idx)
					)
				)

		last_note_idx = enveloppe_note_idx

		# Advance sequence
		if seq_arp['loop'] == -1:
			sequence_step += 1
			if sequence_step >= len(seq_arp['sequence']):
				# Stop forcing the note if the enveloppe ended (letting pitch effect roll)
				# WARN: May not be compatible with relative eveloppe, to be tested
				return False
			sequence_step = min(sequence_step + 1, len(seq_arp['sequence']) - 1)
		else:
			sequence_step += 1
			if sequence_step >= len(seq_arp['sequence']):
				sequence_step = seq_arp['loop']
	scan_next_chan_rows(scanner_arp, modified, track_idx, pattern_idx, row_idx )

	# Inform that the sequence is handled
	return True

def _apply_pitch_sequence(seq_pit, ref_note, modified, instrument_idx, track_idx, pattern_idx, row_idx, chan_idx, effect_idx):
	ensure(len(seq_pit['sequence']) > 0, 'instrument {:X} has an empty pitch sequence'.format(instrument_idx))
	track = modified['tracks'][track_idx]

	# Until the next note, the note is adjusted by the envelope
	sequence_step = 0
	current_slide = None
	last_chan_row = None
	def scanner_pit(current_pattern_idx, current_row_idx):
		nonlocal current_slide, last_chan_row, sequence_step, track
		current_chan_row = track['patterns'][current_pattern_idx]['rows'][current_row_idx]['channels'][chan_idx]
		last_chan_row = current_chan_row

		# Stop on any row with a note
		if current_chan_row['note'] != '...' and (current_pattern_idx, current_row_idx) != (pattern_idx, row_idx):
			return False

		# Compute a pitch slide effect according to envelope
		#FIXME is is one tick late as instrument envelope is immediate while pitch slide begins its effect on the next tick
		#      - An idea whould be to change UCTF to hold frequencies instead of notes
		#        so we can flatten pitch envelopes
		#      - Another could be to add an opcode "instant pitch modify",
		#        that would affect pitch immediately, without long term effect (unlike 1xx/2xx),
		#        this is easy to mix with actual pitch-slide, and actually what instrument pitch envelope do
		#        (bonus: it avoids to use frequencies directly, so more PAL+NTSC friendly)
		envelope_pitch = seq_pit['sequence'][sequence_step]
		envelope_effect = '{}{:02X}'.format(
			'1' if envelope_pitch <= 0 else '2',
			abs(envelope_pitch)
		)

		# Place computed value
		if envelope_pitch != current_slide:
			place_pitch_effect(
				current_chan_row, envelope_effect, effect_idx, replace=True, warn_on_stop=False,
				msg='instrument pitch envelope conflict with pattern in {}: overwrite pattern'.format(
					row_identifier(track_idx, pattern_idx, row_idx, chan_idx)
				)
			)
			current_slide = envelope_pitch

		# Advance sequence
		if seq_pit['loop'] == -1:
			sequence_step = min(sequence_step + 1, len(seq_pit['sequence']) - 1)
			sequence_step = sequence_step + 1
			if sequence_step >= len(seq_pit['sequence']):
				return False
		else:
			sequence_step += 1
			if sequence_step >= len(seq_pit['sequence']):
				sequence_step = seq_pit['loop']
	scan_next_chan_rows(scanner_pit, modified, track_idx, pattern_idx, row_idx)

	# End envelope's effect with a 100
	if last_chan_row is not None:
		if last_chan_row['note'] != '...':
			# Envelope ended by a note, do not replace any existing effect
			place_pitch_effect(last_chan_row, '100', effect_idx, replace=False)
		else:
			# Envelope ended another way, we certainly placed an effect on it, replace it
			place_pitch_effect(last_chan_row, '100', effect_idx, replace=True)

	# Inform that the sequence is handled
	return True

def remove_instruments(music, arp_force_absolute_notes=True):
	"""
	Apply instruments effects to the timeline

	arp_force_absolute_notes:
		If False and the enveloppe is impacted by pitch effect, a frequency_adjust effect will be placed to
		allow the arpeggio to be played alongside the pitch effect.
		This is not famitracker's behaviour, but seems expected by famistudio's exports (and more intuitive.)

	Depends: get_num_channels
	"""
	def get_sequence(music, chan_type, seq_type, seq_idx):
		if seq_idx == -1:
			return None
		return music['macros'][chan_type][seq_type][seq_idx]

	def effect_key(track_idx, chan_idx):
		return (track_idx, chan_idx)

	modified = copy.deepcopy(music)

	# Create an effect column per channel reserved to instruments usage
	# NOTE: we could need to actually create one column per enveloppe type to be safe (and remove HACKs adding their own columns in apply_*_sequence)
	instrument_effect_idx = {} # key=track_idx.chan_idx, value=index of the effect column for instruments usage
	for track_idx in range(len(modified['tracks'])):
		for chan_idx in range(modified['params']['n_chan']):
			# Search for the largest effects list
			max_effects = 0
			def max_effect_scanner(current_pattern_idx, current_row_idx):
				nonlocal max_effects, track_idx, chan_idx
				current_chan_row = modified['tracks'][track_idx]['patterns'][current_pattern_idx]['rows'][current_row_idx]['channels'][chan_idx]
				max_effects = max(max_effects, len(current_chan_row['effects']))
			scan_next_chan_rows(max_effect_scanner, modified, track_idx, 0, 0)

			# Save info of the next column ID, to be used by instruments
			instrument_effect_idx[effect_key(track_idx, chan_idx)] = max_effects

			# Create a new column, and ensure all row have it
			def create_columns_scanner(current_pattern_idx, current_row_idx):
				nonlocal max_effects, track_idx, chan_idx
				current_chan_row = modified['tracks'][track_idx]['patterns'][current_pattern_idx]['rows'][current_row_idx]['channels'][chan_idx]
				while len(current_chan_row['effects']) < max_effects+1:
					current_chan_row['effects'].append('...')
			scan_next_chan_rows(create_columns_scanner, modified, track_idx, 0, 0)

	# Scan each row to flatten instruments
	for track_idx in range(len(modified['tracks'])):
		track = modified['tracks'][track_idx]
		for pattern_idx in range(len(track['patterns'])):
			pattern = track['patterns'][pattern_idx]
			for chan_idx in range(modified['params']['n_chan']):
				effect_idx = instrument_effect_idx[effect_key(track_idx, chan_idx)]
				for row_idx in range(len(pattern['rows'])):
					chan_row = pattern['rows'][row_idx]['channels'][chan_idx]

					# Do nothing if there is no instrument on the row
					if chan_row['instrument'] == '..':
						continue

					# Get instrument details
					instrument_idx = int(chan_row['instrument'], 16)
					instrument = copy.deepcopy(modified['instruments'][instrument_idx])
					if instrument['type'] == '2a03':
						for seq_name in [('seq_vol', 'volume'), ('seq_arp', 'arpeggio'), ('seq_pit', 'pitch'), ('seq_hpi', 'hi-pitch'), ('seq_dut', 'duty')]:
							instrument[seq_name[0]] = get_sequence(modified, instrument['type'], seq_name[1], instrument[seq_name[0]])
					elif instrument['type'] == 'vrc6':
						for seq_name in [('seq_vol', 'volume'), ('seq_arp', 'arpeggio'), ('seq_pit', 'pitch'), ('seq_hpi', 'hi-pitch'), ('seq_wid', 'pulse-width')]:
							instrument[seq_name[0]] = get_sequence(modified, instrument['type'], seq_name[1], instrument[seq_name[0]])
					else:
						ensure(False, 'unsuported instrument type "{}"'.format(instrument['type']))

					seq_vol = instrument.get('seq_vol', None)
					seq_arp = instrument.get('seq_arp', None)
					seq_pit = instrument.get('seq_pit', None)
					seq_hpi = instrument.get('seq_hpi', None)
					seq_dut = instrument.get('seq_dut', None)
					seq_wid = instrument.get('seq_wid', None)

					# Ignore lines without actual note
					ref_note = chan_row['note']
					if ref_note in ['...', '---', '===']:
						if ref_note == '...':
							warn('instrument without note in {}: ignored'.format(
								row_identifier(track_idx, pattern_idx, row_idx, chan_idx)
							))

						seq_vol = None
						seq_arp = None
						seq_pit = None
						seq_hpi = None
						seq_dut = None
						seq_wid = None

					# Remove effects non-applicable to current channel
					if get_chan_type(modified, chan_idx) == '2a03-triangle':
						seq_dut = None

					# Apply instrument effects to the timeline
					if seq_vol is not None:
						if (_apply_volume_sequence(seq_vol, ref_note, modified, instrument_idx, track_idx, pattern_idx, row_idx, chan_idx, effect_idx)):
							seq_vol = None

					if seq_dut is not None:
						if (_apply_duty_sequence(seq_dut, ref_note, modified, instrument_idx, track_idx, pattern_idx, row_idx, chan_idx, effect_idx)):
							seq_dut = None

					if seq_arp is not None:
						if (_apply_arpeggio_sequence(seq_arp, ref_note, modified, instrument_idx, track_idx, pattern_idx, row_idx, chan_idx, effect_idx, force_absolute_notes=arp_force_absolute_notes)):
							seq_arp = None

					if seq_pit is not None:
						if (_apply_pitch_sequence(seq_pit, ref_note, modified, instrument_idx, track_idx, pattern_idx, row_idx, chan_idx, effect_idx)):
							seq_pit = None

					# Remove instrument reference (only if completely handled, to keep warnings where it was partial)
					if (
						seq_vol is None and
						seq_arp is None and
						seq_pit is None and
						seq_hpi is None and
						seq_dut is None and
						seq_wid is None
					):
						chan_row['instrument'] = '..'

	return modified

def repeat_3_effect(music):
	"""
	Repeat 3xx effects in front of each note while it is active.

	Note: 3xx are deactivated by any pitch effect
	"""
	modified = copy.deepcopy(music)

	for track_idx in range(len(modified['tracks'])):
		track = modified['tracks'][track_idx]
		for pattern_idx in range(len(track['patterns'])):
			pattern = track['patterns'][pattern_idx]
			for chan_idx in range(modified['params']['n_chan']):

				original_portamento_effect_idx = None
				current_portamento = 0
				for row_idx in range(len(pattern['rows'])):
					chan_row = pattern['rows'][row_idx]['channels'][chan_idx]

					# Check if there is a portamento effect
					portamento_effect_idx = None
					has_other_pitch_effect = False
					for effect_idx in range(len(chan_row['effects'])):
						effect = chan_row['effects'][effect_idx]
						if effect[0] == '3':
							if portamento_effect_idx is not None:
								warn('multiple 3XX effects in {}'.format(
									row_identifier(track_idx, pattern_idx, row_idx, chan_idx)
								))
								chan_row['effects'][portamento_effect_idx] = '...'
							portamento_effect_idx = effect_idx
						elif effect[0] in pitch_effects:
							has_other_pitch_effect = True

					# Check that we are still treating the original effect
					if original_portamento_effect_idx is None:
						original_portamento_effect_idx = portamento_effect_idx

					if portamento_effect_idx is not None and portamento_effect_idx != original_portamento_effect_idx:
						#TODO propper handling of multi effects on different columns (may need to rewrite this function from scratch)
						warn('multiple 3XX effects in {}: keeping the one on column {}, removing from column {}'.format(
							row_identifier(track_idx, pattern_idx, row_idx, chan_idx),
							original_portamento_effect_idx,
							portamento_effect_idx
						))
						chan_row['effects'][portamento_effect_idx] = '...'
						portamento_effect_idx = None

					# Parse effect
					portamento_effect = chan_row['effects'][portamento_effect_idx] if portamento_effect_idx is not None else None
					new_portamento = int(portamento_effect[1:], 16) if portamento_effect_idx is not None else None

					# Corner cases
					if has_other_pitch_effect and new_portamento is not None and new_portamento != 0:
						warn('3XX effect with other pitch effects in {}: 3XX ignored'.format(
							row_identifier(track_idx, pattern_idx, row_idx, chan_idx)
						))
						assert portamento_effect_idx is not None, "effect_idx is None while effect value is not"
						chan_row['effects'][portamento_effect_idx] = '...'
						continue

					# Special case of portamento 0, deactivation. Place 100 if there is no other pitch effect
					if new_portamento == 0:# and not has_other_pitch_effect:
						chan_row['effects'][portamento_effect_idx] = '100'

					# Update current portamento value
					if new_portamento is not None or has_other_pitch_effect:
						current_portamento = new_portamento if not has_other_pitch_effect else 0

					# If there is a note, repeat portamento
					if chan_row['note'] not in ['...', '---', '==='] and not get_extra_effect(chan_row, '3xx_skip', False) and portamento_effect_idx is None and current_portamento != 0:

						# Do not apply on notes preceded by a stop (matches famitracker's behaviour)
						#NOTE: Check actually done by apply_3_effect, reactivate here if log-flood is too ennoying
						#if get_previous_note(modified, track_idx, pattern_idx, chan_idx, row_idx, ignore_stop=False)['note'] in ['---', '===']:
						#	continue

						# Place the 3xx effect
						if chan_row['effects'][original_portamento_effect_idx] != '...' and chan_row['effects'][original_portamento_effect_idx][0] not in pitch_effects:
							warn('unable to place portamento because of non-pitch effect in {}'.format(
								row_identifier(track_idx, pattern_idx, row_idx, chan_idx)
							))
						if chan_row['effects'][original_portamento_effect_idx] == '...':
							chan_row['effects'][original_portamento_effect_idx] = '3{:02X}'.format(current_portamento)

	return modified

def apply_3_effect(music):
	"""
	Transform 3xx effects to 1xx or 2xx

	Expects: repeat_3_effect
	"""
	modified = copy.deepcopy(music)

	# Iterate on rows per channel
	for track_idx in range(len(modified['tracks'])):
		track = modified['tracks'][track_idx]
		for pattern_idx in range(len(track['patterns'])):
			pattern = track['patterns'][pattern_idx]
			for chan_idx in range(modified['params']['n_chan']):
				for row_idx in range(len(pattern['rows'])):
					chan_row = pattern['rows'][row_idx]['channels'][chan_idx]

					# Find if current row has a 3xx effect
					portamento_effect_idx = None
					has_other_pitch_effect = False
					for effect_idx in range(len(chan_row['effects'])):
						effect = chan_row['effects'][effect_idx]
						if effect[0] == '3':
							if portamento_effect_idx is not None:
								#TODO handle columns separately
								warn('multiple 3xx effects in {}: some will be ignored'.format(
									row_identifier(track_idx, pattern_idx, row_idx, chan_idx)
								))
							portamento_effect_idx = effect_idx
						elif effect[0] in pitch_effects:
							has_other_pitch_effect = True

					# Do not process the row if it has no 3xx effect or is a non-supported corner case
					if portamento_effect_idx is None:
						continue

					if has_other_pitch_effect:
						#TODO handle columns separately
						warn('multiple pitch effects in {}: 3xx will be ignored'.format(
							row_identifier(track_idx, pattern_idx, row_idx, chan_idx)
						))
						chan_row['effects'][portamento_effect_idx] = '...'
						continue

					if chan_row['note'] in ['...', '---', '===']:
						warn('3xx effect without explicit note in {}: effect ignored'.format(
							row_identifier(track_idx, pattern_idx, row_idx, chan_idx)
						))
						chan_row['effects'][portamento_effect_idx] = '...'
						continue

					# Search for original note
					original_note = get_previous_note(modified, track_idx, pattern_idx, chan_idx, row_idx, ignore_stop=False)

					if original_note['note'] is None:
						warn('3xx effect without original note in {}: effect ignored'.format(
							row_identifier(track_idx, pattern_idx, row_idx, chan_idx)
						))
						chan_row['effects'][portamento_effect_idx] = '...'
						continue

					if original_note['note'] in ['---', '===']:
						notice('3xx effect on a note preceded by a stop in {}: effect ignored'.format(
							row_identifier(track_idx, pattern_idx, row_idx, chan_idx)
						))
						chan_row['effects'][portamento_effect_idx] = '...'
						continue

					if original_note['reliable']:
						original_note = original_note['note']
					else:
						if original_note['unhandled_cases'] != []:
							warn('3xx effect while origin note was impacted by unhandled pitch effect in {}: original note roughly estimated'.format(
								row_identifier(track_idx, pattern_idx, row_idx, chan_idx)
							))
						else:
							notice('3xx effect while origin note was impacted by pitch effect in {}: original note estimated (precision={}%)'.format(
								row_identifier(track_idx, pattern_idx, row_idx, chan_idx),
								100 * (1 - abs(get_note_frequency(original_note['approximate_note']) - original_note['frequency']) / original_note['frequency'])
							))
						original_note = original_note['approximate_note']

					# Compute useful values
					effect = chan_row['effects'][portamento_effect_idx]
					slide_speed = int(effect[1:], 16)
					freq_start = get_note_frequency(original_note)
					freq_stop = get_note_frequency(chan_row['note'])
					duration = int(abs(freq_start - freq_stop) / slide_speed) # Round down, we do not want to go over the destination frequence

					# Special handling when destination note is the same as original (just ignore the effect)
					if duration == 0:
						chan_row['effects'][portamento_effect_idx] = '...'
						continue

					# Compute end row
					dest_row_idx = row_idx + duration
					if dest_row_idx >= len(pattern['rows']):
						warn('3xx effect goes over pattern limits in {}: truncated to pattern end'.format(
							row_identifier(track_idx, pattern_idx, dest_row_idx, chan_idx)
						))
						dest_row_idx = len(pattern['rows']) - 1

					# Special handling when ending on the same row as we begin (same as if duration == 0, but due to truncation)
					if dest_row_idx == row_idx:
						chan_row['effects'][portamento_effect_idx] = '...'
						continue

					# Replace current row's effect with the equivalent 1xx or 2xx effect
					direction = '1' if freq_stop < freq_start else '2'
					chan_row['effects'][portamento_effect_idx] = '{}{:02X}'.format(direction, slide_speed)

					# Place the note and a 100 effect at stop location
					explicitely_stopped = False
					assert dest_row_idx > row_idx
					for current_row_idx in range(row_idx+1, dest_row_idx+1):
						current_row = pattern['rows'][current_row_idx]['channels'][chan_idx]

						explicitely_stopped = current_row['note'] != '...'
						if current_row['effects'][portamento_effect_idx][0] in pitch_effects:
							explicitely_stopped = True

						if explicitely_stopped:
							dest_row_idx = current_row_idx
							break

					if not explicitely_stopped:
						pattern['rows'][dest_row_idx]['channels'][chan_idx]['note'] = chan_row['note']

					dest_has_pitch = False
					current_effect = pattern['rows'][dest_row_idx]['channels'][chan_idx]['effects'][portamento_effect_idx]
					if current_effect[0] in pitch_effects:
						dest_has_pitch = True

					if not dest_has_pitch:
						if current_effect != '...':
							warn('non-pitch effect at portamento end location in {}: removing the non-pitch effect'.format(
								row_identifier(track_idx, pattern_idx, row_idx, chan_idx)
							))
						pattern['rows'][dest_row_idx]['channels'][chan_idx]['effects'][portamento_effect_idx] = '100'

					# Remove the note from origin row
					chan_row['note'] = '...'

	return modified

def apply_qr_effect(music, effect_name):
	"""
	Can apply Qxy or Rxy effects, as they are similar

	effect_name: 'Q" to apply Qxy effects, 'R' to apply Rxy effects
	"""
	# Helper functions
	def w(m):
		warn('{}xy {}'.format(effect_name, m))

	# Iterate on rows per channel
	for track_idx in range(len(music['tracks'])):
		track = music['tracks'][track_idx]
		for pattern_idx in range(len(track['patterns'])):
			pattern = track['patterns'][pattern_idx]
			for chan_idx in range(music['params']['n_chan']):
				for row_idx in range(len(pattern['rows'])):
					chan_row = pattern['rows'][row_idx]['channels'][chan_idx]
					for effect_idx in range(len(chan_row['effects'])):

						# Trigger processing only when we encounter the effect
						if chan_row['effects'][effect_idx][0] != effect_name:
							continue

						# Get original note
						origin_note = chan_row['note']

						if origin_note in ['---', '===']:
							w('effect on a stop in {}: Rxy ignored'.format(
								row_identifier(track_idx, pattern_idx, row_idx, chan_idx)
							))
							chan_row['effects'][effect_idx] = '...'
							continue

						if origin_note == '...':
							origin_note_info = get_previous_note(music, track_idx, pattern_idx, chan_idx, row_idx, ignore_stop=False)

							error = False
							if origin_note_info['note'] is None:
								w('effect without explicit note in {}: effect ignored'.format(
									row_identifier(track_idx, pattern_idx, row_idx, chan_idx)
								))
								error = True

							if origin_note_info['note'] in ['---', '===']:
								w('effect while previous note is a stop in {}: effect ignored'.format(
									row_identifier(track_idx, pattern_idx, row_idx, chan_idx)
								))
								error = True

							if not origin_note_info['reliable']:
								#NOTE it should be doable to use computed frequency if necessary, ultimately we just want to compute freq_start and freq_stop
								w('effect with reference note impacted by pitch effect in {}: ignored'.format(
									row_identifier(track_idx, pattern_idx, row_idx, chan_idx)
								))
								error = True

							if error:
								chan_row['effects'][effect_idx] = '...'
								continue

							origin_note = origin_note_info['note']

						# Compute useful values
						effect = chan_row['effects'][effect_idx]
						effect_x = int(effect[1], 16)
						effect_y = int(effect[2], 16)
						slide_speed = 2 * effect_x + 1
						freq_start = get_note_frequency(origin_note)
						note_table_index_stop = None
						freq_stop = None
						duration = None

						if effect_name == 'Q':
							note_table_index_stop = get_note_table_index(origin_note) + effect_y
							if note_table_index_stop >= len(note_table_freqs):
								warn('Qxy effect extends after notes table in {}: effect truncated'.format(
									row_identifier(track_idx, pattern_idx, row_idx, chan_idx)
								))
								note_table_index_stop = len(note_table_freqs) - 1
							freq_stop = note_table_freqs[note_table_index_stop]
							assert freq_stop <= freq_start
							duration = int((freq_start - freq_stop) / slide_speed)
						else:
							note_table_index_stop = get_note_table_index(origin_note) - effect_y
							if note_table_index_stop < 0:
								w('effect extends before notes table in {}: effect truncated'.format(
									row_identifier(track_idx, pattern_idx, row_idx, chan_idx)
								))
								note_table_index_stop = 0
							freq_stop = note_table_freqs[note_table_index_stop]
							assert freq_start <= freq_stop
							duration = int((freq_stop - freq_start) / slide_speed)

						ensure(duration > 0, 'TODO handle super speedy Q/R effects (should just place dest note at start)')

						# Replace current row's effect with the equivalent pitch slide effect
						chan_row['effects'][effect_idx] = '{}{:02X}'.format({'Q':1,'R':2}[effect_name], slide_speed)

						# Determine actual stop row
						#  it can be before duration if
						#   - There is a note before destination, or
						#   - there is a pitch effect before destination
						stop_row_pattern_idx = None
						stop_row_idx = None
						current_step = 1
						def scanner_find_duration(current_pattern_idx, current_row_idx):
							nonlocal current_step, stop_row_idx, stop_row_pattern_idx, track
							current_chan_row = track['patterns'][current_pattern_idx]['rows'][current_row_idx]['channels'][chan_idx]
							if current_step == duration or current_chan_row['note'] != '...' or current_chan_row['effects'][effect_idx][0] in pitch_effects:
								stop_row_pattern_idx = current_pattern_idx
								stop_row_idx = current_row_idx
								return False
							current_step += 1
						scan_next_chan_rows(scanner_find_duration, music, track_idx, pattern_idx, row_idx+1)

						if stop_row_idx is None:
							#NOTE possible if the effect lasts after the last pattern, should be fixed if it occurs
							w('effect stop row not found in {}: effect ignored'.format(
								row_identifier(track_idx, pattern_idx, row_idx, chan_idx)
							))
							chan_row['effects'][effect_idx] = '...'
							continue

						# Place an 100 effect and the stop note at stop location
						stop_chan_row = track['patterns'][stop_row_pattern_idx]['rows'][stop_row_idx]['channels'][chan_idx]

						stop_has_pitch_effect = False
						if stop_chan_row['effects'][effect_idx][0] in pitch_effects:
							stop_has_pitch_effect = True

						if not stop_has_pitch_effect:
							if stop_chan_row['effects'][effect_idx] != '...':
								w('effect stops where a non-pitch effect is placed in {}: removing non-pitch effect {}'.format(
									row_identifier(track_idx, pattern_idx, stop_row_idx, chan_idx),
									stop_chan_row['effects'][effect_idx]
								))
							stop_chan_row['effects'][effect_idx] = '100'

						if stop_chan_row['note'] == '...':
							stop_chan_row['note'] = note_table_names[note_table_index_stop]

	return music

def apply_q_effect(music):
	return apply_qr_effect(music, 'Q')

def apply_r_effect(music):
	return apply_qr_effect(music, 'R')

def apply_4_effect(music):
	modified = copy.deepcopy(music)

	#
	# Vibrato apply functions
	#

	def vibrato_flatten_noise(depth, modified, track_idx, pattern_idx, row_idx, chan_idx, vibrato_effect_idx):
		"""
		Apply vibrato on noise channel by flattening it.
		This is costly, but can handles step values lower than 1, which is the minimum of 1xx effect.
		"""
		track = modified['tracks'][track_idx]

		# Get original pitch
		current_pitch = None
		def scanner_flatten_original_pitch(current_pattern_idx, current_row_idx):
			nonlocal current_pitch, track
			current_chan_row = track['patterns'][current_pattern_idx]['rows'][current_row_idx]['channels'][chan_idx]
			if current_chan_row['note'] not in ['...', '---', '===']:
				current_pitch = int(current_chan_row['note'][0], 16)
				return False
		scan_previous_chan_rows(scanner_flatten_original_pitch, modified, track_idx, pattern_idx, chan_idx, row_idx)

		ensure(current_pitch is not None, 'unable to find original pitch for 4xy in {}: TODO handle it for next notes'.format(
			row_identifier(track_idx, pattern_idx, row_idx, chan_idx)
		))

		# Remove effect from pattern
		chan_row['effects'][vibrato_effect_idx] = '...'

		# Compute vibrato envelope
		vibrato_envelope = []
		for i in range(16):
			vibrato_envelope.append(int(i * depth / 16))
		for i in range(16):
			vibrato_envelope.append(int((16 - i) * depth / 16))
		for i in range(16):
			vibrato_envelope.append(int(-i * depth / 16))
		for i in range(16):
			vibrato_envelope.append(int(-(16 - i) * depth / 16))
		assert len(vibrato_envelope) == 64

		# Apply vibrato until another pitch effect is found or the slide is over
		envelope_step = 0
		def scanner_flatten_apply(current_pattern_idx, current_row_idx):
			nonlocal current_pitch, envelope_step
			current_chan_row = track['patterns'][current_pattern_idx]['rows'][current_row_idx]['channels'][chan_idx]

			# Stop on any pitch effect
			#TODO only stop on pitch effect in the same column
			initial_row = (current_pattern_idx == pattern_idx and current_row_idx == row_idx)
			if not initial_row and len(get_pitch_effects(current_chan_row)) != 0:
				#TODO warn if not a 4xy
				return False

			# Stop on halt/release
			if current_chan_row['note'] in ['---', '===']:
				warn('4xy goes through a stop in {} at {}: effect truncated'.format(
					row_identifier(track_idx, pattern_idx, row_idx, chan_idx),
					row_identifier(track_idx, current_pattern_idx, current_row_idx, chan_idx)
				))
				return False

			# Reset pitch if a note is found on column
			if current_chan_row['note'] != '...':
				current_pitch = int(current_chan_row['note'][0], 16)

			# Rewrite note as impacted by envelope
			pitch_with_envelope = current_pitch + vibrato_envelope[envelope_step]
			pitch_with_envelope = max(0, min(15, pitch_with_envelope))
			current_chan_row['note'] = '{:X}-#'.format(pitch_with_envelope)

			# Step envelope position
			envelope_step = (envelope_step + effect_speed) % len(vibrato_envelope)
		scan_next_chan_rows(scanner_flatten_apply, modified, track_idx, pattern_idx, row_idx)

	def vibrato_slide(step, half_way_time, modified, track_idx, pattern_idx, row_idx, chan_idx, vibrato_effect_idx):
		"""
		Apply vibrato on any channel by convering it to a series of 1xx 2xx.
		This is cheap, but can conflict with other pitch effects.
		"""
		# Step must be an integer
		step_int = int(0.5 + step)
		if abs(step_int - step) / step > .1:
			warn('4xy transformation to pitch slide is imprecise in {}: precision lost'.format(
				row_identifier(track_idx, pattern_idx, row_idx, chan_idx)
			))
		step = step_int

		# Replace current row's effect with a 2xx effect for the initial half way pitch deviation
		time_left = half_way_time
		current_direction = '2'
		chan_row['effects'][vibrato_effect_idx] = '{}{:02X}'.format(current_direction, step)

		# Every one way pitch deviation, change direction. Until the next pitch impacting effect.
		current_row_idx = row_idx + 1
		while current_row_idx < len(pattern['rows']):
			current_chan_row = pattern['rows'][current_row_idx]['channels'][chan_idx]

			# If there is any pitch effect in the same column as the initial 4xy, just stop
			#   warn if pitch impacting effect is not a 4xy (these effects should be stopped by a 40*)
			has_pitch_effect = False
			current_effect = current_chan_row['effects'][vibrato_effect_idx]
			if current_effect[0] in pitch_effects:
				if current_effect[0] != '4':
					notice('4xy effect is interrupted by another effect type in {}, starting in {}'.format(
						row_identifier(track_idx, pattern_idx, current_row_idx, chan_idx),
						row_identifier(track_idx, pattern_idx, row_idx, chan_idx)
					))
				has_pitch_effect = True

			if has_pitch_effect:
				break

			# If there is a non-pitch effect, move it to another column
			if current_effect != '...':
				#NOTE A solution could be to have an early filter that places non-pitch effect on other collumns
				#     than pitch effects while keeping interdependent effects on the same column
				#     Example: from one column containing pitch slides and volume slides,
				#              we get two columnsi: one with only pitch slides, another with only volume slides
				warn('non-pitch effect while a 4xy is active in {}: moving the non-pitch effect to another column'.format(
					row_identifier(track_idx, pattern_idx, current_row_idx, chan_idx),
				))
				current_chan_row['effects'][vibrato_effect_idx] = '...'
				current_chan_row['effects'].append(current_effect)

			# If it is time, change direction
			time_left -= 1
			if time_left <= 0:
				current_direction = '2' if current_direction == '1' else '1'
				time_left = one_way_time
				current_chan_row['effects'][vibrato_effect_idx] = '{}{:02X}'.format(current_direction, step)

			# Next
			current_row_idx += 1

		# Check if we hit the end of pattern
		if current_row_idx >= len(pattern['rows']):
			#TODO use scanner to avoid that
			warn('4xy effect extends after pattern in {}: effect truncated'.format(row_identifier(track_idx, pattern_idx, row_idx, chan_idx)))
			pattern['rows'][-1]['channels'][chan_idx]['effects'][vibrato_effect_idx] = '100'

	#
	# Common logic
	#

	# Iterate on rows per channel
	for track_idx in range(len(modified['tracks'])):
		track = modified['tracks'][track_idx]
		for pattern_idx in range(len(track['patterns'])):
			pattern = track['patterns'][pattern_idx]
			for chan_idx in range(modified['params']['n_chan']):
				for row_idx in range(len(pattern['rows'])):
					chan_row = pattern['rows'][row_idx]['channels'][chan_idx]

					# Find if current row has a 4 effect
					vibrato_effect_idx = None
					has_other_pitch_effect = False
					for effect_idx in range(len(chan_row['effects'])):
						effect = chan_row['effects'][effect_idx]
						if effect[0] == '4':
							if vibrato_effect_idx is not None:
								#TODO handle columns separately
								warn('multiple 4xy effects in {}: some will be ignored'.format(
									row_identifier(track_idx, pattern_idx, row_idx, chan_idx)
								))
							vibrato_effect_idx = effect_idx
						elif effect[0] in pitch_effects:
							has_other_pitch_effect = True

					# Do not process the row if it has no 4 effect or is a non-supported corner case
					if vibrato_effect_idx is None:
						continue

					if has_other_pitch_effect:
						#TODO Handle multiple 4xy (by handling columns separately)
						#TODO Maybe fail if we have to flatten noise or
						#     warn harder since it is compatble with pitch effect but not other flattening.
						warn('multiple pitch effects in {}: 4xy support for it is partial'.format(
							row_identifier(track_idx, pattern_idx, row_idx, chan_idx)
						))

					# Special handling of 40*, simply stop pitch slide
					effect = chan_row['effects'][vibrato_effect_idx]
					if effect[1] == '0':
						chan_row['effects'][vibrato_effect_idx] = '100'
						continue

					# Compute useful values
					effect_speed = int(effect[1], 16)
					effect_y = int(effect[2], 16)
					assert effect_speed != 0

					period = 64 / effect_speed
					depth = [1, 1, 2, 3, 4, 7, 8, 0xf, 0x10, 0x1f, 0x20, 0x3f, 0x40, 0x7f, 0x80, 0xff][effect_y]

					step = (depth * 4) / period
					one_way_time = int(.5 + period / 2)
					half_way_time = int(.5 + period / 4)
					conversion_type = 'pitch-slide'
					if step < 1:
						conversion_type = 'flatten'

					if half_way_time < 1:
						warn('4xy effect too tight in {}: period={}, one_way={}, half_way={}'.format(
							row_identifier(track_idx, pattern_idx, row_idx, chan_idx),
							period, one_way_time, half_way_time
						))

					# Transform effect
					assert conversion_type in ['flatten', 'pitch-slide']
					if get_chan_type(modified, chan_idx) == '2a03-noise' and conversion_type == 'flatten':
						vibrato_flatten_noise(depth, modified, track_idx, pattern_idx, row_idx, chan_idx, vibrato_effect_idx)
					elif conversion_type == 'pitch-slide':
						vibrato_slide(step, half_way_time, modified, track_idx, pattern_idx, row_idx, chan_idx, vibrato_effect_idx)
					else:
						warn('unhandled 4xy in {} chan_type="{}" conversion="{}": effect ignored'.format(
							row_identifier(track_idx, pattern_idx, row_idx, chan_idx),
							get_chan_type(modified, chan_idx), conversion_type
						))

	return modified

def apply_a_effect(music):
	modified = copy.deepcopy(music)

	# Iterate on rows per channel
	for track_idx in range(len(modified['tracks'])):
		track = modified['tracks'][track_idx]
		for pattern_idx in range(len(track['patterns'])):
			pattern = track['patterns'][pattern_idx]
			for chan_idx in range(modified['params']['n_chan']):
				for row_idx in range(len(pattern['rows'])):
					chan_row = pattern['rows'][row_idx]['channels'][chan_idx]

					# Find if current row has a A effect
					a_effect_idx = None
					has_other_volume_effect = False
					for effect_idx in range(len(chan_row['effects'])):
						effect = chan_row['effects'][effect_idx]
						if effect[0] == 'A':
							if a_effect_idx is not None:
								warn('multiple Axy effects in {}: some will be ignored'.format(
									row_identifier(track_idx, pattern_idx, row_idx, chan_idx)
								))
							a_effect_idx = effect_idx
						elif effect[0] in volume_effects:
							has_other_volume_effect = True

					# Do not process the row if it has no A effect or is a non-supported corner case
					if a_effect_idx is None:
						continue

					a_effect = chan_row['effects'][a_effect_idx]
					if a_effect == 'A00':
						chan_row['effects'][a_effect_idx] = '...'
						continue

					if has_other_volume_effect:
						warn('multiple volume effects in {}: Axy will be ignored'.format(
							row_identifier(track_idx, pattern_idx, row_idx, chan_idx)
						))
						chan_row['effects'][a_effect_idx] = '...'
						continue

					# Get original volume
					current_volume = None
					def scanner(current_pattern_idx, current_row_idx):
						nonlocal current_volume
						current_chan_row = track['patterns'][current_pattern_idx]['rows'][current_row_idx]['channels'][chan_idx]
						if current_chan_row['volume'] != '.':
							current_volume = int(current_chan_row['volume'], 16)
							return False
					scan_previous_chan_rows(scanner, modified, track_idx, pattern_idx, chan_idx, row_idx)

					if current_volume is None:
						current_volume = 15

					# Parse effect
					effect_x = int(a_effect[1], 16)
					effect_y = int(a_effect[2], 16)
					ensure(effect_x == 0 or effect_y == 0, 'Axy effect without 0')
					slide = -effect_y if effect_x == 0 else effect_x
					slide = slide / 8.

					# Remove effect from pattern
					chan_row['effects'][a_effect_idx] = '...'

					# Apply volume slide until another volume effect is found or the slide is over
					current_row_idx = row_idx
					while current_row_idx < len(pattern['rows']):
						current_chan_row = pattern['rows'][current_row_idx]['channels'][chan_idx]

						# Reset volume if any volume exists in the volume column
						if current_chan_row['volume'] != '.':
							current_volume = int(current_chan_row['volume'], 16)

						# Stop immediately on any volume effect
						current_volume_effect = None
						for current_effect in current_chan_row['effects']:
							if current_effect[0] == 'A':
								current_volume_effect = current_effect
							elif current_volume_effect is None and current_effect[0] in volume_effects:
								current_volume_effect = current_effect

						if current_volume_effect is not None:
							if current_volume_effect[0] != 'A':
								warn('Axy interrupted by another volume effect in {}: volume slide stopped'.format(
									row_identifier(track_idx, pattern_idx, row_idx, chan_idx)
								))
							break

						# Apply new volume
						current_volume += slide
						current_volume = min(15, max(0, current_volume))
						current_chan_row['volume'] = '{:2X}'.format(int(current_volume))

						# Stop if the slide hit the end
						if current_volume <= 0 or current_volume >= 15:
							break

						current_row_idx += 1

					if current_row_idx >= len(pattern['rows']):
						warn('Axy goes beyond end of pattern in {}: effect truncated'.format(
							row_identifier(track_idx, pattern_idx, row_idx, chan_idx)
						))

	return modified

def merge_pitch_slides(music):
	"""
	Merge 1xx and 2xx effects impacting the same row into only one.
	"""
	for track_idx in range(len(music['tracks'])):
		for chan_idx in range(music['params']['n_chan']):
			currrent_slide = {}
			def scanner_pitch_merge(current_pattern_idx, current_row_idx):
				nonlocal chan_idx, currrent_slide, music, track_idx
				current_row = music['tracks'][track_idx]['patterns'][current_pattern_idx]['rows'][current_row_idx]['channels'][chan_idx]

				# Remove slide effects from pattern, and update current slide info of each row
				has_new_slide = False
				for effect_idx in range(len(current_row['effects'])):
					effect = current_row['effects'][effect_idx]
					if effect[0] in ['1', '2']:
						if effect[0] == '1':
							currrent_slide[effect_idx] = -int(effect[1:], 16)
						else:
							currrent_slide[effect_idx] = int(effect[1:], 16)

						current_row['effects'][effect_idx] = '...'
						has_new_slide = True

				# Compute merged slide value
				if has_new_slide:
					merged_slide = 0
					for row_slide in currrent_slide.values():
						merged_slide += row_slide

					current_row['effects'].append('{}{:02X}'.format(
						'1' if merged_slide <= 0 else '2',
						abs(merged_slide)
					))

			scan_next_chan_rows(scanner_pitch_merge, music, track_idx, 0, 0)

	return music

def warn_instruments(music):
	"""
	Output warnings if the music uses instruments not handled by the engine
	"""
	#TODO check all channels, not just 2a03
	for track_idx in range(len(music['tracks'])):
		track = music['tracks'][track_idx]
		for pattern_idx in range(len(track['patterns'])):
			pattern = track['patterns'][pattern_idx]
			for row_idx in range(len(pattern['rows'])):
				row = pattern['rows'][row_idx]
				for channel_idx in [0, 1, 2, 3]:
					chan_row = row['channels'][channel_idx]
					if chan_row['instrument'] != '..':
						warn('instrument not handled in {}: instrument={}'.format(
							row_identifier(track_idx, pattern_idx, row_idx, channel_idx),
							chan_row['instrument']
						))
	return music

def warn_effects(music):
	"""
	Output warnings if the music uses effects not handled by the engine
	"""
	#TODO check all channels, not just 2a03
	for track_idx in range(len(music['tracks'])):
		track = music['tracks'][track_idx]
		for pattern_idx in range(len(track['patterns'])):
			pattern = track['patterns'][pattern_idx]
			for row_idx in range(len(pattern['rows'])):
				row = pattern['rows'][row_idx]
				for channel_idx in [0, 1, 2, 3]:
					chan_row = row['channels'][channel_idx]

					pitch_effects = []
					duty_effects = []
					for effect in chan_row['effects']:
						if effect[0] not in ['.', '1', '2', 'V']:
							warn('effect not handled in {}: effect={}'.format(
								row_identifier(track_idx, pattern_idx, row_idx, channel_idx),
								effect
							))
						elif effect[0] in ['1', '2']:
							pitch_effects.append(effect)
						elif effect[0] == 'V':
							duty_effects.append(effect)

					if len(pitch_effects) > 1:
						warn('multiple pitch effects not merged in {}: effects={}'.format(
							row_identifier(track_idx, pattern_idx, row_idx, channel_idx),
							pitch_effects
						))
					if len(duty_effects) > 1:
						warn('multiple duty effects not merged in {}: effects={}'.format(
							row_identifier(track_idx, pattern_idx, row_idx, channel_idx),
							duty_effects
						))
	return music

def remove_superfluous_volume(music):
	"""
	Remove volume info when it duplicates the previous one

	Depends: get_num_channels
	"""
	modified = copy.deepcopy(music)
	for track in modified['tracks']:
		for pattern in track['patterns']:
			for chan_idx in range(modified['params']['n_chan']):
				previous_volume = None
				for row_idx in range(len(pattern['rows'])):
					chan_row = pattern['rows'][row_idx]['channels'][chan_idx]
					assert isinstance(chan_row, dict)

					if chan_row['volume'] != '.':
						current_volume = int(chan_row['volume'], 16)
						if current_volume == previous_volume:
							chan_row['volume'] = '.'
						previous_volume = current_volume
	return modified

def remove_superfluous_duty(music):
	"""
	Remove duty info when it duplicates the previous one

	Depends: get_num_channels
	"""
	modified = copy.deepcopy(music)

	for track_idx in range(len(modified['tracks'])):
		track = modified['tracks'][track_idx]
		for pattern_idx in range(len(track['patterns'])):
			pattern = track['patterns'][pattern_idx]
			for chan_idx in range(modified['params']['n_chan']):
				previous_duty = None
				for row_idx in range(len(pattern['rows'])):
					chan_row = pattern['rows'][row_idx]['channels'][chan_idx]
					assert isinstance(chan_row, dict)

					current_duty = None
					duty_effect_idx = None
					for effect_idx in range(len(chan_row['effects'])):
						effect = chan_row['effects'][effect_idx]
						if effect[0] == 'V':
							if current_duty is not None:
								warn('after manipulation, multiple duty effects in {}: some ignored'.format(
									row_identifier(track_idx, pattern_idx, row_idx, chan_idx),
								))
								chan_row['effects'][effect_idx] = '...'
							else:
								current_duty = int(effect[1:], 16)
								duty_effect_idx = effect_idx

					if current_duty is not None:
						assert duty_effect_idx is not None
						if current_duty == previous_duty:
							chan_row['effects'][duty_effect_idx] = '...'
						previous_duty = current_duty

	return modified

def std_empty_row(music):
	"""
	Replace empty rows by a standard string

	Depends: none
	"""
	modified = copy.deepcopy(music)
	for track in modified['tracks']:
		for pattern in track['patterns']:
			for row in pattern['rows']:
				for chan_idx in range(len(row['channels'])):
					chan_row = row['channels'][chan_idx]
					if isinstance(chan_row, dict):
						# Determine if the row is empty for this channel
						empty = chan_row['note'] == '...' and chan_row['instrument'] == '..' and chan_row['volume'] == '.'
						for effect in chan_row['effects']:
							empty = empty and effect == '...'

						# Replace empty row by a sigle standard string
						if empty:
							row['channels'][chan_idx] = 'empty_row'
	return modified

def to_uncompressed_format(music):
	"""
	Add a top level dict named "uctf", containing the "Uncompressed Tracker Format" version of the music.

	Depends: get_num_channels, std_empty_row
	"""
	modified = copy.deepcopy(music)
	modified['uctf'] = {
		'channels': [],
		'samples': [],
	}

	for track in modified['tracks']:
		for chan_idx in range(modified['params']['n_chan']):
			modified['uctf']['channels'].append([])
			for pattern in track['patterns']:
				# Skip unsuported channels
				#TODO generate samples for all channels
				if chan_idx not in [0, 1, 2, 3]:
					continue

				# Construct sample from channel's rows
				sample = {
					'type': get_chan_type(modified, chan_idx),
					'lines': []
				}
				for row in pattern['rows']:
					chan_row = row['channels'][chan_idx]

					if isinstance(chan_row, str):
						assert chan_row == 'empty_row'
						sample['lines'].append('empty_row')
					else:
						duty_effect = '...'
						pitch_slide = None
						frequency_adjust = None
						for effect in chan_row['effects']:
							if effect[0] == 'V':
								duty_effect = effect
							elif effect[0] == '1':
								pitch_slide = -int(effect[1:], 16)
							elif effect[0] == '2':
								pitch_slide = int(effect[1:], 16)
						for effect in chan_row.get('extra_effects', []):
							if effect['effect'] == 'frequency_adjust':
								frequency_adjust = effect['value']

						if sample['type'] == '2a03-pulse':
							sample['lines'].append({
								'note': chan_row['note'] if chan_row['note'] != '...' else None,
								'frequency_adjust': frequency_adjust,
								'volume': int(chan_row['volume'], 16) if chan_row['volume'] != '.' else None,
								'duty': int(duty_effect[1:], 16) if duty_effect != '...' else None,
								'pitch_slide': pitch_slide
							})
						elif sample['type'] == '2a03-triangle':
							sample['lines'].append({
								'note': chan_row['note'] if chan_row['note'] != '...' else None,
								'frequency_adjust': frequency_adjust,
								'pitch_slide': pitch_slide
							})
						elif sample['type'] == '2a03-noise':
							sample['lines'].append({
								'freq': chan_row['note'] if chan_row['note'] != '...' else None,
								'frequency_adjust': frequency_adjust,
								'volume': int(chan_row['volume'], 16) if chan_row['volume'] != '.' else None,
								'periodic': int(duty_effect[1:], 16) if duty_effect != '...' else None,
								'pitch_slide': -pitch_slide if pitch_slide is not None else None
							})
						else:
							ensure(False, 'unhandled sample type: {}'.format(sample['type']))

				# Store Sample
				modified['uctf']['channels'][-1].append(len(modified['uctf']['samples']))
				modified['uctf']['samples'].append(sample)

	return modified

def big_samples(music):
	"""
	Experimental: flatten all uctf channels to one big sample, to see if it improves compression
	Depends: to_uncompressed_format
	"""
	# Create flat samples, one per channel concatening all samples used by this channel
	new_samples = []
	new_chan_index = {} # key: channel index, value: new list of samples index
	for chan_idx in range(len(music['uctf']['channels'])):
		original_channel_samples = music['uctf']['channels'][chan_idx]

		new_channel_sample = {
			'type': None,
			'lines': []
		}
		for original_sample_idx in original_channel_samples:
			original_channel_sample = music['uctf']['samples'][original_sample_idx]
			ensure(new_channel_sample['type'] is None or original_channel_sample['type'] == new_channel_sample['type'])
			new_channel_sample['type'] = original_channel_sample['type']
			new_channel_sample['lines'] += original_channel_sample['lines']

		if len(new_channel_sample['lines']) > 0:
			new_chan_index[chan_idx] = [len(new_samples)]
			new_samples.append(new_channel_sample)

	# Replace music samples by the flat samples
	music['uctf']['samples'] = new_samples

	# Reconstruct channels' sample index
	for chan_idx in range(len(music['uctf']['channels'])):
		music['uctf']['channels'][chan_idx] = new_chan_index.get(chan_idx, [])

	return music

def extend_empty_rows(music):
	"""
	Modify the uctf to replace all "empty_row" by their extended form

	Depends: to_uncompressed_format
	"""
	for sample in music['uctf']['samples']:
		for line_idx in range(len(sample['lines'])):
			if sample['lines'][line_idx] == 'empty_row':
				fields = uctf_fields_by_type[sample['type']]
				sample['lines'][line_idx] = {x: None for x in fields}

	return music

def adapt_tempo(music):
	"""
	Duplicate or remove lines to convert to a supported tempo

	Depends: to_uncompressed_format, extend_empty_rows
	NotAfter: remove_duplicates, aggregate_lines
	"""

	#
	# Constants and helpers
	#

	supported_tempos = [125, 150]

	def uctf_find_value_at_sample_begin(field, music, sample_idx):
		assert field != 'frequency_adjust', 'frequency_adjust does not behave like other fields'

		# Check that sample is used in only once in one channel (else start values may differ)
		chan_idx = None
		for current_chan_idx in range(len(music['uctf']['channels'])):
			occurences = music['uctf']['channels'][current_chan_idx].count(sample_idx)
			if occurences == 1 and chan_idx is None:
				chan_idx = current_chan_idx
			elif occurences > 0 and chan_idx is not None:
				return (None, 'unable to find value of {} at the begining of sample {}, used by multiple channels'.format(field, sample_idx))
			elif occurences > 1:
				return (None, 'unable to find value of {} at the begining of sample {}, used by multiple channels'.format(field, sample_idx))

		if chan_idx is None:
			notice('unused sample')
			return (None, None)

		# List previous samples
		chan_samples_list = music['uctf']['channels'][chan_idx]
		sample_position = chan_samples_list.index(sample_idx)
		previous_samples = chan_samples_list[:sample_position]
		previous_samples.reverse()

		# Search for value in previous samples
		for reference_sample_idx in previous_samples:
			reference_sample = music['uctf']['samples'][reference_sample_idx]
			for line_idx in range(len(reference_sample['lines'])-1, -1, -1):
				if reference_sample['lines'][line_idx][field] is not None:
					return (reference_sample['lines'][line_idx][field], None)

		# Nothing found
		return (None, None)

	#
	# Implementation
	#

	# Do nothing on multi-track files, please read the TODO
	if len(music['tracks']) > 1:
		warn('unsupported multi-tracks file: no tempo adjust (and certainly a lot of other troubles)') #TODO change the "uctf" field to be an array of uctf objects instead of a single object
		return music

	# Adjust tempo of each track
	for track_idx in range(len(music['tracks'])):
		original_tempo = music['tracks'][track_idx]['tempo']

		# Nothing to do if already at a supported tempo
		if original_tempo in supported_tempos:
			continue

		# Check that all channels are composed of equivalent samples (same number, same duration)
		chans_length = None
		chans_samples_durations = None
		check_ok = True
		for chan_idx in range(len(music['uctf']['channels'])):
			# Empty chans are allowed, and cause not trouble
			current_chan_length = len(music['uctf']['channels'][chan_idx])
			if current_chan_length == 0:
				continue

			# Check than chan has the same number of samples than others
			if chans_length is not None and current_chan_length != chans_length:
				warn('channels of track #{} does not have the same number of samples: no tempo adjust'.format(track_idx))
				check_ok = False
				break
			chans_length = current_chan_length

			# Check that chan's sample are the same duration as others
			current_samples_duration = []
			for sample_idx in music['uctf']['channels'][chan_idx]:
				current_samples_duration.append(len(music['uctf']['samples'][sample_idx]))
			if chans_samples_durations is not None and current_samples_duration != chans_samples_durations:
				warn('channels of track #{} have samples of different durations: no tempo adjust'.format(track_idx))
				check_ok = False
				break

		if not check_ok:
			continue

		# Select the closest supported tempo
		target_tempo = sorted(supported_tempos, key=lambda x: abs(original_tempo - x))[0]
		notice('converting tempo from {} to {}'.format(original_tempo, target_tempo))

		# Determine changes to apply
		operation = None
		rythm = None
		if target_tempo > original_tempo:
			# Add a lines to slow down music played too fast by the engine
			operation = 'add_lines'
			tempo_diff = target_tempo - original_tempo
			rythm = target_tempo / tempo_diff
		else:
			# Remove a lines to speed up music played too slowly by the engine
			operation = 'remove_line'
			tempo_diff = original_tempo - target_tempo
			rythm = original_tempo / tempo_diff

		# Change samples to adapt to new tempo
		for sample_idx in range(len(music['uctf']['samples'])):
			sample = music['uctf']['samples'][sample_idx]

			new_lines = []
			last_operation_count = 0
			for original_line_idx in range(len(sample['lines'])):
				original_line = sample['lines'][original_line_idx]
				assert original_line != 'empty_row', 'adapt_tempo does not support "empty_row", you should run extend_empty_rows() filter'
				ensure(isinstance(original_line, dict), 'unsupported uctf line type')

				# Check if the speedup/slowdown operation must be done on this line
				operation_time = False
				operation_count = (original_line_idx + 1) // rythm
				if operation_count != last_operation_count:
					last_operation_count = operation_count
					operation_time = True

				# Apply changes
				if operation == 'add_lines':
					ensure(False, 'TODO tempo slowdown')
				else: #operation == 'remove_lines'
					# Remove the line
					if operation_time:
						# Easy access to next line
						next_line_idx = original_line_idx + 1
						next_line = None
						if next_line_idx < len(sample['lines']):
							next_line = sample['lines'][next_line_idx]
						else:
							next_line_idx = None

						# Merge current line in the next one
						if next_line_idx is not None:
							for field in next_line:
								if field == 'frequency_adjust':
									# Special field, merging meaning adding both values
									current_freq_adjust = original_line['frequency_adjust'] if original_line['frequency_adjust'] is not None else 0
									next_freq_adjust = next_line['frequency_adjust'] if next_line['frequency_adjust'] is not None else 0
									merged_freq_adjust = current_freq_adjust + next_freq_adjust
									if next_line.get('note') is None and next_line.get('freq') is None:
										next_line['frequency_adjust'] = merged_freq_adjust if merged_freq_adjust != 0 else None
								else:
									#FIXME merging a note in line with frequency adjust creates a line with both (should often be simplifiable to another note)
									# Keep destination value if there is one, else place original value in destination line
									if next_line[field] is None:
										next_line[field] = original_line[field]

						# Add slide speed of current line in previous one
						if len(new_lines) > 0:
							previous_line = new_lines[-1]

							# Find slide value of previous line
							previous_line_slide = None
							error = None
							for reference_line_idx in range(len(new_lines)-1, -1, -1):
								if new_lines[reference_line_idx]['pitch_slide'] is not None:
									previous_line_slide = new_lines[reference_line_idx]['pitch_slide']
									break

							if previous_line_slide is None:
								previous_line_slide, error = uctf_find_value_at_sample_begin('pitch_slide', music, sample_idx)

							if previous_line_slide is None:
								if error is None:
									# Will behave differently than famitracker only if pitch slide was set before looping
									warn('no pitch slide for uctf sample={} line={}: assume zero'.format(
										sample_idx, original_line_idx-1
									))
									previous_line_slide = 0
								else:
									warn('unknown pitch slide for an uctf line sample={} line={}: {}'.format(
										sample_idx, original_line_idx-1,
										error
									))
									#TODO determine what to do
									#     note: we may already have modified the "music" by altering other samples
									ensure(False)

							# Find slide value of original line
							original_line_slide = original_line['pitch_slide'] if original_line['pitch_slide'] is not None else previous_line_slide

							# Adapt previous slide to compensate for the loss of original line
							adapted_slide = previous_line_slide + original_line_slide
							if adapted_slide != previous_line_slide:
								previous_line['pitch_slide'] = previous_line_slide + original_line_slide

							# Ensure slide value is reset on next line
							if next_line is not None and next_line['pitch_slide'] is None:
								next_line['pitch_slide'] = original_line_slide

						# Skip processing this line (not adding it to new lines)
						continue

				# Add line to the new list of lines
				new_lines.append(original_line)

			# Update sample with new lines
			sample['lines'] = new_lines

		# Change tempo information in header
		music['tracks'][track_idx]['tempo'] = target_tempo

	return music

def remove_duplicates(music):
	"""
	Simplify any duplicate field in UCTF by None.

	Depends: to_uncompressed_format
	NotAfter: aggregate_lines
	"""
	modified = copy.deepcopy(music)
	for sample_idx in range(len(music['uctf']['samples'])):
		music_sample = music['uctf']['samples'][sample_idx]
		modified_sample = modified['uctf']['samples'][sample_idx]

		ensure(modified_sample['type'] in uctf_fields_by_type, 'unknown UCTF sample format for {}'.format(modified_sample['type']))
		uctf_fields = uctf_fields_by_type[modified_sample['type']]

		# Recreate sample lines without duplicated entries
		last_line_values = {x: None for x in uctf_fields}
		modified_sample['lines'] = []
		for line_idx in range(len(music_sample['lines'])):
			line = copy.deepcopy(music_sample['lines'][line_idx])

			# Ignore empty rows, they have no impact
			if line == 'empty_row':
				modified_sample['lines'].append(line)
				continue

			# Remove fields from current row that actually did not change
			assert isinstance(line, dict), 'unsuported sample line value'
			assert list(line.keys()) == uctf_fields, 'unsuported uctf line format (if you added a supported effect, remove_duplicates() certainly must be updated)'

			def field_changed(field):
				return line[field] is not None and line[field] != last_line_values[field]

			is_empty = True
			for field in uctf_fields:
				if field_changed(field):
					last_line_values[field] = line[field]
					is_empty = False
				else:
					if field == 'note' and line['note'] is not None and last_line_values['pitch_slide'] != 0 and last_line_values['pitch_slide'] is not None:
						# Do not remove a duplicate note if there was a pitch slide
						# Note: "is not None" part of the condition means "if pitch slide was never set in this sample" which
						#       is an aggressive optimization (previous sample could have set a pitch slide)
						#       TODO should be checked against previous samples in the channel, like for previous_line_slide in adapt_tempo
						is_empty = False
					elif field == 'freq' and line['freq'] is not None and last_line_values['pitch_slide'] != 0 and last_line_values['pitch_slide'] is not None:
						# Same as with "note" but for noise channel
						is_empty = False
					elif field == 'frequency_adjust':
						# Do not remove frequency_adjust, it only impacts the line on which it is. Last value is no more impacting current line.
						if line[field] is not None:
							is_empty = False
					else:
						line[field] = None

			if is_empty:
				line = 'empty_row'

			# Record modified version of the line
			modified_sample['lines'].append(line)
	return modified

def aggregate_lines(music):
	"""
	Replace empty lines by duration in non-empty ones

	Depends: to_uncompressed_format
	"""
	modified = copy.deepcopy(music)
	for sample_idx in range(len(music['uctf']['samples'])):
		music_sample = music['uctf']['samples'][sample_idx]
		modified_sample = modified['uctf']['samples'][sample_idx]

		ensure(modified_sample['type'] in uctf_fields_by_type, 'unknown UCTF sample format for {}'.format(modified_sample['type']))
		uctf_fields = uctf_fields_by_type[modified_sample['type']]

		# Recreate sample lines with duration property in useful lines instead of series of empty lines
		modified_sample['lines'] = []
		for line_idx in range(len(music_sample['lines'])):
			line = music_sample['lines'][line_idx]

			# Special case for the first line, if empty create a full-none line, avoiding ignoring it
			if line == 'empty_row' and line_idx == 0:
				line = {x: None for x in uctf_fields}

			# Add duration field to non-empty lines to merge following empty lines in it
			if line != 'empty_row':
				# Copy original line
				assert isinstance(line, dict), 'unsuported sample line value'
				modified_sample['lines'].append(copy.deepcopy(line))

				# Count duration
				duration = 1
				for next_line_idx in range(line_idx+1, len(music_sample['lines'])):
					if music_sample['lines'][next_line_idx] == 'empty_row':
						duration += 1
					else:
						break
				modified_sample['lines'][-1]['duration'] = duration
	return modified

def compute_note_length(music):
	"""
	Add optimal default note length for all samples

	Depends: to_uncompressed_format
	"""
	#TODO for now simply use 5, real value should certainly be gcd(num frames between non-empty rows) (maybe ingoring rare occurence of shorter times)
	#     or simply use track's speed (except on degenerate case were a lot of FXX is used, allow to specify it)
	#     Note that is does not changes a lot of things, PLAY_NOTE opcode is rarely used (PLAY_TIMED_NOTE is less CPU intensive and the same size)
	modified = copy.deepcopy(music)
	for sample in modified['uctf']['samples']:
		sample['default_note_length'] = 5
	return modified

def to_mod_format(music):
	"""
	Convert samples to list of opcodes

	Depends: to_uncompressed_format, compute_note_length, aggregate_lines
	"""
	def add_timed_opcode(line, opcodes, note_offset = 0):
		"""
		Add playback, halt or wait opcodes to the opcodes list, to match behaviour of source line
		"""
		def offseted_get_note_table_index(note):
			result = get_note_table_index(note) + note_offset
			if result < 0:
				warn('got an offseted note below note table "{} + {}": note set to first entry'.format(note, note_offset))
				result = 0
			if result >= len(note_table_names):
				warn('got an offseted note after note table "{} + {}": note set to last entry'.format(note, note_offset))
				result = len(note_table_names) - 1
			return result

		def offseted_get_note_frequency(note):
			actual_note_index = get_note_table_index(note) + note_offset
			if actual_note_index < 0:
				warn('got an offseted note below note table "{} + {}": note set to first entry'.format(note, note_offset))
				actual_note_index = 0
			if actual_note_index >= len(note_table_names):
				warn('got an offseted note after note table "{} + {}": note set to last entry'.format(note, note_offset))
				actual_note_index = len(note_table_names) - 1
			return get_note_frequency(note_table_names[actual_note_index])

		if line['note'] is not None and line['frequency_adjust'] is not None:
			warn('got a note ({}) and frequency adjust ({}) on same line: ignoring frequency adjust'.format(
				line['note'], line['frequency_adjust']
			))

		duration = line['duration']
		if line['note'] in ['---', '===']:
			step = min(duration, 8)
			assert duration >= 1
			opcodes.append({
				'type': 'music_sample_2a03_pulse_opcode',
				'name': 'HALT',
				'parameters': [step - 1]
			})
			duration -= step
		elif line['note'] is not None:
			deflen = sample['default_note_length']
			divide_table = [deflen >> 0, deflen >> 1, deflen >> 2, deflen >> 3]
			mult_table = [deflen << 0, deflen << 1, deflen << 2, deflen << 3]

			if duration <= 16:
				opcodes.append({
					'type': 'music_sample_2a03_pulse_opcode',
					'name': 'PLAY_TIMED_NOTE',
					'parameters': [
						duration - 1,
						offseted_get_note_table_index(line['note'])
					]
				})
				duration = 0
			elif duration in divide_table:
				opcodes.append({
					'type': 'music_sample_2a03_pulse_opcode',
					'name': 'PLAY_NOTE',
					'parameters': [
						0, # divide default length
						divide_table.index(duration), # bit-shift value
						offseted_get_note_table_index(line['note'])
					]
				})
				duration = 0
			elif duration in mult_table:
				opcodes.append({
					'type': 'music_sample_2a03_pulse_opcode',
					'name': 'PLAY_NOTE',
					'parameters': [
						1, # multiply default length
						mult_table.index(duration), # bit-shift value
						offseted_get_note_table_index(line['note'])
					]
				})
				duration = 0
			else:
				step = min(duration, 255)
				opcodes.append({
					'type': 'music_sample_2a03_pulse_opcode',
					'name': 'PLAY_TIMED_FREQ',
					'parameters': [
						offseted_get_note_frequency(line['note']),
						step
					]
				})
				duration -= step
		elif line['frequency_adjust'] is not None:
			step = min(duration, 255)
			if line['frequency_adjust'] == 0:
				# This is actually not a problem, could happen if multiple logic parts played with frequency adjust
				# Warn here because:
				#  - This code is new, I want to see how it behaves
				#  - For now, only arpeggio instrument plays with frequency adjust, so it should never happen
				#  - Ease of converting the log to a "debug" instead of "warn"
				warn('frequency adjust of zero: ignore')
			elif line['frequency_adjust'] > 0:
				opcodes.append({
					'type': 'music_sample_2a03_pulse_opcode',
					'name': 'AUDIO_PULSE_FREQUENCY_ADD',
					'parameters': [
						line['frequency_adjust'],
						step
					]
				})
				duration -= step
			else: # line['frequency_adjust'] < 0
				opcodes.append({
					'type': 'music_sample_2a03_pulse_opcode',
					'name': 'AUDIO_PULSE_FREQUENCY_SUB',
					'parameters': [
						-line['frequency_adjust'],
						step
					]
				})
				duration -= step

		while duration > 0:
			if duration <= 8:
				opcodes.append({
					'type': 'music_sample_2a03_pulse_opcode',
					'name': 'WAIT',
					'parameters': [duration - 1]
				})
				duration = 0
			else:
				step = min(duration, 255)
				opcodes.append({
					'type': 'music_sample_2a03_pulse_opcode',
					'name': 'LONG_WAIT',
					'parameters': [step]
				})
				duration -= step

	def compute_2a03_pulse_mod_sample(sample):
		"""
		Convert an UCTF (with durations) 2a03 sample to a mod sample

		TODO simplify: all the "previous_state/current_state" stuff seems to be a weaker version of the work already done by remove_duplicates
		"""
		default_volume = 15
		default_duty = 0
		default_pitch_slide = 0
		current_state = {
			'volume': None,
			'duty': None,
			'pitch_slide': None,
		}
		opcodes = []
		for line in sample['lines']:
			assert isinstance(line, dict), 'bad sample line format (is there still some "empty_row"?)'
			assert 'note' in line
			assert 'frequency_adjust' in line
			assert 'volume' in line
			assert 'duty' in line
			assert 'duration' in line
			assert 'pitch_slide' in line
			dbg_original_opcodes_length = len(opcodes)

			previous_state = current_state
			current_state = {
				'volume': line['volume'] if line['volume'] is not None else current_state['volume'],
				'duty': line['duty'] if line['duty'] is not None else current_state['duty'],
				'pitch_slide': line['pitch_slide'] if line['pitch_slide'] is not None else current_state['pitch_slide'],
			}

			# Change parameter opcodes
			has_new_duty = line['duty'] is not None and line['duty'] != previous_state['duty']
			has_new_volume = line['volume'] is not None and line['volume'] != previous_state['volume']
			has_new_pitch_slide = line['pitch_slide'] is not None and line['pitch_slide'] != previous_state['pitch_slide']

			if has_new_duty:
				opcodes.append({
					'type': 'music_sample_2a03_pulse_opcode',
					'name': 'CHAN_DUTY',
					'parameters': [line['duty']]
				})

			if has_new_volume:
				opcodes.append({
					'type': 'music_sample_2a03_pulse_opcode',
					'name': 'CHAN_VOLUME_LOW' if line['volume'] < 8 else 'CHAN_VOLUME_HIGH',
					'parameters': [line['volume'] % 8]
				})

			if has_new_pitch_slide:
				opcodes.append({
					'type': 'music_sample_2a03_pulse_opcode',
					'name': 'PITCH_SLIDE',
					'parameters': [line['pitch_slide']]
				})

			# Timed opcodes (note, wait or halt)
			add_timed_opcode(line, opcodes)

			assert dbg_original_opcodes_length < len(opcodes), 'sample line did not produce any opcode'

		return {
			'type': 'music_sample_2a03_pulse',
			'opcodes': opcodes,
		}


	def compute_2a03_triangle_mod_sample(sample):
		"""
		Convert an UCTF (with durations) 2a03 sample to a mod sample
		"""
		default_pitch_slide = 0
		current_state = {
			'pitch_slide': None,
		}
		opcodes = []
		for line in sample['lines']:
			assert isinstance(line, dict), 'bad sample line format (is there still some "empty_row"?)'
			assert 'note' in line
			assert 'frequency_adjust' in line
			assert 'volume' not in line
			assert 'duty' not in line
			assert 'duration' in line
			assert 'pitch_slide' in line
			dbg_original_opcodes_length = len(opcodes)

			previous_state = current_state
			current_state = {
				'pitch_slide': line['pitch_slide'] if line['pitch_slide'] is not None else current_state['pitch_slide'],
			}

			# Change parameter opcodes
			has_new_pitch_slide = line['pitch_slide'] is not None and line['pitch_slide'] != previous_state['pitch_slide']

			if has_new_pitch_slide:
				opcodes.append({
					'type': 'music_sample_2a03_pulse_opcode',
					'name': 'PITCH_SLIDE',
					'parameters': [line['pitch_slide']]
				})

			# Timed opcodes (note, wait or halt)
			add_timed_opcode(line, opcodes, 0) #TODO simplify, we actually don't need to offset notes from famitracker

			assert dbg_original_opcodes_length < len(opcodes), 'sample line did not produce any opcode'

		return {
			'type': 'music_sample_2a03_triangle',
			'opcodes': opcodes,
		}

	def compute_2a03_noise_mod_sample(sample):
		"""
		Convert an UCTF (with durations) 2a03 sample to a mod sample
		"""
		default_pitch_slide = 0
		current_state = {
			'volume': None,
			'periodic': None,
			'pitch_slide': None,
		}
		opcodes = []
		for line in sample['lines']:
			assert isinstance(line, dict), 'bad sample line format (is there still some "empty_row"?)'
			assert 'note' not in line
			assert 'freq' in line
			assert 'frequency_adjust' in line
			assert 'volume' in line
			assert 'duty' not in line
			assert 'periodic' in line
			assert 'duration' in line
			assert 'pitch_slide' in line
			dbg_original_opcodes_length = len(opcodes)

			previous_state = current_state
			current_state = {
				'volume': line['volume'] if line['volume'] is not None else current_state['volume'],
				'periodic': line['periodic'] if line['periodic'] is not None else current_state['periodic'],
				'pitch_slide': line['pitch_slide'] if line['pitch_slide'] is not None else current_state['pitch_slide'],
			}

			# Change parameter opcodes
			has_new_volume = line['volume'] is not None and line['volume'] != previous_state['volume']
			has_new_periodic = line['periodic'] is not None and line['periodic'] != previous_state['periodic']
			has_new_pitch_slide = line['pitch_slide'] is not None and line['pitch_slide'] != previous_state['pitch_slide']

			if has_new_volume:
				value = line['volume']
				if value < 0 or value > 0xf:
					warn('serializing noise volume of "{:X}": fixing to {:X}'.format(value, value % 0x10))
					value %= 0x10
				opcodes.append({
					'type': 'music_sample_2a03_noise_opcode',
					'name': 'SET_VOLUME',
					'parameters': [value]
				})

			if has_new_periodic:
				value = line['periodic']
				if value not in [0, 1]:
					warn('serializing noise periodic value "{}": fixing to {}'.format(value, value % 2))
					value %= 2 # Confirmed to match famitracker's behavior, but should be handled before, invalid in uctf
				opcodes.append({
					'type': 'music_sample_2a03_noise_opcode',
					'name': 'SET_PERIODIC',
					'parameters': [value]
				})

			if has_new_pitch_slide:
				value = line['pitch_slide']
				if value < -15 or 15 < value:
					#FIXME may be caused by adapt_tempo filter, in this case it is not a big deal. Should be fixed in adapt_tempo to avoid warning flood.
					fixed_value = min(max(value, -15), 15) # Same behaviour as bigger values: reach end of range in one tick
					warn('serializing noise pitch slide value "{}": fixing to {}'.format(value, fixed_value))
					value = fixed_value

				if line['pitch_slide'] > 0:
					opcodes.append({
						'type': 'music_sample_2a03_noise_opcode',
						'name': 'PITCH_SLIDE_DOWN', #NOTE not a bug, positive pitch slide means pitch slide DOWN
						'parameters': [value]
					})
				else:
					opcodes.append({
						'type': 'music_sample_2a03_noise_opcode',
						'name': 'PITCH_SLIDE_UP',
						'parameters': [abs(value)]
					})

			# Timed opcodes (play, wait or halt)
			duration = line['duration']

			if line['freq'] is not None and line['frequency_adjust'] is not None:
				warn('got a noise frequency ({}) and frequency adjust ({}) on same line: ignoring frequency adjust'.format(
					line['freq'], line['frequency_adjust']
				))

			if line['freq'] in ['---', '===']:
				step = min(duration, 16)
				assert duration >= 1
				opcodes.append({
					'type': 'music_sample_2a03_noise_opcode',
					'name': 'HALT',
					'parameters': [step - 1]
				})
				duration -= step
			elif line['freq'] is not None:
				ensure(line['freq'][1:] == '-#' and line['freq'][0] in '0123456789ABCDEF', 'unknown noise note format "{}"'.format(line['freq']))
				freq = 0xf - int(line['freq'][0], 16)
				step = min(duration, 255)
				opcodes.append({
					'type': 'music_sample_2a03_noise_opcode',
					'name': 'PLAY_TIMED_FREQ',
					'parameters': [freq, step]
				})
				duration -= step
			elif line['frequency_adjust'] is not None:
				if line['frequency_adjust'] == 0:
					# This is actually not a problem, could happen if multiple logic parts played with frequency adjust
					# Warn here because:
					#  - This code is new, I want to see how it behaves
					#  - For now, only arpeggio instrument plays with frequency adjust, so it should never happen
					#  - Ease of converting the log to a "debug" instead of "warn"
					warn('frequency adjust of zero: ignore')
				else:
					warn('TODO add opcodes for frequency adjust in noise channel')

			while duration > 0:
				if duration <= 16:
					opcodes.append({
						'type': 'music_sample_2a03_noise_opcode',
						'name': 'WAIT',
						'parameters': [duration - 1]
					})
					duration = 0
				else:
					step = min(duration, 255)
					opcodes.append({
						'type': 'music_sample_2a03_noise_opcode',
						'name': 'LONG_WAIT',
						'parameters': [step]
					})
					duration -= step

			assert dbg_original_opcodes_length < len(opcodes), 'sample line did not produce any opcode'

		return {
			'type': 'music_sample_2a03_noise',
			'opcodes': opcodes,
		}

	# Convert UCTF samples to mod format samples
	sample_converters = {
		'2a03-pulse': compute_2a03_pulse_mod_sample,
		'2a03-triangle': compute_2a03_triangle_mod_sample,
		'2a03-noise': compute_2a03_noise_mod_sample,
	}
	samples_list = []
	for sample in music['uctf']['samples']:
		ensure(sample['type'] in sample_converters, 'TODO handle all sample types')
		samples_list.append(sample_converters[sample['type']](sample))

	# Return the music with added "music" field
	modified = copy.deepcopy(music)
	modified['mod'] = {
		'type': 'music',
		'channels': copy.deepcopy(music['uctf']['channels']),
		'samples': samples_list,
	}
	return modified

def optim_pulse_opcodes_to_meta(music):
	"""
	Merge comon series of opcodes to a single meta opcode when desirable

	Works for pulse and triangle samples.

	depends: to_mod_format
	"""
	for sample in music['mod']['samples']:
		# Do not optimize unhandled samples
		if sample['type'] not in ['music_sample_2a03_pulse', 'music_sample_2a03_triangle']:
			continue

		# Generate an optimized opcode list
		optimized_opcodes = []
		opcode_group = []
		for current_opcode in sample['opcodes']:
			# Add opcode to current group of parameters + timed opcode
			opcode_group.append(current_opcode)

			# When reached a timed opcode, try to optimize the group
			if mod_opcode_name(current_opcode) in timed_opcodes:
				# Extract useful information from the opcode group
				duty = None
				volume = None
				pitch_slide = None
				timed = None
				handled = True

				for opcode_from_group in opcode_group:
					if pitch_slide is None and opcode_from_group['name'] == 'PITCH_SLIDE':
						pitch_slide = opcode_from_group['parameters'][0]
					elif volume is None and opcode_from_group['name'] == 'CHAN_VOLUME_LOW':
						volume = opcode_from_group['parameters'][0]
					elif volume is None and opcode_from_group['name'] == 'CHAN_VOLUME_HIGH':
						volume = opcode_from_group['parameters'][0] + 8
					elif duty is None and opcode_from_group['name'] == 'CHAN_DUTY':
						duty = opcode_from_group['parameters'][0]
					elif timed is None and mod_opcode_name(opcode_from_group) in timed_opcodes:
						timed = opcode_from_group
					else:
						handled = False

				if duty is None and volume is None and pitch_slide is None:
					handled = False # Solo timed opcode, no point to "merge" it to a meta opcode

				# Avoid cases where meta opcode uses more bytes than originals
				meta_opcode_size = (2 +
					(1 if 'WAIT' not in timed['name'] else 0) + # Note index takes one byte, WAIT opcodes don't need it
					(1 if volume is not None or duty is not None else 0) + # Volume and duty share one byte
					(1 if pitch_slide is not None else 0)
				)

				original_group_size = 0
				for original_group_opcode in opcode_group:
					original_group_size += get_opcode_size(original_group_opcode)

				if original_group_size < meta_opcode_size:
					handled = False

				# Place an optimized version if possible
				if handled:
					duration = None
					note_idx = None

					if timed['name'] == 'PLAY_TIMED_NOTE':
						duration = timed['parameters'][0] + 1
						note_idx = timed['parameters'][1]
					elif timed['name'] == 'PLAY_NOTE':
						deflen = 5 #TODO get this info instead of hardcoding it, or let accept to PLAY_NOTE die, or refuse to optimize PLAY_NOTE to a meta
						if timed['parameters'][0] == 0:
							duration = deflen >> timed['parameters'][1]
						else:
							duration = deflen << timed['parameters'][1]
						note_idx = timed['parameters'][2]
					elif timed['name'] == 'WAIT':
						duration = timed['parameters'][0] + 1
					elif timed['name'] == 'LONG_WAIT':
						duration = timed['parameters'][0]

					if duration is None:
						handled = False
					else:
						meta_opcode = {
							'type': 'music_sample_2a03_pulse_opcode',
							'name': 'AUDIO_PULSE_META{action}{dut}{vol}{slide}'.format(
								action = '_NOTE' if note_idx is not None else '_WAIT',
								dut = '_DUT' if duty is not None else '',
								vol = '_VOL' if volume is not None else '',
								slide = '' if pitch_slide is None else '_USLIDE' if pitch_slide < 0 else '_DSLIDE'
							),
							'parameters': ([note_idx] if note_idx is not None else []) +
								[duration] +
								([duty] if duty is not None else []) +
								([volume] if volume is not None else []) +
								([pitch_slide] if pitch_slide is not None else [])
						}

						optimized_opcodes.append(meta_opcode)

				# Fallback to re-inserting the original opcodes
				if not handled:
					optimized_opcodes += opcode_group

				# Reset group
				opcode_group = []

		# Replace original list by optimized one
		sample['opcodes'] = optimized_opcodes

		#TODO
		# Sanity check: no duty or volume in triangle channels
		# Sanity check: no AUDIO_PULSE_META_NOTE (without optionals) and a duration <= 16 (PLAY_TIMED_NOTE is better)

	return music

def split_samples(music, max_patterns=None):
	"""
	Split samples to get repeated patterns in their own sample

	Note: In this function the term "pattern" is used to discuss groups of opcodes that are repeated
	multiple times in the music. Not related to Famitracker's patterns.

	Depends: to_mod_format
	"""
	# Determine pattern lengths (in number of opcodes) to search
	max_sample_size = 0
	for sample in music['mod']['samples']:
		max_sample_size = max(max_sample_size, len(sample['opcodes']))

	max_pattern_size = max_sample_size // 2
	min_pattern_size = 1

	# Handle channel types separately
	debug('split samples: min_pattern_size={} max_pattern_size={}'.format(min_pattern_size, max_pattern_size))
	for searched_sample_type in ['music_sample_2a03_pulse', 'music_sample_2a03_triangle', 'music_sample_2a03_noise']:
		debug('\tsearching sample type {}'.format(searched_sample_type))

		# Compute number of free spots in sample index (used to avoid processing too costly patterns)
		channel_idx_by_sample_type = {
			'music_sample_2a03_pulse': [0, 1],
			'music_sample_2a03_triangle': [2],
			'music_sample_2a03_noise': [3],
		}
		MAX_CHANNEL_INDEX_ENTRIES = 127
		free_index_spots = 0
		for channel_idx in channel_idx_by_sample_type[searched_sample_type]:
			free_index_spots = max(free_index_spots, MAX_CHANNEL_INDEX_ENTRIES - len(music['mod']['channels'][channel_idx]))

		# Avoid processing channels that cannot handle more sample split
		if free_index_spots == 0:
			continue

		# Scan all samples, searching for patterns
		debug('\tscanning patterns')
		patterns = {}
		for n_opcodes in range(min_pattern_size, max_pattern_size):
			if max_patterns is not None and len(patterns) >= max_patterns:
				warn('break at {} patterns found in {}, n_opcodes={}/{}'.format(len(patterns), searched_sample_type, n_opcodes, max_pattern_size))
				break
			for scaned_sample in music['mod']['samples']:
				if scaned_sample['type'] != searched_sample_type:
					continue

				last_possible_pattern_pos = len(scaned_sample['opcodes']) - n_opcodes
				for pattern_pos in range(last_possible_pattern_pos + 1):
					# Extract pattern
					pattern_opcodes = scaned_sample['opcodes'][pattern_pos:pattern_pos+n_opcodes]
					assert len(pattern_opcodes) == n_opcodes

					# Reject patterns not ending with a timed opcode
					#  Technically not necessary, but more natural and avoid some of the flood
					#  May be improved by only getting full opcode groups (a timed and all parameters since the last timed)
					if not is_timed_opcode(pattern_opcodes[-1]):
						continue

					# Increment pattern's count
					key = tuple(((x['name'], tuple(x['parameters'])) for x in pattern_opcodes))
					if key in patterns.keys():
						patterns[key]['count'] += 1
					else:
						patterns[key] = {
							'opcodes': pattern_opcodes,
							'count': 1,
							'n_edge': 0, # Number of times the pattern is at the very begining or very end of the sample
						}
					if pattern_pos == 0 or pattern_pos == last_possible_pattern_pos:
						patterns[key]['n_edge'] += 1

		# Get the patterns ordered by the number of bytes they save
		debug('\tcount bytes saved per pattern')
		pattern_priority_option = 'bytes_per_index'
		flat_patterns = [patterns[k] for k in patterns]
		for pattern in flat_patterns:
			pattern_size_in_bytes = 0
			for opcode in pattern['opcodes']:
				pattern_size_in_bytes += get_opcode_size(opcode)

			# Number of bytes saved
			#TODO use "n_edge" to reduce error margin precision
			bytes_saved = pattern_size_in_bytes * (pattern['count'] - 1) # Bytes saved by storing the pattern in a sample instead of repeating it
			bytes_saved -= 2 + pattern['count'] * (4 + 2) # Bytes wasted by referencing more samples in the track (worst case: 2 for pattern's SAMPLE_END + per-use<4 for new samples references in track + 2 for new SAMPLE_END in splitted sample>)
			pattern['bytes_saved'] = bytes_saved

			# Number of extra entries in the track's sample list
			#  Note: It is an approximation, notably over-valued if the pattern is repeated multiples times at the begining of a sample.
			#        Never undervalued.
			pattern['extra_index'] = pattern['n_edge'] + 2 * (pattern['count'] - pattern['n_edge'])

		if pattern_priority_option == 'bytes':
			flat_patterns.sort(key=lambda x: x['bytes_saved'], reverse=True)
		elif pattern_priority_option == 'bytes_per_index':
			flat_patterns.sort(key=lambda x: (x['bytes_saved'] / x['extra_index'], x['bytes_saved']), reverse=True)
		else:
			assert False, 'unknow pattern priority option "{}"'.format(pattern_priority_option)

		# Try to extract each pattern until one can be extracted without breaking the limites of samples in any track
		debug('\textract best pattern (out of {})'.format(len(flat_patterns)))
		for best_pattern in flat_patterns:
			debug('\t\tCheck pattern (-bytes={} +entries={})'.format(best_pattern['bytes_saved'], best_pattern['extra_index']))

			# Determine if it is worth extracting the pattern to its own sample
			if best_pattern['bytes_saved'] <= 0:
				break # logically could be "continue", but it is not worth checking next patterns as they are ordered by "byte_saved"

			# Determine if sample list can support the extra charge
			if best_pattern['extra_index'] > free_index_spots:
				continue

			# Get a modifiable mod
			debug('\t\tcopy mod')
			mod = copy.deepcopy(music['mod'])

			# Add a sample for the pattern
			debug('\t\tadd new sample')
			pattern_sample_index = len(mod['samples'])
			mod['samples'].append({
				'type': searched_sample_type,
				'opcodes': best_pattern['opcodes']
			})

			# Split samples containing this pattern
			debug('\t\tsplit samples')
			sample_index_update = {} # key: original sample index - value: new sequence of sample indexes
			for original_sample_index in range(len(mod['samples'])):
				# Do not process samples of other types
				original_sample = mod['samples'][original_sample_index]
				if original_sample['type'] != searched_sample_type:
					continue

				# Scan sample for pattern presence
				new_sample_indexes = []
				last_split_point = 0
				current_opcode_index = 0
				while current_opcode_index < len(original_sample['opcodes']):
					if original_sample['opcodes'][current_opcode_index:current_opcode_index+len(best_pattern['opcodes'])] == best_pattern['opcodes']:
						# Cut the sample in two: before the pattern and the pattern itself
						if current_opcode_index != 0:
							new_sample_indexes.append(len(mod['samples']))
							mod['samples'].append({
								'type': searched_sample_type,
								'opcodes': original_sample['opcodes'][last_split_point:current_opcode_index]
							})

						new_sample_indexes.append(pattern_sample_index)

						# Update position in original sample
						current_opcode_index += len(best_pattern['opcodes'])
						last_split_point = current_opcode_index
					else:
						current_opcode_index += 1

				if last_split_point != 0 and last_split_point < len(original_sample['opcodes']):
					new_sample_indexes.append(len(mod['samples']))
					mod['samples'].append({
						'type': searched_sample_type,
						'opcodes': original_sample['opcodes'][last_split_point:]
					})

				# Update sample index mapping
				if new_sample_indexes != []:
					sample_index_update[original_sample_index] = new_sample_indexes

			# Modify channels to reference splitted samples
			debug('\t\tmodify references')
			overflow = False
			for chan_idx in range(len(mod['channels'])):
				new_indexes = []
				for original_index in mod['channels'][chan_idx]:
					if original_index not in sample_index_update:
						new_indexes.append(original_index)
					else:
						new_indexes.extend(sample_index_update[original_index])
				if len(new_indexes) > MAX_CHANNEL_INDEX_ENTRIES:
					overflow = True
				mod['channels'][chan_idx] = new_indexes

			# Apply changes if it does not overflow maximum sample count
			debug('\t\tapply changes')
			if not overflow:
				music['mod'] = mod
				break

	return music

def reuse_samples(music):
	"""
	Remove references to duplicate samples in tracks

	Depends: to_mod_format
	"""
	# Get a list of clones
	track_update_table = {}
	for reference_sample_idx in range(len(music['mod']['samples'])):
		reference_sample = music['mod']['samples'][reference_sample_idx]
		for scaned_sample_idx in range(reference_sample_idx + 1, len(music['mod']['samples'])):
			scaned_sample = music['mod']['samples'][scaned_sample_idx]
			if scaned_sample_idx not in track_update_table and scaned_sample == reference_sample:
				track_update_table[scaned_sample_idx] = reference_sample_idx

	# Update samples references in tracks
	for chan in music['mod']['channels']:
		for sample_num in range(len(chan)):
			original_idx = chan[sample_num]
			chan[sample_num] = track_update_table.get(original_idx, original_idx)

	return music

def remove_unused_samples(music):
	"""
	Remove samples that are never used

	Depends: to_mod_format
	"""
	# Get a list of samples actually referenced (each entry is unique)
	referenced_samples = []
	for chan in music['mod']['channels']:
		for sample_idx in chan:
			if sample_idx not in referenced_samples:
				referenced_samples.append(sample_idx)

	# Remove samples not in the list
	for sample_idx in range(len(music['mod']['samples']) - 1, -1, -1):
		if sample_idx not in referenced_samples:
			# Actually remove from the samples list
			del music['mod']['samples'][sample_idx]

			# Update references to samples with a higher idx
			for chan in music['mod']['channels']:
				for chan_sample_num in range(len(chan)):
					assert chan[chan_sample_num] != sample_idx, 'found use of an unused sample'
					if chan[chan_sample_num] > sample_idx:
						chan[chan_sample_num] -= 1

			# Note: no need to update referenced_samples as we iterate samples
			#       in reverse we don't care about it referencing bad higher indexes
			pass

	return music

def samples_to_source(music):
	"""
	Convert samples to list of opcodes

	Depends: to_mod_format
	"""
	music_name = re.sub('[^a-z0-9_]', '', music['tracks'][0]['name'].lower().replace(' ', '_')).strip('_')
	if music_name == '':
		music_name = 'title'
	music_name_low = music_name.lower()
	music_name_up = music_name.upper()
	track_names = ['pulse1', 'pulse2', 'triangle', 'noise']

	# Banking information
	asm_header = 'music_{music_name_low}_bank = CURRENT_BANK_NUMBER\n'.format(**locals())

	# Music header
	music_header = 'music_{music_name_low}_info:\n'.format(**locals())
	for track_name in track_names:
		music_header += '.word music_{music_name_low}_track_{track_name}\n'.format(**locals())

	original_tempo = music['tracks'][0]['tempo']
	for original_track_idx in range(len(music['tracks'])):
		if music['tracks'][original_track_idx]['tempo'] != original_tempo:
			warn('unhandled various tempo between tracks, using first one ({})'.format(original_tempo))

	tempo = 0
	if original_tempo == 150:
		tempo = 0
	elif original_tempo == 125:
		tempo = 1
	else:
		warn('unknown tempo {}, defaulting to NTSC (150)'.format(original_tempo))
	music_header += '.byt {}\n'.format(tempo)

	# Tracks
	tracks_source = ''
	for track_idx in range(len(track_names)):
		track_name = track_names[track_idx]
		tracks_source += 'music_{music_name_low}_track_{track_name}:\n'.format(**locals())
		for sample_num in music['mod']['channels'][track_idx]:
			tracks_source += '.word music_{music_name_low}_sample_{sample_num}\n'.format(**locals())
		tracks_source += 'MUSIC_END\n\n'

	# Samples
	opcode_prefix = {
		'music_sample_2a03_pulse': '',
		'music_sample_2a03_triangle': '',
		'music_sample_2a03_noise': 'AUDIO_NOISE_',
	}
	sample_num = 0
	samples_source = ''
	for sample in music['mod']['samples']:
		if samples_source != '':
			samples_source += '\n'
		samples_source += 'music_{music_name_low}_sample_{sample_num}:\n.(\n'.format(**locals())
		for opcode in sample['opcodes']:
			samples_source += '\t{}{}({})\n'.format(opcode_prefix[sample['type']], opcode['name'], ','.join([str(x) for x in opcode['parameters']]))
		samples_source += '\tSAMPLE_END\n.)\n'

		sample_num += 1

	modified = copy.deepcopy(music)
	modified['src'] = {
		'type': 'samples_source',
		'value': asm_header + '\n' + music_header + '\n' + tracks_source + '\n' +samples_source,
	}
	return modified

def compute_stats(music):
	"""
	Compute stats on generated data

	Note: it should certainly not be a filter, waiting a better idea let's be ugly and implement it like that

	Depends: Actually, it may vary, depending on useful stats
	"""
	stats = {
		'total_size': 0,
		'size_per_opcode': {},
		'play_note_durations': {},
		'play_freq_durations': {},
		'long_wait_durations': {},
	}

	# Special case SAMPLE_END is implicit, once per sample
	stats['size_per_opcode']['SAMPLE_END'] = opcode_size['SAMPLE_END'] * len(music['mod']['samples'])

	# Count opcodes cumulated size
	for sample in music['mod']['samples']:
		for opcode in sample['opcodes']:
			name = mod_opcode_name(opcode)
			size = opcode_size[name]
			stats['size_per_opcode'][name] = stats['size_per_opcode'].get(name, 0) + size

	# Compute total size
	for name in stats['size_per_opcode']:
		stats['total_size'] += stats['size_per_opcode'][name]

	# Get info on which durations are used
	for sample in music['mod']['samples']:
		for opcode in sample['opcodes']:
			duration = None
			kind = None
			name = mod_opcode_name(opcode)
			if name == '2a03_pulse.PLAY_NOTE':
				kind = 'play_note_durations'
				duration = '{}-{}'.format(opcode['parameters'][0], opcode['parameters'][1])
			elif name == '2a03_pulse.PLAY_TIMED_FREQ':
				kind = 'play_freq_durations'
				duration = str(opcode['parameters'][1])
			elif name == '2a03_pulse.LONG_WAIT':
				kind = 'long_wait_durations'
				duration = str(opcode['parameters'][0])

			if kind is not None:
				assert isinstance(duration, str)
				stats[kind][duration] = stats[kind].get(duration, 0) + 1

	# Get stats about opcode groups
	opcode_groups = {}
	for sample in music['mod']['samples']:
		group_name = ''
		group_size = 0
		for opcode in sample['opcodes']:
			opcode_name = mod_opcode_name(opcode)
			group_name = '{}{}{}'.format(group_name, '+' if group_name != '' else '', opcode_name)
			group_size += opcode_size[opcode_name]

			if opcode_name in timed_opcodes:
				if group_name not in opcode_groups:
					opcode_groups[group_name] = {'count':0,'size':0}
				current = opcode_groups.get(group_name, {'count':0,'size':0})
				opcode_groups[group_name] = {
					'count': current['count'] + 1,
					'size': current['size'] + group_size,
				}

				group_name = ''
				group_size = 0

	opcode_groups_flat = []
	for group_name in opcode_groups:
		flat_group = {
			'opcodes': group_name,
			'count': opcode_groups[group_name]['count'],
			'size': opcode_groups[group_name]['size']
		}
		opcode_groups_flat.append(flat_group)
	opcode_groups_flat.sort(key=lambda x: x['size'], reverse=True)

	stats['opcode_groups'] = opcode_groups_flat

	# Return the music with a "stats" section
	modified = copy.deepcopy(music)
	modified['stats'] = stats
	return modified

if __name__ == "__main__":
    import doctest
    doctest.testmod()

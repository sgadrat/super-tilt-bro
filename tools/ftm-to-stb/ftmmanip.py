import copy
import json
import sys

#
# Error handling functions
#

def warn(msg):
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
	'2a03-pulse': ['note', 'volume', 'duty', 'pitch_slide'],
	'2a03-triangle': ['note', 'pitch_slide'],
	'2a03-noise': ['freq', 'volume', 'periodic', 'pitch_slide'],
}

timed_opcodes = [
	'2a03_pulse.PLAY_TIMED_FREQ',
	'2a03_pulse.PLAY_NOTE',
	'2a03_pulse.PLAY_TIMED_NOTE',
	'2a03_pulse.WAIT',
	'2a03_pulse.LONG_WAIT',
	'2a03_pulse.HALT',
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

def get_note_frequency(note):
	"""
	Return the frequency of a note designated by its name
	"""
	return note_table_freqs[get_note_table_index(note)]

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

def place_pitch_effect(chan_row, effect, replace, warn_on_stop=False, msg=None):
	"""
	Place a pitch effect in a row, taking care of existing conflicting effects

	If there is a conflicting pitch effect: it is replaced by the new one if `replace` is set, else the new one is not placed.

	msg will be output as a warning if there is a conflicting effect which is not equivalent to the new one.
	"""
	pitch_effect_idx = None
	for current_effect_idx in range(len(chan_row['effects'])):
		current_effect = chan_row['effects'][current_effect_idx]
		if current_effect[0] in pitch_effects:
			pitch_effect_idx = current_effect_idx
	pitch_effect = None if pitch_effect_idx is None else chan_row['effects'][pitch_effect_idx]

	if msg is not None:
		if pitch_effect_idx is not None and pitch_effect != effect:
			if is_pitch_slide_activation_effect(effect) or is_pitch_slide_activation_effect(pitch_effect):
				if warn_on_stop or is_pitch_slide_activation_effect(pitch_effect):
					warn(msg)

	if pitch_effect_idx is None:
		chan_row['effects'].append(effect)
	elif replace:
		chan_row['effects'][pitch_effect_idx] = effect

def get_pitch_effects(chan_row):
	res = []
	for current_effect_idx in range(len(chan_row['effects'])):
		current_effect = chan_row['effects'][current_effect_idx]
		if current_effect[0] in pitch_effects:
			res.append(current_effect_idx)
	return res

def get_chan_type(music, chan_idx):
	"""
	Return the type of a channel
	"""
	#TODO handle other cases than VRC6 (checking extensions in music)
	return ['2a03-pulse', '2a03-pulse', '2a03-triangle', '2a03-noise', '2a03-pcm', 'vrc6-pulse', 'vrc6-pulse', 'vrc6-saw'][chan_idx]

def get_previous_note(music, track_idx, pattern_idx, chan_idx, row_idx):
	"""
	Return the previous known note and if it is reliable to asume that it is still being played

	TODO actually return a frequence and compute it if there is some pitch effects along the way
	"""
	original_note = None
	has_pitch_fuckery = False
	def scanner(current_pattern_idx, current_row_idx):
		nonlocal has_pitch_fuckery, original_note
		current_row = music['tracks'][track_idx]['patterns'][current_pattern_idx]['rows'][current_row_idx]['channels'][chan_idx]

		for current_effect in current_row['effects']:
			if is_pitch_slide_activation_effect(current_effect):
				has_pitch_fuckery = True

		if current_row['note'] not in ['...', '---', '===']:
			original_note = current_row['note']
			return False
	scan_previous_chan_rows(scanner, music, track_idx, pattern_idx, chan_idx, row_idx-1)

	return {'note': original_note, 'reliable': not has_pitch_fuckery}

def scan_previous_chan_rows(callback, music, track_idx, pattern_idx, chan_idx, start_row_idx):
	"""
	Invoke callback on all previous rows for the channel, ignoring pattern boundary.

	Stops after invoking the very row line of the track or if callback returns False

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

def unroll_f_effect(music):
	"""
	Remove FXX effect, place empty lines to compensate

	Depends: get_num_channels
	"""
	# Copy the music without its patterns
	modified = copy.deepcopy(music)
	for track in modified['tracks']:
		track['patterns'] = []

	# Rewrite patterns with FXX effects unrolled
	for track_idx in range(len(music['tracks'])):
		for original_pattern in music['tracks'][track_idx]['patterns']:
			modified['tracks'][track_idx]['patterns'].append({'rows': []})
			for original_row in original_pattern['rows']:
				# Copy the row without FXX effect, noting the number of dummy rows to add
				modified_row = copy.deepcopy(original_row)
				repeats = 0
				for channel in modified_row['channels']:
					for i in range(len(channel['effects'])):
						if channel['effects'][i][0] == 'F':
							repeats = int(channel['effects'][i][1:], 16) - 1
							# F00 case:
							#  It makes no sense. Maybe infinite beats per minute.
							#  Famitracker wiki state that F00 is valid, without detail on what it does.
							#  Famitracker chm states that it is invalid.
							#  It seems to be equivalent to F01, until a proof is given, let's just crash.
							ensure(repeats >= 0, 'unhandled effect F00')
							channel['effects'][i] = '...'

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
				for i in range(repeats):
					modified['tracks'][track_idx]['patterns'][-1]['rows'].append(copy.deepcopy(dummy_row))

	# Sanity checks and return
	assert len(modified['tracks']) == len(music['tracks']), 'number of tracks differs between modified and original (modified:{}, original:{})'.format(len(modified['tracks']), len(music['tracks']))
	for track_id in range(len(music['tracks'])):
		assert len(modified['tracks'][track_idx]['patterns']) == len(music['tracks'][track_idx]['patterns'])
		for pattern_idx in range(len(music['tracks'][track_idx]['patterns'])):
			assert len(modified['tracks'][track_idx]['patterns'][pattern_idx]) >= len(music['tracks'][track_idx]['patterns'][pattern_idx]), 'pattern {:02x}-{:02x} is shorted than original'.format(track_idx, pattern_idx)

	return modified

def cut_at_b_effect(music):
	"""
	Cut each track at the first Bxx effect

	Note: only B00 is handled, anything else is interpreted as B00
	"""
	def bxx_scanner(current_pattern_idx, current_row_idx):
		nonlocal cut_position
		current_row = music['tracks'][track_idx]['patterns'][current_pattern_idx]['rows'][current_row_idx]

		# Check for presence of a Bxx effect anywhere in the row
		bxx_location = None
		for chan_idx in range(len(current_row['channels'])):
			for effect_idx in range(len(current_row['channels'][chan_idx]['effects'])):
				effect = current_row['channels'][chan_idx]['effects'][effect_idx]
				if effect[0] == 'B':
					if effect[1:] != '00':
						warn('Bxx with "xx != 00" in {}: interpreted as B00'.format(
							row_identifier(track_idx, current_pattern_idx, current_row_idx, chan_idx)
						))
					if bxx_location is not None:
						warn('multiple Bxx in {}: some are ignored'.format(
							row_identifier(track_idx, current_pattern_idx, current_row_idx, chan_idx)
						))
						current_row['channels'][bxx_location['chan']]['effects'][bxx_location['effect']] = '...'
					bxx_location = {'chan':chan_idx, 'effect':effect_idx}

		if bxx_location is not None:
			cut_position = {'pattern': current_pattern_idx, 'row': current_row_idx}
			return False

	# Search for a cut position in each track
	for track_idx in range(len(music['tracks'])):
		cut_position = None
		scan_next_chan_rows(bxx_scanner, music, track_idx, 0, 0)

		if cut_position is not None:
			track = music['tracks'][track_idx]
			pattern = track['patterns'][cut_position['pattern']]

			# Remove rows at the end of the pattern
			pattern['rows'] = pattern['rows'][:cut_position['row']] #NOTE this will cut the row with Bxx effect (hope nobody puts anything else on the last row)

			# Remove patterns after the one containing Bxx
			track['patterns'] = track['patterns'][:cut_position['pattern']+1]

	return music

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
						dest_row_idx = len(pattern['rows'] - 1)
					dest_chan_row = get_row(modified, track=track_idx, pattern=pattern_idx, chan=chan_idx, row=dest_row_idx)

					if dest_chan_row['note'] != '...':
						warn('SXX effect conflict with a note in {} => {}: note erased'.format(
							row_identifier(track_idx, pattern_idx, row_idx, chan_idx),
							row_identifier(track_idx, pattern_idx, dest_row_idx, chan_idx)
						))
					dest_chan_row['note'] = '---'
					chan_row['effects'][s_effect_idx] = '...'

	return modified

def remove_instruments(music):
	"""
	Apply instruments effects to the timeline

	Depends: get_num_channels
	"""
	def get_sequence(music, chan_type, seq_type, seq_idx):
		if seq_idx == -1:
			return None
		return music['macros'][chan_type][seq_type][seq_idx]
		
	modified = copy.deepcopy(music)

	for track_idx in range(len(modified['tracks'])):
		track = modified['tracks'][track_idx]
		for pattern_idx in range(len(track['patterns'])):
			pattern = track['patterns'][pattern_idx]
			for chan_idx in range(modified['params']['n_chan']):
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
						ensure(len(seq_vol['sequence']) > 0, 'instrument {:X} has an empty volume sequence')

						if get_chan_type(modified, chan_idx) == '2a03-triangle':
							# Until the next note, the channel is mute if the volume is zero
							sequence_step = 0
							last_envelope_value = None
							def scanner_vol_tri(current_pattern_idx, current_row_idx):
								nonlocal last_envelope_value, sequence_step
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
							scan_next_chan_rows(scanner_vol_tri, modified, track_idx, pattern_idx, row_idx )

							# Mark sequence as handled for this row
							seq_vol = None
						elif get_chan_type(modified, chan_idx) in ['2a03-pulse', '2a03-noise']:
							if seq_vol['loop'] != -1:
								warn('instrument {:X} has a looping volume enveloppe: TODO handle loops')

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
								nonlocal ref_volume, sequence_step, stop_row
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

								sequence_step = min(sequence_step + 1, len(seq_vol['sequence']) - 1) #TODO handle looping
							scan_next_chan_rows(scanner_apply_volume, modified, track_idx, pattern_idx, row_idx)

							# On the next note, explicitely reset reference volume
							if stop_row is not None and stop_row['volume'] == '.':
								stop_row['volume'] = '{:X}'.format(ref_volume)

							# Mark volume sequence as handled for this row
							seq_vol = None

					if seq_arp is not None:
						ensure(len(seq_arp['sequence']) > 0, 'instrument {:X} has an empty arpeggio sequence')

						# Find reference note
						ref_note_idx = get_note_table_index(ref_note)

						# Until the next note, the note is adjusted by the enveloppe
						sequence_step = 0
						def scanner_arp(current_pattern_idx, current_row_idx):
							nonlocal sequence_step
							current_chan_row = track['patterns'][current_pattern_idx]['rows'][current_row_idx]['channels'][chan_idx]

							# Stop on any row with a note
							if current_chan_row['note'] != '...' and (current_pattern_idx, current_row_idx) != (pattern_idx, row_idx):
								return False

							# Compute value as impacted by the sequence
							enveloppe_note_idx = ref_note_idx + seq_arp['sequence'][sequence_step]
							if enveloppe_note_idx >= len(note_table_names):
								warn('arpegio enveloppe goes over the notes table in {}: last note of the table used'.format(
									row_identifier(track_idx, pattern_idx, row_idx, chan_idx)
								))
								enveloppe_note_idx = len(note_table_names) - 1
							elif enveloppe_note_idx < 0:
								warn('arpegio enveloppe goes under the notes table in {}: first note of the table used'.format(
									row_identifier(track_idx, pattern_idx, row_idx, chan_idx)
								))
								enveloppe_note_idx = 0

							# Place computed value
							current_chan_row['note'] = note_table_names[enveloppe_note_idx]

							# Advance sequence
							if seq_arp['loop'] == -1:
								sequence_step = min(sequence_step + 1, len(seq_arp['sequence']) - 1)
							else:
								sequence_step += 1
								if sequence_step >= len(seq_arp['sequence']):
									sequence_step = seq_arp['loop']
						scan_next_chan_rows(scanner_arp, modified, track_idx, pattern_idx, row_idx )

						# Mark sequence as handled for this row
						seq_arp = None

					if seq_dut is not None:
						ensure(len(seq_dut['sequence']) > 0)
						if seq_dut['loop'] != -1:
							warn('instrument {:X} has a looping duty enveloppe: TODO handle loops')

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
							warn('unable to find reference duty for instrument enveloppe in {}: ignore duty enveloppe'.format(
								row_identifier(track_idx, pattern_idx, row_idx, chan_idx)
							))
						else:
							# Until the next note, the duty is adjusted by the enveloppe
							sequence_step = 0
							current_row_idx = row_idx
							while current_row_idx < len(pattern['rows']) and (
								pattern['rows'][current_row_idx]['channels'][chan_idx]['note'] == '...' or
								current_row_idx == row_idx
							):
								current_chan_row = pattern['rows'][current_row_idx]['channels'][chan_idx]

								duty_effect_idx = None
								for current_effect_idx in range(len(current_chan_row['effects'])):
									current_effect = current_chan_row['effects'][current_effect_idx]
									if current_effect[0] == 'V':
										ref_duty = int(current_effect[1:], 16)
										duty_effect_idx = current_effect_idx

								enveloppe_duty = seq_dut['sequence'][sequence_step]
								if duty_effect_idx is not None:
									current_chan_row['effects'][duty_effect_idx] = 'V{:02X}'.format(enveloppe_duty)
								else:
									current_chan_row['effects'].append('V{:02X}'.format(enveloppe_duty))

								sequence_step = min(sequence_step + 1, len(seq_dut['sequence']) - 1) #TODO handle looping
								current_row_idx += 1

							# On the next note, explicitely reset reference duty
							if current_row_idx == len(pattern['rows']):
								#TODO Handle instrument enveloppes effect on multiple patterns
								warn('instrument with duty enveloppe at the end of pattern in {}: enveloppe cut at end of pattern (TODO handle it)'.format(
									row_identifier(track_idx, pattern_idx, row_idx, chan_idx)
								))
								continue #TODO make a definitive choice between letting it as it is, or resetting to reference duty, or [insert clever idea]

							has_duty_effect = False
							for current_effect in pattern['rows'][current_row_idx]['channels'][chan_idx]['effects']:
								if current_effect[0] == 'V':
									has_duty_effect = True
							if not has_duty_effect:
								pattern['rows'][current_row_idx]['channels'][chan_idx]['effects'].append('V{:02X}'.format(ref_duty))

							# Mark duty sequence as handled for this row
							seq_dut = None

					if seq_pit is not None:
						ensure(len(seq_pit['sequence']) > 0, 'instrument {:X} has an empty pitch sequence')

						# Until the next note, the note is adjusted by the envelope
						sequence_step = 0
						current_slide = None
						last_chan_row = None
						def scanner_pit(current_pattern_idx, current_row_idx):
							nonlocal current_slide, last_chan_row, sequence_step
							current_chan_row = track['patterns'][current_pattern_idx]['rows'][current_row_idx]['channels'][chan_idx]
							last_chan_row = current_chan_row

							# Stop on any row with a note
							if current_chan_row['note'] != '...' and (current_pattern_idx, current_row_idx) != (pattern_idx, row_idx):
								return False

							# Place a pitch slide effect according to envelope
							#FIXME is is one tick late as instrument envelope is immediate while pitch slide begins its effect on the next tick
							#      (ideal whould be to change UCTF to hold frequencies instead of notes, so we can flatten pitch envelopes)
							envelope_pitch = seq_pit['sequence'][sequence_step]
							envelope_effect = '{}{:02X}'.format(
								'1' if envelope_pitch <= 0 else '2',
								abs(envelope_pitch)
							)

							# Place computed value
							if envelope_pitch != current_slide:
								place_pitch_effect(
									current_chan_row, envelope_effect, replace=True, warn_on_stop=False,
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
								place_pitch_effect(last_chan_row, '100', replace=False)
							else:
								# Envelope ended another way, we certainly placed an effect on it, replace it
								place_pitch_effect(last_chan_row, '100', replace=True)

						# Mark sequence as handled for this row
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

def remove_useless_pitch_effects(music):
	"""
	When there is multiple pitch effects on a line, remove some to avoid random selection by effects blindly refusing to start.
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

					# List effects on this row (by category)
					pitch_activation_effects_idx = []
					pitch_stop_effects_idx = []
					for effect_idx in range(len(chan_row['effects'])):
						effect = chan_row['effects'][effect_idx]
						if effect[0] in pitch_effects:
							if is_pitch_slide_activation_effect(effect):
								pitch_activation_effects_idx.append(effect_idx)
							else:
								pitch_stop_effects_idx.append(effect_idx)

					# If activation and deactivation effects cohexist, prioretize activation effects
					if len(pitch_activation_effects_idx) > 0 and len(pitch_stop_effects_idx) > 0:
						for effect_idx in pitch_stop_effects_idx:
							chan_row['effects'][effect_idx] = '...'
						continue

					# Simplify pitch stop effects by keeping only one
					for effect_idx in pitch_stop_effects_idx[1:]:
						chan_row['effects'][effect_idx] = '...'
					continue

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
					if new_portamento == 0 and not has_other_pitch_effect:
						chan_row['effects'][portamento_effect_idx] = '100'

					# Update current portamento value
					if new_portamento is not None or has_other_pitch_effect:
						current_portamento = new_portamento if not has_other_pitch_effect else 0

					# If there is a note, repeat portamento
					if chan_row['note'] not in ['...', '---', '==='] and portamento_effect_idx is None and current_portamento != 0:
						chan_row['effects'].append('3{:02X}'.format(current_portamento))

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
					original_note = get_previous_note(modified, track_idx, pattern_idx, chan_idx, row_idx)

					if original_note['note'] is None:
						warn('3xx effect without original note in {}: effect ignored'.format(
							row_identifier(track_idx, pattern_idx, row_idx, chan_idx)
						))
						chan_row['effects'][portamento_effect_idx] = '...'
						continue

					if not original_note['reliable']:
						warn('3xx effect while origin note was impacted by pitch effect in {}: effect ignored'.format(
							row_identifier(track_idx, pattern_idx, row_idx, chan_idx)
						))
						chan_row['effects'][portamento_effect_idx] = '...'
						continue

					# Compute useful values
					effect = chan_row['effects'][portamento_effect_idx]
					slide_speed = int(effect[1:], 16)
					freq_start = get_note_frequency(original_note['note'])
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
							row_identifier(track_idx, pattern_idx, row_idx, chan_idx)
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
						explicit_stop = current_row['note'] != '...'
						for effect in current_row['effects']:
							if effect[0] in pitch_effects:
								explicit_stop = True

						explicitely_stopped = explicitely_stopped or explicit_stop

					if not explicitely_stopped:
						pattern['rows'][dest_row_idx]['channels'][chan_idx]['note'] = chan_row['note']

						dest_has_pitch = False
						for current_effect in pattern['rows'][dest_row_idx]['channels'][chan_idx]['effects']:
							if current_effect[0] in pitch_effects:
								dest_has_pitch = True
						if not dest_has_pitch:
							pattern['rows'][dest_row_idx]['channels'][chan_idx]['effects'].append('100')

					# Remove the note from origin row
					chan_row['note'] = '...'

	return modified

def apply_q_effect(music):
	modified = copy.deepcopy(music)

	# Iterate on rows per channel
	for track_idx in range(len(modified['tracks'])):
		track = modified['tracks'][track_idx]
		for pattern_idx in range(len(track['patterns'])):
			pattern = track['patterns'][pattern_idx]
			for chan_idx in range(modified['params']['n_chan']):
				for row_idx in range(len(pattern['rows'])):
					chan_row = pattern['rows'][row_idx]['channels'][chan_idx]

					# Find if current row has a Q effect
					q_effect_idx = None
					has_other_pitch_effect = False
					for effect_idx in range(len(chan_row['effects'])):
						effect = chan_row['effects'][effect_idx]
						if effect[0] == 'Q':
							if q_effect_idx is not None:
								warn('multiple Qxy effects in {}: some will be ignored'.format(
									row_identifier(track_idx, pattern_idx, row_idx, chan_idx)
								))
							q_effect_idx = effect_idx
						elif effect[0] in pitch_effects:
							has_other_pitch_effect = True

					# Do not process the row if it has no Q effect or is a non-supported corner case
					if q_effect_idx is None:
						continue

					if has_other_pitch_effect:
						warn('multiple pitch effects in {}: Qxy will be ignored'.format(
							row_identifier(track_idx, pattern_idx, row_idx, chan_idx)
						))
						chan_row['effects'][q_effect_idx] = '...'
						continue

					origin_note = chan_row['note']
					if chan_row['note'] in ['...', '---', '===']:
						origin_note_info = get_previous_note(modified, track_idx, pattern_idx, chan_idx, row_idx)

						error = False
						if origin_note_info['note'] is None:
							warn('Qxy effect without explicit note in {}: effect ignored'.format(
								row_identifier(track_idx, pattern_idx, row_idx, chan_idx)
							))
							error = True

						if not origin_note_info['reliable']:
							warn('Qxy effect with reference note impacted by pitch effect in {}: ignored'.format(
								row_identifier(track_idx, pattern_idx, row_idx, chan_idx)
							))
							error = True

						if error:
							chan_row['effects'][q_effect_idx] = '...'
							continue

						origin_note = origin_note_info['note']

					# Compute useful values
					effect = chan_row['effects'][q_effect_idx]
					effect_x = int(effect[1], 16)
					effect_y = int(effect[2], 16)
					slide_speed = 2 * effect_x + 1
					freq_start = get_note_frequency(origin_note)
					note_table_index_stop = get_note_table_index(origin_note) + effect_y
					if note_table_index_stop >= len(note_table_freqs):
						warn('Qxy effect extends after notes table in {}: effect truncated'.format(
							row_identifier(track_idx, pattern_idx, row_idx, chan_idx)
						))
						note_table_index_stop = len(note_table_freqs) - 1
					freq_stop = note_table_freqs[note_table_index_stop]
					assert freq_stop <= freq_start
					duration = int((freq_start - freq_stop) / slide_speed)

					# Replace current row's effect with the equivalent 1xx effect
					chan_row['effects'][q_effect_idx] = '1{:02X}'.format(slide_speed)

					# Place an 100 effect and the stop note at stop location
					stop_row_idx = row_idx + duration
					if stop_row_idx >= len(pattern['rows']):
						warn('Qxy effect extends after pattern in {}: effect truncated'.format(
							row_identifier(track_idx, pattern_idx, row_idx, chan_idx)
						))
						stop_row_idx = len(pattern['rows']) - 1
					stop_chan_row = pattern['rows'][stop_row_idx]['channels'][chan_idx]

					stop_has_pitch_effect = False
					for current_effect in stop_chan_row['effects']:
						if current_effect[0] in pitch_effects:
							stop_has_pitch_effect = True

					if not stop_has_pitch_effect:
						stop_chan_row['effects'].append('100') #TODO should use an empty effect column if possible

					if stop_chan_row['note'] == '...':
						stop_chan_row['note'] = note_table_names[note_table_index_stop]

	return modified

def apply_r_effect(music):
	modified = copy.deepcopy(music)

	# Iterate on rows per channel
	for track_idx in range(len(modified['tracks'])):
		track = modified['tracks'][track_idx]
		for pattern_idx in range(len(track['patterns'])):
			pattern = track['patterns'][pattern_idx]
			for chan_idx in range(modified['params']['n_chan']):
				for row_idx in range(len(pattern['rows'])):
					chan_row = pattern['rows'][row_idx]['channels'][chan_idx]

					# Find if current row has a R effect
					r_effect_idx = None
					has_other_pitch_effect = False
					for effect_idx in range(len(chan_row['effects'])):
						effect = chan_row['effects'][effect_idx]
						if effect[0] == 'R':
							if r_effect_idx is not None:
								warn('multiple Rxy effects in {}: some will be ignored'.format(
									row_identifier(track_idx, pattern_idx, row_idx, chan_idx)
								))
							r_effect_idx = effect_idx
						elif effect[0] in pitch_effects:
							has_other_pitch_effect = True

					# Do not process the row if it has no R effect or is a non-supported corner case
					if r_effect_idx is None:
						continue

					if has_other_pitch_effect:
						warn('multiple pitch effects in {}: Rxy will be ignored'.format(
							row_identifier(track_idx, pattern_idx, row_idx, chan_idx)
						))
						chan_row['effects'][r_effect_idx] = '...'
						continue

					origin_note = chan_row['note']
					if chan_row['note'] in ['...', '---', '===']:
						origin_note_info = get_previous_note(modified, track_idx, pattern_idx, chan_idx, row_idx)

						error = False
						if origin_note_info['note'] is None:
							warn('Rxy effect without explicit note in {}: effect ignored'.format(
								row_identifier(track_idx, pattern_idx, row_idx, chan_idx)
							))
							error = True

						if not origin_note_info['reliable']:
							warn('Rxy effect with reference note impacted by pitch effect in {}: ignored'.format(
								row_identifier(track_idx, pattern_idx, row_idx, chan_idx)
							))
							error = True

						if error:
							chan_row['effects'][r_effect_idx] = '...'
							continue

						origin_note = origin_note_info['note']

					# Compute useful values
					effect = chan_row['effects'][r_effect_idx]
					effect_x = int(effect[1], 16)
					effect_y = int(effect[2], 16)
					slide_speed = 2 * effect_x + 1
					freq_start = get_note_frequency(origin_note)
					note_table_index_stop = get_note_table_index(origin_note) - effect_y
					if note_table_index_stop < 0:
						warn('Rxy effect extends before notes table in {}: effect truncated'.format(
							row_identifier(track_idx, pattern_idx, row_idx, chan_idx)
						))
						note_table_index_stop = 0
					freq_stop = note_table_freqs[note_table_index_stop]
					assert freq_start <= freq_stop
					duration = int((freq_stop - freq_start) / slide_speed)

					# Replace current row's effect with the equivalent 2xx effect
					chan_row['effects'][r_effect_idx] = '2{:02X}'.format(slide_speed)

					# Place an 100 effect and the stop note at stop location
					stop_row_idx = row_idx + duration
					if stop_row_idx >= len(pattern['rows']):
						warn('Rxy effect extends after pattern in {}: effect truncated'.format(
							row_identifier(track_idx, pattern_idx, row_idx, chan_idx)
						))
						stop_row_idx = len(pattern['rows']) - 1
					stop_chan_row = pattern['rows'][stop_row_idx]['channels'][chan_idx]

					stop_has_pitch_effect = False
					for current_effect in stop_chan_row['effects']:
						if current_effect[0] in pitch_effects:
							stop_has_pitch_effect = True

					if not stop_has_pitch_effect:
						stop_chan_row['effects'].append('100') #TODO should use an empty effect column if possible

					if stop_chan_row['note'] == '...':
						stop_chan_row['note'] = note_table_names[note_table_index_stop]

	return modified

def apply_4_effect(music):
	modified = copy.deepcopy(music)

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
						warn('multiple pitch effects in {}: 4xy will be ignored'.format(
							row_identifier(track_idx, pattern_idx, row_idx, chan_idx)
						))
						chan_row['effects'][vibrato_effect_idx] = '...'
						continue

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
						# Get original pitch
						current_pitch = None
						def scanner_flatten_original_pitch(current_pattern_idx, current_row_idx):
							nonlocal current_pitch
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
					elif conversion_type == 'pitch-slide':
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

							# If the row has any pitch effect, just stop
							#   warn if pitch impacting effect is not a 4xy (these effects should be stopped by a 40*)
							has_pitch_effect = False
							for checked_effect in current_chan_row['effects']:
								if checked_effect[0] in pitch_effects:
									if False and checked_effect[0] != '4':
										#TODO output a notice, not a warning (possibly due to previous manipulations)
										#     of andremove False from if's condition
										warn('4xy effect is interrupted by another effect type in {}, starting in {}'.format(
											row_identifier(track_idx, pattern_idx, current_row_idx, chan_idx),
											row_identifier(track_idx, pattern_idx, row_idx, chan_idx)
										))
									has_pitch_effect = True

							if has_pitch_effect:
								break

							# If it is time, change direction
							time_left -= 1
							if time_left <= 0:
								current_direction = '2' if current_direction == '1' else '1'
								time_left = one_way_time
								current_chan_row['effects'].append('{}{:02X}'.format(current_direction, step)) #TODO should use an empty effect column if possible

							# Next
							current_row_idx += 1

						# Check if we hit the end of pattern
						if current_row_idx >= len(pattern['rows']):
							warn('4xy effect extends after pattern in {}: effect truncated'.format(row_identifier(track_idx, pattern_idx, row_idx, chan_idx)))
							pattern['rows'][-1]['channels'][chan_idx]['effects'].append('100') #TODO should use an empty effect column if possible
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
								warn('Axy intterupted by another volume effect in {}: volume slide stopped'.format(
									row_identifier(track_idx, pattern_idx, row_idx, chan_idx)
								))
							break

						# Apply new volume
						current_volume += slide
						current_volume = min(15, max(0, current_volume))
						current_chan_row['volume'] = '{:2X}'.format(int(current_volume))

						# Stop if the slide hit the end
						if current_volume in [0, 15]:
							break

						current_row_idx += 1

					if current_row_idx >= len(pattern['rows']):
						warn('Axy goes beyond end of pattern in {}: effect truncated'.format(
							row_identifier(track_idx, pattern_idx, row_idx, chan_idx)
						))

	return modified

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
					for effect in chan_row['effects']:
						if effect[0] not in ['.', '1', '2', 'V']:
							warn('effect not handled in {}: effect={}'.format(
								row_identifier(track_idx, pattern_idx, row_idx, channel_idx),
								effect
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
									row_identifier(track_idx, pattern_idx, row_idx, channel_idx),
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
						for effect in chan_row['effects']:
							if effect[0] == 'V':
								duty_effect = effect
							elif effect[0] == '1':
								pitch_slide = -int(effect[1:], 16)
							elif effect[0] == '2':
								pitch_slide = int(effect[1:], 16)

						if sample['type'] == '2a03-pulse':
							sample['lines'].append({
								'note': chan_row['note'] if chan_row['note'] != '...' else None,
								'volume': int(chan_row['volume'], 16) if chan_row['volume'] != '.' else None,
								'duty': int(duty_effect[1:], 16) if duty_effect != '...' else None,
								'pitch_slide': pitch_slide
							})
						elif sample['type'] == '2a03-triangle':
							sample['lines'].append({
								'note': chan_row['note'] if chan_row['note'] != '...' else None,
								'pitch_slide': pitch_slide
							})
						elif sample['type'] == '2a03-noise':
							sample['lines'].append({
								'freq': chan_row['note'] if chan_row['note'] != '...' else None,
								'volume': int(chan_row['volume'], 16) if chan_row['volume'] != '.' else None,
								'periodic': int(duty_effect[1:], 16) if duty_effect != '...' else None,
								'pitch_slide': pitch_slide
							})
						else:
							ensure(False, 'unhandled sample type: {}'.format(sample['type']))

				# Store Sample
				modified['uctf']['channels'][-1].append(len(modified['uctf']['samples']))
				modified['uctf']['samples'].append(sample)

	return modified

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
			assert list(line.keys()) == uctf_fields, 'unsuported uctf line format (if you added a supported effect, remove_duplicated_note() certainly must be updated)'

			def field_changed(field):
				return line[field] is not None and line[field] != last_line_values[field]

			is_empty = True
			for field in uctf_fields:
				if field_changed(field):
					last_line_values[field] = line[field]
					is_empty = False
				else:
					if field == 'note' and last_line_values['pitch_slide'] != 0 and last_line_values['pitch_slide'] is not None:
						# Do not remove a duplicate note if there was a pitch slide
						# Note: "is not None" part of the condition means "if pitch slide was never set in this sample" which
						#        is an aggressive optimization (previous sample could have set a pitch slide)
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
						duration
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
				opcodes.append({
					'type': 'music_sample_2a03_noise_opcode',
					'name': 'SET_VOLUME',
					'parameters': [line['volume']]
				})

			if has_new_periodic:
				opcodes.append({
					'type': 'music_sample_2a03_noise_opcode',
					'name': 'SET_PERIODIC',
					'parameters': [line['periodic']]
				})

			if has_new_pitch_slide:
				if line['pitch_slide'] > 0:
					opcodes.append({
						'type': 'music_sample_2a03_noise_opcode',
						'name': 'PITCH_SLIDE_DOWN', #NOTE not a bug, positive pitch slide means pitch slide DOWN
						'parameters': [line['pitch_slide']]
					})
				else:
					opcodes.append({
						'type': 'music_sample_2a03_noise_opcode',
						'name': 'PITCH_SLIDE_UP',
						'parameters': [abs(line['pitch_slide'])]
					})

			# Timed opcodes (play, wait or halt)
			duration = line['duration']

			if line['freq'] in ['---', '===']:
				step = min(duration, 8)
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

def split_samples(music):
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
	for searched_sample_type in ['music_sample_2a03_pulse', 'music_sample_2a03_triangle', 'music_sample_2a03_noise']:
		# Scan all samples, searching for patterns
		patterns = {}
		for n_opcodes in range(min_pattern_size, max_pattern_size):
			for scaned_sample in music['mod']['samples']:
				if scaned_sample['type'] != searched_sample_type:
					continue

				for pattern_pos in range(len(scaned_sample['opcodes']) - n_opcodes + 1):
					# Extract pattern
					pattern_opcodes = scaned_sample['opcodes'][pattern_pos:pattern_pos+n_opcodes]
					assert len(pattern_opcodes) == n_opcodes

					# Reject patterns not ending with a timed opcode
					#  Technically not necessary, but more natural and avoid some of the flood
					#  May be improved by only getting full opcode groups (a timed and all parameters since the last timed)
					if not is_timed_opcode(pattern_opcodes[-1]):
						continue

					# Increment pattern's count
					key = json.dumps(pattern_opcodes, sort_keys=True)
					if key in patterns.keys():
						patterns[key]['count'] += 1
					else:
						patterns[key] = {
							'opcodes': pattern_opcodes,
							'count': 1
						}

		# Get the patterns ordered by the number of bytes they save
		flat_patterns = [patterns[k] for k in patterns]
		for pattern in flat_patterns:
			pattern_size_in_bytes = 0
			for opcode in pattern['opcodes']:
				pattern_size_in_bytes += get_opcode_size(opcode)

			bytes_saved = pattern_size_in_bytes * (pattern['count'] - 1) # Bytes saved by storing the pattern in a sample instead of repeating it
			bytes_saved -= 2 + pattern['count'] * (4 + 2) # Bytes wasted by referencing more samples in the track (worst case: 2 for pattern's SAMPLE_END + per-use<4 for new samples references in track + 2 for new SAMPLE_END in splitted sample>)
			pattern['bytes_saved'] = bytes_saved

		flat_patterns.sort(key=lambda x: x['bytes_saved'], reverse=True)

		# Try to extract each pattern until one can be extracted without breaking the limites of samples in any track
		for best_pattern in flat_patterns:
			# Determine if it is worth extracting the pattern to its own sample
			if best_pattern['bytes_saved'] <= 0:
				break # logically could be "continue", but it is not worth checking next patterns as they are ordered by "byte_saved"

			mod = copy.deepcopy(music['mod'])

			# Add a sample for the pattern
			pattern_sample_index = len(mod['samples'])
			mod['samples'].append({
				'type': searched_sample_type,
				'opcodes': best_pattern['opcodes']
			})

			# Split samples containing this pattern
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
			overflow = False
			for chan_idx in range(len(mod['channels'])):
				new_indexes = []
				for original_index in mod['channels'][chan_idx]:
					if original_index not in sample_index_update:
						new_indexes.append(original_index)
					else:
						new_indexes.extend(sample_index_update[original_index])
				if len(new_indexes) > 127:
					overflow = True
				mod['channels'][chan_idx] = new_indexes

			# Apply changes if it does not overflow maximum sample count
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
	music_name = 'title' #TODO get it from music structure, would need to extract it from ftm header
	track_names = ['pulse1', 'pulse2', 'triangle', 'noise']

	# Music header
	music_header = 'music_{music_name}_info:\n'.format(**locals())
	for track_name in track_names:
		music_header += '.word music_{music_name}_track_{track_name}\n'.format(**locals())

	# Tracks
	tracks_source = ''
	for track_idx in range(len(track_names)):
		track_name = track_names[track_idx]
		tracks_source += 'music_{music_name}_track_{track_name}:\n'.format(**locals())
		for sample_num in music['mod']['channels'][track_idx]:
			tracks_source += '.word music_{music_name}_sample_{sample_num}\n'.format(**locals())
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
		samples_source += 'music_{music_name}_sample_{sample_num}:\n.(\n'.format(**locals())
		for opcode in sample['opcodes']:
			samples_source += '\t{}{}({})\n'.format(opcode_prefix[sample['type']], opcode['name'], ','.join([str(x) for x in opcode['parameters']]))
		samples_source += '\tSAMPLE_END\n.)\n'

		sample_num += 1

	modified = copy.deepcopy(music)
	modified['src'] = {
		'type': 'samples_source',
		'value': music_header + '\n' + tracks_source + '\n' +samples_source,
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

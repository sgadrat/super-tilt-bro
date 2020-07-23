Music's format
==============

A music is a list of samples for each channel. Samples are played in order from the begining to the end.

Sample's format
===============

opcode parameters
opcode parameters
opcode parameters
[...]

opcode is a 5 bits number.
parameters is variable width, depending on opcode.

opcode+parameters is always a round number of bytes (with filling if necessary)
opcode is stored in the higher bits of the first byte, parameters are all other bits.

binary definition::

	OOOO OPPP  [pppp pppp [pppp pppp ...]]

	OOOOO: opcode number (always present)
	PPP: mandatory parameters (always present)
	ppppp...: optional parameters (presence depends on opcode, possibly also on parameters)

opcode's meaning depends on channel type.

opcode $00 is always the sample's end. Parameters bits are ignored and it is one byte long.

The length of O and P may differe between channels. Pulse and Triangle use 5 bits O, while noise use 4 bits O.

2A03 Pulse channel's opcodes
----------------------------

Opcode is 5 bits long. Opcode %00000 is reserved for sample's end.

CHAN_PARAMS::

	Modify most channel parameters.

	OOOO Oddd  DDLC VVVV  EPPP NSSS
	
	ddd: Default note duration minus one, in display frames
	DDLC VVVV: Duty, loop, constant volume, volume (direct write in $4000/$4004)
	EPPP NSSS: Sweep unit control (direct write in $4001/$4005)

CHAN_VOLUME_LOW::

	Modify channel volume.

	OOOO Ovvv

	vvv: volume

CHAN_VOLUME_HIGH::

	Modify channel volume.

	OOOO Ovvv 

	vvv: volume minus 8

CHAN_DUTY::

	Modify channel duty.

	OOOO ODDz

	DD: new duty
	z: reserved zero bit

PITCH_SLIDE::

	Set the change in pitch to be applied each display frame.

	OOOO Oszz  TTTT TTTT

	s: Sign, 1 - negative, 0 - positive
	zz: Reserved for future use, must be zero
	TTTT TTTT: Change in frequency each display frame (two's complement of it if s is set)

	note: sTTTTTTTT can be seen as a 9 bits signed integer

	note: Negative slide means the sound becomes higher over time, positive means lower pitch over time

PLAY_TIMED_FREQ::

	Play a precise frequency.

	OOOO OTTT  TTTT TTTT  DDDD DDDD

	TTT TTTT TTTT: Frequency (direct write in APU register)
	DDDD DDDD: Duration, in display frames

	The next opcode will be executed only after the specified duration. If duration is zero,
	next opcodes will be executed immediately until one with a non-null duration is found.

PLAY_NOTE::

	Start playing a note.

	OOOO ODdd  zNNN NNNN
	
	D: duration shift direction - 0: divide, 1: multiply
	dd: duration shift
	z: zero bit
	NNN NNNN: index of note's frequence in the lookup table

	The duration in frames is computed:
	if D is 0: nb_frames = (default_note_duration >> dd)
	if D is 1: nb_frames = (default_note_duration << dd)

	The next opcode will be executed only after the specified duration.

PLAY_TIMED_NOTE::

	Start playing a note, with fine-grained timing

	OOOO Oddd  dNNN NNNN

	ddd d: duration minus one, in display frames
	NNN NNNN: index of note's frequence in the lookup table

	The next opcode will be executed only after the specified duration.

WAIT::

	Does nothing for the specified time.

	OOOO Oddd

	ddd: duration minus one, in display frames

	The next opcode will be executed only after the specified duration.

LONG_WAIT::

	Does nothing for the specified time.

	OOOO O... DDDD DDDD

	DDD DDDD: Duration, in display frames

	The next opcode will be executed only after the specified duration. If duration in zero,
	next opcodes will be executed immediately until one with a non-null duration is found.

	note: The behaviour with a duration at zero is a side effect, it basically makes
	LONG_WAIT behave as a noop.

HALT::

	Silence the channel.

	OOOO Oddd

	ddd: Duration minus one, in display frames

	The next opcode will be executed only after the specified duration.

META_NOTE_SLIDE_UP::

	OOOO Ovsd  zNNN NNNN  DDDD DDDD [ddzz vvvv] [SSSS SSSS]

	vsd: presence flags for volume, pitch slide, and duty
	SSSS SSSS: lsb of a signed 16 bit value to add to the frequency register each video frame (msb is assumed to be $ff)

	Note if dolume/duty byte is present but duty is not present, dd must be zero. The same applies for vvvv.

META_NOTE_SLIDE_DOWN::

	OOOO Ovsd  zNNN NNNN  DDDD DDDD [ddzz vvvv] [SSSS SSSS]

	vsd: presence flags for volume, pitch slide, and duty

	Note if dolume/duty byte is present but duty is not present, dd must be zero. The same applies for vvvv.

META_WAIT_SLIDE_UP::

	OOOO Ovsd  DDDD DDDD [ddzz vvvv] [SSSS SSSS]

	vsd: presence flags for volume, pitch slide, and duty
	SSSS SSSS: lsb of a signed 16 bit value to add to the frequency register each video frame (msb is assumed to be $ff)

	Note if dolume/duty byte is present but duty is not present, dd must be zero. The same applies for vvvv.

META_WAIT_SLIDE_DOWN::

	OOOO Ovsd  DDDD DDDD [ddzz vvvv] [SSSS SSSS]

	vsd: presence flags for volume, pitch slide, and duty

	Note if dolume/duty byte is present but duty is not present, dd must be zero. The same applies for vvvv.

2A03 Triangle channel's opcodes
-------------------------------

Same as 2A03 Pulse channel's opcodes, without VOLUME_* nor CHAN_PARAMS

Note::

	Notes are two octaves lower than their equivalent in pulse channels.

2A03 Noise channel's opcodes
----------------------------

Opcode is 4 bits long. Opcode %0000 is reserved for sample's end. In this case, the entire byte should be $00.

SET_VOLUME::

	Modify channel volume.

	OOOO vvvv

	vvvv: volume

SET_PERIODIC::

	Set periodic noise flag.

	OOOO zzzL

	zzz: reserved zero bits
	L: flag's value

PLAY_TIMED_FREQ::

	Start playing a frequence, for a number of fremes timing

	OOOO NNNN  dddd dddd

	dddd dddd: duration, in display frames
	NNNN: frequency register value

	The next opcode will be executed only after the specified duration.

WAIT::

	Does nothing for the specified time.

	OOOO dddd

	ddd: duration minus one, in display frames

	The next opcode will be executed only after the specified duration.

LONG_WAIT::

	Does nothing for the specified time.

	OOOO zzzz DDDD DDDD

	zzzz: reserved zero bits
	DDDD DDDD: Duration, in display frames

	The next opcode will be executed only after the specified duration. If duration in zero,
	next opcodes will be executed immediately until one with a non-null duration is found.

	note: The behaviour with a duration at zero is a side effect, it basically makes
	LONG_WAIT behave as a noop.

HALT::

	Silence the channel.

	OOOO dddd

	dddd: Duration minus one, in display frames

	The next opcode will be executed only after the specified duration.

PITCH_SLIDE_UP::

	Set the change in pitch to be applied each display frame, pitch goes upward.

	OOOO TTTT

	TTTT: Value substracted from frequency register each display frame

	TODO: investigate requiring TTTT to be twos compliment of its value. Trading off readability of music source for a little bit of performance.

PITCH_SLIDE_DOWN::

	Set the change in pitch to be applied each display frame, pitch goes downward.

	OOOO TTTT

	TTTT: Value added to frequency register each display frame

RAINBOW Pulse channel's opcodes
-------------------------------

TODO

RAINBOW Saw channel's opcodes
-----------------------------

TODO



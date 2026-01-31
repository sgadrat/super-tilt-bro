#!/usr/bin/env python
"""
Count duration of samples in a source file.

This script is for helping investigation on desync issues between channels. It
is not intuitive nor resilient. If you did not used in a long time, you may have
to patch it before using.
"""

import sys
import re

DEFAULT_NOTE_DUR = 5

re_play_timed_freq = re.compile(r'PLAY_TIMED_FREQ\([0-9]+,(?P<dur>[0-9]+)\)')
re_play_note = re.compile(r'PLAY_NOTE\((?P<dir>[0-9]+),(?P<mul>[0-9]+),[0-9]+\)')
re_play_timed_note = re.compile(r'PLAY_TIMED_NOTE\((?P<dur>[0-9]+),0-9]+\)')
re_wait = re.compile(r'WAIT\((?P<dur>[0-9]+)\)')
re_long_wait = re.compile(r'LONG_WAIT\((?P<dur>[0-9]+)\)')
re_halt = re.compile(r'HALT\((?P<dur>[0-9]+)\)')

re_sample_end = re.compile('SAMPLE_END')

total = 0
current_sample = 0
current_sample_idx = 1

for line in sys.stdin:
	line = line[:-1]

	dur = 0

	m = re_sample_end.search(line)
	if m is not None:
		print('sample_{} {}'.format(current_sample_idx, current_sample))
		current_sample = 0
		current_sample_idx += 1

	m = re_play_timed_freq.search(line)
	if m is not None:
		dur = int(m.group('dur'))

	m = re_play_note.search(line)
	if m is not None:
		if m.group('dir') == '0':
			dur = DEFAULT_NOTE_DUR >> int(m.group('mul'))
		else:
			dur = DEFAULT_NOTE_DUR << int(m.group('mul'))

	m = re_play_timed_note.search(line)
	if m is not None:
		dur = int(m.group('dur')) + 1

	m = re_wait.search(line)
	if m is not None:
		dur = int(m.group('dur')) + 1

	m = re_long_wait.search(line)
	if m is not None:
		dur = int(m.group('dur'))

	m = re_halt.search(line)
	if m is not None:
		dur = int(m.group('dur')) + 1

	total += dur
	print(line)
	if dur != 0:
		print(' => {:02x} ({:02x} + {:02x})'.format(total, total - dur, dur))
	current_sample += dur

print('total: {}'.format(total))

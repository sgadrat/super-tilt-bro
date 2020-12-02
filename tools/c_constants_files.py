#!/usr/bin/env python

import re
from stblib.utils import asmint

# Build memory layout header
with open('game/mem_labels.asm', 'r') as source_file:
	with open('game/cstb/mem_labels.h', 'w') as dest_file:
		dest_file.write('#include <stdint.h>\n\n')
		for line in source_file:
			processed = line.rstrip('\n')
			processed = re.sub(';', '//', processed)
			processed = re.sub(r'^([a-zA-Z0-9_]+) = \$([0-9a-f]+)', r'static uint8_t* const \1 = (uint8_t* const)0x\2;', processed)
			processed = re.sub(r'^([a-zA-Z0-9_]+) = (.*)', r'static uint8_t* const \1 = \2;', processed)
			dest_file.write(processed + '\n')

# Build project wide constants header
def base_prefix(asm_prefix):
	return {'$': '0x', '%': '0b'}

with open('game/constants.asm', 'r') as source_file:
	with open('game/cstb/constants.h', 'w') as dest_file:
		for line in source_file:
			line = line.rstrip('\n')
			processed = line

			# Common transformation
			processed = re.sub(';', '//', processed)

			# Convert known line formats to C++
			m = re.match(r'^(?P<lbl>[a-zA-Z0-9_]+) = (?P<val>[0-9a-f$%]+)(?P<cmt> //.*)?$', processed)
			if m is not None:
				processed = 'static uint16_t const {} = {};{}'.format(
					m.group('lbl'), asmint(m.group('val')), '' if m.group('cmt') is None else m.group('cmt')
				)
			else:
				m = re.match(r'^(?P<lbl>[a-zA-Z0-9_]+) = (?P<expr>.+)?$', processed)
				if m is not None:
					processed = 'static uint16_t const {} = {};'.format(
						m.group('lbl'), m.group('expr')
					)

			m = re.match(r'^#define (?P<lbl>[a-zA-Z0-9_]+)( +)(#?)(?P<val>[0-9a-f$%]+)', processed)
			if m is not None:
				processed = '#define {} {}'.format(
					m.group('lbl'), asmint(m.group('val'))
				)

			# Write processed line
			dest_file.write(processed + '\n')

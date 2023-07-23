#!/usr/bin/env python

import re
from stblib.utils import asmint

# Build memory layout header
def process_mem_labels_line(line):
	processed = line.rstrip('\n')
	processed = re.sub(';', '//', processed)
	processed = re.sub(r'^([a-zA-Z0-9_]+) = \$([0-9a-f]+)', r'static uint8_t* const \1 = (uint8_t* const)0x\2;', processed)
	processed = re.sub(r'^([a-zA-Z0-9_]+) = ([^/]*)( //.*)?$', r'static uint8_t* const \1 = \2;\3', processed)
	return processed + '\n'

def process_mem_labels_file(filename, dest_file):
	with open(filename, 'r') as source_file:
		for line in source_file:
			m = re.search('^#include "(?P<inc>.*)"', line)
			if m is not None:
				process_mem_labels_file(m.group('inc'), dest_file)
			else:
				dest_file.write(process_mem_labels_line(line))

with open('game/cstb/mem_labels.h', 'w') as dest_file:
	dest_file.write('#pragma once\n\n')
	dest_file.write('#include <stdint.h>\n\n')
	process_mem_labels_file('game/mem_labels.asm', dest_file)

#
# Build project wide constants headers
#

def base_prefix(asm_prefix):
	return {'$': '0x', '%': '0b'}

# Files containing only constants
for paths in [
	{'src': 'game/constants.asm',      'dst': 'game/cstb/constants.h'},
	{'src': 'game/logic/stnp_lib.asm', 'dst': 'game/cstb/stnp_constants.h'},
]:
	with open(paths['src'], 'r') as source_file:
		with open(paths['dst'], 'w') as dest_file:
			dest_file.write('#pragma once\n\n')
			dest_file.write('#include <stdint.h>\n\n')
			for line in source_file:
				line = line.rstrip('\n')
				processed = line

				# Common transformation
				processed = re.sub(';', '//', processed)

				# Convert known line formats to C
				m = re.match(r'^(?P<lbl>[a-zA-Z0-9_]+) = (?P<val>[0-9a-f$%]+)(?P<cmt>( +)//.*)?$', processed)
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

# Build rainbow constants
with open('game/rainbow_lib_declarations.asm', 'r') as source_file:
	with open('game/cstb/rainbow_constants.h', 'w') as dest_file:
		dest_file.write('#pragma once\n\n')
		dest_file.write('#include <stdint.h>\n\n')
		for line in source_file:
			line = line.rstrip('\n')
			processed = None

			# Common transformation
			line = re.sub(';', '//', line)

			# Convert known line formats to C++
			m = re.match(r'^(?P<lbl>((FROMESP)|(TOESP)|(ESP))_[A-Z0-9_]+)( +)= (?P<val>[0-9a-f$%]+)(?P<cmt> +//.*)?$', line)
			if m is not None:
				processed = 'static uint8_t const {} = {};{}'.format(
					m.group('lbl'), asmint(m.group('val')), '' if m.group('cmt') is None else m.group('cmt')
				)

			# Write processed line
			if processed is not None:
				dest_file.write(processed + '\n')

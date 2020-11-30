#!/usr/bin/env python
import argparse
import re
import sys

ignored_opcodes = {}
def convert_gcc_to_xa(source):
	global ignored_opcodes
	passthru_opcodes = ['byte', 'word']
	prune_a_instr = ['asl a', 'lsr a', 'rol a', 'ror a']

	def mangle_labels(line):
		line = re.sub('L@([0-9]+)', r'clbl_\1', line)
		line = re.sub(r'([0-9a-zA-Z_]+)\$([0-9]+)', r'\1_n_\2', line)
		return line

	# First pass: read header, do most transforms, name unnamed labels
	ignored_opcodes = {}
	exports = []
	unnamed_labels = []
	res = ['.(']
	for line in source:
		line = line.rstrip('\r\n')

		unindent_line = line.lstrip()
		if unindent_line.startswith('.'):
			# Handling of pseudo ops (mainly contain meta information and segments boundaries)
			opcode = re.match(r'^\.([^ \t]+).*$', unindent_line).group(1)
			if opcode == 'export':
				exports = unindent_line[8:].split(', ')
			elif opcode == 'res':
				res.append(mangle_labels(line.replace('.res ', '.dsb ')))
			elif opcode in passthru_opcodes:
				res.append(mangle_labels(line))
			else:
				opcode = re.match(r'^\.([^ \t]+).*$', unindent_line).group(1)
				ignored_opcodes[opcode] = ignored_opcodes.get(opcode, 0) + 1
		elif line.strip() == ':':
			# Give a name to unnamed labels, and note their position
			line_num = len(res)
			label_name = 'unamed_lbl_{}'.format(line_num)
			unnamed_labels.append(line_num)
			res.append('{}:'.format(label_name))
		elif line.strip() in prune_a_instr:
			# Remove explicit references to A for implicit addressed instructions on A
			res.append(line.replace(' a', ''))
		else:
			# Rename labels (xa does not like @, nor $ in label names)
			line = mangle_labels(line)

			# Make exported symboles global labels
			for symbol in exports:
				if line == '{}:'.format(symbol):
					line = '+{}:'.format(symbol)

			# Print resulting line
			res.append(line)
	res.append('#include "game/cstb/compiler_routines.asm"')
	res.append('.)')

	# Second pass, resolve references to unnamed labels
	for line_num in range(len(res)):
		line = res[line_num]

		m = re.search(':(\++)', line)
		if m is not None:
			num_forward = len(m.group(1))
			folowing_label_index = unnamed_labels.index(min(filter(lambda x: x > line_num, unnamed_labels))) # index of the first unnamed label following this line
			referenced_label_index = folowing_label_index + (num_forward - 1)
			res[line_num] = re.sub(':(\++)', 'unamed_lbl_{}'.format(unnamed_labels[referenced_label_index]), line)

		m = re.search(':(-+)', line)
		if m is not None:
			num_backward = (m.group(1))
			previous_label_index = unnamed_labels.index(max(filter(lambda x: x < line_num, unnamed_labels))) #index of the last unnamed label before this line
			referenced_label_index = folowing_label_index + (num_backward - 1)
			res[line_num] = re.sub(':(-+)', 'unamed_lbl_{}'.format(unnamed_labels[referenced_label_index]), line)

	# Return
	return '\n'.join(res)

# Parse command line
parser = argparse.ArgumentParser(description='Convert an asm file from gcc output to xa dialect')
parser.add_argument('source', type=str, help='file to convert')
parser.add_argument('-o', '--destination', type=str, default=None, help='output file (default: overwrite source)')
args = parser.parse_args()

source = None
if args.source == '-':
	source = sys.stdin
else:
	source = open(args.source, 'r')

dest_path = args.source
if args.destination is not None:
	dest_path = args.destination

# Convert file
converted = convert_gcc_to_xa(source)
if dest_path == '-':
	sys.stdout.write(converted)
else:
	with open(dest_path, 'w') as dest:
		dest.write(converted)

# Warn about unknown opcodes
ok_to_ignore = [
	'autoimport',
	'code',
	'feature',
	'importzp',
	'p02',
	'segment',
]
has_ignored = False
for opcode in ignored_opcodes:
	if opcode not in ok_to_ignore:
		sys.stderr.write('Ignored "{}" {} times\n'.format(opcode, ignored_opcodes[opcode]))
		has_ignored = True
if has_ignored:
	sys.exit(1)

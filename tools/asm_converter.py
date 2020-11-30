#!/usr/bin/env python
import argparse
import re
import sys

def convert_gcc_to_xa(source):
	res = '.(\n'

	exports = []
	for line in source:
		line = line.rstrip('\r\n')

		# Handling of pseudo ops (mainly contain meta information and segments boundaries)
		if line.startswith('\t.'):
			if line.startswith('\t.export '):
				exports = line[9:].split(', ')
			elif line.startswith('\t.byte'):
				res += line + '\n'
			else:
				pass # prune unknown pseudo-ops
		else:
			# Rename labels (xa does not like @ in label names)
			line = re.sub('L@([0-9]+)', r'clbl_\1', line)

			# Make exported symboles global labels
			for symbol in exports:
				if line == '{}:'.format(symbol):
					line = '+{}:'.format(symbol)

			# Print resulting line
			res += line + '\n'

	return res + '.)\n'

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

#!/usr/bin/env python3
import sys
import re

#
# A slow, and limited preprocessor which aiming at pre-handling
# macro-heavy files before XA.
#
# (XA seems to crash when too much macros are in the project)
#

substitutions = {}

def out(m):
	print(m)

def ensure(cond, m):
	if not cond:
		sys.stderr.write(f'ensure failed: {m}\n')
		sys.exit(1)

def instruction_handler_define(params):
	global substitutions
	ensure(params[0] not in substitutions, f'redefine of {params[0]}')
	substitutions[params[0]] = ' '.join(params[1:])

def instruction_handler_undef(params):
	global substitutions
	del substitutions[params[0]]

# Parse command line
infile = sys.argv[1]

# Iterate though file
re_directive = re.compile('^#( *)(?P<name>[^ ]+)( (?P<params>.*))?$')

with open(infile, 'r') as f:
	for line in f:
		line = line.rstrip('\r\n ')

		# Check if it is a preprocessor directive line (begining with '#')
		#  If the instruction is not handled, print the line as is, without substitution.
		#  Avoid sustituting at definition what should be recursive substitution.
		m = re_directive.match(line)
		if m is not None:
			handler = 'instruction_handler_{}'.format(m.group('name'))
			params = m.group('params').split()
			if params[-1] != '\\' and callable(globals().get(handler)):
				globals().get(handler)(params)
			else:
				out(line)
			continue

		for original in substitutions:
			line = line.replace(original, substitutions[original])
		out(line)

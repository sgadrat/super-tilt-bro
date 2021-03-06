#!/usr/bin/env python
import json
import re
import sys

in_filename = '/tmp/nes.perf'

# Get routines addresses
routines = json.load(sys.stdin)

# Utilities
def translate(addr):
	global routines

	addr_int = int(addr, 16)
	for routine in routines:
		if addr_int >= routine['begin'] and addr_int < routine['end']:
			return routine['name']

	return '({})'.format(addr)

# Translate stack part of perf report from address to routine name
re_in_perf = re.compile('^(?P<stack>([0-9a-f]{4};)*)?(?P<instr>[0-9a-f]{4}) (?P<cycles>[0-9]+)$')
with open(in_filename, 'r') as in_file:
	for line in in_file:
		if line[-1] == '\n':
			line = line[:-1]

		# line format: routine_addr:routine_addr:...:instruction_addr cycle_count
		m = re_in_perf.match(line)
		assert m is not None, "invalid line in input file: '{}'".format(line) #TODO should be ensure
		stack = m.group('stack')
		cycles = m.group('cycles')

		if stack == '':
			stack = ['top_level']
		else:
			# Split stack frames into a list
			assert stack[-1] == ';'
			stack = stack[:-1]
			stack = stack.split(';')

			# Add current instruction at the end of the stack list (see comment about prunning it below)
			stack.append(m.group('instr'))

			# Resolve stack frames to routine name
			for i in range(len(stack)):
				stack[i] = translate(stack[i])

			# Keep the last element only if the instruction is not in the routine pointed by last stack frame
			#  Allows to follow "jmp <routine_label>" while avoiding to almost always double the last routine name
			if stack[-1] == stack[-2]:
				stack = stack[:-1]

		print('{} {}'.format(';'.join(stack), cycles))

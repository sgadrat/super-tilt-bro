#!/usr/bin/env python
import json
import os
import re
import sys
import time

in_filename = '/tmp/nes.perf'

# Get routines addresses
routines = json.load(sys.stdin)
routines_dict = {x['begin']: x['name'] for x in routines}
#routines_dict = {}
#for addr_int in range(0x10000):
#	for routine in routines:
#		if addr_int >= routine['begin'] and addr_int < routine['end']:
#			routines_dict[addr_int] = routine['name']

# Utilities
def translate(addr):
	global routines, routines_dict

	addr_int = int(addr, 16)

	# Note:
	#  this is an ugly speedup using cache of previous results,
	#  would be better preprocess "routines" once for all to construct
	#  the ideal memory structure.
	if addr_int in routines_dict:
		return routines_dict[addr_int]

	for routine in routines:
		if addr_int >= routine['begin'] and addr_int < routine['end']:
			routines_dict[addr_int] = routine['name']
			return routine['name']

	return '({})'.format(addr)

# Translate stack part of perf report from address to routine name
re_in_perf = re.compile('^(?P<stack>([0-9a-f]{4};)*)?(?P<instr>[0-9a-f]{4}) (?P<cycles>[0-9]+)$')
in_file_size = os.stat(in_filename).st_size
read_size = 0
begin = time.time()
last_progress = begin
cycles_counters = {}
with open(in_filename, 'r') as in_file:
	for line in in_file:
		# Update progress
		read_size += len(line)
		if time.time() - last_progress > 10:
			progress = read_size / in_file_size
			time_spent = time.time() - begin
			sys.stderr.write(
				'{:.02f}% - {:.01f} minutes elapsed - ETA {:0.1f} minutes\r'.format(
					100. * progress,
					time_spent / 60,
					((time_spent / progress) - time_spent) / 60
				)
			)
			last_progress = time.time()

		if line[-1] == '\n':
			line = line[:-1]

		# line format: routine_addr:routine_addr:...:instruction_addr cycle_count
		m = re_in_perf.match(line)
		assert m is not None, "invalid line in input file: '{}'".format(line) #TODO should be ensure
		stack = m.group('stack')
		instr = m.group('instr')
		cycles = int(m.group('cycles'))
		#stack, _, cycles = line.partition(' ')
		#instr = stack[-4:]
		#stack = stack[:-4]
		#cycles = int(cycles)

		if stack == '':
			stack = ['top_level']
		else:
			# Split stack frames into a list
			assert stack[-1] == ';'
			stack = stack[:-1]
			stack = stack.split(';')

			# Add current instruction at the end of the stack list (see comment about prunning it below)
			stack.append(instr)

			# Resolve stack frames to routine name
			for i in range(len(stack)):
				#stack[i] = routines_dict.get(int(stack[i],16), '({})'.format(stack[i]))
				stack[i] = translate(stack[i])

			# Keep the last element only if the instruction is not in the routine pointed by last stack frame
			#  Allows to follow "jmp <routine_label>" while avoiding to almost always double the last routine name
			if stack[-1] == stack[-2]:
				stack = stack[:-1]

		frame_desc = ';'.join(stack)
		cycles_counters[frame_desc] = cycles_counters.get(frame_desc, 0) + cycles

if last_progress != begin:
	sys.stderr.write('\n')

for frame_desc in cycles_counters:
	print('{} {}'.format(frame_desc, cycles_counters[frame_desc]))

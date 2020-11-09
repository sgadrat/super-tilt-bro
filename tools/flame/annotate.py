#!/usr/bin/env python
import listing
import re
import sys
from stblib import ensure

# Parse command line
perf_filename = sys.argv[1]
listing_filename = sys.argv[2]

# Gather statistics per instruction
cycles_per_instr = {}
cycles_total = 0
re_perf = re.compile('^(?P<stack>([0-9a-f]{4};)*)?(?P<instr>[0-9a-f]{4}) (?P<cycles>[0-9]+)$')
with open(perf_filename, 'r') as perf_file:
	for line in perf_file:
		if line[-1] == '\n':
			line = line[:-1]

		m = re_perf.match(line)
		ensure(m is not None, "invalid line in input file: '{}'".format(line))
		instr = int(m.group('instr'), 16)
		cycles = int(m.group('cycles'))

		if instr >= 0xc000:
			cycles_per_instr[instr] = cycles_per_instr.get(instr, 0) + cycles
			cycles_total += cycles

# Anotate listing file
def o(m):
	print(m)
def on_file(line_num, filename):
	o('')
	o('# {}'.format(filename))
	o('')
	o('| cycles  | rel  | code                                                                                                                      |')
	o('| ------: | ---: | ------------------------------------------------------------------------------------------------------------------------- |')
def on_listing(line_num, parsed):
	cycles = cycles_per_instr.get(parsed['address'], 0)
	o('| {: 7d} | {:0.2f} | {: <121s} |'.format(
		cycles,
		(1000. * cycles) / cycles_total,
		parsed['code']
	))
	if parsed['address'] in cycles_per_instr:
		del cycles_per_instr[parsed['address']]

if listing_filename == '-':
	listing.parse_fileobj(sys.stdin, on_file=on_file, on_listing=on_listing)
else:
	listing.parse_file(listing_filename, on_file=on_file, on_listing=on_listing)

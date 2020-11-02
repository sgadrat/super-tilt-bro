#!/usr/bin/env python
import json
import listing
import re
import sys

#
# Parse command line
#

input_filename = '-'
if len(sys.argv) > 1:
	if len(sys.argv) > 2 or sys.argv[1] in ['-h', '--help']:
		print('usage: {} [input_file]'.format(sys.argv[0]))
		sys.exit(1)
	input_filename = sys.argv[1]

#
# Construct mapping address -> routine
#

re_label = re.compile('^(?P<label>[a-z0-9_-]+)( +)$')
re_open_scope = re.compile('[ \t]+\\.\\(.*')
re_close_scope = re.compile('[ \t]+\\.\\).*')

routines = []

state = {
	'depth': 0,
	'curr_label': None,
	'curr_routine': None,
}
def on_listing(line_num, parsed):
	global routines, state

	#HACK Ignore everything but fixed bank (TODO handle banks)
	if parsed['address'] < 0xc000 or parsed['address'] > 0xffff:
		return

	m = re_label.match(parsed['code'])
	if m is not None:
		if state['depth'] == 0:
			state['curr_label'] = m.group('label')

	m = re_open_scope.match(parsed['code'])
	if m is not None:
		state['depth'] += 1
		if state['depth'] == 1 and state['curr_label'] is not None:
			state['curr_routine'] = {'name': state['curr_label'], 'begin': parsed['address'], 'end': None}
			state['curr_label'] = None

	m = re_close_scope.match(parsed['code'])
	if m is not None:
		state['depth'] -= 1
		if state['depth'] == 0 and state['curr_routine'] is not None:
			state['curr_routine']['end'] = parsed['address']
			routines.append(state['curr_routine'])
			state['curr_routine'] = None

if input_filename == '-':
	listing.parse_fileobj(sys.stdin, on_file=None, on_listing=on_listing)
else:
	listing.parse_file(input_filename, on_file=None, on_listing=on_listing)

#
# Output routines list
#

print(json.dumps(routines))

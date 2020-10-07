import re
from stblib import ensure

re_listing_line = re.compile('^ {0,4}[0-9]{1,5} [?ATBDUZ]:[0-9a-f]{4}  ')

def parse_file(filepath, on_listing = None, on_file = None):
	"""
	Parse a file line by line, invoking callbacks on interesting lines
	"""
	with open(filepath, 'r') as f:
		line_num = 1

		for line in f:
			parsed = parse_line(line)

			ensure(parsed['type'] in ['listing', 'empty', 'filename'])
			if parsed['type'] == 'listing':
				if on_listing is not None:
					on_listing(line_num, parsed['parsed'])
			elif parsed['type'] == 'filename':
				if on_file is not None:
					on_file(line_num, parsed['file'])

			line_num += 1

def parse_line(line):
	"""
	Parse a line from a listing.
	"""
	if line[-1] == '\n':
		line = line[:-1]

	if len(line) == 0:
		return {'type': 'empty'}
	if re_listing_line.match(line):
		return {'type': 'listing', 'parsed': parse_listing_line(line)}
	return {'type': 'filename', 'file': line}

def parse_listing_line(line):
	"""
	Parse a listing line.

	Warning: not a filename line nor an empty line, just an actual listing line
	"""
	if line[-1] == '\n':
		line = line[:-1]
	ensure(len(line) >= 39, 'listing line truncated "{}"'.format(line))

	return {
		'line': int(line[0:5]),
		'segment': line[6],
		'address': int(line[8:12], 16),
		'data_repr': line[14:38], #TODO parse bytes in "data" field, and deprecate this one
		'code': line[39:]
	}

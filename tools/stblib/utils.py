import struct

def intasm8(i):
	return '$%02x' % struct.pack('>b', i)[0]

def uintasm8(i):
	return '$%02x' % struct.pack('>B', i)[0]

def intasm16(i):
	s = struct.pack('>h', i)
	return '$%02x%02x' % (s[0], s[1])

def uintasm16(i):
	s = struct.pack('>H', i)
	return '$%02x%02x' % (s[0], s[1])

def intasm32(i):
	s = struct.pack('>i', i)
	return '$%02x%02x%02x%02x' % (s[0], s[1], s[2], s[3])

def uintasm32(i):
	s = struct.pack('>I', i)
	return '$%02x%02x%02x%02x' % (s[0], s[1], s[2], s[3])

def asmint(s):
	if s[0] == '$':
		return int(s[1:], 16)
	if s[0] == '%':
		return int(s[1:], 2)
	return int(s)

def asmsint8(s):
	i = asmint(s)
	if i >= 0x80:
		i = -(0x100 - i)
	assert -128 <= i and i <= 127
	return i

def asmsint16(s):
	i = asmint(s)
	if i >= 0x8000:
		i = -(0x10000 - i)
	return i

def int16msb(i):
	s = struct.pack('>h', i)
	return s[0]

def int16lsb(i):
	s = struct.pack('>h', i)
	return s[1]

def uint16msb(i):
	return (i & 0xff00) >> 8

def uint16lsb(i):
	return i & 0x00ff

def str_to_tile_index(s, index_of_a = 0xe6, index_of_zero = 0xdb, special_cases = None):
	"""
	Convert a string to a series of tile indexes.

	Params:
		s: the string to convert
		index_of_a: begining of alphabetical tiles
		index_of_zero: begining of numerical tiles
		special_cases: what to if a character is not alpha-numerical

	special_case can be:
		None - non alpha-numerical characters are skipped
		callable - special cases is called for each non alpha-numerical character
		dict - a correspondance table between characters and their index
	"""

	res = []
	for c in s:
		index = None
		if ord(c) >= ord('a') and ord(c) <= ord('z'):
			index = ord(c) - ord('a') + index_of_a
		elif ord(c) >= ord('A') and ord(c) <= ord('Z'):
			index = ord(c) - ord('A') + index_of_a
		elif ord(c) >= ord('0') and ord(c) <= ord('9'):
			index = ord(c) - ord('0') + index_of_zero
		elif callable(special_cases):
			index = special_cases(c)
		elif special_cases is not None:
			index = special_cases.get(c)

		if index is not None:
			res.append(index)

	return res

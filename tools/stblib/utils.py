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

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
	return i

def asmsint16(s):
	i = asmint(s)
	if i >= 0x8000:
		i = -(0x10000 - i)
	return i

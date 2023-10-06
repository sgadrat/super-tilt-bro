#!/usr/bin/env python

import hashlib
import os
import re
import subprocess
import sys
import tempfile

stb_root = os.path.abspath(os.path.dirname(__file__)+'/..')

class VmState:
	def __init__(self):
		self.memory = bytes()

def execute_asm(source):
	# Set current dir to stb root (so includes in source are relative to stb root)
	os.chdir(stb_root)

	# Execute source code
	process = None
	with tempfile.NamedTemporaryFile('w+t', delete=False) as source_file:
		source_file.write(source)
		source_file.close()
		process = subprocess.run(f"echo -e '%asm {source_file.name}\\n%mem $0000 $10000' | 6502cli", shell=True, capture_output=True, text=True, check=True)
		os.unlink(source_file.name)

	# Display interpretor errors
	if process.stderr != '':
		print("6502 interpretor has some issues")
		print(process.stderr)
		assert False

	# Parse memory
	result = VmState()
	splitted = process.stdout.split('\n')
	for line in splitted:
		m = re.match('([0-9a-f][0-9a-f]) ([0-9a-f][0-9a-f]) ([0-9a-f][0-9a-f]) ([0-9a-f][0-9a-f]) ([0-9a-f][0-9a-f]) ([0-9a-f][0-9a-f]) ([0-9a-f][0-9a-f]) ([0-9a-f][0-9a-f])  ([0-9a-f][0-9a-f]) ([0-9a-f][0-9a-f]) ([0-9a-f][0-9a-f]) ([0-9a-f][0-9a-f]) ([0-9a-f][0-9a-f]) ([0-9a-f][0-9a-f]) ([0-9a-f][0-9a-f]) ([0-9a-f][0-9a-f])', line)
		if m is not None:
			for i in range(16):
				result.memory += bytes.fromhex(m.group(i+1))
	return result

script_header = """
* = $f000
"""

script_footer = """
extra_tmpfield1 = $ea
extra_tmpfield2 = $eb
extra_tmpfield3 = $ec
extra_tmpfield4 = $ed
extra_tmpfield5 = $ee
extra_tmpfield6 = $ef
tmpfield1 = $f0
tmpfield2 = $f1
tmpfield3 = $f2
tmpfield4 = $f3
tmpfield5 = $f4
tmpfield6 = $f5
tmpfield7 = $f6
tmpfield8 = $f7
tmpfield9 = $f8
tmpfield10 = $f9
tmpfield11 = $fa
tmpfield12 = $fb
tmpfield13 = $fc
tmpfield14 = $fd
tmpfield15 = $fe
tmpfield16 = $ff

sha_w = $0400 ; $0400 to $04ff - One page, completely garbaged by sha256_sum routine
sha_msg = $0440 ; $0440 to $047f - Overlaps sha_w, will be overwriten by computations
sha_h = $0500 ; $0500 to $051f - 32 bytes hash result
sha_working_variables = $0520 ; $0520 to $053f
sha_length_lsb = $0540
sha_length_msb = $0541

#define CURRENT_BANK_NUMBER 0

#include "game/logic/sha.asm"
"""

def test_sha(script, expected):
	sha_h = 0x0500
	vm_state = execute_asm(script_header + script + script_footer)
	actual = vm_state.memory[sha_h:sha_h+0x20].hex()
	assert actual == expected, f"{actual} is not the expected hash ({expected})"

def test_sha_payload(payload):
	print(f"test_sha_payload({payload})")

	# Generate a script to hash payload
	script = f"""
	lda #<{len(payload)*8}
	sta sha_length_lsb
	lda #>{len(payload)*8}
	sta sha_length_msb

	ldx #{len(payload)}-1
	copy_payload:
		lda payload, x
		sta sha_msg, x
		dex
		bpl copy_payload
	jsr sha256_sum
	lda $ffff

	payload:
	"""
	script += '.byt {}\n'.format(', '.join([str(x) for x in payload]))

	# Test against python implementation
	expected = hashlib.sha256(payload).hexdigest()
	test_sha(script, expected)
	print("OK")

def test_sha_empty():
	script = """
	lda #0
	sta sha_length_lsb
	sta sha_length_msb
	jsr sha256_sum
	lda $ffff
	"""
	print("test_sha_empty")
	expected = 'e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855'
	test_sha(script, expected)
	print("OK")

# Tests
test_sha_empty()
test_sha_payload(b'hello-world')

# Fuzzing
if len(sys.argv) > 1 and sys.argv[1] == 'fuzz':
	import random
	for i in range(1000):
		payload_size = random.randint(1, 55)
		payload = bytes([random.randint(0,255) for i in range(payload_size)])
		test_sha_payload(payload)

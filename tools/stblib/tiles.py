#!/usr/bin/env python
import re

tile_byte = '%([01])([01])([01])([01])([01])([01])([01])([01])'
re_tileline = re.compile('\.byt %s, %s, %s, %s, %s, %s, %s, %s' % ((tile_byte,)*8))

class Tile:
	def __init__(self):
		self._representation = [
			[0,0,0,0,0,0,0,0],
			[0,0,0,0,0,0,0,0],
			[0,0,0,0,0,0,0,0],
			[0,0,0,0,0,0,0,0],
			[0,0,0,0,0,0,0,0],
			[0,0,0,0,0,0,0,0],
			[0,0,0,0,0,0,0,0],
			[0,0,0,0,0,0,0,0],
		]
		self._asm_line_multiplier = 0

	def __eq__(self, other):
		return self._representation == other._representation

	def __ne__(self, other):
		return not self.__eq__(other)

	def add_asm_line(self, line):
		m = re_tileline.match(line)
		if m is not None:
			self._asm_line_multiplier += 1
			if self._asm_line_multiplier > 2:
				self._asm_line_multiplier = 2
				raise Exception('Too much tile lines')

			for byte in range(8):
				for bit in range(8):
					group_index = 1 + byte*8 + bit
					self._representation[byte][bit] += int(m.group(group_index)) * self._asm_line_multiplier

	def is_complete(self):
		return self._asm_line_multiplier == 2

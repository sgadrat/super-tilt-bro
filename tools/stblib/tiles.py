#!/usr/bin/env python
from stblib import ensure
import re

tile_byte = '(%|\$)(([01][01][01][01][01][01][01][01])|([0-9a-f][0-9a-f]))'
re_tileline = re.compile('\.byt %s, %s, %s, %s, %s, %s, %s, %s' % ((tile_byte,)*8))

class Tile:
	def __init__(self, representation = None):
		if representation is None:
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
		else:
			self._representation = representation
		self._asm_line_multiplier = 0

	def __eq__(self, other):
		return self._representation == other._representation

	def __ne__(self, other):
		return not self.__eq__(other)

	def check(self):
		ensure(isinstance(self._representation, list))
		ensure(len(self._representation) == 8)
		for line in self._representation:
			ensure(isinstance(line, list))
			ensure(len(line) == 8)
			for pixel in line:
				ensure(isinstance(pixel, int))
				ensure(pixel >= 0)
				ensure(pixel <= 3)

	def flip_h(self):
		for line in self._representation:
			for to_swap in [(0,7), (1,6), (2,5), (3,4)]:
				saved = line[to_swap[0]]
				line[to_swap[0]] = line[to_swap[1]]
				line[to_swap[1]] = saved

	def flip_v(self):
		for to_swap in [(0,7), (1,6), (2,5), (3,4)]:
			saved = self._representation[to_swap[0]]
			self._representation[to_swap[0]] = self._representation[to_swap[1]]
			self._representation[to_swap[1]] = saved

	def add_asm_line(self, line):
		m = re_tileline.match(line)
		if m is not None:
			self._asm_line_multiplier += 1
			if self._asm_line_multiplier > 2:
				self._asm_line_multiplier = 2
				raise Exception('Too much tile lines')

			for byte in range(8):
				# Convert the byte from source line to a list of bits
				bits = []
				format_group_index = 1 + byte*4
				format_designer = m.group(format_group_index)
				byte_representation = m.group(format_group_index+1)

				bin_str = '00000000'
				if format_designer == '%':
					bin_str = byte_representation
				elif format_designer == '$':
					bin_str = bin(int(byte_representation, 16))[2:].zfill(8)
				else:
					assert False

				for bit_chr in bin_str:
					assert bit_chr == '0' or bit_chr == '1'
					bits.append(int(bit_chr))
				assert len(bits) == 8

				# Update representation with the current byte
				for bit in range(8):
					self._representation[byte][bit] += bits[bit] * self._asm_line_multiplier

	def is_complete(self):
		return self._asm_line_multiplier == 2

class Tileset:
	def __init__(self, tiles=None, tilenames=None, name=None):
		self.name = name
		self.tiles = tiles if tiles is not None else []
		self.tilenames = tilenames if tilenames is not None else []

	def check(self):
		ensure(isinstance(self.tiles, list))
		for tile in self.tiles:
			ensure(isinstance(tile, Tile))
			tile.check()

		ensure(isinstance(self.tilenames, list))
		for tilename in self.tilenames:
			ensure(isinstance(tilename, str))
			ensure(len(tilename) > 0)

		ensure(len(self.tilenames) == len(self.tiles))

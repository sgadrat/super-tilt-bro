from stblib.utils import uintasm8

class Nametable:
	class BytecodeTile:
		def __init__(self, tilenum = 0):
			self.tilenum = tilenum
			self.size = 1

		def serialize(self):
			return '{}, '.format(uintasm8(self.tilenum))

	class BytecodeZeros:
		def __init__(self, number = 1):
			self.size = number

		def serialize(self):
			if self.size == 1:
				return 'ZIPZ,'
			else:
				serialized = ''
				rest = self.size
				while rest > 255:
					serialized += 'ZIPNT_ZEROS({}), '.format(255)
					rest -= 255
				if rest == 1:
					serialized += 'ZIPZ,'
				else:
					serialized += 'ZIPNT_ZEROS({}), '.format(rest)

				line_size = self.size * 5
				if len(serialized) < line_size:
					serialized += ' ' * (line_size - len(serialized))

				return serialized

	def __init__(self, name = 'nametable', tilemap = None, attributes = None):
		self.name = name

		self.tilemap = tilemap
		if self.tilemap is None:
			self.tilemap = []
			for y in range(30):
				self.tilemap.append([0]*32)

		self.attributes = attributes
		if self.attributes is None:
			self.attributes = []
			for line_num in range(8):
				line = []
				for byte_num in range(8):
					line.append([0]*4)
				self.attributes.append(line)

	def set_tile(self, x, y, tile, attribute):
		self.tilemap[y][x] = tile
		self.set_attribute_for_tile(x, y, attribute)

	def set_attribute_for_tile(self, x, y, attribute):
		x = x // 2
		y = y // 2
		self.set_attribute(x, y, attribute)

	def set_attribute(self, x, y, attribute):
		line = y // 2
		byte = x // 2
		index = ((y+1) % 2) * 2 + (x+1) % 2
		self.attributes[line][byte][index] = attribute

	def serialize(self):
		serialized = 'nametable_{}:\n'.format(self.name)

		compressed = self.get_compressed_tilemap()
		serialized += '.byt '
		position = 0
		line_num = 0
		for bytecode in compressed:
			# Align the bytecode horizontally
			#  5 characters per tile "len('$XX, ') == 5" + 1 character every 4 tiles (to separate by attribute byte)
			horizontal_align = position * 5 + (position // 4)
			current_align = len(serialized) - serialized.rfind('.byt ') - len('.byt ')
			if current_align < horizontal_align:
				serialized += ' ' * (horizontal_align - current_align)

			# Serilize the bytecode
			position += bytecode.size
			serialized += bytecode.serialize()

			# Keep track of new lines
			while position >= 32:
				serialized = serialized.rstrip(', ')

				line_num += 1
				if line_num % 4 == 0:
					serialized += '\n;    -------------------  -------------------  -------------------  -------------------  -------------------  -------------------  -------------------  -------------------'

				serialized += '\n.byt '
				position -= 32
		serialized += '\n'

		serialized += 'nametable_{}_attributes:\n'.format(self.name)
		for attributes_line in self.attributes:
			serialized += '.byt '
			for attributes_byte in attributes_line:
				attribute_int = (attributes_byte[0] << 6) + (attributes_byte[1] << 4) + (attributes_byte[2] << 2) + attributes_byte[3]
				serialized += '{}, '.format(uintasm8(attribute_int))
			serialized = serialized.rstrip(', ')
			serialized += '\n'

		serialized += 'nametable_{}_end:\n.byt ZIPNT_END\n'.format(self.name)

		return serialized

	def get_compressed_tilemap(self):
		compressed = []
		nb_zero = 0
		for tile_line in self.tilemap:
			for tile in tile_line:
				if tile == 0:
					nb_zero += 1
				else:
					if nb_zero > 0:
						compressed.append(Nametable.BytecodeZeros(nb_zero))
						nb_zero = 0
					compressed.append(Nametable.BytecodeTile(tile))
		if nb_zero > 0:
			compressed.append(Nametable.BytecodeZeros(nb_zero))

		return compressed

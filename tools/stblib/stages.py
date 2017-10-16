import re

from stblib.utils import uintasm8, uintasm16
import stblib

RE_STAGE_NAME = re.compile('^[a-z_][a-z0-9_]*$')

class Platform:
	def __init__(self, left = 0, right = 16, top = 0, bottom = 16):
		self.left = left
		self.right = right
		self.top = top
		self.bottom = bottom

	def serialize(self):
		"""
		Serialize platform in a string using Super Tilt Bro's assembly format
		"""
		# Hack horizontal values are caped to [1, 254] instead of [0, 255] to avoid a bug in STB engine
		return 'PLATFORM({}, {}, {}, {}) ; left, right, top, bot\n'.format(
			uintasm8(max(1, self.left-7)), uintasm8(min(254, self.right)), uintasm8(self.top-15), uintasm8(self.bottom)
		)

class SmoothPlatform:
	def __init__(self, left = 0, right = 16, top = 0):
		self.left = left
		self.right = right
		self.top = top

	def serialize(self):
		"""
		Serialize platform in a string using Super Tilt Bro's assembly format
		"""
		# Hack horizontal values are caped to [1, 254] instead of [0, 255] to avoid a bug in STB engine
		return 'SMOOTH_PLATFORM({}, {}, {}) ; left, right, top\n'.format(
			uintasm8(max(1, self.left-7)), uintasm8(min(254, self.right)), uintasm8(self.top-15)
		)

class Stage:
	def __init__(self, name = 'stage', description = 'Stage', player_a_position = (32768, 32768), player_b_position = (32768, 32768), respawn_position = (32768, 32768), platforms = []):
		self.name = name
		self.description = description
		self.player_a_position = player_a_position
		self.player_b_position = player_b_position
		self.respawn_position = respawn_position
		self.platforms = platforms

	def check(self):
		"""
		Check that the stage is compatible with Super Tilt Bro's engine
		"""
		# Check stage's name
		if RE_STAGE_NAME.match(self.name) is None:
			raise Exception('invalid stage name')

		# Check that platforms are actual platforms and that hard ones are before smooth ones
		smooth = False
		for platform in self.platforms:
			if isinstance(platform, Platform):
				if smooth:
					raise Exception('Hard platform found after a smooth one')
			elif isinstance(platform, SmoothPlatform):
				smooth = True
			else:
				raise Exception('Unknown platform object')

	def generate_nametable(self):
		"""
		Generate a nametable corresponding to the stage's layout
		"""
		def set_tile(nametable, x, y, tile, attribute):
			nametable.tilemap[y][x] = tile
			nametable.set_attribute_for_tile(x, y, attribute)

		nametable = stblib.nametables.Nametable(name = 'stage_{}'.format(self.name))

		# Place platforms
		for platform in self.platforms:
			if isinstance(platform, Platform):
				# Grass
				y = (platform.top // 8) - 1
				begin = platform.left // 8
				end = (platform.right // 8) + 1
				for x in range(begin, end):
					set_tile(nametable, x, y, 0x23 + (x % 2), 0)
					set_tile(nametable, x, y+1, 0x25 + (x % 2), 0)
					set_tile(nametable, x, y+2, 0x03, 0)
				
				# Ground
				y += 3
				while y < platform.bottom // 8 and y < 30:
					for x in range(begin, end):
						set_tile(nametable, x, y, 0x01, 2)
					y += 1

			if isinstance(platform, SmoothPlatform):
				y = ((platform.top - 2) // 8)
				begin = platform.left // 8
				end = (platform.right // 8) + 1
				for x in range(begin, end):
					set_tile(nametable, x, y, 0xe8, 0)

		# Place static elements
		for offset in (0, 12):
			set_tile(nametable, 9+offset, 26, 0x27, 2)
			set_tile(nametable, 10+offset, 26, 0x28, 2)
			set_tile(nametable, 9+offset, 27, 0x29, 2)
			set_tile(nametable, 10+offset, 27, 0x2a, 2)
			for x in range(8, 12):
				set_tile(nametable, x+offset, 28, 0x1e, 2)

		return nametable

	def serialize(self):
		self.check()
		return self.serialize_layout() + '\n' + self.serialize_jump_tables()

	def serialize_layout(self):
		"""
		Serialize the stage's data in a string using Super Tilt Bro's assembly format
		"""
		serialized = 'stage_{}_data:\n'.format(self.name)
		serialized += 'STAGE_HEADER({}, {}, {}, {}, {}, {}) ; player_a_x, player_b_x, player_a_y, player_b_y, respawn_x, respawn_y\n'.format(
			uintasm16(self.player_a_position[0]), uintasm16(self.player_b_position[0]),
			uintasm16(self.player_a_position[1]), uintasm16(self.player_b_position[1]),
			uintasm16(self.respawn_position[0]), uintasm16(self.respawn_position[1])
		)

		serialized += 'stage_{}_platforms:\n'.format(self.name)
		for platform in self.platforms:
			serialized += platform.serialize()

		serialized += 'END_OF_STAGE\n'

		return serialized

	def serialize_jump_tables(self):
		"""
		Serialize the jump tables entries for this stage using Super Tilt Bro's assembly format
		"""
		serialized = 'stages_init_routine:\nRAW_VECTOR(stage_generic_init) ; {}\n\n'.format(self.description)
		serialized += 'stages_nametable:\nRAW_VECTOR(nametable_stage_{}) ; {}\n\n'.format(self.name, self.description)
		serialized += 'stages_data:\nRAW_VECTOR(stage_{}_data) ; {}\n'.format(self.name, self.description)
		return serialized

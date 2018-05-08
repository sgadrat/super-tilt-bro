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

class BackgroundMetaTile:
	class TileInfo:
		def __init__(self, x, y, tile_index, palette):
			self.x = x
			self.y = y
			self.tile_index = tile_index
			self.palette = palette

	def __init__(self, x, y, tile_name):
		self.x = x
		self.y = y
		self.tile_name = tile_name

	def getTilesInfo(self):
		"""
		Return info about tiles in the meta-tile.
		"""
		if self.tile_name == 'tree':
			return [
				BackgroundMetaTile.TileInfo(0, 0, 0x04, 1),
				BackgroundMetaTile.TileInfo(1, 0, 0x05, 1),
				BackgroundMetaTile.TileInfo(2, 0, 0x06, 1),
				BackgroundMetaTile.TileInfo(3, 0, 0x07, 1),

				BackgroundMetaTile.TileInfo(0, 1, 0x08, 1),
				BackgroundMetaTile.TileInfo(1, 1, 0x09, 1),
				BackgroundMetaTile.TileInfo(2, 1, 0x0a, 1),
				BackgroundMetaTile.TileInfo(3, 1, 0x0b, 1),

				BackgroundMetaTile.TileInfo(0, 2, 0x0c, 1),
				BackgroundMetaTile.TileInfo(1, 2, 0x0d, 1),
				BackgroundMetaTile.TileInfo(2, 2, 0x0e, 1),
				BackgroundMetaTile.TileInfo(3, 2, 0x0f, 1),

				BackgroundMetaTile.TileInfo(0, 3, 0x10, 1),
				BackgroundMetaTile.TileInfo(1, 3, 0x11, 1),
				BackgroundMetaTile.TileInfo(2, 3, 0x12, 1),
				BackgroundMetaTile.TileInfo(3, 3, 0x13, 1),
			]
		elif self.tile_name == 'cloud':
			return [
				BackgroundMetaTile.TileInfo(2, 0, 0x2b, 3),
				BackgroundMetaTile.TileInfo(3, 0, 0x2c, 3),

				BackgroundMetaTile.TileInfo(0, 1, 0x2d, 3),
				BackgroundMetaTile.TileInfo(1, 1, 0x2e, 3),
				BackgroundMetaTile.TileInfo(2, 1, 0x2f, 3),
				BackgroundMetaTile.TileInfo(3, 1, 0x30, 3),
			]
		elif self.tile_name == 'stones1':
			return [
				BackgroundMetaTile.TileInfo(0, 0, 0x1f, 2),
				BackgroundMetaTile.TileInfo(1, 0, 0x20, 2),

				BackgroundMetaTile.TileInfo(0, 1, 0x21, 2),
				BackgroundMetaTile.TileInfo(1, 1, 0x22, 2),
			]
		elif self.tile_name == 'stones2':
			return [
				BackgroundMetaTile.TileInfo(0, 0, 0x33, 2),
				BackgroundMetaTile.TileInfo(1, 0, 0x34, 2),

				BackgroundMetaTile.TileInfo(0, 1, 0x35, 2),
				BackgroundMetaTile.TileInfo(1, 1, 0x36, 2),
			]
		else:
			return []

class Stage:
	def __init__(self, name = 'stage', description = 'Stage', player_a_position = (32768, 32768), player_b_position = (32768, 32768), respawn_position = (32768, 32768), platforms = [], bg_metatiles = []):
		self.name = name
		self.description = description
		self.player_a_position = player_a_position
		self.player_b_position = player_b_position
		self.respawn_position = respawn_position
		self.platforms = platforms
		self.bg_metatiles = bg_metatiles

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
		nametable = stblib.nametables.Nametable(name = 'stage_{}'.format(self.name))

		# Place platforms
		for platform in self.platforms:
			if isinstance(platform, Platform):
				# Grass
				y = (platform.top // 8) - 1
				begin = platform.left // 8
				end = (platform.right // 8) + 1
				for x in range(begin, end):
					nametable.set_tile(x, y, 0x23 + (x % 2), 0)
					nametable.set_tile(x, y+1, 0x25 + (x % 2), 0)
					nametable.set_tile(x, y+2, 0x03, 0)
				
				# Ground
				y += 3
				while y < platform.bottom // 8 and y < 30:
					for x in range(begin, end):
						nametable.set_tile(x, y, 0x01, 2)
					y += 1

			if isinstance(platform, SmoothPlatform):
				y = ((platform.top - 2) // 8)
				begin = platform.left // 8
				end = (platform.right // 8) + 1
				for x in range(begin, end):
					nametable.set_tile(x, y, 0xe8, 0)

		# Place background enhancement metatiles
		for metatile in self.bg_metatiles:
			for tile_info in metatile.getTilesInfo():
				nametable.set_tile(
					tile_info.x + metatile.x,
					tile_info.y + metatile.y,
					tile_info.tile_index,
					tile_info.palette
				)

		# Place static elements
		for offset in (0, 12):
			nametable.set_tile(9+offset, 26, 0x27, 2)
			nametable.set_tile(10+offset, 26, 0x28, 2)
			nametable.set_tile(9+offset, 27, 0x29, 2)
			nametable.set_tile(10+offset, 27, 0x2a, 2)
			for x in range(8, 12):
				nametable.set_tile(x+offset, 28, 0x1e, 2)

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

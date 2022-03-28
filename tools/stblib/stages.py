import re

from stblib.utils import uintasm8, uintasm16
from stblib import ensure
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
			uintasm8(max(1, self.left-7)), uintasm8(min(254, self.right)), uintasm8(max(0, self.top-15)), uintasm8(self.bottom)
		)

	def check(self):
		# Check that platform is in the screen
		ensure(self.left >= 0, 'invalid platform position (left={} right={} top={} bot={}): left is before screen'.format(self.left, self.right, self.top, self.bottom))
		ensure(self.left <= 255, 'invalid platform position (left={} right={} top={} bot={}): left is after screen'.format(self.left, self.right, self.top, self.bottom))
		ensure(self.right >= 0, 'invalid platform position (left={} right={} top={} bot={}): right is before screen'.format(self.left, self.right, self.top, self.bottom))
		ensure(self.right <= 255, 'invalid platform position (left={} right={} top={} bot={}): right is after screen'.format(self.left, self.right, self.top, self.bottom))
		ensure(self.top >= 0, 'invalid platform position (left={} right={} top={} bot={}): top is above screen'.format(self.left, self.right, self.top, self.bottom))
		ensure(self.top <= 255, 'invalid platform position (left={} right={} top={} bot={}): top is below screen'.format(self.left, self.right, self.top, self.bottom))
		ensure(self.bottom >= 0, 'invalid platform position (left={} right={} top={} bot={}): bottom is above screen'.format(self.left, self.right, self.top, self.bottom))
		ensure(self.bottom <= 255, 'invalid platform position (left={} right={} top={} bot={}): bottom is below screen'.format(self.left, self.right, self.top, self.bottom))

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

	def check(self):
		# Check that platform is in the screen
		ensure(self.left >= 0, 'invalid smooth platform position (left={} right={} top={}): left is before screen'.format(self.left, self.right, self.top))
		ensure(self.left <= 255, 'invalid smooth platform position (left={} right={} top={}): left is after screen'.format(self.left, self.right, self.top))
		ensure(self.right >= 0, 'invalid smooth platform position (left={} right={} top={}): right is before screen'.format(self.left, self.right, self.top))
		ensure(self.right <= 255, 'invalid smooth platform position (left={} right={} top={}): right is after screen'.format(self.left, self.right, self.top))
		ensure(self.top >= 0, 'invalid smooth platform position (left={} right={} top={}): top is above screen'.format(self.left, self.right, self.top))
		ensure(self.top <= 255, 'invalid smooth platform position (left={} right={} top={}): top is below screen'.format(self.left, self.right, self.top))

class Target:
	def __init__(self, left=0, top=0):
		self.left = left
		self.top = top

	def check(self):
		ensure(self.left >= 0, 'invalid target position (left={} top={}): left is before the screen'.format(self.left, self.top))
		ensure(self.left <= 255, 'invalid target position (left={} top={}): left is after the screen'.format(self.left, self.top))
		ensure(self.top >= 0, 'invalid target position (left={} top={}): top is before the screen'.format(self.left, self.top))
		ensure(self.top <= 255, 'invalid target position (left={} top={}): top is below the screen'.format(self.left, self.top))

class Stage:
	def __init__(self, name = 'stage', description = 'Stage', player_a_position = (32768, 32768), player_b_position = (32768, 32768), respawn_position = (32768, 32768), platforms = None, targets = None):
		self.name = name
		self.description = description
		self.player_a_position = player_a_position
		self.player_b_position = player_b_position
		self.respawn_position = respawn_position
		self.platforms = platforms if platforms is not None else []
		self.targets = targets if targets is not None else []

	def check(self):
		"""
		Check that the stage is compatible with Super Tilt Bro's engine
		"""
		# Check stage's name
		ensure(RE_STAGE_NAME.match(self.name) is not None, 'invalid stage name')

		# Check that platforms are actual platforms and that hard ones are before smooth ones
		smooth = False
		for platform in self.platforms:
			ensure(platform.__class__.__name__ in ['Platform', 'SmoothPlatform'], 'Unknown platform object of type "{}"'.format(platform.__class__.__name__))
			if isinstance(platform, Platform):
				ensure(not smooth, 'Hard platform found after a smooth one')
			elif isinstance(platform, SmoothPlatform):
				smooth = True
			else:
				assert False # dead code, unknown types are checked by a former "ensure"

		# Check platforms
		for platform in self.platforms:
			platform.check()

		# Check targets
		MAX_TARGETS = 10
		ensure(len(self.targets) <= MAX_TARGETS, 'Stage has more targets than supported ({} while max is {})'.format(len(self.targets), MAX_TARGETS))
		for target in self.targets:
			target.check()

	def serialize(self):
		raise Exception('Obsolete, use stblib.asmformat.stages.stage_to_asm() instead')

	def serialize_layout(self):
		"""
		Serialize the stage's data in a string using Super Tilt Bro's assembly format
		"""
		serialized = '{}_data:\n'.format(self.name)
		serialized += 'STAGE_HEADER({}, {}, {}, {}, {}, {}) ; player_a_x, player_b_x, player_a_y, player_b_y, respawn_x, respawn_y\n'.format(
			uintasm16(self.player_a_position[0]), uintasm16(self.player_b_position[0]),
			uintasm16(self.player_a_position[1]), uintasm16(self.player_b_position[1]),
			uintasm16(self.respawn_position[0]), uintasm16(self.respawn_position[1])
		)

		serialized += '{}_platforms:\n'.format(self.name)
		for platform in self.platforms:
			serialized += platform.serialize()

		serialized += 'END_OF_STAGE\n'

		return serialized

	def serialize_jump_tables(self):
		"""
		Serialize the jump tables entries for this stage using Super Tilt Bro's assembly format
		"""
		# It was unmaintained and actually unusable since jump tables need a list of all stages to be generated correctly
		raise Exception('Obsolete, no replacement')

import re

from stblib.utils import uintasm8, uintasm16
from stblib import ensure
import stblib

RE_STAGE_NAME = re.compile('^[a-z_][a-z0-9_]*$')

class Exit:
	def __init__(self, left = 0, right = 8, top = 0, bottom = 8):
		self.left = left
		self.right = right
		self.top = top
		self.bottom = bottom

	def check(self):
		coord = '(left={} right={} top={}, bottom={})'.format(self.left, self.right, self.top, self.bottom)

		# Check that rectangle has positive width/height
		ensure(self.right > self.left, 'invalid exit area {}: thinner than one pixel'.format(coord))
		ensure(self.bottom > self.top, 'invalid exit area {}: smaller than one pixel'.format(coord))

		# Check that rectange is in the game coordinates
		for component in ['left', 'right', 'top', 'bottom']:
			ensure(getattr(self, component) >= -0x8000, 'invalid exit position {}: {} is out of game region'.format(coord, component))
			ensure(getattr(self, component) <= 0x7fff, 'invalid exit position {}: {} is out of game region'.format(coord, component))

class Platform:
	def __init__(self, left = 0, right = 16, top = 0, bottom = 16):
		self.left = left
		self.right = right
		self.top = top
		self.bottom = bottom

	def serialize(self):
		"""
		Serialize platform in a string using Super Tilt Bro's assembly format.
		"""
		# Convert logical platform coordinates to engine's quirks compatible coordinates
		left = self.left-8
		right = self.right+1 # +1 because the last pixel is passable, causing "walled" state
		top = self.top-16-1 # -1 to compensate for sprites being displayed one pixel bellow their position
		bottom = self.bottom+1-1 # -1 = passable last pixel // +1 = sprites displayed below their position

		# Hack horizontal values are caped to [1, 254] instead of [0, 255] to avoid a bug in STB engine
		return 'PLATFORM({}, {}, {}, {}) ; left, right, top, bot\n'.format(
			uintasm8(max(1, left)),
			uintasm8(min(254, right)),
			uintasm8(max(0, top)),
			uintasm8(bottom)
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
		# Convert logical platform coordinates to engine's quirks compatible coordinates
		left = self.left-8
		right = self.right+1 # +1 because the last pixel is passable, causing "walled" state
		top = self.top-16-1 # -1 to compensate for sprites being displayed one pixel bellow their position

		# Hack horizontal values are caped to [1, 254] instead of [0, 255] to avoid a bug in STB engine
		return 'SMOOTH_PLATFORM({}, {}, {}) ; left, right, top\n'.format(
			uintasm8(max(1, left)),
			uintasm8(min(254, right)),
			uintasm8(max(0, top))
		)

	def check(self):
		# Check that platform is in the screen
		ensure(self.left >= 0, 'invalid smooth platform position (left={} right={} top={}): left is before screen'.format(self.left, self.right, self.top))
		ensure(self.left <= 255, 'invalid smooth platform position (left={} right={} top={}): left is after screen'.format(self.left, self.right, self.top))
		ensure(self.right >= 0, 'invalid smooth platform position (left={} right={} top={}): right is before screen'.format(self.left, self.right, self.top))
		ensure(self.right <= 255, 'invalid smooth platform position (left={} right={} top={}): right is after screen'.format(self.left, self.right, self.top))
		ensure(self.top >= 0, 'invalid smooth platform position (left={} right={} top={}): top is above screen'.format(self.left, self.right, self.top))
		ensure(self.top <= 255, 'invalid smooth platform position (left={} right={} top={}): top is below screen'.format(self.left, self.right, self.top))

class Bumper:
	def __init__(self, left=0, right=0, top=0, bottom=0, damages=0, base=0, force=0, horizontal_direction=1, vertical_direction=1):
		self.left = left
		self.right = right
		self.top = top
		self.bottom = bottom
		self.damages = damages
		self.base = base
		self.force = force
		self.horizontal_direction = horizontal_direction
		self.vertical_direction = vertical_direction

	def serialize(self):
		"""
		Serialize bumper in a string using Super Tilt Bro's assembly format.
		"""
		# Convert logical coordinates to engine's quirks compatible coordinates
		left = self.left-8
		right = self.right+1 # +1 because the last pixel is passable, causing "walled" state
		top = self.top-16-1 # -1 to compensate for sprites being displayed one pixel bellow their position
		bottom = self.bottom+1-1 # -1 = passable last pixel // +1 = sprites displayed below their position

		# Hack horizontal values are caped to [1, 254] instead of [0, 255] to avoid a bug in STB engine
		return 'STAGE_BUMPER({}, {}, {}, {}, {}, {}, {}, {}, {}) ; left, right, top, bot, damages, base, force, horizontal_direction, vertical_direction\n'.format(
			uintasm8(max(1, left)),
			uintasm8(min(254, right)),
			uintasm8(max(0, top)),
			uintasm8(bottom),
			uintasm8(self.damages),
			uintasm16(self.base),
			uintasm8(self.force),
			uintasm8(0 if self.horizontal_direction >= 0 else 1), # Serialized data is the sign bit
			uintasm8(0 if self.vertical_direction >= 0 else 1), # Serialized data is the sign bit
		)

	def check(self):
		# Check that bumper is in the screen
		position = 'left={} right={} top={} bot={}'.format(self.left, self.right, self.top, self.bottom)
		ensure(self.left >= 0, 'invalid bumper position ({}): left is before screen'.format(position))
		ensure(self.left <= 255, 'invalid bumper position ({}): left is after screen'.format(position))
		ensure(self.right >= 0, 'invalid bumper position ({}): right is before screen'.format(position))
		ensure(self.right <= 255, 'invalid bumper position ({}): right is after screen'.format(position))
		ensure(self.top >= 0, 'invalid bumper position ({}): top is above screen'.format(position))
		ensure(self.top <= 255, 'invalid bumper position ({}): top is below screen'.format(position))
		ensure(self.bottom >= 0, 'invalid bumper position ({}): bottom is above screen'.format(position))
		ensure(self.bottom <= 255, 'invalid bumper position ({}): bottom is below screen'.format(position))

		# Check that parameters are in expected range
		ensure(0 <= self.damages and self.damages <= 0b1111, f'invalid bumper damages ({self.damages} does not fit in 4 bits)')
		ensure(0 <= self.base and self.base < 0x8000, f'invalid bumper base power ({self.base} does not fit in 15 bits)')
		ensure(0 <= self.force and self.force < 0x80, f'invalid bumper force power ({self.force} does not fit in 7 bits)')
		ensure(self.horizontal_direction in [-1, 1], f'invalid horizontal direction ({self.horizontal_direction} must be 1, or -1)')
		ensure(self.vertical_direction in [-1, 1], f'invalid vertical direction ({self.vertical_direction} must be 1, or -1)')

class Target:
	def __init__(self, left=0, top=0):
		self.left = left
		self.top = top

	def check(self):
		ensure(self.left >= 0, 'invalid target position (left={} top={}): left is before the screen'.format(self.left, self.top))
		ensure(self.left <= 255, 'invalid target position (left={} top={}): left is after the screen'.format(self.left, self.top))
		ensure(self.top >= 0, 'invalid target position (left={} top={}): top is before the screen'.format(self.left, self.top))
		ensure(self.top <= 255, 'invalid target position (left={} top={}): top is below the screen'.format(self.left, self.top))

class Waypoints:
	"""
	A list of waypoints

	Each waypoint has a position and a speed the object should have starting from this waypoint.
	"""
	def __init__(self, name='', positions=None, speeds=None):
		self.name = name
		self.positions = positions if positions is not None else []
		self.speeds = speeds if speeds is not None else []

	def add_waypoint(self, x, y, horizontal_speed, vertical_speed):
		self.positions.append({'x': x, 'y': y})
		self.speeds.append({'h': horizontal_speed, 'v': vertical_speed})

	def check(self):
		# Check that name conforms to constraints (valid label)
		ensure(re.match('^[a-z_][a-z0-9_]*$', self.name) is not None, f'waypoint name is not a valid label: "{self.name}"')

		# Check that positions list is well formated
		ensure(isinstance(self.positions, list), 'positions must be a list of {"x": uint8, "y": uint8}')
		for pos_index in range(len(self.positions)):
			pos = self.positions[pos_index]
			ensure(isinstance(pos, dict), f'position of waypoint #{pos_index} is not a dict: "{pos}"')
			ensure('x' in pos and 'y' in pos, f'position of waypoint #{pos_index} misses x/y coordinates')
			x = pos['x']
			y = pos['y']
			ensure(isinstance(x, int), f'position of waypoint #{pos_index} has non-integer X component: "{x}"')
			ensure(isinstance(y, int), f'position of waypoint #{pos_index} has non-integer Y component: "{y}"')
			ensure(0 <= x and x <= 255, f'X position of waypoint #{pos_index} must be in uint8 range: {x}')
			ensure(0 <= y and y <= 255, f'Y position of waypoint #{pos_index} must be in uint8 range: {y}')

		# Check that speeds list is well formated
		ensure(isinstance(self.speeds, list), 'speeds must be a list of {"h": int8, "v": int8}')
		for speed_index in range(len(self.speeds)):
			speed = self.speeds[speed_index]
			ensure(isinstance(speed, dict), f'speed of waypoint #{speed_index} is not a dict: "{speed}"')
			ensure('h' in speed and 'v' in speed, f'speed of waypoint #{speed_index} misses h/v components')
			h = speed['h']
			v = speed['v']
			ensure(isinstance(h, int), f'speed of waypoint #{speed_index} has non-integer H component: "{h}"')
			ensure(isinstance(v, int), f'speed of waypoint #{speed_index} has non-integer V component: "{v}"')
			ensure(-128 <= h and h <= 127, f'H speed of waypoint #{pos_index} must be in int8 range: {h}')
			ensure(-128 <= v and v <= 127, f'V speed of waypoint #{pos_index} must be in int8 range: {v}')

		# Check consistency between positions and speeds
		ensure(len(self.positions) == len(self.speeds), f'number of positions mismatch number of speeds ({len(self.positions)} positions for {len(self.speeds)} speeds)')

		# Check that all speeds allow to reach the next waypoint
		for wp_index in range(len(self.positions)):
			next_wp_index = (wp_index + 1) % len(self.positions)
			wp = {'pos': self.positions[wp_index], 'speed': self.speeds[wp_index]}
			next_wp = {'pos': self.positions[next_wp_index], 'speed': self.speeds[next_wp_index]}

			distance_h = next_wp['pos']['x'] - wp['pos']['x']
			distance_v = next_wp['pos']['y'] - wp['pos']['y']
			ensure(
				(distance_h == 0 and wp['speed']['h'] == 0) or distance_h % wp['speed']['h'] == 0,
				f'object at waypoint #{wp_index} will miss #{next_wp_index}: horizontal distance is {distance_h}, speed is {wp["speed"]["h"]}'
			)
			ensure(
				(distance_v == 0 and wp['speed']['v'] == 0) or distance_v % wp['speed']['v'] == 0,
				f'object at waypoint #{wp_index} will miss #{next_wp_index}: vertical distance is {distance_v}, speed is {wp["speed"]["v"]}'
			)

class Stage:
	def __init__(self, name = 'stage', description = 'Stage', player_a_position = (32768, 32768), player_b_position = (32768, 32768), respawn_position = (32768, 32768), platforms = None, targets = None):
		self.name = name
		self.description = description
		self.player_a_position = player_a_position
		self.player_b_position = player_b_position
		self.respawn_position = respawn_position
		self.platforms = platforms if platforms is not None else [] #TODO should be renamed in "elements" or "layout"
		self.targets = targets if targets is not None else []

	def layout_size(self):
		"""
		Compute the size of the stage's layout (header + platforms) in binary format (in bytes)
		"""
		STAGE_HEADER_SIZE = 6 * 2
		STAGE_ELEMENT_SIZE = 9
		END_OF_STAGE_MARKER_SIZE = 1
		return STAGE_HEADER_SIZE + STAGE_ELEMENT_SIZE * len(self.platforms) + END_OF_STAGE_MARKER_SIZE

	def check(self):
		"""
		Check that the stage is compatible with Super Tilt Bro's engine
		"""
		# Check stage's name
		ensure(RE_STAGE_NAME.match(self.name) is not None, 'invalid stage name')

		# Check that platforms are actual platforms and that hard ones are before smooth ones
		smooth = False
		for platform in self.platforms:
			ensure(platform.__class__.__name__ in ['Platform', 'SmoothPlatform', 'Bumper'], 'Unknown platform object of type "{}"'.format(platform.__class__.__name__))
			if isinstance(platform, Platform) or isinstance(platform, Bumper):
				ensure(not smooth, 'Hard platform found after a smooth one')
			elif isinstance(platform, SmoothPlatform):
				smooth = True
			else:
				assert False # dead code, unknown types are checked by a former "ensure"

		# Check platforms
		for platform in self.platforms:
			platform.check()

		# Check that we don't mix incompatible elements
		ensure(len(self.targets) == 0 or self.exit is None, 'Impossible stage configuration: exit and targets cannot be in the same stage')

		# Check targets
		MAX_TARGETS = 10
		ensure(len(self.targets) <= MAX_TARGETS, 'Stage has more targets than supported ({} while max is {})'.format(len(self.targets), MAX_TARGETS))
		for target in self.targets:
			target.check()

		# Check exit
		if self.exit is not None:
			self.exit.check()

		# Check that stage fits in is reserved memory area
		max_size = 0x80
		ensure(self.layout_size() <= max_size, 'Stage is bigger than allowed by the engine ({} bytes while max is {} bytes)'.format(self.layout_size(), max_size))

	def serialize(self):
		raise Exception('Obsolete, use stblib.asmformat.stages.stage_to_asm() instead')

	def serialize_layout(self, visibility=''):
		"""
		Serialize the stage's data in a string using Super Tilt Bro's assembly format
		"""
		serialized = '{}{}_data:\n'.format(visibility, self.name)
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

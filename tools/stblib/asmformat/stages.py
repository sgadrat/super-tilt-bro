#!/usr/bin/env python

import stblib.asmformat
import stblib.stages
from stblib.utils import asmint, asmsint8, asmsint16, intasm8, intasm16, uintasm8, uintasm16

def stage_to_asm(stage, visibility=''):
	"""
	Serialize a stage to assembly.
	"""
	serialized = ''

	# Header specific to Break the Target mode
	if len(stage.targets) != 0 or stage.exit is not None:
		serialized += '{}{}_data_header:\n'.format(visibility, stage.name)

		if len(stage.targets) != 0:
			for target in stage.targets:
				top = max(0, target.top - 1) # -1 to compensate for sprites being displayed one pixel bellow their position
				serialized += 'ARCADE_TARGET({}, {})\n'.format(uintasm8(target.left), uintasm8(top))
			for x in range(len(stage.targets), 10):
				serialized += 'ARCADE_TARGET($fe, $fe)\n'

		if stage.exit is not None:
			serialized += exit_to_asm(stage.exit)

	# Common stage data
	serialized += '{}{}_data:\n'.format(visibility, stage.name)
	serialized += 'STAGE_HEADER({}, {}, {}, {}, {}, {}) ; player_a_x, player_b_x, player_a_y, player_b_y, respawn_x, respawn_y\n'.format(
		uintasm16(stage.player_a_position[0]), uintasm16(stage.player_b_position[0]),
		uintasm16(stage.player_a_position[1]), uintasm16(stage.player_b_position[1]),
		uintasm16(stage.respawn_position[0]), uintasm16(stage.respawn_position[1])
	)

	serialized += '{}_platforms:\n'.format(stage.name)
	for platform in stage.platforms:
		serialized += stblib.asmformat.to_asm(platform)

	serialized += 'END_OF_STAGE\n'

	return serialized

def platform_to_asm(platform, visibility=''):
	"""
	Serialize platform in a string using Super Tilt Bro's assembly format.
	"""
	# Convert logical platform coordinates to engine's quirks compatible coordinates
	left = platform.left-8
	right = platform.right+1 # +1 because the last pixel is passable, causing "walled" state
	top = platform.top-16-1 # -1 to compensate for sprites being displayed one pixel bellow their position
	bottom = platform.bottom+1-1 # -1 = passable last pixel // +1 = sprites displayed below their position

	# Hack horizontal values are caped to [1, 254] instead of [0, 255] to avoid a bug in STB engine
	return 'PLATFORM({}, {}, {}, {}) ; left, right, top, bot\n'.format(
		uintasm8(max(1, left)),
		uintasm8(min(254, right)),
		uintasm8(max(0, top)),
		uintasm8(bottom)
	)

def oosplatform_to_asm(platform, visibility=''):
	"""
	Serialize platform in a string using Super Tilt Bro's assembly format.
	"""
	# Convert logical platform coordinates to engine's quirks compatible coordinates
	left = platform.left-8
	right = platform.right+1 # +1 because the last pixel is passable, causing "walled" state
	top = platform.top-16-1 # -1 to compensate for sprites being displayed one pixel bellow their position
	bottom = platform.bottom+1-1 # -1 = passable last pixel // +1 = sprites displayed below their position

	return 'PLATFORM({}, {}, {}, {}) ; left, right, top, bot\n'.format(
		intasm16(left),
		intasm16(right),
		intasm16(top),
		intasm16(bottom)
	)

def smoothplatform_to_asm(platform, visibility=''):
	"""
	Serialize platform in a string using Super Tilt Bro's assembly format
	"""
	# Convert logical platform coordinates to engine's quirks compatible coordinates
	left = platform.left-8
	right = platform.right+1 # +1 because the last pixel is passable, causing "walled" state
	top = platform.top-16-1 # -1 to compensate for sprites being displayed one pixel bellow their position

	# Hack horizontal values are caped to [1, 254] instead of [0, 255] to avoid a bug in STB engine
	return 'SMOOTH_PLATFORM({}, {}, {}) ; left, right, top\n'.format(
		uintasm8(max(1, left)),
		uintasm8(min(254, right)),
		uintasm8(max(0, top))
	)

def bumper_to_asm(platform, visibility=''):
	"""
	Serialize bumper in a string using Super Tilt Bro's assembly format.
	"""
	# Convert logical coordinates to engine's quirks compatible coordinates
	left = platform.left-8
	right = platform.right+1 # +1 because the last pixel is passable, causing "walled" state
	top = platform.top-16-1 # -1 to compensate for sprites being displayed one pixel bellow their position
	bottom = platform.bottom+1-1 # -1 = passable last pixel // +1 = sprites displayed below their position

	# Hack horizontal values are caped to [1, 254] instead of [0, 255] to avoid a bug in STB engine
	return 'STAGE_BUMPER({}, {}, {}, {}, {}, {}, {}, {}, {}) ; left, right, top, bot, damages, base, force, horizontal_direction, vertical_direction\n'.format(
		uintasm8(max(1, left)),
		uintasm8(min(254, right)),
		uintasm8(max(0, top)),
		uintasm8(bottom),
		uintasm8(platform.damages),
		uintasm16(platform.base),
		uintasm8(platform.force),
		uintasm8(0 if platform.horizontal_direction >= 0 else 1), # Serialized data is the sign bit
		uintasm8(0 if platform.vertical_direction >= 0 else 1), # Serialized data is the sign bit
	)

def exit_to_asm(ex, visibility=''):
	return 'ARCADE_EXIT({}, {}, {}, {}) ; left, right, top, bot\n'.format(
		intasm16(ex.left), intasm16(ex.right), intasm16(ex.top), intasm16(ex.bottom)
	)

def waypoints_to_asm(waypoints, visibility=''):
	serialized = ''

	# Header
	serialized += '{}{}:\n'.format(visibility, waypoints.name)
	serialized += '.byt {} ; number of waypoints\n'.format(len(waypoints.positions))

	# Speed tables
	serialized += '.byt '
	serialized += ', '.join([intasm8(speed['h']) for speed in waypoints.speeds])
	serialized += ' ; velocity H\n'

	serialized += '.byt '
	serialized += ', '.join([intasm8(speed['v']) for speed in waypoints.speeds])
	serialized += ' ; velocity V\n'

	# End position table
	#  Note that this is the end position of the current waypoint, so actually the position of the next waypoint
	def next_idx(i):
		return (i + 1) % len(waypoints.positions)
	def next_pos(i):
		return waypoints.positions[next_idx(i)]

	serialized += '.byt '
	serialized += ', '.join([uintasm8(next_pos(pos_idx)['x']) for pos_idx in range(len(waypoints.positions))])
	serialized += " ; waypoint's end position X\n"

	serialized += '.byt '
	serialized += ', '.join([uintasm8(next_pos(pos_idx)['y']) for pos_idx in range(len(waypoints.positions))])
	serialized += " ; waypoint's end position Y\n"

	# Size check
	serialized += '#if * - {} > 256\n'.format(waypoints.name)
	serialized += '#error waypoints list too big\n'
	serialized += '#endif\n'

	return serialized

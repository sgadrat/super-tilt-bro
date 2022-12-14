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

	serialized += '; Platforms\n'
	for platform in stage.platforms:
		serialized += stblib.asmformat.to_asm(platform)

	serialized += 'END_OF_STAGE\n'

	# Illustration
	if stage.illustration is not None:
		serialized += '\n; Illustration\n'
		serialized += '.(\n'
		serialized += 'BAC = 0\n'
		serialized += 'SMO = TILE_MENU_CHAR_SELECT_STAGE_SMOOTH\n'
		serialized += 'PLT = TILE_MENU_CHAR_SELECT_STAGE_PLATFORM\n'
		serialized += 'C_A = TILE_CHAR_A\n'
		serialized += 'C_B = C_A + 1\n'
		serialized += 'C_C = C_A + 2\n'
		serialized += 'C_D = C_A + 3\n'
		serialized += 'C_E = C_A + 4\n'
		serialized += 'C_F = C_A + 5\n'
		serialized += 'C_G = C_A + 6\n'
		serialized += 'C_H = C_A + 7\n'
		serialized += 'C_I = C_A + 8\n'
		serialized += 'C_J = C_A + 9\n'
		serialized += 'C_K = C_A + 10\n'
		serialized += 'C_L = C_A + 11\n'
		serialized += 'C_M = C_A + 12\n'
		serialized += 'C_N = C_A + 13\n'
		serialized += 'C_O = C_A + 14\n'
		serialized += 'C_P = C_A + 15\n'
		serialized += 'C_Q = C_A + 16\n'
		serialized += 'C_R = C_A + 17\n'
		serialized += 'C_S = C_A + 18\n'
		serialized += 'C_T = C_A + 19\n'
		serialized += 'C_U = C_A + 20\n'
		serialized += 'C_V = C_A + 21\n'
		serialized += 'C_W = C_A + 22\n'
		serialized += 'C_X = C_A + 23\n'
		serialized += 'C_Y = C_A + 24\n'
		serialized += 'C_Z = C_A + 25\n'
		serialized += '\n'
		serialized += '{}{}_illustration:\n'.format(visibility, stage.name)
		for x in range(len(stage.illustration[0])):
			serialized += '.byt '
			for y in range(len(stage.illustration)):
				entry = stage.illustration[y][x]

				translated_entry = None
				if isinstance(entry, int):
					translated_entry = ['BAC', 'SMO', 'PLT'][entry]
				elif isinstance(entry, str):
					if entry == ' ':
						translated_entry = 'BAC'
					else:
						translated_entry = 'C_{}'.format(entry.upper())
				assert translated_entry is not None, f'unable to translate entry "{entry}", should have been detected by stage.check()'

				serialized += '{}{}'.format(
					', ' if y != 0 else '',
					translated_entry
				)

			serialized += '\n'

		serialized += '.)\n'

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

	return 'OOS_PLATFORM({}, {}, {}, {}) ; left, right, top, bot\n'.format(
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
	horizontal_direction = 0 if platform.horizontal_direction >= 0 else 1
	horizontal_nullified = 1 if abs(platform.horizontal_direction) != 1 else 0
	horizontal_byte = (horizontal_nullified << 1) + horizontal_direction

	vertical_direction = 0 if platform.vertical_direction >= 0 else 1
	vertical_nullified = 1 if abs(platform.vertical_direction) != 1 else 0
	vertical_byte = (vertical_nullified << 1) + vertical_direction

	return 'STAGE_BUMPER({}, {}, {}, {}, {}, {}, {}, {}, {}) ; left, right, top, bot, damages, base, force, horizontal_direction, vertical_direction\n'.format(
		uintasm8(max(1, left)),
		uintasm8(min(254, right)),
		uintasm8(max(0, top)),
		uintasm8(bottom),
		uintasm8(platform.damages),
		uintasm16(platform.base),
		uintasm8(platform.force),
		uintasm8(horizontal_byte),
		uintasm8(vertical_byte)
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

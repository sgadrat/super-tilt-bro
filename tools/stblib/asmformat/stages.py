#!/usr/bin/env python

import stblib.stages
from stblib.utils import asmint, asmsint8, asmsint16, intasm8, intasm16, uintasm8

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
	serialized += stage.serialize_layout(visibility=visibility)

	return serialized

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

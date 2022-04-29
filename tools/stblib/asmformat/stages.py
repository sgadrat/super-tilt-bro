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
				serialized += 'ARCADE_TARGET({}, {})\n'.format(uintasm8(target.left), uintasm8(target.top))
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

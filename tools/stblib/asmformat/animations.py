#!/usr/bin/env python

import re
import stblib.animations
from stblib.utils import asmint, asmsint8, asmsint16
import sys

RE_ANIM_LABEL = re.compile('(?P<name>anim_[a-z_]+):')
RE_ANIM_FRAME_BEGIN = re.compile('ANIM_FRAME_BEGIN\((?P<duration>[$%0-9a-fA-F]+)\)')
RE_ANIM_HURTBOX = re.compile('ANIM_HURTBOX\((?P<left>[$%0-9a-fA-F]+),( *)(?P<right>[$%0-9a-fA-F]+),( *)(?P<top>[$%0-9a-fA-F]+),( *)(?P<bottom>[$%0-9a-fA-F]+)\)')
RE_ANIM_HITBOX = re.compile('ANIM_HITBOX\((?P<enabled>[$%0-9a-fA-F]+),( *)(?P<damages>[$%0-9a-fA-F]+),( *)(?P<base_h>[$%0-9a-fA-F]+),( *)(?P<base_v>[$%0-9a-fA-F]+),( *)(?P<force_h>[$%0-9a-fA-F]+),( *)(?P<force_v>[$%0-9a-fA-F]+),( *)(?P<left>[$%0-9a-fA-F]+),( *)(?P<right>[$%0-9a-fA-F]+),( *)(?P<top>[$%0-9a-fA-F]+),( *)(?P<bottom>[$%0-9a-fA-F]+)\)')
RE_ANIM_SPRITE = re.compile('ANIM_SPRITE(?P<type>_FOREGROUND)?\((?P<y>[$%0-9a-fA-F]+), (?P<tile>[$%0-9a-fA-Z_]+), (?P<attr>[$%0-9a-fA-F]+), (?P<x>[$%0-9a-fA-F]+)\)')
RE_ANIM_END = re.compile('ANIM_ANIMATION_END')

def parse_animations(anim_file):
	"""
	Parse asm animations.

	anim_file file-like object containing animations in assembly format
	return a list of stblib.animations.Animation
	"""
	animations = []

	current_anim = None
	for line in anim_file:
		line = line[:-1]

		m = RE_ANIM_LABEL.match(line)
		if m is not None and current_anim is None:
			current_anim = stblib.animations.Animation(name=m.group('name'))

		m = RE_ANIM_FRAME_BEGIN.match(line)
		if m is not None and current_anim is not None:
			current_anim.frames.append(stblib.animations.Frame(duration=asmint(m.group('duration'))))

		m = RE_ANIM_HURTBOX.match(line)
		if m is not None and current_anim is not None and len(current_anim.frames) > 0:
			current_anim.frames[-1].hurtbox = stblib.animations.Hurtbox(
				asmint(m.group('left')), asmint(m.group('right')), asmint(m.group('top')), asmint(m.group('bottom'))
			)

		m = RE_ANIM_HITBOX.match(line)
		if m is not None and current_anim is not None and len(current_anim.frames) > 0:
			current_anim.frames[-1].hitbox = stblib.animations.Hitbox(
				enabled = asmint(m.group('enabled')) != 0,
				damages = asmint(m.group('damages')),
				base_h = asmsint16(m.group('base_h')),
				base_v = asmsint16(m.group('base_v')),
				force_h = asmsint16(m.group('force_h')),
				force_v = asmsint16(m.group('force_v')),
				left = asmint(m.group('left')),
				right = asmint(m.group('right')),
				top = asmint(m.group('top')),
				bottom = asmint(m.group('bottom'))
			)

		m = RE_ANIM_SPRITE.match(line)
		if m is not None and current_anim is not None and len(current_anim.frames) > 0:
			current_anim.frames[-1].sprites.append(stblib.animations.Sprite(
				y=asmsint8(m.group('y')),
				tile=m.group('tile'),
				attr=asmint(m.group('attr')),
				x=asmsint8(m.group('x')),
				foreground=(m.group('type') == '_FOREGROUND')
			))

		m = RE_ANIM_END.match(line)
		if m is not None and current_anim is not None:
			# Store the animation
			animations.append(current_anim)
			current_anim = None

	return animations

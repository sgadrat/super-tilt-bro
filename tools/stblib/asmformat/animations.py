#!/usr/bin/env python

import re
import stblib.animations
import stblib.asmformat
from stblib.utils import asmint, asmsint8, asmsint16, intasm8, intasm16, uintasm8
import sys

def animation_to_asm(animation, visibility=''):
	"""
	Serialize animation to assembly.
	"""
	serialized = '{}{}:\n'.format(visibility, animation.name)
	frame_num = 1
	for frame in animation.frames:
		serialized += '; Frame {}\n'.format(frame_num)
		serialized += frame_to_asm(frame)
		frame_num += 1
	serialized += '; End of animation\n'
	serialized += 'ANIM_ANIMATION_END\n'
	serialized += '#print {}\n'.format(animation.name)
	return serialized

def frame_to_asm(frame, visibility=''):
	# Frame begin
	serialized = 'ANIM_FRAME_BEGIN(%d)\n' % frame.duration

	# Hurtbox
	if frame.hurtbox is not None:
		serialized += 'ANIM_HURTBOX(%s, %s, %s, %s)\n' % (
			intasm8(frame.hurtbox.left),
			intasm8(frame.hurtbox.right),
			intasm8(frame.hurtbox.top),
			intasm8(frame.hurtbox.bottom)
		)
	else:
		serialized += 'ANIM_NULL_HURTBOX\n'

	# Hitbox
	if frame.hitbox is not None:
		serialized += stblib.asmformat.to_asm(frame.hitbox)
	else:
		serialized += 'ANIM_NULL_HITBOX\n'

	# Foreground sprites
	foreground_sprites = frame.foreground_sprites()
	serialized += 'ANIM_SPRITE_FOREGROUND_COUNT(%d)\n' % len(foreground_sprites)
	for sprite in foreground_sprites:
		serialized += sprite_to_asm(sprite)

	# Normal sprites
	normal_sprites = frame.normal_sprites()
	serialized += 'ANIM_SPRITE_NORMAL_COUNT(%d)\n' % len(normal_sprites)
	for sprite in normal_sprites:
		serialized += sprite_to_asm(sprite)

	return serialized

def directhitbox_to_asm(hitbox, visibility=''):
	return 'ANIM_DIRECT_HITBOX(%s, %s, %s, %s, %s, %s, %s, %s, %s, %s)\n' % (
		'$01' if hitbox.enabled else '$00',
		uintasm8(hitbox.damages),
		intasm16(hitbox.base_h),
		intasm16(hitbox.base_v),
		intasm16(hitbox.force_h),
		intasm16(hitbox.force_v),
		intasm8(hitbox.left),
		intasm8(hitbox.right),
		intasm8(hitbox.top),
		intasm8(hitbox.bottom)
	)

def customhitbox_to_asm(hitbox, visibility=''):
	return 'ANIM_CUSTOM_HITBOX(%s, %s, %s, %s, %s, %s)\n' % (
		'$02' if hitbox.enabled else '$00',
		intasm8(hitbox.left),
		intasm8(hitbox.right),
		intasm8(hitbox.top),
		intasm8(hitbox.bottom),
		hitbox.routine
	)

def sprite_to_asm(sprite, visibility=''):
	return 'ANIM_SPRITE(%s, %s, %s, %s)\n' % (
		intasm8(sprite.y), sprite.tile, uintasm8(sprite.attr), intasm8(sprite.x)
	)

def frame_bin_size(frame):
	"""
	Return the size of an assembled binary frame.
	"""
	return (
		1 + # ANIM_FRAME_BEGIN(duration)
		4 + # ANIM_HURTBOX
		11 + # ANIM_HITBOX
		1 + # ANIM_SPRITE_FOREGROUND_COUNT
		1 + # ANIM_SPRITE_NORMAL_COUNT
		(len(frame.sprites) * 5) # ANIM_SPRITE
	)

RE_ANIM_LABEL = re.compile('(?P<name>([a-z]+_)?anim_[a-z_]+):')
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
	raise Exception('TODO: asm format of animations changed, update parse_animations()')
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
				asmsint8(m.group('left')), asmsint8(m.group('right')), asmsint8(m.group('top')), asmsint8(m.group('bottom'))
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
				left = asmsint8(m.group('left')),
				right = asmsint8(m.group('right')),
				top = asmsint8(m.group('top')),
				bottom = asmsint8(m.group('bottom'))
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

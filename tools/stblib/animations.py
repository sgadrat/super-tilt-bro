from stblib.utils import intasm8, intasm16, uintasm8

class Hurtbox:
	def __init__(self, left=0, right=0, top=0, bottom=0):
		self.left = left
		self.right = right
		self.top = top
		self.bottom = bottom

	def serialize(self):
		return 'ANIM_HURTBOX(%s, %s, %s, %s)\n' % (intasm8(self.left), intasm8(self.right), intasm8(self.top), intasm8(self.bottom))

class Hitbox:
	def __init__(self, enabled=False, damages=0, base_h=0, base_v=0, force_h=0, force_v=0, left=0, right=0, top=0, bottom=0):
		self.enabled = enabled
		self.damages = damages
		self.base_h = base_h
		self.base_v = base_v
		self.force_h = force_h
		self.force_v = force_v
		self.left = left
		self.right = right
		self.top = top
		self.bottom = bottom

	def serialize(self):
		return 'ANIM_HITBOX(%s, %s, %s, %s, %s, %s, %s, %s, %s, %s)\n' % (
			'$01' if self.enabled else '$00', uintasm8(self.damages), intasm16(self.base_h), intasm16(self.base_v), intasm16(self.force_h), intasm16(self.force_v), intasm8(self.left), intasm8(self.right), intasm8(self.top), intasm8(self.bottom)
		)

class Sprite:
	def __init__(self, y=0, tile='', attr=0, x=0, foreground=False):
		self.y = y
		self.tile = tile
		self.attr = attr
		self.x = x
		self.foreground = foreground

	def serialize(self):
		return 'ANIM_SPRITE%s(%s, %s, %s, %s)\n' % ('_FOREGROUND' if self.foreground else '',intasm8(self.y), self.tile, uintasm8(self.attr), intasm8(self.x))

class Frame:
	def __init__(self, duration=0, hurtbox=None, hitbox=None):
		self.duration = duration
		self.hurtbox = hurtbox
		self.hitbox = hitbox
		self.sprites = []

	def serialize(self):
		serialized = 'ANIM_FRAME_BEGIN(%d)\n' % self.duration
		if self.hurtbox is not None:
			serialized += self.hurtbox.serialize()
		if self.hitbox is not None:
			serialized += self.hitbox.serialize()
		for sprite in self.sprites:
			serialized += sprite.serialize()
		serialized += 'ANIM_FRAME_END\n'
		return serialized

	def flip(self):
		if self.hurtbox is not None:
			width = self.hurtbox.right - self.hurtbox.left
			self.hurtbox.right = -self.hurtbox.left - 1 + 8
			self.hurtbox.left = self.hurtbox.right - width
		if self.hitbox is not None:
			width = self.hitbox.right - self.hitbox.left
			self.hitbox.right = -self.hitbox.left - 1 + 8
			self.hitbox.left = self.hitbox.right - width
			self.hitbox.base_h *= -1
			self.hitbox.force_h *= -1
		for sprite in self.sprites:
			sprite.x = -sprite.x - 8 + 8
			sprite.attr ^= 0x40
		self.sprites.reverse()

class Animation:
	def __init__(self, name='', frames=None):
		self.name = name
		if frames is not None:
			self.frames = frames
		else:
			self.frames = []

	def serialize(self):
		serialized = 'anim_{}:\n'.format(self.name)
		frame_num = 1
		for frame in self.frames:
			serialized += '; Frame {}\n'.format(frame_num)
			serialized += frame.serialize()
			frame_num += 1
		serialized += '; End of animation\n'
		serialized += 'ANIM_ANIMATION_END\n'
		return serialized

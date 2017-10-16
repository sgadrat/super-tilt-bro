from stblib.utils import intasm8, intasm16

class Hurtbox:
	def __init__(self, left=0, right=0, top=0, bottom=0):
		self.left = left
		self.right = right
		self.top = top
		self.bottom = bottom

	def serialize(self):
		print('ANIM_HURTBOX(%s, %s, %s, %s)' % (intasm8(self.left), intasm8(self.right), intasm8(self.top), intasm8(self.bottom)))

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
		print(
			'ANIM_HITBOX(%s, %s, %s, %s, %s, %s, %s, %s, %s, %s)' %
			('$01' if self.enabled else '$00', intasm8(self.damages), intasm16(self.base_h), intasm16(self.base_v), intasm16(self.force_h), intasm16(self.force_v), intasm8(self.left), intasm8(self.right), intasm8(self.top), intasm8(self.bottom))
		)

class Sprite:
	def __init__(self, y=0, tile='', attr=0, x=0):
		self.y = y
		self.tile = tile
		self.attr = attr
		self.x = x

	def serialize(self):
		print('ANIM_SPRITE(%s, %s, %s, %s)' % (intasm8(self.y), self.tile, intasm8(self.attr), intasm8(self.x)))

class Frame:
	def __init__(self, duration=0, hurtbox=None, hitbox=None):
		self.duration = duration
		self.hurtbox = hurtbox
		self.hitbox = hitbox
		self.sprites = []

	def serialize(self):
		print('ANIM_FRAME_BEGIN(%d)' % self.duration)
		if self.hurtbox is not None:
			self.hurtbox.serialize()
		if self.hitbox is not None:
			self.hitbox.serialize()
		for sprite in self.sprites:
			sprite.serialize()
		print('ANIM_FRAME_END')

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

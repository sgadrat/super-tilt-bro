from stblib import ensure, utils

class Hurtbox:
	def __init__(self, left=0, right=0, top=0, bottom=0):
		self.left = left
		self.right = right
		self.top = top
		self.bottom = bottom

	def check(self):
		ensure(-128 <= self.left and self.left <= 127)
		ensure(-128 <= self.right and self.right <= 127)
		ensure(-128 <= self.top and self.top <= 127)
		ensure(-128 <= self.bottom and self.bottom <= 127)
		ensure(self.left <= self.right)
		ensure(self.top <= self.bottom)

class DirectHitbox:
	def __init__(self, enabled=False, damages=0, base_h=0, base_v=0, force_h=0, force_v=0, left=0, right=0, top=0, bottom=0):
		self.enabled = enabled
		self.left = left
		self.right = right
		self.top = top
		self.bottom = bottom
		self.damages = damages
		self.base_h = base_h
		self.base_v = base_v
		self.force_h = force_h
		self.force_v = force_v

	def check(self):
		ensure(-128 <= self.left and self.left <= 127)
		ensure(-128 <= self.right and self.right <= 127)
		ensure(-128 <= self.top and self.top <= 127)
		ensure(-128 <= self.bottom and self.bottom <= 127)
		ensure(self.left <= self.right)
		ensure(self.top <= self.bottom)

class CustomHitbox:
	def __init__(self, enabled=False, left=0, right=0, top=0, bottom=0, routine='', directional1=0, directional2=0, value1=0, value2=0, value3=0):
		self.enabled = enabled
		self.left = left
		self.right = right
		self.top = top
		self.bottom = bottom
		self.routine = routine
		self.directional1 = directional1
		self.directional2 = directional2
		self.value1 = value1
		self.value2 = value2
		self.value3 = value3

	def check(self):
		ensure(-128 <= self.left and self.left <= 127)
		ensure(-128 <= self.right and self.right <= 127)
		ensure(-128 <= self.top and self.top <= 127)
		ensure(-128 <= self.bottom and self.bottom <= 127)
		ensure(self.left <= self.right)
		ensure(self.top <= self.bottom)
		ensure(utils.valid_routine_name(self.routine))
		ensure(-32768 <= self.directional1 and self.directional1 <= 32767, 'directional1 value of {} is out of int16 bounds'.format(self.directional1))
		ensure(-32768 <= self.directional2 and self.directional2 <= 32767, 'directional2 value of {} is out of int16 bounds'.format(self.directional2))
		ensure(0 <= self.value1 and self.value1 <= 255, 'value1 ({}) is out of uint8 bounds'.format(self.value1))
		ensure(0 <= self.value2 and self.value2 <= 255, 'value2 ({}) is out of uint8 bounds'.format(self.value1))
		ensure(0 <= self.value3 and self.value3 <= 255, 'value3 ({}) is out of uint8 bounds'.format(self.value1))

class Sprite:
	def __init__(self, y=0, tile='', attr=0, x=0, foreground=False):
		self.y = y
		self.tile = tile
		self.attr = attr
		self.x = x
		self.foreground = foreground

	def check(self):
		ensure(-128 <= self.x and self.x <= 127)
		ensure(-128 <= self.y and self.y <= 127)
		ensure(0 <= self.attr and self.attr <= 255)
		ensure(isinstance(self.foreground, bool))

class Frame:
	def __init__(self, duration=0, hurtbox=None, hitbox=None, sprites=None):
		self.duration = duration
		self.hurtbox = hurtbox
		self.hitbox = hitbox
		self.sprites = sprites if sprites is not None else []

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

	def foreground_sprites(self):
		foreground_sprites = []
		for sprite in self.sprites:
			if sprite.foreground:
				foreground_sprites.append(sprite)
		return foreground_sprites

	def normal_sprites(self):
		normal_sprites = []
		for sprite in self.sprites:
			if not sprite.foreground:
				normal_sprites.append(sprite)
		return normal_sprites

	def check(self):
		ensure(self.duration > 0 and self.duration < 256)
		if self.hurtbox is not None:
			self.hurtbox.check()
		if self.hitbox is not None:
			self.hitbox.check()
		for sprite in self.sprites:
			sprite.check()

class Animation:
	def __init__(self, name='', frames=None):
		self.name = name
		if frames is not None:
			self.frames = frames
		else:
			self.frames = []

	def check(self):
		ensure(len(self.frames) > 0, 'empty animation')
		for frame in self.frames:
			frame.check()

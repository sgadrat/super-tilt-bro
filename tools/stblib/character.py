import stblib.animations
import stblib.tiles

class State:
	def __init__(self, name='', start_routine='', update_routine='', offground_routine='', onground_routine='', input_routine='', onhurt_routine=''):
		self.name = name
		self.start_routine = start_routine
		self.update_routine = update_routine
		self.offground_routine = offground_routine
		self.onground_routine = onground_routine
		self.input_routine = input_routine
		self.onhurt_routine = onhurt_routine

	def check(self):
		assert len(self.name) > 0
		assert len(self.start_routine) > 0
		assert len(self.update_routine) > 0
		assert len(self.offground_routine) > 0
		assert len(self.onground_routine) > 0
		assert len(input_routine) > 0
		assert len(onhurt_routine) > 0

class Palette:
	def __init__(self, colors=None):
		self.colors = colors if colors is not None else []

	def check(self):
		assert isinstance(self.colors, list)
		assert len(self.colors) == 3
		for color in self.colors:
			assert color >= 0
			assert color <= 255

class Colorswaps:
	def __init__(self, primary_names=None, secondary_names=None, primary_colors=None, alternate_colors=None, secondary_colors=None):
		self.primary_names = primary_names if primary_names is not None else []
		self.secondary_names = secondary_names if secondary_names is not None else []
		self.primary_colors = primary_colors if primary_colors is not None else []
		self.alternate_colors = alternate_colors if alternate_colors is not None else []
		self.secondary_colors = secondary_colors if secondary_colors is not None else []

	def check(self):
		assert isinstance(self.primary_names, list)
		for name in self.primary_names:
			assert isinstance(name, str)
			assert len(name) >= 1
			assert len(name) <= 8

		assert isinstance(self.secondary_names, list)
		for name in self.secondary_names:
			assert isinstance(name, str)
			assert len(name) >= 1
			assert len(name) <= 8

		assert isinstance(self.primary_colors, list)
		for colors in self.primary_colors:
			assert isinstance(colors, Palette)
			colors.check()

		assert isinstance(self.alternate_colors, list)
		for colors in self.alternate_colors:
			assert isinstance(colors, Palette)
			colors.check()

		assert isinstance(self.secondary_colors, list)
		for colors in self.secondary_colors:
			assert isinstance(colors, Palette)
			colors.check()

		assert len(self.primary_names) == len(self.primary_colors)
		assert len(self.alternate_colors) == len(self.primary_colors)
		assert len(self.secondary_names) == len(self.secondary_colors)

		

class Tileset:
	def __init(self, tiles=None, tilenames=None):
		self.tiles = tiles if tiles is not None else []
		self.tilenames = tilenames if tilenames is not None else []
	
	def check(self):
		assert isinstance(self.tiles, list)
		for tile in self.tiles:
			assert isinstance(tile, stblib.tiles.Tile)
			tile.check()

		assert isinstance(self.tilenames, list)
		for tilename in self.tilenames:
			assert isinstance(tilename, str)
			assert len(tilename) > 0

		assert len(self.tilenames) == len(self.tiles)

class Character:
	def __init__(self, name='', weapon_name='', sourcecode='', tileset=None, victory_animation=None, defeat_animation=None, menu_select_animation=None, animations=None, color_swaps=None, states=None):
		self.name = name
		self.weapon_name = weapon_name
		self.sourcecode = sourcecode
		self.tileset = tileset if tileset is not None else Tileset()
		self.victory_animation = victory_animation if victory_animation is not None else stblib.animations.Animation()
		self.defeat_animation = defeat_animation if defeat_animation is not None else stblib.animations.Animation()
		self.menu_select_animation = menu_select_animation if menu_select_animation is not None else stblib.animations.Animation()
		self.animations = animations if animations is not None else []
		self.color_swaps = color_swaps if color_swaps is not None else Colorswaps()
		self.states = states if states is not None else []

	def check(self):
		assert isinstance(self.name, str)
		assert len(self.name) >= 1
		assert len(self.name) <= 10

		assert isinstance(self.weapon_name, str)
		assert len(self.weapon_name) >= 1
		assert len(self.weapon_name) <= 10

		assert isinstance(self.sourcecode, str)

		assert isinstance(self.victory_animation, stblib.animations.Animation)
		assert self.victory_animation.hitbox is None
		assert self.victory_animation.hurtbox is None

		assert isinstance(self.defeat_animation, stblib.animations.Animation)
		assert self.defeat_animation.hitbox is None
		assert self.defeat_animation.hurtbox is None

		assert isinstance(self.menu_select_animation, stblib.animations.Animation)
		assert self.menu_select_animation.hitbox is None
		assert self.menu_select_animation.hurtbox is None

		assert isinstance(self.animations, list)
		for animation in self.animations:
			assert isinstance(animation, stblib.animations.Animation)

		assert isinstance(self.color_swaps, Colorswaps)
		self.color_swaps.check()

		assert isinstance(self.states, list)
		for state in self.states:
			assert isinstance(state, State)
			state.check()

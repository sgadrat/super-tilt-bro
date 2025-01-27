from stblib import ensure, is_valid_label_name
import stblib.animations
import stblib.tiles

class State:
	def __init__(self, name='', start_routine=None, update_routine='', offground_routine='', onground_routine='', input_routine='', onhurt_routine=''):
		self.name = name
		self.start_routine = start_routine
		self.update_routine = update_routine
		self.offground_routine = offground_routine
		self.onground_routine = onground_routine
		self.input_routine = input_routine
		self.onhurt_routine = onhurt_routine

	def check(self):
		ensure(len(self.name) > 0, 'player state must have a non-empty name')
		ensure(self.start_routine is None or len(self.start_routine) > 0, 'start routine of state "{}" is empty (must be None or non-empty string)'.format(self.name))
		ensure(len(self.update_routine) > 0, 'state "{}": update routine is empty'.format(self.name))
		ensure(len(self.offground_routine) > 0, 'state "{}": offground routine is empty'.format(self.name))
		ensure(len(self.onground_routine) > 0, 'state "{}": onground routine is empty'.format(self.name))
		ensure(len(self.input_routine) > 0, 'state "{}": input routine is empty'.format(self.name))
		ensure(len(self.onhurt_routine) > 0, 'state "{}": onhurt routine is empty'.format(self.name))

class Palette:
	def __init__(self, colors=None):
		self.colors = colors if colors is not None else []

	def check(self):
		ensure(isinstance(self.colors, list))
		ensure(len(self.colors) == 3)
		for color in self.colors:
			ensure(color >= 0)
			ensure(color <= 255)

class Colorswaps:
	def __init__(self, primary_colors=None, alternate_colors=None, secondary_colors=None):
		self.primary_colors = primary_colors if primary_colors is not None else []
		self.alternate_colors = alternate_colors if alternate_colors is not None else []
		self.secondary_colors = secondary_colors if secondary_colors is not None else []

	def check(self):
		ensure(isinstance(self.primary_colors, list))
		for colors in self.primary_colors:
			ensure(isinstance(colors, Palette))
			colors.check()

		ensure(isinstance(self.alternate_colors, list))
		for colors in self.alternate_colors:
			ensure(isinstance(colors, Palette))
			colors.check()

		ensure(isinstance(self.secondary_colors, list))
		for colors in self.secondary_colors:
			ensure(isinstance(colors, Palette))
			colors.check()

		ensure(len(self.alternate_colors) == len(self.primary_colors))
		ensure(len(self.secondary_colors) == len(self.primary_colors))

class AiHitbox:
	def __init__(self, left=0, right=0, top=0, bottom=0):
		self.left = left
		self.right = right
		self.top = top
		self.bottom = bottom

	def check(self):
		ensure(isinstance(self.left, int))
		ensure(isinstance(self.right, int))
		ensure(isinstance(self.top, int))
		ensure(isinstance(self.bottom, int))

		ensure(self.left <= self.right)
		ensure(self.top <= self.bottom)

class AiAttack:
	class ConstraintFlag:
		DIRECTION_LEFT  = 0b00000001
		DIRECTION_RIGHT = 0b00000010
		AIRBORNE        = 0b00000100
		GROUNDED        = 0b00001000

	def __init__(self, action='', hitbox=None, constraints=0):
		self.action = action
		self.constraints = constraints
		self.hitbox = hitbox if hitbox is not None else AiHitbox()

	def constraint_set(self, constraint):
		return self.constraints & constraint != 0

	def check(self):
		ensure(isinstance(self.action, str))

		ensure(isinstance(self.hitbox, AiHitbox))
		self.hitbox.check()

		ensure(isinstance(self.constraints, int))
		ensure(
			self.constraints <=
				AiAttack.ConstraintFlag.DIRECTION_LEFT +
				AiAttack.ConstraintFlag.DIRECTION_RIGHT +
				AiAttack.ConstraintFlag.AIRBORNE +
				AiAttack.ConstraintFlag.GROUNDED,
			"unknown flag set in action's constraints"
		)
		ensure(
			not(
				self.constraint_set(AiAttack.ConstraintFlag.DIRECTION_LEFT) and
				self.constraint_set(AiAttack.ConstraintFlag.DIRECTION_RIGHT)
			),
			"impossible constraints mix: right and left"
		)
		ensure(
			not(
				self.constraint_set(AiAttack.ConstraintFlag.AIRBORNE) and
				self.constraint_set(AiAttack.ConstraintFlag.GROUNDED)
			),
			"impossible constraints mix: airborne and grounded"
		)

class AiActionStep:
	def __init__(self, input=0, duration=0):
		self.input = input
		self.duration = duration

	def check(self):
		ensure(isinstance(self.input, int) or isinstance(self.input, str))
		if isinstance(self.input, int):
			ensure(0 <= self.input and self.input <= 255)
		if isinstance(self.input, str):
			ensure(self.input[:17] == 'CONTROLLER_INPUT_')

		ensure(isinstance(self.duration, int))
		ensure(0 <= self.duration and self.duration <= 255)

class AiAction:
	def __init__(self, name='', steps=None):
		self.name = name
		self.steps = steps if steps is not None else []

	def check(self):
		ensure(is_valid_label_name(self.name))

		ensure(isinstance(self.steps, list))
		ensure(len(self.steps) > 0, 'empty action')
		for step in self.steps:
			ensure(isinstance(step, AiActionStep))
			step.check()

class Ai:
	def __init__(self, action_selectors=None, attacks=None, actions=None, sourcecode=''):
		self.action_selectors = action_selectors if action_selectors is not None else []
		self.attacks = attacks if attacks is not None else []
		self.actions = actions if actions is not None else []
		self.sourcecode = sourcecode

	def check(self):
		ensure(isinstance(self.action_selectors, list))
		for selector in self.action_selectors:
			ensure(isinstance(selector, str))

		ensure(isinstance(self.attacks, list))
		for attack in self.attacks:
			ensure(isinstance(attack, AiAttack))
			attack.check()

		ensure(isinstance(self.actions, list))
		for action in self.actions:
			ensure(isinstance(action, AiAction))
			action.check()

		ensure(isinstance(self.sourcecode, str))

class Character:
	def __init__(self, name='', sourcecode='', tileset=None, victory_animation=None, defeat_animation=None, menu_select_animation=None, animations=None, color_swaps=None, states=None, illustration_large=None, illustration_small=None, illustration_token=None, ai=None, netload_routine=None, projectile_hit_routine=None, global_tick_routine=None):
		self.name = name
		self.sourcecode = sourcecode
		self.tileset = tileset if tileset is not None else stblib.tiles.Tileset()
		self.victory_animation = victory_animation if victory_animation is not None else stblib.animations.Animation()
		self.defeat_animation = defeat_animation if defeat_animation is not None else stblib.animations.Animation()
		self.menu_select_animation = menu_select_animation if menu_select_animation is not None else stblib.animations.Animation()
		self.animations = animations if animations is not None else []
		self.color_swaps = color_swaps if color_swaps is not None else Colorswaps()
		self.states = states if states is not None else []
		self.illustration_large = illustration_large if illustration_large is not None else stblib.tiles.Tileset()
		self.illustration_small = illustration_small if illustration_small is not None else stblib.tiles.Tileset()
		self.illustration_token = illustration_token if illustration_token is not None else stblib.tiles.Tileset()
		self.ai = ai if ai is not None else Ai()
		self.netload_routine = netload_routine
		self.projectile_hit_routine = projectile_hit_routine
		self.global_tick_routine = global_tick_routine

	def check(self):
		ensure(isinstance(self.name, str))
		ensure(len(self.name) >= 1)
		ensure(len(self.name) <= 10)

		ensure(isinstance(self.sourcecode, str))

		self.tileset.check()
		ensure(len(self.tileset.tiles) <= 96, f'character "{self.name}" tileset has too many tiles: {len(self.tileset.tiles)} while max is 96')

		ensure(isinstance(self.victory_animation, stblib.animations.Animation))
		self.victory_animation.check()
		for frame in self.victory_animation.frames:
			ensure(frame.hitbox is None)
			ensure(frame.hurtbox is None)

		ensure(isinstance(self.defeat_animation, stblib.animations.Animation))
		self.defeat_animation.check()
		for frame in self.defeat_animation.frames:
			ensure(frame.hitbox is None)
			ensure(frame.hurtbox is None)

		ensure(isinstance(self.menu_select_animation, stblib.animations.Animation))
		self.menu_select_animation.check()
		for frame in self.menu_select_animation.frames:
			ensure(frame.hitbox is None)
			ensure(frame.hurtbox is None)

		ensure(isinstance(self.animations, list))
		for animation in self.animations:
			ensure(isinstance(animation, stblib.animations.Animation))
			animation.check()

		ensure(isinstance(self.color_swaps, Colorswaps))
		self.color_swaps.check()

		ensure(isinstance(self.states, list))
		for state in self.states:
			ensure(isinstance(state, State))
			state.check()

		ensure(isinstance(self.illustration_large, stblib.tiles.Tileset))
		self.illustration_large.check()
		ensure(len(self.illustration_large.tiles) == 48, "bad number of tiles in large illustration {} instead of 48".format(len(self.illustration_large.tiles)))

		ensure(isinstance(self.illustration_small, stblib.tiles.Tileset))
		self.illustration_small.check()
		ensure(len(self.illustration_small.tiles) == 4, "bad number of tiles in small illustration {} instead of 4".format(len(self.illustration_small.tiles)))

		ensure(isinstance(self.illustration_token, stblib.tiles.Tileset))
		self.illustration_token.check()
		ensure(len(self.illustration_token.tiles) == 1, "bad number of tiles in token illustration {} instead of 1".format(len(self.illustration_token.tiles)))

		ensure(isinstance(self.ai, Ai))
		self.ai.check()

		ensure(isinstance(self.netload_routine, str), "netload_routine shall be the label of a network state-loading routine")
		ensure(isinstance(self.projectile_hit_routine, str), "projectile_hit_routine shall be the label of a routine")
		ensure(isinstance(self.global_tick_routine, str), "global_tick_routine shall be the label of a routine")

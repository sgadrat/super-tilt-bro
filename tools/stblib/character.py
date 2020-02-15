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
		ensure(len(self.name) > 0)
		ensure(self.start_routine is None or len(self.start_routine) > 0)
		ensure(len(self.update_routine) > 0)
		ensure(len(self.offground_routine) > 0)
		ensure(len(self.onground_routine) > 0)
		ensure(len(self.input_routine) > 0)
		ensure(len(self.onhurt_routine) > 0)

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
	def __init__(self, primary_names=None, secondary_names=None, primary_colors=None, alternate_colors=None, secondary_colors=None):
		self.primary_names = primary_names if primary_names is not None else []
		self.secondary_names = secondary_names if secondary_names is not None else []
		self.primary_colors = primary_colors if primary_colors is not None else []
		self.alternate_colors = alternate_colors if alternate_colors is not None else []
		self.secondary_colors = secondary_colors if secondary_colors is not None else []

	def check(self):
		ensure(isinstance(self.primary_names, list))
		for name in self.primary_names:
			ensure(isinstance(name, str))
			ensure(len(name) >= 1)
			ensure(len(name) <= 8)

		ensure(isinstance(self.secondary_names, list))
		for name in self.secondary_names:
			ensure(isinstance(name, str))
			ensure(len(name) >= 1)
			ensure(len(name) <= 8)

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

		ensure(len(self.primary_names) == len(self.primary_colors))
		ensure(len(self.alternate_colors) == len(self.primary_colors))
		ensure(len(self.secondary_names) == len(self.secondary_colors))

class AiHitbox:
	def __init__(self, left=0, right=0, top=0, bottom=0):
		self.left = left
		self.right = right
		self.top = top
		self.bottom = bottom

	def check(self):
		ensure(isinstance(left, int))
		ensure(isinstance(right, int))
		ensure(isinstance(top, int))
		ensure(isinstance(bottom, int))

		ensure(left <= right)
		ensure(top <= bottom)

class AiAttack:
	class ConstraintFlag:
		DIRECTION_LEFT  = 0b00000001
		DIRECTION_RIGHT = 0b00000010

	def __init(self, action='', hitbox=None, constraints=0):
		self.action = action
		self.constraints = constraints
		self.hitbox = hitbox if hitbox is not None else AiHitbox

	def constraint_set(self, constraint):
		return self.constraints & constraint != 0

	def check(self):
		ensure(isinstance(self.action, str))

		ensure(isinstance(self.hitbox, AiHitbox))
		self.hitbox.check()

		ensure(isinstance(self.constraints, int))
		ensure(self.constraints <= ConstraintFlag.DIRECTION_LEFT + ConstraintFlag.DIRECTION_RIGHT, "unknown flag set in action's constraints")
		ensure(not (self.constraint_set(ConstraintFlag.DIRECTION_LEFT) and self.constraint_set(ConstraintFlag.DIRECTION_RIGHT)), "impossible constraints mix: right and left")

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
	def __init(self, name='', steps=None):
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
		self.sourcecode = ''

	def check(self):
		ensure(isinstance(action_selectors, list))
		for selector in action_selectors:
			ensure(isinstance(selector, str))

		ensure(isinstance(attacks, list))
		for attack in attacks:
			ensure(isinstance(attack, AiAttack))
			attack.check()

		ensure(isinstance(actions, list))
		for action in actions:
			ensure(isinstance(action, AiAction))
			action.check()

		ensure(isinstance(self.sourcecode, str))

class Character:
	def __init__(self, name='', weapon_name='', sourcecode='', tileset=None, victory_animation=None, defeat_animation=None, menu_select_animation=None, animations=None, color_swaps=None, states=None, illustration_small=None, illustration_token=None, ai=None):
		self.name = name
		self.weapon_name = weapon_name
		self.sourcecode = sourcecode
		self.tileset = tileset if tileset is not None else stblib.tiles.Tileset()
		self.victory_animation = victory_animation if victory_animation is not None else stblib.animations.Animation()
		self.defeat_animation = defeat_animation if defeat_animation is not None else stblib.animations.Animation()
		self.menu_select_animation = menu_select_animation if menu_select_animation is not None else stblib.animations.Animation()
		self.animations = animations if animations is not None else []
		self.color_swaps = color_swaps if color_swaps is not None else Colorswaps()
		self.states = states if states is not None else []
		self.illustration_small = illustration_small if illustration_small is not None else stblib.tiles.Tileset()
		self.illustration_token = illustration_token if illustration_token is not None else stblib.tiles.Tileset()
		self.ai = ai if ai is not None else Ai()

	def check(self):
		ensure(isinstance(self.name, str))
		ensure(len(self.name) >= 1)
		ensure(len(self.name) <= 10)

		ensure(isinstance(self.weapon_name, str))
		ensure(len(self.weapon_name) >= 1)
		ensure(len(self.weapon_name) <= 10)

		ensure(isinstance(self.sourcecode, str))

		self.tileset.check()
		ensure(len(self.tileset.tiles) <= 96)

		ensure(isinstance(self.victory_animation, stblib.animations.Animation))
		for frame in self.victory_animation.frames:
			ensure(frame.hitbox is None)
			ensure(frame.hurtbox is None)

		ensure(isinstance(self.defeat_animation, stblib.animations.Animation))
		for frame in self.defeat_animation.frames:
			ensure(frame.hitbox is None)
			ensure(frame.hurtbox is None)

		ensure(isinstance(self.menu_select_animation, stblib.animations.Animation))
		for frame in self.menu_select_animation.frames:
			ensure(frame.hitbox is None)
			ensure(frame.hurtbox is None)

		ensure(isinstance(self.animations, list))
		for animation in self.animations:
			ensure(isinstance(animation, stblib.animations.Animation))

		ensure(isinstance(self.color_swaps, Colorswaps))
		self.color_swaps.check()

		ensure(isinstance(self.states, list))
		for state in self.states:
			ensure(isinstance(state, State))
			state.check()

		ensure(isinstance(self.illustration_small, stblib.tiles.Tileset))
		self.illustration_small.check()
		ensure(len(self.illustration_small.tiles) == 4)

		ensure(isinstance(self.illustration_token, stblib.tiles.Tileset))
		self.illustration_token.check()
		ensure(len(self.illustration_token.tiles) == 1)

		ensure(isinstance(self.ai, Ai))
		self.ai.check()

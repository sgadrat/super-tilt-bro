import stblib.animations
import stblib.character
import stblib.gamemod
import stblib.nametables
import stblib.stages
import stblib.tiles

def import_from_dict(source):
	if source is None:
		return None
	if 'type' not in source:
		raise Exception('object not explicitely typed: {}'.format(source))
	return globals()['parse_{}'.format(source['type'])](source)

def export_to_dict(obj):
	if obj is None or type(obj) in [int, str, float, bool]:
		return obj
	return globals()['serialize_{}'.format(_mangle(type(obj)))](obj)

def mandatory_get(source, field, typename=None):
	if field in source:
		return source[field]

	if typename is None:
		typename = source['type']
	raise Exception('object of type "{}" must contain a "{}" field'.format(typename, field))

def _mangle(t):
	name = None
	if isinstance(t, type):
		name = '{}.{}'.format(t.__module__, t.__name__)
	else:
		name = t
	return name.lower().replace('.', '_')

def _import_list(source):
	res = []
	for item in source:
		res.append(import_from_dict(item))
	return res

def parse_animation(source):
	return stblib.animations.Animation(
		name = mandatory_get(source, 'name'),
		frames = _import_list(mandatory_get(source, 'frames'))
	)

def parse_animation_frame(source):
	return stblib.animations.Frame(
		duration = mandatory_get(source, 'duration'),
		hurtbox = import_from_dict(mandatory_get(source, 'hurtbox')),
		hitbox = import_from_dict(mandatory_get(source, 'hitbox')),
		sprites = _import_list(mandatory_get(source, 'sprites'))
	)

def parse_animation_hitbox(source):
	return stblib.animations.Hitbox(
		enabled = mandatory_get(source, 'enabled'),
		damages = mandatory_get(source, 'damages'),
		base_h = mandatory_get(source, 'base_h'),
		base_v = mandatory_get(source, 'base_v'),
		force_h = mandatory_get(source, 'force_h'),
		force_v = mandatory_get(source, 'force_v'),
		left = mandatory_get(source, 'left'),
		right = mandatory_get(source, 'right'),
		top = mandatory_get(source, 'top'),
		bottom = mandatory_get(source, 'bottom')
	)

def parse_animation_hurtbox(source):
	return stblib.animations.Hurtbox(
		left = mandatory_get(source, 'left'),
		right = mandatory_get(source, 'right'),
		top = mandatory_get(source, 'top'),
		bottom = mandatory_get(source, 'bottom')
	)

def parse_animation_sprite(source):
	return stblib.animations.Sprite(
		y = mandatory_get(source, 'y'),
		tile = mandatory_get(source, 'tile'),
		attr = source['attr'] if isinstance(source['attr'], int) else import_from_dict(source['attr']),
		x = mandatory_get(source, 'x'),
		foreground = mandatory_get(source, 'foreground')
	)

def parse_bg_metatile(source):
	return stblib.stages.BackgroundMetaTile(x = source['x'], y = source['y'], tile_name = source['tile'])

def parse_character(source):
	return stblib.character.Character(
		name = mandatory_get(source, 'name'),
		weapon_name = mandatory_get(source, 'weapon_name'),
		sourcecode = mandatory_get(source, 'sourcecode'),
		tileset = import_from_dict(mandatory_get(source, 'tileset')),
		victory_animation = import_from_dict(mandatory_get(source, 'victory_animation')),
		defeat_animation = import_from_dict(mandatory_get(source, 'defeat_animation')),
		menu_select_animation = import_from_dict(mandatory_get(source, 'menu_select_animation')),
		animations = _import_list(mandatory_get(source, 'animations')),
		color_swaps = import_from_dict(mandatory_get(source, 'color_swaps')),
		states = _import_list(mandatory_get(source, 'states')),
		illustration_large = import_from_dict(mandatory_get(source, 'illustration_large')),
		illustration_small = import_from_dict(mandatory_get(source, 'illustration_small')),
		illustration_token = import_from_dict(mandatory_get(source, 'illustration_token')),
		ai = import_from_dict(mandatory_get(source, 'ai')),
		netload_routine = mandatory_get(source, 'netload_routine')
	)

def parse_character_ai(source):
	return stblib.character.Ai(
		action_selectors = mandatory_get(source, 'action_selectors'),
		attacks = _import_list(mandatory_get(source, 'attacks')),
		actions = _import_list(mandatory_get(source, 'actions')),
		sourcecode = mandatory_get(source, 'sourcecode')
	)

def parse_character_ai_action(source):
	return stblib.character.AiAction(
		name = mandatory_get(source, 'name'),
		steps = _import_list(mandatory_get(source, 'steps'))
	)

def parse_character_ai_action_step(source):
	return stblib.character.AiActionStep(
		input = mandatory_get(source, 'input'),
		duration = mandatory_get(source, 'duration')
	)

def parse_character_ai_attack(source):
	return stblib.character.AiAttack(
		action = mandatory_get(source, 'action'),
		hitbox = import_from_dict(mandatory_get(source, 'hitbox')),
		constraints = mandatory_get(source, 'constraints')
	)

def parse_character_ai_hitbox(source):
	return stblib.character.AiHitbox(
		left = mandatory_get(source, 'left'),
		right = mandatory_get(source, 'right'),
		top = mandatory_get(source, 'top'),
		bottom = mandatory_get(source, 'bottom')
	)

def parse_character_colors(source):
	return stblib.character.Colorswaps(
		primary_names = mandatory_get(source, 'primary_names'),
		secondary_names = mandatory_get(source, 'secondary_names'),
		primary_colors = _import_list(mandatory_get(source, 'primary_colors')),
		alternate_colors = _import_list(mandatory_get(source, 'alternate_colors')),
		secondary_colors = _import_list(mandatory_get(source, 'secondary_colors'))
	)

def parse_character_state(source):
	return stblib.character.State(
		name = mandatory_get(source, 'name'),
		start_routine = source.get('start_routine'),
		update_routine = mandatory_get(source, 'update_routine'),
		offground_routine = mandatory_get(source, 'offground_routine'),
		onground_routine = mandatory_get(source, 'onground_routine'),
		input_routine = mandatory_get(source, 'input_routine'),
		onhurt_routine = mandatory_get(source, 'onhurt_routine')
	)

def parse_gamemod(source):
	return stblib.gamemod.GameMod(
		characters = _import_list(mandatory_get(source, 'characters')),
		tilesets = _import_list(mandatory_get(source, 'tilesets'))
	)

def parse_nametable(source):
	return stblib.nametables.Nametable(name = source['name'], tilemap = source['tilemap'], attributes = source['attributes'])

def parse_palette(source):
	return stblib.character.Palette(colors = mandatory_get(source, 'colors'))

def parse_platform(source):
	return stblib.stages.Platform(
		left = source['left'], right = source['right'], top = source['top'], bottom = source['bottom']
	)

def parse_smooth_platform(source):
	return stblib.stages.SmoothPlatform(
		left = source['left'], right = source['right'], top = source['top']
	)

def parse_sprite_attributes(source):
	int_attributes = 0
	if mandatory_get(source, 'flip_v'):
		int_attributes += 0x80
	if mandatory_get(source, 'flip_h'):
		int_attributes += 0x40
	if mandatory_get(source, 'background'):
		int_attributes += 0x20
	int_attributes += mandatory_get(source, 'palette')
	return int_attributes

def parse_stage(source):
	return stblib.stages.Stage(
		name = source['name'], description = source['description'],
		player_a_position = tuple(mandatory_get(source, 'player_a_position')),
		player_b_position = tuple(mandatory_get(source, 'player_b_position')),
		respawn_position = tuple(mandatory_get(source, 'respawn_position')),
		platforms = _import_list(mandatory_get(source, 'platforms')),
		bg_metatiles = _import_list(mandatory_get(source, 'metatiles'))
	)

def parse_tile(source):
	return stblib.tiles.Tile(
		representation = mandatory_get(source, 'representation')
	)

def parse_tileset(source):
	return stblib.tiles.Tileset(
		tiles = _import_list(mandatory_get(source, 'tiles')),
		tilenames = mandatory_get(source, 'tilenames'),
		name = source.get('name')
	)

def _serialize_object(obj_type, obj):
	result = {
		'type': obj_type,
	}
	for att_name in dir(obj):
		if att_name[0] == '_':
			continue

		att_value = getattr(obj, att_name)

		if callable(att_value):
			pass # Certainly a method, possibly a lambda, anyway we do not want to serialize it
		elif isinstance(att_value, list):
			serial_list = []
			for elem in att_value:
				serial_list.append(export_to_dict(elem))
			result[att_name] = serial_list
		else:
			result[att_name] = export_to_dict(att_value)
	return result

def serialize_stblib_animations_animation(obj):
	return _serialize_object('animation', obj)

def serialize_stblib_animations_frame(obj):
	return _serialize_object('animation_frame', obj)

def serialize_stblib_animations_hitbox(obj):
	return _serialize_object('animation_hitbox', obj)

def serialize_stblib_animations_hurtbox(obj):
	return _serialize_object('animation_hurtbox', obj)

def serialize_stblib_animations_sprite(obj):
	return _serialize_object('animation_sprite', obj)

def serialize_stblib_character_character(obj):
	return _serialize_object('character', obj)

def serialize_stblib_character_ai(obj):
	return _serialize_object('character_ai', obj)

def serialize_stblib_character_aiaction(obj):
	return _serialize_object('character_ai_action', obj)

def serialize_stblib_character_aiactionstep(obj):
	return _serialize_object('character_ai_action_step', obj)

def serialize_stblib_character_aiattack(obj):
	return _serialize_object('character_ai_attack', obj)

def serialize_stblib_character_aihitbox(obj):
	return _serialize_object('character_ai_hitbox', obj)

def serialize_stblib_character_colorswaps(obj):
	return _serialize_object('character_colors', obj)

def serialize_stblib_character_palette(obj):
	return _serialize_object('palette', obj)

def serialize_stblib_character_state(obj):
	return _serialize_object('character_state', obj)

def serialize_stblib_tiles_tileset(obj):
	return _serialize_object('tileset', obj)

def serialize_stblib_tiles_tile(obj):
	# Hack: cannot use _serialize_object() because of misnamed _representation attribute
	return {
		'type': 'tile',
		'representation': obj._representation.copy()
	}

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
		name = source['name'],
		frames = _import_list(source['frames'])
	)

def parse_animation_frame(source):
	return stblib.animations.Frame(
		duration = source['duration'],
		hurtbox = import_from_dict(source['hurtbox']),
		hitbox = import_from_dict(source['hitbox']),
		sprites = _import_list(source['sprites'])
	)

def parse_animation_hitbox(source):
	return stblib.animations.Hitbox(
		enabled = source['enabled'],
		damages = source['damages'],
		base_h = source['base_h'],
		base_v = source['base_v'],
		force_h = source['force_h'],
		force_v = source['force_v'],
		left = source['left'],
		right = source['right'],
		top = source['top'],
		bottom = source['bottom']
	)

def parse_animation_hurtbox(source):
	return stblib.animations.Hurtbox(
		left = source['left'],
		right = source['right'],
		top = source['top'],
		bottom = source['bottom']
	)

def parse_animation_sprite(source):
	return stblib.animations.Sprite(
		y = source['y'],
		tile = source['tile'],
		attr = source['attr'] if isinstance(source['attr'], int) else import_from_dict(source['attr']),
		x = source['x'],
		foreground = source['foreground']
	)

def parse_bg_metatile(source):
	return stblib.stages.BackgroundMetaTile(x = source['x'], y = source['y'], tile_name = source['tile'])

def parse_character(source):
	return stblib.character.Character(
		name = source['name'],
		weapon_name = source['weapon_name'],
		sourcecode = source['sourcecode'],
		tileset = import_from_dict(source['tileset']),
		victory_animation = import_from_dict(source['victory_animation']),
		defeat_animation = import_from_dict(source['defeat_animation']),
		menu_select_animation = import_from_dict(source['menu_select_animation']),
		animations = _import_list(source['animations']),
		color_swaps = import_from_dict(source['color_swaps']),
		states = _import_list(source['states']),
		illustration_small = import_from_dict(source['illustration_small']),
		illustration_token = import_from_dict(source['illustration_token']),
		ai = import_from_dict(source['ai'])
	)

def parse_character_ai(source):
	return stblib.character.Ai(
		action_selectors = source['action_selectors'],
		attacks = _import_list(source['attacks']),
		actions = _import_list(source['actions']),
		sourcecode = source['sourcecode']
	)

def parse_character_ai_action(source):
	return stblib.character.AiAction(
		name = source['name'],
		steps = _import_list(source['steps'])
	)

def parse_character_ai_action_step(source):
	return stblib.character.AiActionStep(
		input = source['input'],
		duration = source['duration']
	)

def parse_character_ai_attack(source):
	return stblib.character.AiAttack(
		action = source['action'],
		hitbox = import_from_dict(source['hitbox']),
		constraints = source['constraints']
	)

def parse_character_ai_hitbox(source):
	return stblib.character.AiHitbox(
		left = source['left'],
		right = source['right'],
		top = source['top'],
		bottom = source['bottom']
	)

def parse_character_colors(source):
	return stblib.character.Colorswaps(
		primary_names = source['primary_names'],
		secondary_names = source['secondary_names'],
		primary_colors = _import_list(source['primary_colors']),
		alternate_colors = _import_list(source['alternate_colors']),
		secondary_colors = _import_list(source['secondary_colors'])
	)

def parse_character_state(source):
	return stblib.character.State(
		name = source['name'],
		start_routine = source.get('start_routine'),
		update_routine = source['update_routine'],
		offground_routine = source['offground_routine'],
		onground_routine = source['onground_routine'],
		input_routine = source['input_routine'],
		onhurt_routine = source['onhurt_routine']
	)

def parse_gamemod(source):
	return stblib.gamemod.GameMod(
		characters = _import_list(source['characters']),
		tilesets = _import_list(source['tilesets'])
	)

def parse_nametable(source):
	return stblib.nametables.Nametable(name = source['name'], tilemap = source['tilemap'], attributes = source['attributes'])

def parse_palette(source):
	return stblib.character.Palette(colors = source['colors'])

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
	if source['flip_v']:
		int_attributes += 0x80
	if source['flip_h']:
		int_attributes += 0x40
	if source['background']:
		int_attributes += 0x20
	int_attributes += source['palette']
	return int_attributes

def parse_stage(source):
	return stblib.stages.Stage(
		name = source['name'], description = source['description'],
		player_a_position = tuple(source['player_a_position']),
		player_b_position = tuple(source['player_b_position']),
		respawn_position = tuple(source['respawn_position']),
		platforms = _import_list(source['platforms']),
		bg_metatiles = _import_list(source['metatiles'])
	)

def parse_tile(source):
	return stblib.tiles.Tile(
		representation = source['representation']
	)

def parse_tileset(source):
	return stblib.tiles.Tileset(
		tiles = _import_list(source['tiles']),
		tilenames = source['tilenames'],
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

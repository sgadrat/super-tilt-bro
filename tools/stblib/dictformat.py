from stblib import ensure
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
	parser = 'parse_{}'.format(source['type'])
	if parser not in globals():
		raise Exception('Object type "{}" unknown by dictformat parsers: problematic object = {}'.format(source['type'], source))
	return globals()[parser](source)

def export_to_dict(obj):
	if obj is None or type(obj) in [int, str, float, bool]:
		return obj
	serializer = 'serialize_{}'.format(_mangle(type(obj)))
	if serializer not in globals():
		raise Exception('Object type "{}" unknown by dictformat serializers: problematic object = {}'.format(_mangle(type(obj)), obj))
	return globals()[serializer](obj)

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

def _parse_object(obj_class, source):
	# Create object of the parsed type, and get its attributes list
	parsed = obj_class()
	attributes = [att for att in dir(parsed) if att[0] != '_' and not callable(getattr(parsed, att))]

	# Check that source dict contains all attributes
	for att in attributes:
		ensure(att in source, 'missing attribute "{}" when parsing a {}: {}'.format(att, parsed.__class__.__name__, source))
	for att in source:
		ensure(att == 'type' or att in attributes, 'unknown attribute "{}" when parsing a {}: {}'.format(att, parsed.__class__.__name__, source))

	# Copy attributes in parsed object
	for att in attributes:
		att_value = source[att]
		parsed_att = None
		if isinstance(att_value, dict):
			parsed_att = import_from_dict(att_value)
		elif isinstance(att_value, list):
			parsed_att = _import_list(att_value)
		else:
			ensure(
				att_value.__class__.__name__ in ['bool', 'float', 'int', 'NoneType', 'str'],
				'unparsable attribute "{}" of source type "{}": {}'.format(att, att_value.__class__.__name__, source)
			)
			parsed_att = att_value

		setattr(parsed, att, parsed_att)

	return parsed

def parse_animation(source):
	return _parse_object(stblib.animations.Animation, source)

def parse_animation_custom_hitbox(source):
	return _parse_object(stblib.animations.CustomHitbox, source)

def parse_animation_direct_hitbox(source):
	return _parse_object(stblib.animations.DirectHitbox, source)

def parse_animation_frame(source):
	return _parse_object(stblib.animations.Frame, source)

def parse_animation_hurtbox(source):
	return _parse_object(stblib.animations.Hurtbox, source)

def parse_animation_sprite(source):
	return _parse_object(stblib.animations.Sprite, source)

def parse_bg_metatile(source):
	return _parse_object(stblib.stages.BackgroundMetaTile, source)

def parse_character(source):
	return _parse_object(stblib.character.Character, source)

def parse_character_ai(source):
	return stblib.character.Ai(
		action_selectors = mandatory_get(source, 'action_selectors'),
		attacks = _import_list(mandatory_get(source, 'attacks')),
		actions = _import_list(mandatory_get(source, 'actions')),
		sourcecode = mandatory_get(source, 'sourcecode')
	)

def parse_character_ai_action(source):
	return _parse_object(stblib.character.AiAction, source)

def parse_character_ai_action_step(source):
	return _parse_object(stblib.character.AiActionStep, source)

def parse_character_ai_attack(source):
	return _parse_object(stblib.character.AiAttack, source)

def parse_character_ai_hitbox(source):
	return _parse_object(stblib.character.AiHitbox, source)

def parse_character_colors(source):
	return _parse_object(stblib.character.Colorswaps, source)

def parse_character_state(source):
	return _parse_object(stblib.character.State, source)

def parse_gamemod(source):
	return _parse_object(stblib.gamemod.GameMod, source)

def parse_nametable(source):
	return _parse_object(stblib.nametables.Nametable, source)

def parse_palette(source):
	return stblib.character.Palette(colors = mandatory_get(source, 'colors'))

def parse_platform(source):
	return _parse_object(stblib.stages.Platform, source)

def parse_smooth_platform(source):
	return _parse_object(stblib.stages.SmoothPlatform, source)

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

def serialize_stblib_animations_customhitbox(obj):
	return _serialize_object('animation_custom_hitbox', obj)

def serialize_stblib_animations_directhitbox(obj):
	return _serialize_object('animation_direct_hitbox', obj)

def serialize_stblib_animations_frame(obj):
	return _serialize_object('animation_frame', obj)

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

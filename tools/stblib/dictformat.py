import stblib.animations
import stblib.character
import stblib.nametables
import stblib.stages

def import_from_dict(source):
	if source is None:
		return None
	if 'type' not in source:
		raise Exception('object not explicitely typed: {}'.format(source))
	return globals()['parse_{}'.format(source['type'])](source)

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
		states = _import_list(source['states'])
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
	return stblib.character.Tileset(
		tiles = _import_list(source['tiles']),
		tilenames = source['tilenames']
	)

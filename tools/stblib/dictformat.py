import stblib.animations
import stblib.nametables
import stblib.stages

def import_from_dict(source):
	if source is None:
		return None
	if 'type' not in source:
		raise Exception('object not explicitely typed: {}'.format(source))
	return globals()['parse_{}'.format(source['type'])](source)

def parse_animation(source):
	animation = stblib.animations.Animation(name = source['name'])
	for frame in source['frames']:
		animation.frames.append(import_from_dict(frame))
	return animation

def parse_animation_frame(source):
	frame = stblib.animations.Frame(
		duration = source['duration'],
		hurtbox = import_from_dict(source['hurtbox']),
		hitbox = import_from_dict(source['hitbox'])
	)
	for sprite in source['sprites']:
		frame.sprites.append(import_from_dict(sprite))
	return frame

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
	return stblib.animations.Sprite(y = source['y'], tile = source['tile'], attr = import_from_dict(source['attr']), x = source['x'], foreground = source['foreground'])

def parse_bg_metatile(source):
	return stblib.stages.BackgroundMetaTile(x = source['x'], y = source['y'], tile_name = source['tile'])

def parse_nametable(source):
	return stblib.nametables.Nametable(name = source['name'], tilemap = source['tilemap'], attributes = source['attributes'])

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
	platforms = []
	for source_platform in source['platforms']:
		platforms.append(import_from_dict(source_platform))

	metatiles = []
	for source_metatile in source['metatiles']:
		metatiles.append(import_from_dict(source_metatile))

	return stblib.stages.Stage(
		name = source['name'], description = source['description'],
		player_a_position = tuple(source['player_a_position']),
		player_b_position = tuple(source['player_b_position']),
		respawn_position = tuple(source['respawn_position']),
		platforms = platforms,
		bg_metatiles = metatiles
	)

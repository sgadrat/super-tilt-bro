import stblib.nametables
import stblib.stages

def import_from_dict(source):
	return globals()['parse_{}'.format(source['type'])](source)

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

def parse_stage(source):
	platforms = []
	for source_platform in source['platforms']:
		platforms.append(import_from_dict(source_platform))

	return stblib.stages.Stage(
		name = source['name'], description = source['description'],
		player_a_position = tuple(source['player_a_position']),
		player_b_position = tuple(source['player_b_position']),
		respawn_position = tuple(source['respawn_position']),
		platforms = platforms
	)

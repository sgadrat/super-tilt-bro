"""
Handle the JSON storage format of stblib structure.

This format has a lot in common with the dict format, but handles some structures differently to take advantage of being able to handle separate files.

Notable changes:
	* The "import" type is specific to JSON format, it inlines another JSON file
	* The "tileset" type is based on a GIF file instead of specifying each tile in the dicument
	* The character's "sourcecode" property is a filename instead of the sourcecode
"""

import json
import os
import PIL.Image
from stblib import ensure
import stblib.dictformat

def import_from_json(json_file, base_path = None):
	dict_version = json_to_dict(json_file, base_path)
	return stblib.dictformat.import_from_dict(dict_version)

def export_to_json(obj, json_file, base_path = None):
	dict_version = stblib.dictformat.export_to_dict(obj)
	dict_to_json(dict_version, json_file, base_path)

def json_to_dict(json_file, base_path = None):
	"""
	Construct a dict compatible with dictformat from a json file and its imported files
	"""

	# Normalize base_path
	#  Force it to be set, deduce it from fileobject if needed
	#  Force it to be in canonical form
	if base_path is None:
		if not hasattr(json_file, 'name'):
			raise Exception('unable to import from json: no base path specified')
		base_path = os.path.dirname(json_file.name)
	base_path = os.path.abspath(base_path)

	# Read the file, resolving any "import" object
	dict_version = json.load(json_file)
	dict_version = _process_childs(dict_version, base_path)

	return dict_version

def dict_to_json(dict_version, json_file, base_path = None):
	# Normalize base_path
	#  Force it to be set, deduce it from fileobject if needed
	#  Force it to be in canonical form
	if base_path is None:
		if not hasattr(json_file, 'name'):
			raise Exception('unable to export to json: no base path specified')
		base_path = os.path.dirname(json_file.name)
	base_path = os.path.abspath(base_path)

	# Apply objects transformations
	json_version = _apply_json_transform(dict_version, base_path)

	# Save json file
	json.dump(json_version, json_file, indent='\t', sort_keys=True)
	json_file.write('\n')

def tileset_to_img(tileset, img_with_in_tiles, img_height_in_tiles):
	# Normalize to accept a Tileset or a list of tiles as input
	tiles = None
	if isinstance(tileset, stblib.tiles.Tileset):
		tiles = tileset.tiles
	else:
		tiles = tileset
	ensure(len(tiles) <= img_with_in_tiles * img_height_in_tiles, 'too much tiles in the tileset: {} / {}'.format(len(tiles), img_with_in_tiles * img_height_in_tiles))

	# Create empty image
	img_size = (img_with_in_tiles * 8, img_height_in_tiles * 8)
	img = PIL.Image.new('P', img_size, 0)
	img.putpalette([
		238, 130, 238,
		0, 0, 0,
		128, 128, 128,
		255, 255, 255,
	] + [0]*(256*3-4*3))

	# Draw pixels from tiles data
	tile_num = 0
	for tile in tiles:
		representation = None
		if isinstance(tile, stblib.tiles.Tile):
			representation = tile._representation
		else:
			representation = tile['representation']

		for tile_y in range(8):
			img_y = (int(tile_num / img_with_in_tiles) * 8) + tile_y
			for tile_x in range(8):
				img_x = (tile_num % img_with_in_tiles) * 8 + tile_x
				img.putpixel((img_x, img_y), representation[tile_y][tile_x])
		tile_num += 1

	return img

def extract_tiles_from_img(image_file_path):
	tiles = []

	# Open image file and do sanity checks
	img = PIL.Image.open(image_file_path)
	ensure(img.mode == 'P', 'image file "{}" is not in palette mode'.format(image_file_path))

	width = img.size[0]
	height = img.size[1]
	ensure(width % 8 == 0, 'image file "{}" does not contain 8x8 tiles'.format(image_file_path))
	ensure(height % 8 == 0, 'image file "{}" does not contain 8x8 tiles'.format(image_file_path))

	# Compute useful values
	width_in_tiles = int(width / 8)
	height_in_tiles = int(height / 8)

	# Generate tiles
	for y_tile in range(height_in_tiles):
		for x_tile in range(width_in_tiles):
			tile = {
				'type': 'tile',
				'representation': [
					[0, 0, 0, 0, 0, 0, 0, 0],
					[0, 0, 0, 0, 0, 0, 0, 0],
					[0, 0, 0, 0, 0, 0, 0, 0],
					[0, 0, 0, 0, 0, 0, 0, 0],
					[0, 0, 0, 0, 0, 0, 0, 0],
					[0, 0, 0, 0, 0, 0, 0, 0],
					[0, 0, 0, 0, 0, 0, 0, 0],
					[0, 0, 0, 0, 0, 0, 0, 0],
				],
			}
			for y in range(8):
				y_img = y_tile * 8 + y
				for x in range(8):
					x_img = x_tile * 8 + x
					tile['representation'][y][x] = img.getpixel((x_img, y_img)) % 4
			tiles.append(tile)

	return tiles

def _apply_json_transform(obj, base_path):
	#transformed_types = ['character'] #'animation', 'character', 'tileset']

	if isinstance(obj, dict):
		original_obj_type = obj.get('type')

		# Call specific handler if it exists
		handler = globals().get('_jsonify_{}'.format(original_obj_type))
		if handler is not None:
			obj = handler(obj, base_path)

		# Process all childs if the specific handler did not do it
		for k in obj:
			obj[k] = _apply_json_transform(obj[k], base_path)
	elif isinstance(obj, list):
		# Process all childs
		for k in range(len(obj)):
			obj[k] = _apply_json_transform(obj[k], base_path)
	return obj

def _jsonify_character(character, base_path):
	character_path_rel = 'characters/{}'.format(character['name'])
	animations_path_rel = '{}/animations'.format(character_path_rel)
	illustrations_path_rel = '{}/illustrations'.format(character_path_rel)
	character_path = '{}/{}'.format(base_path, character_path_rel)
	animations_path = '{}/{}'.format(base_path, animations_path_rel)
	illustrations_path = '{}/{}'.format(base_path, illustrations_path_rel)
	os.makedirs(character_path, exist_ok=True)
	os.makedirs(animations_path, exist_ok=True)

	# Convert tilesets to gif based tileset
	tileset_src = '{}/tileset.gif'.format(character_path)
	tileset_img = tileset_to_img(character['tileset']['tiles'], 8, 12)
	tileset_img.save(tileset_src)
	del character['tileset']['tiles']
	character['tileset']['src'] = '{}/tileset.gif'.format(character_path_rel)

	illustration_small_src = '{}/small.gif'.format(illustrations_path)
	illustration_small_img = tileset_to_img(character['illustration_small']['tiles'], 2, 2)
	illustration_small_img.save(illustration_small_src)
	del character['illustration_small']['tiles']
	character['illustration_small']['src'] = '{}/small.gif'.format(illustrations_path_rel)

	illustration_token_src = '{}/token.gif'.format(illustrations_path)
	illustration_token_img = tileset_to_img(character['illustration_token']['tiles'], 1, 1)
	illustration_token_img.save(illustration_token_src)
	del character['illustration_token']['tiles']
	character['illustration_token']['src'] = '{}/token.gif'.format(illustrations_path_rel)

	# Export animations in their own file
	def _externalize_anim(anim, animations_path_rel, base_path):
		ensure(anim.get('name', '') != '', 'empty animation name')
		anim_path_rel = '{}/{}.json'.format(animations_path_rel, anim['name'])
		anim_path = '{}/{}'.format(base_path, anim_path_rel)
		with open(anim_path, 'w') as anim_file:
			dict_to_json(anim, anim_file, base_path)
		return {
			'type': 'import',
			'src': anim_path_rel
		}

	for anim_index in range(len(character['animations'])):
		character['animations'][anim_index] = _externalize_anim(character['animations'][anim_index], animations_path_rel, base_path)
	character['victory_animation'] = _externalize_anim(character['victory_animation'], animations_path_rel, base_path)
	character['defeat_animation'] = _externalize_anim(character['defeat_animation'], animations_path_rel, base_path)
	character['menu_select_animation'] = _externalize_anim(character['menu_select_animation'], animations_path_rel, base_path)

	# Export sourcecode in its own file
	source_path_rel = '{}/states.asm'.format(character_path_rel)
	source_path = '{}/{}'.format(base_path, source_path_rel)
	with open(source_path, 'w') as source_file:
		source_file.write(character['sourcecode'])

	del character['sourcecode']
	character['sourcecode_file'] = source_path_rel

	return character

def _process_childs(obj, base_path):
	"""
	Recursively resolve imports of an object
	"""
	# A list of types for which recursion is already done by the handler
	recursive_handlers = ['import']

	if isinstance(obj, dict):
		original_obj_type = obj.get('type')

		# Call specific handler if it exists
		handler = globals().get('_handle_{}'.format(original_obj_type))
		if handler is not None:
			obj = handler(obj, base_path)

		# Process all childs if the specific handler did not do it
		if original_obj_type not in recursive_handlers:
			for k in obj:
				obj[k] = _process_childs(obj[k], base_path)
	elif isinstance(obj, list):
		# Process all childs
		for k in range(len(obj)):
			obj[k] = _process_childs(obj[k], base_path)
	return obj

def _handle_import(obj, base_path):
	"""
	Return the imported object if "obj" is an import close, else simply return "obj".
	"""
	with open('{}/{}'.format(base_path, obj['src']), 'r') as f:
		return json_to_dict(f, base_path)

def _handle_character(obj, base_path):
	if obj.get('sourcecode_file') is not None:
		with open('{}/{}'.format(base_path, obj['sourcecode_file']), 'r') as f:
			obj['sourcecode'] = f.read()
		del obj['sourcecode_file']
	return obj

def _handle_tileset(obj, base_path):
	if obj.get('src') is not None:
		obj['tiles'] = extract_tiles_from_img('{}/{}'.format(base_path, obj['src']))

		nb_tiles = len(obj['tiles'])
		nb_tilenames = len(obj['tilenames'])
		ensure(nb_tiles >= nb_tilenames, 'less tiles in image "{}" than names in the tileset'.format(obj['src']))
		if nb_tiles > nb_tilenames:
			obj['tiles'] = obj['tiles'][:nb_tilenames]

		del obj['src']
	return obj

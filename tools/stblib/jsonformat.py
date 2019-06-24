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

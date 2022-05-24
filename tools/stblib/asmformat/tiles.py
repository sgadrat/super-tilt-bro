from stblib import ensure

def tile_to_asm(tile, visibility=''):
	# First line: least significant bit of each pixel
	res = '.byt '
	for y in range(8):
		res += '%'
		for x in range(8):
			res += '0' if tile._representation[y][x] % 2 == 0 else '1'
		if y != 7:
			res += ', '
	res += '\n'

	# Second line: most significant bit of each pixel
	res += '.byt '
	for y in range(8):
		res += '%'
		for x in range(8):
			res += '0' if tile._representation[y][x] < 2 else '1'
		if y != 7:
			res += ', '

	return res

def tileset_to_asm(tileset, visibility=''):
	res = f'{visibility}{tileset.name}:\n'
	res += '\n'
	res += "; Tileset's size in tiles (zero means 256)\n"
	res += '.byt ({name}_end-{name}_tiles)/16\n'.format(name = tileset.name)
	res += '\n'
	res += f'{tileset.name}_tiles:\n'

	ensure(len(tileset.tiles) == len(tileset.tilenames), 'tiles must all be named')
	for tile_index in range(len(tileset.tiles)):
		tile_label = f'{visibility}TILE_{tileset.name.upper()}_{tileset.tilenames[tile_index].upper()}'
		tile = tileset.tiles[tile_index]

		res += f'{tile_label} = (*-{tileset.name}_tiles)/16\n'
		res += tile_to_asm(tile) + '\n'

	res += f'{tileset.name}_end:\n'

	return res

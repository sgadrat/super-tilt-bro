def tile_to_asm(tile):
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

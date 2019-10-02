from stblib import ensure
import re

class GameMod:
	def __init__(self, characters = None, tilesets = None):
		self.characters = characters if characters is not None else []
		self.tilesets = tilesets if tilesets is not None else []

	def check(self):
		# Self consistency check of characters
		for character in self.characters:
			character.check()

		# Check that no unique name is shared between characters
		character_names = []
		animation_names = []

		def ensure_unique_animation_name(anim):
			ensure(anim.name not in animation_names, 'multiple animations are named "{}"'.format(anim.name))

		for character in self.characters:
			ensure(character.name not in character_names, 'multiple characters are named "{}"'.format(character.name))
			character_names.append(character.name)

			ensure_unique_animation_name(character.victory_animation)
			ensure_unique_animation_name(character.defeat_animation)
			ensure_unique_animation_name(character.menu_select_animation)
			for anim in character.animations:
				ensure_unique_animation_name(anim)

		# Self consistency check of tilesets
		for tileset in self.tilesets:
			tileset.check()

		# Check that all tilesets are uniqueley named and not oversized
		tileset_names = []
		for tileset_index in range(len(self.tilesets)):
			tileset = self.tilesets[tileset_index]
			ensure(tileset.name is not None, 'tileset #{} is not named'.format(tileset_index))
			ensure(re.match('[a-z_][a-z0-9_]+', tileset.name) is not None, 'invalid tileset name "{}" (shall be lower case, numbers and underscores)'.format(tileset.name))
			ensure(tileset.name not in tileset_names, 'multiple tilesets are named "{}"'.format(tileset.name))
			ensure(len(tileset.tiles) <= 256)
			tileset_names.append(tileset.name)

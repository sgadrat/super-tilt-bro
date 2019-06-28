from stblib import ensure

class GameMod:
	def __init__(self, characters = None):
		self.characters = characters if characters is not None else []

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

#!/usr/bin/env python
from stblib import ensure
import json
import math
import os
import re
import stblib.asmformat.tiles
import stblib.asmformat.animations
import stblib.jsonformat
import stblib.utils
import sys
import textwrap

FIRST_AVAILABLE_BANK = 13

def text_asm(text, size, space_tile):
	"""
	Convert a string to a fixed-size sequence of tile indexes in assembly
	"""
	assert len(text) <= size

	padded_text = text.center(size)
	tiled_text = stblib.utils.str_to_tile_index(padded_text, special_cases = {' ':space_tile})
	assert len(tiled_text) == size

	res = ''
	for i in range(len(tiled_text)):
		char_index = tiled_text[i]
		res += stblib.utils.uintasm8(char_index)
		if i != size - 1:
			res += ', '

	return res

def compute_anim_duration_raw(anim):
	total_dur = 0
	for frame in anim.frames:
		total_dur += frame.duration
	return total_dur

def compute_anim_duration_pal(anim):
	return compute_anim_duration_raw(anim)

def compute_anim_duration_ntsc(anim):
	# In NTSC the animation engine double one out of five frames
	raw_dur = compute_anim_duration_raw(anim)
	return raw_dur + int(raw_dur / 5)

def expand_macros(source, game_dir, char):
	# State
	expanded_source_code = source # Source code with macros expanded
	defined = {} # Defined macro values
	source_pos = [{'file': '{}/states.asm'.format(char.name), 'line': 1}] # Current backtrace of files/lines being parsed

	# Helper functions
	def place_tpl_values(orig):
		"""
		Replace {place} patterns in a string by their value
		"""
		for name in defined:
			orig = orig.replace('{%s}' % (name,), defined[name])
		return orig

	def bt():
		"""
		Return a string indicating the current source files/lines being parsed.

		ex: kiki/states.asm:1391-tpl_grounded_attack.asm:5
			-> kiki/states.asm at line 1391 includes tpl_grounded_attack.asm and we are at line 5 of it.
		"""
		nonlocal source_pos
		str_bt = ''
		for frame in source_pos:
			if str_bt != '':
				str_bt += '-'
			str_bt += '{}:{}'.format(frame['file'], frame['line'])
		return str_bt

	# Macro handlers
	#  Each is a class with class attributes
	#   name - The identifier of the macro in source file (must exactly match the begining of macro invocation)
	#   regexp - Fine parsing of the macro
	#   parse_may_fail (optional) - if True, parse errors will be ignored (and the source left untouched)
	#   process - Function to do the job
	class IncludeHandler:
		name = '!include'
		regexp = re.compile('!include "(?P<src>[^"]+)"')
		def process(m):
			nonlocal source_pos
			source_pos.append({'file': m.group('src'), 'line': 1})

			rel_templates_dir = 'tools/compile-mod'
			templates_dir = '{}/{}'.format(game_dir, rel_templates_dir)
			template_path = '{}/{}'.format(templates_dir, m.group('src'))
			ensure(os.path.isfile(template_path), 'character {}\'s logic includes an non-existent template "{}"'.format(char.name, m.group('src')))
			with open(template_path, 'r') as template_file:
				return template_file.read() + '!return-include'

	class DefineHandler:
		name = '!define'
		regexp = re.compile('!define "(?P<name>[^"]+)" {(?P<value>[^}]+)}', flags=re.MULTILINE)
		def process(m):
			nonlocal defined, source_pos
			ensure(
				m.group('name') not in defined,
				'[{}] defining an already defined value: "{}"'.format(bt(), m.group('name'))
			)
			defined[m.group('name')] = m.group('value')
			source_pos[-1]['line'] += m.group('value').count('\n')
			return ''

	class UndefHandler:
		name = '!undef'
		regexp = re.compile('!undef "(?P<name>[^"]+)"')
		def process(m):
			nonlocal defined, source_pos
			ensure(
				m.group('name') in defined,
				'[{}] !undef on a value not already defined: {} ...'.format(bt(), expanded_source_code[pos:pos+20])
			)
			del defined[m.group('name')]
			return ''

	class PlaceHandler:
		name = '!place'
		regexp = re.compile('!place "(?P<name>[^"]+)"')
		def process(m):
			nonlocal defined, source_pos
			name = place_tpl_values(m.group('name'))
			ensure(name in defined, '[{}] unknown value to !place "{}" (resolved: "{}")'.format(bt(), m.group('name'), name))
			return defined[name]

	class ReturnIncludeHandler:
		name = '!return-include'
		regexp = re.compile('!return-include')
		def process(m):
			nonlocal source_pos
			del source_pos[-1]
			return ''

	class ShortPlaceHandler:
		name = '{'
		regexp = re.compile('\{(?P<name>[a-z_]+)\}')
		parse_may_fail = True
		def process(m):
			nonlocal defined, source_pos
			ensure(m.group('name') in defined, '[%s] unknown value to place: {%s}' % (bt(), m.group('name'),))
			return defined[m.group('name')]

	handlers = [
		IncludeHandler,
		DefineHandler,
		UndefHandler,
		PlaceHandler,
		ReturnIncludeHandler,
		ShortPlaceHandler,
	]

	# Scan the source to expand macros
	pos = 0
	while pos < len(expanded_source_code):
		for handler in handlers:
			if expanded_source_code[pos:pos+len(handler.name)] == handler.name:
				m = handler.regexp.search(expanded_source_code, pos)
				parsing_failed = m is None or m.start() != pos
				if parsing_failed and getattr(handler, 'parse_may_fail', False):
					continue

				ensure(
					not parsing_failed,
					'[{}] unparsable {}: {} ...'.format(
						bt(), handler.name, expanded_source_code[pos:pos+20]
					)
				)

				expanded_source_code = expanded_source_code[:m.start()] + handler.process(m) + expanded_source_code[m.end():]
				break
		else:
			if expanded_source_code[pos] == '\n':
				source_pos[-1]['line'] += 1
			pos += 1

	return expanded_source_code

def generate_character(char, game_dir):
	name_upper = char.name.upper()

	# Create destination directories
	rel_char_dir = 'game/data/characters/characters-data/{}'.format(char.name)
	rel_anim_dir = '{}/animations'.format(rel_char_dir)
	char_dir = '{}/{}'.format(game_dir, rel_char_dir)
	anim_dir = '{}/{}'.format(game_dir, rel_anim_dir)
	os.makedirs(char_dir)
	os.makedirs(anim_dir)

	# Label names that are used in multiple places
	tileset_label_name = '{}_chr_tiles'.format(char.name)
	illustrations_label_name = '{}_chr_illustrations'.format(char.name)
	primary_palettes_label_name = '{}_character_palettes'.format(char.name)
	alternate_palettes_label_name = '{}_character_alternate_palettes'.format(char.name)
	weapon_palettes_label_name = '{}_weapon_palettes'.format(char.name)
	properties_table_label_name = '{}_properties'.format(char.name)
	ai_attacks_table_label_name = '{}_ai_attacks'.format(char.name)
	ai_selectors_table_label_name = '{}_ai_selectors'.format(char.name)

	# Create character's master file
	master_file_path = '{}/{}.asm'.format(char_dir, char.name)
	with open(master_file_path, 'w') as master_file:
		master_file.write(textwrap.dedent("""\
			{name_upper}_BANK_NUMBER = CURRENT_BANK_NUMBER

			#include "{rel_char_dir}/chr_tiles.asm"
			#include "{rel_char_dir}/chr_illustrations.asm"
			#include "{rel_char_dir}/animations/animations.asm"
			#include "{rel_char_dir}/character_colors.asm"
			#include "{rel_char_dir}/properties.asm"
			#include "{rel_char_dir}/state_events.asm"
			#include "{rel_char_dir}/player_states.asm"
			#include "{rel_char_dir}/ai_data.asm"
			#include "{rel_char_dir}/ai.asm"
		""".format_map(locals())))

	# Tileset file
	chr_tiles_file_path = '{}/chr_tiles.asm'.format(char_dir)
	with open(chr_tiles_file_path, 'w') as chr_tiles_file:
		# Tileset label
		chr_tiles_file.write('{}:\n\n'.format(tileset_label_name))

		# Tiles in binary form, each with a label containing its index
		index_expression = '(*-{})/16'.format(tileset_label_name)
		for tile_index in range(len(char.tileset.tilenames)):
			tile = char.tileset.tiles[tile_index]
			tile_name = char.tileset.tilenames[tile_index]

			# Label containing tile's index
			chr_tiles_file.write('{} = {}\n'.format(tile_name, index_expression))

			# Tile data
			chr_tiles_file.write('{}\n\n'.format(stblib.asmformat.tiles.tile_to_asm(tile)))

		# Tileset footer
		chr_tiles_file.write(textwrap.dedent("""\
			{name_upper}_SPRITE_TILES_NUMBER = {index_expression}
			#print {name_upper}_SPRITE_TILES_NUMBER
			#if {name_upper}_SPRITE_TILES_NUMBER > 96
			#error too many sprites for character {name_upper}
			#endif
		""".format_map(locals())))

	# Illustrations file
	chr_illustrations_file_path = '{}/chr_illustrations.asm'.format(char_dir)
	with open(chr_illustrations_file_path, 'w') as chr_illustrations_file:
		# Illustrations label
		chr_illustrations_file.write('{}:\n\n'.format(illustrations_label_name))
		index_expression = '(*-{})/16'.format(illustrations_label_name)

		# Token illustration
		chr_illustrations_file.write(';\n; Token\n;\n\n')
		ensure(len(char.illustration_token.tilenames) == 1)
		ensure(len(char.illustration_token.tiles) == len(char.illustration_token.tilenames))
		chr_illustrations_file.write('{}\n\n'.format(stblib.asmformat.tiles.tile_to_asm(char.illustration_token.tiles[0])))

		# Small illustration
		chr_illustrations_file.write(';\n; Small\n;\n\n')
		ensure(len(char.illustration_small.tilenames) == 4)
		ensure(len(char.illustration_small.tiles) == len(char.illustration_small.tilenames))
		for tile_index in range(len(char.illustration_small.tilenames)):
			tile = char.illustration_small.tiles[tile_index]
			chr_illustrations_file.write('{}\n\n'.format(stblib.asmformat.tiles.tile_to_asm(tile)))

		# Large illustration
		chr_illustrations_file.write(';\n; Large\n;\n\n')
		ensure(len(char.illustration_large.tilenames) == 48)
		ensure(len(char.illustration_large.tiles) == len(char.illustration_large.tilenames))
		for tile_index in range(len(char.illustration_large.tilenames)):
			tile = char.illustration_large.tiles[tile_index]
			chr_illustrations_file.write('{}\n\n'.format(stblib.asmformat.tiles.tile_to_asm(tile)))

		# Illustration footer
		chr_illustrations_file.write(textwrap.dedent("""\
			{name_upper}_ILLUSTRATION_TILES_NUMBER = {index_expression}
			#print {name_upper}_ILLUSTRATION_TILES_NUMBER
			#if {name_upper}_ILLUSTRATION_TILES_NUMBER <> 53
			#error bad count of illustration tiles for character {name_upper}
			#endif
		""".format_map(locals())))

	# Palettes file
	character_colors_file_path = '{}/character_colors.asm'.format(char_dir)
	with open(character_colors_file_path, 'w') as character_colors_file:
		def write_palettes_table(palettes, label_name, description):
			def _c(i):
				return stblib.utils.intasm8(palette.colors[i])
			character_colors_file.write('; {}\n'.format(description))
			character_colors_file.write('{}:\n'.format(label_name))
			for palette in palettes:
				character_colors_file.write('.byt {}, {}, {}\n'.format(_c(0), _c(1), _c(2)))
			character_colors_file.write('\n')

		# Primary palettes
		write_palettes_table(
			char.color_swaps.primary_colors,
			primary_palettes_label_name,
			'Main palette for character'
		)

		# Alternate palettes
		write_palettes_table(
			char.color_swaps.alternate_colors,
			alternate_palettes_label_name,
			'Alternate palette to use to reflect special state'
		)

		# Secondary palettes
		write_palettes_table(
			char.color_swaps.secondary_colors,
			weapon_palettes_label_name,
			'Secondary palette for character'
		)

	# Character properties
	properties_file_path = '{}/properties.asm'.format(char_dir)
	with open(properties_file_path, 'w') as properties_file:
		# Propeties table's label
		properties_file.write('{}:\n'.format(properties_table_label_name))

		# Standard animations
		properties_file.write('VECTOR({})\n'.format(char.victory_animation.name))
		properties_file.write('VECTOR({})\n'.format(char.defeat_animation.name))
		properties_file.write('VECTOR({})\n'.format(char.menu_select_animation.name))

		# Character name
		properties_file.write('.byt {} ; {}\n'.format(text_asm(char.name, 10, 2), char.name))

		# Illustrations
		properties_file.write('VECTOR({}) ; Illustrations begining\n'.format(illustrations_label_name))

		# AI
		properties_file.write('VECTOR({}) ; AI selectors\n'.format(ai_selectors_table_label_name))
		properties_file.write('.byt {} ; Number of AI attacks\n'.format(len(char.ai.attacks)))
		properties_file.write('VECTOR({}) ; AI attacks\n'.format(ai_attacks_table_label_name))

	# State events
	state_events_file_path = '{}/state_events.asm'.format(char_dir)
	with open(state_events_file_path, 'w') as state_events_file:
		# State count
		state_events_file.write('{}_NUM_STATES = {}\n\n'.format(name_upper, len(char.states)))

		# Routines tables
		for routine_type in ['start', 'update', 'offground', 'onground', 'input', 'onhurt']:
			state_events_file.write('{}_state_{}_routines:\n'.format(char.name, routine_type))
			for state in char.states:
				routine_name = getattr(state, '{}_routine'.format(routine_type))
				ensure(routine_name is not None or routine_type == 'start', 'in {}\'s state {}, missing {} routine'.format(char.name, state.name, routine_type))

				if routine_name is not None:
					state_events_file.write('STATE_ROUTINE({}) ; {}\n'.format(routine_name, state.name))
			state_events_file.write('\n')

	# Character's logic
	expanded_source_code = expand_macros(char.sourcecode, game_dir, char)
	player_states_file_path = '{}/player_states.asm'.format(char_dir)
	with open(player_states_file_path, 'w') as player_states_file:
		player_states_file.write(expanded_source_code)

	# Animations
	rel_animations_path = []
	def write_animation_file(anim):
		rel_anim_file_path = '{}/{}.asm'.format(rel_anim_dir, anim.name)
		anim_file_path = '{}/{}'.format(game_dir, rel_anim_file_path)

		with open(anim_file_path, 'w') as anim_file:
			anim_file.write('{}_dur_pal = {}\n'.format(anim.name, compute_anim_duration_pal(anim)))
			anim_file.write('{}_dur_ntsc = {}\n'.format(anim.name, compute_anim_duration_ntsc(anim)))
			anim_file.write(stblib.asmformat.animations.animation_to_asm(anim))
		rel_animations_path.append(rel_anim_file_path)

	write_animation_file(char.victory_animation)
	write_animation_file(char.defeat_animation)
	write_animation_file(char.menu_select_animation)
	for anim in char.animations:
		write_animation_file(anim)

	master_animations_file_path = '{}/animations.asm'.format(anim_dir)
	with open(master_animations_file_path, 'w') as master_animations_file:
		for rel_anim_file_path in rel_animations_path:
			master_animations_file.write('#include "{}"\n'.format(rel_anim_file_path))

	# AI
	custom_ai_file_path = '{}/ai.asm'.format(char_dir)
	with open(custom_ai_file_path, 'w') as custom_ai_file:
		custom_ai_file.write(char.ai.sourcecode)

	ai_data_file_path = '{}/ai_data.asm'.format(char_dir)
	with open(ai_data_file_path, 'w') as ai_data_file:
		# Attacks
		ai_data_file.write('{}:\n'.format(ai_attacks_table_label_name))
		ai_data_file.write('; LSBs\n')
		for attack in char.ai.attacks:
			ai_data_file.write('AI_ATTACK_HITBOX({}, ${:02x}, ${:02x}, ${:02x}, ${:02x})\n'.format(
				stblib.utils.uint16lsb(attack.constraints),
				stblib.utils.int16lsb(attack.hitbox.left),
				stblib.utils.int16lsb(attack.hitbox.right),
				stblib.utils.int16lsb(attack.hitbox.top),
				stblib.utils.int16lsb(attack.hitbox.bottom)
			))
			ai_data_file.write('.byt <{}\n'.format(attack.action))
		ai_data_file.write('; MSBs\n')
		for attack in char.ai.attacks:
			ai_data_file.write('AI_ATTACK_HITBOX({}, ${:02x}, ${:02x}, ${:02x}, ${:02x})\n'.format(
				stblib.utils.uint16msb(attack.constraints),
				stblib.utils.int16msb(attack.hitbox.left),
				stblib.utils.int16msb(attack.hitbox.right),
				stblib.utils.int16msb(attack.hitbox.top),
				stblib.utils.int16msb(attack.hitbox.bottom)
			))
			ai_data_file.write('.byt >{}\n'.format(attack.action))
		ai_data_file.write('\n')

		# Selectors
		ai_data_file.write('{}:\n'.format(ai_selectors_table_label_name))
		for selector in char.ai.action_selectors:
			ai_data_file.write('VECTOR({})\n'.format(selector))
		ai_data_file.write('\n')

		# Actions
		for action in char.ai.actions:
			ai_data_file.write('{}_ai_action_{}:\n'.format(char.name, action.name))
			for step in action.steps:
				ai_data_file.write('AI_ACTION_STEP({}, {})\n'.format(step.input, step.duration))
			ai_data_file.write('AI_ACTION_END_STEPS\n')

def generate_characters_index(characters, game_dir):
	characters_index_file_path = '{}/game/data/characters/characters-index.asm'.format(game_dir)
	with open(characters_index_file_path, 'w') as characters_index_file:
		def _w(s):
			characters_index_file.write(s)

		def _w_table(desc, name, value):
			if desc is not None and len(desc) > 0:
				_w('; {}\n'.format(desc))
			_w('{}:\n'.format(name))
			for char in characters:
				_w('.byt {} ; {}\n'.format(value(char), char.name.capitalize()))
			_w('\n')

		def _w_routine_table(routine_type):
			_w_table(
				'',
				'characters_{}_routines_table_lsb'.format(routine_type),
				lambda c: '<{}_state_{}_routines'.format(c.name, routine_type)
			)
			_w_table(
				'',
				'characters_{}_routines_table_msb'.format(routine_type),
				lambda c: '>{}_state_{}_routines'.format(c.name, routine_type)
			)

		_w('; Number of characters referenced in following tables\n')
		_w('CHARACTERS_NUMBER = {}\n\n'.format(len(characters)))

		_w_table(
			'Bank in which each character is stored',
			'characters_bank_number',
			lambda c: '{}_BANK_NUMBER'.format(c.name.upper())
		)
		_w_table(
			'Begining of tiles data for each character',
			'characters_tiles_data_lsb',
			lambda c: '<{}_chr_tiles'.format(c.name)
		)
		_w_table(
			'',
			'characters_tiles_data_msb',
			lambda c: '>{}_chr_tiles'.format(c.name)
		)
		_w_table(
			'Number of CHR tiles per character',
			'characters_tiles_number',
			lambda c: '{}_SPRITE_TILES_NUMBER'.format(c.name.upper())
		)
		_w_table(
			'Character properties',
			'characters_properties_lsb',
			lambda c: '<{}_properties'.format(c.name)
		)
		_w_table(
			'',
			'characters_properties_msb',
			lambda c: '>{}_properties'.format(c.name)
		)
		_w_table(
			'',
			'characters_palettes_lsb',
			lambda c: '<{}_character_palettes'.format(c.name)
		)
		_w_table(
			'',
			'characters_palettes_msb',
			lambda c: '>{}_character_palettes'.format(c.name)
		)
		_w_table(
			'',
			'characters_alternate_palettes_lsb',
			lambda c: '<{}_character_alternate_palettes'.format(c.name)
		)
		_w_table(
			'',
			'characters_alternate_palettes_msb',
			lambda c: '>{}_character_alternate_palettes'.format(c.name)
		)
		_w_table(
			'',
			'characters_weapon_palettes_lsb',
			lambda c: '<{}_weapon_palettes'.format(c.name)
		)
		_w_table(
			'',
			'characters_weapon_palettes_msb',
			lambda c: '>{}_weapon_palettes'.format(c.name)
		)
		_w_table(
			'Routine to load character specific state from network',
			'characters_netload_routine_lsb',
			lambda c: '<{}'.format(c.netload_routine)
		)
		_w_table(
			'',
			'characters_netload_routine_msb',
			lambda c: '>{}'.format(c.netload_routine)
		)

		_w('; Begining of character\'s jump tables\n')
		for routine_type in ['start', 'update', 'offground', 'onground', 'input', 'onhurt']:
			_w_routine_table(routine_type)

def generate_tileset(tileset, game_dir):
	name_upper = tileset.name.upper()

	# Compute some useful values
	rel_tileset_dir = 'game/data/tilesets'
	tileset_dir = '{}/{}'.format(game_dir, rel_tileset_dir)
	tileset_filename = '{}/{}.asm'.format(tileset_dir, tileset.name)
	tileset_label_name = 'tileset_{}'.format(tileset.name)

	# Generate tileset file
	with open(tileset_filename, 'w') as tileset_file:
		def _w(s):
			tileset_file.write(s)

		# Bank number
		_w('TILESET_{}_BANK_NUMBER = CURRENT_BANK_NUMBER\n\n'.format(name_upper))

		# Tileset label
		_w('{}:\n\n'.format(tileset_label_name))

		# Tileset size
		_w('; Tileset\'s size in tiles (zero means 256)\n')
		_w('.byt {}\n\n'.format(stblib.utils.uintasm8(len(tileset.tiles))))

		# Tiles in binary form, each with a label containing its index
		index_expression = '(*-({}+1))/16'.format(tileset_label_name)
		for tile_index in range(len(tileset.tilenames)):
			tile = tileset.tiles[tile_index]
			tile_name = tileset.tilenames[tile_index]

			# Label containing tile's index
			_w('{} = {}\n'.format(tile_name, index_expression))

			# Tile data
			_w('{}\n\n'.format(stblib.asmformat.tiles.tile_to_asm(tile)))

def generate_banks(char_to_bank, tileset_to_bank, game_dir):
	data_banks = []

	# Populate the bank index
	bank_index_file_path = '{}/game/extra_banks.asm'.format(game_dir)
	with open(bank_index_file_path, 'w') as bank_index_file:
		bank_index_file.write(textwrap.dedent("""\
			;
			; Contents of the 31 swappable banks
			;
			; The fixed bank is handled separately
			;


			#define CHR_BANK_NUMBER $00
			#define CURRENT_BANK_NUMBER CHR_BANK_NUMBER
			#include "game/banks/chr_data.asm"

			#define CURRENT_BANK_NUMBER $01
			#include "game/banks/data01_bank.asm"

			#define DATA_BANK_NUMBER $02
			#define CURRENT_BANK_NUMBER DATA_BANK_NUMBER
			#include "game/banks/data_bank.asm"
		"""))

		for bank_number in range(3, FIRST_AVAILABLE_BANK):
			bank_index_file.write(textwrap.dedent("""\

				#define CURRENT_BANK_NUMBER ${num:02x}
				#include "game/banks/data{num:02d}_bank.asm"
			""".format(num=bank_number)))

		for bank_number in range(FIRST_AVAILABLE_BANK, 31):
			bank_index_file.write('\n#define CURRENT_BANK_NUMBER {}\n'.format(stblib.utils.uintasm8(bank_number)))
			if bank_number in char_to_bank.values() or bank_number in tileset_to_bank.values():
				bank_index_file.write('#include "game/banks/data{:02d}_bank.built.asm"\n'.format(bank_number))
				if bank_number not in data_banks:
					data_banks.append(bank_number)
			else:
				bank_index_file.write('#include "game/banks/empty_bank.asm"\n')

	# Construct data banks
	for bank_number in data_banks:
		bank_file_path = '{}/game/banks/data{:02d}_bank.built.asm'.format(game_dir, bank_number)
		with open(bank_file_path, 'w') as bank_file:
			# Header
			bank_file.write(textwrap.dedent("""\
				#echo
				#echo ===== DATA{bank_number:02d}-BANK =====
				* = $8000

			""".format_map(locals())))

			# Data begining label
			bank_file.write('bank_data{bank_number:02d}_begin:\n'.format_map(locals()))

			# Characters includes
			for char_name in char_to_bank:
				if char_to_bank[char_name] == bank_number:
					bank_file.write(textwrap.dedent("""\
						bank_data{bank_number:02d}_character_{char_name}_begin:
						#include "game/data/characters/characters-data/{char_name}/{char_name}.asm"
						bank_data{bank_number:02d}_character_{char_name}_end:
					""".format_map(locals())))

			for tileset_name in tileset_to_bank:
				if tileset_to_bank[tileset_name] == bank_number:
					bank_file.write(textwrap.dedent("""\
						bank_data{bank_number:02d}_tileset_{tileset_name}_begin:
						#include "game/data/tilesets/{tileset_name}.asm"
						bank_data{bank_number:02d}_tileset_{tileset_name}_end:
					""".format_map(locals())))

			# Data end label
			bank_file.write('bank_data{bank_number:02d}_end:\n\n'.format_map(locals()))

			# Size statistics
			bank_file.write(textwrap.dedent("""\
				#echo
				#echo DATA{bank_number:02d}-bank data size:
				#print bank_data{bank_number:02d}_end-bank_data{bank_number:02d}_begin
			""".format_map(locals())))

			for char_name in char_to_bank:
				if char_to_bank[char_name] == bank_number:
					bank_file.write(textwrap.dedent("""\
						#echo
						#echo DATA{bank_number:02d}-bank {char_name} size:
						#print bank_data{bank_number:02d}_character_{char_name}_end-bank_data{bank_number:02d}_character_{char_name}_begin
					""".format_map(locals())))

			for tileset_name in tileset_to_bank:
				if tileset_to_bank[tileset_name] == bank_number:
					bank_file.write(textwrap.dedent("""\
						#echo
						#echo DATA{bank_number:02d}-bank {tileset_name} tileset size:
						#print bank_data{bank_number:02d}_tileset_{tileset_name}_end-bank_data{bank_number:02d}_tileset_{tileset_name}_begin
					""".format_map(locals())))

			bank_file.write(textwrap.dedent("""\
				#echo
				#echo DATA{bank_number:02d}-bank free space:
				#print $c000-*

			""".format_map(locals())))

			# Filler
			bank_file.write(textwrap.dedent("""\
				#if $c000-* < 0
				#error DATADATA{bank_number:02d} bank occupies too much space
				#else
				.dsb $c000-*, CURRENT_BANK_NUMBER
				#endif
			""".format_map(locals())))

def main():
	# Parse command line
	if len(sys.argv) < 3 or sys.argv[1] == '-h' or sys.argv[1] == '--help':
		print('Compile a game mod stored in JSON format to Super Tilt Bro. source files')
		print('')
		print('usage: {} game-mod-path super-tilt-bro-path')
		print('')
		return 1

	mod_file = sys.argv[1]
	ensure(os.path.isfile(mod_file), 'file not found: "{}"'.format(mod_file))

	game_dir = sys.argv[2]
	ensure(os.path.isdir(game_dir), 'directory not found: "{}"'.format(game_dir))
	game_dir = os.path.abspath(game_dir)
	if os.path.basename(game_dir) == 'game':
		gamedir = os.path.dirname(gamedir)
	ensure(os.path.isdir('{}/game'.format(game_dir)), '"game/" folder not found in source directory "{}"'.format(game_dir))

	# Parse mod
	with open(mod_file, 'r') as f:
		mod_dict = stblib.jsonformat.json_to_dict(f, os.path.dirname(mod_file))
	mod = stblib.dictformat.import_from_dict(mod_dict)
	mod.check()

	# Generate characters
	char_to_bank = {}
	current_bank = FIRST_AVAILABLE_BANK
	for character in mod.characters:
		if character.name not in char_to_bank:
			char_to_bank[character.name] = current_bank
			current_bank += 1

		generate_character(character, game_dir)

	# Generate shared character files
	generate_characters_index(mod.characters, game_dir)
	
	# Generate tilesets
	tileset_to_bank = {}
	current_bank = FIRST_AVAILABLE_BANK
	for tileset in mod.tilesets:
		tileset_to_bank[tileset.name] = current_bank
		current_bank += 1

		generate_tileset(tileset, game_dir)

	# Generate bank files
	generate_banks(char_to_bank, tileset_to_bank, game_dir)

	return 0

if __name__ == '__main__':
	sys.exit(main())

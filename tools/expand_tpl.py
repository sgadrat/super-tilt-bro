#!/usr/bin/env python
from stblib import ensure
import argparse
import os
import sys
import re

def expand(source, game_dir, filename, templates_dir):
	# State
	expanded_source_code = source # Source code with macros expanded
	defined = {} # Defined macro values
	source_pos = [{'file': '{}/states.asm'.format(filename), 'line': 1}] # Current backtrace of files/lines being parsed

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

			template_path = '{}/{}'.format(templates_dir, m.group('src'))
			ensure(os.path.isfile(template_path), '[{}] including an non-existent template "{}"'.format(bt(), m.group('src')))
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

def main():
	# Parse command line
	parser = argparse.ArgumentParser(description='Expand macros in a template file.')
	parser.add_argument('input', help='Path to the file to expand')
	parser.add_argument('super-tilt-bro-path', help='Path to game\'s source')
	parser.add_argument('--tpl-dir', default='.', help='Base dir for includes in templates')

	args = parser.parse_args()

	source_file = getattr(args, 'input')
	ensure(os.path.isfile(source_file), 'file not found: "{}"'.format(source_file))

	game_dir = getattr(args, 'super-tilt-bro-path')
	ensure(os.path.isdir(game_dir), 'directory not found: "{}"'.format(game_dir))
	game_dir = os.path.abspath(game_dir)
	if os.path.basename(game_dir) == 'game':
		gamedir = os.path.dirname(gamedir)
	ensure(os.path.isdir('{}/game'.format(game_dir)), '"game/" folder not found in source directory "{}"'.format(game_dir))

	templates_dir = args.tpl_dir
	ensure(os.path.isdir(templates_dir), 'directory not found: "{}"'.format(templates_dir))
	templates_dir = os.path.abspath(templates_dir)

	# Expand file
	source = None
	with open(source_file, 'r') as f:
		source = f.read()
	print(expand(source, game_dir, source_file, templates_dir))

	return 0

if __name__ == '__main__':
	sys.exit(main())

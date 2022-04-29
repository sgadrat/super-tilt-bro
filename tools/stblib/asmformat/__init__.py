from stblib.asmformat import animations, stages, tiles

def to_asm(obj, visibility=''):
	"""
	Serialize any (supported) object to assembly format
	"""
	serial_function_name = '{}_to_asm'.format(obj.__class__.__name__.lower())
	candidate_modules = []
	for module in [animations, stages, tiles]:
		if hasattr(module, serial_function_name):
			candidate_modules.append(module)

	if len(candidate_modules) > 1:
		# Before raising, check if there is one module matching "module.__name__ == obj.__module__.__name__"
		# this is not 100% accurate since we compare modules names from stblib and from stblib.asmformat,
		# but better than just aborting
		better_candidates = []
		for module in candidate_modules:
			if module.__name__ == obj.__module__.__name__:
				better_candidates.append(module)

		if len(better_candidates) != 1:
			raise Exception('Multiple candidates for serializing objects of type "{}": {}'.format(obj.__class__.__name__, [x.__name__ for x in candidate_modules]))

		sys.stderr.write('warning: half ambiguous call to to_asm(): selected {} module from [{}] capable of serializing object of type {}'.format(better_candidates[0].__name__, [x.__name__ for x in candidate_modules], {obj.__class__.__name__}))
		candidate_modules = better_candidates
	elif len(candidate_modules) == 0:
		raise Exception(f'No serialization function found for objects of type "{obj.__class__.__name__}"')

	module = candidate_modules[0]
	return getattr(module, serial_function_name)(obj, visibility=visibility)

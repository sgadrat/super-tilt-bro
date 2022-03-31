from stblib.asmformat import animations, stages, tiles

def to_asm(obj):
	"""
	Serialize any (supported) object to assembly format
	"""
	#TODO detect ambiguous class names (and find a way to work around it)
	parse_function_name = '{}_to_asm'.format(obj.__class__.__name__.lower())
	for module in [animations, stages, tiles]:
		if hasattr(module, parse_function_name):
			return getattr(module, parse_function_name)(obj)
	raise Exception(f'No serialization function found for objects of type "{obj.__class__.__name__}"')

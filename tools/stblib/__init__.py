class ValidationError(Exception):
	"""
	Error that should not happen but can only be asserted at runtime, like bad user input or inconsistant data in a file
	"""
	pass

def ensure(condition, msg = None):
	"""
	An equivalent to assert that cannot disapear at runtime
	"""
	if not condition:
		raise ValidationError(msg)

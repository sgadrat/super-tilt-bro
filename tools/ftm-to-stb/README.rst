ftm-to-stb
==========

ftm-to-stb is a tool to convert tracker's files to Super Tilt Bro's audio engine's internal format. It takes a file following the Famitracker's text export format as input and outputs a json with stuff of varying interest.

Interesing properties
---------------------

``.src.value`` is an assembly source that can be included as is for compilation in Super Tilt Bro.

``.mod`` is the JSON representation of audio data, in a similar way of ``game-mod`` format.

Note::

	game-mod can not yet store audio data. Once it can, this ftm-to-stb should
	be re-puposed to easilly update game-mod. Until then, it can be used to
	generate assembly to be hardcoded in game's source.

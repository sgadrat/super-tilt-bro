Constraints on netload routines
===============================

 * ``A``: output: Can be modified
 * ``X``: output: Can be modified, input: offset of stage's data in current message
 * ``Y``: output: Can be modified
 * ``player_number``: output: Can be modified

Sprites allocation in game
==========================

 * ``0`` -> ``15``: Player A's character animation
 * ``16`` -> ``31``: Player B's character animation
 * ``32`` -> ``41``: Targets in BTT stages // Available for the stage in versus
 * ``42`` -> ``49``: Target-break animation in BTT stage // Available for the stage in versus
 * ``50`` -> ``63``: Particles

Tile allocation in game
=======================

Sprite tiles
------------

 * ``0`` -> ``95``: Player A's character graphics
 * ``96`` -> ``191``: Player B's character graphics
 * ``192`` -> ``255``: Available for the stage and game mode

Beware, deprecated tileset in ``game/banks/chr_data.asm`` still copy stuff in "free" space, leaving ``192`` -> ``218`` blank, and initializing the ``219`` -> ``255`` to values that may be used (particles graphics, oos indicator, ...)

Helpful constants:

 * ``CHARACTERS_NUM_TILES_PER_CHAR``
 * ``CHARACTERS_CHARACTER_A_FIRST_TILE``
 * ``CHARACTERS_CHARACTER_B_FIRST_TILE``
 * ``CHARACTERS_CHARACTER_A_TILES_OFFSET``
 * ``CHARACTERS_CHARACTER_B_TILES_OFFSET``
 * ``CHARACTERS_END_TILES``
 * ``CHARACTERS_END_TILES_OFFSET``

Background tiles
----------------

 * ``0`` -> ``207``: Available for the stage and game mode
 * ``208`` -> ``218``: Characters stocks graphics
 * ``219`` -> ``229``: Numeric (plus "%") font for damage metter
 * ``230`` -> ``255``: Alpha font (unused? maybe important for gameover screen?)

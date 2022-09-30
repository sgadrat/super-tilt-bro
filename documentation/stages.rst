Constraints on netload routines
===============================

 * ``A``: output: Can be modified
 * ``X``: output: Can be modified, input: offset of stage's data in current message
 * ``Y``: output: Can be modified
 * ``player_number``: output: Can be modified

Constraints on fadeout routines
===============================

The fadeout routine is called to set a variant of the stage's background palette. There must be five variants::

 * 0: Full black
 * 1: Darkest visible palette
 * 2: Dark palette
 * 3: Slightly darkened palette
 * 4: Normal palette

The routine must not create a nametable buffer if called during rollback (applying changes on next non-rollback tick is acceptable.)

The stage's special effects must continue to work (ex: palette-swap based animations shall continue while darkened.)

Input::

 * ``X``: requested fade level

Output contraints::

 * ``A``: Can be modified
 * ``X``: Can be modified
 * ``Y``: Can be modified
 * ``player_number``: Cannot be modified
 * ``tmpfields``: Can be modified
 * ``stage_fade_level``: must be set to requested level

Sprites allocation in game
==========================

 * ``0`` -> ``15``: Player A's character animation
 * ``16`` -> ``31``: Player B's character animation
 * ``32`` -> ``41``: Targets in BTT stages // Available for the stage in versus
 * ``42`` -> ``49``: Target-break animation in BTT stage // Character's portrait in versus
 * ``50`` -> ``63``: Particles

Helpful constants:

 * ``INGAME_PLAYER_A_FIRST_SPRITE``
 * ``INGAME_PLAYER_A_LAST_SPRITE``
 * ``INGAME_PLAYER_B_FIRST_SPRITE``
 * ``INGAME_PLAYER_B_LAST_SPRITE``
 * ``INGAME_STAGE_FIRST_SPRITE``
 * ``INGAME_PORTRAIT_FIRST_SPRITE``
 * ``INGAME_PORTRAIT_LAST_SPRITE``
 * ``PARTICLE_FIRST_SPRITE``

Tile allocation in game
=======================

Sprite tiles
------------

 * ``0`` -> ``95``: Player A's character graphics
 * ``96`` -> ``191``: Player B's character graphics
 * ``192`` -> ``240``: Available for the stage and game mode
 * ``241`` -> ``247``: Common sprites (particles, out of screen bubble, ...)
 * ``248`` -> ``251``: Player A's portrait
 * ``252`` -> ``255``: Player B's portrait

Beware, deprecated tileset in ``game/banks/chr_data.asm`` still copy stuff in "free" space, leaving ``192`` -> ``218`` blank, and initializing the ``219`` -> ``255`` to values that may be used (particles graphics, oos indicator, ...)

Helpful constants:

 * ``CHARACTERS_NUM_TILES_PER_CHAR``
 * ``CHARACTERS_CHARACTER_A_FIRST_TILE``
 * ``CHARACTERS_CHARACTER_B_FIRST_TILE``
 * ``CHARACTERS_CHARACTER_A_TILES_OFFSET``
 * ``CHARACTERS_CHARACTER_B_TILES_OFFSET``
 * ``CHARACTERS_END_TILES``
 * ``CHARACTERS_END_TILES_OFFSET``
 * ``STAGE_FIRST_SPRITE_TILE``
 * ``STAGE_FIRST_SPRITE_TILE_OFFSET``
 * ``STAGE_NUM_SPRITE_TILES``
 * ``INGAME_COMMON_FIRST_SPRITE_TILE``
 * ``INGAME_COMMON_FIRST_SPRITE_TILE_OFFSET``
 * ``INGAME_CHARACTER_A_PORTRAIT_FIRST_SPRITE_TILE``
 * ``INGAME_CHARACTER_B_PORTRAIT_FIRST_SPRITE_TILE``

Background tiles
----------------

 * ``0`` -> ``207``: Available for the stage and game mode
 * ``208`` -> ``218``: Characters stocks graphics
 * ``219`` -> ``229``: Numeric (plus "%") font for damage metter
 * ``230`` -> ``255``: Alpha font (unused? maybe important for gameover screen?)

Memory allocation
=================

 * ``$80`` -> ``$8f``: Available for the stage
 * ``$05dc`` -> ``$05ff``: Available for stage and game mode
 * ``$0400`` -> ``$0480``: Must begin with stage layout, after that it is freely usable by the stage
 * ``$0680`` -> ``$06ff``: Currently unused ingame it seems

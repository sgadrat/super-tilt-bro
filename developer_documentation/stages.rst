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

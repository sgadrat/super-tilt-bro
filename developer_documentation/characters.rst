Constraints on tick routines
============================

Registers
---------

 * ``A``: output: Can be modified
 * ``X``: output: cannot be modified not restored by check_player_position, used in loop by init_game_state), input: Contains player number
 * ``Y``: output: Can be modified
 * ``player_number``: output: to be checked if can be modified, input: not ensured to be set

Constraints on start routines
=============================

Tick routines constraints generally apply, as start routines are often called from a tick routine

Constraints on input routines
=============================

Constraints on onhurt routines
==============================

Registers
---------

 * ``A``: output: Can be modified, input: garbage
 * ``X``: output: Can be modified, input: player number
 * ``Y``: output: Can be modified, input: garbage
 * ``player_number``: output: to be checked if can be modified, input: to be checked if ensured to be good


Constraints on onground routines
================================

Constraints on offground routines
=================================

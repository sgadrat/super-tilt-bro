Constraints on netload routines
===============================

 * ``A``: output: Can be modified
 * ``X``: output: Can be modified, input: Contains player number
 * ``Y``: output: Must be incremented by character's payload size, input: offset of character's data in current message
 * ``player_number``: output: Cannot be modified, input: Contains player number

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
 * ``tmpfield10``: output: cannot be modified, input: Player number of the striker
 * ``tmpfield11``: output: cannot be modified, input: Player number of the stroke (equal to register X)
 * ``other tmpfields``: output: can be modified, input garbage


Constraints on onground routines
================================

Constraints on offground routines
=================================

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
 * ``X``: output: Cannot be modified, input: Contains player number
 * ``Y``: output: Can be modified
 * ``player_number``: output: Can be modified, input: not ensured to be set
 * ``tmpfields``: Can be modified
 * ``extra_tmpfields``: To be checked

Constraints on start routines
=============================

Tick routines constraints generally apply, as start routines are often called from a tick routine

 * ``A``: output: Can be modified
 * ``X``: output: cannot be modified
 * ``Y``: output: Can be modified
 * ``player_number``: output: to be checked, input: not ensured to be set
 * ``tmpfields``: Can be modified
 * ``extra_tmpfields``: To be checked

Constraints on input routines
=============================

 * ``A``: output: Can be modified
 * ``X``: output: Cannot be modified, input: Contains player number
 * ``Y``: output: Can be modified
 * ``player_number``: output: Can be modified, input: not ensured to be set
 * ``tmpfields``: Can be modified
 * ``extra_tmpfields``: To be checked

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

Custom hitboxes
===============

Most of the time you'd want to use direct hitbox, containing knockback and damage info to be handled automatically by the engine.

In some case, you may need more flexibility and here comes the custom hitbox. It is defined by setting hitbox enabled byte to ``2`` (instead of ``1`` for direct hitboxes), and a routine pointer in place of knockback parameters.

Constraints on the callback
---------------------------

 * ``A``: output: Can be modified, input: Garbage
 * ``X``: output: Can be modified, input: Player number
 * ``Y``: output: Can be modified, input: Type of the collided object (HITBOX or HURTBOX defined in global constants)
 * ``player_number``: output: Can be modified, input: Not ensured to be set
 * ``tmpfields``: output: can be modified, input: Garbage

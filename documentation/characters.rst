Editor
======

The characters editor can be found here: https://benoitryder.github.io/stb-mod-editor/#/tileset

Source code may be at two locations, choose the most up to date:

 * https://github.com/benoitryder/stb-mod-editor
 * https://github.com/sgadrat/stb-mod-editor

Characters animations
=====================

Sprites per scanline
--------------------

Animation frames should not have more than 4 sprites per scanline to not hit the limit (of 8) when both characters are on the same height.

Animations can occasionally place more than 4 sprites per scanline, but make it fast to come back to a compliant state.

Special case: the idle animation should not have more than 3 sprites per scanline, to limit its impact on stage's elements.


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
 * ``tmpfield15``: Used by aerial input code, aerial attacks should not modify it (or {char_name}_check_aerial_inputs should be fixed to use the stack/extra tmpfields)
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
 * ``Y``: output: Can be modified, input: Type of the collided object (``HITBOX`` or ``HURTBOX`` defined in global constants)
 * ``player_number``: output: Can be modified, input: Not ensured to be set
 * ``tmpfields``: output: can be modified, input: Garbage

When ``Y`` is set to ``HITBOX`` the callback is responsible for consequences of the collision::

 * On the character it controls,
 * On the opponent if the opponent's hitbox is direct.

Direct hitboxes will not apply parry to their opponent when colliding to a custom hitbox.

When ``Y`` is set to ``HITBOX`` the hitbox type should not be changed to ``HITBOX_DISABLED`` if the result is a parry. (Quirk in the engine, relying on hitboxes staying active in parry to apply it correctly to both player. May change with a future rework of parry handling.)

Game modes
##########

Not to be mistaken for game mods.

Game modes are a series of hooks that can modify ingame state's behavior.

Currently implemented game modes
================================

 * ``local``: Handles the pause and the AI
 * ``online``: Handles netcode
 * ``arcade``: Handles the pause, the AI, break the target, and run to exit

Memory allocation
=================

Game modes can freely use the memory section begining at ``game_mode_state_begin`` and ending at ``game_mode_state_end`` (inclusive). This memory area is preserved during the entire ingame stage, but not between games.

Init hook
=========

Called after the generic initialization, but before stage initialization.

The initialization sequence is::

 * Generic initialization
 * Game mode initialization
 * Stage initialization

It means that game mode can modify what as been done by generic code, and the stage can further customize it. It goes from the most generic to the more specific.

Pre update hook
===============

Called at the before anything else in the game tick.

Output::

 * `Carry flag``: if set when returning from the hook, the game tick will be skipped

Gameover hook
=============

Called when the game is terminated (after the final slowdown.)

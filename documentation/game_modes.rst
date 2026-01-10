Game modes
##########

Not to be mistaken for game mods.

Game modes are a series of hooks that can modify ingame state's behavior.

Currently implemented game modes
================================

* ``local``: Handles the pause and the AI.
* ``online``: Handles netcode.
* ``arcade``: Handles the pause, the AI, break the target, and run to exit.
* ``server``: Like ``local``, without pause nor AI. Used to simulate an ``online`` game server-side.

Memory allocation
=================

Game modes can freely use the memory section begining at ``game_mode_state_begin`` and ending at ``game_mode_state_end`` (inclusive). This memory area is preserved during the entire ingame stage, but not between games.

Init hook
=========

Called after the generic initialization, but before stage initialization.

The initialization sequence is:

* Generic initialization
* Game mode initialization
* Stage initialization

It means that game mode can modify what as been done by generic code, and the stage can further customize it. It goes from the most generic to the more specific.

Pre update hook
===============

Called before anything else in the game tick.

Output:

* ``Carry flag``: if set when returning from the hook, the game tick will be skipped

Gameover hook
=============

Called when the game is terminated (after the final slowdown.)

It is expected to not return in nominal conditions. It should transition from ingame to another game state.

If it returns it is responsible to change the ingame state variables to something correct. Special care has to be taken of:

* ``Z flag``: set it to skip this frame as part of the slowdown, unset to play the frame normally,
* ``slow_down_counter``: it is garbage when the hook is called, put it to some value to continue to slowdown or to zero to continue at normal speed,
* ``player_*_state`` and friends: the game engine guarantees nothing on players states, especially when gameover is triggered by the game mode. Set player states in a correct state, or ensure your game mode knows their state is correct before returning.

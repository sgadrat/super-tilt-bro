Game loop
#########

The Super Tilt Bro.'s main loop is implemented in `nine/main.asm`, it handles ticking the music engine at the same speed in PAL and NTSC systems as well as ticking the gobal game state regularily. The global game state is ticked at 50 FPS on PAL systems and can be ticked at 60 or 50 FPS on NTSC systems.

There are a lot of global game states possible, essentially one per menu screen. Here, we will discuss the `game` global game state which handles gameplay.

Game initialization
###################

TODO:

- What's needed to correctly init `game` state
	- game modes, link to game_modes.rst
	- characters

Game Tick
#########

The tick code is in `game/logic/game_states/game/game_logic.asm`, in fixed bank.

- Reset temporary velocity
- Tick game mode (which can decide to early abort the tick)
- Shake screen and do nothing until shaking is over
- Do nothing during a slowdown skipped frame
- Call stage's logic
- Update game state
	- Decrement hitstun counters
	- Check hitbox collisions
	- Update both players
	- Updates that impact both players
	- Move characters, and check position-dependent events (like being behind blastlines)
- Update screen
	- Character-dependent screen updating routines
	- Deathplosion
	- Characters animations

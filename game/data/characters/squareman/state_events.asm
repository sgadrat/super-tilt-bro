SQUAREMAN_NUM_STATES = 4

squareman_state_start_routines:
STATE_ROUTINE(squareman_start_thrown)
STATE_ROUTINE(squareman_start_respawn)
STATE_ROUTINE(squareman_start_innexistant)
STATE_ROUTINE(squareman_start_spawn)

squareman_state_update_routines:
STATE_ROUTINE(squareman_tick_thrown)
STATE_ROUTINE(squareman_tick_respawn)
STATE_ROUTINE(squareman_tick_innexistant)
STATE_ROUTINE(squareman_tick_spawn)

squareman_state_offground_routines:
STATE_ROUTINE(dummy_routine) ; Thrown
STATE_ROUTINE(dummy_routine) ; Respawn
STATE_ROUTINE(dummy_routine) ; Innexistant
STATE_ROUTINE(dummy_routine) ; Spawn

squareman_state_onground_routines:
STATE_ROUTINE(dummy_routine) ; Thrown
STATE_ROUTINE(dummy_routine) ; Respawn
STATE_ROUTINE(dummy_routine) ; Innexistant
STATE_ROUTINE(dummy_routine) ; Spawn

squareman_state_input_routines:
STATE_ROUTINE(dummy_routine) ; Thrown
STATE_ROUTINE(dummy_routine) ; Respawn
STATE_ROUTINE(dummy_routine) ; Innexistant
STATE_ROUTINE(dummy_routine) ; Spawn

squareman_state_onhurt_routines:
STATE_ROUTINE(hurt_player) ; Thrown
STATE_ROUTINE(dummy_routine) ; Respawn
STATE_ROUTINE(dummy_routine) ; Innexistant
STATE_ROUTINE(dummy_routine) ; Spawn

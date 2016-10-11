#define STATE_ROUTINE(x) .byt >(x-1), <(x-1)
sinbad_state_update_routines:
STATE_ROUTINE(standing_player)
STATE_ROUTINE(running_player)
STATE_ROUTINE(falling_player)
STATE_ROUTINE(jumping_player)
STATE_ROUTINE(jabbing_player)
STATE_ROUTINE(thrown_player)
STATE_ROUTINE(respawn_player)
STATE_ROUTINE(side_tilt_player)
STATE_ROUTINE(special_player)
STATE_ROUTINE(side_special_player)
STATE_ROUTINE(helpless_player)

sinbad_state_offground_routines:
STATE_ROUTINE(start_falling_player) ; Standing
STATE_ROUTINE(start_falling_player) ; Running
STATE_ROUTINE(dummy_routine) ; Falling
STATE_ROUTINE(dummy_routine) ; Jumping
STATE_ROUTINE(start_falling_player) ; Jabbing
STATE_ROUTINE(start_falling_player) ; Thrown
STATE_ROUTINE(start_falling_player) ; Respawn
STATE_ROUTINE(dummy_routine) ; Side tilt
STATE_ROUTINE(dummy_routine) ; Special
STATE_ROUTINE(dummy_routine) ; Side special
STATE_ROUTINE(dummy_routine) ; Helpless

sinbad_state_onground_routines:
STATE_ROUTINE(dummy_routine) ; Standing
STATE_ROUTINE(dummy_routine) ; Running
STATE_ROUTINE(start_standing_player) ; Falling
STATE_ROUTINE(dummy_routine) ; Jumping
STATE_ROUTINE(dummy_routine) ; Jabbing
STATE_ROUTINE(dummy_routine) ; Thrown
STATE_ROUTINE(dummy_routine) ; Respawn
STATE_ROUTINE(dummy_routine) ; Side tilt
STATE_ROUTINE(dummy_routine) ; Special
STATE_ROUTINE(dummy_routine) ; Side special
STATE_ROUTINE(start_standing_player) ; Helpless

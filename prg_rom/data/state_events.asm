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
STATE_ROUTINE(landing_player)
STATE_ROUTINE(crashing_player)
STATE_ROUTINE(down_tilt_player)

sinbad_state_offground_routines:
STATE_ROUTINE(start_falling_player) ; Standing
STATE_ROUTINE(start_falling_player) ; Running
STATE_ROUTINE(dummy_routine) ; Falling
STATE_ROUTINE(dummy_routine) ; Jumping
STATE_ROUTINE(start_falling_player) ; Jabbing
STATE_ROUTINE(dummy_routine) ; Thrown
STATE_ROUTINE(start_falling_player) ; Respawn
STATE_ROUTINE(dummy_routine) ; Side tilt
STATE_ROUTINE(dummy_routine) ; Special
STATE_ROUTINE(dummy_routine) ; Side special
STATE_ROUTINE(dummy_routine) ; Helpless
STATE_ROUTINE(start_helpless_player) ; Landing
STATE_ROUTINE(start_helpless_player) ; Crashing
STATE_ROUTINE(dummy_routine) ; Down tilt

sinbad_state_onground_routines:
STATE_ROUTINE(dummy_routine) ; Standing
STATE_ROUTINE(dummy_routine) ; Running
STATE_ROUTINE(start_landing_player) ; Falling
STATE_ROUTINE(dummy_routine) ; Jumping
STATE_ROUTINE(dummy_routine) ; Jabbing
STATE_ROUTINE(thrown_player_on_ground) ; Thrown
STATE_ROUTINE(dummy_routine) ; Respawn
STATE_ROUTINE(dummy_routine) ; Side tilt
STATE_ROUTINE(dummy_routine) ; Special
STATE_ROUTINE(dummy_routine) ; Side special
STATE_ROUTINE(start_landing_player) ; Helpless
STATE_ROUTINE(dummy_routine) ; Landing
STATE_ROUTINE(dummy_routine) ; Crashing
STATE_ROUTINE(dummy_routine) ; Down tilt

sinbad_state_input_routines:
STATE_ROUTINE(standing_player_input) ; Standing
STATE_ROUTINE(running_player_input) ; Running
STATE_ROUTINE(check_aerial_inputs) ; Falling
STATE_ROUTINE(keep_input_dirty) ; Jumping
STATE_ROUTINE(keep_input_dirty) ; Jabbing
STATE_ROUTINE(thrown_player_input) ; Thrown
STATE_ROUTINE(keep_input_dirty) ; Respawn
STATE_ROUTINE(keep_input_dirty) ; Side tilt
STATE_ROUTINE(special_player_input) ; Special
STATE_ROUTINE(dummy_routine) ; Side special
STATE_ROUTINE(keep_input_dirty) ; Helpless
STATE_ROUTINE(keep_input_dirty) ; Landing
STATE_ROUTINE(keep_input_dirty) ; Crashing
STATE_ROUTINE(keep_input_dirty) ; Down tilt

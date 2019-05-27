#define STATE_ROUTINE(x) .byt >(x-1), <(x-1)
sinbad_state_update_routines:
STATE_ROUTINE(sinbad_tick_standing)
STATE_ROUTINE(sinbad_tick_running)
STATE_ROUTINE(sinbad_tick_falling)
STATE_ROUTINE(sinbad_tick_jumping)
STATE_ROUTINE(sinbad_tick_jabbing)
STATE_ROUTINE(sinbad_tick_thrown)
STATE_ROUTINE(sinbad_tick_respawn)
STATE_ROUTINE(sinbad_tick_side_tilt)
STATE_ROUTINE(sinbad_tick_special)
STATE_ROUTINE(sinbad_tick_side_special)
STATE_ROUTINE(sinbad_tick_helpless)
STATE_ROUTINE(sinbad_tick_landing)
STATE_ROUTINE(sinbad_tick_crashing)
STATE_ROUTINE(sinbad_tick_down_tilt)
STATE_ROUTINE(sinbad_tick_aerial_side)
STATE_ROUTINE(sinbad_tick_aerial_down)
STATE_ROUTINE(sinbad_tick_aerial_up)
STATE_ROUTINE(sinbad_tick_aerial_neutral)
STATE_ROUTINE(sinbad_tick_aerial_spe)
STATE_ROUTINE(sinbad_tick_spe_up)
STATE_ROUTINE(sinbad_tick_spe_down)
STATE_ROUTINE(sinbad_tick_up_tilt)
STATE_ROUTINE(sinbad_tick_shielding)
STATE_ROUTINE(sinbad_tick_innexistant)
STATE_ROUTINE(sinbad_tick_spawn)
STATE_ROUTINE(sinbad_tick_shieldlag)

sinbad_state_offground_routines:
STATE_ROUTINE(sinbad_start_falling) ; Standing
STATE_ROUTINE(sinbad_start_falling) ; Running
STATE_ROUTINE(dummy_routine) ; Falling
STATE_ROUTINE(dummy_routine) ; Jumping
STATE_ROUTINE(sinbad_start_falling) ; Jabbing
STATE_ROUTINE(dummy_routine) ; Thrown
STATE_ROUTINE(dummy_routine) ; Respawn
STATE_ROUTINE(dummy_routine) ; Side tilt
STATE_ROUTINE(dummy_routine) ; Special
STATE_ROUTINE(dummy_routine) ; Side special
STATE_ROUTINE(dummy_routine) ; Helpless
STATE_ROUTINE(sinbad_start_helpless) ; Landing
STATE_ROUTINE(sinbad_start_helpless) ; Crashing
STATE_ROUTINE(dummy_routine) ; Down tilt
STATE_ROUTINE(dummy_routine) ; Aerial side
STATE_ROUTINE(dummy_routine) ; Aerial down
STATE_ROUTINE(dummy_routine) ; Aerial up
STATE_ROUTINE(dummy_routine) ; Aerial neutral
STATE_ROUTINE(dummy_routine) ; Aerial special neutral
STATE_ROUTINE(dummy_routine) ; Special up
STATE_ROUTINE(dummy_routine) ; Special down
STATE_ROUTINE(dummy_routine) ; Up tilt
STATE_ROUTINE(sinbad_start_helpless) ; Shielding
STATE_ROUTINE(dummy_routine) ; Innexistant
STATE_ROUTINE(dummy_routine) ; Spawn
STATE_ROUTINE(sinbad_start_helpless) ; Shield lag

sinbad_state_onground_routines:
STATE_ROUTINE(dummy_routine) ; Standing
STATE_ROUTINE(dummy_routine) ; Running
STATE_ROUTINE(sinbad_start_landing) ; Falling
STATE_ROUTINE(dummy_routine) ; Jumping
STATE_ROUTINE(dummy_routine) ; Jabbing
STATE_ROUTINE(thrown_player_on_ground) ; Thrown
STATE_ROUTINE(dummy_routine) ; Respawn
STATE_ROUTINE(dummy_routine) ; Side tilt
STATE_ROUTINE(dummy_routine) ; Special
STATE_ROUTINE(dummy_routine) ; Side special
STATE_ROUTINE(sinbad_start_landing) ; Helpless
STATE_ROUTINE(dummy_routine) ; Landing
STATE_ROUTINE(dummy_routine) ; Crashing
STATE_ROUTINE(dummy_routine) ; Down tilt
STATE_ROUTINE(sinbad_start_landing) ; Aerial side
STATE_ROUTINE(sinbad_start_landing) ; Aerial down
STATE_ROUTINE(sinbad_start_landing) ; Aerial up
STATE_ROUTINE(sinbad_start_landing) ; Aerial neutral
STATE_ROUTINE(sinbad_start_landing) ; Aerial special neutral
STATE_ROUTINE(dummy_routine) ; Special up
STATE_ROUTINE(dummy_routine) ; Special down
STATE_ROUTINE(dummy_routine) ; Up tilt
STATE_ROUTINE(dummy_routine) ; Shielding
STATE_ROUTINE(dummy_routine) ; Innexistant
STATE_ROUTINE(dummy_routine) ; Spawn
STATE_ROUTINE(dummy_routine) ; Shield lag

sinbad_state_input_routines:
STATE_ROUTINE(standing_player_input) ; Standing
STATE_ROUTINE(running_player_input) ; Running
STATE_ROUTINE(check_aerial_inputs) ; Falling
STATE_ROUTINE(jumping_player_input) ; Jumping
STATE_ROUTINE(jabbing_player_input) ; Jabbing
STATE_ROUTINE(thrown_player_input) ; Thrown
STATE_ROUTINE(respawn_player_input) ; Respawn
STATE_ROUTINE(keep_input_dirty) ; Side tilt
STATE_ROUTINE(special_player_input) ; Special
STATE_ROUTINE(dummy_routine) ; Side special
STATE_ROUTINE(keep_input_dirty) ; Helpless
STATE_ROUTINE(keep_input_dirty) ; Landing
STATE_ROUTINE(keep_input_dirty) ; Crashing
STATE_ROUTINE(keep_input_dirty) ; Down tilt
STATE_ROUTINE(keep_input_dirty) ; Aerial side
STATE_ROUTINE(keep_input_dirty) ; Aerial down
STATE_ROUTINE(keep_input_dirty) ; Aerial up
STATE_ROUTINE(keep_input_dirty) ; Aerial neutral
STATE_ROUTINE(dummy_routine) ; Aerial special neutral
STATE_ROUTINE(dummy_routine) ; Special up
STATE_ROUTINE(keep_input_dirty) ; Special down
STATE_ROUTINE(keep_input_dirty) ; Up tilt
STATE_ROUTINE(shielding_player_input) ; Shielding
STATE_ROUTINE(dummy_routine) ; Innexistant
STATE_ROUTINE(keep_input_dirty) ; Spawn
STATE_ROUTINE(keep_input_dirty) ; Shield lag

sinbad_state_onhurt_routines:
STATE_ROUTINE(hurt_player) ; Standing
STATE_ROUTINE(hurt_player) ; Running
STATE_ROUTINE(hurt_player) ; Falling
STATE_ROUTINE(hurt_player) ; Jumping
STATE_ROUTINE(hurt_player) ; Jabbing
STATE_ROUTINE(hurt_player) ; Thrown
STATE_ROUTINE(dummy_routine) ; Respawn
STATE_ROUTINE(hurt_player) ; Side tilt
STATE_ROUTINE(hurt_player) ; Special
STATE_ROUTINE(hurt_player) ; Side special
STATE_ROUTINE(hurt_player) ; Helpless
STATE_ROUTINE(hurt_player) ; Landing
STATE_ROUTINE(hurt_player) ; Crashing
STATE_ROUTINE(hurt_player) ; Down tilt
STATE_ROUTINE(hurt_player) ; Aerial side
STATE_ROUTINE(hurt_player) ; Aerial down
STATE_ROUTINE(hurt_player) ; Aerial up
STATE_ROUTINE(hurt_player) ; Aerial neutral
STATE_ROUTINE(hurt_player) ; Aerial special neutral
STATE_ROUTINE(hurt_player) ; Special up
STATE_ROUTINE(hurt_player) ; Special down
STATE_ROUTINE(hurt_player) ; Up tilt
STATE_ROUTINE(shielding_player_hurt) ; Shielding
STATE_ROUTINE(dummy_routine) ; Innexistant
STATE_ROUTINE(dummy_routine) ; Spawn
STATE_ROUTINE(hurt_player) ; Shield lag

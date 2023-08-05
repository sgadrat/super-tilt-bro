!define "char_name" {pepper}
!define "char_name_upper" {PEPPER}

;
; States index
;

PEPPER_STATE_THROWN = PLAYER_STATE_THROWN
PEPPER_STATE_RESPAWN_INVISIBLE = PLAYER_STATE_RESPAWN
PEPPER_STATE_INNEXISTANT = PLAYER_STATE_INNEXISTANT
PEPPER_STATE_SPAWN = PLAYER_STATE_SPAWN
PEPPER_STATE_OWNED = PLAYER_STATE_OWNED
PEPPER_STATE_IDLE = PLAYER_STATE_STANDING
PEPPER_STATE_RUNNING = PLAYER_STATE_RUNNING
PEPPER_STATE_FALLING = CUSTOM_PLAYER_STATES_BEGIN + 0
PEPPER_STATE_LANDING = CUSTOM_PLAYER_STATES_BEGIN + 1
PEPPER_STATE_CRASHING = CUSTOM_PLAYER_STATES_BEGIN + 2
PEPPER_STATE_HELPLESS = CUSTOM_PLAYER_STATES_BEGIN + 3
PEPPER_STATE_JUMPING = CUSTOM_PLAYER_STATES_BEGIN + 4
PEPPER_STATE_SHIELDING = CUSTOM_PLAYER_STATES_BEGIN + 5
PEPPER_STATE_SHIELDLAG = CUSTOM_PLAYER_STATES_BEGIN + 6
PEPPER_STATE_WALLJUMPING = CUSTOM_PLAYER_STATES_BEGIN + 7
PEPPER_STATE_DTILT = CUSTOM_PLAYER_STATES_BEGIN + 8
PEPPER_STATE_STILT = CUSTOM_PLAYER_STATES_BEGIN + 9
PEPPER_STATE_UTILT = CUSTOM_PLAYER_STATES_BEGIN + 10
PEPPER_STATE_FLASH_POTION = CUSTOM_PLAYER_STATES_BEGIN + 11
PEPPER_STATE_AERIAL_SIDE = CUSTOM_PLAYER_STATES_BEGIN + 12
PEPPER_STATE_AERIAL_FIREWORK = CUSTOM_PLAYER_STATES_BEGIN + 13
PEPPER_STATE_HYPERSPEED_LANDING = CUSTOM_PLAYER_STATES_BEGIN + 14
PEPPER_STATE_HYPERSPEED_CRASHING = CUSTOM_PLAYER_STATES_BEGIN + 15
PEPPER_STATE_AERIAL_WRENCH_GRAB = CUSTOM_PLAYER_STATES_BEGIN + 16
PEPPER_STATE_POTION_SMASH = CUSTOM_PLAYER_STATES_BEGIN + 17
PEPPER_STATE_SEND_CARROT = CUSTOM_PLAYER_STATES_BEGIN + 18
PEPPER_STATE_WITCH_FLY = CUSTOM_PLAYER_STATES_BEGIN + 19
PEPPER_STATE_TELEPORT = CUSTOM_PLAYER_STATES_BEGIN + 20
PEPPER_STATE_WRENCH_GRAB = CUSTOM_PLAYER_STATES_BEGIN + 21
PEPPER_STATE_DZZZ_CHARGE = CUSTOM_PLAYER_STATES_BEGIN + 22
PEPPER_STATE_DZZZ_STRIKE = CUSTOM_PLAYER_STATES_BEGIN + 23
PEPPER_STATE_RESPAWN_PLATFORM = CUSTOM_PLAYER_STATES_BEGIN + 24

;
; Gameplay constants
;

PEPPER_MAX_NUM_AERIAL_JUMPS = 1
PEPPER_ALL_SPECIAL_JUMPS = %10000001
PEPPER_WALL_JUMP_VELOCITY_H = $0100
PEPPER_WALL_JUMP_VELOCITY_V = $0480
PEPPER_WALL_JUMP_SQUAT_END = 4
PEPPER_AIR_FRICTION_STRENGTH = 7
PEPPER_AERIAL_DIRECTIONAL_INFLUENCE_STRENGTH = $80
PEPPER_AERIAL_SPEED = $0100
PEPPER_FASTFALL_SPEED = $0600
PEPPER_GROUND_FRICTION_STRENGTH = $40
PEPPER_JUMP_SQUAT_DURATION_PAL = 4
PEPPER_JUMP_SQUAT_DURATION_NTSC = 5
PEPPER_JUMP_SHORT_HOP_EXTRA_TIME_PAL = 4
PEPPER_JUMP_SHORT_HOP_EXTRA_TIME_NTSC = 5
PEPPER_JUMP_SHORT_HOP_AERIAL_TIME_PAL = 2 ;  Number of frames after jumpsquat at which an attack input stops converting is into a short hop-aerial
PEPPER_JUMP_SHORT_HOP_AERIAL_TIME_NTSC = 2
PEPPER_JUMP_POWER = $0540
PEPPER_JUMP_SHORT_HOP_POWER = $0102
PEPPER_LANDING_MAX_VELOCITY = $0200
PEPPER_RUNNING_INITIAL_VELOCITY = $0100
PEPPER_RUNNING_MAX_VELOCITY = $0180
PEPPER_RUNNING_ACCELERATION = $40
PEPPER_TECH_SPEED = $0400

PEPPER_CARROT_NOT_PLACED = $80

;
; Constants data
;

!include "characters/std_constant_tables.asm"

; Offset of 12 bytes reserved in player's object data for storing carrot's animation state
pepper_carrot_anim_per_player:
.byt (player_a_objects-stage_data)+1, (player_b_objects-stage_data)+1
pepper_carrot_anim_ptr_lsb_per_player:
.byt <(player_a_objects+1), <(player_b_objects+1)
pepper_carrot_anim_ptr_msb_per_player:
.byt >(player_a_objects+1), >(player_b_objects+1)

; Sprites reserved for carrot's animation
pepper_first_carrot_sprite_per_player:
.byt INGAME_PLAYER_A_LAST_SPRITE-1, INGAME_PLAYER_B_LAST_SPRITE-1
pepper_last_carrot_sprite_per_player:
.byt INGAME_PLAYER_A_LAST_SPRITE, INGAME_PLAYER_B_LAST_SPRITE
pepper_last_anim_sprite_per_player:
.byt INGAME_PLAYER_A_LAST_SPRITE-2, INGAME_PLAYER_B_LAST_SPRITE-2

pepper_netload:
.(
	cpx #0
	beq load_element
		ldx #player_b_objects-player_a_objects
	load_element:

	; Carrot's animation
	lda esp_rx_buffer+0, y
	sta player_a_objects+1+ANIMATION_STATE_OFFSET_X_LSB, x
	lda esp_rx_buffer+1, y
	sta player_a_objects+1+ANIMATION_STATE_OFFSET_X_MSB, x
	lda esp_rx_buffer+2, y
	sta player_a_objects+1+ANIMATION_STATE_OFFSET_Y_LSB, x
	lda esp_rx_buffer+3, y
	sta player_a_objects+1+ANIMATION_STATE_OFFSET_Y_MSB, x
	lda esp_rx_buffer+4, y
	sta player_a_objects+1+ANIMATION_STATE_OFFSET_DATA_VECTOR_LSB, x
	lda esp_rx_buffer+5, y
	sta player_a_objects+1+ANIMATION_STATE_OFFSET_DATA_VECTOR_MSB, x
	lda esp_rx_buffer+6, y
	sta player_a_objects+1+ANIMATION_STATE_OFFSET_DIRECTION, x
	lda esp_rx_buffer+7, y
	sta player_a_objects+1+ANIMATION_STATE_OFFSET_CLOCK, x
	;lda esp_rx_buffer+, y
	;sta player_a_objects+1+ANIMATION_STATE_OFFSET_FIRST_SPRITE_NUM, x ; Never change
	;lda esp_rx_buffer+, y
	;sta player_a_objects+1+ANIMATION_STATE_OFFSET_LAST_SPRITE_NUM, x ; Never change
	lda esp_rx_buffer+8, y
	sta player_a_objects+1+ANIMATION_STATE_OFFSET_FRAME_VECTOR_LSB, x
	lda esp_rx_buffer+9, y
	sta player_a_objects+1+ANIMATION_STATE_OFFSET_FRAME_VECTOR_MSB, x
	;TODO ANIMATION_STATE_OFFSET_NTSC_CNT

	; Update message's cursor
	tya
	clc
	adc #10
	tay

	rts
.)

pepper_init:
.(

	; Reserve two sprites for carrot
	.(
		animation_state_vector = tmpfield2

		; Animation's last sprite num = animation's last sprite num - 2
		lda anim_last_sprite_num_per_player_lsb, x
		sta animation_state_vector
		lda anim_last_sprite_num_per_player_msb, x
		sta animation_state_vector+1

		ldy #0
		lda pepper_last_anim_sprite_per_player, x
		sta (animation_state_vector), y

		; Same for out of screen indicator
		lda oos_last_sprite_num_per_player_lsb, x
		sta animation_state_vector
		lda oos_last_sprite_num_per_player_msb, x
		sta animation_state_vector+1

		;ldy #0 ; useless, already set above
		lda pepper_last_anim_sprite_per_player, x
		sta (animation_state_vector), y
	.)

	; Initialize carrot's animation state
	.(
		lda pepper_carrot_anim_ptr_lsb_per_player, x
		sta tmpfield11
		lda pepper_carrot_anim_ptr_msb_per_player, x
		sta tmpfield12
		lda #<pepper_anim_carrot
		sta tmpfield13
		lda #>pepper_anim_carrot
		sta tmpfield14
		jsr animation_init_state

		lda pepper_first_carrot_sprite_per_player, x
		ldy #ANIMATION_STATE_OFFSET_FIRST_SPRITE_NUM
		sta (tmpfield11), y
		lda pepper_last_carrot_sprite_per_player, x
		ldy #ANIMATION_STATE_OFFSET_LAST_SPRITE_NUM
		sta (tmpfield11), y

		lda #PEPPER_CARROT_NOT_PLACED
		ldy #ANIMATION_STATE_OFFSET_X_MSB
		sta (tmpfield11), y

		; Tick global onground as it reinits walljumps
		jmp pepper_global_onground
	.)

	;rts ; useless, jump to subrountine

	anim_last_sprite_num_per_player_msb:
		.byt >player_a_animation+ANIMATION_STATE_OFFSET_LAST_SPRITE_NUM
		.byt >player_b_animation+ANIMATION_STATE_OFFSET_LAST_SPRITE_NUM
	anim_last_sprite_num_per_player_lsb:
		.byt <player_a_animation+ANIMATION_STATE_OFFSET_LAST_SPRITE_NUM
		.byt <player_b_animation+ANIMATION_STATE_OFFSET_LAST_SPRITE_NUM

	oos_last_sprite_num_per_player_msb:
		.byt >player_a_out_of_screen_indicator+ANIMATION_STATE_OFFSET_LAST_SPRITE_NUM
		.byt >player_b_out_of_screen_indicator+ANIMATION_STATE_OFFSET_LAST_SPRITE_NUM
	oos_last_sprite_num_per_player_lsb:
		.byt <player_a_out_of_screen_indicator+ANIMATION_STATE_OFFSET_LAST_SPRITE_NUM
		.byt <player_b_out_of_screen_indicator+ANIMATION_STATE_OFFSET_LAST_SPRITE_NUM
.)

pepper_global_onground:
.(
	; Initialize special jump flags
	lda #PEPPER_ALL_SPECIAL_JUMPS
	sta player_a_special_jumps, x
	rts
.)

pepper_global_tick:
.(
	; Update carrot's animation
	lda pepper_carrot_anim_ptr_lsb_per_player, x
	sta tmpfield11
	lda pepper_carrot_anim_ptr_msb_per_player, x
	sta tmpfield12
	stx player_number

	lda network_rollback_mode
	bne drawn
		jsr animation_draw
	drawn:
	jsr animation_tick

	; Restore X register
	ldx player_number

	; Check if carrot has been hit
	.(
		; boxes_overlap parameters
		hitbox_left_pixel = tmpfield1 ; Rectangle 1 left (pixel)
		hitbox_right_pixel = tmpfield2 ; Rectangle 1 right (pixel)
		hitbox_top_pixel = tmpfield3 ; Rectangle 1 top (pixel)
		hitbox_bot_pixel = tmpfield4 ; Rectangle 1 bottom (pixel)
		hurtbox_left_pixel = tmpfield5 ; Rectangle 2 left (pixel)
		hurtbox_right_pixel = tmpfield6 ; Rectangle 2 right (pixel)
		hurtbox_top_pixel = tmpfield7 ; Rectangle 2 top (pixel)
		hurtbox_bot_pixel = tmpfield8 ; Rectangle 2 bottom (pixel)
		hitbox_left_screen = tmpfield9 ; Rectangle 1 left (screen)
		hitbox_right_screen = tmpfield10 ; Rectangle 1 right (screen)
		hitbox_top_screen = tmpfield11 ; Rectangle 1 top (screen)
		hitbox_bot_screen = tmpfield12 ; Rectangle 1 bottom (screen)
		hurtbox_left_screen = tmpfield13 ; Rectangle 2 left (screen)
		hurtbox_right_screen = tmpfield14 ; Rectangle 2 right (screen)
		hurtbox_top_screen = tmpfield15 ; Rectangle 2 top (screen)
		hurtbox_bot_screen = tmpfield16 ; Rectangle 2 bottom (screen)

		; Y = offset to carrot's animation
		ldy pepper_carrot_anim_per_player, x

		; Check that carrot is placed, else skip doing anything
		lda stage_data+ANIMATION_STATE_OFFSET_X_MSB, y
		cmp #PEPPER_CARROT_NOT_PLACED
		beq end_carrot_hit

		; Check if opponent's hitbox is active
		SWITCH_SELECTED_PLAYER
		lda player_a_hitbox_enabled, x
		beq end_carrot_hit

			; Store opponent's hitbox in collision routine parameters
			lda player_a_hitbox_left, x
			sta hitbox_left_pixel
			lda player_a_hitbox_right, x
			sta hitbox_right_pixel
			lda player_a_hitbox_top, x
			sta hitbox_top_pixel
			lda player_a_hitbox_bottom, x
			sta hitbox_bot_pixel

			lda player_a_hitbox_left_msb, x
			sta hitbox_left_screen
			lda player_a_hitbox_right_msb, x
			sta hitbox_right_screen
			lda player_a_hitbox_top_msb, x
			sta hitbox_top_screen
			lda player_a_hitbox_bottom_msb, x
			sta hitbox_bot_screen

			; Store carrot's hurtbox in collision routine parameters
			lda stage_data+ANIMATION_STATE_OFFSET_X_LSB, y
			sta hurtbox_left_pixel
			clc
			adc #8
			sta hurtbox_right_pixel
			lda stage_data+ANIMATION_STATE_OFFSET_X_MSB, y
			sta hurtbox_left_screen
			adc #0
			sta hurtbox_right_screen

			lda stage_data+ANIMATION_STATE_OFFSET_Y_LSB, y
			sta hurtbox_top_pixel
			clc
			adc #16
			sta hurtbox_bot_pixel
			lda stage_data+ANIMATION_STATE_OFFSET_Y_MSB, y
			sta hurtbox_top_screen
			adc #0
			sta hurtbox_bot_screen

			; Do the collision check
			jsr boxes_overlap
			bne end_carrot_hit

				; Carrot was hit, remove him
				lda #PEPPER_CARROT_NOT_PLACED
				sta stage_data+ANIMATION_STATE_OFFSET_X_MSB, y

		end_carrot_hit:
		ldx player_number
	.)

	rts
.)

; Input table for aerial moves, special values are
;  fast_fall - mandatorily on INPUT_NONE to take effect on release of DOWN
;  jump      - automatically choose between aerial jump or wall jump
;  no_input  - expected default
!input-table-define "PEPPER_AERIAL_INPUTS_TABLE" {
	CONTROLLER_INPUT_NONE               fast_fall
	CONTROLLER_INPUT_SPECIAL_RIGHT      pepper_start_dzzz_right
	CONTROLLER_INPUT_SPECIAL_LEFT       pepper_start_dzzz_left
	CONTROLLER_INPUT_JUMP               jump
	CONTROLLER_INPUT_JUMP_RIGHT         jump
	CONTROLLER_INPUT_JUMP_LEFT          jump
	CONTROLLER_INPUT_ATTACK_LEFT        pepper_start_aerial_side_left
	CONTROLLER_INPUT_ATTACK_RIGHT       pepper_start_aerial_side_right
	CONTROLLER_INPUT_DOWN_TILT          pepper_start_hyperspeed_landing
	CONTROLLER_INPUT_ATTACK_UP          pepper_start_aerial_firework
	CONTROLLER_INPUT_JAB                pepper_start_potion_smash
	CONTROLLER_INPUT_SPECIAL            pepper_start_plan_7b
	CONTROLLER_INPUT_SPECIAL_UP         pepper_start_witch_fly
	CONTROLLER_INPUT_SPECIAL_DOWN       pepper_start_aerial_wrench_grab
	CONTROLLER_INPUT_ATTACK_UP_LEFT     pepper_start_aerial_firework_left
	CONTROLLER_INPUT_ATTACK_UP_RIGHT    pepper_start_aerial_firework_right
	CONTROLLER_INPUT_SPECIAL_UP_RIGHT   pepper_start_witch_fly_right
	CONTROLLER_INPUT_SPECIAL_UP_LEFT    pepper_start_witch_fly_left
	CONTROLLER_INPUT_ATTACK_DOWN_LEFT   pepper_start_hyperspeed_landing_left
	CONTROLLER_INPUT_ATTACK_DOWN_RIGHT  pepper_start_hyperspeed_landing_right
	CONTROLLER_INPUT_SPECIAL_DOWN_LEFT  pepper_start_aerial_wrench_grab_left
	CONTROLLER_INPUT_SPECIAL_DOWN_RIGHT pepper_start_aerial_wrench_grab_right

	no_input
}

; Input table for idle state, special values are
;  no_input - Default
!input-table-define "PEPPER_IDLE_INPUTS_TABLE" {
	CONTROLLER_INPUT_LEFT                pepper_start_running_left
	CONTROLLER_INPUT_RIGHT               pepper_start_running_right
	CONTROLLER_INPUT_JUMP                pepper_start_jumping
	CONTROLLER_INPUT_JUMP_RIGHT          pepper_start_jumping_right
	CONTROLLER_INPUT_JUMP_LEFT           pepper_start_jumping_left
	CONTROLLER_INPUT_TECH                pepper_start_shielding
	CONTROLLER_INPUT_TECH_LEFT           pepper_start_shielding_left
	CONTROLLER_INPUT_TECH_RIGHT          pepper_start_shielding_right
	CONTROLLER_INPUT_DOWN_TILT           pepper_start_down_tilt
	CONTROLLER_INPUT_ATTACK_LEFT         pepper_start_side_tilt_left
	CONTROLLER_INPUT_ATTACK_RIGHT        pepper_start_side_tilt_right
	CONTROLLER_INPUT_SPECIAL_LEFT        pepper_start_dzzz_left
	CONTROLLER_INPUT_SPECIAL_RIGHT       pepper_start_dzzz_right
	CONTROLLER_INPUT_SPECIAL             pepper_start_plan_7b
	CONTROLLER_INPUT_SPECIAL_UP          pepper_start_witch_fly
	CONTROLLER_INPUT_SPECIAL_UP_LEFT     pepper_start_witch_fly_left
	CONTROLLER_INPUT_SPECIAL_UP_RIGHT    pepper_start_witch_fly_right
	CONTROLLER_INPUT_ATTACK_UP_LEFT      pepper_start_up_tilt_left
	CONTROLLER_INPUT_ATTACK_UP_RIGHT     pepper_start_up_tilt_right
	CONTROLLER_INPUT_ATTACK_UP           pepper_start_up_tilt
	CONTROLLER_INPUT_JAB                 pepper_start_flash_potion
	CONTROLLER_INPUT_SPECIAL_DOWN_LEFT   pepper_start_wrench_grab_left
	CONTROLLER_INPUT_SPECIAL_DOWN_RIGHT  pepper_start_wrench_grab_right
	CONTROLLER_INPUT_SPECIAL_DOWN        pepper_start_wrench_grab
	CONTROLLER_INPUT_ATTACK_DOWN_LEFT    pepper_start_down_tilt_left
	CONTROLLER_INPUT_ATTACK_DOWN_RIGHT   pepper_start_down_tilt_right

	no_input
}

; Input table for running state, special values are
;  input_running_left - Change running direction to the left (if not already running to the left)
;  input_runnning_right - Change running direction to the right (if not already running to the right)
!input-table-define "PEPPER_RUNNING_INPUTS_TABLE" {
	CONTROLLER_INPUT_LEFT                input_running_left
	CONTROLLER_INPUT_RIGHT               input_running_right
	CONTROLLER_INPUT_JUMP                pepper_start_jumping
	CONTROLLER_INPUT_JUMP_LEFT           pepper_start_jumping_left
	CONTROLLER_INPUT_JUMP_RIGHT          pepper_start_jumping_right
	CONTROLLER_INPUT_TECH                pepper_start_shielding
	CONTROLLER_INPUT_TECH_LEFT           pepper_start_shielding
	CONTROLLER_INPUT_TECH_RIGHT          pepper_start_shielding
	CONTROLLER_INPUT_DOWN_TILT           pepper_start_down_tilt
	CONTROLLER_INPUT_ATTACK_LEFT         pepper_start_side_tilt_left
	CONTROLLER_INPUT_ATTACK_RIGHT        pepper_start_side_tilt_right
	CONTROLLER_INPUT_SPECIAL_LEFT        pepper_start_dzzz_left
	CONTROLLER_INPUT_SPECIAL_RIGHT       pepper_start_dzzz_right
	CONTROLLER_INPUT_SPECIAL             pepper_start_plan_7b
	CONTROLLER_INPUT_SPECIAL_UP          pepper_start_witch_fly
	CONTROLLER_INPUT_SPECIAL_UP_LEFT     pepper_start_witch_fly_left
	CONTROLLER_INPUT_SPECIAL_UP_RIGHT    pepper_start_witch_fly_right
	CONTROLLER_INPUT_SPECIAL_UP_LEFT     pepper_start_up_tilt_left
	CONTROLLER_INPUT_ATTACK_UP_RIGHT     pepper_start_up_tilt_right
	CONTROLLER_INPUT_ATTACK_UP           pepper_start_up_tilt
	CONTROLLER_INPUT_JAB                 pepper_start_flash_potion
	CONTROLLER_INPUT_SPECIAL_DOWN_LEFT   pepper_start_wrench_grab_left
	CONTROLLER_INPUT_SPECIAL_DOWN_RIGHT  pepper_start_wrench_grab_right
	CONTROLLER_INPUT_SPECIAL_DOWN        pepper_start_wrench_grab
	CONTROLLER_INPUT_ATTACK_DOWN_LEFT    pepper_start_down_tilt_left
	CONTROLLER_INPUT_ATTACK_DOWN_RIGHT   pepper_start_down_tilt_right

	pepper_start_idle
}

; Input table for jumping state state (only used during jumpsquat), special values are
;  no_input - default
!input-table-define "PEPPER_JUMPSQUAT_INPUTS_TABLE" {
	CONTROLLER_INPUT_ATTACK_UP        pepper_start_up_tilt
	CONTROLLER_INPUT_ATTACK_UP_LEFT   pepper_start_up_tilt_left
	CONTROLLER_INPUT_ATTACK_UP_RIGHT  pepper_start_up_tilt_right
	CONTROLLER_INPUT_SPECIAL_UP       pepper_start_witch_fly
	CONTROLLER_INPUT_SPECIAL_UP_LEFT  pepper_start_witch_fly_left
	CONTROLLER_INPUT_SPECIAL_UP_RIGHT pepper_start_witch_fly_right

	no_input
}

!include "characters/std_aerial_input.asm"
!include "characters/std_crashing.asm"
!include "characters/std_thrown.asm"
!include "characters/std_respawn.asm"
!include "characters/std_innexistant.asm"
!include "characters/std_spawn.asm"
!include "characters/std_idle.asm"
!include "characters/std_running.asm"
!include "characters/std_jumping.asm"
!include "characters/std_landing.asm"
!include "characters/std_helpless.asm"
!include "characters/std_shielding.asm"
!include "characters/std_walljumping.asm"
!include "characters/std_owned.asm"

;
; Aerial wrench grab
;

.(
	pepper_anim_aerial_wrench_grab_dur:
		.byt pepper_anim_aerial_wrench_grab_dur_pal, pepper_anim_aerial_wrench_grab_dur_ntsc

	pal_fall_immunity_dur = 20
	ntsc_fall_immunity_dur = pal_fall_immunity_dur + ((((pal_fall_immunity_dur)*10)/5)+9)/10
	pepper_anim_aerial_wrench_fall_time:
		.byt pepper_anim_aerial_wrench_grab_dur_pal - pal_fall_immunity_dur
		.byt pepper_anim_aerial_wrench_grab_dur_ntsc - ntsc_fall_immunity_dur

	&{char_name}_start_aerial_wrench_grab_left:
	.(
		lda #DIRECTION_LEFT2
		jmp {char_name}_start_aerial_wrench_grab_directional
	.)
	&{char_name}_start_aerial_wrench_grab_right:
	.(
		lda #DIRECTION_RIGHT2
		; Fallthrough to {char_name}_start_aerial_wrench_grab_directional
	.)
	{char_name}_start_aerial_wrench_grab_directional:
	.(
		sta player_a_direction, x
		; Fallthrough to {char_name}_start_aerial_wrench_grab
	.)
	&pepper_start_aerial_wrench_grab:
	.(
		; Set state
		lda #PEPPER_STATE_AERIAL_WRENCH_GRAB
		sta player_a_state, x

		; Reset clock
		ldy system_index
		lda pepper_anim_aerial_wrench_grab_dur, y
		sta player_a_state_clock, x

		; Cancel momentum
		lda #0
		sta player_a_velocity_h_low, x
		sta player_a_velocity_h, x
		sta player_a_velocity_v_low, x
		sta player_a_velocity_v, x

		; Set the appropriate animation
		lda #<pepper_anim_aerial_wrench_grab
		sta tmpfield13
		lda #>pepper_anim_aerial_wrench_grab
		sta tmpfield14
		jmp set_player_animation

		;rts ; useless, jump to subroutine
	.)

	&pepper_tick_aerial_wrench_grab:
	.(
		jsr pepper_global_tick

		; After move's time is out, go to falling state
		dec player_a_state_clock, x
		bne do_tick
			jmp pepper_start_falling
			; No return, jump to subroutine
		do_tick:

		; Apply friction
		jsr {char_name}_apply_air_friction

		; Apply gravity if after the gravity-ignoring section
		lda player_a_state_clock, x
		ldy system_index
		cmp pepper_anim_aerial_wrench_fall_time, y
		bcs ok
			jsr apply_player_gravity
		ok:

		rts
	.)
.)

.(
	POTION_SMASH_DURATION = 34
	POTION_SMASH_DURATION_NTSC = POTION_SMASH_DURATION+(((((POTION_SMASH_DURATION)*10)/5)+5)/10)

	potion_smash_duration:
		.byt POTION_SMASH_DURATION, POTION_SMASH_DURATION_NTSC
	potion_smash_gravity_time:
		.byt POTION_SMASH_DURATION-14, POTION_SMASH_DURATION_NTSC-16 ; frame perfect constant, just at the begining on idle pose

	&pepper_start_potion_smash:
	.(
		; Set state
		lda #PEPPER_STATE_POTION_SMASH
		sta player_a_state, x

		; Reset clock
		ldy system_index
		lda potion_smash_duration, y
		sta player_a_state_clock, x

		; Cancel momentum
		lda #0
		sta player_a_velocity_h_low, x
		sta player_a_velocity_h, x
		sta player_a_velocity_v_low, x
		sta player_a_velocity_v, x

		; Set the appropriate animation
		lda #<pepper_anim_potion_smash
		sta tmpfield13
		lda #>pepper_anim_potion_smash
		sta tmpfield14
		jmp set_player_animation

		;rts ; useless, jump to subroutine
	.)

	&pepper_tick_potion_smash:
	.(
		jsr pepper_global_tick

		; After move's time is out, go to falling state
		dec player_a_state_clock, x
		bne do_tick
			jmp pepper_start_falling
			; No return, jump to subroutine
		do_tick:

		; Apply gravity, only after active frames
		ldy system_index
		lda potion_smash_gravity_time, y
		cmp player_a_state_clock, x
		bcc end
			jmp apply_player_gravity
			; No return, jump to subroutine

		end:
		rts
	.)
.)

!define "anim" {pepper_anim_dtilt}
!define "state" {PEPPER_STATE_DTILT}
!define "routine" {down_tilt}
!include "characters/tpl_grounded_attack.asm"

.(
	STILT_DURATION = 20
	duration_table(STILT_DURATION, stilt_duration)

	+{char_name}_start_side_tilt_left:
	.(
		lda #DIRECTION_LEFT2
		jmp {char_name}_start_side_tilt_directional
	.)
	+{char_name}_start_side_tilt_right:
	.(
		lda #DIRECTION_RIGHT2
		; Fallthrough to {char_name}_start_side_tilt_directional
	.)
	{char_name}_start_side_tilt_directional:
	.(
		sta player_a_direction, x
		; Fallthrough to {char_name}_start_side_tilt
	.)
	&pepper_start_side_tilt:
	.(
		; Set state
		lda #PEPPER_STATE_STILT
		sta player_a_state, x

		; Reset clock
		ldy system_index
		lda stilt_duration, y
		sta player_a_state_clock, x

		; Set the appropriate animation
		lda #<pepper_anim_dark_stare
		sta tmpfield13
		lda #>pepper_anim_dark_stare
		sta tmpfield14
		jmp set_player_animation

		;rts ; useless, jump to subroutine
	.)

	&pepper_tick_side_tilt = pepper_std_grounded_tick
.)

!define "anim" {pepper_anim_up_tilt}
!define "state" {PEPPER_STATE_UTILT}
!define "routine" {up_tilt}
!include "characters/tpl_grounded_attack.asm"

!define "anim" {pepper_anim_flash_potion}
!define "state" {PEPPER_STATE_FLASH_POTION}
!define "routine" {flash_potion}
!include "characters/tpl_grounded_attack.asm"

.(
	HIT_TIME_PAL = 6
	HIT_TIME_NTSC = 7

	pepper_anim_aerial_wrench_dur:
		.byt pepper_anim_aerial_wrench_dur_pal, pepper_anim_aerial_wrench_dur_ntsc
	hit_time:
		.byt pepper_anim_aerial_wrench_dur_pal-HIT_TIME_PAL, pepper_anim_aerial_wrench_dur_ntsc-HIT_TIME_NTSC


	&{char_name}_start_aerial_side_left:
	.(
		lda #DIRECTION_LEFT2
		jmp {char_name}_start_aerial_side_directional
	.)
	&{char_name}_start_aerial_side_right:
	.(
		lda #DIRECTION_RIGHT2
		; Fallthrough to {char_name}_start_aerial_side_directional
	.)
	{char_name}_start_aerial_side_directional:
	.(
		sta player_a_direction, x
		; Fallthrough to {char_name}_start_aerial_side
	.)
	&pepper_start_aerial_side:
	.(
		; Short hop takeover
		jsr pepper_short_hop_takeover_init

		; Set state
		lda #PEPPER_STATE_AERIAL_SIDE
		sta player_a_state, x

		; Reset clock
		ldy system_index
		lda pepper_anim_aerial_wrench_dur, y
		sta player_a_state_clock, x

		; Set the appropriate animation
		lda #<pepper_anim_aerial_wrench
		sta tmpfield13
		lda #>pepper_anim_aerial_wrench
		sta tmpfield14
		jmp set_player_animation

		;rts ; useless, jump to subroutine
	.)

	&pepper_tick_aerial_side:
	.(
		; Set little upward velocity on the strong hit frame, dramatic effect
		; Note - no NTSC conversion, it is barely one pixel per frame, would be unoticable if lower
		ldy system_index
		lda player_a_state_clock, x
		cmp hit_time, y
		bne ok
			lda #$fe
			sta player_a_velocity_v, x
			sta player_a_velocity_v_low, x
		ok:

		jmp pepper_std_aerial_tick
		;rts ; useless, jump to subroutine
	.)
.)

!define "anim" {pepper_anim_firework}
!define "state" {PEPPER_STATE_AERIAL_FIREWORK}
!define "routine" {aerial_firework}
!include "characters/tpl_aerial_attack.asm"

.(
	;FIXME keyframe system is not ntsc-friendly
	&{char_name}_start_hyperspeed_landing_left:
	.(
		lda #DIRECTION_LEFT2
		jmp {char_name}_start_hyperspeed_landing_directional
	.)
	&{char_name}_start_hyperspeed_landing_right:
	.(
		lda #DIRECTION_RIGHT2
		; Fallthrough to {char_name}_start_hyperspeed_landing_directional
	.)
	{char_name}_start_hyperspeed_landing_directional:
	.(
		sta player_a_direction, x
		; Fallthrough to {char_name}_start_hyperspeed_landing
	.)
	&pepper_start_hyperspeed_landing:
	.(
		keyframe_index = player_a_state_field1

		; Set state
		lda #PEPPER_STATE_HYPERSPEED_LANDING
		sta player_a_state, x

		; Reset clock
		lda #0
		sta player_a_state_clock, x
		sta keyframe_index, x

		; Set the appropriate animation
		lda #<pepper_anim_hyperspeed_flying
		sta tmpfield13
		lda #>pepper_anim_hyperspeed_flying
		sta tmpfield14
		jmp set_player_animation

		;rts ; useless, jump to subroutine
	.)

	&pepper_tick_hyperspeed_landing:
	.(
		keyframe_index = player_a_state_field1

		; Store next keyframe index in register Y, skip keyframe logic if after the end
		ldy keyframe_index, x
		cmp #KEYFRAMES_END
		beq end

			; Set velocity if on velocity keyframe
			.(
				lda velocity_keyframes_clock, y
				cmp player_a_state_clock, x
				bne ok

					; Set vertical velocity (direct)
					lda velocity_keyframes_v_lsb, y
					sta player_a_velocity_v_low, x
					lda velocity_keyframes_v_msb, y
					sta player_a_velocity_v, x

					; Set horizontal velocity (negated if right facing)
					lda player_a_direction, x
					bne right
						left:
							lda velocity_keyframes_h_lsb, y
							sta player_a_velocity_h_low, x
							lda velocity_keyframes_h_msb, y
							sta player_a_velocity_h, x
							jmp velocity_ok
						right:
							lda velocity_keyframes_h_lsb, y
							eor #%11111111
							clc
							adc #1
							sta player_a_velocity_h_low, x

							lda velocity_keyframes_h_msb, y
							eor #%11111111
							adc #0
							sta player_a_velocity_h, x
						velocity_ok:

					; Update next keyframe
					inc keyframe_index, x

				ok:
			.)

			; Tick clock
			inc player_a_state_clock, x

		end:
		rts

		velocity_keyframes_clock:
		.byt 0,   12, 20
		velocity_keyframes_v_lsb:
		.byt $00, $00, $00
		velocity_keyframes_v_msb:
		.byt $00, $01, $04
		velocity_keyframes_h_lsb:
		.byt $00, $c0, $00
		velocity_keyframes_h_msb:
		.byt $00, $ff, $ff
		KEYFRAMES_END = velocity_keyframes_v_lsb - velocity_keyframes_clock + 1
	.)
.)

;TODO could be "tpl_grounded_attack" if there was a way to play audio sound (not sure it should be, it is definitely not a standard attack)
.(
	pepper_anim_hyperspeed_crash_dur:
		.byt pepper_anim_hyperspeed_crash_dur_pal, pepper_anim_hyperspeed_crash_dur_ntsc

	&pepper_start_hyperspeed_crashing:
	.(
		; Set state
		lda #PEPPER_STATE_HYPERSPEED_CRASHING
		sta player_a_state, x

		; Reset clock
		ldy system_index
		lda pepper_anim_hyperspeed_crash_dur, y
		sta player_a_state_clock, x

		; Set the appropriate animation
		lda #<pepper_anim_hyperspeed_crash
		sta tmpfield13
		lda #>pepper_anim_hyperspeed_crash
		sta tmpfield14
		jsr set_player_animation

		; Play crash sound
		jmp audio_play_crash

		;rts ; useless, jump to subroutine
	.)

	&pepper_tick_hyperspeed_crashing = pepper_std_grounded_tick
.)

;
; Plan 7-B
;

.(
	&pepper_start_plan_7b:
	.(
		; Check that carrot is placed
		;  if not - place him
		;  else - teleport
		ldy pepper_carrot_anim_per_player, x
		lda stage_data+ANIMATION_STATE_OFFSET_X_MSB, y
		cmp #PEPPER_CARROT_NOT_PLACED
		beq pepper_start_send_carrot

			placed:
				jmp pepper_start_teleport
				; No return, jump to subroutine
	.)
.)

.(
	pepper_anim_send_carrot_dur:
		.byt pepper_anim_send_carrot_dur_pal, pepper_anim_send_carrot_dur_ntsc

	&pepper_start_send_carrot:
	.(
		; Set state
		lda #PEPPER_STATE_SEND_CARROT
		sta player_a_state, x

		; Reset clock
		ldy system_index
		lda pepper_anim_send_carrot_dur, y
		sta player_a_state_clock, x

		; Cancel any momentum
		;lda #0
		;sta player_a_velocity_h, x
		;sta player_a_velocity_h_low, x
		;sta player_a_velocity_v, x
		;sta player_a_velocity_v_low, x

		; Set the appropriate animation
		lda #<pepper_anim_send_carrot
		sta tmpfield13
		lda #>pepper_anim_send_carrot
		sta tmpfield14
		jmp set_player_animation

		;rts ; useless, jump to subroutine
	.)

	&pepper_tick_send_carrot:
	.(
		carrot_anim_direction = tmpfield1
		stage_element_handler_lsb = tmpfield1
		stage_element_handler_msb = tmpfield2
		collision_point_x_lsb = tmpfield3
		collision_point_y_lsb = tmpfield4
		collision_point_x_msb = tmpfield5
		collision_point_y_msb = tmpfield6
		carrot_offset_x_lsb = tmpfield7
		carrot_offset_x_msb = tmpfield8

		jsr pepper_global_tick

		; After move's time is out, place carrot and return to inactive state
		dec player_a_state_clock, x
		bne do_tick
			; Put carrot offset in fixed location
			ldy player_a_direction, x
			sty carrot_anim_direction

			lda carrot_offset_x_lsb_per_direction, y
			sta carrot_offset_x_lsb
			lda carrot_offset_x_msb_per_direction, y
			sta carrot_offset_x_msb

			; Place carrot
			ldy pepper_carrot_anim_per_player, x

			lda player_a_x, x
			clc
			adc carrot_offset_x_lsb
			sta stage_data+ANIMATION_STATE_OFFSET_X_LSB, y
			sta collision_point_x_lsb
			lda player_a_x_screen, x
			adc carrot_offset_x_msb
			sta stage_data+ANIMATION_STATE_OFFSET_X_MSB, y
			sta collision_point_x_msb

			lda player_a_y, x
			sta stage_data+ANIMATION_STATE_OFFSET_Y_LSB, y
			sta collision_point_y_lsb
			lda player_a_y_screen, x
			sta stage_data+ANIMATION_STATE_OFFSET_Y_MSB, y
			sta collision_point_y_msb

			lda carrot_anim_direction
			sta stage_data+ANIMATION_STATE_OFFSET_DIRECTION, y

			; Remove carrot if in a platform
			.(
				lda #<check_in_platform
				sta stage_element_handler_lsb
				lda #>check_in_platform
				sta stage_element_handler_msb
				jsr stage_iterate_all_elements
				; Note - expects none of stage_iterate_all_elements nor check_in_platform to overwrite register X

				cpy #$ff
				bne ok
					lda #PEPPER_CARROT_NOT_PLACED
					ldy pepper_carrot_anim_per_player, x
					sta stage_data+ANIMATION_STATE_OFFSET_X_MSB, y
				ok:
			.)

			; Return to inactive state
			jmp pepper_start_inactive_state
			; No return, jump to subroutine

		do_tick:
			; Apply friction and gravity
			jmp pepper_apply_friction_lite
			; No return, jump to subroutine

		;rts ; useless, no branch returns

		carrot_offset_x_lsb_per_direction:
		.byt $e8, $18
		carrot_offset_x_msb_per_direction:
		.byt $ff, $00
	.)
.)

.(
	TELEPORT_TP_TIME_PAL = 8
	TELEPORT_MOVE_TIME_PAL = 6
	TELEPORT_TP_TIME_NTSC = 9
	TELEPORT_MOVE_TIME_NTSC = 7

	pepper_anim_teleport_dur:
		.byt pepper_anim_teleport_dur_pal, pepper_anim_teleport_dur_ntsc
	tp_time:
		.byt pepper_anim_teleport_dur_pal-TELEPORT_TP_TIME_PAL, pepper_anim_teleport_dur_ntsc-TELEPORT_TP_TIME_NTSC
	move_time:
		.byt pepper_anim_teleport_dur_pal-TELEPORT_MOVE_TIME_PAL+1, pepper_anim_teleport_dur_ntsc-TELEPORT_MOVE_TIME_NTSC+1

	&pepper_start_teleport:
	.(
		move_step_x = player_a_state_field1
		move_step_y = player_a_state_field2

		; Set state
		lda #PEPPER_STATE_TELEPORT
		sta player_a_state, x

		; Reset clock
		ldy system_index
		lda pepper_anim_teleport_dur, y
		sta player_a_state_clock, x

		; Reset velocity
		lda #0
		sta player_a_velocity_h_low, x
		sta player_a_velocity_h, x
		sta player_a_velocity_v_low, x
		sta player_a_velocity_v, x

		; Compute move step distance
		.(
			; Y = offset to carrot's animation
			ldy pepper_carrot_anim_per_player, x

			; move_step_x = (carrot_x - player_x) / 4
			;FIXME check that divide by 4 works with ntsc (if move time is 5 frames, it may appear strange, or even SD if near blastline)
			lda stage_data+ANIMATION_STATE_OFFSET_X_LSB, y
			sec
			sbc player_a_x, x
			sta move_step_x, x
			lda stage_data+ANIMATION_STATE_OFFSET_X_MSB, y
			sbc player_a_x_screen, x
			lsr
			ror move_step_x, x
			lsr
			ror move_step_x, x

			; move_step_y = (carrot_y - player_y) / 4
			lda stage_data+ANIMATION_STATE_OFFSET_Y_LSB, y
			sec
			sbc player_a_y, x
			sta move_step_y, x
			lda stage_data+ANIMATION_STATE_OFFSET_Y_MSB, y
			sbc player_a_y_screen, x
			lsr
			ror move_step_y, x
			lsr
			ror move_step_y, x
		.)

		; Set the appropriate animation
		lda #<pepper_anim_teleport
		sta tmpfield13
		lda #>pepper_anim_teleport
		sta tmpfield14
		jmp set_player_animation

		;rts ; useless, jump to subroutine
	.)

	&pepper_tick_teleport:
	.(
		move_step_x = player_a_state_field1
		move_step_y = player_a_state_field2

		jsr pepper_global_tick

		; After move's time is out, go to inactive state
		dec player_a_state_clock, x
		bne do_tick
			jmp pepper_start_inactive_state
			; No return, jump to subroutine
		do_tick:

		; Apply logic depending on time
		;  Disapear animation - Do nothing
		;  Traveling - Move toward Carrot
		;  Reapear animation - Place exactly on Carrot and remove Carrot
		ldy system_index
		lda player_a_state_clock, x
		cmp tp_time, y
		beq final_position ; at teleport time
		cmp move_time, y
		beq start_move
		jmp end

		start_move:

			; Set velocity to pre-computed values
			lda move_step_x, x
			sta player_a_velocity_h, x
			lda move_step_y, x
			sta player_a_velocity_v, x
			; No need to set low bytes, already at zero
			jmp end

		final_position:

			; Y = offset to carrot's animation
			ldy pepper_carrot_anim_per_player, x

			; Reset velocity
			lda #0
			sta player_a_velocity_h_low, x
			sta player_a_velocity_h, x
			sta player_a_velocity_v_low, x
			sta player_a_velocity_v, x

			; Check that carrot is placed, else skip doing anything
			lda stage_data+ANIMATION_STATE_OFFSET_X_MSB, y
			cmp #PEPPER_CARROT_NOT_PLACED
			beq end

			; Change Pepper's position
			lda stage_data+ANIMATION_STATE_OFFSET_X_MSB, y
			sta player_a_x_screen, x
			lda stage_data+ANIMATION_STATE_OFFSET_X_LSB, y
			sta player_a_x, x

			lda stage_data+ANIMATION_STATE_OFFSET_Y_LSB, y
			sta player_a_y, x
			lda stage_data+ANIMATION_STATE_OFFSET_Y_MSB, y
			sta player_a_y_screen, x

			lda #0
			sta player_a_x_low, x
			sta player_a_y_low, x

			; Remove carrot
			lda #PEPPER_CARROT_NOT_PLACED
			sta stage_data+ANIMATION_STATE_OFFSET_X_MSB, y

		end:
		rts
	.)
.)

.(
	FLY_DURATION = 25
	VELOCITY_H = $0200
	VELOCITY_V = $0100
	VELOCITY_H_NTSC = (VELOCITY_H*5)/6

	duration_table(FLY_DURATION, fly_duration)
	velocity_table(-VELOCITY_V, velocity_v_msb, velocity_v_lsb)

	witch_fly_velocity_h_lsb_per_direction:
		.byt <-VELOCITY_H, <VELOCITY_H
		.byt <-VELOCITY_H_NTSC, <VELOCITY_H_NTSC
	witch_fly_velocity_h_msb_per_direction:
		.byt >-VELOCITY_H, >VELOCITY_H
		.byt >-VELOCITY_H_NTSC, >VELOCITY_H_NTSC

	&pepper_start_witch_fly_right:
	.(
		lda #DIRECTION_RIGHT2
		sta player_a_direction, x
		jmp pepper_start_witch_fly
		;rts ; useless, jump to subroutine
	.)
	&pepper_start_witch_fly_left:
	.(
		lda #DIRECTION_LEFT2
		sta player_a_direction, x
		jmp pepper_start_witch_fly
		;rts ; useless, jump to subroutine
	.)
	&pepper_start_witch_fly:
	.(
		; Set state
		lda #PEPPER_STATE_WITCH_FLY
		sta player_a_state, x

		; Reset clock
		ldy system_index
		lda fly_duration, y
		sta player_a_state_clock, x

		; Set momentum
		lda system_index
		asl
		clc
		adc player_a_direction, x
		tay

		lda witch_fly_velocity_h_lsb_per_direction, y
		sta player_a_velocity_h_low, x
		lda witch_fly_velocity_h_msb_per_direction, y
		sta player_a_velocity_h, x

		ldy system_index
		lda velocity_v_lsb, y
		sta player_a_velocity_v_low,x
		lda velocity_v_msb, y
		sta player_a_velocity_v, x

		; Reset fall speed
		jsr reset_default_gravity

		; Set the appropriate animation
		lda #<pepper_anim_witch_fly
		sta tmpfield13
		lda #>pepper_anim_witch_fly
		sta tmpfield14
		jmp set_player_animation

		;rts ; useless, jump to subroutine
	.)

	&pepper_tick_witch_fly:
	.(
		jsr pepper_global_tick

		; After move's time is out, go helpless
		dec player_a_state_clock, x
		bne do_tick
			jmp pepper_start_helpless
			; No return, jump to subroutine
		do_tick:

		; Allow to change direction
		reset_speed = tmpfield1
		.(
			animation_state_vector = tmpfield2

			lda #0
			sta reset_speed

			lda controller_a_btns, x
			and #CONTROLLER_INPUT_LEFT
			bne go_left
			lda controller_a_btns, x
			and #CONTROLLER_INPUT_RIGHT
			bne go_right
			jmp ok

				go_left:
					lda #DIRECTION_LEFT2
					jmp common_changes

				go_right:
					lda #DIRECTION_RIGHT2

				common_changes:
					sta player_a_direction, x

					; Chose animation state
					lda player_animation_state_vectors_lsb, x
					sta animation_state_vector
					lda player_animation_state_vectors_msb, x
					sta animation_state_vector+1

					; Set animation's direction
					lda player_a_direction, x
					ldy #ANIMATION_STATE_OFFSET_DIRECTION
					sta (animation_state_vector), y

					; Force a reset of fly speed
					lda #1
					sta reset_speed

			ok:
		.)

		; Force momentum to come back to normal if modified
		lda system_index
		asl
		clc
		adc player_a_direction, x
		tay

		lda reset_speed
		bne set_velocity

			merge_to_velocity:
				; Accelerate to the desired speed
				;  In normal condition, Pepper stays at desired speed since it has been set at start
				;  If an external force is applied, this is the natural behavior
				lda witch_fly_velocity_h_lsb_per_direction, y
				sta tmpfield2
				lda witch_fly_velocity_h_msb_per_direction, y
				sta tmpfield4

				ldy system_index
				lda velocity_v_lsb, y
				sta tmpfield1
				lda velocity_v_msb, y
				sta tmpfield3

				lda {char_name}_ground_friction_strength, y
				sta tmpfield5

				jmp merge_to_player_velocity
				; No return

			set_velocity:
				; Reset velocity directly
				;  This is the wanted behaviour when we change direction
				lda witch_fly_velocity_h_lsb_per_direction, y
				sta player_a_velocity_h_low, x
				lda witch_fly_velocity_h_msb_per_direction, y
				sta player_a_velocity_h, x

		rts
	.)
.)

!define "anim" {pepper_anim_wrench_grab}
!define "state" {PEPPER_STATE_WRENCH_GRAB}
!define "routine" {wrench_grab}
!include "characters/tpl_grounded_attack.asm"

;
; Dzzz
;

.(
	PEPPER_DZZZ_GRAVITY = $0100

	strike_duration:
		.byt pepper_anim_dzzz_strike_dur_pal, pepper_anim_dzzz_strike_dur_ntsc

	anim_duration_table(25, charge_duration)

	velocity_table(PEPPER_DZZZ_GRAVITY, pepper_dzzz_gravity_msb, pepper_dzzz_gravity_lsb)

	&pepper_start_dzzz_left:
	.(
		lda DIRECTION_LEFT
		sta player_a_direction, x
		jmp pepper_start_dzzz
		;rts ; useless, jump to subroutine
	.)

	&pepper_start_dzzz_right:
	.(
		lda DIRECTION_RIGHT
		sta player_a_direction, x
		; Falthrough to pepper_start_dzzz
	.)

	&pepper_start_dzzz:
	.(
		; Set state
		lda #PEPPER_STATE_DZZZ_CHARGE
		sta player_a_state, x

		; Reset clock
		ldy system_index
		lda charge_duration, y
		sta player_a_state_clock, x

		; Cancel vertical momentum
		lda #0
		sta player_a_velocity_v_low, x
		sta player_a_velocity_v, x

		; Lower horizontal momentum
		lda player_a_velocity_h, x ; Set sign bit in carry flag, so the following bitshift is a signed division
		rol

		ror player_a_velocity_h, x
		ror player_a_velocity_h_low, x

		; Lower gravity
		ldy system_index
		lda pepper_dzzz_gravity_lsb, y
		sta player_a_gravity_lsb, x
		lda pepper_dzzz_gravity_msb, y
		sta player_a_gravity_msb, x

		; Set the appropriate animation
		lda #<pepper_anim_dzzz_charge
		sta tmpfield13
		lda #>pepper_anim_dzzz_charge
		sta tmpfield14
		jmp set_player_animation

		;rts ; useless, jump to subroutine
	.)

	&pepper_tick_dzzz_charge:
	.(
		jsr pepper_global_tick

		dec player_a_state_clock, x
		bne tick
			jmp pepper_start_dzzz_strike
			; No return, jump to subroutine
		tick:
			jmp pepper_apply_friction_lite
			; No return, jump to subroutine
		;rts ; useless, no branch return
	.)

	pepper_start_dzzz_strike:
	.(
		; Set state
		lda #PEPPER_STATE_DZZZ_STRIKE
		sta player_a_state, x

		; Reset clock
		ldy system_index
		lda strike_duration, y
		sta player_a_state_clock, x

		; Set the appropriate animation
		lda #<pepper_anim_dzzz_strike
		sta tmpfield13
		lda #>pepper_anim_dzzz_strike
		sta tmpfield14
		jmp set_player_animation

		;rts ; useless, jump to subroutine
	.)

	&pepper_tick_dzzz_strike:
	.(
		jsr pepper_global_tick

		dec player_a_state_clock, x
		bne tick
			jsr reset_default_gravity
			jmp pepper_start_inactive_state
			; No return, jump to subroutine
		tick:
			jmp pepper_apply_friction_lite
			; No return, jump to subroutine
		;rts ; useless, no branch return
	.)
.)

!include "characters/std_friction_routines.asm"

; Standard move names
;pepper_start_down_tilt = pepper_start_down_tilt
pepper_start_spe_down = pepper_start_wrench_grab

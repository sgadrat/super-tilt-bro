;
; States index
;

PEPPER_STATE_THROWN = PLAYER_STATE_THROWN
PEPPER_STATE_RESPAWN_INVISIBLE = PLAYER_STATE_RESPAWN
PEPPER_STATE_INNEXISTANT = PLAYER_STATE_INNEXISTANT
PEPPER_STATE_SPAWN = PLAYER_STATE_SPAWN
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
PEPPER_MAX_WALLJUMPS = 1
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

velocity_table(PEPPER_AERIAL_SPEED, pepper_aerial_speed_msb, pepper_aerial_speed_lsb)
velocity_table(-PEPPER_AERIAL_SPEED, pepper_aerial_neg_speed_msb, pepper_aerial_neg_speed_lsb)
acceleration_table(PEPPER_AERIAL_DIRECTIONAL_INFLUENCE_STRENGTH, pepper_aerial_directional_influence_strength)
acceleration_table(PEPPER_AIR_FRICTION_STRENGTH, pepper_air_friction_strength)
velocity_table(PEPPER_FASTFALL_SPEED, pepper_fastfall_speed_msb, pepper_fastfall_speed_lsb)
acceleration_table(PEPPER_GROUND_FRICTION_STRENGTH, pepper_ground_friction_strength)
acceleration_table(PEPPER_GROUND_FRICTION_STRENGTH/3, pepper_ground_friction_strength_weak)
acceleration_table(PEPPER_GROUND_FRICTION_STRENGTH*3, pepper_ground_friction_strength_strong)
velocity_table(PEPPER_TECH_SPEED, pepper_tech_speed_msb, pepper_tech_speed_lsb)
velocity_table(-PEPPER_TECH_SPEED, pepper_tech_speed_neg_msb, pepper_tech_speed_neg_lsb)
velocity_table(-PEPPER_JUMP_POWER, pepper_jump_velocity_msb, pepper_jump_velocity_lsb)
velocity_table(-PEPPER_JUMP_SHORT_HOP_POWER, pepper_jump_short_hop_velocity_msb, pepper_jump_short_hop_velocity_lsb)

pepper_jumpsquat_duration:
	.byt PEPPER_JUMP_SQUAT_DURATION_PAL, PEPPER_JUMP_SQUAT_DURATION_NTSC

pepper_short_hop_time:
	.byt PEPPER_JUMP_SQUAT_DURATION_PAL + PEPPER_JUMP_SHORT_HOP_EXTRA_TIME_PAL, PEPPER_JUMP_SQUAT_DURATION_NTSC + PEPPER_JUMP_SHORT_HOP_EXTRA_TIME_NTSC

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
	; Initialize walljump counter
	lda #PEPPER_MAX_WALLJUMPS
	sta player_a_walljump, x
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
!define "PEPPER_AERIAL_INPUTS_TABLE" {
	.(
		controller_inputs
		.byt CONTROLLER_INPUT_NONE,              CONTROLLER_INPUT_SPECIAL_RIGHT
		.byt CONTROLLER_INPUT_SPECIAL_LEFT,      CONTROLLER_INPUT_JUMP
		.byt CONTROLLER_INPUT_JUMP_RIGHT,        CONTROLLER_INPUT_JUMP_LEFT
		.byt CONTROLLER_INPUT_ATTACK_LEFT,       CONTROLLER_INPUT_ATTACK_RIGHT
		.byt CONTROLLER_INPUT_DOWN_TILT,         CONTROLLER_INPUT_ATTACK_UP
		.byt CONTROLLER_INPUT_JAB,               CONTROLLER_INPUT_SPECIAL
		.byt CONTROLLER_INPUT_SPECIAL_UP,        CONTROLLER_INPUT_SPECIAL_DOWN,
		.byt CONTROLLER_INPUT_ATTACK_UP_RIGHT,   CONTROLLER_INPUT_ATTACK_UP_LEFT
		.byt CONTROLLER_INPUT_SPECIAL_UP_RIGHT,  CONTROLLER_INPUT_SPECIAL_UP_LEFT
		.byt CONTROLLER_INPUT_ATTACK_DOWN_LEFT,  CONTROLLER_INPUT_ATTACK_DOWN_RIGHT
		.byt CONTROLLER_INPUT_SPECIAL_DOWN_LEFT, CONTROLLER_INPUT_SPECIAL_DOWN_RIGHT
		controller_callbacks_lo
		.byt <fast_fall,                        <pepper_start_dzzz_right
		.byt <pepper_start_dzzz_left,           <jump
		.byt <jump,                             <jump
		.byt <pepper_start_aerial_side,         <pepper_start_aerial_side
		.byt <pepper_start_hyperspeed_landing,  <pepper_start_aerial_firework
		.byt <pepper_start_potion_smash,        <pepper_start_plan_7b
		.byt <pepper_start_witch_fly,           <pepper_start_aerial_wrench_grab
		.byt <pepper_start_aerial_firework,     <pepper_start_aerial_firework
		.byt <pepper_start_witch_fly_right,     <pepper_start_witch_fly_left
		.byt <pepper_start_hyperspeed_landing,  <pepper_start_hyperspeed_landing
		.byt <pepper_start_aerial_wrench_grab,  <pepper_start_aerial_wrench_grab
		controller_callbacks_hi
		.byt >fast_fall,                        >pepper_start_dzzz_right
		.byt >pepper_start_dzzz_left,           >jump
		.byt >jump,                             >jump
		.byt >pepper_start_aerial_side,         >pepper_start_aerial_side
		.byt >pepper_start_hyperspeed_landing,  >pepper_start_aerial_firework
		.byt >pepper_start_potion_smash,        >pepper_start_plan_7b
		.byt >pepper_start_witch_fly,           >pepper_start_aerial_wrench_grab
		.byt >pepper_start_aerial_firework,     >pepper_start_aerial_firework
		.byt >pepper_start_witch_fly_right,     >pepper_start_witch_fly_left
		.byt >pepper_start_hyperspeed_landing,  >pepper_start_hyperspeed_landing
		.byt >pepper_start_aerial_wrench_grab,  >pepper_start_aerial_wrench_grab
		controller_default_callback
		.word no_input
		&INPUT_TABLE_LENGTH = controller_callbacks_lo - controller_inputs
	.)
}

!include "std_aerial_input.asm"
!include "std_crashing.asm"
!include "std_thrown.asm"
!include "std_respawn.asm"

;
; Innexistant
;

.(
	&pepper_start_innexistant:
	.(
		; Set the player's state
		lda #PEPPER_STATE_INNEXISTANT
		sta player_a_state, x

		; Set to a fixed place
		lda #0
		sta player_a_x_screen, x
		sta player_a_x, x
		sta player_a_x_low, x
		sta player_a_y_screen, x
		sta player_a_y, x
		sta player_a_y_low, x
		sta player_a_velocity_h, x
		sta player_a_velocity_h_low, x
		sta player_a_velocity_v, x
		sta player_a_velocity_v_low, x

		; Set the appropriate animation
		lda #<anim_invisible
		sta tmpfield13
		lda #>anim_invisible
		sta tmpfield14
		jmp set_player_animation

		;rts ; useless, jump to subroutine
	.)
.)

;
; Spawn
;

.(
	spawn_duration:
		.byt pepper_anim_spawn_dur_pal, pepper_anim_spawn_dur_ntsc
#if pepper_anim_spawn_dur_pal <> 50
#error incorrect spawn duration
#endif
#if pepper_anim_spawn_dur_ntsc <> 60
#error incorrect spawn duration (ntsc only)
#endif

	&pepper_start_spawn:
	.(
		; Hack - there is no ensured call to a character init function
		;        expect start_spawn to be called once at the begining of a game
		jsr pepper_init

		; Set the player's state
		lda #PEPPER_STATE_SPAWN
		sta player_a_state, x

		; Reset clock
		ldy system_index
		lda spawn_duration, y
		sta player_a_state_clock, x

		; Set the appropriate animation
		lda #<pepper_anim_spawn
		sta tmpfield13
		lda #>pepper_anim_spawn
		sta tmpfield14
		jsr set_player_animation

		rts
	.)

	&pepper_tick_spawn:
	.(
		jsr pepper_global_tick

		dec player_a_state_clock, x
		bne tick
			jmp pepper_start_idle
			; No return, jump to subroutine
		tick:
		rts
	.)
.)

;
; Idle
;

; Choose between falling or idle depending if grounded
pepper_start_inactive_state:
.(
	lda player_a_grounded, x
	bne idle

	fall:
		jmp pepper_start_falling
		; No return, jump to subroutine

	idle:
	; Fallthrough to pepper_start_idle
.)

.(
	&pepper_start_idle:
	.(
		; Set the player's state
		lda #PEPPER_STATE_IDLE
		sta player_a_state, x

		; Set the appropriate animation
		lda #<pepper_anim_idle
		sta tmpfield13
		lda #>pepper_anim_idle
		sta tmpfield14
		jmp set_player_animation

		;rts ; useless, jump to subroutine
	.)

	&pepper_tick_idle:
	.(
		jsr pepper_global_tick

		; Do not move, velocity tends toward vector (0,0)
		lda #$00
		sta tmpfield4
		sta tmpfield3
		sta tmpfield2
		sta tmpfield1
		lda #$ff
		sta tmpfield5
		jsr merge_to_player_velocity

		; Force handling directional controls
		;   we want to start running even if button presses where maintained from previous state
		lda controller_a_btns, x
		cmp #CONTROLLER_INPUT_LEFT
		bne no_left
			jmp pepper_input_idle_left
			; No return, jump to subroutine
		no_left:
			cmp #CONTROLLER_INPUT_RIGHT
			bne end
				jmp pepper_input_idle_right
				; No return, jump to subroutine

		end:
		rts
	.)

	&pepper_input_idle:
	.(
		; Do not handle any input if under hitstun
		lda player_a_hitstun, x
		bne end

			; Check state changes
			lda #<input_table
			sta tmpfield1
			lda #>input_table
			sta tmpfield2
			lda #INPUT_TABLE_LENGTH
			sta tmpfield3
			jmp controller_callbacks

		end:
		rts

		input_table:
		.(
			controller_inputs:
			.byt CONTROLLER_INPUT_LEFT,               CONTROLLER_INPUT_RIGHT
			.byt CONTROLLER_INPUT_JUMP,               CONTROLLER_INPUT_JUMP_RIGHT
			.byt CONTROLLER_INPUT_JUMP_LEFT,          CONTROLLER_INPUT_TECH
			.byt CONTROLLER_INPUT_TECH_LEFT,          CONTROLLER_INPUT_TECH_RIGHT
			.byt CONTROLLER_INPUT_DOWN_TILT,          CONTROLLER_INPUT_ATTACK_LEFT
			.byt CONTROLLER_INPUT_ATTACK_RIGHT,       CONTROLLER_INPUT_SPECIAL_LEFT
			.byt CONTROLLER_INPUT_SPECIAL_RIGHT,      CONTROLLER_INPUT_SPECIAL
			.byt CONTROLLER_INPUT_SPECIAL_UP,         CONTROLLER_INPUT_SPECIAL_UP_LEFT
			.byt CONTROLLER_INPUT_SPECIAL_UP_RIGHT,   CONTROLLER_INPUT_ATTACK_UP_LEFT
			.byt CONTROLLER_INPUT_ATTACK_UP_RIGHT,    CONTROLLER_INPUT_ATTACK_UP
			.byt CONTROLLER_INPUT_JAB,                CONTROLLER_INPUT_SPECIAL_DOWN_LEFT
			.byt CONTROLLER_INPUT_SPECIAL_DOWN_RIGHT, CONTROLLER_INPUT_SPECIAL_DOWN
			.byt CONTROLLER_INPUT_ATTACK_DOWN_LEFT,   CONTROLLER_INPUT_ATTACK_DOWN_RIGHT
			controller_callbacks_lsb:
			.byt <pepper_input_idle_left,           <pepper_input_idle_right
			.byt <pepper_start_jumping,             <pepper_input_idle_jump_right
			.byt <pepper_input_idle_jump_left,      <pepper_start_shielding
			.byt <pepper_start_shielding,           <pepper_start_shielding
			.byt <pepper_start_down_tilt,           <input_left_tilt
			.byt <input_right_tilt,                 <pepper_start_dzzz_left
			.byt <pepper_start_dzzz_right,          <pepper_start_plan_7b
			.byt <pepper_start_witch_fly,           <pepper_start_witch_fly_left
			.byt <pepper_start_witch_fly_right,     <pepper_start_up_tilt
			.byt <pepper_start_up_tilt,             <pepper_start_up_tilt
			.byt <pepper_start_flash_potion,        <pepper_start_wrench_grab
			.byt <pepper_start_wrench_grab,         <pepper_start_wrench_grab
			.byt <pepper_start_down_tilt,           <pepper_start_down_tilt
			controller_callbacks_msb:
			.byt >pepper_input_idle_left,           >pepper_input_idle_right
			.byt >pepper_start_jumping,             >pepper_input_idle_jump_right
			.byt >pepper_input_idle_jump_left,      >pepper_start_shielding
			.byt >pepper_start_shielding,           >pepper_start_shielding
			.byt >pepper_start_down_tilt,           >input_left_tilt
			.byt >input_right_tilt,                 >pepper_start_dzzz_left
			.byt >pepper_start_dzzz_right,          >pepper_start_plan_7b
			.byt >pepper_start_witch_fly,           >pepper_start_witch_fly_left
			.byt >pepper_start_witch_fly_right,     >pepper_start_up_tilt
			.byt >pepper_start_up_tilt,             >pepper_start_up_tilt
			.byt >pepper_start_flash_potion,        >pepper_start_wrench_grab
			.byt >pepper_start_wrench_grab,         >pepper_start_wrench_grab
			.byt >pepper_start_down_tilt,           >pepper_start_down_tilt
			controller_default_callback:
			.word end
			&INPUT_TABLE_LENGTH = controller_callbacks_lsb - controller_inputs
		.)

		pepper_input_idle_jump_right:
		.(
			lda DIRECTION_RIGHT
			sta player_a_direction, x
			jmp pepper_start_jumping
			;rts ; useless - pepper_start_jumping is a routine
		.)

		pepper_input_idle_jump_left:
		.(
			lda DIRECTION_LEFT
			sta player_a_direction, x
			jmp pepper_start_jumping
			;rts ; useless - pepper_start_jumping is a routine
		.)

		input_left_tilt:
		.(
			lda DIRECTION_LEFT
			sta player_a_direction, x
			jmp pepper_start_side_tilt
			;rts ; useless - pepper_start_jumping is a routine
		.)

		input_right_tilt:
		.(
			lda DIRECTION_RIGHT
			sta player_a_direction, x
			jmp pepper_start_side_tilt
			;rts ; useless - pepper_start_jumping is a routine
		.)
	.)
.)

pepper_input_idle_left:
.(
	lda DIRECTION_LEFT
	sta player_a_direction, x
	jsr pepper_start_running
	rts
.)

pepper_input_idle_right:
.(
	lda DIRECTION_RIGHT
	sta player_a_direction, x
	jsr pepper_start_running
	rts
.)

;
; Running
;

.(
	velocity_table(PEPPER_RUNNING_INITIAL_VELOCITY, run_init_velocity_msb, run_init_velocity_lsb)
	velocity_table(-PEPPER_RUNNING_INITIAL_VELOCITY, run_init_neg_velocity_msb, run_init_neg_velocity_lsb)

	velocity_table(PEPPER_RUNNING_MAX_VELOCITY, run_max_velocity_msb, run_max_velocity_lsb)
	velocity_table(-PEPPER_RUNNING_MAX_VELOCITY, run_max_neg_velocity_msb, run_max_neg_velocity_lsb)

	acceleration_table(PEPPER_RUNNING_ACCELERATION, run_acceleration)

	&pepper_start_running:
	.(
		; Set the player's state
		lda #PEPPER_STATE_RUNNING
		sta player_a_state, x

		; Set initial velocity
		ldy system_index
		lda player_a_direction, x
		cmp DIRECTION_LEFT
		bne direction_right
			lda run_init_neg_velocity_lsb, y
			sta player_a_velocity_h_low, x
			lda run_init_neg_velocity_msb, y
			jmp set_high_byte
		direction_right:
			lda run_init_velocity_lsb, y
			sta player_a_velocity_h_low, x
			lda run_init_velocity_msb, y
		set_high_byte:
		sta player_a_velocity_h, x

		; Fallthrough to set animation
	.)
	pepper_set_running_animation:
	.(
		; Set the appropriate animation
		lda #<pepper_anim_run
		sta tmpfield13
		lda #>pepper_anim_run
		sta tmpfield14
		jmp set_player_animation

		;rts ; useless, jump to subroutine
	.)

	&pepper_tick_running:
	.(
		jsr pepper_global_tick

		; Update player's velocity dependeing on his direction
		ldy system_index
		lda player_a_direction, x
		beq run_left

			; Running right, velocity tends toward vector max velocity
			lda run_max_velocity_msb, y
			sta tmpfield4
			lda run_max_velocity_lsb, y
			jmp update_velocity

		run_left:
			; Running left, velocity tends toward vector "-1 * max volcity"
			lda run_max_neg_velocity_msb, y
			sta tmpfield4
			lda run_max_neg_velocity_lsb, y

		update_velocity:
			sta tmpfield2
			lda #0
			sta tmpfield3
			sta tmpfield1
			lda run_acceleration, y
			sta tmpfield5
			jmp merge_to_player_velocity
			; No return, jump to subroutine

		end:
		rts
	.)

	&pepper_input_running:
	.(
		; If in hitstun, stop running
		lda player_a_hitstun, x
		beq take_input
			jsr pepper_start_idle
			jmp end
		take_input:

			; Check state changes
			lda #<input_table
			sta tmpfield1
			lda #>input_table
			sta tmpfield2
			lda #INPUT_TABLE_LENGTH
			sta tmpfield3
			jmp controller_callbacks

		end:
		rts

		pepper_input_running_left:
		.(
			lda DIRECTION_LEFT
			cmp player_a_direction, x
			beq end_changing_direction
				sta player_a_direction, x
				jsr pepper_set_running_animation
			end_changing_direction:
			rts
		.)

		pepper_input_running_right:
		.(
			lda DIRECTION_RIGHT
			cmp player_a_direction, x
			beq end_changing_direction
				sta player_a_direction, x
				jsr pepper_set_running_animation
			end_changing_direction:
			rts
		.)

		input_table:
		.(
			controller_inputs:
			.byt CONTROLLER_INPUT_LEFT,               CONTROLLER_INPUT_RIGHT
			.byt CONTROLLER_INPUT_JUMP,               CONTROLLER_INPUT_JUMP_RIGHT,
			.byt CONTROLLER_INPUT_JUMP_LEFT,          CONTROLLER_INPUT_TECH
			.byt CONTROLLER_INPUT_TECH_LEFT,          CONTROLLER_INPUT_TECH_RIGHT
			.byt CONTROLLER_INPUT_DOWN_TILT,          CONTROLLER_INPUT_ATTACK_LEFT
			.byt CONTROLLER_INPUT_ATTACK_RIGHT,       CONTROLLER_INPUT_SPECIAL_LEFT
			.byt CONTROLLER_INPUT_SPECIAL_RIGHT,      CONTROLLER_INPUT_SPECIAL
			.byt CONTROLLER_INPUT_SPECIAL_UP,         CONTROLLER_INPUT_SPECIAL_UP_LEFT
			.byt CONTROLLER_INPUT_SPECIAL_UP_RIGHT,   CONTROLLER_INPUT_SPECIAL_UP_LEFT
			.byt CONTROLLER_INPUT_ATTACK_UP_RIGHT,    CONTROLLER_INPUT_ATTACK_UP
			.byt CONTROLLER_INPUT_JAB,                CONTROLLER_INPUT_SPECIAL_DOWN_LEFT
			.byt CONTROLLER_INPUT_SPECIAL_DOWN_RIGHT, CONTROLLER_INPUT_SPECIAL_DOWN
			.byt CONTROLLER_INPUT_ATTACK_DOWN_LEFT,   CONTROLLER_INPUT_ATTACK_DOWN_RIGHT
			controller_callbacks_lsb:
			.byt <pepper_input_running_left,        <pepper_input_running_right
			.byt <pepper_start_jumping,             <pepper_start_jumping
			.byt <pepper_start_jumping,             <pepper_start_shielding
			.byt <pepper_start_shielding,           <pepper_start_shielding
			.byt <pepper_start_down_tilt,           <pepper_start_side_tilt
			.byt <pepper_start_side_tilt,           <pepper_start_dzzz_left
			.byt <pepper_start_dzzz_right,          <pepper_start_plan_7b
			.byt <pepper_start_witch_fly,           <pepper_start_witch_fly_left
			.byt <pepper_start_witch_fly_right,     <pepper_start_up_tilt
			.byt <pepper_start_up_tilt,             <pepper_start_up_tilt
			.byt <pepper_start_flash_potion,        <pepper_start_wrench_grab
			.byt <pepper_start_wrench_grab,         <pepper_start_wrench_grab
			.byt <pepper_start_down_tilt,           <pepper_start_down_tilt
			controller_callbacks_msb:
			.byt >pepper_input_running_left,        >pepper_input_running_right
			.byt >pepper_start_jumping,             >pepper_start_jumping
			.byt >pepper_start_jumping,             >pepper_start_shielding
			.byt >pepper_start_shielding,           >pepper_start_shielding
			.byt >pepper_start_down_tilt,           >pepper_start_side_tilt
			.byt >pepper_start_side_tilt,           >pepper_start_dzzz_left
			.byt >pepper_start_dzzz_right,          >pepper_start_plan_7b
			.byt >pepper_start_witch_fly,           >pepper_start_witch_fly_left
			.byt >pepper_start_witch_fly_right,     >pepper_start_up_tilt
			.byt >pepper_start_up_tilt,             >pepper_start_up_tilt
			.byt >pepper_start_flash_potion,        >pepper_start_wrench_grab
			.byt >pepper_start_wrench_grab,         >pepper_start_wrench_grab
			.byt >pepper_start_down_tilt,           >pepper_start_down_tilt
			controller_default_callback:
			.word pepper_start_idle

			&INPUT_TABLE_LENGTH = controller_callbacks_lsb - controller_inputs
		.)
	.)
.)

;
; Jumping
;

.(
	&pepper_start_jumping:
	.(
		lda #PEPPER_STATE_JUMPING
		sta player_a_state, x

		lda #0
		sta player_a_state_clock, x

		jsr audio_play_jump

		; Set the appropriate animation
		lda #<pepper_anim_jump
		sta tmpfield13
		lda #>pepper_anim_jump
		sta tmpfield14
		jsr set_player_animation

		rts
	.)

	&pepper_tick_jumping:
	.(
		jsr pepper_global_tick

		; Tick clock
		inc player_a_state_clock, x

		; Wait for the preparation to end to begin to jump
		ldy system_index
		lda player_a_state_clock, x
		cmp pepper_jumpsquat_duration, y
		bcc end
		beq begin_to_jump

		; Handle short-hop input
		cmp pepper_short_hop_time, y
		beq stop_short_hop

		; Check if the top of the jump is reached
		lda player_a_velocity_v, x
		beq top_reached
		bpl top_reached

		; The top is not reached, stay in jumping state but apply gravity and directional influence
		moving_upward:
			jsr pepper_tick_falling ; Hack - We just use pepper_tick_falling which do exactly what we want
			jmp end

		; The top is reached, return to falling
		top_reached:
			jsr pepper_start_falling
			jmp end

		; If the jump button is no more pressed mid jump, convert the jump to a short-hop
		stop_short_hop:
			; Handle this tick as any other
			jsr pepper_tick_falling

			; If the jump button is still pressed, this is not a short-hop
			lda controller_a_btns, x
			and #CONTROLLER_INPUT_JUMP
			bne end

			; Reduce upward momentum to end the jump earlier
			ldy system_index
			lda pepper_jump_short_hop_velocity_msb, y
			sta player_a_velocity_v, x
			lda pepper_jump_short_hop_velocity_lsb, y
			sta player_a_velocity_v_low, x
			rts
			; No return

		; Put initial jumping velocity
		begin_to_jump:
			ldy system_index
			lda pepper_jump_velocity_msb, y
			sta player_a_velocity_v, x
			lda pepper_jump_velocity_lsb, y
			sta player_a_velocity_v_low, x
			;jmp end ; Useless, fallthrough

		end:
		rts
	.)

	&pepper_input_jumping:
	.(
		; The jump is cancellable by grounded movements during preparation
		; and by aerial movements after that
		lda player_a_num_aerial_jumps, x ; performing aerial jump, not
		bne not_grounded                 ; grounded

		ldy system_index
		lda player_a_state_clock, x   ;
		cmp pepper_jumpsquat_duration ; Still preparing the jump
		bcc grounded                  ;

		not_grounded:
		jsr pepper_check_aerial_inputs
		jmp end

		grounded:
		lda #<input_table
		sta tmpfield1
		lda #>input_table
		sta tmpfield2
		lda #INPUT_TABLE_LENGTH
		sta tmpfield3
		jmp controller_callbacks

		end:
		rts

		input_table:
		.(
			; Impactful controller states and associated callbacks (when still grounded)
			; Note - We can put subroutines as callbacks because we have nothing to do after calling it
			;        (sourboutines return to our caller since "called" with jmp)
			controller_inputs:
			.byt CONTROLLER_INPUT_ATTACK_UP,       CONTROLLER_INPUT_ATTACK_UP_LEFT
			.byt CONTROLLER_INPUT_ATTACK_UP_RIGHT, CONTROLLER_INPUT_SPECIAL_UP
			.byt CONTROLLER_INPUT_SPECIAL_UP_LEFT, CONTROLLER_INPUT_SPECIAL_UP_RIGHT
			controller_callbacks_lo:
			.byt <pepper_start_up_tilt,             <pepper_start_up_tilt
			.byt <pepper_start_up_tilt,             <pepper_start_witch_fly
			.byt <pepper_start_witch_fly_left,      <pepper_start_witch_fly_right
			controller_callbacks_hi:
			.byt >pepper_start_up_tilt,             >pepper_start_up_tilt
			.byt >pepper_start_up_tilt,             >pepper_start_witch_fly
			.byt >pepper_start_witch_fly_left, >pepper_start_witch_fly_right
			controller_default_callback:
			.word end
			&INPUT_TABLE_LENGTH = controller_callbacks_lo - controller_inputs
		.)
	.)
.)

.(
	&pepper_start_aerial_jumping:
	.(
		; Deny to start jump state if the player used all it's jumps
		lda #PEPPER_MAX_NUM_AERIAL_JUMPS
		cmp player_a_num_aerial_jumps, x
		bne jump_ok
		rts
		jump_ok:
		inc player_a_num_aerial_jumps, x

		; Reset fall speed
		jsr reset_default_gravity

		; Trick - aerial_jumping set the state to jumping. It is the same state with
		; the starting conditions as the only differences
		lda #PEPPER_STATE_JUMPING
		sta player_a_state, x

		; Reset clock
		lda #0
		sta player_a_state_clock, x

		lda #$00
		sta player_a_velocity_v, x
		lda #$00
		sta player_a_velocity_v_low, x

		; Play SFX
		jsr audio_play_aerial_jump

		; Set the appropriate animation
		;TODO use pepper_anim_aerial_jump animation
		lda #<pepper_anim_jump
		sta tmpfield13
		lda #>pepper_anim_jump
		sta tmpfield14
		jsr set_player_animation

		rts
	.)
.)

.(
	&pepper_start_falling:
	.(
		lda #PEPPER_STATE_FALLING
		sta player_a_state, x

		; Set the appropriate animation
		lda #<pepper_anim_falling
		sta tmpfield13
		lda #>pepper_anim_falling
		sta tmpfield14
		jsr set_player_animation

		rts
	.)

	&pepper_tick_falling:
	.(
		jsr pepper_global_tick

		jsr pepper_aerial_directional_influence
		jmp apply_player_gravity
		;rts ; useless, jump to subroutine
	.)
.)

;
; Landing
;

.(
	landing_duration:
		.byt pepper_anim_landing_dur_pal, pepper_anim_landing_dur_ntsc

	velocity_table(PEPPER_LANDING_MAX_VELOCITY, land_max_velocity_msb, land_max_velocity_lsb)
	velocity_table(-PEPPER_LANDING_MAX_VELOCITY, land_max_neg_velocity_msb, land_max_neg_velocity_lsb)

	&pepper_start_teching:
	.(
		jsr audio_play_tech
		jmp pepper_start_landing_common
	.)
	&pepper_start_landing:
	.(
		jsr audio_play_land
		; Fallthrough
	.)
	pepper_start_landing_common:
	.(
		jsr pepper_global_onground

		; Set state
		lda #PEPPER_STATE_LANDING
		sta player_a_state, x

		; Reset clock
		lda #0
		sta player_a_state_clock, x

		; Cap initial velocity
		ldy system_index
		lda player_a_velocity_h, x
		bmi negative_cap
			positive_cap:
			.(
				; Check wether to cap or not
				lda land_max_velocity_msb, y
				cmp player_a_velocity_h, x
				bcc do_cap ; msb(max) < msb(velocity)
				bne ok ; msb(max) > msb(velocity)
					lda player_a_velocity_h_low, x
					cmp land_max_velocity_lsb, y
					bcc ok ; lsb(velocity) < lsb(max)

				do_cap:
					lda land_max_velocity_msb, y
					sta player_a_velocity_h, x
					lda land_max_velocity_lsb, y
					sta player_a_velocity_h_low, x
				ok:
				jmp pepper_set_landing_animation
			.)
			negative_cap:
			.(
				; Check wether to cap or not - negative, we have to cap if unsigned CMP is lower than "max"
				lda player_a_velocity_h, x
				cmp land_max_velocity_msb, y
				bcc do_cap ; msb(velocity) < msb(max)
				bne ok ; msb(velocity) > msb(max)
					lda land_max_velocity_lsb, y
					cmp player_a_velocity_h_low, x
					bcc ok ; lsb(max) < lsb(velocity)

				do_cap:
					lda land_max_neg_velocity_msb, y
					sta player_a_velocity_h, x
					lda land_max_neg_velocity_lsb, y
					sta player_a_velocity_h_low, x
				ok:
			.)

		; Fallthrough to set the animation
	.)
	pepper_set_landing_animation:
	.(
		; Set the appropriate animation
		lda #<pepper_anim_landing
		sta tmpfield13
		lda #>pepper_anim_landing
		sta tmpfield14
		jmp set_player_animation

		;rts ; useless, jump to subroutine
	.)

	&pepper_tick_landing:
	.(
		jsr pepper_global_tick

		; Tick clock
		inc player_a_state_clock, x

		; Do not move, velocity tends toward vector (0,0)
		jsr pepper_apply_ground_friction

		; After move's time is out, go to standing state
		ldy system_index
		lda player_a_state_clock, x
		cmp landing_duration, y
		bne end
			jmp pepper_start_inactive_state
			; No return, jump to subroutine

		end:
		rts
	.)
.)

.(
	pepper_anim_aerial_wrench_grab_dur:
		.byt pepper_anim_aerial_wrench_grab_dur_pal, pepper_anim_aerial_wrench_grab_dur_ntsc

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

.(
	&pepper_start_helpless:
	.(
		; Set state
		lda #PEPPER_STATE_HELPLESS
		sta player_a_state, x

		; Set the appropriate animation
		lda #<pepper_anim_helpless
		sta tmpfield13
		lda #>pepper_anim_helpless
		sta tmpfield14
		jsr set_player_animation

		rts
	.)

	&pepper_tick_helpless:
	.(
		jsr pepper_global_tick

		jmp pepper_tick_falling
	.)

	&pepper_input_helpless:
	.(
		; Allow to escape helpless mode with a walljump, else keep input dirty
		lda player_a_walled, x
		beq no_jump
		lda player_a_walljump, x
		beq no_jump
			jump:
				lda player_a_walled_direction, x
				sta player_a_direction, x
				jmp pepper_start_walljumping
			no_jump:
				jmp keep_input_dirty
		;rts ; useless, both branches jump to a subroutine
	.)
.)

.(
	&pepper_start_shielding:
	.(
		; Set state
		lda #PEPPER_STATE_SHIELDING
		sta player_a_state, x

		; Reset clock
		lda #0
		sta player_a_state_clock, x

		; Set the appropriate animation
		lda #<pepper_anim_shield_full
		sta tmpfield13
		lda #>pepper_anim_shield_full
		sta tmpfield14
		jsr set_player_animation

		; Cancel momentum
		lda #$00
		sta player_a_velocity_h_low, x
		sta player_a_velocity_h, x

		; Set shield as full life
		lda #2
		sta player_a_state_field1, x

		rts
	.)

	&pepper_tick_shielding:
	.(
		jsr pepper_global_tick

		; Tick clock
		lda player_a_state_clock, x
		cmp #PLAYER_DOWN_TAP_MAX_DURATION
		bcs end_tick
			inc player_a_state_clock, x
		end_tick:

		rts
	.)

	&pepper_input_shielding:
	.(
		; Maintain down to stay on shield
		; Ignore left/right as they are too susceptible to be pressed unvoluntarily on a lot of gamepads
		; Down-a and down-b are allowed as out of shield moves
		; Any other combination ends the shield (with shield lag or falling from smooth platform)
		lda controller_a_btns, x
		and #CONTROLLER_BTN_A+CONTROLLER_BTN_B+CONTROLLER_BTN_UP+CONTROLLER_BTN_DOWN
		cmp #CONTROLLER_INPUT_TECH
		beq end
		cmp #CONTROLLER_INPUT_DOWN_TILT
		beq handle_input
		cmp #CONTROLLER_INPUT_SPECIAL_DOWN
		beq handle_input

		end_shield:

			lda #PLAYER_DOWN_TAP_MAX_DURATION
			cmp player_a_state_clock, x
			beq shieldlag
			bcc shieldlag
				ldy player_a_grounded, x
				beq shieldlag
					lda stage_data, y
					cmp #STAGE_ELEMENT_PLATFORM
					beq shieldlag
					cmp #STAGE_ELEMENT_OOS_PLATFORM
					beq shieldlag

			fall_from_smooth:
				; HACK - "position = position + 2" to compensate collision system not handling subpixels and "position + 1" being the collision line
				;        actually, "position = position + 3" to compensate for moving platforms that move down
				;        Better solution would be to have an intermediary player state with a specific animation
				clc
				lda player_a_y, x
				adc #3
				sta player_a_y, x
				lda player_a_y_screen, x
				adc #0
				sta player_a_y_screen, x

				jmp pepper_start_falling
				; No return, jump to subroutine

			shieldlag:
				jmp pepper_start_shieldlag
				; No return, jump to subroutine

		handle_input:

			jmp pepper_input_idle
			; No return, jump to subroutine

		end:
		rts
	.)

	&pepper_hurt_shielding:
	.(
		stroke_player = tmpfield11

		; Reduce shield's life
		dec player_a_state_field1, x

		; Select what to do according to shield's life
		lda player_a_state_field1, x
		beq limit_shield
		cmp #1
		beq partial_shield

			; Break the shield, derived from normal hurt with:
			;  Knockback * 2
			;  Screen shaking * 4
			;  Special sound
			jsr hurt_player
			ldx stroke_player
			asl player_a_velocity_h_low, x
			rol player_a_velocity_h, x
			asl player_a_velocity_v_low, x
			rol player_a_velocity_v, x
			asl player_a_hitstun, x
			asl screen_shake_counter
			asl screen_shake_counter
			jsr audio_play_shield_break
			jmp end

		partial_shield:
			; Get the animation corresponding to the shield's life
			lda #<pepper_anim_shield_partial
			sta tmpfield13
			lda #>pepper_anim_shield_partial
			jmp still_shield

		limit_shield:
			; Get the animation corresponding to the shield's life
			lda #<pepper_anim_shield_limit
			sta tmpfield13
			lda #>pepper_anim_shield_limit

		still_shield:
			; Set the new shield animation
			sta tmpfield14
			jsr set_player_animation

			; Play sound
			jsr audio_play_shield_hit

		end:
		; Disable the hitbox to avoid multi-hits
		SWITCH_SELECTED_PLAYER
		lda HITBOX_DISABLED
		sta player_a_hitbox_enabled, x

		rts
	.)
.)

.(
	shieldlag_duration:
		.byt pepper_anim_shield_remove_dur_pal, pepper_anim_shield_remove_dur_ntsc

	&pepper_start_shieldlag:
	.(
		; Set state
		lda #PEPPER_STATE_SHIELDLAG
		sta player_a_state, x

		; Reset clock
		ldy system_index
		lda shieldlag_duration, y
		sta player_a_state_clock, x

		; Set the appropriate animation
		lda #<pepper_anim_shield_remove
		sta tmpfield13
		lda #>pepper_anim_shield_remove
		sta tmpfield14
		jsr set_player_animation

		rts
	.)

	&pepper_tick_shieldlag:
	.(
		jsr pepper_global_tick

		dec player_a_state_clock, x
		bne tick
			jmp pepper_start_inactive_state
			; No return, jump to subroutine
		tick:
		jmp pepper_apply_ground_friction
		;rts ; useless, jump to subroutine
	.)
.)

.(
	velocity_table(-PEPPER_WALL_JUMP_VELOCITY_V, pepper_wall_jump_velocity_v_msb, pepper_wall_jump_velocity_v_lsb)
	velocity_table(PEPPER_WALL_JUMP_VELOCITY_H, pepper_wall_jump_velocity_h_msb, pepper_wall_jump_velocity_h_lsb)
	velocity_table(-PEPPER_WALL_JUMP_VELOCITY_H, pepper_wall_jump_velocity_h_neg_msb, pepper_wall_jump_velocity_h_neg_lsb)

	&pepper_start_walljumping:
	.(
		; Deny to start jump state if the player used all it's jumps
		;lda player_a_walljump, x ; useless, all calls to pepper_start_walljumping actually do this check
		;beq end

		; Update wall jump counter
		dec player_a_walljump, x

		; Set player's state
		lda #PEPPER_STATE_WALLJUMPING
		sta player_a_state, x

		; Reset clock
		lda #0
		sta player_a_state_clock, x

		; Stop any momentum, pepper does not fall during jumpsquat
		sta player_a_velocity_h, x
		sta player_a_velocity_h_low, x
		sta player_a_velocity_v, x
		sta player_a_velocity_v_low, x

		; Reset fall speed
		jsr reset_default_gravity

		; Play SFX
		jsr audio_play_jump

		; Set the appropriate animation
		;TODO specific animation
		lda #<pepper_anim_jump
		sta tmpfield13
		lda #>pepper_anim_jump
		sta tmpfield14
		jsr set_player_animation

		end:
		rts
	.)

	&pepper_tick_walljumping:
	.(
		jsr pepper_global_tick

		; Tick clock
		inc player_a_state_clock, x

		; Wait for the preparation to end to begin to jump
		lda player_a_state_clock, x
		cmp #PEPPER_WALL_JUMP_SQUAT_END
		bcc end
		beq begin_to_jump

		; Check if the top of the jump is reached
		lda player_a_velocity_v, x
		beq top_reached
		bpl top_reached

			; The top is not reached, stay in walljumping state but apply gravity, without directional influence
			jmp apply_player_gravity
			;jmp end ; useless, jump to a subroutine

		; The top is reached, return to falling
		top_reached:
			jmp pepper_start_falling
			;jmp end ; useless, jump to a subroutine

		; Put initial jumping velocity
		begin_to_jump:
			; Vertical velocity
			ldy system_index
			lda pepper_wall_jump_velocity_v_msb, y
			sta player_a_velocity_v, x
			lda pepper_wall_jump_velocity_v_lsb, y
			sta player_a_velocity_v_low, x

			; Horizontal velocity
			lda player_a_direction, x
			;cmp DIRECTION_LEFT ; useless while DIRECTION_LEFT is $00
			bne jump_right
				jump_left:
					lda pepper_wall_jump_velocity_h_neg_lsb, y
					sta player_a_velocity_h_low, x
					lda pepper_wall_jump_velocity_h_neg_msb, y
					jmp end_jump_direction
				jump_right:
					lda pepper_wall_jump_velocity_h_lsb, y
					sta player_a_velocity_h_low, x
					lda pepper_wall_jump_velocity_h_msb, y
			end_jump_direction:
			sta player_a_velocity_h, x

			;jmp end ; useless, fallthrough

		end:
		rts
	.)

	&pepper_input_walljumping:
	.(
		; The jump is cancellable by aerial movements, but only after preparation
		lda #PEPPER_WALL_JUMP_SQUAT_END
		cmp player_a_state_clock, x
		bcs grounded
			not_grounded:
				jmp pepper_check_aerial_inputs
				; no return, jump to a subroutine
		grounded:
		rts
	.)
.)

.(
	pepper_anim_dtilt_dur:
		.byt pepper_anim_dtilt_dur_pal, pepper_anim_dtilt_dur_ntsc

	&pepper_start_down_tilt:
	.(
		; Set state
		lda #PEPPER_STATE_DTILT
		sta player_a_state, x

		; Reset clock
		ldy system_index
		lda pepper_anim_dtilt_dur, y
		sta player_a_state_clock, x

		; Set the appropriate animation
		lda #<pepper_anim_dtilt
		sta tmpfield13
		lda #>pepper_anim_dtilt
		sta tmpfield14
		jmp set_player_animation

		;rts ; useless, jump to subroutine
	.)

	&pepper_tick_down_tilt:
	&pepper_tick_side_tilt:
	&pepper_tick_up_tilt:
	&pepper_tick_flash_potion:
	&pepper_tick_hyperspeed_crashing:
	&pepper_tick_wrench_grab:
	.(
		jsr pepper_global_tick

		; After move's time is out, go to standing state
		dec player_a_state_clock, x
		bne do_tick
			jmp pepper_start_idle
			; No return, jump to subroutine
		do_tick:

		; Do not move, velocity tends toward vector (0,0)
		jmp pepper_apply_ground_friction

		;rts ; useless, jump to subroutine
	.)
.)

.(
	STILT_DURATION = 20
	duration_table(STILT_DURATION, stilt_duration)

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
.)

.(
	pepper_anim_up_tilt_dur:
		.byt pepper_anim_up_tilt_dur_pal, pepper_anim_up_tilt_dur_ntsc

	&pepper_start_up_tilt:
	.(
		; Set state
		lda #PEPPER_STATE_UTILT
		sta player_a_state, x

		; Reset clock
		ldy system_index
		lda pepper_anim_up_tilt_dur, y
		sta player_a_state_clock, x

		; Set the appropriate animation
		lda #<pepper_anim_up_tilt
		sta tmpfield13
		lda #>pepper_anim_up_tilt
		sta tmpfield14
		jmp set_player_animation

		;rts ; useless, jump to subroutine
	.)
.)

.(
	pepper_anim_flash_potion_dur:
		.byt pepper_anim_flash_potion_dur_pal, pepper_anim_flash_potion_dur_ntsc

	&pepper_start_flash_potion:
	.(
		; Set state
		lda #PEPPER_STATE_FLASH_POTION
		sta player_a_state, x

		; Reset clock
		ldy system_index
		lda pepper_anim_flash_potion_dur, y
		sta player_a_state_clock, x

		; Set the appropriate animation
		lda #<pepper_anim_flash_potion
		sta tmpfield13
		lda #>pepper_anim_flash_potion
		sta tmpfield14
		jmp set_player_animation

		;rts ; useless, jump to subroutine
	.)
.)

.(
	HIT_TIME_PAL = 6
	HIT_TIME_NTSC = 7

	pepper_anim_aerial_wrench_dur:
		.byt pepper_anim_aerial_wrench_dur_pal, pepper_anim_aerial_wrench_dur_ntsc
	hit_time:
		.byt pepper_anim_aerial_wrench_dur_pal-HIT_TIME_PAL, pepper_anim_aerial_wrench_dur_ntsc-HIT_TIME_NTSC

	&pepper_start_aerial_side:
	.(
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

		;rts ; Fallthrough to generic aerial tick
	.)
	&pepper_tick_aerial_firework:
	.(
		jsr pepper_global_tick

		; After move's time is out, go to falling state
		dec player_a_state_clock, x
		bne do_tick
			jmp pepper_start_falling
			; No return, jump to subroutine
		do_tick:

		jsr pepper_aerial_directional_influence
		jmp apply_player_gravity
		;rts ; useless, jump to subroutine
	.)
.)

.(
	pepper_anim_firework_dur:
		.byt pepper_anim_firework_dur_pal, pepper_anim_firework_dur_ntsc

	&pepper_start_aerial_firework:
	.(
		; Set state
		lda #PEPPER_STATE_AERIAL_FIREWORK
		sta player_a_state, x

		; Reset clock
		ldy system_index
		lda pepper_anim_firework_dur, y
		sta player_a_state_clock, x

		; Set the appropriate animation
		lda #<pepper_anim_firework
		sta tmpfield13
		lda #>pepper_anim_firework
		sta tmpfield14
		jmp set_player_animation

		;rts ; useless, jump to subroutine
	.)
.)

.(
	;FIXME keyframe system is not ntsc-friendly
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

	&pepper_start_witch_fly_right:
	.(
		lda DIRECTION_RIGHT
		sta player_a_direction, x
		jmp pepper_start_witch_fly
		;rts ; useless, jump to subroutine
	.)
	&pepper_start_witch_fly_left:
	.(
		lda DIRECTION_LEFT
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

		witch_fly_velocity_h_lsb_per_direction:
			.byt <-VELOCITY_H, <VELOCITY_H
			.byt <-VELOCITY_H_NTSC, <VELOCITY_H_NTSC
		witch_fly_velocity_h_msb_per_direction:
			.byt >-VELOCITY_H, >VELOCITY_H
			.byt >-VELOCITY_H_NTSC, >VELOCITY_H_NTSC
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

		rts
	.)
.)

.(
	pepper_anim_wrench_grab_dur:
		.byt pepper_anim_wrench_grab_dur_pal, pepper_anim_wrench_grab_dur_ntsc

	&pepper_start_wrench_grab:
	.(
		; Set state
		lda #PEPPER_STATE_WRENCH_GRAB
		sta player_a_state, x

		; Reset clock
		ldy system_index
		lda pepper_anim_wrench_grab_dur, y
		sta player_a_state_clock, x

		; Set the appropriate animation
		lda #<pepper_anim_wrench_grab
		sta tmpfield13
		lda #>pepper_anim_wrench_grab
		sta tmpfield14
		jmp set_player_animation

		;rts ; useless, jump to subroutine
	.)
.)

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

!include "std_friction_routines.asm"

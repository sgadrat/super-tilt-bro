!define "char_name" {sinbad}
!define "char_name_upper" {SINBAD}

;
; States index
;

SINBAD_STATE_THROWN = PLAYER_STATE_THROWN                         ;  0
SINBAD_STATE_RESPAWN_INVISIBLE = PLAYER_STATE_RESPAWN             ;  1
SINBAD_STATE_INNEXISTANT = PLAYER_STATE_INNEXISTANT               ;  2
SINBAD_STATE_SPAWN = PLAYER_STATE_SPAWN                           ;  3
SINBAD_STATE_IDLE = PLAYER_STATE_STANDING                         ;  4
SINBAD_STATE_RUNNING = PLAYER_STATE_RUNNING                       ;  5
SINBAD_STATE_FALLING = CUSTOM_PLAYER_STATES_BEGIN + 0             ;  6
SINBAD_STATE_JUMPING = CUSTOM_PLAYER_STATES_BEGIN + 1             ;  7
SINBAD_STATE_JABBING_1 = CUSTOM_PLAYER_STATES_BEGIN + 2           ;  8
SINBAD_STATE_SIDE_TILT = CUSTOM_PLAYER_STATES_BEGIN + 3           ;  9
SINBAD_STATE_SPECIAL_CHARGE = CUSTOM_PLAYER_STATES_BEGIN + 4      ;  a
SINBAD_STATE_SPECIAL_STRIKE = CUSTOM_PLAYER_STATES_BEGIN + 5      ;  b
SINBAD_STATE_SIDE_SPECIAL = CUSTOM_PLAYER_STATES_BEGIN + 6        ;  c
SINBAD_STATE_HELPLESS = CUSTOM_PLAYER_STATES_BEGIN + 7            ;  d
SINBAD_STATE_LANDING = CUSTOM_PLAYER_STATES_BEGIN + 8             ;  e
SINBAD_STATE_CRASHING = CUSTOM_PLAYER_STATES_BEGIN + 9            ;  f
SINBAD_STATE_DOWN_TILT = CUSTOM_PLAYER_STATES_BEGIN + 10          ; 10
SINBAD_STATE_AERIAL_SIDE = CUSTOM_PLAYER_STATES_BEGIN + 11        ; 11
SINBAD_STATE_AERIAL_DOWN = CUSTOM_PLAYER_STATES_BEGIN + 12        ; 12
SINBAD_STATE_AERIAL_UP = CUSTOM_PLAYER_STATES_BEGIN + 13          ; 13
SINBAD_STATE_AERIAL_NEUTRAL = CUSTOM_PLAYER_STATES_BEGIN + 14     ; 14
SINBAD_STATE_AERIAL_SPE_NEUTRAL = CUSTOM_PLAYER_STATES_BEGIN + 15 ; 15
SINBAD_STATE_SPE_UP = CUSTOM_PLAYER_STATES_BEGIN + 16             ; 16
SINBAD_STATE_SPE_DOWN = CUSTOM_PLAYER_STATES_BEGIN + 17           ; 17
SINBAD_STATE_UP_TILT = CUSTOM_PLAYER_STATES_BEGIN + 18            ; 18
SINBAD_STATE_SHIELDING = CUSTOM_PLAYER_STATES_BEGIN + 19          ; 19
SINBAD_STATE_SHIELDLAG = CUSTOM_PLAYER_STATES_BEGIN + 20          ; 1a
SINBAD_STATE_WALLJUMPING = CUSTOM_PLAYER_STATES_BEGIN + 21        ; 1b
SINBAD_STATE_JABBING_2 = CUSTOM_PLAYER_STATES_BEGIN + 22          ; 1c
SINBAD_STATE_JABBING_3 = CUSTOM_PLAYER_STATES_BEGIN + 23          ; 1d
SINBAD_STATE_RESPAWN_PLATFORM = CUSTOM_PLAYER_STATES_BEGIN + 24   ; 1e

;
; Gameplay constants
;

SINBAD_AERIAL_SPEED = $0100
SINBAD_AERIAL_DIRECTIONAL_INFLUENCE_STRENGTH = $80
SINBAD_AIR_FRICTION_STRENGTH = 7
SINBAD_FASTFALL_SPEED = $0500
SINBAD_GROUND_FRICTION_STRENGTH = $40
SINBAD_JUMP_POWER = $0480
SINBAD_JUMP_SHORT_HOP_POWER = $0102
SINBAD_JUMP_SHORT_HOP_EXTRA_TIME_PAL = 4 ; Number of frames after jumpsquat at which shorthop is handled
SINBAD_JUMP_SHORT_HOP_EXTRA_TIME_NTSC = 5
SINBAD_JUMP_SQUAT_DURATION_PAL = 4
SINBAD_JUMP_SQUAT_DURATION_NTSC = 5
SINBAD_LANDING_MAX_VELOCITY = $0200
SINBAD_MAX_NUM_AERIAL_JUMPS = 1
SINBAD_MAX_WALLJUMPS = 1
SINBAD_RUNNING_INITIAL_VELOCITY = $0100
SINBAD_RUNNING_MAX_VELOCITY = $0200
SINBAD_RUNNING_ACCELERATION = $40
SINBAD_TECH_SPEED = $0400
SINBAD_WALL_JUMP_SQUAT_END = 4
SINBAD_WALL_JUMP_VELOCITY_V = $0480
SINBAD_WALL_JUMP_VELOCITY_H = $0100

;
; Constants data
;

velocity_table(SINBAD_AERIAL_SPEED, sinbad_aerial_speed_msb, sinbad_aerial_speed_lsb)
velocity_table(-SINBAD_AERIAL_SPEED, sinbad_aerial_neg_speed_msb, sinbad_aerial_neg_speed_lsb)
acceleration_table(SINBAD_AERIAL_DIRECTIONAL_INFLUENCE_STRENGTH, sinbad_aerial_directional_influence_strength)
acceleration_table(SINBAD_AIR_FRICTION_STRENGTH, sinbad_air_friction_strength)
velocity_table(SINBAD_FASTFALL_SPEED, sinbad_fastfall_speed_msb, sinbad_fastfall_speed_lsb)
acceleration_table(SINBAD_GROUND_FRICTION_STRENGTH, sinbad_ground_friction_strength)
acceleration_table(SINBAD_GROUND_FRICTION_STRENGTH/3, sinbad_ground_friction_strength_weak)
acceleration_table(SINBAD_GROUND_FRICTION_STRENGTH*3, sinbad_ground_friction_strength_strong)
velocity_table(SINBAD_TECH_SPEED, sinbad_tech_speed_msb, sinbad_tech_speed_lsb)
velocity_table(-SINBAD_TECH_SPEED, sinbad_tech_speed_neg_msb, sinbad_tech_speed_neg_lsb)
velocity_table(-SINBAD_JUMP_POWER, sinbad_jump_velocity_msb, sinbad_jump_velocity_lsb)
velocity_table(-SINBAD_JUMP_SHORT_HOP_POWER, sinbad_jump_short_hop_velocity_msb, sinbad_jump_short_hop_velocity_lsb)

sinbad_jumpsquat_duration:
	.byt SINBAD_JUMP_SQUAT_DURATION_PAL, SINBAD_JUMP_SQUAT_DURATION_NTSC

sinbad_short_hop_time:
	.byt SINBAD_JUMP_SQUAT_DURATION_PAL + SINBAD_JUMP_SHORT_HOP_EXTRA_TIME_PAL, SINBAD_JUMP_SQUAT_DURATION_NTSC + SINBAD_JUMP_SHORT_HOP_EXTRA_TIME_NTSC

;
; Implementation
;

sinbad_init:
sinbad_global_onground:
.(
	; Initialize walljump counter
	lda #SINBAD_MAX_WALLJUMPS
	sta player_a_walljump, x
	rts
.)

; Input table for aerial moves, special values are
;  fast_fall - mandatorily on INPUT_NONE to take effect on release of DOWN
;  jump      - automatically choose between aerial jump or wall jump
;  no_input  - expected default
!define "SINBAD_AERIAL_INPUTS_TABLE" {
	.(
		controller_inputs:
		.byt CONTROLLER_INPUT_NONE,               CONTROLLER_INPUT_SPECIAL_RIGHT
		.byt CONTROLLER_INPUT_SPECIAL_LEFT,       CONTROLLER_INPUT_JUMP
		.byt CONTROLLER_INPUT_JUMP_RIGHT,         CONTROLLER_INPUT_JUMP_LEFT
		.byt CONTROLLER_INPUT_ATTACK_LEFT,        CONTROLLER_INPUT_ATTACK_RIGHT
		.byt CONTROLLER_INPUT_DOWN_TILT,          CONTROLLER_INPUT_ATTACK_UP
		.byt CONTROLLER_INPUT_JAB,                CONTROLLER_INPUT_SPECIAL
		.byt CONTROLLER_INPUT_SPECIAL_UP,         CONTROLLER_INPUT_SPECIAL_DOWN
		.byt CONTROLLER_INPUT_ATTACK_UP_RIGHT,    CONTROLLER_INPUT_ATTACK_UP_LEFT
		.byt CONTROLLER_INPUT_SPECIAL_UP_RIGHT,   CONTROLLER_INPUT_SPECIAL_UP_LEFT
		.byt CONTROLLER_INPUT_ATTACK_DOWN_RIGHT,  CONTROLLER_INPUT_ATTACK_DOWN_LEFT
		.byt CONTROLLER_INPUT_SPECIAL_DOWN_RIGHT, CONTROLLER_INPUT_SPECIAL_DOWN_LEFT
		controller_callbacks_lo:
		.byt <fast_fall,                   <sinbad_start_side_special
		.byt <sinbad_start_side_special,   <jump
		.byt <jump,                        <jump
		.byt <sinbad_start_aerial_side,    <sinbad_start_aerial_side
		.byt <sinbad_start_aerial_down,    <sinbad_start_aerial_up
		.byt <sinbad_start_aerial_neutral, <sinbad_start_aerial_spe
		.byt <sinbad_start_spe_up,         <sinbad_start_spe_down
		.byt <sinbad_start_aerial_up,      <sinbad_start_aerial_up
		.byt <sinbad_start_spe_up,         <sinbad_start_spe_up
		.byt <sinbad_start_aerial_down,    <sinbad_start_aerial_down
		.byt <sinbad_start_spe_down,       <sinbad_start_spe_down
		controller_callbacks_hi:
		.byt >fast_fall,                   >sinbad_start_side_special
		.byt >sinbad_start_side_special,   >jump
		.byt >jump,                        >jump
		.byt >sinbad_start_aerial_side,    >sinbad_start_aerial_side
		.byt >sinbad_start_aerial_down,    >sinbad_start_aerial_up
		.byt >sinbad_start_aerial_neutral, >sinbad_start_aerial_spe
		.byt >sinbad_start_spe_up,         >sinbad_start_spe_down
		.byt >sinbad_start_aerial_up,      >sinbad_start_aerial_up
		.byt >sinbad_start_spe_up,         >sinbad_start_spe_up
		.byt >sinbad_start_aerial_down,    >sinbad_start_aerial_down
		.byt >sinbad_start_spe_down,       >sinbad_start_spe_down
		controller_default_callback:
		.word no_input
		&INPUT_TABLE_LENGTH = controller_callbacks_lo - controller_inputs
	.)
}

; Input table for idle state, special values are
;  input_idle_jump_left - Force LEFT direction and jump
;  input_idle_jump_right - Force RIGHT direction and jump
;  input_idle_tilt_left - Left tilt
;  input_idle_tilt_right - Right tilt
;  input_idle_left - Run to the left
;  input_idle_right - Run to the right
;  no_input - Default
!define "SINBAD_IDLE_INPUTS_TABLE" {
	.(
		controller_inputs:
		.byt CONTROLLER_INPUT_LEFT,              CONTROLLER_INPUT_RIGHT
		.byt CONTROLLER_INPUT_JUMP,              CONTROLLER_INPUT_JUMP_RIGHT
		.byt CONTROLLER_INPUT_JUMP_LEFT,         CONTROLLER_INPUT_JAB
		.byt CONTROLLER_INPUT_ATTACK_LEFT,       CONTROLLER_INPUT_ATTACK_RIGHT
		.byt CONTROLLER_INPUT_SPECIAL,           CONTROLLER_INPUT_SPECIAL_RIGHT
		.byt CONTROLLER_INPUT_SPECIAL_LEFT,      CONTROLLER_INPUT_DOWN_TILT
		.byt CONTROLLER_INPUT_SPECIAL_UP,        CONTROLLER_INPUT_SPECIAL_DOWN
		.byt CONTROLLER_INPUT_ATTACK_UP,         CONTROLLER_INPUT_TECH
		.byt CONTROLLER_INPUT_TECH_LEFT,         CONTROLLER_INPUT_TECH_RIGHT
		.byt CONTROLLER_INPUT_SPECIAL_UP_LEFT,   CONTROLLER_INPUT_SPECIAL_UP_RIGHT
		.byt CONTROLLER_INPUT_ATTACK_UP_LEFT,    CONTROLLER_INPUT_ATTACK_UP_RIGHT
		.byt CONTROLLER_INPUT_SPECIAL_DOWN_LEFT, CONTROLLER_INPUT_SPECIAL_DOWN_RIGHT
		.byt CONTROLLER_INPUT_ATTACK_DOWN_LEFT,  CONTROLLER_INPUT_ATTACK_DOWN_RIGHT
		controller_callbacks_lo:
		.byt <input_idle_left,                <input_idle_right
		.byt <sinbad_start_jumping,           <input_idle_jump_right
		.byt <input_idle_jump_left,           <sinbad_start_jabbing
		.byt <input_idle_tilt_left,           <input_idle_tilt_right
		.byt <sinbad_start_special,           <sinbad_start_side_special_right
		.byt <sinbad_start_side_special_left, <sinbad_start_down_tilt
		.byt <sinbad_start_spe_up,            <sinbad_start_spe_down
		.byt <sinbad_start_up_tilt,           <sinbad_start_shielding
		.byt <sinbad_start_shielding,         <sinbad_start_shielding
		.byt <sinbad_start_spe_up,            <sinbad_start_spe_up
		.byt <sinbad_start_up_tilt,           <sinbad_start_up_tilt
		.byt <sinbad_start_spe_down,          <sinbad_start_spe_down
		.byt <sinbad_start_down_tilt,         <sinbad_start_down_tilt
		controller_callbacks_hi:
		.byt >input_idle_left,                >input_idle_right
		.byt >sinbad_start_jumping,           >input_idle_jump_right
		.byt >input_idle_jump_left,           >sinbad_start_jabbing
		.byt >input_idle_tilt_left,           >input_idle_tilt_right
		.byt >sinbad_start_special,           >sinbad_start_side_special_right
		.byt >sinbad_start_side_special_left, >sinbad_start_down_tilt
		.byt >sinbad_start_spe_up,            >sinbad_start_spe_down
		.byt >sinbad_start_up_tilt,           >sinbad_start_shielding
		.byt >sinbad_start_shielding,         >sinbad_start_shielding
		.byt >sinbad_start_spe_up,            >sinbad_start_spe_up
		.byt >sinbad_start_up_tilt,           >sinbad_start_up_tilt
		.byt >sinbad_start_spe_down,          >sinbad_start_spe_down
		.byt >sinbad_start_down_tilt,         >sinbad_start_down_tilt
		controller_default_callback:
		.word no_input
		&INPUT_TABLE_LENGTH = controller_callbacks_lo - controller_inputs
	.)
}

; Input table for running state, special values are
;  input_running_left - Change running direction to the left (if not already running to the left)
;  input_runnning_right - Change running direction to the right (if not already running to the right)
!define "SINBAD_RUNNING_INPUTS_TABLE" {
	.(
		controller_inputs:
		.byt CONTROLLER_INPUT_LEFT,              CONTROLLER_INPUT_RIGHT
		.byt CONTROLLER_INPUT_JUMP,              CONTROLLER_INPUT_JUMP_RIGHT
		.byt CONTROLLER_INPUT_JUMP_LEFT,         CONTROLLER_INPUT_ATTACK_LEFT
		.byt CONTROLLER_INPUT_ATTACK_RIGHT,      CONTROLLER_INPUT_SPECIAL
		.byt CONTROLLER_INPUT_SPECIAL_RIGHT,     CONTROLLER_INPUT_SPECIAL_LEFT
		.byt CONTROLLER_INPUT_SPECIAL_UP,        CONTROLLER_INPUT_SPECIAL_DOWN
		.byt CONTROLLER_INPUT_TECH_LEFT,         CONTROLLER_INPUT_TECH_RIGHT
		.byt CONTROLLER_INPUT_SPECIAL_UP_LEFT,   CONTROLLER_INPUT_SPECIAL_UP_RIGHT
		.byt CONTROLLER_INPUT_ATTACK_UP_LEFT,    CONTROLLER_INPUT_ATTACK_UP_RIGHT
		.byt CONTROLLER_INPUT_SPECIAL_DOWN_LEFT, CONTROLLER_INPUT_SPECIAL_DOWN_RIGHT
		.byt CONTROLLER_INPUT_ATTACK_DOWN_LEFT,  CONTROLLER_INPUT_ATTACK_DOWN_RIGHT
		.byt CONTROLLER_INPUT_DOWN_TILT
		controller_callbacks_lo:
		.byt <input_running_left,           <input_running_right
		.byt <sinbad_start_jumping,         <sinbad_start_jumping
		.byt <sinbad_start_jumping,         <sinbad_start_side_tilt_left
		.byt <sinbad_start_side_tilt_right, <sinbad_start_special
		.byt <sinbad_start_side_special,    <sinbad_start_side_special
		.byt <sinbad_start_spe_up,          <sinbad_start_spe_down
		.byt <sinbad_start_shielding,       <sinbad_start_shielding
		.byt <sinbad_start_spe_up,          <sinbad_start_spe_up
		.byt <sinbad_start_up_tilt,         <sinbad_start_up_tilt
		.byt <sinbad_start_spe_down,        <sinbad_start_spe_down
		.byt <sinbad_start_down_tilt,       <sinbad_start_down_tilt
		.byt <sinbad_start_down_tilt
		controller_callbacks_hi:
		.byt >input_running_left,           >input_running_right
		.byt >sinbad_start_jumping,         >sinbad_start_jumping
		.byt >sinbad_start_jumping,         >sinbad_start_side_tilt_left
		.byt >sinbad_start_side_tilt_right, >sinbad_start_special
		.byt >sinbad_start_side_special,    >sinbad_start_side_special
		.byt >sinbad_start_spe_up,          >sinbad_start_spe_down
		.byt >sinbad_start_shielding,       >sinbad_start_shielding
		.byt >sinbad_start_spe_up,          >sinbad_start_spe_up
		.byt >sinbad_start_up_tilt,         >sinbad_start_up_tilt
		.byt >sinbad_start_spe_down,        >sinbad_start_spe_down
		.byt >sinbad_start_down_tilt,       >sinbad_start_down_tilt
		.byt >sinbad_start_down_tilt
		controller_default_callback:
		.word sinbad_start_idle
		&INPUT_TABLE_LENGTH = controller_callbacks_lo - controller_inputs
	.)
}

; Input table for jumping state state (only used during jumpsquat), special values are
;  no_input - default
!define "SINBAD_JUMPSQUAT_INPUTS_TABLE" {
	.(
		controller_inputs:
		.byt CONTROLLER_INPUT_ATTACK_UP,       CONTROLLER_INPUT_SPECIAL_UP
		.byt CONTROLLER_INPUT_ATTACK_UP_LEFT,  CONTROLLER_INPUT_SPECIAL_UP_LEFT
		.byt CONTROLLER_INPUT_ATTACK_UP_RIGHT, CONTROLLER_INPUT_SPECIAL_UP_RIGHT
		controller_callbacks_lo:
		.byt <sinbad_start_up_tilt, <sinbad_start_spe_up
		.byt <sinbad_start_up_tilt, <sinbad_start_spe_up
		.byt <sinbad_start_up_tilt, <sinbad_start_spe_up
		controller_callbacks_hi:
		.byt >sinbad_start_up_tilt, >sinbad_start_spe_up
		.byt >sinbad_start_up_tilt, >sinbad_start_spe_up
		.byt >sinbad_start_up_tilt, >sinbad_start_spe_up
		controller_default_callback:
		.word no_input
		&INPUT_TABLE_LENGTH = controller_callbacks_lo - controller_inputs
	.)
}

!include "std_aerial_input.asm"
!include "std_crashing.asm"
!include "std_thrown.asm"
!include "std_respawn.asm"
!include "std_innexistant.asm"
!include "std_spawn.asm"
!include "std_idle.asm"
!include "std_running.asm"
!include "std_jumping.asm"
!include "std_landing.asm"
!include "std_helpless.asm"
!include "std_shielding.asm"
!include "std_walljumping.asm"

;
; Jab
;

.(
	jab1_duration:
		.byt sinbad_anim_jab1_dur_pal, sinbad_anim_jab1_dur_ntsc
	anim_duration_table(sinbad_anim_jab1_dur_pal-10, jab1_cuttable_duration)

	jab2_duration:
		.byt sinbad_anim_jab2_dur_pal, sinbad_anim_jab2_dur_ntsc
	anim_duration_table(sinbad_anim_jab2_dur_pal-10, jab2_cuttable_duration)

	jab3_duration:
		.byt sinbad_anim_jab3_dur_pal, sinbad_anim_jab3_dur_ntsc
	anim_duration_table(sinbad_anim_jab3_dur_pal-9, jab3_sfx_time)

	&sinbad_start_jabbing:
	.(
		lda #SINBAD_STATE_JABBING_1
		sta player_a_state, x
		ldy system_index
		lda jab1_duration, y
		sta player_a_state_clock, x

		; Set the appropriate animation
		lda #<sinbad_anim_jab1
		sta tmpfield13
		lda #>sinbad_anim_jab1
		sta tmpfield14
		jsr set_player_animation

		; SFX
		jmp audio_play_strike_lite

		;rts ; useless, jump to subroutine
	.)

	&sinbad_start_jabbing2:
	.(
		lda #SINBAD_STATE_JABBING_2
		sta player_a_state, x
		ldy system_index
		lda jab2_duration, y
		sta player_a_state_clock, x

		; Set the appropriate animation
		lda #<sinbad_anim_jab2
		sta tmpfield13
		lda #>sinbad_anim_jab2
		sta tmpfield14
		jsr set_player_animation

		; SFX
		jmp audio_play_strike_lite

		;rts ; useless, jump to subroutine
	.)

	&sinbad_start_jabbing3:
	.(
		lda #SINBAD_STATE_JABBING_3
		sta player_a_state, x
		ldy system_index
		lda jab2_duration, y
		sta player_a_state_clock, x

		; Set the appropriate animation
		lda #<sinbad_anim_jab3
		sta tmpfield13
		lda #>sinbad_anim_jab3
		sta tmpfield14
		jmp set_player_animation

		;rts ; useless, jump to subroutine
	.)

	&sinbad_tick_jab3:
	.(
		; Play SFX when landing
		ldy system_index
		lda player_a_state_clock, x
		cmp jab3_sfx_time, y
		bne ok

			jsr sinbad_audio_play_jab3_land

		ok:
		;Fallthrough
	.)
	&sinbad_tick_jabbing:
	.(
		; Do not move, velocity tends toward vector (0,0)
		lda #$00
		sta tmpfield4
		sta tmpfield3
		sta tmpfield2
		sta tmpfield1
		lda #$ff
		sta tmpfield5
		jsr merge_to_player_velocity

		; At the end of the move, return to idle state
		dec player_a_state_clock, x
		bne end
			jmp sinbad_start_inactive_state
			; No return, jump to subroutine

		end:
		rts
	.)

	&sinbad_input_jabbing1:
	.(
		ldy system_index
		lda jab1_cuttable_duration, y
		cmp player_a_state_clock, x
		bcs take_input

			not_yet:
				; Keep keypress dirty, but acknowledge key release
				;  So releasing then pressing again jab input correctly bufferises the jab input
				lda controller_a_btns, x
				beq end
					jmp keep_input_dirty

			take_input:
				; Allow to cut the animation for another jab
				lda controller_a_btns, x
				cmp #CONTROLLER_INPUT_JAB
				bne end
					jmp sinbad_start_jabbing2
					; No return, jump to subroutine

		end:
		rts
	.)

	&sinbad_input_jabbing2:
	.(
		ldy system_index
		lda jab2_cuttable_duration, y
		cmp player_a_state_clock, x
		bcs take_input

			not_yet:
				; Keep keypress dirty, but acknowledge key release
				;  So releasing then pressing again jab input correctly bufferises the jab input
				lda controller_a_btns, x
				beq end
					jmp keep_input_dirty

			take_input:
				; Allow to cut the animation for another jab
				lda controller_a_btns, x
				cmp #CONTROLLER_INPUT_JAB
				bne end
					jmp sinbad_start_jabbing3
					; No return, jump to subroutine

		end:
		rts
	.)
.)

;
; Side tilt
;

.(
	side_tilt_duration:
		.byt sinbad_anim_side_tilt_dur_pal, sinbad_anim_side_tilt_dur_ntsc

	; Not per-system constant
	;  The static decay ensures the same distance is traveled
	;  The difference in travel speed is barely noticeable (when focusing on it)
	;  Seriously, this animation is ugly and should be rework anyway
	VELOCITY_H = $0480
	VELOCITY_V = $fd80
	VELOCITY_DECAY = $80

	&sinbad_start_side_tilt_right:
	.(
		lda DIRECTION_RIGHT
		sta player_a_direction, x
		jmp sinbad_start_side_tilt
		; rts ; useless - sinbad_start_side_tilt is a routine
	.)

	&sinbad_start_side_tilt_left:
	.(
		lda DIRECTION_LEFT
		sta player_a_direction, x
		; jmp sinbad_start_side_tilt ; useless - fallthrough
		; rts ; useless - sinbad_start_side_tilt is a routine
	.)

	&sinbad_start_side_tilt:
	.(
		; Set the appropriate animation
		lda #<sinbad_anim_side_tilt
		sta tmpfield13
		lda #>sinbad_anim_side_tilt
		sta tmpfield14
		jsr set_player_animation

		; Set the player's state
		lda #SINBAD_STATE_SIDE_TILT
		sta player_a_state, x

		; Initialize the clock
		ldy system_index
		lda side_tilt_duration, y
		sta player_a_state_clock,x

		; Set initial velocity
		lda #>VELOCITY_V
		sta player_a_velocity_v, x
		lda #<VELOCITY_V
		sta player_a_velocity_v_low, x

		lda player_a_direction, x
		beq set_velocity_left
			set_velocity_right:
				lda #>VELOCITY_H
				sta player_a_velocity_h, x
				jmp end_set_velocity
			set_velocity_left:
				lda #>-VELOCITY_H
				sta player_a_velocity_h, x
		end_set_velocity:
		lda #<VELOCITY_H ;NOTE this is the same as "<-VELOCITY_H" ($80)
		sta player_a_velocity_h_low, x

		rts
	.)

	; Update a player that is performing a side tilt
	;  register X must contain the player number
	&sinbad_tick_side_tilt:
	.(
		dec player_a_state_clock, x
		bne update_velocity
			jmp sinbad_start_inactive_state
			; No return, jump to a subroutine

		update_velocity:
			lda #$01
			sta tmpfield3
			lda #$00
			sta tmpfield4
			sta tmpfield1
			sta tmpfield2
			lda #VELOCITY_DECAY
			sta tmpfield5
			jmp merge_to_player_velocity
			; No return, jump to subroutine
	.)
.)

;
; Grounded neutral special
;

.(
	SINBAD_GROUNDED_SPECIAL_CHARGE_DURATION = 20
	duration_table(SINBAD_GROUNDED_SPECIAL_CHARGE_DURATION, duration_per_system)

	&sinbad_start_special:
	.(
		; Set the appropriate animation
		lda #<sinbad_anim_special_charge
		sta tmpfield13
		lda #>sinbad_anim_special_charge
		sta tmpfield14
		jsr set_player_animation

		; Set the player's state
		lda #SINBAD_STATE_SPECIAL_CHARGE
		sta player_a_state, x

		; Stop any momentum
		lda #$00
		sta player_a_velocity_h_low, x
		sta player_a_velocity_h, x
		sta player_a_velocity_v_low, x
		sta player_a_velocity_v, x

		; Initialize the clock
		ldy system_index
		lda duration_per_system, y
		sta player_a_state_clock, x

		rts
	.)

	&sinbad_tick_special_charge:
	.(
		dec player_a_state_clock, x
		bne end
			jmp sinbad_start_special_strike
			; No return, jump to a subroutine
		end:
		rts
	.)
.)

.(
	duration_per_system:
		.byt 2*sinbad_anim_special_dur_pal, 2*sinbad_anim_special_dur_ntsc

	STRIKE_HEIGHT = $10

	&sinbad_start_special_strike:
	.(

		; Set the appropriate animation
		lda #<sinbad_anim_special
		sta tmpfield13
		lda #>sinbad_anim_special
		sta tmpfield14
		jsr set_player_animation

		; Set the player's state
		lda #SINBAD_STATE_SPECIAL_STRIKE
		sta player_a_state, x

		; Place the player above ground
		lda player_a_y, x
		sec
		sbc #STRIKE_HEIGHT
		sta player_a_y, x

		; Initialize the clock
		ldy system_index
		lda duration_per_system, y
		sta player_a_state_clock, x

		rts
	.)

	&sinbad_tick_special_strike:
	.(
		dec player_a_state_clock, x
		bne end
			jmp sinbad_start_helpless
			; No return, jump to a subroutine
		end:
		rts
	.)
.)

;
; Side special
;

.(
	CHARGE_DURATION = 120
	MOVING_VELOCITY_V = $0080
	MOVING_VELOCITY_H = $0400

	duration_table(CHARGE_DURATION, charge_duration)
	velocity_table(-MOVING_VELOCITY_V, moving_velocity_v_msb, moving_velocity_v_lsb)
	velocity_table(MOVING_VELOCITY_H, moving_velocity_h_msb, moving_velocity_h_lsb)
	velocity_table(-MOVING_VELOCITY_H, moving_velocity_h_neg_msb, moving_velocity_h_neg_lsb)

	&sinbad_start_side_special_left:
	.(
		lda DIRECTION_LEFT
		sta player_a_direction, x
		jmp sinbad_start_side_special
		;rts ; useless, jump to subroutine
	.)

	&sinbad_start_side_special_right:
	.(
		lda DIRECTION_RIGHT
		sta player_a_direction, x
		;jmp sinbad_start_side_special ; useless, fallthrough
		; Falltrhough to sinbad_start_side_special
	.)

	&sinbad_start_side_special:
	.(
		; Set state
		lda #SINBAD_STATE_SIDE_SPECIAL
		sta player_a_state, x

		; Set initial velocity
		lda #$00
		sta player_a_velocity_h_low, x
		sta player_a_velocity_h, x
		sta player_a_velocity_v_low, x
		sta player_a_velocity_v, x

		; Reset clock
		sta player_a_state_clock, x

		; Set substate to "charging"
		sta player_a_state_field1, x

		; Fallthrough to set the animation
	.)
	set_side_special_animation:
	.(
		; Set the appropriate animation
		lda #<sinbad_anim_side_special_charge
		sta tmpfield13
		lda #>sinbad_anim_side_special_charge
		sta tmpfield14
		jmp set_player_animation

		;rts ; useless, jump to subroutine
	.)

	&sinbad_tick_side_special:
	.(
		; Tick clock
		inc player_a_state_clock, x

		; Move if the substate is set to moving
		lda player_a_state_field1, x
		bne moving

		; Check if there is reason to begin to move
		ldy system_index
		lda player_a_state_clock, x
		cmp charge_duration, y
		bcs start_moving
		lda controller_a_btns, x
		cmp #CONTROLLER_INPUT_SPECIAL_RIGHT
		beq not_moving
		cmp #CONTROLLER_INPUT_SPECIAL_LEFT
		bne start_moving

		not_moving:
			jmp end

		start_moving:
			; Set substate to "moving"
			lda #$01
			sta player_a_state_field1, x

			; Store fly duration (fly_duration = 5 + charge_duration / 8)
			;NOTE The division of duration is pal/ntsc independent, the "5" constant could be made system-specific (but it would be minor)
			lda player_a_state_clock, x
			lsr
			lsr
			lsr
			clc
			adc #5
			sta player_a_state_field2, x

			; Set the movement animation
			lda #<sinbad_anim_side_special_jump
			sta tmpfield13
			lda #>sinbad_anim_side_special_jump
			sta tmpfield14
			jsr set_player_animation

			; Reset clock
			lda #0
			sta player_a_state_clock, x

		moving:
			; Set vertical velocity (fixed)
			ldy system_index
			lda moving_velocity_v_msb, y
			sta player_a_velocity_v, x
			lda moving_velocity_v_lsb, y
			sta player_a_velocity_v_low, x

			; Set horizontal velocity (depending on direction)
			lda player_a_direction, x
			cmp DIRECTION_LEFT
			bne right_velocity
				left_velocity:
					lda moving_velocity_h_neg_msb, y
					sta player_a_velocity_h, x
					lda moving_velocity_h_neg_lsb, y
					jmp h_velocity_ok
				right_velocity:
					lda moving_velocity_h_msb, y
					sta player_a_velocity_h, x
					lda moving_velocity_h_lsb, y
			h_velocity_ok:
			sta player_a_velocity_h_low, x

		; After move's time is out, go to helpless state
		lda player_a_state_clock, x
		cmp player_a_state_field2, x
		bne end
			jmp sinbad_start_helpless
			; No return, jump to subroutine

		end:
		rts
	.)
.)

;
; Down tilt
;

!define "anim" {sinbad_anim_down_tilt}
!define "state" {SINBAD_STATE_DOWN_TILT}
!define "routine" {down_tilt}
!include "tpl_grounded_attack.asm"

;
; Aerial side
;

!define "anim" {sinbad_anim_aerial_side}
!define "state" {SINBAD_STATE_AERIAL_SIDE}
!define "routine" {aerial_side}
!include "tpl_aerial_attack.asm"

;
; Aerial down
;

!define "anim" {sinbad_anim_aerial_down}
!define "state" {SINBAD_STATE_AERIAL_DOWN}
!define "routine" {aerial_down}
!include "tpl_aerial_attack.asm"

;
; Aerial up
;

!define "anim" {sinbad_anim_aerial_up}
!define "state" {SINBAD_STATE_AERIAL_UP}
!define "routine" {aerial_up}
!include "tpl_aerial_attack.asm"

;
; Aerial neutral
;

!define "anim" {sinbad_anim_aerial_neutral}
!define "state" {SINBAD_STATE_AERIAL_NEUTRAL}
!define "routine" {aerial_neutral}
!include "tpl_aerial_attack.asm"

;
; Aerial special
;

.(
	FALL_SPEED = $0100
	FALL_ACCELERATION = $10

	velocity_table(FALL_SPEED, fall_speed_msb, fall_speed_lsb)
	velocity_table_u8(FALL_ACCELERATION, fall_acceleration)

	&sinbad_start_aerial_spe:
	.(
		; Set state
		lda #SINBAD_STATE_AERIAL_SPE_NEUTRAL
		sta player_a_state, x

		; Set substate to "not cancelable"
		lda #0
		sta player_a_state_field1, x

		; Fallthrough to set the animation
	.)
	set_aerial_spe_animation:
	.(
		; Set the appropriate animation
		lda #<sinbad_anim_aerial_spe
		sta tmpfield13
		lda #>sinbad_anim_aerial_spe
		sta tmpfield14
		jsr set_player_animation

		rts
	.)

	&sinbad_tick_aerial_spe:
	.(
		jsr sinbad_aerial_directional_influence

		; Never move upward in this state
		lda player_a_velocity_v, x
		bpl end_max_velocity
			lda #$00
			sta player_a_velocity_v, x
			sta player_a_velocity_v_low, x
		end_max_velocity:

		; Special fall speed - particularily slow
		lda player_a_velocity_h, x
		sta tmpfield4
		lda player_a_velocity_h_low, x
		sta tmpfield2
		ldy system_index
		lda fall_speed_msb, y
		sta tmpfield3
		lda fall_speed_lsb, y
		sta tmpfield1
		lda fall_acceleration, y
		sta tmpfield5
		jsr merge_to_player_velocity

		rts
	.)

	&sinbad_input_aerial_spe:
	.(
		lda player_a_state_field1, x
		beq check_release

			check_cancel:
				; Press B again to cancel into helpless
				lda controller_a_btns, x
				and #CONTROLLER_BTN_B
				beq end

					jmp sinbad_start_helpless
					; No return, jump to a subroutine

			check_release:
				; Release B to pass in "cancelable" substate
				lda controller_a_btns, x
				and #CONTROLLER_BTN_B
				bne end

					inc player_a_state_field1, x
					; Fallthrough

		end:
		rts
	.)
.)

.(
	SPE_UP_PREPARATION_DURATION = 3
	SPE_UP_POWER = $0600

	velocity_table(-SPE_UP_POWER, spe_up_power_msb, spe_up_power_lsb)

	&sinbad_start_spe_up:
	.(
		; Set state
		lda #SINBAD_STATE_SPE_UP
		sta player_a_state, x

		; Reset fall speed
		jsr reset_default_gravity

		; Set initial velocity
		lda #$00
		sta player_a_velocity_h_low, x
		sta player_a_velocity_h, x
		sta player_a_velocity_v_low, x
		sta player_a_velocity_v, x

		; Reset clock
		sta player_a_state_clock, x

		; Set substate to "charging"
		sta player_a_state_field1, x

		; Fallthrough to set the animation
	.)
	set_spe_up_animation:
	.(
		; Set the appropriate animation
		lda #<sinbad_anim_spe_up_prepare
		sta tmpfield13
		lda #>sinbad_anim_spe_up_prepare
		sta tmpfield14
		jsr set_player_animation

		rts
	.)

	&sinbad_tick_spe_up:
	.(
		; Tick clock
		inc player_a_state_clock, x

		; Move if the substate is set to moving
		lda player_a_state_field1, x
		bne moving

		; Check if there is reason to begin to move
		lda player_a_state_clock, x
		cmp #SPE_UP_PREPARATION_DURATION
		bcs start_moving

		not_moving:
			jmp end

		start_moving:
			; Set substate to "moving"
			lda #$01
			sta player_a_state_field1, x

			; Set jumping velocity
			ldy system_index
			lda spe_up_power_msb, y
			sta player_a_velocity_v, x
			lda spe_up_power_lsb, y
			sta player_a_velocity_v_low, x

			; Set the movement animation
			lda #<sinbad_anim_spe_up_jump
			sta tmpfield13
			lda #>sinbad_anim_spe_up_jump
			sta tmpfield14
			jsr set_player_animation

		moving:
			; Return to falling when the top is reached
			lda player_a_velocity_v, x
			beq top_reached
			bpl top_reached

				; The top is not reached, stay in special upward state but apply gravity and directional influence
				jsr sinbad_aerial_directional_influence
				jsr apply_player_gravity
				jmp end

			top_reached:
				jsr sinbad_start_helpless
				jmp end

		end:
		rts
	.)
.)

.(
	spe_down_duration:
		.byt sinbad_anim_spe_down_dur_pal, sinbad_anim_spe_down_dur_ntsc

	&sinbad_start_spe_down:
	.(
		; Set state
		lda #SINBAD_STATE_SPE_DOWN
		sta player_a_state, x

		; Reset clock
		lda #0
		sta player_a_state_clock, x

		; Fallthrough to set the animation
	.)
	set_spe_down_animation:
	.(
		; Set the appropriate animation
		lda #<sinbad_anim_spe_down
		sta tmpfield13
		lda #>sinbad_anim_spe_down
		sta tmpfield14
		jsr set_player_animation

		rts
	.)

	&sinbad_tick_spe_down:
	.(
		lda player_a_grounded, x
		beq air_friction
			ground_friction:
				lda #$00
				sta tmpfield4
				sta tmpfield3
				sta tmpfield2
				sta tmpfield1
				ldy system_index
				lda sinbad_ground_friction_strength_weak, y
				sta tmpfield5
				jsr merge_to_player_velocity
				jmp end_friction
			air_friction:
				jsr sinbad_apply_air_friction
				jsr apply_player_gravity
				; Fallthrough
		end_friction:

		; Wait for move's timeout
		ldy system_index
		inc player_a_state_clock, x
		lda player_a_state_clock, x
		cmp spe_down_duration, y
		bne end

		; Return to falling or idle
		jmp sinbad_start_inactive_state
		; No return, jump to subroutine

		end:
		rts
	.)
.)

!define "anim" {sinbad_anim_up_tilt}
!define "state" {SINBAD_STATE_UP_TILT}
!define "routine" {up_tilt}
!include "tpl_grounded_attack.asm"

!include "std_friction_routines.asm"

!define "char_name" {sinbad}
!define "char_name_upper" {SINBAD}

;
; States index
;

SINBAD_STATE_THROWN = PLAYER_STATE_THROWN                         ; 00
SINBAD_STATE_RESPAWN_INVISIBLE = PLAYER_STATE_RESPAWN             ; 01
SINBAD_STATE_INNEXISTANT = PLAYER_STATE_INNEXISTANT               ; 02
SINBAD_STATE_SPAWN = PLAYER_STATE_SPAWN                           ; 03
SINBAD_STATE_OWNED = PLAYER_STATE_OWNED                           ; 04
SINBAD_STATE_IDLE = PLAYER_STATE_STANDING                         ; 05
SINBAD_STATE_RUNNING = PLAYER_STATE_RUNNING                       ; 06
SINBAD_STATE_FALLING = CUSTOM_PLAYER_STATES_BEGIN + 0             ; 07
SINBAD_STATE_JUMPING = CUSTOM_PLAYER_STATES_BEGIN + 1             ; 08
SINBAD_STATE_JABBING_1 = CUSTOM_PLAYER_STATES_BEGIN + 2           ; 09
SINBAD_STATE_SIDE_TILT = CUSTOM_PLAYER_STATES_BEGIN + 3           ; 0a
SINBAD_STATE_SPECIAL_CHARGE = CUSTOM_PLAYER_STATES_BEGIN + 4      ; 0b
SINBAD_STATE_SPECIAL_STRIKE = CUSTOM_PLAYER_STATES_BEGIN + 5      ; 0c
SINBAD_STATE_SIDE_SPECIAL = CUSTOM_PLAYER_STATES_BEGIN + 6        ; 0d
SINBAD_STATE_HELPLESS = CUSTOM_PLAYER_STATES_BEGIN + 7            ; 0e
SINBAD_STATE_LANDING = CUSTOM_PLAYER_STATES_BEGIN + 8             ; 0f
SINBAD_STATE_CRASHING = CUSTOM_PLAYER_STATES_BEGIN + 9            ; 10
SINBAD_STATE_DOWN_TILT = CUSTOM_PLAYER_STATES_BEGIN + 10          ; 11
SINBAD_STATE_AERIAL_SIDE = CUSTOM_PLAYER_STATES_BEGIN + 11        ; 12
SINBAD_STATE_AERIAL_DOWN = CUSTOM_PLAYER_STATES_BEGIN + 12        ; 13
SINBAD_STATE_AERIAL_UP = CUSTOM_PLAYER_STATES_BEGIN + 13          ; 14
SINBAD_STATE_AERIAL_NEUTRAL = CUSTOM_PLAYER_STATES_BEGIN + 14     ; 15
SINBAD_STATE_AERIAL_SPE_NEUTRAL = CUSTOM_PLAYER_STATES_BEGIN + 15 ; 16
SINBAD_STATE_SPE_UP = CUSTOM_PLAYER_STATES_BEGIN + 16             ; 17
SINBAD_STATE_SPE_DOWN = CUSTOM_PLAYER_STATES_BEGIN + 17           ; 18
SINBAD_STATE_UP_TILT = CUSTOM_PLAYER_STATES_BEGIN + 18            ; 19
SINBAD_STATE_SHIELDING = CUSTOM_PLAYER_STATES_BEGIN + 19          ; 1a
SINBAD_STATE_SHIELDLAG = CUSTOM_PLAYER_STATES_BEGIN + 20          ; 1b
SINBAD_STATE_WALLJUMPING = CUSTOM_PLAYER_STATES_BEGIN + 21        ; 1c
SINBAD_STATE_JABBING_2 = CUSTOM_PLAYER_STATES_BEGIN + 22          ; 1d
SINBAD_STATE_JABBING_3 = CUSTOM_PLAYER_STATES_BEGIN + 23          ; 1e
SINBAD_STATE_RESPAWN_PLATFORM = CUSTOM_PLAYER_STATES_BEGIN + 24   ; 1f

;
; Gameplay constants
;

SINBAD_AERIAL_SPEED = $0100
SINBAD_AERIAL_DIRECTIONAL_INFLUENCE_STRENGTH = $80
SINBAD_AIR_FRICTION_STRENGTH = 7
SINBAD_FASTFALL_SPEED = $0500
SINBAD_GROUND_FRICTION_STRENGTH = $60
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

!include "characters/std_constant_tables.asm"

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
!input-table-define "SINBAD_AERIAL_INPUTS_TABLE" {
	CONTROLLER_INPUT_NONE               fast_fall
	CONTROLLER_INPUT_SPECIAL_RIGHT      sinbad_start_side_special
	CONTROLLER_INPUT_SPECIAL_LEFT       sinbad_start_side_special
	CONTROLLER_INPUT_JUMP               jump
	CONTROLLER_INPUT_JUMP_RIGHT         jump
	CONTROLLER_INPUT_JUMP_LEFT          jump
	CONTROLLER_INPUT_ATTACK_LEFT        sinbad_start_aerial_side
	CONTROLLER_INPUT_ATTACK_RIGHT       sinbad_start_aerial_side
	CONTROLLER_INPUT_DOWN_TILT          sinbad_start_aerial_down
	CONTROLLER_INPUT_ATTACK_UP          sinbad_start_aerial_up
	CONTROLLER_INPUT_JAB                sinbad_start_aerial_neutral
	CONTROLLER_INPUT_SPECIAL            sinbad_start_aerial_spe
	CONTROLLER_INPUT_SPECIAL_UP         sinbad_start_spe_up
	CONTROLLER_INPUT_SPECIAL_DOWN       sinbad_start_spe_down
	CONTROLLER_INPUT_ATTACK_UP_RIGHT    sinbad_start_aerial_up_right
	CONTROLLER_INPUT_ATTACK_UP_LEFT     sinbad_start_aerial_up_left
	CONTROLLER_INPUT_SPECIAL_UP_RIGHT   sinbad_start_spe_up_right
	CONTROLLER_INPUT_SPECIAL_UP_LEFT    sinbad_start_spe_up_left
	CONTROLLER_INPUT_ATTACK_DOWN_RIGHT  sinbad_start_aerial_down_right
	CONTROLLER_INPUT_ATTACK_DOWN_LEFT   sinbad_start_aerial_down_left
	CONTROLLER_INPUT_SPECIAL_DOWN_RIGHT sinbad_start_spe_down_right
	CONTROLLER_INPUT_SPECIAL_DOWN_LEFT  sinbad_start_spe_down_left

	no_input
}

; Input table for idle state, special values are
;  no_input - Default
!input-table-define "SINBAD_IDLE_INPUTS_TABLE" {
	CONTROLLER_INPUT_LEFT               sinbad_start_running_left
	CONTROLLER_INPUT_RIGHT              sinbad_start_running_right
	CONTROLLER_INPUT_JUMP               sinbad_start_jumping
	CONTROLLER_INPUT_JUMP_RIGHT         sinbad_start_jumping_right
	CONTROLLER_INPUT_JUMP_LEFT          sinbad_start_jumping_left
	CONTROLLER_INPUT_JAB                sinbad_start_jabbing
	CONTROLLER_INPUT_ATTACK_LEFT        sinbad_start_side_tilt_left
	CONTROLLER_INPUT_ATTACK_RIGHT       sinbad_start_side_tilt_right
	CONTROLLER_INPUT_SPECIAL            sinbad_start_special
	CONTROLLER_INPUT_SPECIAL_RIGHT      sinbad_start_side_special_right
	CONTROLLER_INPUT_SPECIAL_LEFT       sinbad_start_side_special_left
	CONTROLLER_INPUT_DOWN_TILT          sinbad_start_down_tilt
	CONTROLLER_INPUT_SPECIAL_UP         sinbad_start_spe_up
	CONTROLLER_INPUT_SPECIAL_DOWN       sinbad_start_spe_down
	CONTROLLER_INPUT_ATTACK_UP          sinbad_start_up_tilt
	CONTROLLER_INPUT_TECH               sinbad_start_shielding
	CONTROLLER_INPUT_TECH_LEFT          sinbad_start_shielding_left
	CONTROLLER_INPUT_TECH_RIGHT         sinbad_start_shielding_right
	CONTROLLER_INPUT_SPECIAL_UP_LEFT    sinbad_start_spe_up_left
	CONTROLLER_INPUT_SPECIAL_UP_RIGHT   sinbad_start_spe_up_right
	CONTROLLER_INPUT_ATTACK_UP_LEFT     sinbad_start_up_tilt_left
	CONTROLLER_INPUT_ATTACK_UP_RIGHT    sinbad_start_up_tilt_right
	CONTROLLER_INPUT_SPECIAL_DOWN_LEFT  sinbad_start_spe_down_left
	CONTROLLER_INPUT_SPECIAL_DOWN_RIGHT sinbad_start_spe_down_right
	CONTROLLER_INPUT_ATTACK_DOWN_LEFT   sinbad_start_down_tilt_left
	CONTROLLER_INPUT_ATTACK_DOWN_RIGHT  sinbad_start_down_tilt_right

	no_input
}

; Input table for running state, special values are
;  input_running_left - Change running direction to the left (if not already running to the left)
;  input_runnning_right - Change running direction to the right (if not already running to the right)
!input-table-define "SINBAD_RUNNING_INPUTS_TABLE" {
	CONTROLLER_INPUT_LEFT               input_running_left
	CONTROLLER_INPUT_RIGHT              input_running_right
	CONTROLLER_INPUT_JUMP               sinbad_start_jumping
	CONTROLLER_INPUT_JUMP_LEFT          sinbad_start_jumping_left
	CONTROLLER_INPUT_JUMP_RIGHT         sinbad_start_jumping_right
	CONTROLLER_INPUT_ATTACK_LEFT        sinbad_start_side_tilt_left
	CONTROLLER_INPUT_ATTACK_RIGHT       sinbad_start_side_tilt_right
	CONTROLLER_INPUT_SPECIAL            sinbad_start_special
	CONTROLLER_INPUT_SPECIAL_RIGHT      sinbad_start_side_special_right
	CONTROLLER_INPUT_SPECIAL_LEFT       sinbad_start_side_special_left
	CONTROLLER_INPUT_SPECIAL_UP         sinbad_start_spe_up
	CONTROLLER_INPUT_SPECIAL_DOWN       sinbad_start_spe_down
	CONTROLLER_INPUT_TECH_LEFT          sinbad_start_shielding_left
	CONTROLLER_INPUT_TECH_RIGHT         sinbad_start_shielding_right
	CONTROLLER_INPUT_SPECIAL_UP_LEFT    sinbad_start_spe_up_left
	CONTROLLER_INPUT_SPECIAL_UP_RIGHT   sinbad_start_spe_up_right
	CONTROLLER_INPUT_ATTACK_UP_LEFT     sinbad_start_up_tilt_left
	CONTROLLER_INPUT_ATTACK_UP_RIGHT    sinbad_start_up_tilt_right
	CONTROLLER_INPUT_SPECIAL_DOWN_LEFT  sinbad_start_spe_down_left
	CONTROLLER_INPUT_SPECIAL_DOWN_RIGHT sinbad_start_spe_down_right
	CONTROLLER_INPUT_ATTACK_DOWN_LEFT   sinbad_start_down_tilt_left
	CONTROLLER_INPUT_ATTACK_DOWN_RIGHT  sinbad_start_down_tilt_right
	CONTROLLER_INPUT_DOWN_TILT          sinbad_start_down_tilt

	sinbad_start_idle
}

; Input table for jumping state state (only used during jumpsquat), special values are
;  no_input - default
!input-table-define "SINBAD_JUMPSQUAT_INPUTS_TABLE" {
	CONTROLLER_INPUT_ATTACK_UP        sinbad_start_up_tilt
	CONTROLLER_INPUT_SPECIAL_UP       sinbad_start_spe_up
	CONTROLLER_INPUT_ATTACK_UP_LEFT   sinbad_start_up_tilt_left
	CONTROLLER_INPUT_SPECIAL_UP_LEFT  sinbad_start_spe_up_left
	CONTROLLER_INPUT_ATTACK_UP_RIGHT  sinbad_start_up_tilt_right
	CONTROLLER_INPUT_SPECIAL_UP_RIGHT sinbad_start_spe_up_right

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
					jmp dumb_keep_input_dirty ; dumb as we already checked the "smart" condition for our own logic

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
					jmp dumb_keep_input_dirty ; dumb as we already checked the "smart" condition for our own logic

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
!include "characters/tpl_grounded_attack.asm"

;
; Aerial side
;

!define "anim" {sinbad_anim_aerial_side}
!define "state" {SINBAD_STATE_AERIAL_SIDE}
!define "routine" {aerial_side}
!include "characters/tpl_aerial_attack.asm"

;
; Aerial down
;

!define "anim" {sinbad_anim_aerial_down}
!define "state" {SINBAD_STATE_AERIAL_DOWN}
!define "routine" {aerial_down}
!include "characters/tpl_aerial_attack.asm"

;
; Aerial up
;

!define "anim" {sinbad_anim_aerial_up}
!define "state" {SINBAD_STATE_AERIAL_UP}
!define "routine" {aerial_up}
!include "characters/tpl_aerial_attack.asm"

;
; Aerial neutral
;

!define "anim" {sinbad_anim_aerial_neutral}
!define "state" {SINBAD_STATE_AERIAL_NEUTRAL}
!define "routine" {aerial_neutral}
!include "characters/tpl_aerial_attack.asm"

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

	&{char_name}_start_spe_up_left:
	.(
		lda #DIRECTION_LEFT2
		jmp {char_name}_start_spe_up_directional
	.)
	&{char_name}_start_spe_up_right:
	.(
		lda #DIRECTION_RIGHT2
		; Fallthrough to {char_name}_start_spe_up_directional
	.)
	{char_name}_start_spe_up_directional:
	.(
		sta player_a_direction, x
		; Fallthrough to {char_name}_start_spe_up
	.)
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

!define "anim" {sinbad_anim_spe_down}
!define "state" {SINBAD_STATE_SPE_DOWN}
!define "routine" {spe_down}
!include "characters/tpl_aerial_attack_uncancellable.asm"

!define "anim" {sinbad_anim_up_tilt}
!define "state" {SINBAD_STATE_UP_TILT}
!define "routine" {up_tilt}
!include "characters/tpl_grounded_attack.asm"

!include "characters/std_friction_routines.asm"

; Standard move names
;{char_name}_start_down_tilt = {char_name}_start_down_tilt
;{char_name}_start_spe_down = {char_name}_start_spe_down

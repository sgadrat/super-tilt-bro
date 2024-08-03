!define "char_name" {sunny}
!define "char_name_upper" {SUNNY}

;
; Gameplay constants
;

SUNNY_AERIAL_SPEED = $0100
SUNNY_AERIAL_DIRECTIONAL_INFLUENCE_STRENGTH = $80
SUNNY_AIR_FRICTION_STRENGTH = 7
SUNNY_FASTFALL_SPEED = $0500
SUNNY_GROUND_FRICTION_STRENGTH = $60
SUNNY_JUMP_POWER = $0480
SUNNY_JUMP_SHORT_HOP_POWER = $0102
SUNNY_JUMP_SHORT_HOP_EXTRA_TIME_PAL = 4 ; Number of frames after jumpsquat at which shorthop is handled
SUNNY_JUMP_SHORT_HOP_EXTRA_TIME_NTSC = 5
SUNNY_JUMP_SHORT_HOP_AERIAL_TIME_PAL = 2 ;  Number of frames after jumpsquat at which an attack input stops converting is into a short hop-aerial
SUNNY_JUMP_SHORT_HOP_AERIAL_TIME_NTSC = 2
SUNNY_JUMP_SQUAT_DURATION_PAL = 4
SUNNY_JUMP_SQUAT_DURATION_NTSC = 5
SUNNY_LANDING_MAX_VELOCITY = $0200
SUNNY_MAX_NUM_AERIAL_JUMPS = 1
SUNNY_ALL_SPECIAL_JUMPS = %10000001
SUNNY_RUNNING_INITIAL_VELOCITY = $0100
SUNNY_RUNNING_MAX_VELOCITY = $0200
SUNNY_RUNNING_ACCELERATION = $40
SUNNY_TECH_SPEED = $0400
SUNNY_WALL_JUMP_SQUAT_END = 4
SUNNY_WALL_JUMP_VELOCITY_V = $0480
SUNNY_WALL_JUMP_VELOCITY_H = $0100

;
; Constants data
;

!include "characters/std_constant_tables.asm"

;
; Implementation
;

sunny_init:
sunny_global_onground:
.(
	; Initialize special jump flags
	lda #SUNNY_ALL_SPECIAL_JUMPS
	sta player_a_special_jumps, x
	rts
.)

; Input table for aerial moves, special values are
;  fast_fall - mandatorily on INPUT_NONE to take effect on release of DOWN
;  jump      - automatically choose between aerial jump or wall jump
;  no_input  - expected default
!input-table-define "SUNNY_AERIAL_INPUTS_TABLE" {
	CONTROLLER_INPUT_NONE               fast_fall
	CONTROLLER_INPUT_SPECIAL_RIGHT      sunny_start_side_special
	CONTROLLER_INPUT_SPECIAL_LEFT       sunny_start_side_special
	CONTROLLER_INPUT_JUMP               jump
	CONTROLLER_INPUT_JUMP_RIGHT         jump
	CONTROLLER_INPUT_JUMP_LEFT          jump
	CONTROLLER_INPUT_ATTACK_LEFT        sunny_start_aerial_side
	CONTROLLER_INPUT_ATTACK_RIGHT       sunny_start_aerial_side
	CONTROLLER_INPUT_DOWN_TILT          sunny_start_aerial_down
	CONTROLLER_INPUT_ATTACK_UP          sunny_start_aerial_up
	CONTROLLER_INPUT_JAB                sunny_start_aerial_neutral
	CONTROLLER_INPUT_SPECIAL            sunny_start_aerial_spe
	CONTROLLER_INPUT_SPECIAL_UP         sunny_start_spe_up
	CONTROLLER_INPUT_SPECIAL_DOWN       sunny_start_spe_down
	CONTROLLER_INPUT_ATTACK_UP_RIGHT    sunny_start_aerial_up_right
	CONTROLLER_INPUT_ATTACK_UP_LEFT     sunny_start_aerial_up_left
	CONTROLLER_INPUT_SPECIAL_UP_RIGHT   sunny_start_spe_up_right
	CONTROLLER_INPUT_SPECIAL_UP_LEFT    sunny_start_spe_up_left
	CONTROLLER_INPUT_ATTACK_DOWN_RIGHT  sunny_start_aerial_down_right
	CONTROLLER_INPUT_ATTACK_DOWN_LEFT   sunny_start_aerial_down_left
	CONTROLLER_INPUT_SPECIAL_DOWN_RIGHT sunny_start_spe_down_right
	CONTROLLER_INPUT_SPECIAL_DOWN_LEFT  sunny_start_spe_down_left

	no_input
}

; Input table for idle state, special values are
;  no_input - Default
!input-table-define "SUNNY_IDLE_INPUTS_TABLE" {
	CONTROLLER_INPUT_LEFT               sunny_start_running_left
	CONTROLLER_INPUT_RIGHT              sunny_start_running_right
	CONTROLLER_INPUT_JUMP               sunny_start_jumping
	CONTROLLER_INPUT_JUMP_RIGHT         sunny_start_jumping_right
	CONTROLLER_INPUT_JUMP_LEFT          sunny_start_jumping_left
	CONTROLLER_INPUT_JAB                sunny_start_jabbing
	CONTROLLER_INPUT_ATTACK_LEFT        sunny_start_side_tilt_left
	CONTROLLER_INPUT_ATTACK_RIGHT       sunny_start_side_tilt_right
	CONTROLLER_INPUT_SPECIAL            sunny_start_special
	CONTROLLER_INPUT_SPECIAL_RIGHT      sunny_start_side_special_right
	CONTROLLER_INPUT_SPECIAL_LEFT       sunny_start_side_special_left
	CONTROLLER_INPUT_DOWN_TILT          sunny_start_down_tilt
	CONTROLLER_INPUT_SPECIAL_UP         sunny_start_spe_up
	CONTROLLER_INPUT_SPECIAL_DOWN       sunny_start_spe_down
	CONTROLLER_INPUT_ATTACK_UP          sunny_start_up_tilt
	CONTROLLER_INPUT_TECH               sunny_start_shielding
	CONTROLLER_INPUT_TECH_LEFT          sunny_start_shielding_left
	CONTROLLER_INPUT_TECH_RIGHT         sunny_start_shielding_right
	CONTROLLER_INPUT_SPECIAL_UP_LEFT    sunny_start_spe_up_left
	CONTROLLER_INPUT_SPECIAL_UP_RIGHT   sunny_start_spe_up_right
	CONTROLLER_INPUT_ATTACK_UP_LEFT     sunny_start_up_tilt_left
	CONTROLLER_INPUT_ATTACK_UP_RIGHT    sunny_start_up_tilt_right
	CONTROLLER_INPUT_SPECIAL_DOWN_LEFT  sunny_start_spe_down_left
	CONTROLLER_INPUT_SPECIAL_DOWN_RIGHT sunny_start_spe_down_right
	CONTROLLER_INPUT_ATTACK_DOWN_LEFT   sunny_start_down_tilt_left
	CONTROLLER_INPUT_ATTACK_DOWN_RIGHT  sunny_start_down_tilt_right

	no_input
}

; Input table for running state, special values are
;  input_running_left - Change running direction to the left (if not already running to the left)
;  input_runnning_right - Change running direction to the right (if not already running to the right)
!input-table-define "SUNNY_RUNNING_INPUTS_TABLE" {
	CONTROLLER_INPUT_LEFT               input_running_left
	CONTROLLER_INPUT_RIGHT              input_running_right
	CONTROLLER_INPUT_JUMP               sunny_start_jumping
	CONTROLLER_INPUT_JUMP_LEFT          sunny_start_jumping_left
	CONTROLLER_INPUT_JUMP_RIGHT         sunny_start_jumping_right
	CONTROLLER_INPUT_ATTACK_LEFT        sunny_start_side_tilt_left
	CONTROLLER_INPUT_ATTACK_RIGHT       sunny_start_side_tilt_right
	CONTROLLER_INPUT_SPECIAL            sunny_start_special
	CONTROLLER_INPUT_SPECIAL_RIGHT      sunny_start_side_special_right
	CONTROLLER_INPUT_SPECIAL_LEFT       sunny_start_side_special_left
	CONTROLLER_INPUT_SPECIAL_UP         sunny_start_spe_up
	CONTROLLER_INPUT_SPECIAL_DOWN       sunny_start_spe_down
	CONTROLLER_INPUT_TECH_LEFT          sunny_start_shielding_left
	CONTROLLER_INPUT_TECH_RIGHT         sunny_start_shielding_right
	CONTROLLER_INPUT_SPECIAL_UP_LEFT    sunny_start_spe_up_left
	CONTROLLER_INPUT_SPECIAL_UP_RIGHT   sunny_start_spe_up_right
	CONTROLLER_INPUT_ATTACK_UP_LEFT     sunny_start_up_tilt_left
	CONTROLLER_INPUT_ATTACK_UP_RIGHT    sunny_start_up_tilt_right
	CONTROLLER_INPUT_SPECIAL_DOWN_LEFT  sunny_start_spe_down_left
	CONTROLLER_INPUT_SPECIAL_DOWN_RIGHT sunny_start_spe_down_right
	CONTROLLER_INPUT_ATTACK_DOWN_LEFT   sunny_start_down_tilt_left
	CONTROLLER_INPUT_ATTACK_DOWN_RIGHT  sunny_start_down_tilt_right
	CONTROLLER_INPUT_DOWN_TILT          sunny_start_down_tilt

	sunny_start_idle
}

; Input table for jumping state state (only used during jumpsquat), special values are
;  no_input - default
!input-table-define "SUNNY_JUMPSQUAT_INPUTS_TABLE" {
	CONTROLLER_INPUT_ATTACK_UP        sunny_start_up_tilt
	CONTROLLER_INPUT_SPECIAL_UP       sunny_start_spe_up
	CONTROLLER_INPUT_ATTACK_UP_LEFT   sunny_start_up_tilt_left
	CONTROLLER_INPUT_SPECIAL_UP_LEFT  sunny_start_spe_up_left
	CONTROLLER_INPUT_ATTACK_UP_RIGHT  sunny_start_up_tilt_right
	CONTROLLER_INPUT_SPECIAL_UP_RIGHT sunny_start_spe_up_right

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
		.byt sunny_anim_jab1_dur_pal, sunny_anim_jab1_dur_ntsc
	anim_duration_table(sunny_anim_jab1_dur_pal-10, jab1_cuttable_duration)

	jab2_duration:
		.byt sunny_anim_jab2_dur_pal, sunny_anim_jab2_dur_ntsc
	anim_duration_table(sunny_anim_jab2_dur_pal-10, jab2_cuttable_duration)

	jab3_duration:
		.byt sunny_anim_jab3_dur_pal, sunny_anim_jab3_dur_ntsc
	anim_duration_table(sunny_anim_jab3_dur_pal-9, jab3_sfx_time)

	&sunny_start_jabbing:
	.(
		lda #SUNNY_STATE_JABBING_1
		sta player_a_state, x
		ldy system_index
		lda jab1_duration, y
		sta player_a_state_clock, x

		; Set the appropriate animation
		lda #<sunny_anim_jab1
		sta tmpfield13
		lda #>sunny_anim_jab1
		sta tmpfield14
		jsr set_player_animation

		; SFX
		jmp audio_play_strike_lite

		;rts ; useless, jump to subroutine
	.)

	&sunny_start_jabbing2:
	.(
		lda #SUNNY_STATE_JABBING_2
		sta player_a_state, x
		ldy system_index
		lda jab2_duration, y
		sta player_a_state_clock, x

		; Set the appropriate animation
		lda #<sunny_anim_jab2
		sta tmpfield13
		lda #>sunny_anim_jab2
		sta tmpfield14
		jsr set_player_animation

		; SFX
		jmp audio_play_strike_lite

		;rts ; useless, jump to subroutine
	.)

	&sunny_start_jabbing3:
	.(
		lda #SUNNY_STATE_JABBING_3
		sta player_a_state, x
		ldy system_index
		lda jab2_duration, y
		sta player_a_state_clock, x

		; Set the appropriate animation
		lda #<sunny_anim_jab3
		sta tmpfield13
		lda #>sunny_anim_jab3
		sta tmpfield14
		jmp set_player_animation

		;rts ; useless, jump to subroutine
	.)

	&sunny_tick_jab3:
	.(
		; Play SFX when landing
		ldy system_index
		lda player_a_state_clock, x
		cmp jab3_sfx_time, y
		bne ok

			;jsr sunny_audio_play_jab3_land ;FIXME sound effect does not exists (and this is a copy/paste of sinbad's code)

		ok:
		;Fallthrough
	.)
	&sunny_tick_jabbing:
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
			jmp sunny_start_inactive_state
			; No return, jump to subroutine

		end:
		rts
	.)

	&sunny_input_jabbing1:
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
					jmp sunny_start_jabbing2
					; No return, jump to subroutine

		end:
		rts
	.)

	&sunny_input_jabbing2:
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
					jmp sunny_start_jabbing3
					; No return, jump to subroutine

		end:
		rts
	.)
.)

;
; Side tilt
;

!define "anim" {sunny_anim_side_tilt}
!define "state" {SUNNY_STATE_SIDE_TILT}
!define "routine" {side_tilt}
!include "characters/tpl_grounded_attack.asm"

;
; Grounded neutral special
;

.(
	SUNNY_GROUNDED_SPECIAL_CHARGE_DURATION = 20
	duration_table(SUNNY_GROUNDED_SPECIAL_CHARGE_DURATION, duration_per_system)

	&sunny_start_special:
	.(
		; Set the appropriate animation
		lda #<sunny_anim_special_charge
		sta tmpfield13
		lda #>sunny_anim_special_charge
		sta tmpfield14
		jsr set_player_animation

		; Set the player's state
		lda #SUNNY_STATE_SPECIAL_CHARGE
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

	&sunny_tick_special_charge:
	.(
		dec player_a_state_clock, x
		bne do_tick
			jmp sunny_start_special_strike
			; No return, jump to a subroutine
		do_tick:

		jmp sunny_apply_ground_friction
		;rts ; useless, jump to subroutine
	.)
.)

.(
	duration_per_system:
		.byt 2*sunny_anim_special_dur_pal, 2*sunny_anim_special_dur_ntsc

	STRIKE_HEIGHT = $10

	&sunny_start_special_strike:
	.(

		; Set the appropriate animation
		lda #<sunny_anim_special
		sta tmpfield13
		lda #>sunny_anim_special
		sta tmpfield14
		jsr set_player_animation

		; Set the player's state
		lda #SUNNY_STATE_SPECIAL_STRIKE
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

	&sunny_tick_special_strike:
	.(
		dec player_a_state_clock, x
		bne do_tick
			jmp sunny_start_helpless
			; No return, jump to a subroutine
		do_tick:

		jmp sunny_apply_ground_friction
		;rts ; useless, jump to subroutine
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

	&sunny_start_side_special_left:
	.(
		lda DIRECTION_LEFT
		sta player_a_direction, x
		jmp sunny_start_side_special
		;rts ; useless, jump to subroutine
	.)

	&sunny_start_side_special_right:
	.(
		lda DIRECTION_RIGHT
		sta player_a_direction, x
		;jmp sunny_start_side_special ; useless, fallthrough
		; Falltrhough to sunny_start_side_special
	.)

	&sunny_start_side_special:
	.(
		; Set state
		lda #SUNNY_STATE_SIDE_SPECIAL
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
		lda #<sunny_anim_side_special_charge
		sta tmpfield13
		lda #>sunny_anim_side_special_charge
		sta tmpfield14
		jmp set_player_animation

		;rts ; useless, jump to subroutine
	.)

	&sunny_tick_side_special:
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
			lda #<sunny_anim_side_special_jump
			sta tmpfield13
			lda #>sunny_anim_side_special_jump
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
			jmp sunny_start_helpless
			; No return, jump to subroutine

		end:
		rts
	.)
.)

;
; Down tilt
;

!define "anim" {sunny_anim_down_tilt}
!define "state" {SUNNY_STATE_DOWN_TILT}
!define "routine" {down_tilt}
!include "characters/tpl_grounded_attack.asm"

;
; Aerial side
;

!define "anim" {sunny_anim_aerial_side}
!define "state" {SUNNY_STATE_AERIAL_SIDE}
!define "routine" {aerial_side}
!include "characters/tpl_aerial_attack.asm"

;
; Aerial down
;

!define "anim" {sunny_anim_aerial_down}
!define "state" {SUNNY_STATE_AERIAL_DOWN}
!define "routine" {aerial_down}
!include "characters/tpl_aerial_attack.asm"

;
; Aerial up
;

!define "anim" {sunny_anim_aerial_up}
!define "state" {SUNNY_STATE_AERIAL_UP}
!define "routine" {aerial_up}
!define "cutable_duration" {12}
!include "characters/tpl_aerial_attack_cutable.asm"

;
; Aerial neutral
;

!define "anim" {sunny_anim_aerial_neutral}
!define "state" {SUNNY_STATE_AERIAL_NEUTRAL}
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

	&sunny_start_aerial_spe:
	.(
		; Set state
		lda #SUNNY_STATE_AERIAL_SPE_NEUTRAL
		sta player_a_state, x

		; Set substate to "not cancelable"
		lda #0
		sta player_a_state_field1, x

		; Fallthrough to set the animation
	.)
	set_aerial_spe_animation:
	.(
		; Set the appropriate animation
		lda #<sunny_anim_aerial_spe
		sta tmpfield13
		lda #>sunny_anim_aerial_spe
		sta tmpfield14
		jsr set_player_animation

		rts
	.)

	&sunny_tick_aerial_spe:
	.(
		jsr sunny_aerial_directional_influence

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

	&sunny_input_aerial_spe:
	.(
		lda player_a_state_field1, x
		beq check_release

			check_cancel:
				; Press B again to cancel into helpless
				lda controller_a_btns, x
				and #CONTROLLER_BTN_B
				beq end

					jmp sunny_start_helpless
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
	&sunny_start_spe_up:
	.(
		; Set state
		lda #SUNNY_STATE_SPE_UP
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
		lda #<sunny_anim_spe_up_prepare
		sta tmpfield13
		lda #>sunny_anim_spe_up_prepare
		sta tmpfield14
		jsr set_player_animation

		rts
	.)

	&sunny_tick_spe_up:
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
			lda #<sunny_anim_spe_up_jump
			sta tmpfield13
			lda #>sunny_anim_spe_up_jump
			sta tmpfield14
			jsr set_player_animation

		moving:
			; Return to falling when the top is reached
			lda player_a_velocity_v, x
			beq top_reached
			bpl top_reached

				; The top is not reached, stay in special upward state but apply gravity and directional influence
				jsr sunny_aerial_directional_influence
				jsr apply_player_gravity
				jmp end

			top_reached:
				jsr sunny_start_helpless
				jmp end

		end:
		rts
	.)
.)

!define "anim" {sunny_anim_spe_down}
!define "state" {SUNNY_STATE_SPE_DOWN}
!define "routine" {spe_down}
!include "characters/tpl_aerial_attack_uncancellable.asm"

!define "anim" {sunny_anim_up_tilt}
!define "state" {SUNNY_STATE_UP_TILT}
!define "routine" {up_tilt}
!define "cutable_duration" {20}
!define "cut_input" {
	lda controller_a_btns, x
	cmp #CONTROLLER_INPUT_JUMP
	beq cut
	cmp #CONTROLLER_INPUT_JUMP_LEFT
	beq cut
	cmp #CONTROLLER_INPUT_JUMP_RIGHT
	beq cut
		rts
	cut:
		jmp sunny_start_jumping
}
!include "characters/tpl_grounded_attack_cutable.asm"

!include "characters/std_friction_routines.asm"

; Standard move names
;{char_name}_start_down_tilt = {char_name}_start_down_tilt
;{char_name}_start_spe_down = {char_name}_start_spe_down

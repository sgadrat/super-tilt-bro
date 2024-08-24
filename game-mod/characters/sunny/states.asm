!define "char_name" {sunny}
!define "char_name_upper" {SUNNY}

;
; Gameplay constants
;

SUNNY_AERIAL_SPEED = $0180
SUNNY_AERIAL_DIRECTIONAL_INFLUENCE_STRENGTH = $c0
SUNNY_AIR_FRICTION_STRENGTH = 7
SUNNY_FASTFALL_SPEED = $0500
SUNNY_GROUND_FRICTION_STRENGTH = $40
SUNNY_JUMP_POWER = $0480
SUNNY_JUMP_SHORT_HOP_POWER = $0100
SUNNY_JUMP_SHORT_HOP_EXTRA_TIME_PAL = 4 ; Number of frames after jumpsquat at which shorthop is handled
SUNNY_JUMP_SHORT_HOP_EXTRA_TIME_NTSC = 5
SUNNY_JUMP_SHORT_HOP_AERIAL_TIME_PAL = 2 ;  Number of frames after jumpsquat at which an attack input stops converting is into a short hop-aerial
SUNNY_JUMP_SHORT_HOP_AERIAL_TIME_NTSC = 2
SUNNY_JUMP_SQUAT_DURATION_PAL = 4
SUNNY_JUMP_SQUAT_DURATION_NTSC = 5
SUNNY_LANDING_MAX_VELOCITY = $01c0
SUNNY_MAX_NUM_AERIAL_JUMPS = 1
SUNNY_ALL_SPECIAL_JUMPS = %10000001
SUNNY_RUNNING_INITIAL_VELOCITY = $0100
SUNNY_RUNNING_MAX_VELOCITY = $01c0
SUNNY_RUNNING_ACCELERATION = $20
SUNNY_TECH_SPEED = $0300
SUNNY_WALL_JUMP_SQUAT_END = 4
SUNNY_WALL_JUMP_VELOCITY_V = $0500
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

!define "anim" {sunny_anim_jab1}
!define "state" {SUNNY_STATE_JABBING_1}
!define "routine" {jabbing}
!define "cutable_duration" {8}
!define "cut_input" {
	; Allow to cut the animation for another jab
	lda controller_a_btns, x
	cmp #CONTROLLER_INPUT_JAB
	beq cut
		rts
	cut:
		jmp sunny_start_jabbing2
		; No return, jump to subroutine
}
!include "characters/tpl_grounded_attack_cutable.asm"

!define "anim" {sunny_anim_jab2}
!define "state" {SUNNY_STATE_JABBING_2}
!define "routine" {jabbing2}
!define "cutable_duration" {8}
!define "cut_input" {
	; Allow to cut the animation for another jab
	lda controller_a_btns, x
	cmp #CONTROLLER_INPUT_JAB
	beq cut
		rts
	cut:
		jmp sunny_start_jabbing3
		; No return, jump to subroutine
}
!include "characters/tpl_grounded_attack_cutable.asm"

!define "anim" {sunny_anim_jab3}
!define "state" {SUNNY_STATE_JABBING_3}
!define "routine" {jabbing3}
!include "characters/tpl_grounded_attack.asm"

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
	INITIAL_VELOCITY = $0300
	velocity_table(INITIAL_VELOCITY, initial_velocity_right_msb, initial_velocity_right_lsb)
	velocity_table(-INITIAL_VELOCITY, initial_velocity_left_msb, initial_velocity_left_lsb)

	FRICTION = $08
	acceleration_table(FRICTION, friction_table)

	!define "anim" {sunny_anim_side_special_charge}
	!define "state" {SUNNY_STATE_SIDE_SPECIAL}
	!define "routine" {side_special}
	!define "followup" {sunny_start_side_special_end}
	!define "init" {
		; No vertical velocity
		lda #0
		sta player_a_velocity_v_low
		sta player_a_velocity_v

		; Fixed horizontal velocity
		ldy system_index
		lda player_a_direction, x
		bne right
			left:
				lda initial_velocity_left_msb, y
				sta player_a_velocity_h, x
				lda initial_velocity_left_lsb
				sta player_a_velocity_h_low
				rts
			right:
				lda initial_velocity_right_msb, y
				sta player_a_velocity_h, x
				lda initial_velocity_right_lsb
				sta player_a_velocity_h_low
				rts
		;rts ; useless, no branch return
	}
	!define "tick" {
		; No gravity, and specific air-friction for this move
		lda #0
		sta tmpfield1
		sta tmpfield2
		sta tmpfield3
		sta tmpfield4
		ldy system_index
		lda friction_table, y
		sta tmpfield5
		jmp merge_to_player_velocity
	}
	!include "characters/tpl_grounded_attack_followup.asm"

	!define "anim" {sunny_anim_side_special_end}
	!define "state" {SUNNY_STATE_SIDE_SPECIAL_END}
	!define "routine" {side_special_end}
	!include "characters/tpl_aerial_attack_uncancellable.asm"

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
; NOTE we are using two "spin" states while one state with
;      extended duration to 2*animation-duration would do the same.
;      A bit wasteful, but would need to allow custom duration in
;      tpl_aerial_attack to fix.
;

!define "anim" {sunny_anim_aerial_down}
!define "state" {SUNNY_STATE_AERIAL_DOWN}
!define "routine" {aerial_down}
!define "followup" {sunny_start_aerial_down_spin}
!define "init" {
	lda #0
	sta player_a_velocity_v_low, x
	sta player_a_velocity_v, x
	rts
}
!include "characters/tpl_aerial_attack.asm"

!define "anim" {sunny_anim_aerial_down_spin}
!define "state" {SUNNY_STATE_AERIAL_DOWN_SPIN}
!define "routine" {aerial_down_spin}
!define "followup" {sunny_start_aerial_down_spin2}
!include "characters/tpl_aerial_attack.asm"

!define "anim" {sunny_anim_aerial_down_spin}
!define "state" {SUNNY_STATE_AERIAL_DOWN_SPIN2}
!define "routine" {aerial_down_spin2}
!define "followup" {sunny_aerial_down_select_end}
!include "characters/tpl_aerial_attack.asm"

!define "anim" {sunny_anim_aerial_down_end}
!define "state" {SUNNY_STATE_AERIAL_DOWN_END}
!define "routine" {aerial_down_end}
!define "followup" {sunny_start_helpless}
!include "characters/tpl_aerial_attack.asm"

!define "anim" {sunny_anim_aerial_down_stomp}
!define "state" {SUNNY_STATE_AERIAL_DOWN_STOMP}
!define "routine" {aerial_down_stomp}
!include "characters/tpl_grounded_attack.asm"

.(
	VELOCITY_BOOST = $fd00
	velocity_table(VELOCITY_BOOST, velocity_boost_msb, velocity_boost_lsb)
#if 0
	; A bit more complexe implementation, not needed if the simple one proves sufficent
	; Simple - set velocity when tapping A
	; Complex - add velocity when tapping A, capping maximum result
	VELOCITY_CAP = $fc00
	velocity_table(VELOCITY_CAP, velocity_cap_msb, velocity_cap_lsb)
#else

	+sunny_input_aerial_down_spin:
	.(
#if 0
		lda controller_a_btns, x
		and #(CONTROLLER_BTN_DOWN | CONTROLLER_BTN_LEFT | CONTROLLER_BTN_RIGHT)^$ff
		cmp #CONTROLLER_INPUT_JAB
		bne end
			ldy system_index
			lda velocity_boost_lsb, y
			clc
			adc player_a_velocity_v_low, x
			sta player_a_velocity_v_low, x
			lda velocity_boost_msb, y
			adc player_a_velocity_v, x
			sta player_a_velocity_v, x

			SIGNED_CMP(player_a_velocity_v_low COMMA x, player_a_velocity_v COMMA x, velocity_cap_lsb COMMA y, velocity_cap_msb COMMA y)
			bpl end
				lda velocity_cap_lsb, y
				sta player_a_velocity_v_low, x
				lda velocity_boost_msb, y
				sta player_a_velocity_v, x
		end:
		rts
#else
		lda controller_a_btns, x
		and #(CONTROLLER_BTN_DOWN | CONTROLLER_BTN_LEFT | CONTROLLER_BTN_RIGHT)^$ff
		cmp #CONTROLLER_INPUT_JAB
		bne end
			ldy system_index
			lda velocity_boost_lsb, y
			sta player_a_velocity_v_low, x
			lda velocity_boost_msb, y
			sta player_a_velocity_v, x
		end:
		rts
#endif
	.)

	&sunny_aerial_down_select_end:
	.(
		lda player_a_grounded, x
		bne grounded_end
			aerial_end:
				jmp sunny_start_aerial_down_end
			grounded_end:
				jmp sunny_start_aerial_down_stomp
		;rts ; useless, jump to subroutine
	.)
.)

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

;
; Special up
;

.(
	;TODO moves here use tpl_aerial_attack, but may be better using tpl_aerial_attack_uncancellable
	;     Need to adapt uncancellable API to match features in tpl_aerial_attack if so.

	SPE_UP_POWER = $0500
	velocity_table(-SPE_UP_POWER, spe_up_power_msb, spe_up_power_lsb)

	!define "anim" {sunny_anim_spe_up_prepare}
	!define "state" {SUNNY_STATE_SPE_UP_PREPARE}
	!define "routine" {spe_up}
	!define "followup" {sunny_start_spe_up_jump}
	!define "init" {
		; Set initial velocity
		lda #$00
		sta player_a_velocity_h_low, x
		sta player_a_velocity_h, x
		sta player_a_velocity_v_low, x
		sta player_a_velocity_v, x

		; Reset fall speed
		jmp reset_default_gravity
		;rts ; useless, jump to subroutine
	}
	!include "characters/tpl_aerial_attack.asm"

	!define "anim" {sunny_anim_spe_up_jump}
	!define "state" {SUNNY_STATE_SPE_UP_JUMP}
	!define "routine" {spe_up_jump}
	!define "followup" {sunny_start_helpless}
	!define "init" {
		; Set jumping velocity
		ldy system_index
		lda spe_up_power_msb, y
		sta player_a_velocity_v, x
		lda spe_up_power_lsb, y
		sta player_a_velocity_v_low, x

		rts
	}
	!include "characters/tpl_aerial_attack.asm"
.)

;
; Special down
;

!define "anim" {sunny_anim_spe_down}
!define "state" {SUNNY_STATE_SPE_DOWN}
!define "routine" {spe_down}
!include "characters/tpl_aerial_attack_uncancellable.asm"

;
; Up tilt
;

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

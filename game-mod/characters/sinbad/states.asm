!define "char_name" {sinbad}
!define "char_name_upper" {SINBAD}

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
SINBAD_JUMP_SHORT_HOP_AERIAL_TIME_PAL = 2 ;  Number of frames after jumpsquat at which an attack input stops converting is into a short hop-aerial
SINBAD_JUMP_SHORT_HOP_AERIAL_TIME_NTSC = 2
SINBAD_JUMP_SQUAT_DURATION_PAL = 4
SINBAD_JUMP_SQUAT_DURATION_NTSC = 5
SINBAD_LANDING_MAX_VELOCITY = $0200
SINBAD_MAX_NUM_AERIAL_JUMPS = 1
SINBAD_ALL_SPECIAL_JUMPS = %10000001
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
	; Initialize special jump flags
	lda #SINBAD_ALL_SPECIAL_JUMPS
	sta player_a_special_jumps, x
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
	CONTROLLER_INPUT_ATTACK_LEFT        sinbad_start_side_tilt_windup_left
	CONTROLLER_INPUT_ATTACK_RIGHT       sinbad_start_side_tilt_windup_right
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
	CONTROLLER_INPUT_ATTACK_LEFT        sinbad_start_side_tilt_windup_left
	CONTROLLER_INPUT_ATTACK_RIGHT       sinbad_start_side_tilt_windup_right
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

sinbad_unfallable_platform = player_a_state_field1
sinbad_side_tilt_hitbox_state = player_a_state_field2

!define "anim" {sinbad_anim_side_tilt_windup}
!define "state" {SINBAD_STATE_SIDE_TILT_WINDUP}
!define "routine" {side_tilt_windup}
!define "followup" {sinbad_start_side_tilt_hit}
!square-define "init" [
	; Set initial velocity
	ldy system_index
	lda player_a_direction, x
	cmp #DIRECTION_LEFT2
	bne direction_right
		direction_left:
			lda {char_name}_run_init_neg_velocity_lsb, y
			sta player_a_velocity_h_low, x
			lda {char_name}_run_init_neg_velocity_msb, y
			jmp set_high_byte
		direction_right:
			lda {char_name}_run_init_velocity_lsb, y
			sta player_a_velocity_h_low, x
			lda {char_name}_run_init_velocity_msb, y
	set_high_byte:
	sta player_a_velocity_h, x

	; Get platform from which we cannot fall
	lda player_a_grounded, x
	sta sinbad_unfallable_platform, x

	; Set hitbox in normal state
	lda #0
	sta sinbad_side_tilt_hitbox_state, x

	rts
]
!square-define "tick" [
	jmp {char_name}_side_tilt_speed_update
	;rts ; useless, jump to subroutine
]
!include "characters/tpl_grounded_attack_followup.asm"

!define "anim" {sinbad_anim_side_tilt_hit}
!define "state" {SINBAD_STATE_SIDE_TILT_HIT}
!define "routine" {side_tilt_hit}
!define "followup" {sinbad_side_tilt_hit_end}
!define "duration" {12, 14}
!square-define "tick" [
	jmp {char_name}_side_tilt_speed_update
	;rts ; useless, jump to subroutine
]
!include "characters/tpl_grounded_attack_followup.asm"

!define "anim" {sinbad_anim_side_tilt_recovery}
!define "state" {SINBAD_STATE_SIDE_TILT_RECOVERY}
!define "routine" {side_tilt_recovery}
!include "characters/tpl_grounded_attack_followup.asm"

SINBAD_DASH_MAX_VELOCITY = (SINBAD_RUNNING_MAX_VELOCITY*4)/3
velocity_table({char_name_upper}_DASH_MAX_VELOCITY, {char_name}_dash_max_velocity_msb, {char_name}_dash_max_velocity_lsb)
velocity_table(-{char_name_upper}_DASH_MAX_VELOCITY, {char_name}_dash_max_neg_velocity_msb, {char_name}_dash_max_neg_velocity_lsb)

; Displacement between ledge and actual position sinbad stops at, in pixels
;  Minimum is 1 for staying on collision box.
;  Set to greater value to avoid appearing glitchy, only one pixel on platform feels unatural
SINBAD_LEDGE_REPLACE_OFFSET = 6

sinbad_side_tilt_speed_update:
.(
	; Do not change velocity from zero, it is certainly due to offground routine
	lda player_a_velocity_h_low, x
	bne proceed
	lda player_a_velocity_h, x
	bne proceed
		rts
	proceed:

	; Update player's velocity depending on their direction
	ldy system_index
	lda player_a_direction, x
	beq run_left

		; Running right, velocity tends toward vector max velocity
		lda {char_name}_dash_max_velocity_msb, y
		sta tmpfield4
		lda {char_name}_dash_max_velocity_lsb, y
		jmp update_velocity ; Optimizable - inline "update_velocity" section in both "run_left" and "run_right" branches

	run_left:
		; Running left, velocity tends toward vector "-1 * max volcity"
		lda {char_name}_dash_max_neg_velocity_msb, y
		sta tmpfield4
		lda {char_name}_dash_max_neg_velocity_lsb, y

	update_velocity:
		sta tmpfield2
		lda #0
		sta tmpfield3
		sta tmpfield1
		lda {char_name}_run_acceleration, y
		sta tmpfield5
		jmp merge_to_player_velocity
		; No return, jump to subroutine

	;rts; useless, no branch return
.)

sinbad_offground_side_tilt:
.(
	sinbad_unfallable_ledge_x_lsb = tmpfield1
	sinbad_unfallable_ledge_x_msb = tmpfield2
	sinbad_unfallable_ledge_y_lsb = tmpfield3
	sinbad_unfallable_ledge_y_msb = tmpfield4
	ledge_distance_lsb = tmpfield5
	ledge_distance_msb = tmpfield6

	; Get ledge position
	.(
		jsr sinbad_side_tilt_unfallable_ledge
	.)

	; Check if character felt from this ledge
	.(
		; Invalid platform
		.(
			lda sinbad_unfallable_ledge_x_msb
			cmp #$80
			beq unatural_cause_of_going_offground
		.)

		; Character no more at platform's height
		.(
			lda player_a_y, x
			cmp sinbad_unfallable_ledge_y_lsb
			bne unatural_cause_of_going_offground
			lda player_a_y_screen, x
			cmp sinbad_unfallable_ledge_y_msb
			bne unatural_cause_of_going_offground
		.)

		; Character too far from ledge
		.(
			; ledge_distance = sinbad_unfallable_ledge_x - player_x
			lda sinbad_unfallable_ledge_x_lsb
			sec
			sbc player_a_x, x
			sta ledge_distance_lsb
			lda sinbad_unfallable_ledge_x_msb
			sbc player_a_x_screen, x
			sta ledge_distance_msb

			; ledge_distance = abs(ledge_distance)
			bpl distance_ok
				eor #%11111111
				sta ledge_distance_msb
				lda ledge_distance_lsb
				eor #%11111111
				sta ledge_distance_lsb
				inc ledge_distance_lsb
				bne distance_ok
					inc ledge_distance_msb
			distance_ok:

			; unatural if ledge_distance >= 8 pixels
			lda ledge_distance_msb
			bne unatural_cause_of_going_offground
			lda ledge_distance_lsb
			cmp #8+SINBAD_LEDGE_REPLACE_OFFSET
			bcs unatural_cause_of_going_offground
		.)

		felt_from_ledge:
			; Cancel momentum
			lda #0
			sta player_a_velocity_h_low, x
			sta player_a_velocity_h, x

			; Place character on the ledge
			lda #0
			sta player_a_x_low, x
			lda sinbad_unfallable_ledge_x_lsb
			sta player_a_x, x
			lda sinbad_unfallable_ledge_x_msb
			sta player_a_x_screen, x
			lda sinbad_unfallable_platform, x
			sta player_a_grounded, x

			rts

		unatural_cause_of_going_offground:
			jmp sinbad_start_falling
	.)

	;rts ; useless, no branch return
.)

; Get coordinates of the ledge that can't be passed in side-tilt state
;
; Output
;  tmpfield1 - X position of the ledge LSB
;  tmpfield2 - X position of the ledge MSB
;  tmpfield3 - Y position of the ledge LSB
;  tmpfield4 - Y position of the ledge MSB
;
;  If the platform no more exists, tmpfield2 is set to $80. Other values are meaningless.
sinbad_side_tilt_unfallable_ledge:
.(
	sinbad_unfallable_ledge_x_lsb = tmpfield1
	sinbad_unfallable_ledge_x_msb = tmpfield2
	sinbad_unfallable_ledge_y_lsb = tmpfield3
	sinbad_unfallable_ledge_y_msb = tmpfield4

	; Select between left or right ledge to be impassable
	.(
		lda player_a_direction, x
		cmp #DIRECTION_LEFT2
		bne direction_right
			direction_left:
				lda #<platform_handlers_left
				sta tmpfield1
				lda #>platform_handlers_left
				sta tmpfield2
				jmp ok
			direction_right:
				lda #<platform_handlers_right
				sta tmpfield1
				lda #>platform_handlers_right
				sta tmpfield2
		ok:
	.)

	; Get ledge coordinates
	.(
		lda sinbad_unfallable_platform, x
		beq not_grounded
			pha
			tay

			lda #platform_handlers_size
			sta tmpfield3
			lda stage_data, y
			jmp switch_linear
	.)

	on_unknown_platform:
		; Unknown platform could happen if stage layout changed, and platform type is now STAGE_ELEMENT_END.
		; Other values should not happen.
		;  - Clear the stack from pushed platform offset, and report invalid coordinates
		pla
		; Fallthrough to not_grounded
	not_grounded:
		; There is no reason too have no unfallable platform, so code does not support it, return invalid coordinates
		lda #$80
		sta sinbad_unfallable_ledge_x_msb
		rts

	on_platform_facing_left:
		pla:tay

		lda stage_data+1, y
		clc
		adc #<SINBAD_LEDGE_REPLACE_OFFSET
		sta sinbad_unfallable_ledge_x_lsb
		lda #0
		sta sinbad_unfallable_ledge_y_msb ; beware, setting y_msb here because A is zero
		adc #>SINBAD_LEDGE_REPLACE_OFFSET
		sta sinbad_unfallable_ledge_x_msb

		lda stage_data+3, y
		sta sinbad_unfallable_ledge_y_lsb

		rts

	on_oos_platform_facing_left:
		pla:tay

		lda stage_data+1, y
		clc
		adc #<SINBAD_LEDGE_REPLACE_OFFSET
		sta sinbad_unfallable_ledge_x_lsb
		lda stage_data+2, y
		adc #>SINBAD_LEDGE_REPLACE_OFFSET
		sta sinbad_unfallable_ledge_x_msb

		lda stage_data+5, y
		sta sinbad_unfallable_ledge_y_lsb
		lda stage_data+6, y
		sta sinbad_unfallable_ledge_y_msb

		rts

	on_platform_facing_right:
		pla:tay

		lda stage_data+2, y
		sec
		sbc #<SINBAD_LEDGE_REPLACE_OFFSET
		sta sinbad_unfallable_ledge_x_lsb
		lda #0
		sta sinbad_unfallable_ledge_y_msb ; beware, setting y_msb here because A is zero
		sbc #>SINBAD_LEDGE_REPLACE_OFFSET
		sta sinbad_unfallable_ledge_x_msb

		lda stage_data+3, y
		sta sinbad_unfallable_ledge_y_lsb

		rts

	on_oos_platform_facing_right:
		pla:tay

		lda stage_data+3, y
		sec
		sbc #<SINBAD_LEDGE_REPLACE_OFFSET
		sta sinbad_unfallable_ledge_x_lsb
		lda stage_data+4, y
		sbc #>SINBAD_LEDGE_REPLACE_OFFSET
		sta sinbad_unfallable_ledge_x_msb

		lda stage_data+5, y
		sta sinbad_unfallable_ledge_y_lsb
		lda stage_data+6, y
		sta sinbad_unfallable_ledge_y_msb

		rts

	platform_handlers_left:
		.byt STAGE_ELEMENT_PLATFORM,   STAGE_ELEMENT_SMOOTH_PLATFORM, STAGE_ELEMENT_OOS_PLATFORM,   STAGE_ELEMENT_OOS_SMOOTH_PLATFORM
		.byt <on_platform_facing_left, <on_platform_facing_left,      <on_oos_platform_facing_left, <on_oos_platform_facing_left
		.byt >on_platform_facing_left, >on_platform_facing_left,      >on_oos_platform_facing_left, >on_oos_platform_facing_left
		.word on_unknown_platform
	platform_handlers_size = (*-platform_handlers_left-1)/3

	platform_handlers_right:
		.byt STAGE_ELEMENT_PLATFORM,    STAGE_ELEMENT_SMOOTH_PLATFORM, STAGE_ELEMENT_OOS_PLATFORM,    STAGE_ELEMENT_OOS_SMOOTH_PLATFORM
		.byt <on_platform_facing_right, <on_platform_facing_right,     <on_oos_platform_facing_right, <on_oos_platform_facing_right
		.byt >on_platform_facing_right, >on_platform_facing_right,     >on_oos_platform_facing_right, >on_oos_platform_facing_right
		.word on_unknown_platform
#if (*-platform_handlers_right-1)/3 <> platform_handlers_size
#error non-matching platform handlers size
#endif
.)

anim_duration_table(sinbad_anim_side_tilt_recovery_dur_pal-4, sinbad_side_tilt_recovery_cuttable_time)

sinbad_input_side_tilt_recovery:
.(
	; After cuttable time, the player can cut the recovry by jump moves (or up-tilt, up-special)
	lda player_a_state_clock, x
	ldy system_index
	cmp sinbad_side_tilt_recovery_cuttable_time, y
	bcs ignore
		lda controller_a_btns, x
		and #CONTROLLER_INPUT_JUMP
		beq ignore
			jmp sinbad_input_idle
	ignore:
		jmp smart_keep_input_dirty
	;rts ; useless, no branch return
.)

sinbad_side_tilt_hit_end:
.(
	lda player_a_grounded, x
	bne grounded

		midair:
			jmp sinbad_start_falling

		grounded:
			jmp sinbad_start_side_tilt_recovery

	;rts ; useless, no branch return
.)

sinbad_side_tilt_on_hit:
.(
	HITBOX_OK = 0
	HITBOX_WHIFFED = 1

	; Disable Hitbox
	lda #HITBOX_DISABLED
	sta player_a_hitbox_enabled, x

	; Apply parry when not hitting opponent's hurtbox
	.(
		cpy #HURTBOX
		beq process

			; Apply parry to both players if opponent has a direct hitbox
			SWITCH_SELECTED_PLAYER
			lda player_a_hitbox_enabled, x
			cmp #HITBOX_DIRECT
			bne ok
				TRAMPOLINE(parry_players, #0, #CURRENT_BANK_NUMBER)
			ok:

			; Do not actually process hit
			rts

		process:
	.)

	; Weak hit if a previous hitbox did not throw
	.(
		lda sinbad_side_tilt_hitbox_state, x
		beq ok
			;NOTE simply do nothing on weak it, could be nice to add some feedback (sound + screen-freeze?)
			rts
		ok:
	.)

	; Hurt opponent normally
	.(
		DAMAGES = 1
		BASE_H = -800
		FORCE_H = 0
		BASE_V = -400
		FORCE_V = 0
		HITSTUN_MODIFIER = 0

		; Hurt opponent
		.(
			; Rewrite hitbox knockback info to match sage's punch values
			lda #DAMAGES
			sta player_a_hitbox_damages, x
			lda #<BASE_V
			sta player_a_hitbox_base_knock_up_v_low, x
			lda #>BASE_V
			sta player_a_hitbox_base_knock_up_v_high, x
			lda #FORCE_V
			sta player_a_hitbox_force_v_low, x
			lda #HITSTUN_MODIFIER
			sta player_a_hitbox_hitstun, x

			lda player_a_direction, x
			bne right
				left:
					lda #<BASE_H
					sta player_a_hitbox_base_knock_up_h_low, x
					lda #>BASE_H
					sta player_a_hitbox_base_knock_up_h_high, x
					lda #FORCE_H
					sta player_a_hitbox_force_h_low, x

					jmp hitbox_ok

				right:
					lda #<-BASE_H
					sta player_a_hitbox_base_knock_up_h_low, x
					lda #>-BASE_H
					sta player_a_hitbox_base_knock_up_h_high, x
					lda #-FORCE_H
					sta player_a_hitbox_force_h_low, x

			hitbox_ok:

			; Call opponent's onhurt routine
			.(
				; Save X
				txa:pha

				; Set current_player/opponent_player parameters (and switch X to the hurt player)
				stx tmpfield10
				SWITCH_SELECTED_PLAYER
				stx tmpfield11

				; Call opponent's onhurt callback
				ldy config_player_a_character, x
				lda characters_onhurt_routines_table_lsb, y
				sta tmpfield1
				lda characters_onhurt_routines_table_msb, y
				sta tmpfield2
				lda #<hurt_player
				sta tmpfield12
				lda #>hurt_player
				sta tmpfield13
				lda characters_bank_number, y
				sta tmpfield14
				TRAMPOLINE(player_state_action, characters_bank_number COMMA y, #CURRENT_BANK_NUMBER)

				; Restore X
				pla:tax
			.)

			; Compute screenshake
			.(
				SWITCH_SELECTED_PLAYER
				lda player_a_hitstun, x
				lsr
				cmp #SCREEN_SAKE_MAX_DURATION
				bcc ok
					lda #SCREEN_SAKE_MAX_DURATION
				ok:
				sta screen_shake_counter
				SWITCH_SELECTED_PLAYER
			.)
		.)
	.)

	; If opponent is not in thrown state, flag that next hitboxes should not throw
	.(
		SWITCH_SELECTED_PLAYER
		lda player_a_state, x
		cmp #PLAYER_STATE_THROWN
		beq hit_connected

			hit_missed:
				SWITCH_SELECTED_PLAYER
				lda #HITBOX_WHIFFED
				sta sinbad_side_tilt_hitbox_state, x
				rts ; NOTE return here as we know there is nothing more in the routine

			hit_connected:
				SWITCH_SELECTED_PLAYER
	.)

	rts
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
		bne do_tick
			jmp sinbad_start_special_strike
			; No return, jump to a subroutine
		do_tick:

		jmp sinbad_apply_ground_friction
		;rts ; useless, jump to subroutine
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
		bne do_tick
			jmp sinbad_start_helpless
			; No return, jump to a subroutine
		do_tick:

		jmp sinbad_apply_ground_friction
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

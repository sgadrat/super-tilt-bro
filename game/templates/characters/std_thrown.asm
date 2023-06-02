;
; Thrown
;

.(
	&{char_name}_start_thrown:
	.(
		; Set the player's state
		lda #{char_name_upper}_STATE_THROWN
		sta player_a_state, x

		; Reinitialize walljump counter
		lda #{char_name_upper}_MAX_WALLJUMPS
		sta player_a_walljump, x

		; Initialize tech counter
		lda #0
		sta player_a_state_field1, x

		; Set the appropriate animation
		lda #<{char_name}_anim_thrown
		sta tmpfield13
		lda #>{char_name}_anim_thrown
		sta tmpfield14
		jsr set_player_animation

		; Set the appropriate animation direction (depending on player's velocity)
		lda player_a_velocity_h, x
		bmi set_anim_left
			lda DIRECTION_RIGHT
			jmp set_anim_dir
		set_anim_left:
			lda DIRECTION_LEFT
		set_anim_dir:
			ldy #ANIMATION_STATE_OFFSET_DIRECTION
			sta (tmpfield11), y

		rts
	.)

	&{char_name}_tick_thrown:
	.(
#ifldef {char_name}_global_tick
		jsr {char_name}_global_tick
#endif

		; Decrement tech counter (to zero minimum)
		lda player_a_state_field1, x
		beq end_dec_tech_cnt
			dec player_a_state_field1, x
		end_dec_tech_cnt:

		; Update velocity
		lda player_a_hitstun, x
		bne no_control
			controllable:
				jsr {char_name}_aerial_directional_influence
				jmp apply_player_gravity
				; No return, jump to subroutine

			no_control:
				jsr {char_name}_apply_air_friction
				jmp apply_player_gravity
				; No return, jump to subroutine

		;rts ; useless, no branch return
	.)

	&{char_name}_input_thrown:
	.(
		; Handle controller inputs
		lda #<input_table
		sta tmpfield1
		lda #>input_table
		sta tmpfield2
		lda #INPUT_TABLE_LENGTH
		sta tmpfield3
		jmp controller_callbacks

		; If a tech is entered, store it's direction in state_field2
		; and if the counter is at 0, reset it to it's max value.
		weak_tech_neutral:
			jsr {char_name}_check_aerial_inputs
			lda player_a_state, x
			cmp #{char_name_upper}_STATE_THROWN
			bne end
		tech_neutral:
			lda #$00
			jmp tech_common

		weak_tech_right:
			jsr {char_name}_check_aerial_inputs
			lda player_a_state, x
			cmp #{char_name_upper}_STATE_THROWN
			bne end
		tech_right:
			lda #$01
			jmp tech_common

		weak_tech_left:
			jsr {char_name}_check_aerial_inputs
			lda player_a_state, x
			cmp #{char_name_upper}_STATE_THROWN
			bne end
		tech_left:
			lda #$02

		tech_common:
			sta player_a_state_field2, x
			lda player_a_state_field1, x
			bne end
				ldy system_index
				lda tech_window, y
				sta player_a_state_field1, x

		no_tech:
			jmp {char_name}_check_aerial_inputs
			; No return, jump to subroutine

		end:
		rts

		; Impactful controller states and associated callbacks
		input_table:
		.(
			controller_inputs:
			.byt CONTROLLER_INPUT_TECH,        CONTROLLER_INPUT_TECH_RIGHT,   CONTROLLER_INPUT_TECH_LEFT
			.byt CONTROLLER_INPUT_JUMP,        CONTROLLER_INPUT_JUMP_RIGHT,   CONTROLLER_INPUT_JUMP_LEFT
			controller_callbacks_lo:
			.byt <tech_neutral,                <tech_right,                   <tech_left
			.byt <weak_tech_neutral,           <weak_tech_right,              <weak_tech_left
			controller_callbacks_hi:
			.byt >tech_neutral,                >tech_right,                   >tech_left
			.byt >weak_tech_neutral,           >weak_tech_right,              >weak_tech_left
			controller_default_callback:
			.word no_tech
			&INPUT_TABLE_LENGTH = controller_callbacks_lo - controller_inputs
		.)
	.)

	&{char_name}_onground_thrown:
	.(
		;jsr {char_name}_global_onground ; useless, will be done by start_landing or start_crashing

		; If the tech counter is bellow the threshold, just crash
		ldy system_index
		lda tech_nb_forbidden_frames, y
		cmp player_a_state_field1, x
		bcs crash

		; A valid tech was entered, land with momentum depending on tech's direction
		jsr {char_name}_start_teching
		lda player_a_state_field2, x
		beq no_momentum
		cmp #$01
		beq momentum_right
			ldy system_index
			lda {char_name}_tech_speed_neg_msb, y
			sta player_a_velocity_h, x
			lda {char_name}_tech_speed_neg_lsb, y
			sta player_a_velocity_h_low, x
			rts
		no_momentum:
			lda #$00
			sta player_a_velocity_h, x
			sta player_a_velocity_h_low, x
			rts
		momentum_right:
			ldy system_index
			lda {char_name}_tech_speed_msb, y
			sta player_a_velocity_h, x
			lda {char_name}_tech_speed_lsb, y
			sta player_a_velocity_h_low, x
			rts

		crash:
		jmp {char_name}_start_crashing
		;Note - no return, jump to a subroutine

		;rts ; Useless, unreachable code
	.)
.)

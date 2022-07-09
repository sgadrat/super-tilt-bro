{char_name}_aerial_directional_influence:
.(
	; merge_to_player_velocity parameter names
	merged_v_low = tmpfield1
	merged_v_high = tmpfield3
	merged_h_low = tmpfield2
	merged_h_high = tmpfield4
	merge_step = tmpfield5

	; Choose what to do depending on controller state
	lda controller_a_btns, x
	and #CONTROLLER_INPUT_LEFT
	bne go_left

	lda controller_a_btns, x
	and #CONTROLLER_INPUT_RIGHT
	bne go_right

	air_friction:
		jmp {char_name}_apply_air_friction
		; No return, jump to a subroutine

	go_left:
	.(
		; Go to the left
		ldy system_index

		lda player_a_velocity_v_low, x
		sta merged_v_low
		lda player_a_velocity_v, x
		sta merged_v_high
		lda {char_name}_aerial_neg_speed_lsb, y
		sta merged_h_low
		lda {char_name}_aerial_neg_speed_msb, y
		sta merged_h_high

		SIGNED_CMP({char_name}_aerial_neg_speed_lsb COMMA y, {char_name}_aerial_neg_speed_msb COMMA y, player_a_velocity_h_low COMMA x, player_a_velocity_h COMMA x)
		bpl friction
			influence:
				lda {char_name}_aerial_directional_influence_strength, y
				sta merge_step
				jmp merge_to_player_velocity
				; No return, jump to a subroutine
			friction:
				lda {char_name}_air_friction_strength, y
				sta merge_step
				jmp merge_to_player_velocity
				; No return, jump to a subroutine
	.)

	go_right:
	.(
		; Go to the right
		ldy system_index

		lda player_a_velocity_v_low, x
		sta merged_v_low
		lda player_a_velocity_v, x
		sta merged_v_high
		lda {char_name}_aerial_speed_lsb, y
		sta merged_h_low
		lda {char_name}_aerial_speed_msb, y
		sta merged_h_high

		SIGNED_CMP(player_a_velocity_h_low COMMA x, player_a_velocity_h COMMA x, {char_name}_aerial_speed_lsb COMMA y, {char_name}_aerial_speed_msb COMMA y)
		bpl friction
			influence:
				lda {char_name}_aerial_directional_influence_strength, y
				sta merge_step
				jmp merge_to_player_velocity
				; No return, jump to a subroutine
			friction:
				lda {char_name}_air_friction_strength, y
				sta merge_step
				jmp merge_to_player_velocity
				; No return, jump to a subroutine
	.)

	;rts ; useless, no branch return
.)

; Change the player's state if an aerial move is input on the controller
;  register X - Player number
;
;  Overwrites tmpfield15 and tmpfield2 plus the ones overriten by the state starting subroutine
{char_name}_check_aerial_inputs:
.(
	input_marker = tmpfield15
	player_btn = tmpfield2

	.(
		; Refuse to do anything if under hitstun
		lda player_a_hitstun, x
		bne end

		; Assuming we are called from an input event
		; Do nothing if the only changes concern the left-right buttons
		lda controller_a_btns, x
		eor controller_a_last_frame_btns, x
		and #CONTROLLER_BTN_A | CONTROLLER_BTN_B | CONTROLLER_BTN_UP | CONTROLLER_BTN_DOWN
		beq end

			; Save current direction
			lda player_a_direction, x
			pha

			; Change player's direction according to input direction
			lda controller_a_btns, x
			sta player_btn
			lda #CONTROLLER_BTN_LEFT
			bit player_btn
			beq check_direction_right
				lda DIRECTION_LEFT
				jmp set_direction
			check_direction_right:
				lda #CONTROLLER_BTN_RIGHT
				bit player_btn
				beq no_direction
				lda DIRECTION_RIGHT
			set_direction:
				sta player_a_direction, x
			no_direction:

			; Start the good state according to input
			jsr take_input

			; Restore player's direction if there was no input, else discard saved direction
			lda input_marker
			beq restore_direction
				pla
				jmp end
			restore_direction:
				pla
				sta player_a_direction, x

		end:
		rts
	.)

	take_input:
	.(
		; Mark input
		lda #01
		sta input_marker

		; Call aerial subroutines, in case of input it will return with input marked
		lda #<input_table
		sta tmpfield1
		lda #>input_table
		sta tmpfield2
		lda #INPUT_TABLE_LENGTH
		sta tmpfield3
		jmp controller_callbacks

		;rts ; useless, controller_callbacks returns to caller

		; Fast fall on release of CONTROLLER_INPUT_TECH, gravity * 1.5
		fast_fall:
		.(
			lda controller_a_last_frame_btns, x
			cmp #CONTROLLER_INPUT_TECH
			bne no_fast_fall
				; Set fast fall gravity and velocity
				ldy system_index
				lda {char_name}_fastfall_speed_msb, y
				sta player_a_gravity_msb, x
				sta player_a_velocity_v, x
				lda {char_name}_fastfall_speed_lsb, y
				sta player_a_gravity_lsb, x
				sta player_a_velocity_v_low, x

				; Play SFX
				txa
				pha
				jsr audio_play_fast_fall
				pla
				tax
			no_fast_fall:
			rts
		.)

		; Jump, choose between aerial jump or wall jump
        jump:
        .(
			lda player_a_walled, x
			beq aerial_jump
			lda player_a_walljump, x
			beq aerial_jump
				wall_jump:
					lda player_a_walled_direction, x
					sta player_a_direction, x
					jmp {char_name}_start_walljumping
				aerial_jump:
					jmp {char_name}_start_aerial_jumping
			;rts ; useless, both branches jump to subroutine
        .)

		; If no input, unmark the input flag and return
		no_input:
		.(
			lda #$00
			sta input_marker
			;rts ; Fallthrough to return
		.)

		end:
		rts

		input_table:
		!place "{char_name_upper}_AERIAL_INPUTS_TABLE"
	.)
.)

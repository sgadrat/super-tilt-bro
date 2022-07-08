.(
	velocity_table({char_name_upper}_RUNNING_INITIAL_VELOCITY, run_init_velocity_msb, run_init_velocity_lsb)
	velocity_table(-{char_name_upper}_RUNNING_INITIAL_VELOCITY, run_init_neg_velocity_msb, run_init_neg_velocity_lsb)

	velocity_table({char_name_upper}_RUNNING_MAX_VELOCITY, run_max_velocity_msb, run_max_velocity_lsb)
	velocity_table(-{char_name_upper}_RUNNING_MAX_VELOCITY, run_max_neg_velocity_msb, run_max_neg_velocity_lsb)

	acceleration_table({char_name_upper}_RUNNING_ACCELERATION, run_acceleration)

	&{char_name}_start_running:
	.(
		; Set the player's state
		lda #{char_name_upper}_STATE_RUNNING
		sta player_a_state, x

		; Set initial velocity
		ldy system_index
		lda player_a_direction, x
		cmp DIRECTION_LEFT
		bne direction_right
			direction_left:
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

		; Set the appropriate animation
		lda #<{char_name}_anim_run
		sta tmpfield13
		lda #>{char_name}_anim_run
		sta tmpfield14
		jmp set_player_animation

		;rts ; useless, jump to subroutine
	.)

	&{char_name}_tick_running:
	.(
#ifldef {char_name}_global_tick
		jsr {char_name}_global_tick
#endif

		; Update player's velocity dependeing on his direction
		ldy system_index
		lda player_a_direction, x
		beq run_left

			; Running right, velocity tends toward vector max velocity
			lda run_max_velocity_msb, y
			sta tmpfield4
			lda run_max_velocity_lsb, y
			jmp update_velocity ; Optimizable - inline "update_velocity" section in both "run_left" and "run_right" branches

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

		;rts ; Useless, jump to subroutine
	.)

	&{char_name}_input_running:
	.(
		; If in hitstun, stop running
		lda player_a_hitstun, x
		beq take_input
			jmp {char_name}_start_idle
			; No return, jump to subroutine

		take_input:

			; Check state changes
			lda #<input_table
			sta tmpfield1
			lda #>input_table
			sta tmpfield2
			lda #INPUT_TABLE_LENGTH
			sta tmpfield3
			jmp controller_callbacks

		;rts ; useless, jump to subroutine

		input_running_left:
		.(
			lda DIRECTION_LEFT
			cmp player_a_direction, x
			beq end_changing_direction
				sta player_a_direction, x
				jmp {char_name}_start_running
				; No return, jump to subroutine
			end_changing_direction:
			rts
		.)

		input_running_right:
		.(
			lda DIRECTION_RIGHT
			cmp player_a_direction, x
			beq end_changing_direction
				sta player_a_direction, x
				jmp {char_name}_start_running
				; No return, jump to subroutine
			end_changing_direction:
			rts
		.)

		input_table:
		!place "{char_name_upper}_RUNNING_INPUTS_TABLE"
	.)
.)

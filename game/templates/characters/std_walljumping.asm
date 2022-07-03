.(
	velocity_table(-{char_name_upper}_WALL_JUMP_VELOCITY_V, {char_name}_wall_jump_velocity_v_msb, {char_name}_wall_jump_velocity_v_lsb)
	velocity_table({char_name_upper}_WALL_JUMP_VELOCITY_H, {char_name}_wall_jump_velocity_h_msb, {char_name}_wall_jump_velocity_h_lsb)
	velocity_table(-{char_name_upper}_WALL_JUMP_VELOCITY_H, {char_name}_wall_jump_velocity_h_neg_msb, {char_name}_wall_jump_velocity_h_neg_lsb)

	&{char_name}_start_walljumping:
	.(
		; Deny to start jump state if the player used all it's jumps
		;lda player_a_walljump, x ; useless, all calls to {char_name}_start_walljumping actually do this check
		;beq end

		; Update wall jump counter
		dec player_a_walljump, x

		; Set player's state
		lda #{char_name_upper}_STATE_WALLJUMPING
		sta player_a_state, x

		; Reset clock
		lda #0
		sta player_a_state_clock, x

		; Stop any momentum, {char_name} does not fall during jumpsquat
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
		lda #<{char_name}_anim_jump
		sta tmpfield13
		lda #>{char_name}_anim_jump
		sta tmpfield14
		jsr set_player_animation

		end:
		rts
	.)

	&{char_name}_tick_walljumping:
	.(
#ifldef {char_name}_global_tick
		jsr {char_name}_global_tick
#endif

		; Tick clock
		inc player_a_state_clock, x

		; Wait for the preparation to end to begin to jump
		lda player_a_state_clock, x
		cmp #{char_name_upper}_WALL_JUMP_SQUAT_END
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
			jmp {char_name}_start_falling
			;jmp end ; useless, jump to a subroutine

		; Put initial jumping velocity
		begin_to_jump:
			; Vertical velocity
			ldy system_index
			lda {char_name}_wall_jump_velocity_v_msb, y
			sta player_a_velocity_v, x
			lda {char_name}_wall_jump_velocity_v_lsb, y
			sta player_a_velocity_v_low, x

			; Horizontal velocity
			lda player_a_direction, x
			;cmp DIRECTION_LEFT ; useless while DIRECTION_LEFT is $00
			bne jump_right
				jump_left:
					lda {char_name}_wall_jump_velocity_h_neg_lsb, y
					sta player_a_velocity_h_low, x
					lda {char_name}_wall_jump_velocity_h_neg_msb, y
					jmp end_jump_direction
				jump_right:
					lda {char_name}_wall_jump_velocity_h_lsb, y
					sta player_a_velocity_h_low, x
					lda {char_name}_wall_jump_velocity_h_msb, y
			end_jump_direction:
			sta player_a_velocity_h, x

			;jmp end ; useless, fallthrough

		end:
		rts
	.)

	&{char_name}_input_walljumping:
	.(
		; The jump is cancellable by aerial movements, but only after preparation
		lda #{char_name_upper}_WALL_JUMP_SQUAT_END
		cmp player_a_state_clock, x
		bcs grounded
			not_grounded:
				jmp {char_name}_check_aerial_inputs
				; no return, jump to a subroutine
		grounded:
		rts
	.)
.)

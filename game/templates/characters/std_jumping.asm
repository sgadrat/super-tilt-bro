.(
	+{char_name}_start_jumping_left:
	.(
		lda #DIRECTION_LEFT2
		jmp {char_name}_start_jumping_directional
	.)
	+{char_name}_start_jumping_right:
	.(
		lda #DIRECTION_RIGHT2
		; Fallthrough to {char_name}_start_jumping_directional
	.)
	{char_name}_start_jumping_directional:
	.(
		sta player_a_direction, x
		; Fallthrough to {char_name}_start_jumping
	.)
	&{char_name}_start_jumping:
	.(
		lda #{char_name_upper}_STATE_JUMPING
		sta player_a_state, x

		lda #0
		sta player_a_state_clock, x

		jsr audio_play_jump

		; Set the appropriate animation
		lda #<{char_name}_anim_jump
		sta tmpfield13
		lda #>{char_name}_anim_jump
		sta tmpfield14
		jmp set_player_animation

		;rts ; useless, jump to subroutine
	.)

	&{char_name}_tick_jumping:
	.(
#ifldef {char_name}_global_tick
		jsr {char_name}_global_tick
#endif

		; Tick clock
		inc player_a_state_clock, x

		; Wait for the preparation to end to begin to jump
		ldy system_index
		lda player_a_state_clock, x
		cmp {char_name}_jumpsquat_duration, y
		bcc end
		beq begin_to_jump

		; Handle short-hop input
		cmp {char_name}_short_hop_time, y
		beq stop_short_hop

		; Check if the top of the jump is reached
		lda player_a_velocity_v, x
		beq top_reached
		bpl top_reached

		; The top is not reached, stay in jumping state but apply gravity and directional influence
		moving_upward:
			jmp {char_name}_tick_falling ; Hack - We just use {char_name}_tick_falling which do exactly what we want
			; No return, jump to subroutine

		; The top is reached, return to falling
		top_reached:
			jmp {char_name}_start_falling
			; No return, jump to subroutine

		; If the jump button is no more pressed mid jump, convert the jump to a short-hop
		stop_short_hop:
			; Handle this tick as any other
			jsr {char_name}_tick_falling

			; If the jump button is still pressed, this is not a short-hop
			lda controller_a_btns, x
			and #CONTROLLER_INPUT_JUMP
			bne end

				; Reduce upward momentum to end the jump earlier
				ldy system_index
				lda {char_name}_jump_short_hop_velocity_msb, y
				sta player_a_velocity_v, x
				lda {char_name}_jump_short_hop_velocity_lsb, y
				sta player_a_velocity_v_low, x
				rts
				; No return

		; Put initial jumping velocity
		begin_to_jump:
			ldy system_index
			lda {char_name}_jump_velocity_msb, y
			sta player_a_velocity_v, x
			lda {char_name}_jump_velocity_lsb, y
			sta player_a_velocity_v_low, x
			;jmp end ; Useless, fallthrough

		end:
		rts
	.)

	&{char_name}_input_jumping:
	.(
		; Jump is cancellable by grounded movements during preparation
		; and by aerial movements after that.
		;
		; Aerial jump is cancellable by aerial movements.
		;
		; Above conditions simplified as cancel by ground movements if grounded
		; or aerial movements if not.
		; Note - Grounded with upward momentum is considered ungrounded.
		;        First frame after jumpsquat is still grounded, but with the
		;        jump velocity set.

		lda player_a_grounded, x
		beq not_grounded
		lda player_a_velocity_v, x
		bpl grounded

		not_grounded:
		.(
			jmp {char_name}_check_aerial_inputs
			; No return
		.)

		grounded:
		.(
			lda #<input_table
			sta tmpfield1
			lda #>input_table
			sta tmpfield2
			lda #INPUT_TABLE_LENGTH
			sta tmpfield3
			jmp controller_callbacks
			; No return
		.)

		no_input:
		rts

		input_table:
		!place "{char_name_upper}_JUMPSQUAT_INPUTS_TABLE"
	.)
.)

.(
	&{char_name}_start_aerial_jumping:
	.(
		; Deny to start jump state if the player used all it's jumps
		lda #{char_name_upper}_MAX_NUM_AERIAL_JUMPS
		cmp player_a_num_aerial_jumps, x
		bne jump_ok
			rts
		jump_ok:
		inc player_a_num_aerial_jumps, x

		; Reset fall speed
		jsr reset_default_gravity

		; Trick - aerial_jumping set the state to jumping. It is the same state with
		; the starting conditions as the only differences
		lda #{char_name_upper}_STATE_JUMPING
		sta player_a_state, x

		; Reset clock
		lda #0
		sta player_a_state_clock, x

		;lda #0
		sta player_a_velocity_v, x
		sta player_a_velocity_v_low, x

		; Play SFX
		jsr audio_play_aerial_jump

		; Set the appropriate animation
		lda #<{char_name}_anim_aerial_jump
		sta tmpfield13
		lda #>{char_name}_anim_aerial_jump
		sta tmpfield14
		jmp set_player_animation

		;rts ; useless, jump to subroutine
	.)
.)

.(
	&{char_name}_start_falling:
	.(
		lda #{char_name_upper}_STATE_FALLING
		sta player_a_state, x

		; Set the appropriate animation
		lda #<{char_name}_anim_falling
		sta tmpfield13
		lda #>{char_name}_anim_falling
		sta tmpfield14
		jmp set_player_animation

		;rts ; useless, jump to subroutine
	.)

	&{char_name}_tick_falling:
	.(
#ifldef {char_name}_global_tick
		jsr {char_name}_global_tick
#endif

		jsr {char_name}_aerial_directional_influence
		jmp apply_player_gravity
		;rts ; useless, jump to subroutine
	.)
.)

.(
	jumping_short_hop_clock = player_a_state_field1

	; Initialize what's needed to be able to adjust jump velocity like the jumping state would do for a short hop
	;  X - player number
	;
	;  Overwrites A, Y, player_a_state_field1, player_b_state_field1
	;
	;  Note - must be called before changing player_a_state,x
	;  Note - will use associated player's state field 1 in tick, do not overwrite
	&{char_name}_short_hop_takeover_init:
	.(
		; Don't handle short hop if not comming from jumping state
		lda player_a_state, x
		cmp #{char_name_upper}_STATE_JUMPING
		bne disable_clock

		; Don't handle short hop if input check has already been done
		ldy system_index
		lda {char_name}_short_hop_aerial_time, y
		cmp player_a_state_clock, x
		bcc disable_clock

		enable_clock:
			; Store number of frames left before short hop velocity change in clock
			lda  {char_name}_short_hop_time, y
			sec
			sbc player_a_state_clock, x
			sta jumping_short_hop_clock, x
			rts

		disable_clock:
			; Disable short hop handling by storing a negative number in clock
			lda #$ff
			sta jumping_short_hop_clock, x

		rts
	.)

	; Proceed to adjust jump velocity to convert high jump to a short hop
	&{char_name}_short_hop_takeover_tick:
	.(
		lda jumping_short_hop_clock, x
		bmi ok
		bne tick_clock

			set_short_hop_velocity:
				ldy system_index
				lda {char_name}_jump_short_hop_velocity_msb, y
				sta player_a_velocity_v, x
				lda {char_name}_jump_short_hop_velocity_lsb, y
				sta player_a_velocity_v_low, x
				; fallthrough to disable the clock by setting it to a negative value

			tick_clock:
				dec jumping_short_hop_clock, x

		ok:
		rts
	.)
.)

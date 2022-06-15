;
; Respawn
;

.(
	&{char_name}_start_respawn_invisible:
	.(
		; Set the player's state
		lda #{char_name_upper}_STATE_RESPAWN_INVISIBLE
		sta player_a_state, x

		; Place player on the corner of the screen
		lda #$00
		sta player_a_x, x
		sta player_a_x_low, x
		sta player_a_y, x
		sta player_a_y_low, x
		sta player_a_x_screen, x
		sta player_a_y_screen, x
		sta player_a_velocity_h, x
		sta player_a_velocity_h_low, x
		sta player_a_velocity_v, x
		sta player_a_velocity_v_low, x
		sta player_a_damages, x

		; Init timer
		ldy system_index
		lda player_respawn_invisible_duration, y
		sta player_a_state_field1, x

		; Set the appropriate animation
		lda #<anim_invisible
		sta tmpfield13
		lda #>anim_invisible
		sta tmpfield14
		jmp set_player_animation

		;rts ; useless, jump to subroutine
	.)

	&{char_name}_tick_respawn_invisible:
	.(
		dec player_a_state_field1, x
		bne ok
			jmp {char_name}_start_respawn_platform
		ok:
		rts
	.)

	&{char_name}_start_respawn_platform:
	.(
		; Set the player's state
		lda #{char_name_upper}_STATE_RESPAWN_PLATFORM
		sta player_a_state, x

		; Place player to the respawn spot
		lda stage_data+STAGE_HEADER_OFFSET_RESPAWNX_HIGH
		sta player_a_x, x
		lda stage_data+STAGE_HEADER_OFFSET_RESPAWNX_LOW
		sta player_a_x_low, x
		lda stage_data+STAGE_HEADER_OFFSET_RESPAWNY_HIGH
		sta player_a_y, x
		lda stage_data+STAGE_HEADER_OFFSET_RESPAWNY_LOW
		sta player_a_y_low, x
		lda #$00
		sta player_a_x_screen, x
		sta player_a_y_screen, x
		sta player_a_velocity_h, x
		sta player_a_velocity_h_low, x
		sta player_a_velocity_v, x
		sta player_a_velocity_v_low, x
		sta player_a_damages, x

		; Initialize state's timer
		ldy system_index
		lda player_respawn_max_duration, y
		sta player_a_state_field1, x

		; Reinitialize walljump counter
		lda #{char_name_upper}_MAX_WALLJUMPS
		sta player_a_walljump, x

		; Set the appropriate animation
		lda #<{char_name}_anim_respawn
		sta tmpfield13
		lda #>{char_name}_anim_respawn
		sta tmpfield14
		jmp set_player_animation

		;rts ; useless, jump to subroutine
	.)

	&{char_name}_tick_respawn_platform:
	.(
		; Check for timeout
		dec player_a_state_field1, x
		bne end
			jmp {char_name}_start_falling
			; No return, jump to subroutine

		end:
		rts
	.)

	&{char_name}_input_respawn_platform:
	.(
		; Avoid doing anything until controller has returned to neutral since after
		; death the player can release buttons without expecting to take action
		lda controller_a_last_frame_btns, x
		bne end

		; Call {char_name}_check_aerial_inputs
		;  If it does not change the player state, go to falling state
		;  so that any button press makes the player falls from revival
		;  platform
		jsr {char_name}_check_aerial_inputs
		lda player_a_state, x
		cmp #{char_name_upper}_STATE_RESPAWN_PLATFORM
		bne end
			jmp {char_name}_start_falling
			; No return, jump to subroutine

		end:
		rts
	.)
.)

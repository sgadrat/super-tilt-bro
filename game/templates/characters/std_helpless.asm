.(
	&{char_name}_start_helpless:
	.(
		; Set state
		lda #{char_name_upper}_STATE_HELPLESS
		sta player_a_state, x

		; Set the appropriate animation
		lda #<{char_name}_anim_helpless
		sta tmpfield13
		lda #>{char_name}_anim_helpless
		sta tmpfield14
		jmp set_player_animation

		;rts ; useless, jump to subroutine
	.)

	&{char_name}_tick_helpless = {char_name}_tick_falling

	&{char_name}_input_helpless:
	.(
		; Allow to escape helpless mode with a walljump, else keep input dirty
		lda player_a_walled, x
		beq no_jump
		lda player_a_special_jumps, x
		and #%00000001
		beq no_jump
			jump:
				lda player_a_walled_direction, x
				sta player_a_direction, x
				jmp {char_name}_start_walljumping
			no_jump:
				jmp dumb_keep_input_dirty ; Beware - changing this call to "smart_keep_input_dirty" may change walljump behaviour (which was performed if the player released buttons after entring helpless), it may be desirable though.
		;rts ; useless, both branches jump to a subroutine
	.)
.)

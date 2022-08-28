.(
	+{char_name}_start_owned:
	.(
		; Set the player's state
		lda #{char_name_upper}_STATE_OWNED
		sta player_a_state, x

		; Set the appropriate animation
		lda #<{char_name}_anim_owned
		sta tmpfield13
		lda #>{char_name}_anim_owned
		sta tmpfield14
		jmp set_player_animation

		;rts ; useless, jump to subroutine
	.)
.)

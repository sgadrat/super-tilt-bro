.(
	&{char_name}_start_innexistant:
	.(
		; Set the player's state
		lda #{char_name_upper}_STATE_INNEXISTANT
		sta player_a_state, x

		; Set to a fixed place
		lda #0
		sta player_a_x_screen, x
		sta player_a_x, x
		sta player_a_x_low, x
		sta player_a_y_screen, x
		sta player_a_y, x
		sta player_a_y_low, x
		sta player_a_velocity_h, x
		sta player_a_velocity_h_low, x
		sta player_a_velocity_v, x
		sta player_a_velocity_v_low, x

		; Set the appropriate animation
		lda #<anim_invisible
		sta tmpfield13
		lda #>anim_invisible
		sta tmpfield14
		jmp set_player_animation

		;rts ; useless, jump to subroutine
	.)
.)

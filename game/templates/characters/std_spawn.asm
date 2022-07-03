.(
	spawn_duration:
		.byt {char_name}_anim_spawn_dur_pal, {char_name}_anim_spawn_dur_ntsc
#if {char_name}_anim_spawn_dur_pal <> 50
#error incorrect spawn duration
#endif
#if {char_name}_anim_spawn_dur_ntsc <> 60
#error incorrect spawn duration (ntsc only)
#endif

	&{char_name}_start_spawn:
	.(
#ifldef {char_name}_init
		; Hack - there is no ensured call to a character init function
		;        expect start_spawn to be called once at the begining of a game
		jsr {char_name}_init
#endif

		; Set the player's state
		lda #{char_name_upper}_STATE_SPAWN
		sta player_a_state, x

		; Reset clock
		ldy system_index
		lda spawn_duration, y
		sta player_a_state_clock, x

		; Set the appropriate animation
		lda #<{char_name}_anim_spawn
		sta tmpfield13
		lda #>{char_name}_anim_spawn
		sta tmpfield14
		jmp set_player_animation

		;rts ; useless, jump to subroutine
	.)

	&{char_name}_tick_spawn:
	.(
#ifldef {char_name}_global_tick
		jsr {char_name}_global_tick
#endif

		dec player_a_state_clock, x
		bne tick
			jmp {char_name}_start_idle
			; No return, jump to subroutine
		tick:
		rts
	.)
.)

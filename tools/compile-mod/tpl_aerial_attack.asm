;
; Aerial move
;

; {anim} - Animation of the move
; {state} - Character's state number
; {routine} - Name of the state's routines

.(
	duration:
		.byt {anim}_dur_pal, {anim}_dur_ntsc

	+{char_name}_start_{routine}:
	.(
		; Set state
		lda #{state}
		sta player_a_state, x

		; Reset clock
		ldy system_index
		lda duration, y
		sta player_a_state_clock, x

		; Set the appropriate animation
		lda #<{anim}
		sta tmpfield13
		lda #>{anim}
		sta tmpfield14
		jmp set_player_animation

		;rts ; useless, jump to subroutine
	.)
.)

#ifldef {char_name}_std_aerial_tick
#else
	+{char_name}_std_aerial_tick:
	.(
#ifldef {char_name}_global_tick
		jsr {char_name}_global_tick
#endif

		dec player_a_state_clock, x
		bne tick
			jmp {char_name}_start_falling
			; No return, jump to subroutine
		tick:
		jmp apply_player_gravity
		;rts ; useless, jump to subroutine
	.)
#endif

+{char_name}_tick_{routine} = {char_name}_std_aerial_tick

!undef "anim"
!undef "state"
!undef "routine"

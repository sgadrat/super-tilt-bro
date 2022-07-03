;
; Aerial move that is not cancelled by landing
;

; {anim} - Animation of the move
; {state} - Character's state number
; {routine} - Name of the state's routines

.(
	duration:
		.byt {anim}_dur_pal, {anim}_dur_ntsc

	&{char_name}_start_{routine}:
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

	&{char_name}_tick_{routine}:
	.(
#ifldef {char_name}_global_tick
		jsr {char_name}_global_tick
#endif

		jsr {char_name}_apply_friction_lite

		dec player_a_state_clock, x
		bne end
			jmp {char_name}_start_inactive_state
			; No return, jump to subroutine
		end:
		rts
	.)
.)

!undef "anim"
!undef "state"
!undef "routine"

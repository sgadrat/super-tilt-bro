;
; Aerial move
;

; {anim} - Animation of the move
; {state} - Character's state number
; {routine} - Name of the state's routines

.(
	duration:
		.byt {anim}_dur_pal, {anim}_dur_ntsc

	;Note - player_a_state_field1,x is used by short hop takeover

	+{char_name}_start_{routine}_left:
	.(
		lda #DIRECTION_LEFT2
		jmp {char_name}_start_{routine}_directional
	.)
	+{char_name}_start_{routine}_right:
	.(
		lda #DIRECTION_RIGHT2
		; Fallthrough to {char_name}_start_{routine}_directional
	.)
	{char_name}_start_{routine}_directional:
	.(
		sta player_a_direction, x
		; Fallthrough to {char_name}_start_{routine}
	.)
	+{char_name}_start_{routine}:
	.(
		; Take over short hop logic to force a short hop if aerial is input at the begining of the jump
		jsr {char_name}_short_hop_takeover_init

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
		; Global tick
		jsr {char_name}_global_tick
#endif

		; Return to falling at the end of the move
		dec player_a_state_clock, x
		bne tick
			jmp {char_name}_start_falling
			; No return, jump to subroutine
		tick:
		jsr {char_name}_short_hop_takeover_tick
		jsr {char_name}_aerial_directional_influence
		jmp apply_player_gravity
		;rts ; useless, jump to subroutine
	.)
#endif

+{char_name}_tick_{routine} = {char_name}_std_aerial_tick

!undef "anim"
!undef "state"
!undef "routine"

;
; Grounded move
;

; {anim} - Animation of the move
; {state} - Character's state number
; {routine} - Name of the state's routines

.(
	{anim}_dur:
		.byt {anim}_dur_pal, {anim}_dur_ntsc

	&{char_name}_start_{routine}:
	.(
		; Set state
		lda #{state}
		sta player_a_state, x

		; Reset clock
		ldy system_index
		lda {anim}_dur, y
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

#ifldef {char_name}_std_grounded_tick
#else
{char_name}_std_grounded_tick:
.(
#ifldef {char_name}_global_tick
	jsr {char_name}_global_tick
#endif

	; After move's time is out, go to standing state
	dec player_a_state_clock, x
	bne do_tick
		jmp {char_name}_start_idle
		; No return, jump to subroutine
	do_tick:

	; Do not move, velocity tends toward vector (0,0)
	jmp {char_name}_apply_ground_friction

	;rts ; useless, jump to subroutine
.)
#endif

{char_name}_tick_{routine} = {char_name}_std_grounded_tick

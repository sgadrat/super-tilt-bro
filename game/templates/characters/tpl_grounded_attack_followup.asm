;
; Grounded move
;

; anim - Animation of the move
; state - Character's state number
; routine - Name of the state's routines
; followup - Name of the routine to call on state's end (defaults to inactive state)
; init - Extra init code (defaults to just returning from subroutine)
; tick - Tick code (defaults to applying grounded friction)
; duration - Duration of the state in frames (defaults to animation duration)

!default "followup" {!place "char_name"_start_inactive_state}

!default "tick" {
	; Do not move, velocity tends toward vector (0,0)
	jmp !place "char_name"_apply_ground_friction
	;rts ; useless, jump to subroutine
}

!default "duration" {!place "anim"_dur_pal, !place "anim"_dur_ntsc}

.(
	{anim}_dur:
		.byt !place "duration"

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
		!ifndef "init" {
			jmp set_player_animation
			;rts ; useless, jump to subroutine
		}
		!ifdef "init" {
			jsr set_player_animation
			!place "init"
		}
	.)
.)

+{char_name}_tick_{routine}
.(
#ifldef {char_name}_global_tick
	jsr {char_name}_global_tick
#endif

	; After move's time is out, go to standing state
	dec player_a_state_clock, x
	bne do_tick
		jmp {followup}
		; No return, jump to subroutine
	do_tick:

	!place "tick"
.)

!undef "anim"
!undef "state"
!undef "routine"
!undef "followup"
!ifdef "init" {!undef "init"}
!undef "tick"
!undef "duration"

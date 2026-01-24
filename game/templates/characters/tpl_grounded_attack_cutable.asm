;
; Grounded move which the end can be skipped by specific inputs
;

; anim - Animation of the move
; state - Character's state number
; routine - Name of the state's routines
; cutable_duration - Duration of the part of the animation that CANNOT be cut
; followup - Name of the routine to call on state's end (defaults to inactive state)
; init - Extra init code (defaults to just returning from subroutine)
; tick - Tick code (defaults to applying grounded friction)
; duration - Duration of the state in frames (defaults to animation duration)
; cut_input - Code handling input changes during the cutable part (defaults to idle input handler)

;NOTE this template could be merged with tpl_grounded_attack_followup
;     - it adds the input routine, but does not touchother code
;     - difficulty being computing the cutable_duration table from "duration" parameter which contains pal+ntsc variants
;       - maybe make it two parameters, duration_pal and duration_ntsc? would disallow to use "anim duration table" macro though.

!default "followup" {!place "char_name"_start_inactive_state}

!default "tick" {
	; Do not move, velocity tends toward vector (0,0)
	jmp !place "char_name"_apply_ground_friction
	;rts ; useless, jump to subroutine
}

!default "duration" {!place "anim"_dur_pal, !place "anim"_dur_ntsc}

!default "cut_input" {
	jmp !place "char_name"_input_idle
}

.(
	{anim}_dur:
		.byt !place "duration"

	anim_duration_table({anim}_dur_pal-{cutable_duration}, cutable_duration)

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

	+{char_name}_input_{routine}:
	.(
		ldy system_index
		lda cutable_duration, y
		cmp player_a_state_clock, x
		bcs take_input

			not_yet:
				; Keep keypress dirty, but acknowledge key release
				;  So releasing then pressing again same move's input correctly bufferises the move's input
				;  otherwise an attack could not be cut by itself
				lda controller_a_btns, x
				beq end
					jmp dumb_keep_input_dirty ; dumb as we already checked the "smart" condition for our own logic

			take_input:
				; Allow to cut the animation
				.(
					!place "cut_input"
				.)

		end:
		rts
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
!undef "cutable_duration"
!undef "cut_input"

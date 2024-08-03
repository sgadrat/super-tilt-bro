;
; Aerial move
;

; anim - Animation of the move
; state - Character's state number
; routine - Name of the state's routines
; cutable_duration - Duration of the part of the animation that can be cut
; init - Extra init code (defaults to just returning from subroutine)
; tick - Extra tick code (defaults to just returning from subroutine)
; followup - Name of the routine to call on state's end (defaults to falling state)
; cut_input - Code handling input changes during the cutable part (defaults to calling character's check_aerial_inputs)

!default "followup" {!place "char_name"_start_falling}
!default "cut_input" {
	jmp !place "char_name"_check_aerial_inputs
}

.(
	duration:
		.byt {anim}_dur_pal, {anim}_dur_ntsc

	anim_duration_table({anim}_dur_pal-{cutable_duration}, cutable_duration)

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
		!ifndef "init" {
			jmp set_player_animation
			;rts ; useless, jump to subroutine
		}
		!ifdef "init" {
			jsr set_player_animation
			!place "init"
		}

		;rts ; useless, jump to subroutine
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
				!place "cut_input"

		end:
		rts
	.)

	+{char_name}_tick_{routine}:
	.(
#ifldef {char_name}_global_tick
		; Global tick
		jsr {char_name}_global_tick
#endif

		; Return to falling at the end of the move
		dec player_a_state_clock, x
		bne tick
			jmp {followup}
			; No return, jump to subroutine
		tick:
		jsr {char_name}_short_hop_takeover_tick
		jsr {char_name}_aerial_directional_influence
		!ifndef "tick" {
			jmp apply_player_gravity
			;rts ; useless, jump to subroutine
		}
		!ifdef "tick" {
			jsr apply_player_gravity
			!place "tick"
		}
	.)
.)

!undef "anim"
!undef "state"
!undef "routine"
!undef "cutable_duration"
!ifdef "init" {!undef "init"}
!ifdef "tick" {!undef "tick"}
!undef "followup"
!undef "cut_input"

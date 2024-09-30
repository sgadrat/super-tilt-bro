;
; Aerial move that is not cancelled by landing
;

; anim - Animation of the move
; state - Character's state number
; routine - Name of the state's routines
; init - Extra init code (defaults to just returning from subroutine)
; followup - Name of the routine to call on state's end (defaults to inactive state)

!default "followup" {!place "char_name"_start_inactive_state}

.(
	duration:
		.byt {anim}_dur_pal, {anim}_dur_ntsc

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
		!ifndef "init" {
			jmp set_player_animation
			;rts ; useless, jump to subroutine
		}
		!ifdef "init" {
			jsr set_player_animation
			!place "init"
		}

		;rts ; useless, handled by init
	.)

	+{char_name}_tick_{routine}:
	.(
#ifldef {char_name}_global_tick
		jsr {char_name}_global_tick
#endif

		jsr {char_name}_apply_friction_lite
		jsr {char_name}_short_hop_takeover_tick

		dec player_a_state_clock, x
		bne end
			jmp {followup}
			; No return, jump to subroutine
		end:
		rts
	.)
.)

!undef "anim"
!undef "state"
!undef "routine"
!ifdef "init" {!undef "init"}
!undef "followup"

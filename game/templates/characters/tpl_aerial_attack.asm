;
; Aerial move
;

; anim - Animation of the move
; state - Character's state number
; routine - Name of the state's routines
; init - Extra init code (defaults to just returning from subroutine)
; tick - Extra tick code (defaults to just returning from subroutine) ;FIXME do not return from this one (contrarily to "tick" in other templates)
; followup - Name of the routine to call on state's end (defaults to falling state)

!ifdef "followup" {
	!square-default "tpl_special_tick" []
}
!ifdef "tick" {
	!square-default "tpl_special_tick" []
}

!default "followup" {!place "char_name"_start_falling}
!default "tick" {}

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
.)



!ifndef "tpl_special_tick" {
#ifldef !place "char_name"_std_aerial_tick
#else
	+!place "char_name"_std_aerial_tick:
	.(
#ifldef !place "char_name"_global_tick
		; Global tick
		jsr !place "char_name"_global_tick
#endif

		; Return to falling at the end of the move
		dec player_a_state_clock, x
		bne tick
			jmp !place "char_name"_start_falling
			; No return, jump to subroutine
		tick:
		jsr !place "char_name"_short_hop_takeover_tick
		jsr !place "char_name"_aerial_directional_influence
		jmp apply_player_gravity
		;rts ; useless, jump to subroutine
	.)
#endif

	+!place "char_name"_tick_!place "routine" = !place "char_name"_std_aerial_tick
}

!ifdef "tpl_special_tick" {
	+!place "char_name"_tick_!place "routine":
	.(
#ifldef !place "char_name"_global_tick
		; Global tick
		jsr !place "char_name"_global_tick
#endif

		; Return to falling at the end of the move
		dec player_a_state_clock, x
		bne tick
			jmp !place "followup"
			; No return, jump to subroutine
		tick:
		!place "tick"
		jsr !place "char_name"_short_hop_takeover_tick
		jsr !place "char_name"_aerial_directional_influence
		jmp apply_player_gravity
		;rts ; useless, jump to subroutine
	.)
}

!undef "anim"
!undef "state"
!undef "routine"
!ifdef "init" {!undef "init"}
!ifdef "followup" {!undef "followup"}
!ifdef "tick" {!undef "tick"}
!ifdef "tpl_special_tick" {!undef "tpl_special_tick"}

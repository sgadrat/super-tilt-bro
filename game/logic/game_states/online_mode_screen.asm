online_mode_screen_fadein:
.(
	SWITCH_BANK(#ONLINE_MODE_SCREEN_FADEIN_BANK_NUMBER)
	jmp online_mode_screen_fadein_extra
	;rts ; useless, jump to subroutine
.)

init_online_mode_screen:
.(
	; Initialize C stack
	jsr reinit_c_stack

	; Call C init routine
	SWITCH_BANK(#ONLINE_MODE_SCREEN_EXTRA_BANK_NUMBER)
	jmp init_online_mode_screen_extra

	;rts ; useless, jump to subroutine
.)

online_mode_screen_tick:
.(
	; Call C tick routine
	SWITCH_BANK(#ONLINE_MODE_SCREEN_EXTRA_BANK_NUMBER)
	jmp online_mode_screen_tick_extra

	;rts ; useless, jump to subroutine
.)

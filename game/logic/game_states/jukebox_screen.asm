init_jukebox_screen:
.(
	; Initialize C stack
	jsr reinit_c_stack

	; Call C init routine
	SWITCH_BANK(#JUKEBOX_SCREEN_EXTRA_CODE_BANK_NUMBER)
	jmp init_jukebox_screen_extra
	;rts ; useless, jump to subroutine
.)

jukebox_screen_tick:
.(
	; Call C tick routine
	SWITCH_BANK(#JUKEBOX_SCREEN_EXTRA_CODE_BANK_NUMBER)
	jmp jukebox_screen_tick_extra
	;rts ; useless, jump to subroutine
.)

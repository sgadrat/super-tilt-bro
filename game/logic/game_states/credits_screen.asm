init_credits_screen:
.(
	; Initialize C stack
	jsr reinit_c_stack

	; Call C init routine
	SWITCH_BANK(#CREDITS_SCREEN_EXTRA_BANK_NUMBER)
	jmp init_credits_screen_extra

	;rts ; useless, jump to subroutine
.)

credits_screen_tick:
.(
	; Call C tick routine
	SWITCH_BANK(#CREDITS_SCREEN_EXTRA_BANK_NUMBER)
	jmp credits_screen_tick_extra

	;rts ; useless, jump to subroutine
.)

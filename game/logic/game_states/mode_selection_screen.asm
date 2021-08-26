init_mode_selection_screen:
.(
	; Initialize C stack
	jsr reinit_c_stack

	; Call C init routine
	SWITCH_BANK(#MODE_SELECTION_SCREEN_EXTRA_BANK_NUMBER)
	jmp init_mode_selection_screen_extra

	;rts ; useless, jump to subroutine
.)

mode_selection_screen_tick:
.(
	; Call C tick routine
	SWITCH_BANK(#MODE_SELECTION_SCREEN_EXTRA_BANK_NUMBER)
	jmp mode_selection_screen_tick_extra

	;rts ; useless, jump to subroutine
.)

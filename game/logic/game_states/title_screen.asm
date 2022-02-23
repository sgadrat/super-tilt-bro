init_title_screen:
.(
	SWITCH_BANK(#TITLE_SCREEN_EXTRA_CODE_BANK_NUMBER)
	jmp init_title_screen_extra
	;rts ; useless, jump to subroutine
.)

title_screen_tick:
.(
	SWITCH_BANK(#TITLE_SCREEN_EXTRA_CODE_BANK_NUMBER)
	jmp title_screen_tick_extra
	;rts ; useless, jump to subroutine
.)

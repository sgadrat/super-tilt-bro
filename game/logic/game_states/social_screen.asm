+init_social_screen:
.(
	SWITCH_BANK(#SOCIAL_SCREEN_EXTRA_BANK_NUMBER)
	jmp init_social_screen_extra
	;rts ; useless, jump to subroutine
.)

+social_screen_tick:
.(
	SWITCH_BANK(#SOCIAL_SCREEN_EXTRA_BANK_NUMBER)
	jmp social_screen_tick_extra
	;rts ; useless, jump to subroutine
.)

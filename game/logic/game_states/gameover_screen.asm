init_gameover_screen:
.(
	SWITCH_BANK(#GAMEOVER_SCREEN_EXTRA_CODE_BANK_NUMBER)
	jmp init_gameover_screen_extra
	;rts ; useless, jump to subroutine
.)

gameover_screen_tick:
.(
	SWITCH_BANK(#GAMEOVER_SCREEN_EXTRA_CODE_BANK_NUMBER)
	jmp gameover_screen_tick_extra
	;rts ; useless, jump to subroutine
.)

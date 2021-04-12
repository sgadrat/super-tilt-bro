init_netplay_launch_screen:
.(
	jsr set_menu_chr

	SWITCH_BANK(#NETPLAY_LAUNCH_SCREEN_EXTRA_BANK_NUMBER)
	jmp init_netplay_launch_screen_extra

	;rts ; useless, jump to a subroutine
.)

netplay_launch_screen_tick:
.(
	SWITCH_BANK(#NETPLAY_LAUNCH_SCREEN_EXTRA_BANK_NUMBER)
	jmp netplay_launch_screen_tick_extra
	;rts ; useless, jump to a subroutine
.)

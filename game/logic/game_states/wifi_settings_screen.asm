init_wifi_settings_screen:
.(
	; Initialize C stack
	jsr reinit_c_stack

	; Call C init routine
	SWITCH_BANK(#WIFI_SETTINGS_SCREEN_EXTRA_BANK_NUMBER)
	jmp init_wifi_settings_screen_extra

	;rts ; useless, jump to subroutine
.)

wifi_settings_screen_tick:
.(
	; Call C tick routine
	SWITCH_BANK(#WIFI_SETTINGS_SCREEN_EXTRA_BANK_NUMBER)
	jmp wifi_settings_screen_tick_extra

	;rts ; useless, jump to subroutine
.)

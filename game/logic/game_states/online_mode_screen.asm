init_online_mode_screen:
.(
	; Initialize C stack
	lda #<c_stack_end
	sta _sp0
	lda #>c_stack_end
	sta _sp1

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

online_mode_screen_tick_music:
.(
	jsr audio_music_tick
	SWITCH_BANK(#ONLINE_MODE_SCREEN_EXTRA_BANK_NUMBER)
	rts
.)

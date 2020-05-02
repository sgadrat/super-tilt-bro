game_mode_online_init:
.(
#ifdef NETWORK_AI
	jsr game_mode_local_init
#endif

	jmp network_init_stage
	;rts ; useless - jump to a subroutine
.)

game_mode_online_pre_update:
.(
#ifdef NETWORK_AI
	; Process AI, done before network call to override "physical" gamepad state
	jsr game_mode_local_pre_update
	lda controller_b_btns
	sta controller_a_btns
#endif

	jmp network_tick_ingame
	;rts ; useless - jump to a subroutine
.)

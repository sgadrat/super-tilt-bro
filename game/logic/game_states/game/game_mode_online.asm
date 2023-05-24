game_mode_online_init = network_init_stage
game_mode_online_pre_update = network_tick_ingame

game_mode_online_gameover:
.(
	; Deactivate PAL emulation
	.(
		lda pal_emulation_counter
		bmi ok
			lda #$ff
			sta pal_emulation_counter
			lda #1
			sta system_index
		ok:
	.)

	; Continue to gameover screen
	jmp game_mode_goto_gameover

	;rts ; useless, jump to subroutine
.)

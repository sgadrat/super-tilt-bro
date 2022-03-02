;
; Screen between fights implementation
;

init_arcade_mode:
.(
	; Initialize C stack
	jsr reinit_c_stack

	; Call C init routine
	SWITCH_BANK(#ARCADE_MODE_EXTRA_BANK_NUMBER)
	jmp init_arcade_mode_extra

	;rts ; useless, jump to subroutine
.)

arcade_mode_tick:
.(
	; Call C tick routine
	SWITCH_BANK(#ARCADE_MODE_EXTRA_BANK_NUMBER)
	jmp arcade_mode_tick_extra

	;rts ; useless, jump to subroutine
.)

;
; Game mode implementation
;

;HACK local mode only handle AI, and we want AI too
game_mode_arcade_pre_update = game_mode_local_pre_update

game_mode_arcade_init:
.(
	lda arcade_mode_player_damages
	sta player_a_damages

	jmp game_mode_local_init ; ;HACK local mode only handle AI, and we want AI too
.)

game_mode_arcade_gameover:
.(
	lda gameover_winner
	sta arcade_mode_last_game_winner

	lda player_a_damages
	sta arcade_mode_player_damages

	inc arcade_mode_current_encounter

	lda #GAME_STATE_ARCADE_MODE
	jmp change_global_game_state
.)

game_mode_local_init:
.(
	jmp ai_init
	;rts ; useless - jump to subroutine
.)

game_mode_local_pre_update:
.(
	; Tick AI only if AI is active and frame is playable
	lda config_ai_level
	beq end_ai
	lda network_rollback_mode
    bne end_ai
	lda screen_shake_counter
	bne end_ai
	lda slow_down_counter
	bne end_ai
        jsr ai_tick
    end_ai:
	rts
.)

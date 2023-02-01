; Sets fadeout level
;  register X - fadeout level
;
; Overwrites registers, tmpfield1 to tmpfield4
+stage_deeprock_fadeout:
.(
	; Set ideal fade level
	stx stage_fade_level

	; If not in rollback, apply it immediately
	lda network_rollback_mode
	beq apply_fadeout
		rts

	apply_fadeout:
	;Fallthrough to stage_deeprock_fadeout_update
.)

; Rewrite palettes to match fadeout level
;  register X - fadeout level
;
; Overwrites registers, tmpfield1 to tmpfield4
stage_deeprock_fadeout_update:
.(
	header = tmpfield1 ; construct_nt_buffer parameter
	payload = tmpfield3 ; construct_nt_buffer parameter

	; Do nothing if there is not enough space in the buffer
	.(
		IF_NT_BUFFERS_FREE_SPACE_LT(#1+3+16+1, ok)
			rts
		ok:
	.)

	; Set actual fade level
	stx stage_current_fade_level

	; Change palette
	lda #<palette_header
	sta header
	lda #>palette_header
	sta header+1

	lda stage_deeprock_fadeout_lsb, x
	sta payload
	lda stage_deeprock_fadeout_msb, x
	sta payload+1

	jmp construct_nt_buffer

	;rts ; useless, jump to subroutine

	palette_header:
	.byt $3f, $00, $10
.)

+stage_deeprock_init:
.(
	; Magma stage initialization
	TRAMPOLINE(stages_magma_init, #BANKED_UTILS_BANK_NUMBER, #CURRENT_BANK_NUMBER)

	; Disable screen restore
	lda #$ff
	sta stage_restore_screen_step
	lda #FADE_LEVEL_NORMAL
	sta stage_fade_level
	sta stage_current_fade_level
	rts
.)

+stage_deeprock_tick:
.(
	; Update background (apply an asynchrone change if requested, else animate lava)
	lda network_rollback_mode
	bne bg_update_ok
		lda #<stage_deeprock_top_attributes : sta tmpfield1
		lda #<stage_deeprock_bot_attributes : sta tmpfield2
		lda #>stage_deeprock_top_attributes : sta tmpfield3
		lda #>stage_deeprock_bot_attributes : sta tmpfield4
		TRAMPOLINE(stages_magma_update_background, #BANKED_UTILS_BANK_NUMBER, #CURRENT_BANK_NUMBER)
	bg_update_ok:
	rts
.)

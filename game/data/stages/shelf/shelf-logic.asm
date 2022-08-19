+stage_skyride_fadeout:
.(
	header = tmpfield1 ; construct_nt_buffer parameter
	payload = tmpfield3 ; construct_nt_buffer parameter

	lda #<palette_header
	sta header
	lda #>palette_header
	sta header+1

	lda stage_skyride_fadeout_lsb, x
	sta payload
	lda stage_skyride_fadeout_msb, x
	sta payload+1

	jmp construct_nt_buffer

	;rts ; useless, jump to subroutine

	palette_header:
	.byt $3f, $00, $10
.)

+stage_skyride_init:
.(
	; Disable screen restore
	lda #$ff
	sta stage_restore_screen_step
	rts
.)

+stage_skyride_tick:
stage_skyride_restore_screen:
.(
	; Do nothing when rollbacking - optimizable, could be checked by caller (already done on one call)
	.(
		lda network_rollback_mode
		beq ok
			rts
		ok:
	.)

	; Do noting if there is no restore operation running - optimizable, could have X loaded by caller (one call already checks for bpl)
	.(
		ldx stage_restore_screen_step
		bpl ok
			rts
		ok:
	.)

	; Write NT buffer corresponding to current step
	.(
		;ldx stage_restore_screen_step ; useless, done above
		lda steps_buffers_lsb, x
		ldy steps_buffers_msb, x
		jsr push_nt_buffer
	.)

	; Increment step
	.(
		inc stage_restore_screen_step
		lda stage_restore_screen_step
		cmp #NUM_RESTORE_STEPS
		bne ok
			lda #$ff
			sta stage_restore_screen_step
		ok:
	.)

	rts

	top_attributes:
	.byt $23, $c0, $20
	.byt %00000000, %00000000, %00000000, %00000000, %00000000, %00000000, %01010000, %00000000
	.byt %00000000, %00000000, %00000000, %00000000, %00000000, %00000000, %00000000, %00000000
	.byt %00000000, %00000101, %10000000, %00000000, %10000000, %10100000, %00000000, %00000000
	.byt %00000000, %00000000, %00000000, %00000000, %00000000, %00000000, %00000000, %00000000
	bot_attibutes:
	.byt $23, $e0, $20
	.byt %00000000, %00001010, %00000000, %00000000, %00000000, %00000000, %00001010, %00000000
	.byt %00000000, %00000000, %00000010, %00000000, %00000000, %00001000, %00000000, %00000000
	.byt %01010000, %00010000, %00000000, %00000000, %00000000, %00000000, %01000000, %01010000
	.byt %00000101, %00000001, %00000000, %00000000, %00000000, %00000000, %00000100, %00000101

	steps_buffers_lsb:
	.byt <stage_skyride_palette_ntbuffer, <top_attributes, <bot_attibutes
	steps_buffers_msb:
	.byt >stage_skyride_palette_ntbuffer, >top_attributes, >bot_attibutes
	NUM_RESTORE_STEPS = *-steps_buffers_msb
.)

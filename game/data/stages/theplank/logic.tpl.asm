!define "stage_name" {stage_theplank}
!define "blastline_left" {STAGE_THEPLANK_BLAST_LEFT}
!define "blastline_right" {STAGE_THEPLANK_BLAST_RIGHT}
!define "blastline_top" {STAGE_THEPLANK_BLAST_TOP}
!define "blastline_bottom" {STAGE_THEPLANK_BLAST_BOTTOM}
!include "stages/std_stage_ringout.asm"
!undef "stage_name"

; Sets fadeout level
;  register X - fadeout level
;
; Overwrites registers, tmpfield1 to tmpfield4
+stage_theplank_fadeout:
.(
	; Set ideal fade level
	stx stage_fade_level

	; If not in rollback, apply it immediately
	lda network_rollback_mode
	beq apply_fadeout
		rts

	apply_fadeout:
	;Fallthrough to stage_theplank_fadeout_update
.)

; Rewrite palettes to match fadeout level
;  register X - fadeout level
;
; Overwrites registers, tmpfield1 to tmpfield4
stage_theplank_fadeout_update:
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

	lda stage_theplank_fadeout_lsb, x
	sta payload
	lda stage_theplank_fadeout_msb, x
	sta payload+1

	jmp construct_nt_buffer

	;rts ; useless, jump to subroutine

	palette_header:
	.byt $3f, $00, $10
.)

+stage_theplank_init:
.(
	; Disable screen restore
	lda #$ff
	sta stage_restore_screen_step
	lda #FADE_LEVEL_NORMAL
	sta stage_fade_level
	sta stage_current_fade_level
	rts
.)

+stage_theplank_tick:
.(
	; Falthrough to stage_theplank_repair_screen
.)

; Redraw the stage background (one step per call)
;  network_rollback_mode - set to inhibit any repair operation
;  stage_screen_effect - set to inhibit any repair operation
;  stage_fade_level - Desired fade level
;  stage_current_fade_level - Currently applied fade level
;  stage_restore_screen_step - Attributes restoration step (>= $80 to inhibit attributes restoration)
;
; Overwrites all registers, tmpfield1 to tmpfield4
stage_theplank_repair_screen:
.(
	; Do nothing in rollback mode
	.(
		lda network_rollback_mode
		beq ok
			rts
		ok:
	.)

	; Do nothing if a fullscreen animation is running
	.(
		lda stage_screen_effect
		beq ok
			rts
		ok:
	.)

	; Fix fadeout if needed
	;NOTE does not return if action is taken (to avoid flooding nametable buffers)
	.(
		ldx stage_fade_level
		cpx stage_current_fade_level
		beq ok
			jmp stage_theplank_fadeout_update
			;No return, jump to subroutine
		ok:
	.)

	; Fix attributes if needed
	.(
		; Do noting if there is no restore operation running
		.(
			ldx stage_restore_screen_step
			bpl ok
				rts
			ok:
		.)

		; Do nothing if there lack space for the nametable buffers
		.(
			IF_NT_BUFFERS_FREE_SPACE_LT(#1+3+32+1, ok)
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
	.)

	rts

	steps_buffers_lsb:
	.byt <stage_theplank_top_attributes, <stage_theplank_bot_attributes
	steps_buffers_msb:
	.byt >stage_theplank_top_attributes, >stage_theplank_bot_attributes
	NUM_RESTORE_STEPS = *-steps_buffers_msb
.)

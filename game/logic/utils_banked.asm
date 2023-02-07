+BANKED_UTILS_BANK_NUMBER = CURRENT_BANK_NUMBER

; Write solid tiles in background patterns
;
; Overwrites A, X
+write_solid_bg_tiles:
.(
	lda PPUSTATUS
	lda #$10
	sta PPUADDR
	lda #$00
	sta PPUADDR

	lda #$00
	ldx #16
	jsr ppu_fill

	lda #$ff
	ldx #8
	jsr ppu_fill

	lda #$00
	ldx #16
	jsr ppu_fill

	lda #$ff
	ldx #24
	jmp ppu_fill

	;rts ; useless, jump to subroutine
.)

; Lighten players avatars if the game engine didn't already ligtened one to handle same character + same skin situation
;  Overwrites all registers, extra_tmpfield1 to extra_tmpfield4
+stages_lighten_avatars:
.(
	lda config_player_a_character
	cmp config_player_b_character
	bne do_it
	lda config_player_a_character_palette
	cmp config_player_b_character_palette
	bne do_it
	rts
		do_it:
			ldx #0+4 ; Player A's normal palette, first color
			TRAMPOLINE(lighten_player_palette, #GAMESTATE_GAME_EXTRA_BANK, #CURRENT_BANK_NUMBER)
			ldx #16+4 ; Player B's normal palette, first color
			TRAMPOLINE(lighten_player_palette, #GAMESTATE_GAME_EXTRA_BANK, #CURRENT_BANK_NUMBER)
	rts
.)

; Initialization stuff specific to stages using the magma tileset
+stages_magma_init:
.(
	; Init background animation
	lda #0
	sta stages_magma_frame_cnt

	; Lighten avatars
	jmp stages_lighten_avatars

	;rts ; useless, jump to subroutine
.)

; Update background of magma stages (taking care of lava animation, and screen repairs)
;  tmpfield1, tmpfield3 - first restore step nametable buffer
;  tmpfield2, tmpfield4 - first restore step nametable buffer
;
; Overwrites all registers, tmpfield1 to tmpfield5
+stages_magma_update_background:
.(
	; Apply repair operation (and stop there if it had work to do)
	.(
		lda #1
		sta tmpfield5

		jsr stages_magma_repair_screen

		lda tmpfield5
		bne ok
			rts
		ok:
	.)

	; Do nothing if there is not enough space for lava tiles
	IF_NT_BUFFERS_FREE_SPACE_GE(#1+3+2+1, bg_update_ok)

		; Update lava
		.(
			; Update frame counter
			inc stages_magma_frame_cnt

			; Compute current animation frame frome counter
			lda #%0010000
			bit stages_magma_frame_cnt
			beq even_frame
				ldx #1
				jmp x_ok
			even_frame:
				ldx #0
			x_ok:

			; Get animation frame pointer
			lda lava_bg_frames_lsb, x
			sta tmpfield1
			lda lava_bg_frames_msb, x
			sta tmpfield2

			; Write nametable buffer
			.(
				; X points to last nametable buffer
				LAST_NT_BUFFER

				; Write buffer's header
				lda #1 ; Continuation byte
				sta nametable_buffers, x
				inx

				lda #$3f ; VRAM address MSB
				sta nametable_buffers, x
				inx

				lda #$02 ; VRAM address LSB
				sta nametable_buffers, x
				inx

				lda #$02 ; Payload size
				sta nametable_buffers, x
				inx

				; Y = offset in the frame of colors for the current fade level
				lda stage_fade_level
				asl
				tay

				; Write buffer's payload
				lda (tmpfield1), y
				sta nametable_buffers, x
				inx
				iny

				lda (tmpfield1), y
				sta nametable_buffers, x
				inx

				; Write stop byte
				lda #0
				sta nametable_buffers, x
				stx nt_buffers_end
			.)
		.)

	bg_update_ok:
	rts

	lava_color_frame0:
		.byt $0f, $0f ; black
		.byt $0f, $07 ; darkest
		.byt $06, $07 ; darker
		.byt $06, $17 ; dark
		.byt $17, $27 ; normal
	lava_color_frame1:
		.byt $0f, $0f ; black
		.byt $07, $0f ; darkest
		.byt $07, $06 ; darker
		.byt $17, $06 ; dark
		.byt $27, $17 ; normal
	lava_bg_frames_lsb:
		.byt <lava_color_frame0, <lava_color_frame1
	lava_bg_frames_msb:
		.byt >lava_color_frame0, >lava_color_frame1
.)

; Redraw the stage background (one step per call)
;  stage_screen_effect - set to inhibit any repair operation
;  stage_fade_level - Desired fade level
;  stage_current_fade_level - Currently applied fade level
;  stage_restore_screen_step - Attributes restoration step (>= $80 to inhibit attributes restoration)
;  tmpfield1, tmpfield3 - first restore step nametable buffer
;  tmpfield2, tmpfield4 - first restore step nametable buffer
;
; Output
;  tmpfield5 - Set to zero if a nametable buffer has been produced (untouched otherwise)
;
; Overwrites all registers, tmpfield1 to tmpfield5
+stages_magma_repair_screen:
.(
	steps_buffers_lsb = tmpfield1
	;tmpfield2
	steps_buffers_msb = tmpfield3
	;tmpfield4

	result = tmpfield5
	NUM_RESTORE_STEPS = 2

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
			ldy config_selected_stage
			TRAMPOLINE_POINTED(stage_routine_fadeout_lsb COMMA y, stage_routine_fadeout_msb COMMA y, stages_bank COMMA y, #CURRENT_BANK_NUMBER)
			lda #0
			sta result
			rts
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
			; Copy buffer pointer in tmpfield1+tmpfield2, and compute payload pointer in tmpfield3+tmpfield4
			;  Beware, overiding the table while reading it.
			;ldx stage_restore_screen_step ; useless, done above
			lda steps_buffers_lsb, x
			sta tmpfield1
			clc
			adc #3
			tay
			lda steps_buffers_msb, x
			sta tmpfield2
			adc #0
			sta tmpfield4
			sty tmpfield3

			ldx config_selected_stage
			TRAMPOLINE(construct_nt_buffer, stages_bank COMMA x, #CURRENT_BANK_NUMBER)

			lda #0
			sta result
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
.)

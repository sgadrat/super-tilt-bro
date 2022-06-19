.(
; Increment counter
; Overwrites A, X
+arcade_mode_inc_counter
.(
	; Avoid going over 9min 59sec, so minutes are always in one digit
	ldx system_index

	lda arcade_mode_counter_minutes
	cmp #9
	bne ok
		lda arcade_mode_counter_seconds
		cmp #59
		bne ok
			lda arcade_mode_counter_frames
			clc
			adc #1
			cmp framerate, x
			beq end
	ok:

	; Increment counter
	inc arcade_mode_counter_frames
	lda arcade_mode_counter_frames
	;ldx system_index ; useless, done above
	cmp framerate, x
	bne end

		lda #0
		sta arcade_mode_counter_frames

		inc arcade_mode_counter_seconds
		lda arcade_mode_counter_seconds
		cmp #60
		bne end

			lda #0
			sta arcade_mode_counter_seconds

			inc arcade_mode_counter_minutes

	end:
	rts

	framerate:
	.byt 60, 50
.)

+arcade_mode_display_counter:
.(
	COLON_TILE = TILE_EMPTY_STOCK_ICON
	DOT_TILE = TILE_EMPTY_STOCK_ICON

	POSITION_X = 3
	POSITION_Y = 3
	FIRST_DIGIT_PPU_ADDR = $2000+POSITION_Y*32+POSITION_X

	; Write buffer header
	jsr last_nt_buffer

	lda #1 ; continuation byte
	sta nametable_buffers, x
	inx

	lda #>(FIRST_DIGIT_PPU_ADDR) ; PPU address
	sta nametable_buffers, x
	inx
	lda #<(FIRST_DIGIT_PPU_ADDR)
	sta nametable_buffers, x
	inx

	lda #7 ; Tile count
	sta nametable_buffers, x
	inx

	; Write counter value
	ldy arcade_mode_counter_minutes
	lda base10_to_tile_low, y
	jsr set_one_tile

	lda #COLON_TILE
	jsr set_one_tile

	ldy arcade_mode_counter_seconds
	lda base10_to_tile_high, y
	jsr set_one_tile
	lda base10_to_tile_low, y
	jsr set_one_tile

	lda #DOT_TILE
	jsr set_one_tile

	ldy arcade_mode_counter_frames
	lda base10_to_tile_high, y
	jsr set_one_tile
	lda base10_to_tile_low, y
	jsr set_one_tile

	; Buffer stop byte
	lda #0
	sta nametable_buffers, x

	rts

	set_one_tile:
	.(
		sta nametable_buffers, x
		inx
		rts
	.)

	base10_to_tile_low:
	.byt TILE_CHAR_0+0, TILE_CHAR_0+1, TILE_CHAR_0+2, TILE_CHAR_0+3, TILE_CHAR_0+4, TILE_CHAR_0+5, TILE_CHAR_0+6, TILE_CHAR_0+7, TILE_CHAR_0+8, TILE_CHAR_0+9
	.byt TILE_CHAR_0+0, TILE_CHAR_0+1, TILE_CHAR_0+2, TILE_CHAR_0+3, TILE_CHAR_0+4, TILE_CHAR_0+5, TILE_CHAR_0+6, TILE_CHAR_0+7, TILE_CHAR_0+8, TILE_CHAR_0+9
	.byt TILE_CHAR_0+0, TILE_CHAR_0+1, TILE_CHAR_0+2, TILE_CHAR_0+3, TILE_CHAR_0+4, TILE_CHAR_0+5, TILE_CHAR_0+6, TILE_CHAR_0+7, TILE_CHAR_0+8, TILE_CHAR_0+9
	.byt TILE_CHAR_0+0, TILE_CHAR_0+1, TILE_CHAR_0+2, TILE_CHAR_0+3, TILE_CHAR_0+4, TILE_CHAR_0+5, TILE_CHAR_0+6, TILE_CHAR_0+7, TILE_CHAR_0+8, TILE_CHAR_0+9
	.byt TILE_CHAR_0+0, TILE_CHAR_0+1, TILE_CHAR_0+2, TILE_CHAR_0+3, TILE_CHAR_0+4, TILE_CHAR_0+5, TILE_CHAR_0+6, TILE_CHAR_0+7, TILE_CHAR_0+8, TILE_CHAR_0+9
	.byt TILE_CHAR_0+0, TILE_CHAR_0+1, TILE_CHAR_0+2, TILE_CHAR_0+3, TILE_CHAR_0+4, TILE_CHAR_0+5, TILE_CHAR_0+6, TILE_CHAR_0+7, TILE_CHAR_0+8, TILE_CHAR_0+9
	.byt TILE_CHAR_0+0, TILE_CHAR_0+1, TILE_CHAR_0+2, TILE_CHAR_0+3, TILE_CHAR_0+4, TILE_CHAR_0+5, TILE_CHAR_0+6, TILE_CHAR_0+7, TILE_CHAR_0+8, TILE_CHAR_0+9
	.byt TILE_CHAR_0+0, TILE_CHAR_0+1, TILE_CHAR_0+2, TILE_CHAR_0+3, TILE_CHAR_0+4, TILE_CHAR_0+5, TILE_CHAR_0+6, TILE_CHAR_0+7, TILE_CHAR_0+8, TILE_CHAR_0+9
	.byt TILE_CHAR_0+0, TILE_CHAR_0+1, TILE_CHAR_0+2, TILE_CHAR_0+3, TILE_CHAR_0+4, TILE_CHAR_0+5, TILE_CHAR_0+6, TILE_CHAR_0+7, TILE_CHAR_0+8, TILE_CHAR_0+9
	.byt TILE_CHAR_0+0, TILE_CHAR_0+1, TILE_CHAR_0+2, TILE_CHAR_0+3, TILE_CHAR_0+4, TILE_CHAR_0+5, TILE_CHAR_0+6, TILE_CHAR_0+7, TILE_CHAR_0+8, TILE_CHAR_0+9

	base10_to_tile_high:
	.byt TILE_CHAR_0+0, TILE_CHAR_0+0, TILE_CHAR_0+0, TILE_CHAR_0+0, TILE_CHAR_0+0, TILE_CHAR_0+0, TILE_CHAR_0+0, TILE_CHAR_0+0, TILE_CHAR_0+0, TILE_CHAR_0+0
	.byt TILE_CHAR_0+1, TILE_CHAR_0+1, TILE_CHAR_0+1, TILE_CHAR_0+1, TILE_CHAR_0+1, TILE_CHAR_0+1, TILE_CHAR_0+1, TILE_CHAR_0+1, TILE_CHAR_0+1, TILE_CHAR_0+1
	.byt TILE_CHAR_0+2, TILE_CHAR_0+2, TILE_CHAR_0+2, TILE_CHAR_0+2, TILE_CHAR_0+2, TILE_CHAR_0+2, TILE_CHAR_0+2, TILE_CHAR_0+2, TILE_CHAR_0+2, TILE_CHAR_0+2
	.byt TILE_CHAR_0+3, TILE_CHAR_0+3, TILE_CHAR_0+3, TILE_CHAR_0+3, TILE_CHAR_0+3, TILE_CHAR_0+3, TILE_CHAR_0+3, TILE_CHAR_0+3, TILE_CHAR_0+3, TILE_CHAR_0+3
	.byt TILE_CHAR_0+4, TILE_CHAR_0+4, TILE_CHAR_0+4, TILE_CHAR_0+4, TILE_CHAR_0+4, TILE_CHAR_0+4, TILE_CHAR_0+4, TILE_CHAR_0+4, TILE_CHAR_0+4, TILE_CHAR_0+4
	.byt TILE_CHAR_0+5, TILE_CHAR_0+5, TILE_CHAR_0+5, TILE_CHAR_0+5, TILE_CHAR_0+5, TILE_CHAR_0+5, TILE_CHAR_0+5, TILE_CHAR_0+5, TILE_CHAR_0+5, TILE_CHAR_0+5
	.byt TILE_CHAR_0+6, TILE_CHAR_0+6, TILE_CHAR_0+6, TILE_CHAR_0+6, TILE_CHAR_0+6, TILE_CHAR_0+6, TILE_CHAR_0+6, TILE_CHAR_0+6, TILE_CHAR_0+6, TILE_CHAR_0+6
	.byt TILE_CHAR_0+7, TILE_CHAR_0+7, TILE_CHAR_0+7, TILE_CHAR_0+7, TILE_CHAR_0+7, TILE_CHAR_0+7, TILE_CHAR_0+7, TILE_CHAR_0+7, TILE_CHAR_0+7, TILE_CHAR_0+7
	.byt TILE_CHAR_0+8, TILE_CHAR_0+8, TILE_CHAR_0+8, TILE_CHAR_0+8, TILE_CHAR_0+8, TILE_CHAR_0+8, TILE_CHAR_0+8, TILE_CHAR_0+8, TILE_CHAR_0+8, TILE_CHAR_0+8
	.byt TILE_CHAR_0+9, TILE_CHAR_0+9, TILE_CHAR_0+9, TILE_CHAR_0+9, TILE_CHAR_0+9, TILE_CHAR_0+9, TILE_CHAR_0+9, TILE_CHAR_0+9, TILE_CHAR_0+9, TILE_CHAR_0+9

.)
.)

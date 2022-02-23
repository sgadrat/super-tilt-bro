global_init:
.(
	prg_vector = tmpfield1

	; Initialize CHR-RAM
	; TODO to be removed once we successfuly got rid of CHR-BANK
	lda #CHR_BANK_NUMBER
	jsr switch_bank

	lda PPUSTATUS
	lda #$00
	sta PPUADDR
	sta PPUADDR

	sta prg_vector ; expect A to be zero
	lda #$80
	sta prg_vector+1

	ldy #0
	copy_one_page:
		copy_one_byte:
			lda (prg_vector), y
			sta PPUDATA

			iny
			bne copy_one_byte

		inc prg_vector+1
		lda prg_vector+1
		cmp #$a0
		bne copy_one_page

	; Set data bank
	;TODO check if still necessary (seems to be a leftover of NROM to UNROM512 conversion)
	lda #DATA_BANK_NUMBER
	jsr switch_bank

	; Initialize configuration
	jsr default_config

	; Enable music, but do not activate APU, it will be done when a music starts
	lda #$01
	sta audio_music_enabled

	; Network config
#ifndef NO_NETWORK
	lda #0 ; LOGIN_UNLOGGED
	sta network_logged
#endif

	rts
.)

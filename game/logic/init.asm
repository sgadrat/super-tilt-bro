global_init:
.(
	; Initialize configuration
	jsr default_config

	; Disable music
	lda #$00
	sta audio_music_enabled

	; Network config
#ifndef NO_NETWORK
	lda #0 ; LOGIN_UNLOGGED
	sta network_logged
#endif

	; Initialize menus to a default state
	lda #0
	sta menu_state_mode_selection_current_option

	rts
.)

; TODO to be removed once we successfuly got rid of CHR-BANK
init_chr_ram:
.(
	prg_vector = tmpfield1

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

	rts
.)

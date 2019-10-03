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

	; Copy common tiles in CHR-RAM
	.(
		tileset_addr = tmpfield1 ; Not movable, used by cpu_to_ppu_copy_tiles
		;tileset_addr_msb = tmpfield2 ; Not movable, used by cpu_to_ppu_copy_tiles
		tiles_count = tmpfield3 ; Not movable, used by cpu_to_ppu_copy_tiles

		lda #<(tileset_common+1)
		sta tileset_addr
		lda #>(tileset_common+1)
		sta tileset_addr+1

		SWITCH_BANK(#TILESET_COMMON_BANK_NUMBER)

		lda tileset_common
		sta tiles_count

		PPU_COMMON_TILES_ADDR = ($2000-(tileset_common_end-tileset_common_tiles))
		lda PPUSTATUS
		lda #>PPU_COMMON_TILES_ADDR
		sta PPUADDR
		lda #<PPU_COMMON_TILES_ADDR
		sta PPUADDR

		jsr cpu_to_ppu_copy_tiles
	.)

	; Set data bank
	;TODO check if still necessary (seems to be a leftover of NROM to UNROM512 conversion)
	lda #DATA_BANK_NUMBER
	jsr switch_bank

	; Initialize configuration
	jsr default_config

	; Enable music, but do not activate APU, it will be done when a music starts
	lda #$01
	sta audio_music_enabled

	rts
.)

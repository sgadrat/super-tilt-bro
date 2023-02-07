+cutscene_sinbad_story_dialog_encounter_utils_bank = CURRENT_BANK_NUMBER

solid_tileset_size = 4
sinbad_tileset_size = (cutscene_sinbad_story_sinbad_dialog_tileset_end-cutscene_sinbad_story_sinbad_dialog_tileset_tiles)/16
island_tileset_size = (cutscene_sinbad_story_common_island_tileset_end-cutscene_sinbad_story_common_island_tileset_tiles)/16
cloud_tileset_size = (tileset_new_cloud_end-tileset_new_cloud_tiles)/16
water_tileset_size = (cutscene_sinbad_story_common_water_tileset_end-cutscene_sinbad_story_common_water_tileset_tiles)/16

+sinbad_tiles_begin = solid_tileset_size
+island_tiles_begin = sinbad_tiles_begin + sinbad_tileset_size
+cloud_tiles_begin = island_tiles_begin + island_tileset_size
+water_tiles_begin = cloud_tiles_begin + cloud_tileset_size
+opponent_tiles_begin = water_tiles_begin + water_tileset_size

+cutscene_sinbad_story_dialog_encounter_init:
.(
	; Write solid tiles in patterns
	TRAMPOLINE(write_solid_bg_tiles, #BANKED_UTILS_BANK_NUMBER, #CURRENT_BANK_NUMBER)

	; Set alphanum charset at the end of tileset
	lda PPUSTATUS
	lda #$1d
	sta PPUADDR
	lda #$c0
	sta PPUADDR

	lda #<charset_alphanum
	sta tmpfield3
	lda #>charset_alphanum
	sta tmpfield4

	ldx #%00001100

	TRAMPOLINE(cpu_to_ppu_copy_charset, #CHARSET_ALPHANUM_BANK_NUMBER, #CURRENT_BANK_NUMBER)

	; Set symbols before alphanum in the tileset
	lda PPUSTATUS
	lda #$1c
	sta PPUADDR
	lda #$c0
	sta PPUADDR

	lda #<charset_symbols
	sta tmpfield3
	lda #>charset_symbols
	sta tmpfield4

	ldx #%00001100

	TRAMPOLINE(cpu_to_ppu_copy_charset, #CHARSET_SYMBOLS_BANK_NUMBER, #CURRENT_BANK_NUMBER)

	; Load shared background tilesets
	LOAD_TILESET(cutscene_sinbad_story_sinbad_dialog_tileset, CUTSCENE_SINBAD_STORY_SINBAD_DIALOG_BANK_NUMBER, $1000+sinbad_tiles_begin*16, CURRENT_BANK_NUMBER)
	LOAD_TILESET_REMAP(cutscene_sinbad_story_common_island_tileset, cutscene_sinbad_story_common_tilesets_bank, $1000+island_tiles_begin*16, #2, #1, #3, #2, CURRENT_BANK_NUMBER)
	LOAD_TILESET_REMAP(tileset_new_cloud, TILESET_NEW_CLOUD_BANK_NUMBER, $1000+cloud_tiles_begin*16, #2, #1, #2, #3, CURRENT_BANK_NUMBER)
	LOAD_TILESET(cutscene_sinbad_story_common_water_tileset, cutscene_sinbad_story_common_tilesets_bank, $1000+water_tiles_begin*16, CURRENT_BANK_NUMBER)

	rts
.)

+arcade_write_colon_tile:
.(
	lda PPUSTATUS
	lda #>($1000 + ARCADE_COLON_TILE * 16)
	sta PPUADDR
	lda #<($1000 + ARCADE_COLON_TILE * 16)
	sta PPUADDR

	lda #<char_colon
	sta tmpfield3
	lda #>char_colon
	sta tmpfield4

	lda #1
	sta tmpfield7
	ldx #CHARSET_COLOR(0,3)
	TRAMPOLINE(cpu_to_ppu_copy_charset_raw, #CHARSET_SYMBOLS_BANK_NUMBER, #CURRENT_BANK_NUMBER)

	rts
.)

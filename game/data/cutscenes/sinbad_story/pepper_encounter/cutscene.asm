+cutscene_sinbad_story_pepper_encounter_bank = CURRENT_BANK_NUMBER

bg_tileset_size = (cutscene_sinbad_story_pepper_encounter_bg_tileset_end-cutscene_sinbad_story_pepper_encounter_bg_tileset_tiles)/16
sinbad_tileset_size = (cutscene_sinbad_story_sinbad_dialog_tileset_end-cutscene_sinbad_story_sinbad_dialog_tileset_tiles)/16
pepper_tileset_size = (cutscene_sinbad_story_pepper_dialog_tileset_end-cutscene_sinbad_story_pepper_dialog_tileset_tiles)/16
island_tileset_size = (cutscene_sinbad_story_common_island_tileset_end-cutscene_sinbad_story_common_island_tileset_tiles)/16
cloud_tileset_size = (tileset_new_cloud_end-tileset_new_cloud_tiles)/16

sinbad_tiles_begin = bg_tileset_size
pepper_tiles_begin = sinbad_tiles_begin + sinbad_tileset_size
island_tiles_begin = pepper_tiles_begin + pepper_tileset_size
cloud_tiles_begin = island_tiles_begin + island_tileset_size
water_tiles_begin = cloud_tiles_begin + cloud_tileset_size

#include "game/data/cutscenes/sinbad_story/pepper_encounter/screen.asm"
#include "game/data/cutscenes/sinbad_story/pepper_encounter/tilesets.asm"

.(
+cutscene_sinbad_story_pepper_encounter:
.word cutscene_sinbad_story_pepper_encounter_palette ; palettes
.word cutscene_sinbad_story_pepper_encounter_nametable ; top nametable
.word cutscene_sinbad_story_pepper_encounter_nametable ; bottom nametable
.word cutscene_sinbad_story_pepper_encounter_bg_tileset ; background tileset
.word $ffff ; sprites tileset
.word cutscene_sinbad_story_pepper_encounter_logic ; scene script
.word cutscene_sinbad_story_pepper_encounter_init ; initialization routine

cutscene_sinbad_story_pepper_encounter_init:
.(
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
	LOAD_TILESET(cutscene_sinbad_story_sinbad_dialog_tileset, CUTSCENE_SINBAD_STORY_SINBAD_DIALOG_BANK_NUMBER, $1000+sinbad_tiles_begin*16)
	LOAD_TILESET(cutscene_sinbad_story_pepper_dialog_tileset, CUTSCENE_SINBAD_STORY_PEPPER_DIALOG_BANK_NUMBER, $1000+pepper_tiles_begin*16)
	LOAD_TILESET_REMAP(cutscene_sinbad_story_common_island_tileset, cutscene_sinbad_story_common_tilesets_bank, $1000+island_tiles_begin*16, #2, #1, #3, #2)
	LOAD_TILESET_REMAP(tileset_new_cloud, TILESET_NEW_CLOUD_BANK_NUMBER, $1000+cloud_tiles_begin*16, #2, #1, #2, #3)
	LOAD_TILESET(cutscene_sinbad_story_common_water_tileset, cutscene_sinbad_story_common_tilesets_bank, $1000+water_tiles_begin*16)

	rts
.)

cutscene_sinbad_story_pepper_encounter_logic:
.(
	SKIPPABLE_FRAMES(25)
	TEXT(3, 18, "                          ")
	TEXT(3, 19, "                  YOU     ")
	TEXT(3, 20, "                          ")
	DRAW_BUFFERS
	TEXT(3, 21, "                          ")
	TEXT(3, 22, "                          ")
	TEXT(3, 23, "                          ")
	DRAW_BUFFERS
	SKIPPABLE_FRAMES(25)
	TEXT(3, 18, "                          ")
	TEXT(3, 19, "                  YOU     ")
	TEXT(3, 20, "                 SHALL    ")
	DRAW_BUFFERS
	TEXT(3, 21, "                          ")
	TEXT(3, 22, "                          ")
	TEXT(3, 23, "                          ")
	DRAW_BUFFERS
	SKIPPABLE_FRAMES(25)
	TEXT(3, 18, "                          ")
	TEXT(3, 19, "                  YOU     ")
	TEXT(3, 20, "                 SHALL    ")
	DRAW_BUFFERS
	TEXT(3, 21, "                  NOT     ")
	TEXT(3, 22, "                          ")
	TEXT(3, 23, "                          ")
	DRAW_BUFFERS
	SKIPPABLE_FRAMES(25)
	TEXT(3, 18, "                          ")
	TEXT(3, 19, "                  YOU     ")
	TEXT(3, 20, "                 SHALL    ")
	DRAW_BUFFERS
	TEXT(3, 21, "                  NOT     ")
	TEXT(3, 22, "                 PASS!!!  ")
	TEXT(3, 23, "                          ")
	DRAW_BUFFERS
	SKIPPABLE_FRAMES(100)

	TEXT(3, 18, "                          ")
	TEXT(3, 19, "                  YOU     ")
	TEXT(3, 20, "                 SHALL    ")
	DRAW_BUFFERS
	TEXT(3, 21, "                  NOT     ")
	TEXT(3, 22, "                 PASS!!!  ")
	TEXT(3, 23, "Hey! that's not           ")
	DRAW_BUFFERS

	TEXT(3, 18, "                  YOU     ")
	TEXT(3, 19, "                 SHALL    ")
	TEXT(3, 20, "                  NOT     ")
	DRAW_BUFFERS
	TEXT(3, 21, "                 PASS!!!  ")
	TEXT(3, 22, "Hey! that's not           ")
	TEXT(3, 23, "your line!                ")
	DRAW_BUFFERS

	TEXT(3, 18, "                 SHALL    ")
	TEXT(3, 19, "                  NOT     ")
	TEXT(3, 20, "                 PASS!!!  ")
	DRAW_BUFFERS
	TEXT(3, 21, "Hey! that's not           ")
	TEXT(3, 22, "your line!                ")
	TEXT(3, 23, "                          ")
	DRAW_BUFFERS
	SKIPPABLE_FRAMES(100)

	TEXT(3, 18, "                 SHALL    ")
	TEXT(3, 19, "                  NOT     ")
	TEXT(3, 20, "                 PASS!!!  ")
	DRAW_BUFFERS
	TEXT(3, 21, "Hey! that's not           ")
	TEXT(3, 22, "your line!                ")
	TEXT(3, 23, "              No, but this")
	DRAW_BUFFERS

	TEXT(3, 18, "                  NOT     ")
	TEXT(3, 19, "                 PASS!!!  ")
	TEXT(3, 20, "Hey! that's not           ")
	DRAW_BUFFERS
	TEXT(3, 21, "your line!                ")
	TEXT(3, 22, "              No, but this")
	TEXT(3, 23, "              cake is mine")
	DRAW_BUFFERS

	TEXT(3, 18, "                 PASS!!!  ")
	TEXT(3, 19, "Hey! that's not           ")
	TEXT(3, 20, "your line!                ")
	DRAW_BUFFERS
	TEXT(3, 21, "              No, but this")
	TEXT(3, 22, "              cake is mine")
	TEXT(3, 23, "                          ")
	DRAW_BUFFERS
	SKIPPABLE_FRAMES(150)
	rts
.)
.)

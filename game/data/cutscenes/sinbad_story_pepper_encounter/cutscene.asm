+cutscene_sinbad_story_pepper_encounter_bank = CURRENT_BANK_NUMBER

#include "game/data/cutscenes/sinbad_story_pepper_encounter/screen.asm"
#include "game/data/cutscenes/sinbad_story_pepper_encounter/tilesets.asm"

.(
+cutscene_sinbad_story_pepper_encounter:
.word cutscene_sinbad_story_pepper_encounter_palette ; palettes
.word cutscene_sinbad_story_pepper_encounter_nametable ; top nametable
.word cutscene_sinbad_story_pepper_encounter_nametable ; bottom nametable
.word cutscene_sinbad_story_pepper_encounter_bg_tileset ; background tileset
.word cutscene_sinbad_story_pepper_encounter_bg_tileset ; sprites tileset
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

	rts
.)

cutscene_sinbad_story_pepper_encounter_logic:
.(
	SKIPPABLE_FRAMES(25)
	TEXT(3, 18, "                          ")
	TEXT(3, 19, "                  YOU     ")
	TEXT(3, 20, "                          ")
	PLAY_FRAMES(1)
	TEXT(3, 21, "                          ")
	TEXT(3, 22, "                          ")
	TEXT(3, 23, "                          ")
	SKIPPABLE_FRAMES(25)
	TEXT(3, 18, "                          ")
	TEXT(3, 19, "                  YOU     ")
	TEXT(3, 20, "                 SHALL    ")
	PLAY_FRAMES(1)
	TEXT(3, 21, "                          ")
	TEXT(3, 22, "                          ")
	TEXT(3, 23, "                          ")
	SKIPPABLE_FRAMES(25)
	TEXT(3, 18, "                          ")
	TEXT(3, 19, "                  YOU     ")
	TEXT(3, 20, "                 SHALL    ")
	PLAY_FRAMES(1)
	TEXT(3, 21, "                  NOT     ")
	TEXT(3, 22, "                          ")
	TEXT(3, 23, "                          ")
	SKIPPABLE_FRAMES(25)
	TEXT(3, 18, "                          ")
	TEXT(3, 19, "                  YOU     ")
	TEXT(3, 20, "                 SHALL    ")
	PLAY_FRAMES(1)
	TEXT(3, 21, "                  NOT     ")
	TEXT(3, 22, "                 PASS!!!  ")
	TEXT(3, 23, "                          ")
	SKIPPABLE_FRAMES(100)

	TEXT(3, 18, "                          ")
	TEXT(3, 19, "                  YOU     ")
	TEXT(3, 20, "                 SHALL    ")
	PLAY_FRAMES(1)
	TEXT(3, 21, "                  NOT     ")
	TEXT(3, 22, "                 PASS!!!  ")
	TEXT(3, 23, "Hey! that's not           ")
	PLAY_FRAMES(1)

	TEXT(3, 18, "                  YOU     ")
	TEXT(3, 19, "                 SHALL    ")
	TEXT(3, 20, "                  NOT     ")
	PLAY_FRAMES(1)
	TEXT(3, 21, "                 PASS!!!  ")
	TEXT(3, 22, "Hey! that's not           ")
	TEXT(3, 23, "your line!                ")
	PLAY_FRAMES(1)

	TEXT(3, 18, "                 SHALL    ")
	TEXT(3, 19, "                  NOT     ")
	TEXT(3, 20, "                 PASS!!!  ")
	PLAY_FRAMES(1)
	TEXT(3, 21, "Hey! that's not           ")
	TEXT(3, 22, "your line!                ")
	TEXT(3, 23, "                          ")
	SKIPPABLE_FRAMES(100)

	TEXT(3, 18, "                 SHALL    ")
	TEXT(3, 19, "                  NOT     ")
	TEXT(3, 20, "                 PASS!!!  ")
	PLAY_FRAMES(1)
	TEXT(3, 21, "Hey! that's not           ")
	TEXT(3, 22, "your line!                ")
	TEXT(3, 23, "              No, but this")
	PLAY_FRAMES(1)

	TEXT(3, 18, "                  NOT     ")
	TEXT(3, 19, "                 PASS!!!  ")
	TEXT(3, 20, "Hey! that's not           ")
	PLAY_FRAMES(1)
	TEXT(3, 21, "your line!                ")
	TEXT(3, 22, "              No, but this")
	TEXT(3, 23, "              cake is mine")
	PLAY_FRAMES(1)

	TEXT(3, 18, "                 PASS!!!  ")
	TEXT(3, 19, "Hey! that's not           ")
	TEXT(3, 20, "your line!                ")
	PLAY_FRAMES(1)
	TEXT(3, 21, "              No, but this")
	TEXT(3, 22, "              cake is mine")
	TEXT(3, 23, "                          ")
	PLAY_FRAMES(1)
	SKIPPABLE_FRAMES(150)
	rts
.)
.)

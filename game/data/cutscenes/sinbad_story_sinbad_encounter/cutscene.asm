+cutscene_sinbad_story_sinbad_encounter_bank = CURRENT_BANK_NUMBER

#include "game/data/cutscenes/sinbad_story_sinbad_encounter/screen.asm"
#include "game/data/cutscenes/sinbad_story_sinbad_encounter/tilesets.asm"

.(
+cutscene_sinbad_story_sinbad_encounter:
.word cutscene_sinbad_story_sinbad_encounter_palette ; palettes
.word cutscene_sinbad_story_sinbad_encounter_nametable ; top nametable
.word cutscene_sinbad_story_sinbad_encounter_nametable ; bottom nametable
.word cutscene_sinbad_story_sinbad_encounter_bg_tileset ; background tileset
.word cutscene_sinbad_story_sinbad_encounter_bg_tileset ; sprites tileset
.word cutscene_sinbad_story_sinbad_encounter_logic ; scene script
.word cutscene_sinbad_story_sinbad_encounter_init ; initialization routine

cutscene_sinbad_story_sinbad_encounter_init:
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

	ldx #%00001000

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

	ldx #%00001000

	TRAMPOLINE(cpu_to_ppu_copy_charset, #CHARSET_SYMBOLS_BANK_NUMBER, #CURRENT_BANK_NUMBER)

	rts
.)

cutscene_sinbad_story_sinbad_encounter_logic:
.(
	SKIPPABLE_FRAMES(25)
	TEXT(3, 18, "                          ")
	TEXT(3, 19, "             Hey! Sinbad! ")
	TEXT(3, 20, "                          ")
	PLAY_FRAMES(1)
	TEXT(3, 21, "                          ")
	TEXT(3, 22, "                          ")
	TEXT(3, 23, "                          ")
	SKIPPABLE_FRAMES(100)

	TEXT(3, 18, "                          ")
	TEXT(3, 19, "             Hey! Sinbad! ")
	TEXT(3, 20, "Hmm. Me?                  ")
	PLAY_FRAMES(1)
	TEXT(3, 21, "                          ")
	TEXT(3, 22, "                          ")
	TEXT(3, 23, "                          ")
	SKIPPABLE_FRAMES(100)

	TEXT(3, 18, "                          ")
	TEXT(3, 19, "             Hey! Sinbad! ")
	TEXT(3, 20, "Hmm. Me?                  ")
	PLAY_FRAMES(1)
	TEXT(3, 21, "             I am your    ")
	TEXT(3, 22, "             conscience...")
	TEXT(3, 23, "                          ")
	SKIPPABLE_FRAMES(100)

	TEXT(3, 18, "             Hey! Sinbad! ")
	TEXT(3, 19, "Hmm. Me?                  ")
	TEXT(3, 20, "             I am your    ")
	PLAY_FRAMES(1)
	TEXT(3, 21, "             conscience...")
	TEXT(3, 22, "                          ")
	TEXT(3, 23, "             You are on   ")
	PLAY_FRAMES(1)

	TEXT(3, 18, "Hmm. Me?                  ")
	TEXT(3, 19, "             I am your    ")
	TEXT(3, 20, "             conscience...")
	PLAY_FRAMES(1)
	TEXT(3, 21, "                          ")
	TEXT(3, 22, "             You are on   ")
	TEXT(3, 23, "             diet!        ")
	PLAY_FRAMES(1)

	TEXT(3, 18, "             I am your    ")
	TEXT(3, 19, "             conscience...")
	TEXT(3, 20, "                          ")
	PLAY_FRAMES(1)
	TEXT(3, 21, "             You are on   ")
	TEXT(3, 22, "             diet!        ")
	TEXT(3, 23, "                          ")
	SKIPPABLE_FRAMES(100)

	TEXT(3, 18, "             I am your    ")
	TEXT(3, 19, "             conscience...")
	TEXT(3, 20, "                          ")
	PLAY_FRAMES(1)
	TEXT(3, 21, "             You are on   ")
	TEXT(3, 22, "             diet!        ")
	TEXT(3, 23, "I need this               ")
	PLAY_FRAMES(1)

	TEXT(3, 18, "             conscience...")
	TEXT(3, 19, "                          ")
	TEXT(3, 20, "             You are on   ")
	PLAY_FRAMES(1)
	TEXT(3, 21, "             diet!        ")
	TEXT(3, 22, "I need this               ")
	TEXT(3, 23, "cake.                     ")
	PLAY_FRAMES(1)

	TEXT(3, 18, "                          ")
	TEXT(3, 19, "             You are on   ")
	TEXT(3, 20, "             diet!        ")
	PLAY_FRAMES(1)
	TEXT(3, 21, "I need this               ")
	TEXT(3, 22, "cake.                     ")
	TEXT(3, 23, "                          ")
	SKIPPABLE_FRAMES(100)

	TEXT(3, 18, "             You are on   ")
	TEXT(3, 19, "             diet!        ")
	TEXT(3, 20, "I need this               ")
	PLAY_FRAMES(1)
	TEXT(3, 21, "cake.                     ")
	TEXT(3, 22, "                          ")
	TEXT(3, 23, "let me go,                ")
	PLAY_FRAMES(1)

	TEXT(3, 18, "             diet!        ")
	TEXT(3, 19, "I need this               ")
	TEXT(3, 20, "cake.                     ")
	PLAY_FRAMES(1)
	TEXT(3, 21, "                          ")
	TEXT(3, 22, "let me go,                ")
	TEXT(3, 23, "ghost-me!                 ")
	PLAY_FRAMES(1)

	TEXT(3, 18, "I need this               ")
	TEXT(3, 19, "cake.                     ")
	TEXT(3, 20, "                          ")
	PLAY_FRAMES(1)
	TEXT(3, 21, "let me go,                ")
	TEXT(3, 22, "ghost-me!                 ")
	TEXT(3, 23, "                          ")
	SKIPPABLE_FRAMES(150)
	rts
.)
.)

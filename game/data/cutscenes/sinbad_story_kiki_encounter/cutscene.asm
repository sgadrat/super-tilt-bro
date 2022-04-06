cutscene_sinbad_story_kiki_encounter_bank = CURRENT_BANK_NUMBER

#include "game/data/cutscenes/sinbad_story_kiki_encounter/screen.asm"
#include "game/data/cutscenes/sinbad_story_kiki_encounter/tilesets.asm"

.(
&cutscene_sinbad_story_kiki_encounter:
.word cutscene_sinbad_story_kiki_encounter_palette ; palettes
.word cutscene_sinbad_story_kiki_encounter_nametable ; top nametable
.word cutscene_sinbad_story_kiki_encounter_nametable ; bottom nametable
.word cutscene_sinbad_story_kiki_encounter_bg_tileset ; background tileset
.word cutscene_sinbad_story_kiki_encounter_bg_tileset ; sprites tileset
.word cutscene_sinbad_story_kiki_encounter_logic ; scene script
.word cutscene_sinbad_story_kiki_encounter_init ; initialization routine

cutscene_sinbad_story_kiki_encounter_init:
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

cutscene_sinbad_story_kiki_encounter_logic:
.(
	SKIPPABLE_FRAMES(25)
	TEXT(15, 19, "Saluton amiko!")
	SKIPPABLE_FRAMES(100)
	TEXT(3, 21, "Maybe a")
	TEXT(3, 22, "weird private joke.")
	SKIPPABLE_FRAMES(100)
	TEXT(15, 18, "Saluton amiko!")
	TEXT(3, 20, "Maybe a")
	TEXT(3, 21, "weird private joke.")
	PLAY_FRAMES(1)
	TEXT(15, 19, "              ")
	TEXT(3, 22, "                   ")
	TEXT(3, 23, "No time for that")
	PLAY_FRAMES(1)
	TEXT(15, 18, "              ")
	TEXT(3, 19, "Maybe a")
	TEXT(3, 20, "weird private joke.")
	TEXT(3, 21, "                   ")
	TEXT(3, 22, "No time for that")
	TEXT(3, 23, "I'll force the way!")
	SKIPPABLE_FRAMES(150)
	rts
.)
.)

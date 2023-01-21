+cutscene_sinbad_story_kiki_encounter_bank = CURRENT_BANK_NUMBER

kiki_tiles_begin = opponent_tiles_begin

#include "game/data/cutscenes/sinbad_story/kiki_encounter/screen.built.asm"
#include "game/data/cutscenes/sinbad_story/kiki_encounter/tilesets.asm"

.(
+cutscene_sinbad_story_kiki_encounter:
.word cutscene_sinbad_story_kiki_encounter_palette ; palettes
.word cutscene_sinbad_story_kiki_encounter_nametable ; top nametable
.word cutscene_sinbad_story_kiki_encounter_nametable ; bottom nametable
.word cutscene_sinbad_story_kiki_encounter_bg_tileset ; background tileset
.word $ffff ; sprites tileset
.word cutscene_sinbad_story_kiki_encounter_logic ; scene script
.word cutscene_sinbad_story_kiki_encounter_init ; initialization routine

cutscene_sinbad_story_kiki_encounter_init:
.(
	TRAMPOLINE(cutscene_sinbad_story_dialog_encounter_init, #cutscene_sinbad_story_dialog_encounter_utils_bank, #CURRENT_BANK_NUMBER)
	LOAD_TILESET(cutscene_sinbad_story_kiki_dialog_tileset, CUTSCENE_SINBAD_STORY_KIKI_DIALOG_BANK_NUMBER, $1000+kiki_tiles_begin*16)
	rts
.)

cutscene_sinbad_story_kiki_encounter_logic:
.(
	SKIPPABLE_FRAMES(25)
	TEXT(15, 19, "Saluton amiko!")
	SKIPPABLE_FRAMES(100)
	TEXT(3, 21, "Maybe a")
	TEXT(3, 22, "weird private joke.")
	DRAW_BUFFERS
	SKIPPABLE_FRAMES(99)
	TEXT(15, 18, "Saluton amiko!")
	TEXT(3, 20, "Maybe a")
	TEXT(3, 21, "weird private joke.")
	DRAW_BUFFERS
	TEXT(15, 19, "              ")
	TEXT(3, 22, "                   ")
	TEXT(3, 23, "No time for that")
	DRAW_BUFFERS
	TEXT(15, 18, "              ")
	TEXT(3, 19, "Maybe a")
	TEXT(3, 20, "weird private joke.")
	TEXT(3, 21, "                   ")
	TEXT(3, 22, "No time for that")
	TEXT(3, 23, "I'll force the way!")
	DRAW_BUFFERS
	SKIPPABLE_FRAMES(149)
	rts
.)
.)

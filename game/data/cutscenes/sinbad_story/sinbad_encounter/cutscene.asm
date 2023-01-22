+cutscene_sinbad_story_sinbad_encounter_bank = CURRENT_BANK_NUMBER

#include "game/data/cutscenes/sinbad_story/sinbad_encounter/screen.built.asm"

.(
+cutscene_sinbad_story_sinbad_encounter:
.word cutscene_sinbad_story_sinbad_encounter_palette ; palettes
.word cutscene_sinbad_story_sinbad_encounter_nametable ; top nametable
.word cutscene_sinbad_story_sinbad_encounter_nametable ; bottom nametable
.word $ffff ; background tileset
.word $ffff ; sprites tileset
.word cutscene_sinbad_story_sinbad_encounter_logic ; scene script
.word cutscene_sinbad_story_sinbad_encounter_init ; initialization routine

cutscene_sinbad_story_sinbad_encounter_init:
.(
	TRAMPOLINE(cutscene_sinbad_story_dialog_encounter_init, #cutscene_sinbad_story_dialog_encounter_utils_bank, #CURRENT_BANK_NUMBER)
	LOAD_TILESET_FLIP(cutscene_sinbad_story_sinbad_dialog_tileset, CUTSCENE_SINBAD_STORY_SINBAD_DIALOG_BANK_NUMBER, $1000+opponent_tiles_begin*16)
	rts
.)

cutscene_sinbad_story_sinbad_encounter_logic:
.(
	SKIPPABLE_FRAMES(25)
	TEXT(3, 18, "                          ")
	TEXT(3, 19, "             Hey! Sinbad! ")
	TEXT(3, 20, "                          ")
	DRAW_BUFFERS
	TEXT(3, 21, "                          ")
	TEXT(3, 22, "                          ")
	TEXT(3, 23, "                          ")
	SKIPPABLE_FRAMES(100)

	TEXT(3, 18, "                          ")
	TEXT(3, 19, "             Hey! Sinbad! ")
	TEXT(3, 20, "Hmm. Me?                  ")
	DRAW_BUFFERS
	TEXT(3, 21, "                          ")
	TEXT(3, 22, "                          ")
	TEXT(3, 23, "                          ")
	SKIPPABLE_FRAMES(100)

	TEXT(3, 18, "                          ")
	TEXT(3, 19, "             Hey! Sinbad! ")
	TEXT(3, 20, "Hmm. Me?                  ")
	DRAW_BUFFERS
	TEXT(3, 21, "             I am your    ")
	TEXT(3, 22, "             conscience...")
	TEXT(3, 23, "                          ")
	SKIPPABLE_FRAMES(100)

	TEXT(3, 18, "             Hey! Sinbad! ")
	TEXT(3, 19, "Hmm. Me?                  ")
	TEXT(3, 20, "             I am your    ")
	DRAW_BUFFERS
	TEXT(3, 21, "             conscience...")
	TEXT(3, 22, "                          ")
	TEXT(3, 23, "             You are on   ")
	DRAW_BUFFERS

	TEXT(3, 18, "Hmm. Me?                  ")
	TEXT(3, 19, "             I am your    ")
	TEXT(3, 20, "             conscience...")
	DRAW_BUFFERS
	TEXT(3, 21, "                          ")
	TEXT(3, 22, "             You are on   ")
	TEXT(3, 23, "             diet!        ")
	DRAW_BUFFERS

	TEXT(3, 18, "             I am your    ")
	TEXT(3, 19, "             conscience...")
	TEXT(3, 20, "                          ")
	DRAW_BUFFERS
	TEXT(3, 21, "             You are on   ")
	TEXT(3, 22, "             diet!        ")
	TEXT(3, 23, "                          ")
	SKIPPABLE_FRAMES(100)

	TEXT(3, 18, "             I am your    ")
	TEXT(3, 19, "             conscience...")
	TEXT(3, 20, "                          ")
	DRAW_BUFFERS
	TEXT(3, 21, "             You are on   ")
	TEXT(3, 22, "             diet!        ")
	TEXT(3, 23, "I need this               ")
	DRAW_BUFFERS

	TEXT(3, 18, "             conscience...")
	TEXT(3, 19, "                          ")
	TEXT(3, 20, "             You are on   ")
	DRAW_BUFFERS
	TEXT(3, 21, "             diet!        ")
	TEXT(3, 22, "I need this               ")
	TEXT(3, 23, "cake.                     ")
	DRAW_BUFFERS

	TEXT(3, 18, "                          ")
	TEXT(3, 19, "             You are on   ")
	TEXT(3, 20, "             diet!        ")
	DRAW_BUFFERS
	TEXT(3, 21, "I need this               ")
	TEXT(3, 22, "cake.                     ")
	TEXT(3, 23, "                          ")
	SKIPPABLE_FRAMES(100)

	TEXT(3, 18, "             You are on   ")
	TEXT(3, 19, "             diet!        ")
	TEXT(3, 20, "I need this               ")
	DRAW_BUFFERS
	TEXT(3, 21, "cake.                     ")
	TEXT(3, 22, "                          ")
	TEXT(3, 23, "let me go,                ")
	DRAW_BUFFERS

	TEXT(3, 18, "             diet!        ")
	TEXT(3, 19, "I need this               ")
	TEXT(3, 20, "cake.                     ")
	DRAW_BUFFERS
	TEXT(3, 21, "                          ")
	TEXT(3, 22, "let me go,                ")
	TEXT(3, 23, "ghost-me!                 ")
	DRAW_BUFFERS

	TEXT(3, 18, "I need this               ")
	TEXT(3, 19, "cake.                     ")
	TEXT(3, 20, "                          ")
	DRAW_BUFFERS
	TEXT(3, 21, "let me go,                ")
	TEXT(3, 22, "ghost-me!                 ")
	TEXT(3, 23, "                          ")
	SKIPPABLE_FRAMES(150)
	rts
.)
.)

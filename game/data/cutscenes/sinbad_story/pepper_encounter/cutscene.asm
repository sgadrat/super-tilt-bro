+cutscene_sinbad_story_pepper_encounter_bank = CURRENT_BANK_NUMBER

pepper_tiles_begin = opponent_tiles_begin
pepper_tileset_size = (cutscene_sinbad_story_pepper_dialog_tileset_end-cutscene_sinbad_story_pepper_dialog_tileset_tiles)/16

#include "game/data/cutscenes/sinbad_story/pepper_encounter/screen.built.asm"

.(
+cutscene_sinbad_story_pepper_encounter:
.word cutscene_sinbad_story_pepper_encounter_palette ; palettes
.word cutscene_sinbad_story_pepper_encounter_nametable ; top nametable
.word cutscene_sinbad_story_pepper_encounter_nametable ; bottom nametable
.word $ffff ; background tileset
.word $ffff ; sprites tileset
.word cutscene_sinbad_story_pepper_encounter_logic ; scene script
.word cutscene_sinbad_story_pepper_encounter_init ; initialization routine

reenable_music = cutscene_flags

cutscene_sinbad_story_pepper_encounter_init:
.(
	TRAMPOLINE(cutscene_sinbad_story_dialog_encounter_init, #cutscene_sinbad_story_dialog_encounter_utils_bank, #CURRENT_BANK_NUMBER)
	LOAD_TILESET(cutscene_sinbad_story_pepper_dialog_tileset, CUTSCENE_SINBAD_STORY_PEPPER_DIALOG_BANK_NUMBER, $1000+pepper_tiles_begin*16, CURRENT_BANK_NUMBER)
	rts
.)

start_pepper_music:
.(
	; Start Pepper theme
	LOAD_MUSIC(music_adventure_info, music_adventure_bank)

	; Unmute music if config allows
	lda reenable_music
	beq ok
		jsr audio_unmute_music
	ok:

	; Unset reenable flag
	lda #0
	sta reenable_music

	rts
.)

cutscene_sinbad_story_pepper_encounter_logic:
.(
	; Real script is in cutscene_sinbad_story_pepper_encounter_logic_script
	; This method is a wrapper around it,
	; handling reenabling music if the cutscene has been skipped before

	lda audio_music_enabled
	sta reenable_music

	jsr cutscene_sinbad_story_pepper_encounter_logic_script

	lda reenable_music
	bne start_pepper_music ;NOTE bne to another routine

	rts
.)

cutscene_sinbad_story_pepper_encounter_logic_script:
.(
	jsr audio_mute_music
	; Pepper music
	;OAD_MUSIC(music_adventure_info, music_adventure_bank)

	SKIPPABLE_FRAMES(25)

	PLAY_SFX(SFX_HIT_IDX)
	TEXT(3, 18, "                          ")
	TEXT(3, 19, "                  YOU     ")
	TEXT(3, 20, "                          ")
	DRAW_BUFFERS
	TEXT(3, 21, "                          ")
	TEXT(3, 22, "                          ")
	TEXT(3, 23, "                          ")
	DRAW_BUFFERS
	SKIPPABLE_FRAMES(25)

	PLAY_SFX(SFX_HIT_IDX)
	TEXT(3, 18, "                          ")
	TEXT(3, 19, "                  YOU     ")
	TEXT(3, 20, "                 SHALL    ")
	DRAW_BUFFERS
	TEXT(3, 21, "                          ")
	TEXT(3, 22, "                          ")
	TEXT(3, 23, "                          ")
	DRAW_BUFFERS
	SKIPPABLE_FRAMES(25)

	PLAY_SFX(SFX_HIT_IDX)
	TEXT(3, 18, "                          ")
	TEXT(3, 19, "                  YOU     ")
	TEXT(3, 20, "                 SHALL    ")
	DRAW_BUFFERS
	TEXT(3, 21, "                  NOT     ")
	TEXT(3, 22, "                          ")
	TEXT(3, 23, "                          ")
	DRAW_BUFFERS
	SKIPPABLE_FRAMES(25)

	PLAY_SFX(SFX_SHIELD_BREAK_IDX)
	CUTS_SCREEN_SHAKE(25, 10, 0)
	TEXT(3, 18, "                          ")
	TEXT(3, 19, "                  YOU     ")
	TEXT(3, 20, "                 SHALL    ")
	DRAW_BUFFERS
	TEXT(3, 21, "                  NOT     ")
	TEXT(3, 22, "                 PASS!!!  ")
	TEXT(3, 23, "                          ")
	DRAW_BUFFERS
	SKIPPABLE_FRAMES(50)

	jsr start_pepper_music
	SKIPPABLE_FRAMES(25)

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

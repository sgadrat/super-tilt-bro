+JUKEBOX_SCREEN_EXTRA_CODE_BANK_NUMBER = CURRENT_BANK_NUMBER

jukebox_themes_lsb:
	.byt <music_title_info
	.byt <music_perihelium_info
	.byt <music_sinbad_info
	.byt <music_adventure_info
	.byt <music_volcano_info
	.byt <music_kiki_info
	.byt <music_jump_rope_info
	.byt <music_sinbad2_info
	.byt <music_pepper_info
jukebox_themes_msb:
	.byt >music_title_info
	.byt >music_perihelium_info
	.byt >music_sinbad_info
	.byt >music_adventure_info
	.byt >music_volcano_info
	.byt >music_kiki_info
	.byt >music_jump_rope_info
	.byt >music_sinbad2_info
	.byt >music_pepper_info
jukebox_themes_bank:
	.byt music_title_bank
	.byt music_perihelium_bank
	.byt music_sinbad_bank
	.byt music_adventure_bank
	.byt music_volcano_bank
	.byt music_kiki_bank
	.byt music_jump_rope_bank
	.byt music_sinbad2_bank
	.byt music_pepper_bank
jukebox_themes_title:
	.asc "Super Tilt Bro. "
	.asc "Perihelium      "
	.asc "Sinbad theme    "
	.asc "Adventure       "
	.asc "Volcano         "
	.asc "Kiki theme      "
	.asc "I Like Jump Rope"
	.asc "Sinbad theme    "
	.asc "Pepper theme    "
jukebox_themes_title_end:
jukebox_themes_author:
	.asc "Tui     "
	.asc "Ozzed   "
	.asc "Kilirane"
	.asc "Kilirane"
	.asc "Kilirane"
	.asc "Tui     "
	.asc "Ozzed   "
	.asc "Tui     "
	.asc "Tui     "
jukebox_themes_author_end:

LAST_JUKEBOX_TRACK = jukebox_themes_msb - jukebox_themes_lsb - 1
THEME_TITLE_LENGTH = (jukebox_themes_title_end - jukebox_themes_title) / (LAST_JUKEBOX_TRACK + 1)
THEME_AUTHOR_LENGTH = (jukebox_themes_author_end - jukebox_themes_author) / (LAST_JUKEBOX_TRACK + 1)

; Start playback of a specific theme
;  tmpfield1 - theme number
jukebox_play_music:
.(
	ldx tmpfield1
	lda jukebox_themes_lsb, x
	sta audio_current_track_lsb
	lda jukebox_themes_msb, x
	sta audio_current_track_msb
	lda jukebox_themes_bank, x
	sta audio_current_track_bank
	TRAMPOLINE(audio_play_music_direct, #0, #CURRENT_BANK_NUMBER)
	rts
.)

#include "game/logic/game_states/jukebox_screen/jukebox_screen.built.asm"

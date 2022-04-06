cutscene_sinbad_story_bird_msg_bank = CURRENT_BANK_NUMBER

#include "game/data/cutscenes/sinbad_story_bird_msg/screen.asm"
#include "game/data/cutscenes/sinbad_story_bird_msg/tilesets.asm"
#include "game/data/cutscenes/sinbad_story_bird_msg/anims.asm"

.(
&cutscene_sinbad_story_bird_msg:
.word cutscene_sinbad_story_bird_msg_palette
.word cutscene_sinbad_story_bird_msg_nametable
.word cutscene_sinbad_story_bird_msg_nametable2
.word cutscene_sinbad_story_bird_msg_bg_tileset
.word cutscene_sinbad_story_bird_msg_sprite_tileset
.word cutscene_sinbad_story_bird_msg_logic
.word dummy_routine

cutscene_sinbad_story_bird_msg_logic:
.(
	; Birb going to Sinbad
	INIT_ANIM(0, sinbad_anim_idle, SINBAD_BANK_NUMBER, DIRECTION_RIGHT2, 146, 127, 0, 0) ; index, anim, bank, direction, x, y, velocity_h, velocity_v
	INIT_ANIM(1, cutscene_sinbad_story_bird_msg_anim_bird, cutscene_sinbad_story_bird_msg_bank, DIRECTION_LEFT2, 200, 80, -$0040, $0040) ; index, anim, bank, direction, x, y, velocity_h, velocity_v
	PLAY_FRAMES(220) ; n_frames

	; Showing letter
	CLEAR_ANIM(0)
	CLEAR_ANIM(1)
	SET_PALETTE(0, $21, $27, $37)
	SET_PALETTE(1, $11, $27, $19)
	SET_PALETTE(2, $27, $37, $19)
	SET_PALETTE(3, $27, $37, $11)
	SET_SCREEN(2)
	PLAY_FRAMES(220)

	; Sinbad going to adventure
	INIT_ANIM(0, sinbad_anim_idle, SINBAD_BANK_NUMBER, DIRECTION_RIGHT2, 146, 127, $0100, 0) ; index, anim, bank, direction, x, y, velocity_h, velocity_v
	SET_PALETTE(0, $17, $11, $20)
	SET_PALETTE(1, $17, $21, $20)
	SET_SCREEN(0)
	AUTO_SCROLL(-1, 0)
	PLAY_FRAMES(4)

	AUTO_SCROLL(-2, 0)
	ANIM_VELOCITY(0, $0200, 0)
	PLAY_FRAMES(4)

	AUTO_SCROLL(-3, 0)
	ANIM_VELOCITY(0, $0300, 0)
	PLAY_FRAMES(4)

	AUTO_SCROLL(-4, 0)
	ANIM_VELOCITY(0, $0400, 0)
	lda #%10010100 ; set vertical PPU write increments
	sta ppuctrl_val
	PLAY_FRAMES(2)

	BG_UPDATE($20db, 18, empty_sea)
	PLAY_FRAMES(2)
	BG_UPDATE($20da, 18, empty_sea)
	PLAY_FRAMES(2)
	BG_UPDATE($20d9, 18, empty_sea)
	PLAY_FRAMES(2)
	BG_UPDATE($20d8, 18, empty_sea)
	PLAY_FRAMES(2)
	BG_UPDATE($20d7, 18, empty_sea)
	PLAY_FRAMES(2)
	BG_UPDATE($20d6, 18, empty_sea)
	PLAY_FRAMES(2)
	BG_UPDATE($20d5, 18, empty_sea)
	PLAY_FRAMES(2)
	BG_UPDATE($20d4, 18, empty_sea)
	PLAY_FRAMES(2)
	BG_UPDATE($20d3, 18, empty_sea)
	PLAY_FRAMES(2)
	BG_UPDATE($20d2, 18, empty_sea)
	PLAY_FRAMES(2)
	BG_UPDATE($20d1, 18, empty_sea)
	PLAY_FRAMES(2)
	BG_UPDATE($20d0, 18, empty_sea)
	PLAY_FRAMES(2)
	BG_UPDATE($20cf, 18, empty_sea)
	PLAY_FRAMES(2)
	BG_UPDATE($20ce, 18, empty_sea)
	PLAY_FRAMES(2)
	BG_UPDATE($20cd, 18, empty_sea)
	PLAY_FRAMES(2)
	BG_UPDATE($20cc, 18, empty_sea)
	PLAY_FRAMES(2)

	rts

	empty_sea:
		.byt $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01
.)
.)

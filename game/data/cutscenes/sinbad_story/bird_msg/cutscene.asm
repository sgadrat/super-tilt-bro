+cutscene_sinbad_story_bird_msg_bank = CURRENT_BANK_NUMBER

.(

sprites_tileset_size = (cutscene_sinbad_story_bird_msg_sprite_tileset_end-cutscene_sinbad_story_bird_msg_sprite_tileset_tiles)/16
island_tileset_size = (cutscene_sinbad_story_common_island_tileset_end-cutscene_sinbad_story_common_island_tileset_tiles)/16
bg_boat_tileset_size = (cutscene_sinbad_story_bird_msg_bg_boat_tileset_end-cutscene_sinbad_story_bird_msg_bg_boat_tileset_tiles)/16

#include "game/data/cutscenes/sinbad_story/bird_msg/screen.asm"
#include "game/data/cutscenes/sinbad_story/bird_msg/tilesets.asm"
#include "game/data/cutscenes/sinbad_story/bird_msg/anims.asm"

+cutscene_sinbad_story_bird_msg:
.word cutscene_sinbad_story_bird_msg_palette
.word cutscene_sinbad_story_bird_msg_boat_nametable
.word cutscene_sinbad_story_bird_msg_letter_nametable
.word cutscene_sinbad_story_bird_msg_bg_boat_tileset
.word $ffff ; sprites tileset ($ffff for not using a sprite tileset)
.word cutscene_sinbad_story_bird_msg_logic
.word cutscene_sinbad_story_bird_msg_init

cutscene_sinbad_story_bird_msg_init:
.(
	; Load sprites tiles (begin after character 1 animations tiles)
	LOAD_TILESET(cutscene_sinbad_story_bird_msg_sprite_tileset, cutscene_sinbad_story_bird_msg_bank, CHARACTERS_CHARACTER_B_TILES_OFFSET)
	LOAD_TILESET(cutscene_sinbad_story_common_island_tileset, cutscene_sinbad_story_common_tilesets_bank, CHARACTERS_CHARACTER_B_TILES_OFFSET+sprites_tileset_size*16)
	LOAD_TILESET(tileset_new_cloud, TILESET_NEW_CLOUD_BANK_NUMBER, CHARACTERS_CHARACTER_B_TILES_OFFSET+(sprites_tileset_size+island_tileset_size)*16)

	; Load background tiles from common tilesets
	LOAD_TILESET(cutscene_sinbad_story_common_water_tileset, cutscene_sinbad_story_common_tilesets_bank, $1000+bg_boat_tileset_size*16)

	rts
.)

cutscene_sinbad_story_bird_msg_boat_fadeout:
.(
#if 0
	; Original values (from screen.asm)
	SET_PALETTE(0, $0f,$17,$27):SET_PALETTE(1, $0f,$10,$20):SET_PALETTE(2, $11,$21,$20)
	SET_PALETTE(4, $08,$1a,$20):SET_PALETTE(5, $08,$10,$37):SET_PALETTE(6, $0f,$10,$20):SET_PALETTE(7, $07,$19,$00)
	CUTS_SET_BG_COLOR($21)
	PLAY_FRAMES(1)
#endif

	SET_PALETTE(0, $0f,$07,$17):SET_PALETTE(1, $0f,$00,$10):SET_PALETTE(2, $01,$11,$10)
	SET_PALETTE(4, $08,$0a,$10):SET_PALETTE(5, $08,$00,$27):SET_PALETTE(6, $0f,$00,$10):SET_PALETTE(7, $07,$09,$00)
	CUTS_SET_BG_COLOR($11)
	PLAY_FRAMES(1)

	SET_PALETTE(0, $0f,$07,$07):SET_PALETTE(1, $0f,$0f,$00):SET_PALETTE(2, $01,$01,$00)
	SET_PALETTE(4, $0f,$0f,$00):SET_PALETTE(5, $0f,$0f,$17):SET_PALETTE(6, $0f,$0f,$10):SET_PALETTE(7, $0f,$09,$0f)
	CUTS_SET_BG_COLOR($01)
	PLAY_FRAMES(1)

	SET_PALETTE(0, $0f,$0f,$07):SET_PALETTE(1, $0f,$0f,$0f):SET_PALETTE(2, $0f,$0f,$0f)
	SET_PALETTE(4, $0f,$0f,$0f):SET_PALETTE(5, $0f,$0f,$07):SET_PALETTE(6, $0f,$0f,$00):SET_PALETTE(7, $0f,$0f,$0f)
	CUTS_SET_BG_COLOR($0f)
	PLAY_FRAMES(1)

	rts
.)

cutscene_sinbad_story_bird_msg_logic:
.(
	; Birb going to Sinbad
	INIT_ANIM(0, cutscene_sinbad_story_bird_msg_anim_bird, cutscene_sinbad_story_bird_msg_bank, DIRECTION_LEFT2, 190, 80, -$0040, $0040) ; index, anim, bank, direction, x, y, velocity_h, velocity_v
	INIT_ANIM(1, sinbad_anim_idle, SINBAD_BANK_NUMBER, DIRECTION_RIGHT2, 146, 127, 0, 0) ; index, anim, bank, direction, x, y, velocity_h, velocity_v
	INIT_ANIM(2, cutscene_sinbad_story_bird_msg_anim_overlay_left, cutscene_sinbad_story_bird_msg_bank, DIRECTION_LEFT2, 128, 47, 0, 0) ; index, anim, bank, direction, x, y, velocity_h, velocity_v
	INIT_ANIM(3, cutscene_sinbad_story_bird_msg_anim_overlay_right, cutscene_sinbad_story_bird_msg_bank, DIRECTION_LEFT2, 128, 47, 0, 0) ; index, anim, bank, direction, x, y, velocity_h, velocity_v
	SKIPPABLE_FRAMES(160) ; n_frames

	; Fade out
	jsr cutscene_sinbad_story_bird_msg_boat_fadeout

	; Load letter tileset
	CLEAR_ANIM(0)
	CLEAR_ANIM(1)
	CLEAR_ANIM(2)
	CLEAR_ANIM(3)
	LOAD_TILESET_BG(cutscene_sinbad_story_bird_msg_bg_letter_tileset, cutscene_sinbad_story_bird_msg_bank)

	; Showing letter
	SET_PALETTE(0, $21,$27,$37):SET_PALETTE(1, $19,$21,$27):SET_PALETTE(2, $19,$27,$37)
	START_RENDERING(1, 0)
	SKIPPABLE_FRAMES(220)

	; Fade out
	SET_PALETTE(0, $11,$17,$27):SET_PALETTE(1, $09,$11,$17):SET_PALETTE(2, $09,$17,$17)
	PLAY_FRAMES(1)
	SET_PALETTE(0, $11,$17,$17):SET_PALETTE(1, $09,$11,$17):SET_PALETTE(2, $09,$17,$17)
	PLAY_FRAMES(1)
	SET_PALETTE(0, $01,$07,$07):SET_PALETTE(1, $09,$01,$07):SET_PALETTE(2, $09,$07,$07)
	PLAY_FRAMES(1)
	SET_PALETTE(0, $0f,$07,$07):SET_PALETTE(1, $0f,$0f,$07):SET_PALETTE(2, $0f,$0f,$07)
	PLAY_FRAMES(1)
	SET_PALETTE(0, $0f,$0f,$07):SET_PALETTE(1, $0f,$0f,$07):SET_PALETTE(2, $0f,$0f,$07)
	PLAY_FRAMES(1)

	; Sinbad going to adventure
	.(
		; Display boat scene
		LOAD_TILESET_BG(cutscene_sinbad_story_bird_msg_bg_boat_tileset, cutscene_sinbad_story_bird_msg_bank)
		LOAD_TILESET(cutscene_sinbad_story_common_water_tileset, cutscene_sinbad_story_common_tilesets_bank, $1000+bg_boat_tileset_size*16)

		INIT_ANIM(0, sinbad_anim_idle, SINBAD_BANK_NUMBER, DIRECTION_RIGHT2, 146, 127, $0100, 0) ; index, anim, bank, direction, x, y, velocity_h, velocity_v
		INIT_ANIM(2, cutscene_sinbad_story_bird_msg_anim_overlay_left, cutscene_sinbad_story_bird_msg_bank, DIRECTION_LEFT2, 128, 47, 0, 0) ; index, anim, bank, direction, x, y, velocity_h, velocity_v
		INIT_ANIM(3, cutscene_sinbad_story_bird_msg_anim_overlay_right, cutscene_sinbad_story_bird_msg_bank, DIRECTION_LEFT2, 128, 47, 0, 0) ; index, anim, bank, direction, x, y, velocity_h, velocity_v
		SET_PALETTE(0, $0f, $17, $27)
		SET_PALETTE(1, $0f, $10, $20)
		SET_PALETTE(2, $11, $21, $20)
		SET_PALETTE(4, $08, $1a, $20)
		SET_PALETTE(5, $08, $10, $37)
		SET_PALETTE(6, $0f, $10, $20)
		SET_PALETTE(7, $07, $19, $00)
		CUTS_SET_BG_COLOR($21)
		START_RENDERING(0, 0)

		; Remove sprite 0 from anim 0, and place it for screen-split
		;TODO opcode for that PLACE_SPRITE0
		ldx #ANIMATION_STATE_OFFSET_FIRST_SPRITE_NUM
		inc cutscene_anims, x

		lda #174
		sta oam_mirror
		lda #TILE_CUTSCENE_BIRD_DOT
		sta oam_mirror+1
		lda #%00100000 ; Hide sprite behing background
		sta oam_mirror+2
		lda #210
		sta oam_mirror+3

		PLAY_FRAMES(1)

		ldx #1
		stx cutscene_sprite0_hit
		dex
		stx cutscene_sprite0_scroll

		; Boat acceleration
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

		; Boat travel
		BG_UPDATE($20db, 16, empty_sky)
		PLAY_FRAMES(2)
		BG_UPDATE($20da, 16, empty_sky)
		PLAY_FRAMES(2)
		BG_UPDATE($20d9, 16, empty_sky)
		PLAY_FRAMES(2)
		BG_UPDATE($20d8, 16, empty_sky)
		PLAY_FRAMES(2)
		BG_UPDATE($20d7, 16, empty_sky)
		PLAY_FRAMES(2)
		BG_UPDATE($20d6, 16, empty_sky)
		PLAY_FRAMES(2)
		BG_UPDATE($20d5, 16, empty_sky)
		PLAY_FRAMES(2)
		BG_UPDATE($20d4, 16, empty_sky)
		PLAY_FRAMES(2)
		BG_UPDATE($20d3, 16, empty_sky)
		PLAY_FRAMES(2)
		BG_UPDATE($20d2, 16, empty_sky)
		PLAY_FRAMES(2)
		BG_UPDATE($20d1, 16, empty_sky)
		PLAY_FRAMES(2)
		BG_UPDATE($20d0, 16, empty_sky)
		PLAY_FRAMES(2)
		BG_UPDATE($20cf, 16, empty_sky)
		PLAY_FRAMES(2)
		BG_UPDATE($20ce, 16, empty_sky)
		PLAY_FRAMES(2)
		BG_UPDATE($20cd, 16, empty_sky)
		PLAY_FRAMES(2)
		BG_UPDATE($20cc, 16, empty_sky)
		PLAY_FRAMES(2)
	.)

	; Fadeout
	jsr cutscene_sinbad_story_bird_msg_boat_fadeout

	rts

	empty_sky:
		.byt $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01
.)
.)

+cutscene_sinbad_story_meteor_bank = CURRENT_BANK_NUMBER

#include "game/data/cutscenes/sinbad_story_meteor/screen.asm"
#include "game/data/cutscenes/sinbad_story_meteor/tilesets.asm"

.(
+cutscene_sinbad_story_meteor:
.word cutscene_sinbad_story_meteor_palette
.word cutscene_sinbad_story_meteor_nametable_top
.word cutscene_sinbad_story_meteor_nametable_bottom
.word cutscene_sinbad_story_meteor_bg_tileset
.word $ffff ; sprites tileset ($ffff for not using a sprite tileset)
.word cutscene_sinbad_story_meteor_logic
.word cutscene_sinbad_story_meteor_init

cutscene_sinbad_story_meteor_init:
.(
	; Place second player's character tileset for evil sinbad
	ldy #0
	ldx #1
	TRAMPOLINE(place_character_ppu_tiles_direct, #SINBAD_BANK_NUMBER, #CURRENT_BANK_NUMBER)

	rts
.)

cutscene_sinbad_story_meteor_logic:
.(
	; Sinbad runs to the cake
	INIT_ANIM(0, sinbad_anim_run, SINBAD_BANK_NUMBER, DIRECTION_RIGHT2, -8, 111, $0180, 0) ; index, anim, bank, direction, x, y, velocity_h, velocity_v
	SKIPPABLE_FRAMES(120)
	INIT_ANIM(0, sinbad_anim_idle, SINBAD_BANK_NUMBER, DIRECTION_RIGHT2, 172, 111, 0, 0) ; index, anim, bank, direction, x, y, velocity_h, velocity_v
	SKIPPABLE_FRAMES(12)

	; Evil sinbad comes
	INIT_ANIM_FOR_PLAYER(1, sinbad_anim_spawn, SINBAD_BANK_NUMBER, DIRECTION_LEFT2, 196, 111, 0, 0, 1)
	SKIPPABLE_FRAMES(50)
	INIT_ANIM_FOR_PLAYER(1, sinbad_anim_idle, SINBAD_BANK_NUMBER, DIRECTION_LEFT2, 196, 111, 0, 0, 1)

	; Screen shakes and sky darkens
	CUTS_SCREEN_SHAKE(50, 1, 3)
	PLAY_FRAMES(20)
	SET_PALETTE(0, $19, $19, $12)
	SET_PALETTE(1, $27, $12, $20)
	SET_PALETTE(2, $17, $19, $19)
	SET_PALETTE(3, $10, $12, $32)
	PLAY_FRAMES(1)
	SET_PALETTE(0, $09, $19, $02)
	SET_PALETTE(1, $27, $02, $20)
	SET_PALETTE(2, $17, $09, $19)
	SET_PALETTE(3, $10, $02, $34)
	PLAY_FRAMES(1)
	SET_PALETTE(0, $09, $19, $03)
	SET_PALETTE(1, $27, $03, $20)
	SET_PALETTE(2, $07, $09, $19)
	SET_PALETTE(3, $10, $03, $36)
	PLAY_FRAMES(1)
	SET_PALETTE(0, $09, $19, $0f)
	SET_PALETTE(1, $27, $0f, $20)
	SET_PALETTE(3, $10, $0f, $26)
	PLAY_FRAMES(50-20-1-1-1)

	; Camera traveling to space
	AUTO_SCROLL(0, -5)
	INIT_ANIM(0, sinbad_anim_idle, SINBAD_BANK_NUMBER, DIRECTION_RIGHT2, 172, 111, 0, $0500)
	INIT_ANIM_FOR_PLAYER(1, sinbad_anim_idle, SINBAD_BANK_NUMBER, DIRECTION_LEFT2, 196, 111, 0, $0500, 1)
	PLAY_FRAMES(3)
	SET_PALETTE(0, $09, $09, $0f)
	SET_PALETTE(1, $17, $0f, $10)
	PLAY_FRAMES(1)
	SET_PALETTE(0, $0f, $0f, $0f)
	SET_PALETTE(1, $07, $0f, $00)
	PLAY_FRAMES(1)
	SET_PALETTE(0, $0f, $0f, $0f)
	SET_PALETTE(1, $0f, $0f, $0f)
	PLAY_FRAMES(40-3-1-1)
	SET_PALETTE(0, $19, $21, $20)
	SET_PALETTE(1, $07, $16, $37)
	PLAY_FRAMES(48-40)
	AUTO_SCROLL(0, 0)
	ANIM_VELOCITY(0, 0, 0)
	ANIM_VELOCITY(0, 0, 0)
	SKIPPABLE_FRAMES(50)

	; Fade out
	SET_PALETTE(0, $09, $11, $10)
	SET_PALETTE(1, $07, $06, $16)
	PLAY_FRAMES(1)
	SET_PALETTE(0, $09, $01, $00)
	SET_PALETTE(1, $0f, $06, $00)
	PLAY_FRAMES(1)
	SET_PALETTE(0, $0f, $0f, $0f)
	SET_PALETTE(1, $0f, $0f, $0f)
	SKIPPABLE_FRAMES(10)

	; Come back to Earth
	SET_SCREEN(0)
	CUTS_SET_SCROLL(0, 0)
	SET_PALETTE(0, $09, $19, $0f)
	SET_PALETTE(1, $27, $0f, $20)

	; Player's Sinbad jump to the meteor
	INIT_ANIM(0, sinbad_anim_aerial_jump, SINBAD_BANK_NUMBER, DIRECTION_RIGHT2, 172, 111, 0, 0) ; index, anim, bank, direction, x, y, velocity_h, velocity_v
	INIT_ANIM_FOR_PLAYER(1, sinbad_anim_idle, SINBAD_BANK_NUMBER, DIRECTION_LEFT2, 196, 111, 0, 0, 1)
	SKIPPABLE_FRAMES(7)
	ANIM_VELOCITY(0, 0, -$0700) ; index, velocity_h, velocity_v

	; Evil Sinbad follows
	INIT_ANIM_FOR_PLAYER(1, sinbad_anim_jump, SINBAD_BANK_NUMBER, DIRECTION_LEFT2, 196, 111, 0, 0, 1)
	SKIPPABLE_FRAMES(7)
	ANIM_VELOCITY(1, 0, -$0700)
	SKIPPABLE_FRAMES(50)

	rts
.)
.)

+cutscene_sinbad_story_meteor_bank = CURRENT_BANK_NUMBER

#include "game/data/cutscenes/sinbad_story/meteor/anims.asm"
#include "game/data/cutscenes/sinbad_story/meteor/screen.asm"
#include "game/data/cutscenes/sinbad_story/meteor/tilesets.asm"

.(
+cutscene_sinbad_story_meteor:
.word cutscene_sinbad_story_meteor_palette
.word cutscene_sinbad_story_meteor_nametable_ground
.word cutscene_sinbad_story_meteor_nametable_space
.word cutscene_sinbad_story_meteor_ground_tileset
.word $ffff ; sprites tileset ($ffff for not using a sprite tileset)
.word cutscene_sinbad_story_meteor_logic
.word cutscene_sinbad_story_meteor_init

cutscene_sinbad_story_meteor_init:
.(
	; Place second player's character tileset for evil sinbad
	ldy #0
	ldx #1
	TRAMPOLINE(place_character_ppu_tiles_direct, #SINBAD_BANK_NUMBER, #CURRENT_BANK_NUMBER)

	; Place sprites specific from this cutscene
	LOAD_TILESET(cutscene_sinbad_story_meteor_sprites_tileset, cutscene_sinbad_story_meteor_bank, CHARACTERS_END_TILES_OFFSET)

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
	CUTS_SCREEN_SHAKE(50, 2, 12)
	PLAY_FRAMES(20)
	SET_PALETTE(0, $19, $19, $12)
	SET_PALETTE(1, $27, $12, $20)
	SET_PALETTE(2, $07, $19, $17)
	SET_PALETTE(3, $12, $10, $32)
	PLAY_FRAMES(1)
	SET_PALETTE(0, $09, $19, $02)
	SET_PALETTE(1, $27, $02, $20)
	SET_PALETTE(2, $07, $09, $17)
	SET_PALETTE(3, $02, $10, $34)
	PLAY_FRAMES(1)
	SET_PALETTE(0, $09, $19, $03)
	SET_PALETTE(1, $27, $03, $20)
	SET_PALETTE(2, $08, $09, $07)
	SET_PALETTE(3, $03, $00, $36)
	PLAY_FRAMES(1)
	SET_PALETTE(0, $09, $19, $0f)
	SET_PALETTE(1, $27, $0f, $20)
	SET_PALETTE(3, $0f, $00, $26)
	PLAY_FRAMES(50-20-1-1-1)

	; Camera traveling to space
	;  Fade-out palettes 0 and 1, must be black before contents from space-screen is displayed
	AUTO_SCROLL(0, -5)
	INIT_ANIM(0, sinbad_anim_idle, SINBAD_BANK_NUMBER, DIRECTION_RIGHT2, 172, 111, 0, $0500) ;TODO anim_velocity opcode should work here
	INIT_ANIM_FOR_PLAYER(1, sinbad_anim_idle, SINBAD_BANK_NUMBER, DIRECTION_LEFT2, 196, 111, 0, $0500, 1)
	PLAY_FRAMES(3)
	SET_PALETTE(0, $09, $09, $0f)
	SET_PALETTE(1, $17, $0f, $10)
	PLAY_FRAMES(1)
	SET_PALETTE(0, $0f, $0f, $0f)
	SET_PALETTE(1, $07, $0f, $00)
	PLAY_FRAMES(1)
	SET_PALETTE(0, $0f, $0f, $0f)
	SET_PALETTE(1, $08, $0f, $00)
	PLAY_FRAMES(14)
	SET_PALETTE(0, $0f, $0f, $0f)
	SET_PALETTE(1, $0f, $0f, $0f)
	PLAY_FRAMES(40-3-1-1-14)

	; Copy space tileset to VRAM
	LOAD_TILESET_BG(cutscene_sinbad_story_meteor_space_tileset, cutscene_sinbad_story_meteor_bank)
	START_RENDERING(1, 0)

	; Init sprites overlay
	;TODO implement SPRITE_OVERLAY opcode (taking a list of ANIM_SPRITE-like objects, placing sprites not touching it)
	INIT_ANIM(2, cutscene_sinbad_story_meteor_space_overlay, cutscene_sinbad_story_meteor_bank, DIRECTION_LEFT2, 192, 127-(5*8), 0, $0500) ; index, anim, bank, direction, x, y, velocity_h, velocity_v
	INIT_ANIM(3, cutscene_sinbad_story_meteor_space_overlay2, cutscene_sinbad_story_meteor_bank, DIRECTION_LEFT2, 192, 127-(5*8), 0, $0500)

	; Scroll-in + Fade-in space scene
	SET_PALETTE(0, $0f, $0f, $0c)
	SET_PALETTE(1, $0f, $06, $06)
	SET_PALETTE(4, $0f, $0f, $09)
	PLAY_FRAMES(1)
	SET_PALETTE(0, $0c, $00, $0c)
	SET_PALETTE(1, $07, $06, $16)
	SET_PALETTE(4, $0c, $00, $0a)
	PLAY_FRAMES(1)
	SET_PALETTE(0, $0c, $00, $1c)
	SET_PALETTE(1, $07, $16, $27)
	SET_PALETTE(4, $0c, $00, $1a)
	PLAY_FRAMES(48-40-1-1)

	; Display space scene
	AUTO_SCROLL(0, 0)
	ANIM_VELOCITY(0, 0, 0)
	ANIM_VELOCITY(1, 0, 0)
	ANIM_VELOCITY(2, 0, 0)
	ANIM_VELOCITY(3, 0, 0)
	SKIPPABLE_FRAMES(50)

	; Fade out
	SET_PALETTE(0, $0c, $00, $0c)
	SET_PALETTE(1, $07, $06, $16)
	SET_PALETTE(4, $0c, $00, $0a)
	PLAY_FRAMES(1)
	SET_PALETTE(0, $0f, $0f, $0c)
	SET_PALETTE(1, $0f, $06, $06)
	SET_PALETTE(4, $0f, $0f, $09)
	PLAY_FRAMES(1)
	SET_PALETTE(0, $0f, $0f, $0f)
	SET_PALETTE(1, $0f, $0f, $0f)
	SET_PALETTE(4, $0f, $0f, $0f)
	SKIPPABLE_FRAMES(10)

	; Hide sprites overlay
	CLEAR_ANIM(2)
	CLEAR_ANIM(3)
	SET_PALETTE(4, $08, $1a, $20)

	; Copy ground tileset to VRAM
	LOAD_TILESET_BG(cutscene_sinbad_story_meteor_ground_tileset, cutscene_sinbad_story_meteor_bank)
	START_RENDERING(0, 0)

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

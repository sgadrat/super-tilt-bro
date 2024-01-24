+cutscene_sinbad_story_ending_bank = CURRENT_BANK_NUMBER
#if cutscene_sinbad_story_ending_bank <> cutscene_sinbad_story_meteor_bank
#error ending shall be in same bank as meteor cutscene
#endif

.(
+cutscene_sinbad_story_ending:
.word cutscene_sinbad_story_meteor_palette
.word cutscene_sinbad_story_meteor_nametable_space
.word cutscene_sinbad_story_meteor_nametable_ground
.word cutscene_sinbad_story_meteor_space_tileset
.word $ffff ; sprites tileset ($ffff for not using a sprite tileset)
.word cutscene_sinbad_story_ending_logic
.word cutscene_sinbad_story_ending_init

no_cake_nt_tiles:
.byt $0a, $0a

cutscene_sinbad_story_ending_init:
.(
	; Place sprites specific from this cutscene
	LOAD_TILESET(cutscene_sinbad_story_meteor_sprites_tileset, cutscene_sinbad_story_meteor_bank, CHARACTERS_END_TILES_OFFSET, CURRENT_BANK_NUMBER)

	rts
.)

cutscene_sinbad_story_ending_logic:
.(

	; Init sprites overlay
	INIT_ANIM(2, cutscene_sinbad_story_meteor_space_overlay, cutscene_sinbad_story_meteor_bank, DIRECTION_LEFT2, 192, 127, 0, 0) ; index, anim, bank, direction, x, y, velocity_h, velocity_v
	INIT_ANIM(3, cutscene_sinbad_story_meteor_space_overlay2, cutscene_sinbad_story_meteor_bank, DIRECTION_LEFT2, 192, 127, 0, 0)

	; Set scroll on space scene
	CUTS_SET_SCROLL(0, 0)
	SET_PALETTE(0, $0c, $00, $1c)
	SET_PALETTE(1, $07, $16, $27)
	SET_PALETTE(6, $0c, $00, $1a)
	PLAY_FRAMES(50)

	; Have Sinbad cut the meteor
	INIT_ANIM_FOR_PLAYER(0, sinbad_anim_side_special_jump, SINBAD_BANK_NUMBER, DIRECTION_LEFT2, 128, 128, $fd00, $fe80, 0) ; index, anim, bank, direction, x, y, velocity_h, velocity_v, player
	PLAY_FRAMES(20)
	CUTS_SCREEN_SHAKE(10, 12, 6)
	PLAY_SFX(SFX_DEATH_IDX)
	PLAY_FRAMES(40-20)
	INIT_ANIM_FOR_PLAYER(0, sinbad_anim_side_special_jump, SINBAD_BANK_NUMBER, DIRECTION_RIGHT2, 16, 112, $0300, $fe80, 0) ; index, anim, bank, direction, x, y, velocity_h, velocity_v, player
	PLAY_FRAMES(10)
	CUTS_SCREEN_SHAKE(10, 12, 6)
	PLAY_SFX(SFX_DEATH_IDX)
	PLAY_FRAMES(20-10)

	; Meteor explode and Sinbad fades away
	CUTS_SCREEN_SHAKE(20, 12, 12)
	SET_PALETTE(1, $37,$20,$27)
	SET_PALETTE(4, $08,$0a,$10)
	SET_PALETTE(5, $08,$00,$27)
	PLAY_FRAMES(5)
	SET_PALETTE(1, $27,$26,$20)
	SET_PALETTE(4, $0f,$0a,$00)
	SET_PALETTE(5, $0f,$0f,$17)
	PLAY_FRAMES(5)
	SET_PALETTE(1, $17,$16,$10)
	CLEAR_ANIM(0)
	PLAY_FRAMES(2)
	SET_PALETTE(1, $07,$06,$00)
	PLAY_FRAMES(2)
	SET_PALETTE(1, $0f,$0f,$0f)
	PLAY_FRAMES(20-5-5-2-2)

	; Scroll down to ground scene (while fading away)
	SET_PALETTE(2, $0f, $0f, $0f)
	SET_PALETTE(3, $0f, $0f, $0f)
	AUTO_SCROLL(0, 5)
	ANIM_VELOCITY(2, 0, $fb00)
	ANIM_VELOCITY(3, 0, $fb00)
	PLAY_FRAMES(5)
	SET_PALETTE(0, $0c, $00, $0c)
	SET_PALETTE(6, $0c, $00, $0a)
	PLAY_FRAMES(2)
	SET_PALETTE(0, $0f, $00, $0c)
	SET_PALETTE(6, $0f, $00, $0a)
	PLAY_FRAMES(2)
	SET_PALETTE(0, $0f, $0f, $0f)
	SET_PALETTE(6, $0f, $0f, $0f)
	CLEAR_ANIM(2)
	CLEAR_ANIM(3)

	; Copy ground tileset to VRAM
	STOP_RENDERING
	LOAD_TILESET_BG(cutscene_sinbad_story_meteor_ground_tileset, cutscene_sinbad_story_meteor_bank, CURRENT_BANK_NUMBER)
	START_RENDERING(0, 0)

	; Scroll down from space scene (while fading in)
	CUTS_SET_SCROLL(32, $f0-(2+2+2)*5)
	SET_PALETTE(0, $0f, $0f, $0f)
	SET_PALETTE(1, $0f, $0f, $0f)
	SET_PALETTE(2, $0f, $0f, $0f)
	SET_PALETTE(3, $0f, $0f, $0f)
	PLAY_FRAMES(2)
	SET_PALETTE(0, $09, $09, $01)
	SET_PALETTE(1, $07, $01, $00)
	SET_PALETTE(2, $0f, $09, $07)
	SET_PALETTE(3, $01, $00, $00)
	PLAY_FRAMES(2)
	SET_PALETTE(0, $09, $19, $11)
	SET_PALETTE(1, $17, $11, $10)
	SET_PALETTE(2, $07, $19, $17)
	SET_PALETTE(3, $11, $10, $10)
	PLAY_FRAMES(2)
	SET_PALETTE(0, $19, $29, $21)
	SET_PALETTE(1, $27, $21, $20)
	SET_PALETTE(2, $07, $19, $17)
	SET_PALETTE(3, $21, $10, $20)
	AUTO_SCROLL(0, 0)
	SET_SCREEN(2)
	CUTS_SET_SCROLL(32, 0)

	; Sinbad comes back and take the cake
	SET_PALETTE(4, $08,$1a,$20)
	SET_PALETTE(5, $08,$10,$37)
	INIT_ANIM_FOR_PLAYER(0, sinbad_anim_helpless, SINBAD_BANK_NUMBER, DIRECTION_RIGHT2, 32, 111-(3*20), $0100, $0300, 0) ; index, anim, bank, direction, x, y, velocity_h, velocity_v, player
	PLAY_FRAMES(20)
	landing_x=32+(1*20)
	INIT_ANIM_FOR_PLAYER(0, sinbad_anim_run, SINBAD_BANK_NUMBER, DIRECTION_RIGHT2, landing_x, 111, $0300, $0000, 0) ; index, anim, bank, direction, x, y, velocity_h, velocity_v, player
	cake_x=172
	PLAY_FRAMES((cake_x-landing_x)/3+1)
	BG_UPDATE($2999, 2, no_cake_nt_tiles)
	BG_UPDATE($29b9, 2, no_cake_nt_tiles)
	BG_UPDATE($29d9, 2, no_cake_nt_tiles)
	PLAY_FRAMES((256-cake_x)/3+1)

	; Fadeout to blue
	CLEAR_ANIM(0)
	SET_PALETTE(0, $29, $2a, $21)
	SET_PALETTE(1, $26, $21, $31)
	SET_PALETTE(2, $15, $1a, $16)
	SET_PALETTE(3, $21, $11, $31)
	PLAY_FRAMES(2)
	SET_PALETTE(0, $2b, $2b, $21)
	SET_PALETTE(1, $22, $21, $21)
	SET_PALETTE(2, $23, $2b, $23)
	SET_PALETTE(3, $21, $21, $21)
	PLAY_FRAMES(2)
	SET_PALETTE(0, $21, $21, $21)
	SET_PALETTE(1, $21, $21, $21)
	SET_PALETTE(2, $21, $21, $21)

	rts
.)
.)

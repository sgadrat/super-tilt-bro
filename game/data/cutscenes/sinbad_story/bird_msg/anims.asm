island_begin = CHARACTERS_CHARACTER_B_FIRST_TILE + sprites_tileset_size
cloud_begin = island_begin + island_tileset_size

cutscene_sinbad_story_bird_msg_anim_bird:
; Frame 1
ANIM_FRAME_BEGIN(5)
ANIM_DEFAULT_HEADER
ANIM_SPRITE_FOREGROUND_COUNT(0)
ANIM_SPRITE_NORMAL_COUNT(4)
ANIM_SPRITE($00, TILE_CUTSCENE_BIRD_0, $02, $00) ; y, tile, attr, x
ANIM_SPRITE($00, TILE_CUTSCENE_BIRD_1, $02, $08)
ANIM_SPRITE($08, TILE_CUTSCENE_BIRD_2, $02, $00)
ANIM_SPRITE($08, TILE_CUTSCENE_BIRD_3, $02, $08)
; Frame 2
ANIM_FRAME_BEGIN(5)
ANIM_DEFAULT_HEADER
ANIM_SPRITE_FOREGROUND_COUNT(0)
ANIM_SPRITE_NORMAL_COUNT(4)
ANIM_SPRITE($00, TILE_CUTSCENE_BIRD_4, $02, $00) ; y, tile, attr, x
ANIM_SPRITE($00, TILE_CUTSCENE_BIRD_5, $02, $08)
ANIM_SPRITE($08, TILE_CUTSCENE_BIRD_6, $02, $00)
ANIM_SPRITE($08, TILE_CUTSCENE_BIRD_7, $02, $08)
; Frame 3
ANIM_FRAME_BEGIN(5)
ANIM_DEFAULT_HEADER
ANIM_SPRITE_FOREGROUND_COUNT(0)
ANIM_SPRITE_NORMAL_COUNT(4)
ANIM_SPRITE($00, TILE_CUTSCENE_BIRD_8, $02, $00) ; y, tile, attr, x
ANIM_SPRITE($00, TILE_CUTSCENE_BIRD_9, $02, $08)
ANIM_SPRITE($08, TILE_CUTSCENE_BIRD_10, $02, $00)
ANIM_SPRITE($08, TILE_CUTSCENE_BIRD_11, $02, $08)
; Frame 4
ANIM_FRAME_BEGIN(5)
ANIM_DEFAULT_HEADER
ANIM_SPRITE_FOREGROUND_COUNT(0)
ANIM_SPRITE_NORMAL_COUNT(4)
ANIM_SPRITE($00, TILE_CUTSCENE_BIRD_4, $02, $00) ; y, tile, attr, x
ANIM_SPRITE($00, TILE_CUTSCENE_BIRD_5, $02, $08)
ANIM_SPRITE($08, TILE_CUTSCENE_BIRD_6, $02, $00)
ANIM_SPRITE($08, TILE_CUTSCENE_BIRD_7, $02, $08)
; End of animation
ANIM_ANIMATION_END

cutscene_sinbad_story_bird_msg_anim_overlay_left:
; Frame 1
ANIM_FRAME_BEGIN(100)
ANIM_DEFAULT_HEADER
ANIM_SPRITE_FOREGROUND_COUNT(14)
	; Left island
	ANIM_SPRITE(160-48+0, island_begin+TILE_CUTSCENE_SINBAD_ISLAND_2, $23, -128+0) ; y, tile, attr, x
	ANIM_SPRITE(160-48+8, island_begin+TILE_CUTSCENE_SINBAD_ISLAND_5, $23, -128+0)
	ANIM_SPRITE(160-48+8, island_begin+TILE_CUTSCENE_SINBAD_ISLAND_6, $23, -128+0+8)

	; Left cloud
	ANIM_SPRITE(88-48+0, cloud_begin+TILE_TILESET_NEW_CLOUD_0, $22, -128+40+0)
	ANIM_SPRITE(88-48+0, cloud_begin+TILE_TILESET_NEW_CLOUD_1, $22, -128+40+8)
	ANIM_SPRITE(88-48+8, cloud_begin+TILE_TILESET_NEW_CLOUD_2, $22, -128+40+0)
	ANIM_SPRITE(88-48+8, cloud_begin+TILE_TILESET_NEW_CLOUD_3, $22, -128+40+8)
	ANIM_SPRITE(88-48+8, cloud_begin+TILE_TILESET_NEW_CLOUD_4, $22, -128+40+16)

	; Middle island
	ANIM_SPRITE(160-48+0, island_begin+TILE_CUTSCENE_SINBAD_ISLAND_0, $23, -128+96+0)
	ANIM_SPRITE(160-48+0, island_begin+TILE_CUTSCENE_SINBAD_ISLAND_1, $23, -128+96+8)
	ANIM_SPRITE(160-48+0, island_begin+TILE_CUTSCENE_SINBAD_ISLAND_2, $23, -128+96+16)
	ANIM_SPRITE(160-48+8, island_begin+TILE_CUTSCENE_SINBAD_ISLAND_7, $23, -128+96+8)
	ANIM_SPRITE(160-48+8, island_begin+TILE_CUTSCENE_SINBAD_ISLAND_5, $23, -128+96+16)

	; Middle cloud
	ANIM_SPRITE(96-48+0, cloud_begin+TILE_TILESET_NEW_CLOUD_0, $22, -128+160+0)
ANIM_SPRITE_NORMAL_COUNT(0)
; End of animation
ANIM_ANIMATION_END

cutscene_sinbad_story_bird_msg_anim_overlay_right:
; Frame 1
ANIM_FRAME_BEGIN(100)
ANIM_DEFAULT_HEADER
ANIM_SPRITE_FOREGROUND_COUNT(15)
	; Middle cloud
	ANIM_SPRITE(96-48+0, cloud_begin+TILE_TILESET_NEW_CLOUD_1, $22, -128+160+8)
	ANIM_SPRITE(96-48+8, cloud_begin+TILE_TILESET_NEW_CLOUD_2, $22, -128+160+0)
	ANIM_SPRITE(96-48+8, cloud_begin+TILE_TILESET_NEW_CLOUD_3, $22, -128+160+8)
	ANIM_SPRITE(96-48+8, cloud_begin+TILE_TILESET_NEW_CLOUD_4, $22, -128+160+16)

	; Right cloud
	ANIM_SPRITE(64-48+0, cloud_begin+TILE_TILESET_NEW_CLOUD_0, $22, -128+224+0)
	ANIM_SPRITE(64-48+0, cloud_begin+TILE_TILESET_NEW_CLOUD_1, $22, -128+224+8)
	ANIM_SPRITE(64-48+8, cloud_begin+TILE_TILESET_NEW_CLOUD_2, $22, -128+224+0)
	ANIM_SPRITE(64-48+8, cloud_begin+TILE_TILESET_NEW_CLOUD_3, $22, -128+224+8)
	ANIM_SPRITE(64-48+8, cloud_begin+TILE_TILESET_NEW_CLOUD_4, $22, -128+224+16)

	; Right island
	ANIM_SPRITE(160-48+0, island_begin+TILE_CUTSCENE_SINBAD_ISLAND_0, $23, -128+224+0)
	ANIM_SPRITE(160-48+0, island_begin+TILE_CUTSCENE_SINBAD_ISLAND_1, $23, -128+224+8)
	ANIM_SPRITE(160-48+0, island_begin+TILE_CUTSCENE_SINBAD_ISLAND_2, $23, -128+224+16)
	ANIM_SPRITE(160-48+8, island_begin+TILE_CUTSCENE_SINBAD_ISLAND_3, $23, -128+224+0)
	ANIM_SPRITE(160-48+8, island_begin+TILE_CUTSCENE_SINBAD_ISLAND_4, $23, -128+224+8)
	ANIM_SPRITE(160-48+8, island_begin+TILE_CUTSCENE_SINBAD_ISLAND_5, $23, -128+224+16)
ANIM_SPRITE_NORMAL_COUNT(0)
; End of animation
ANIM_ANIMATION_END
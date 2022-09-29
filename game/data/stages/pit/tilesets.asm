tileset_stage_pit_sprites:

; Tileset's size in tiles (zero means 256)
.byt (tileset_stage_pit_sprites_end-tileset_stage_pit_sprites_tiles)/16

tileset_stage_pit_sprites_tiles:

; TILE - Moving platform
;
; 33333333
; 33333333
; 00000000
; 00000000
; 00000000
; 00000000
; 00000000
; 00000000
TILE_MOVING_PLATFORM = (*-tileset_stage_pit_sprites_tiles+STAGE_FIRST_SPRITE_TILE_OFFSET)/16
.byt %11111111, %11111111, %00000000, %00000000, %00000000, %00000000, %00000000, %00000000
.byt %11111111, %11111111, %00000000, %00000000, %00000000, %00000000, %00000000, %00000000

tileset_stage_pit_sprites_end:

#if (tileset_stage_pit_sprites_end - tileset_stage_pit_sprites_tiles) / 16 > STAGE_NUM_SPRITE_TILES
#error too much tiles in stage's tileset
#endif

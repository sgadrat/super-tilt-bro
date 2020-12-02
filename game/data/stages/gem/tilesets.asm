tileset_stage_thehunt_sprites:

; Tileset's size in tiles (zero means 256)
.byt (tileset_stage_thehunt_sprites_end-tileset_stage_thehunt_sprites_tiles)/16

tileset_stage_thehunt_sprites_tiles:

; TILE - Gem
;
; 00111100
; 01333010
; 13330301
; 13333031
; 13333301
; 01333310
; 13133131
; 01011010
TILE_GEM = (*-tileset_stage_thehunt_sprites_tiles+CHARACTERS_END_TILES_OFFSET)/16
.byt %00111100, %01111010, %11110101, %11111011, %11111101, %01111110, %11111111, %01011010
.byt %00000000, %00111000, %01110100, %01111010, %01111100, %00111100, %01011010, %00000000

tileset_stage_thehunt_sprites_end:

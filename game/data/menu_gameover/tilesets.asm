+TILESET_GAMEOVER_BANK_NUMBER = CURRENT_BANK_NUMBER

+tileset_gameover_sprites:

; Tileset's size in tiles (zero means 256)
.byt (tileset_gameover_sprites_end-tileset_gameover_sprites_tiles)/16

tileset_gameover_sprites_tiles:

; TILES $4a to 4b - Balloon
;
; Full picture layout
; $4a
; $4b
+TILE_BALLOON = (*-tileset_gameover_sprites_tiles+CHARACTERS_END_TILES_OFFSET)/16
.byt %00111100, %01001110, %10000011, %10000001, %01000010, %01000010, %00100100, %00011000
.byt %00000000, %00111100, %01111110, %01111110, %00111100, %00111100, %00011000, %00000000
+TILE_BALLOON_TAIL = (*-tileset_gameover_sprites_tiles+CHARACTERS_END_TILES_OFFSET)/16
.byt %00011000, %00010000, %00010000, %00001000, %00001000, %00010000, %00010000, %00001000
.byt %00000000, %00000000, %00000000, %00000000, %00000000, %00000000, %00000000, %00000000

tileset_gameover_sprites_end:

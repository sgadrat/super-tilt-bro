ARCADE_BTT_SPRITES_TILESET_BANK_NUMBER = CURRENT_BANK_NUMBER

arcade_btt_sprites_tileset:

; Tileset's size in tiles (zero means 256)
.byt (arcade_btt_sprites_tileset_end-arcade_btt_sprites_tileset_tiles)/16

arcade_btt_sprites_tileset_tiles:
TILE_ARCADE_BTT_SPRITES_TILESET_TARGET = $c0+(*-arcade_btt_sprites_tileset_tiles)/16
.byt %00000000, %00011000, %00111100, %01100110, %01100110, %00111100, %00011000, %00000000
.byt %00111100, %01111110, %11111111, %11111111, %11111111, %11111111, %01111110, %00111100
arcade_btt_sprites_tileset_end:

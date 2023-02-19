+ARCADE_CONGRATZ_TINY_MEDAL_TILESET_BANK_NUMBER = CURRENT_BANK_NUMBER

+arcade_congratz_tiny_medal_tileset:

; Tileset's size in tiles (zero means 256)
.byt (arcade_congratz_tiny_medal_tileset_end-arcade_congratz_tiny_medal_tileset_tiles)/16

arcade_congratz_tiny_medal_tileset_tiles:
.byt %00000000, %00000000, %00000111, %00011000, %00100000, %01000000, %11000000, %11000000
.byt %00000000, %00000000, %00000000, %00000111, %00011111, %00111111, %00111111, %00111111
.byt %00000000, %00000000, %11100000, %00011000, %00000100, %00000010, %00000011, %00000011
.byt %00000000, %00000000, %00000000, %11100000, %11111000, %11111100, %11111100, %11111100
.byt %11000000, %11100000, %11011000, %01100111, %00101001, %00011011, %00000011, %00000000
.byt %00111111, %00011111, %00100111, %00011000, %00010110, %00000100, %00000000, %00000000
.byt %00000011, %00000111, %00011011, %11100110, %10010100, %11011000, %11000000, %00000000
.byt %11111100, %11111000, %11100100, %00011000, %01101000, %00100000, %00000000, %00000000
arcade_congratz_tiny_medal_tileset_end:
+arcade_congratz_tiny_medal_tileset_size = arcade_congratz_tiny_medal_tileset_end - arcade_congratz_tiny_medal_tileset_tiles

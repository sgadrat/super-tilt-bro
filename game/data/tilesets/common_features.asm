; This file contains a collection of small tileset of recuring graphics through the game
; so it can easily be copied wherever in VRAM as needed.

TILESET_COMMON_FEATURES_BANK_NUMBER = CURRENT_BANK_NUMBER

; This version of the cloud can only be correctly displayed as a metasprite
; top sprite must be offset by 5 pixels on the right.
tileset_cloud_sprites:

; Tileset's size in tiles (zero means 256)
.byt (tileset_cloud_sprites_end-tileset_cloud_sprites_tiles)/16

tileset_cloud_sprites_tiles:

; 5 tiles - Cloud
; Pattern
;    1
;   2 3 4
.byt %00000000, %00000000, %00000000, %00000000, %00000000, %00111100, %01111110, %11111111
.byt %00000000, %00000000, %00000000, %00000000, %00000000, %00000000, %00111100, %01111110
.byt %00001111, %01111111, %11111111, %01111011, %11111111, %11111111, %01111000, %00110000
.byt %00000111, %00000111, %01110111, %11111111, %11111111, %11111111, %11111111, %01111000
.byt %11111100, %11111101, %11111111, %11111111, %11111111, %11111111, %11100111, %01100000
.byt %11111000, %11111000, %11111101, %11111111, %11111111, %11111111, %11111111, %11100000
.byt %01110000, %11111000, %11111000, %11111100, %11111100, %11111110, %11110110, %00000000
.byt %00000000, %01110000, %11110000, %11111000, %11111000, %11111100, %11111111, %11110100

tileset_cloud_sprites_end:

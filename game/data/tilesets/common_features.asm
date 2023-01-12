; This file contains a collection of small tileset of recuring graphics through the game
; so it can easily be copied wherever in VRAM as needed.

TILESET_COMMON_FEATURES_BANK_NUMBER = CURRENT_BANK_NUMBER

; ============
; Cloud sprite
;  deprecated - new cloud tileset has more details, is grid-aligned, can be expanded to longer clouds
; ============

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

; ============
; New cloud
; ============

; Layout
;  $00 $01
;  $02 $03 $04
:
; Extended layout (extra row can be repeated to extend at will)
;  $00 $05 $01
;  $02 $06 $03 $04

TILESET_NEW_CLOUD_BANK_NUMBER = CURRENT_BANK_NUMBER

tileset_new_cloud:

; Tileset's size in tiles (zero means 256)
.byt (tileset_new_cloud_end-tileset_new_cloud_tiles)/16

tileset_new_cloud_tiles:
TILE_TILESET_NEW_CLOUD_0 = (*-tileset_new_cloud_tiles)/16
.byt %00000000, %00000000, %00000000, %00000000, %00000000, %00000000, %00000001, %00000010
.byt %00000000, %00000000, %00000000, %00000000, %00000000, %00000000, %00000000, %00000001
TILE_TILESET_NEW_CLOUD_1 = (*-tileset_new_cloud_tiles)/16
.byt %00000000, %00000000, %00000000, %00000000, %00000000, %11110000, %00001000, %11110100
.byt %00000000, %00000000, %00000000, %00000000, %00000000, %00000000, %11110000, %11111000
TILE_TILESET_NEW_CLOUD_2 = (*-tileset_new_cloud_tiles)/16
.byt %00000101, %00111101, %01000101, %01011010, %10111100, %10111100, %01011011, %00100100
.byt %00000011, %00000011, %00111011, %00111101, %01111111, %01111111, %00111100, %00011000
TILE_TILESET_NEW_CLOUD_3 = (*-tileset_new_cloud_tiles)/16
.byt %11111010, %11111010, %11111101, %11111110, %00001111, %00000011, %10001100, %01110011
.byt %11111100, %11111100, %11111110, %11111111, %11111111, %11111111, %01110011, %00000000
TILE_TILESET_NEW_CLOUD_4 = (*-tileset_new_cloud_tiles)/16
.byt %01110000, %10111000, %01111000, %11110100, %11110100, %11111010, %00001001, %11110110
.byt %00000000, %01110000, %11110000, %11111000, %11111000, %11111100, %11110110, %00000000
TILE_TILESET_NEW_CLOUD_5 = (*-tileset_new_cloud_tiles)/16
.byt %00000000, %00000000, %00000000, %00000000, %00000000, %11110000, %00001001, %11110110
.byt %00000000, %00000000, %00000000, %00000000, %00000000, %00000000, %11110000, %11111001
TILE_TILESET_NEW_CLOUD_6 = (*-tileset_new_cloud_tiles)/16
.byt %11111101, %11111101, %11111101, %11110010, %00000100, %00000100, %10000011, %01111100
.byt %11111011, %11111011, %11111011, %11111101, %11111111, %11111111, %01111100, %00000000
tileset_new_cloud_end:

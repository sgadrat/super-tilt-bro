TILESET_MENUS_BANK_NUMBER = CURRENT_BANK_NUMBER

tileset_menus:

; Tileset's size in tiles (zero means 256)
.byt (tileset_menus_end-tileset_menus_tiles)/16

tileset_menus_tiles:

; Full backdrop color
;
; 00000000
; 00000000
; 00000000
; 00000000
; 00000000
; 00000000
; 00000000
; 00000000
.byt $00, $00, $00, $00, $00, $00, $00, $00
.byt $00, $00, $00, $00, $00, $00, $00, $00

; Solid 1
;
; 11111111
; 11111111
; 11111111
; 11111111
; 11111111
; 11111111
; 11111111
; 11111111
.byt $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
.byt $00, $00, $00, $00, $00, $00, $00, $00

; Solid 2
.byt $00, $00, $00, $00, $00, $00, $00, $00
.byt $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff

; Solid 3
.byt $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
.byt $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff

; Menu box, top border plus top internal border
;
; 33333333
; 33333333
; 22222222
; 22222222
; 22222222
; 22222222
; 22222222
; 33333333
.byt %11111111, %11111111, %00000000, %00000000, %00000000, %00000000, %00000000, %11111111
.byt %11111111, %11111111, %11111111, %11111111, %11111111, %11111111, %11111111, %11111111

; Numeric font 2 with other background color
.byt %00000000, %01111100, %11000110, %01100110, %00001100, %00111000, %01111110, %00000000
.byt %11111111, %10000011, %00111001, %10011001, %11110011, %11000111, %10000001, %11111111

; Menu box, top inner border
;
; 22222222
; 22222222
; 22222222
; 22222222
; 22222222
; 22222222
; 22222222
; 33333333
.byt %00000000, %00000000, %00000000, %00000000, %00000000, %00000000, %00000000, %11111111
.byt %11111111, %11111111, %11111111, %11111111, %11111111, %11111111, %11111111, %11111111

; Menu box, left inner border
;
; 22222223
; 22222223
; 22222223
; 22222223
; 22222223
; 22222223
; 22222223
; 22222223
.byt %00000001, %00000001, %00000001, %00000001, %00000001, %00000001, %00000001, %00000001
.byt %11111111, %11111111, %11111111, %11111111, %11111111, %11111111, %11111111, %11111111

; Menu box, bottom inner border
;
; 32222222
; 32222222
; 32222222
; 32222222
; 32222222
; 32222222
; 32222222
; 32222222
.byt %10000000, %10000000, %10000000, %10000000, %10000000, %10000000, %10000000, %10000000
.byt %11111111, %11111111, %11111111, %11111111, %11111111, %11111111, %11111111, %11111111

; Stage selection menu icon
;
; Full picture layout
; e9 ea
; eb ec
.byt %11111111, %11111111, %11111111, %11111111, %11111111, %11111111, %11111111, %11111111
.byt %11111111, %11111111, %11111111, %11111111, %11110000, %11111000, %11111100, %11111111
.byt %11111111, %11111111, %11111111, %11111111, %11111111, %11111111, %11111111, %11111111
.byt %11111111, %11111111, %11111111, %11111111, %00001111, %00011111, %00111111, %11111111
.byt %11111111, %11111111, %11111111, %11111111, %11111111, %11111111, %11111111, %11111111
.byt %11111111, %11111111, %11111111, %10000011, %11000111, %11111111, %11111111, %11111111
.byt %11111111, %11111111, %11111111, %11111111, %11111111, %11111111, %11111111, %11111111
.byt %11111111, %11111111, %11111111, %11000001, %11100011, %11111111, %11111111, %11111111

; Configuration menu icon
;
; Full picture layout
; ed ee
; ef f0
.byt %11111111, %11111111, %11111111, %11111111, %11111111, %11111111, %11111111, %11111111
.byt %11111111, %11111001, %10010011, %11000111, %11101111, %11111111, %11111001, %10010011
.byt %11111111, %11111111, %11111111, %11111111, %11111111, %11111111, %11111111, %11111111
.byt %11111111, %11111111, %11111111, %00000001, %11111111, %11111111, %11111111, %11111111
.byt %11111111, %11111111, %11111111, %11111111, %11111111, %11111111, %11111111, %11111111
.byt %11000111, %11101111, %11111111, %11111001, %10010011, %11000111, %11101111, %11111111
.byt %11111111, %11111111, %11111111, %11111111, %11111111, %11111111, %11111111, %11111111
.byt %00000001, %11111111, %11111111, %11111111, %11111111, %00000001, %11111111, %11111111

; Character selection menu icon
;
; Full picture layout
; f1 f2
; f2 f4
.byt %11111111, %11111111, %11111111, %11111111, %11111111, %11111111, %11111111, %11111111
.byt %11111111, %10001011, %01110111, %11111011, %10101011, %11111011, %11011011, %00000111
.byt %11111111, %11111111, %11111111, %11111111, %11111111, %11111111, %11111111, %11111111
.byt %11111111, %11110001, %11001110, %10110101, %10110101, %11001110, %11011011, %11100000
.byt %11111111, %11111111, %11111111, %11111111, %11111111, %11111111, %11111111, %11111111
.byt %10101101, %01110111, %01110100, %01110111, %00100100, %01010111, %10101111, %11111111
.byt %11111111, %11111111, %11111111, %11111111, %11111111, %11111111, %11111111, %11111111
.byt %01110101, %11101110, %10101110, %11101110, %01100100, %11101010, %11110101, %11111111

; Left arrow
;
; 22222222
; 22221222
; 22211222
; 21111222
; 11111222
; 21111222
; 22211222
; 22221222
.byt %00000000, %00001000, %00011000, %01111000, %11111000, %01111000, %00011000, %00001000
.byt %11111111, %11110111, %11100111, %10000111, %00000111, %10000111, %11100111, %11110111

; Right arrow
;
; 22222222
; 22212222
; 22211222
; 22211112
; 22211111
; 22211112
; 22211222
; 22212222
.byt %00000000, %00010000, %00011000, %00011110, %00011111, %00011110, %00011000, %00010000
.byt %11111111, %11101111, %11100111, %11100001, %11100000, %11100001, %11100111, %11101111

; Menu box, top-left corner
;
; 00000003
; 00000333
; 00033332
; 00333222
; 00332222
; 03322222
; 03322222
; 33222222
.byt %00000001, %00000111, %00011110, %00111000, %00110000, %01100000, %01100000, %11000000
.byt %00000001, %00000111, %00011111, %00111111, %00111111, %01111111, %01111111, %11111111

; Menu box, top-right corner
;
; 33333333
; 33333333
; 22222233
; 22222233
; 22222233
; 22222233
; 22222233
; 22222233
.byt %11111111, %11111111, %00000011, %00000011, %00000011, %00000011, %00000011, %00000011
.byt %11111111, %11111111, %11111111, %11111111, %11111111, %11111111, %11111111, %11111111

; Menu box, bottom-left corner
;
; 33222222
; 33222222
; 33222222
; 33222222
; 33333333
; 33333333
; 33333333
; 33333333
.byt %11000000, %11000000, %11000000, %11000000, %11111111, %11111111, %11111111, %11111111
.byt %11111111, %11111111, %11111111, %11111111, %11111111, %11111111, %11111111, %11111111

; Menu box, bottom-right corner
;
; 22222233
; 22222233
; 22222233
; 22222233
; 33333333
; 33333333
; 33333333
; 33333333
.byt %00000011, %00000011, %00000011, %00000011, %11111111, %11111111, %11111111, %11111111
.byt %11111111, %11111111, %11111111, %11111111, %11111111, %11111111, %11111111, %11111111

; Menu box, top border
;
; 33333333
; 33333333
; 22222222
; 22222222
; 22222222
; 22222222
; 22222222
; 22222222
.byt %11111111, %11111111, %00000000, %00000000, %00000000, %00000000, %00000000, %00000000
.byt %11111111, %11111111, %11111111, %11111111, %11111111, %11111111, %11111111, %11111111

; Menu box, left border
;
; 33222222
; 33222222
; 33222222
; 33222222
; 33222222
; 33222222
; 33222222
; 33222222
.byt %11000000, %11000000, %11000000, %11000000, %11000000, %11000000, %11000000, %11000000
.byt %11111111, %11111111, %11111111, %11111111, %11111111, %11111111, %11111111, %11111111

; Menu box, right border
;
; 22222233
; 22222233
; 22222233
; 22222233
; 22222233
; 22222233
; 22222233
; 22222233
.byt %00000011, %00000011, %00000011, %00000011, %00000011, %00000011, %00000011, %00000011
.byt %11111111, %11111111, %11111111, %11111111, %11111111, %11111111, %11111111, %11111111

; Menu box, bottom border
;
; 22222222
; 22222222
; 22222222
; 22222222
; 33333333
; 33333333
; 33333333
; 33333333
.byt %00000000, %00000000, %00000000, %00000000, %11111111, %11111111, %11111111, %11111111
.byt %11111111, %11111111, %11111111, %11111111, %11111111, %11111111, %11111111, %11111111

; Menu box, bottome inner border
;
; 33333333
; 22222222
; 22222222
; 22222222
; 22222222
; 22222222
; 22222222
; 22222222
.byt %11111111, %00000000, %00000000, %00000000, %00000000, %00000000, %00000000, %00000000
.byt %11111111, %11111111, %11111111, %11111111, %11111111, %11111111, %11111111, %11111111

; Upper grass
.byt %00000000, %00000010, %00000001, %00001001, %01000000, %00010110, %00100000, %10000000
.byt %00000000, %00000000, %00000010, %00000010, %00001011, %01001001, %01011111, %01111111

.byt %00000000, %00000000, %00010000, %00000000, %10100100, %00000000, %01001010, %00000000
.byt %00000000, %00000000, %00000000, %00010000, %00010000, %10110100, %10110100, %11111111

; Under grass
.byt %00000000, %00000000, %10001100, %10100110, %11000110, %11111111, %11111111, %11111111
.byt %11111111, %11111111, %01110011, %11011101, %11111111, %11101111, %11111111, %11111111

.byt %00000000, %00000000, %00001000, %00011001, %00011101, %10011111, %10111111, %11111111
.byt %11111111, %11111111, %11110111, %11101110, %11101011, %01111101, %11011111, %11111111

; Ponctuation signs
; dash, dot, colon, slash, exclamation mark
.byt %00000000, %00000000, %00000000, %00111100, %01111110, %00000000, %00000000, %00000000
.byt %11111111, %11111111, %11111111, %11000011, %10000001, %11111111, %11111111, %11111111

.byt %00000000, %00000000, %00000000, %00000000, %00000000, %00011000, %00011000, %00000000
.byt %11111111, %11111111, %11111111, %11111111, %11111111, %11100111, %11100111, %11111111

.byt %00000000, %00000000, %00011000, %00011000, %00000000, %00011000, %00011000, %00000000
.byt %11111111, %11111111, %11100111, %11100111, %11111111, %11100111, %11100111, %11111111

.byt %00000000, %00000110, %00001100, %00001100, %00111000, %01100000, %11000000, %00000000
.byt %11111111, %11111001, %11110011, %11110011, %11000111, %10011111, %00111111, %11111111

.byt %00000000, %00011000, %00011000, %00111000, %00110000, %00000000, %01100000, %01100000
.byt %11111111, %11100111, %11100111, %11000111, %11001111, %11111111, %10011111, %10011111

; QR code blocks
.byt %00000000, %00000000, %00000000, %00000000, %00000000, %00000000, %00000000, %00000000
.byt %11111111, %11111111, %11111111, %11111111, %11111111, %11111111, %11111111, %11111111
.byt %00000000, %00000000, %00000000, %00000000, %00001111, %00001111, %00001111, %00001111
.byt %11111111, %11111111, %11111111, %11111111, %11110000, %11110000, %11110000, %11110000
.byt %00000000, %00000000, %00000000, %00000000, %11110000, %11110000, %11110000, %11110000
.byt %11111111, %11111111, %11111111, %11111111, %00001111, %00001111, %00001111, %00001111
.byt %00000000, %00000000, %00000000, %00000000, %11111111, %11111111, %11111111, %11111111
.byt %11111111, %11111111, %11111111, %11111111, %00000000, %00000000, %00000000, %00000000
.byt %00001111, %00001111, %00001111, %00001111, %00000000, %00000000, %00000000, %00000000
.byt %11110000, %11110000, %11110000, %11110000, %11111111, %11111111, %11111111, %11111111
.byt %00001111, %00001111, %00001111, %00001111, %00001111, %00001111, %00001111, %00001111
.byt %11110000, %11110000, %11110000, %11110000, %11110000, %11110000, %11110000, %11110000
.byt %00001111, %00001111, %00001111, %00001111, %11110000, %11110000, %11110000, %11110000
.byt %11110000, %11110000, %11110000, %11110000, %00001111, %00001111, %00001111, %00001111
.byt %00001111, %00001111, %00001111, %00001111, %11111111, %11111111, %11111111, %11111111
.byt %11110000, %11110000, %11110000, %11110000, %00000000, %00000000, %00000000, %00000000
.byt %11110000, %11110000, %11110000, %11110000, %00000000, %00000000, %00000000, %00000000
.byt %00001111, %00001111, %00001111, %00001111, %11111111, %11111111, %11111111, %11111111
.byt %11110000, %11110000, %11110000, %11110000, %00001111, %00001111, %00001111, %00001111
.byt %00001111, %00001111, %00001111, %00001111, %11110000, %11110000, %11110000, %11110000
.byt %11110000, %11110000, %11110000, %11110000, %11110000, %11110000, %11110000, %11110000
.byt %00001111, %00001111, %00001111, %00001111, %00001111, %00001111, %00001111, %00001111
.byt %11110000, %11110000, %11110000, %11110000, %11111111, %11111111, %11111111, %11111111
.byt %00001111, %00001111, %00001111, %00001111, %00000000, %00000000, %00000000, %00000000
.byt %11111111, %11111111, %11111111, %11111111, %00000000, %00000000, %00000000, %00000000
.byt %00000000, %00000000, %00000000, %00000000, %11111111, %11111111, %11111111, %11111111
.byt %11111111, %11111111, %11111111, %11111111, %00001111, %00001111, %00001111, %00001111
.byt %00000000, %00000000, %00000000, %00000000, %11110000, %11110000, %11110000, %11110000
.byt %11111111, %11111111, %11111111, %11111111, %11110000, %11110000, %11110000, %11110000
.byt %00000000, %00000000, %00000000, %00000000, %00001111, %00001111, %00001111, %00001111
.byt %11111111, %11111111, %11111111, %11111111, %11111111, %11111111, %11111111, %11111111
.byt %00000000, %00000000, %00000000, %00000000, %00000000, %00000000, %00000000, %00000000

tileset_menus_end:

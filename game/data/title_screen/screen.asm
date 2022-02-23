.(
&title_screen_palette:
; Background
.byt $21,$0f,$21,$30, $21,$0f,$20,$00, $21,$20,$0f,$00, $21,$0f,$21,$21, ; 0 - logo, 1 - credits title, 2 - credits section, 3 - text and number with same colors
; Sprites
.byt $21,$0f,$21,$00, $21,$00,$00,$00, $21,$00,$00,$00, $21,$0f,$00,$31 ; 0 - text, 1,2 - unused, 3 - cloud

C0 = $DC
C1 = C0+1
C2 = C1+1
C3 = C2+1
C4 = C3+1
C5 = C4+1
C6 = C5+1
C7 = C6+1
C8 = C7+1
C9 = C8+1
CA = C9+1
CB = CA+1
CC = CA+2
CD = CA+3
CE = CA+4
CF = CA+5
CG = CA+6
CH = CA+7
CI = CA+8
CJ = CA+9
CK = CA+10
CL = CA+11
CM = CA+12
CN = CA+13
CO = CA+14
CP = CA+15
CQ = CA+16
CR = CA+17
CS = CA+18
CT = CA+19
CU = CA+20
CV = CA+21
CW = CA+22
CX = CA+23
CY = CA+24
CZ = CA+25

#define FOR_NES CF, CO, CR, $00, $02, CN, CE, CS
#define PRESS_ANY_BUTTON  CP, CR, CE, CS, CS, $00, $01, CA, CN, CY, $00, $01, CB, CU, CT, CT, CO, CN

#define TITLE_SCREEN_VERSION \
	CV, CE, CR, CS, CI, CO, CN, $00, $01, \
	C2, $00, $01, \
	CA, CL, CP, CH, CA, \
	C0+(GAME_VERSION_MINOR/10), C0+(GAME_VERSION_MINOR-((GAME_VERSION_MINOR/10)*10))

&title_screen_nametable:
.byt ZIPNT_ZEROS(32*3+6)
.byt                                $01, $02,  $03, $04, $05
.byt ZIPNT_ZEROS(21+6)
;    -------------------  -------------------  -------------------  -------------------  -------------------  -------------------  -------------------  -------------------
.byt                                $06, $07,  $08, $09, $0a, $0b,  $0c, $0d, $0e, $0b,  $0f, $10, $11, $12,  $13, $14, $0b, $0f,  $15
.byt ZIPNT_ZEROS(7+6)
.byt                                $16, $17,  $18, $19, $1a, $1b,  $19, $1c, $1a, $1b,  $1d, $1e, $1f, $20,  $21, $22, $1b, $1d,  $1e, $23
.byt ZIPNT_ZEROS(6+6)
.byt                                $24, $25,  $26, $27, $28, $1b,  $19, $1c, $1a, $29,  $2a, $2b, $1f, $2c,  $2d, $1a, $29, $2a,  $2e, $2f
.byt ZIPNT_ZEROS(6+6)
.byt                                $30, $31,  $32, $33, $34, $35,  $19, $1c, $1a, $36,  $37, $19, $1f, $38,  $39, $1a, $36, $3a,  $3b
.byt ZIPNT_ZEROS(7+6)
;    -------------------  -------------------  -------------------  -------------------  -------------------  -------------------  -------------------  -------------------
.byt                                $3c, $3d,  $3e, $3f, $40, $41,  $42, $43, $44, $29,  $45, $46, $47, $2c,  $48, $49, $29, $4a,  $4b, $4c
.byt ZIPNT_ZEROS(6+6)
.byt                                $4d, $4e,  $4f, $50,ZIPZ, $51,  $4f, $52, $53, $4f,  $54, $55, $4f, $4f,  $4f, $56, $4f, $57,  $4f, $58
.byt ZIPNT_ZEROS(6+2)
.byt           $59, $03,  $03, $03, $5a, $5b,            ZIPNT_ZEROS(7),           $5c,  $03, $5d, $5e, $05
.byt ZIPNT_ZEROS(12+2)
.byt           $5f, $60,  $61, $62, $63, $64,  $65, $66, $67, $68,  $69, $6a, $6b, $6c,  $61, $6d, $6e, $6f,  $70, $0b, $0f, $15,  $71, $72, $73, $74
.byt ZIPNT_ZEROS(4+2)
;    -------------------  -------------------  -------------------  -------------------  -------------------  -------------------  -------------------  -------------------
.byt           $75, $76,  $77, $78, $19, $77,  $79, $77, $79, $7a,  $7b, $7c, $7d, $76,  $77, $7e, $7f, $80,  $1a, $1b, $1d, $1e,  $81, $82, $83, $84,  $85
.byt ZIPNT_ZEROS(3+3)
.byt                $86,  $77, $78, $19, $77,  $79, $77, $79, $19,  $7b, $87,ZIPZ, $86,  $77, $88, $89, $8a,  $1a, $29, $2a, $2b,  $8b, $20, $19, $8c,  $8d
.byt ZIPNT_ZEROS(3+3)
.byt                $86,  $77, $78, $19, $77,  $79, $77, $79, $19,  $7b, $87,ZIPZ, $86,  $77, $78, $8e, $8f,  $1a, $36, $3a, $90,  $91, $92, $93, $94,  $95, $96
.byt ZIPNT_ZEROS(2+3)
.byt                $97,  $98, $99, $9a, $98,  $9b, $98, $9c, $9d,  $9e, $9f, $a0, $a1,  $98, $a2, $a3, $a4,  $44, $29, $4a, $a5,  $a6, $a7, $a8, $a9,  $aa, $ab
.byt ZIPNT_ZEROS(2+3)
;    -------------------  -------------------  -------------------  -------------------  -------------------  -------------------  -------------------  -------------------
.byt                $ac,  $4f, $ad, $ae, $4f,  $af, $4f, $4f, $b0,  $b1, $ad, $b2, $ac,  $4f, $4f, $b3, $b4,  $b5, $4f, $b6, $4f,  $b7, $51, $b3, $b8,  $b9, $ba
.byt ZIPNT_ZEROS(2+12)
.byt                                                                                 FOR_NES
.byt ZIPNT_ZEROS(12+32*5+8)
.byt                                                                             PRESS_ANY_BUTTON
;    -------------------  -------------------  -------------------  -------------------  -------------------  -------------------  -------------------  -------------------
.byt ZIPNT_ZEROS(8+32*2+13)
.byt                                                                                               TITLE_SCREEN_VERSION
.byt ZIPNT_ZEROS(2+32*3)
title_screen_nametable_attributes:
.byt ZIPNT_ZEROS(8+8+8+8+8+2)
.byt                       %11110000, %11110000, %11110000, %11110000
.byt ZIPNT_ZEROS(2+3)
.byt                                  %11110000, %11110000, %11110000, %11110000, %00110000
.byt ZIPNT_ZEROS(8)
title_screen_nametable_end:
.byt ZIPNT_END

#undef FOR_NES
#undef PRESS_ANY_BUTTON
#undef TITLE_SCREEN_VERSION
.)

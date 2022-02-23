.(
&title_screen_palette:
; Background
.byt $21,$0f,$21,$30, $21,$00,$00,$00, $21,$00,$00,$00, $21,$0f,$00,$00 ; 0 - logo, 1,2 - unused, 3 - text
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

#define FOR_NES CF, CO, CR, $00, $01, CN, CE, CS
#define PRESS_ANY_BUTTON  CP, CR, CE, CS, CS, $00, $01, CA, CN, CY, $00, $01, CB, CU, CT, CT, CO, CN

#define TITLE_SCREEN_VERSION \
	CV, CE, CR, CS, CI, CO, CN, $00, $01, \
	C2, $00, $01, \
	CA, CL, CP, CH, CA, \
	C0+(GAME_VERSION_MINOR/10), C0+(GAME_VERSION_MINOR-((GAME_VERSION_MINOR/10)*10))

#define ZZ1 ZIPZ
#define ZZ2 $00,$02

&title_screen_nametable:
.byt ZIPNT_ZEROS(32*3+6)
.byt                         $01,$02,$03,$04,$05
.byt ZIPNT_ZEROS(21+6)
;    --------------- --------------- --------------- --------------- --------------- -------------- ---------------- -------------------
.byt                         $06,$07,$08,$09,$0a,$0b,$0c,$0d,$0e,$0b,$0f,$10,$11,$12,$13,$14,$0b,$0f,$15
.byt ZIPNT_ZEROS(7+6)
.byt                         $16,$17,$18,$19,$1a,$1b,$19,$1c,$1a,$1b,$1d,$1e,$1f,$20,$21,$22,$1b,$1d,$1e,$23
.byt ZIPNT_ZEROS(6+6)
.byt                         $24,$25,$26,$27,$28,$1b,$19,$1c,$1a,$29,$2a,$2b,$1f,$2c,$2d,$1a,$29,$2a,$2e,$2f
.byt ZIPNT_ZEROS(6+6)
.byt                         $30,$31,$32,$33,$34,$35,$19,$1c,$1a,$36,$37,$19,$1f,$38,$39,$1a,$36,$3a,$3b
.byt ZIPNT_ZEROS(7+6)
;    --------------- --------------- --------------- --------------- --------------- -------------- ---------------- -------------------
.byt                         $3c,$3d,$3e,$3f,$40,$41,$42,$43,$44,$29,$45,$46,$47,$2c,$48,$49,$29,$4a,$4b,$4c
.byt ZIPNT_ZEROS(6+6)
.byt                         $4d,$4e,$4f,$50,ZZ1,$51,$4f,$52,$53,$4f,$54,$55,$4f,$4f,$4f,$56,$4f,$57,$4f,$58
.byt ZIPNT_ZEROS(6+2)
.byt         $59,$03,$03,$03,$5a,$5b,        ZIPNT_ZEROS(8),         $5c,$03,$5d,$5e,$5f
.byt ZIPNT_ZEROS(11+2)
.byt         $60,$61,$62,$63,$64,$65,$66,$67,$68,$69,$11,$12,$6a,ZZ1,$6b,$6c,$6d,$6e,$6f,$70,$71,$72,$73,$74,$75,$76,$05
.byt ZIPNT_ZEROS(3+2)
;    --------------- --------------- --------------- --------------- --------------- -------------- ---------------- -------------------
.byt         $77,$78,$79,$20,$19,$7a,$19,$7a,$19,$7b,$1f,$7c,$7d,ZZ1,$7e,$7f,$80,$81,$82,$83,$84,$85,$86,$87,$88,$89,$8a
.byt ZIPNT_ZEROS(3+3)
.byt             $78,$79,$20,$19,$7a,$19,$7a,$19,$19,$1f,$8b,  ZZ2,  $7e,$8c,$8d,$8e,$8f,$83,$90,$91,$92,$93,$19,$94,$95,$96
.byt ZIPNT_ZEROS(2+3)
.byt             $78,$79,$20,$19,$7a,$19,$7a,$19,$19,$1f,$8b,  ZZ2,  $7e,$7f,$19,$97,$98,$83,$99,$9a,$9b,$9c,$19,$9d,$9e,$9f
.byt ZIPNT_ZEROS(2+3)
.byt             $a0,$a1,$a2,$a3,$a4,$a5,$a4,$42,$a6,$47,$a7,  ZZ2,  $a8,$a9,$aa,$3f,$ab,$ac,$ad,$ae,$af,$b0,$b1,$b2,$b3,$b4,$b5
.byt ZIPNT_ZEROS(1+3)
;    --------------- --------------- --------------- --------------- --------------- -------------- ---------------- -------------------
.byt             $b6,$4f,$b7,$b8,$4f,$b9,$4f,$4f,$ba,$4f,$b7,  ZZ2,  $bb,$4f,$4f,$50,$bc,$bd,$be,$4e,$be,$bf,$c0,$50,$c1,$c2
.byt ZIPNT_ZEROS(2+12)
.byt                                                         FOR_NES
.byt ZIPNT_ZEROS(13+32*5+8)
.byt                                                     PRESS_ANY_BUTTON
;    --------------- --------------- --------------- --------------- --------------- -------------- ---------------- -------------------
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

#undef ZZ1
#undef ZZ2
#undef FOR_NES
#undef PRESS_ANY_BUTTON
#undef TITLE_SCREEN_VERSION
.)

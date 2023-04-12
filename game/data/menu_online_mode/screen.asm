.(
CA = TILE_CHAR_A
CB = TILE_CHAR_B
CC = TILE_CHAR_C
CD = TILE_CHAR_D
CE = TILE_CHAR_E
CF = TILE_CHAR_F
CG = TILE_CHAR_G
CH = TILE_CHAR_H
CI = TILE_CHAR_I
CJ = TILE_CHAR_J
CK = TILE_CHAR_K
CL = TILE_CHAR_L
CM = TILE_CHAR_M
CN = TILE_CHAR_N
CO = TILE_CHAR_O
CP = TILE_CHAR_P
CQ = TILE_CHAR_Q
CR = TILE_CHAR_R
CS = TILE_CHAR_S
CT = TILE_CHAR_T
CU = TILE_CHAR_U
CV = TILE_CHAR_V
CW = TILE_CHAR_W
CX = TILE_CHAR_X
CY = TILE_CHAR_Y
CZ = TILE_CHAR_Z

T0 = TILE_MENU_ONLINE_MODE_DIALOGS_00
T1 = TILE_MENU_ONLINE_MODE_DIALOGS_01
T2 = TILE_MENU_ONLINE_MODE_DIALOGS_02
T3 = TILE_MENU_ONLINE_MODE_DIALOGS_03
T4 = TILE_MENU_ONLINE_MODE_DIALOGS_04
T5 = TILE_MENU_ONLINE_MODE_DIALOGS_05
T6 = TILE_MENU_ONLINE_MODE_DIALOGS_06
T7 = TILE_MENU_ONLINE_MODE_DIALOGS_07
T8 = TILE_MENU_ONLINE_MODE_DIALOGS_08
T9 = TILE_MENU_ONLINE_MODE_DIALOGS_09
TA = TILE_MENU_ONLINE_MODE_DIALOGS_0A
TB = TILE_MENU_ONLINE_MODE_DIALOGS_0B
TC = TILE_MENU_ONLINE_MODE_DIALOGS_0C
TD = TILE_MENU_ONLINE_MODE_DIALOGS_0D
TE = TILE_MENU_ONLINE_MODE_DIALOGS_0E

&menu_online_mode_palette:
; Background
;    0-sky/inactive_box, 1-stars/active_box, 2-earth,         3-title
.byt $0f,$02,$11,$21,    $0f,$08,$28,$20,    $0f,$29,$02,$21, $0f,$28,$20,$21
; Sprites
;    0-earth,            1-cursor/ship,      2-unused,        3-unused
.byt $0f,$29,$02,$0f,    $0f,$28,$0f,$20,    $0f,$00,$00,$00, $0f,$00,$00,$00

&menu_online_mode_palette_transition:
; Background
;    0-sky/inactive_box, 1-stars/active_box, 2-earth,         3-title
.byt $21,$02,$11,$21,    $21,$08,$28,$20,    $21,$29,$02,$21, $21,$28,$20,$21
; Sprites
;    0-earth,            1-cursor/ship,      2-unused,        3-unused
.byt $21,$29,$02,$0f,    $21,$28,$0f,$20,    $21,$00,$00,$00, $21,$00,$00,$00

&menu_online_mode_nametable:
.byt $00,$6b
.byt
.byt
.byt                                                          $01,  $02, $03, $04, $05,  ZIPZ,$06, $03, $04,  $07, $08, $00,$15
;    -------------------  -------------------  -------------------  -------------------  -------------------  -------------------  -------------------  -------------------
.byt                                                          $09,  $0a, $0b, $0c, $0d,  $0e, $0f, $0b, $0c,  $10, $11, $00,$0c
.byt           $12, $13,  $14, $15, $00,$02,   $12, $13, ZIPZ,$16,  $00,$02,  $17, $15,  $00,$02,  $12, $13,  $14, $15, $00,$02,   $18, $13, $00,$03,        $19, $17, $15
.byt $18, $1a, $1b, $1c,  $1c, $1d, $1e, $1f,  $20, $21, $22, $23,  $24, $25, $26, $26,  $27, $1a, $1b, $1c,  $1c, $1d, $1e, $1f,  $20, $21, $22, $23,  $24, $25, $28, $26
.byt $26, $26, $29, $2a,  $2b,  CC,  CA,  CS,   CU,  CA,  CL, $2b,  $2b, $2c, $26, $26,  $26, $26, $29, $2a,  $2b,  CR,  CA, CN,   CK,  CE,  CD, $2b,  $2b, $2c, $26, $26
;    -------------------  -------------------  -------------------  -------------------  -------------------  -------------------  -------------------  -------------------
.byt $26, $26, $2d, $2e,  $2b, $2b, $2b, $2f,  $2b, $2b, $2b, $30,  $2b, $31, $26, $26,  $26, $26, $2d, $2e,  $2b, $2b, $32, $33,  $34, $35, $2b, $30,  $2b, $31, $26, $26
.byt $26, $26, $36, $2b,  $2b, $2b, $37, $38,  $39, $3a, $2b, $3b,  $3c, $3d, $26, $26,  $26, $26, $36, $2b,  $2b, $2b, $3e, $3f,  $40, $41, $2b, $3b,  $3c, $3d, $26, $26
.byt $26, $26, $42, $2b,  $43, $2b, $44, $45,  $46, $47, $2b, $2b,  $48, $49, $4a, $4b,  $4c, $4d, $42, $2b,  $43, $2b, $4e, $4f,  $50, $51, $2b, $2b,  $48, $49, $26, $26
.byt $26, $26, $52, $53,  $54, $55, $56, $57,  $58, $59, $2b, $2b,  $2b, $5a, $5b, $5c,  $5d, $5e, $52, $53,  $54, $55, $5f, $60,  $61, $2b, $2b, $2b,  $2b, $5a, $26, $26
;    -------------------  -------------------  -------------------  -------------------  -------------------  -------------------  -------------------  -------------------
.byt $26, $26, $62, $2b,  $2b, $2b, $2b, $63,  $64, $2b, $2b, $65,  $66, $67, $68, $69,  $6a, $6b, $62, $2b,  $2b, $2b, $2b, $63,  $64, $2b, $2b, $65,  $66, $67, $26, $26
.byt $26, $26, $6c, $6d,  $6e, $6f, $70, $71,  $72, $73, $74, $75,  $76, $77, $2b, $2b,  $78, $79, $6c, $6d,  $6e, $6f, $70, $71,  $72, $73, $74, $75,  $76, $77, $26, $26
.byt $26, $26, $26, $26,  $26, $26, $7a, $26,  $26, $26, $7b, $7c,  $7d, $2b, $2b, $7e,  $7f, $80, $80, $80,  $81, $82, $26, $26,  $26, $26, $26, $26,  $26, $26, $26, $26
.byt $26, $26, $26, $26,  $26, $26, $26, $26,  $26, $26, $83, $84,  $2b, $2b, $2b, $85,  $80, $80, $80, $80,  $86, $87, $26, $26,  $26, $88, $26, $26,  $26, $26, $26, $26
;    -------------------  -------------------  -------------------  -------------------  -------------------  -------------------  -------------------  -------------------
.byt $26, $26, $26, $88,  $26, $26, $26, $26,  $26, $26, $89, $8a,  $8b, $8c, $2b, $3b,  $8d, $8e, $8f, $80,  $90, $91, $26, $26,  $26, $26, $26, $26,  $26, $92, $26, $26
.byt $26, $26, $26, $26,  $26, $26, $26, $92,  $26, $26, $93, $94,  $80, $95, $96, $97,  $2b, $2b, $98, $80,  $99, $9a, $26, $26,  $26, $26, $26, $26,  $26, $26, $26, $26
.byt $26, $26, $1b, $1c,  $1c, $1d, $1e, $1f,  $20, $21, $22, $9b,  $9c, $25, $9d, $9e,  $2b, $2b, $1b, $1c,  $1c, $1d, $1e, $1f,  $20, $21, $22, $23,  $24, $25, $26, $26
.byt $26, $26, $29, $2a,  $2b,  CP,  CR,  CI,   CV,  CA,  CT,  CE,  $2b, $9f, $a0, $2b,  $2b, $2b, $29, $2a,   CS,  CE,  CT,  CT,   CI,  CN,  CG,  CS,  $2b, $2c, $26, $26
;    -------------------  -------------------  -------------------  -------------------  -------------------  -------------------  -------------------  -------------------
.byt $26, $26, $2d, $2e,  $2b, $2b, $2b, $a1,  $a2, $2b, $2b, $30,  $2b, $31, $a3, $2b,  $2b, $a4, $a5, $2e,  $2b, $2b, $a6, $a7,  $a8, $2b, $2b, $30,  $2b, $31, $26, $26
.byt $26, $26, $36, $2b,  $2b, $2b, $2b, $a9,  $aa, $2b, $2b, $3b,  $3c, $3d, $ab, $ac,  $ad, $ae, $af, $2b,  $2b, $b0, $b1, $b2,  $b3, $a2, $2b, $3b,  $3c, $3d, $26, $26
.byt $26, $26, $42, $2b,  $43, $2b, $2b, $b4,  $b5, $2b, $2b, $2b,  $48, $49, $26, $26,  $26, $26, $42, $2b,  $43, $2b, $b6, $b7,  $b8, $b9, $ba, $2b,  $48, $49, $26, $26
.byt $26, $26, $52, $53,  $54, $55, $bb, $bc,  $bc, $bd, $2b, $2b,  $2b, $5a, $26, $26,  $26, $26, $52, $53,  $54, $55, $56, $be,  $bf, $c0, $c1, $2b,  $2b, $5a, $26, $26
;    -------------------  -------------------  -------------------  -------------------  -------------------  -------------------  -------------------  -------------------
.byt $26, $26, $62, $2b,  $2b, $2b, $2b, $63,  $64, $2b, $2b, $65,  $66, $67, $26, $26,  $26, $26, $62, $2b,  $2b, $2b, $2b, $63,  $64, $2b, $2b, $65,  $66, $67, $26, $26
.byt $26, $26, $6c, $6d,  $6e, $6f, $70, $71,  $72, $73, $74, $75,  $76, $77, $26, $26,  $26, $26, $6c, $6d,  $6e, $6f, $70, $71,  $72, $73, $74, $75,  $76, $77, $26, $26
.byt $26, $26, $c2, $c3,  $c4, $c5, $26, $26,  $c2, $c3, $26, $26,  $26, $26, $c4, $c5,  $26, $26, $c2, $c3,  $c4, $c5, $26, $26,  $c6, $c3, $26, $26,  $26, $26, $c4, $c5
.byt $c7, $c8, $00,$04,             $c9, $c8,  $00,$02,  $c9, $c7,  $c9, $c8, $00,$02,   $c9, $c8, $00,$04,             $c9, $c8,  $00,$02,  $c9, $c4,  $c9, $c8, $00,$44
;    -------------------  -------------------  -------------------  -------------------  -------------------  -------------------  -------------------  -------------------
.byt
.byt
.byt
menu_online_mode_nametable_attributes:
.byt           $cc, $ff, $ff, $33,                $00,$02
.byt $40, $50, $5c, $1f, $0f, $03,                $00,$02
.byt $44, $55, $55, $91, $20,                     $00,$03
.byt $04, $55, $85, $a9, $a2, $20, $10,           $00,$01
.byt $04, $04, $08, $8a, $2a, $02, $00,$01, $01,  $00,$03
.byt                $08, $02,
.byt $00,$13
menu_online_mode_nametable_end:
.byt ZIPNT_END

&menu_online_mode_login_window:
.byt 20, 10 ; width, height (in tiles)
.byt T0, T1, T1, T1, T1, T1, T1, T1, T1, T1, T1, T1, T1, T1, T1, T1, T1, T1, T1, T2
.byt T3, T4, T4, T4, T4, T4, T4, T4, T4, T4, T4, T4, T4, T4, T4, T4, T4, T4, T4, T5
.byt T3, T4, CU, CS, CE, CR, T4, CN, CA, CM, CE, T4, T4, T4, T4, T4, T4, T4, T4, T5
.byt T3, T4, T6, T6, T6, T6, T6, T6, T6, T6, T6, T6, T6, T6, T6, T6, T6, T6, T4, T5
.byt T3, T4, T4, T4, T4, T4, T4, T4, T4, T4, T4, T4, T4, T4, T4, T4, T4, T4, T4, T5
.byt T3, T4, CP, CA, CS, CS, CW, CO, CR, CD, T4, T4, T4, T4, T4, T4, T4, T4, T4, T5
.byt T3, T4, T6, T6, T6, T6, T6, T6, T6, T6, T6, T6, T6, T6, T6, T6, T6, T6, T4, T5
.byt T3, T4, T4, T4, T4, T4, T4, T4, T4, T4, T4, T4, T4, T4, T4, T4, T4, T4, T4, T5
.byt T3, T4, T7, T8, T9, TA, T4, CO, CK, T4, T4, T4, TB, T4, CB, CA, CC, CK, T4, T5
.byt TC, TD, TD, TD, TD, TD, TD, TD, TD, TD, TD, TD, TD, TD, TD, TD, TD, TD, TD, TE

&menu_online_mode_game_password_window:
.byt 20, 10 ; width, height (in tiles)
.byt T0, T1, T1, T1, T1, T1, T1, T1, T1, T1, T1, T1, T1, T1, T1, T1, T1, T1, T1, T2
.byt T3, T4, CS, CH, CA, CR, CE, T4, CP, CA, CS, CS, CW, CO, CR, CD, T4, T4, T4, T5
.byt T3, T4, CW, CI, CT, CH, T4, CY, CO, CU, CR, T4, CF, CR, CI, CE, CN, CD, T4, T5
.byt T3, T4, T4, T4, T4, T4, T4, T4, T4, T4, T4, T4, T4, T4, T4, T4, T4, T4, T4, T5
.byt T3, T4, T4, T4, T4, T4, T4, T4, T4, T4, T4, T4, T4, T4, T4, T4, T4, T4, T4, T5
.byt T3, T4, CG, CA, CM, CE, T4, CP, CA, CS, CS, CW, CO, CR, CD, T4, T4, T4, T4, T5
.byt T3, T4, T6, T6, T6, T6, T6, T6, T6, T6, T6, T6, T6, T6, T6, T6, T6, T6, T4, T5
.byt T3, T4, T4, T4, T4, T4, T4, T4, T4, T4, T4, T4, T4, T4, T4, T4, T4, T4, T4, T5
.byt T3, T4, T7, T8, T9, TA, T4, CO, CK, T4, T4, T4, TB, T4, CB, CA, CC, CK, T4, T5
.byt TC, TD, TD, TD, TD, TD, TD, TD, TD, TD, TD, TD, TD, TD, TD, TD, TD, TD, TD, TE

&menu_online_mode_setting_select_window:
.byt 20, 10 ; width, height (in tiles)
.byt T0, T1, T1, T1, T1, T1, T1, T1, T1, T1, T1, T1, T1, T1, T1, T1, T1, T1, T1, T2
.byt T3, T4, CN, CE, CT, CW, CO, CR, CK, T4, CS, CE, CT, CT, CI, CN, CG, CS, T4, T5
.byt T3, T4, T4, T4, T4, T4, T4, T4, T4, T4, T4, T4, T4, T4, T4, T4, T4, T4, T4, T5
.byt T3, T4, CC, CR, CE, CA, CT, CE, T4, CA, CC, CC, CO, CU, CN, CT, T4, T4, T4, T5
.byt T3, T4, CW, CI, CF, CI, T4, CS, CE, CT, CT, CI, CN, CG, T4, T4, T4, T4, T4, T5
.byt T3, T4, CG, CA, CM, CE, T4, CU, CP, CD, CA, CT, CE, T4, T4, T4, T4, T4, T4, T5
.byt T3, T4, T4, T4, T4, T4, T4, T4, T4, T4, T4, T4, T4, T4, T4, T4, T4, T4, T4, T5
.byt T3, T4, T4, T4, T4, T4, T4, T4, T4, T4, T4, T4, T4, T4, T4, T4, T4, T4, T4, T5
.byt T3, T4, T7, T8, T9, TA, T4, CO, CK, T4, T4, T4, TB, T4, CB, CA, CC, CK, T4, T5
.byt TC, TD, TD, TD, TD, TD, TD, TD, TD, TD, TD, TD, TD, TD, TD, TD, TD, TD, TD, TE

&menu_online_mode_deny_update_game_window:
.byt 20, 10 ; width, height (in tiles)
.byt T0, T1, T1, T1, T1, T1, T1, T1, T1, T1, T1, T1, T1, T1, T1, T1, T1, T1, T1, T2
.byt T3, T4, CN, CO, CT, T4, CO, CN, T4, CE, CM, CU, CL, CA, CT, CO, CR, T4, T4, T5
.byt T3, T4, T4, T4, T4, T4, T4, T4, T4, T4, T4, T4, T4, T4, T4, T4, T4, T4, T4, T5
.byt T3, T4, CP, CL, CE, CA, CS, CE, T4, CD, CO, CW, CN, CL, CO, CA, CD, T4, T4, T5
.byt T3, T4, CT, CH, CE, T4, CL, CA, CT, CE, CS, CT, T4, T4, T4, T4, T4, T4, T4, T5
.byt T3, T4, CV, CE, CR, CS, CI, CO, CN, T4, CM, CA, CN, CU, CA, CL, CL, CY, T4, T5
.byt T3, T4, T4, T4, T4, T4, T4, T4, T4, T4, T4, T4, T4, T4, T4, T4, T4, T4, T4, T5
.byt T3, T4, T4, T4, T4, T4, T4, T4, T4, T4, T4, T4, T4, T4, T4, T4, T4, T4, T4, T5
.byt T3, T4, T4, T4, T4, T4, T4, T4, T4, T4, T4, T4, T4, T4, T4, T4, T4, T4, T4, T5
.byt TC, TD, TD, TD, TD, TD, TD, TD, TD, TD, TD, TD, TD, TD, TD, TD, TD, TD, TD, TE

&menu_online_mode_deny_wifi_settings_window:
.byt 20, 10 ; width, height (in tiles)
.byt T0, T1, T1, T1, T1, T1, T1, T1, T1, T1, T1, T1, T1, T1, T1, T1, T1, T1, T1, T2
.byt T3, T4, CN, CO, CT, T4, CO, CN, T4, CE, CM, CU, CL, CA, CT, CO, CR, T4, T4, T5
.byt T3, T4, T4, T4, T4, T4, T4, T4, T4, T4, T4, T4, T4, T4, T4, T4, T4, T4, T4, T5
.byt T3, T4, CT, CH, CE, T4, CE, CM, CU, CL, CA, CT, CO, CR, T4, CU, CS, CE, CS, T5
.byt T3, T4, CY, CO, CU, CR, T4, CI, CN, CT, CE, CR, CN, CE, CT, T4, T4, T4, T4, T5
.byt T3, T4, T4, T4, T4, T4, T4, T4, T4, T4, T4, T4, T4, T4, T4, T4, T4, T4, T4, T5
.byt T3, T4, CN, CO, T4, CS, CP, CE, CC, CI, CF, CI, CC, T4, T4, T4, T4, T4, T4, T5
.byt T3, T4, CS, CE, CT, CT, CI, CN, CG, T4, CR, CE, CQ, CU, CI, CR, CE, CD, T4, T5
.byt T3, T4, T4, T4, T4, T4, T4, T4, T4, T4, T4, T4, T4, T4, T4, T4, T4, T4, T4, T5
.byt TC, TD, TD, TD, TD, TD, TD, TD, TD, TD, TD, TD, TD, TD, TD, TD, TD, TD, TD, TE
.)

menu_online_mode_palette:
; Background
.byt $21,$0f,$12,$19, $21,$20,$28,$00, $21,$0f,$20,$20, $21,$0f,$20,$10 ; 0-earth, 1-active_box, 2-alphanumeric, 3-title ;TODO use 3 for alphanumeric and fix digit charset to share same bg color than letters
; Sprites
.byt $21,$0f,$12,$19, $21,$28,$0f,$20, $21,$00,$00,$00, $21,$00,$00,$00 ; 0-earth, 1-cursor/ship, 2-unused, 3-unused

menu_online_mode_nametable:
.byt $00,$62
.byt
.byt
.byt           $01, $02,  $03, $04, $05, $06,  $07, $05, $08, $03,  $03, $03, $03, $03,  $03, $03, $03, $03,  $03, $03, $03, $03,  $03, $03, $03, $03,  $03, $03, $00,$04
;    -------------------  -------------------  -------------------  -------------------  -------------------  -------------------  -------------------  -------------------
.byt           $09, $0a,  $00,$3e
.byt
.byt           $0b, $0c,  $0c, $0c, $0c, $0c,  $0c, $0c, $0c, $0c,  $0c, $0d, $00,$04,             $0b, $0c,  $0c, $0c, $0c, $0c,  $0c, $0c, $0c, $0c,  $0c, $0d, $00,$04
.byt           $0e, $03,  $03, $03, $03, $03,  $03, $03, $03, $03,  $03, $0f, $00,$04,             $0e, $03,  $03, $03, $03, $03,  $03, $03, $03, $03,  $03, $0f, $00,$04
;    -------------------  -------------------  -------------------  -------------------  -------------------  -------------------  -------------------  -------------------
.byt           $0e, $03,  $03, $03, $03, $03,  $03, $03, $03, $03,  $03, $0f, $00,$04,             $0e, $03,  $03, $03, $03, $03,  $03, $03, $03, $03,  $03, $0f, $00,$04
.byt           $0e, $03,  $03, $10, $11, $12,  $13, $11, $06, $03,  $03, $0f, $00,$04,             $0e, $03,  $03, $14, $11, $05,  $15, $08, $16, $03,  $03, $0f, $00,$04
.byt           $0e, $03,  $03, $03, $03, $03,  $03, $03, $03, $03,  $03, $0f, $17, $18,  $19, $1a, $0e, $03,  $03, $03, $03, $03,  $03, $03, $03, $03,  $03, $0f, $00,$04
.byt           $0e, $03,  $03, $03, $03, $03,  $03, $03, $03, $03,  $03, $0f, $1b, $1c,  $03, $1d, $0e, $03,  $03, $03, $03, $03,  $03, $03, $03, $03,  $03, $0f, $00,$04
;    -------------------  -------------------  -------------------  -------------------  -------------------  -------------------  -------------------  -------------------
.byt           $0e, $03,  $03, $03, $03, $03,  $03, $03, $03, $03,  $03, $0f, $1e, $1f,  $20, $21, $0e, $03,  $03, $03, $03, $03,  $03, $03, $03, $03,  $03, $0f, $00,$04
.byt           $22, $23,  $23, $23, $23, $23,  $23, $23, $23, $23,  $23, $24, $03, $03,  $25, $26, $22, $23,  $23, $23, $23, $23,  $23, $23, $23, $23,  $23, $24, $00,$0c
.byt                                                     $27, $28,  $1f, $03, $03, $29,  $2a, $2b, $2b, $2b,  $2c, $2d, $00,$14
.byt                                                     $2e, $2f,  $03, $03, $03, $30,  $2b, $2b, $2b, $2b,  $31, $32, $00,$14
;    -------------------  -------------------  -------------------  -------------------  -------------------  -------------------  -------------------  -------------------
.byt                                                     $33, $34,  $35, $36, $03, $37,  $38, $39, $3a, $2b,  $2b, $3b, $00,$14
.byt                                                     $3c, $3d,  $2b, $3e, $3f, $40,  $03, $03, $41, $2b,  $42, $43, $00,$0c
.byt           $0b, $0c,  $0c, $0c, $0c, $0c,  $0c, $0c, $0c, $0c,  $0c, $0d, $42, $44,  $03, $03, $0b, $0c,  $0c, $0c, $0c, $0c,  $0c, $0c, $0c, $0c,  $0c, $0d, $00,$04
.byt           $0e, $03,  $03, $03, $03, $03,  $03, $03, $03, $03,  $03, $0f, $45, $03,  $03, $03, $0e, $03,  $03, $03, $03, $03,  $03, $03, $03, $03,  $03, $0f, $00,$04
;    -------------------  -------------------  -------------------  -------------------  -------------------  -------------------  -------------------  -------------------
.byt           $0e, $03,  $03, $03, $03, $03,  $03, $03, $03, $03,  $03, $0f, $46, $03,  $03, $03, $0e, $03,  $03, $03, $03, $03,  $03, $03, $03, $03,  $03, $0f, $00,$04
.byt           $0e, $03,  $47, $14, $07, $48,  $11, $49, $08, $03,  $03, $0f, $4a, $4b,  $4c, $4d, $0e, $03,  $12, $08, $49, $49,  $07, $05, $4e, $12,  $03, $0f, $00,$04
.byt           $0e, $03,  $03, $03, $03, $03,  $03, $03, $03, $03,  $03, $0f, $00,$04,             $0e, $03,  $03, $03, $03, $03,  $03, $03, $03, $03,  $03, $0f, $00,$04
.byt           $0e, $03,  $03, $03, $03, $03,  $03, $03, $03, $03,  $03, $0f, $00,$04,             $0e, $03,  $03, $03, $03, $03,  $03, $03, $03, $03,  $03, $0f, $00,$04
;    -------------------  -------------------  -------------------  -------------------  -------------------  -------------------  -------------------  -------------------
.byt           $0e, $03,  $03, $03, $03, $03,  $03, $03, $03, $03,  $03, $0f, $00,$04,             $0e, $03,  $03, $03, $03, $03,  $03, $03, $03, $03,  $03, $0f, $00,$04
.byt           $22, $23,  $23, $23, $23, $23,  $23, $23, $23, $23,  $23, $24, $00,$04,             $22, $23,  $23, $23, $23, $23,  $23, $23, $23, $23,  $23, $24, $00,$82
.byt
.byt
;    -------------------  -------------------  -------------------  -------------------  -------------------  -------------------  -------------------  -------------------
.byt
.byt
.byt
menu_online_mode_nametable_attributes:
.byt %11111111, %11111111, %11111111, %11111111, %11111111, %11111111, %11111111, %11111111
.byt %00001111
.byt ZIPNT_ZEROS(7+8*6)
menu_online_mode_nametable_end:
.byt ZIPNT_END

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

	&menu_online_mode_connexion_window:
	.byt 20, 10 ; width, height (in tiles)
	.byt T0, T1, T1, T1, T1, T1, T1, T1, T1, T1, T1, T1, T1, T1, T1, T1, T1, T1, T1, T2
	.byt T3, T4, T4, T4, T4, T4, T4, T4, T4, T4, T4, T4, T4, T4, T4, T4, T4, T4, T4, T5
	.byt T3, T4, T4, T4, T4, T4, T4, T4, T4, T4, T4, T4, T4, T4, T4, T4, T4, T4, T4, T5
	.byt T3, T4, T4, T4, T4, T4, T4, T4, T4, T4, T4, T4, T4, T4, T4, T4, T4, T4, T4, T5
	.byt T3, T4, T4, T4, T4, T4, T4, T4, T4, T4, T4, T4, T4, T4, T4, T4, T4, T4, T4, T5
	.byt T3, T4, T4, T4, CC, CO, CN, CN, CE, CC, CT, CI, CO, CN, T6, T6, T6, T4, T4, T5
	.byt T3, T4, T4, T4, T4, T4, T4, T4, T4, T4, T4, T4, T4, T4, T4, T4, T4, T4, T4, T5
	.byt T3, T4, T4, T4, T4, T4, T4, T4, T4, T4, T4, T4, T4, T4, T4, T4, T4, T4, T4, T5
	.byt T3, T4, T4, T4, T4, T4, T4, T4, T4, T4, T4, T4, T4, T4, T4, T4, T4, T4, T4, T5
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

	&menu_online_mode_check_update_window:
	.byt 20, 10 ; width, height (in tiles)
	.byt T0, T1, T1, T1, T1, T1, T1, T1, T1, T1, T1, T1, T1, T1, T1, T1, T1, T1, T1, T2
	.byt T3, T4, T4, T4, T4, T4, T4, T4, T4, T4, T4, T4, T4, T4, T4, T4, T4, T4, T4, T5
	.byt T3, T4, T4, T4, T4, T4, T4, T4, T4, T4, T4, T4, T4, T4, T4, T4, T4, T4, T4, T5
	.byt T3, T4, T4, T4, T4, T4, T4, T4, T4, T4, T4, T4, T4, T4, T4, T4, T4, T4, T4, T5
	.byt T3, T4, T4, T4, T4, T4, T4, T4, T4, T4, T4, T4, T4, T4, T4, T4, T4, T4, T4, T5
	.byt T3, T4, T4, T4, CC, CO, CN, CN, CE, CC, CT, CI, CO, CN, T6, T6, T6, T4, T4, T5
	.byt T3, T4, T4, T4, T4, T4, T4, T4, T4, T4, T4, T4, T4, T4, T4, T4, T4, T4, T4, T5
	.byt T3, T4, T4, T4, T4, T4, T4, T4, T4, T4, T4, T4, T4, T4, T4, T4, T4, T4, T4, T5
	.byt T3, T4, T4, T4, T4, T4, T4, T4, T4, T4, T4, T4, T4, T4, T4, T4, T4, T4, T4, T5
	.byt TC, TD, TD, TD, TD, TD, TD, TD, TD, TD, TD, TD, TD, TD, TD, TD, TD, TD, TD, TE
.)

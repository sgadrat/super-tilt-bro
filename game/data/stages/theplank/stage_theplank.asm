.(
+STAGE_THEPLANK_BANK_NUMBER = CURRENT_BANK_NUMBER

+stage_theplank_data:
STAGE_HEADER($5800, $a800, $63ff, $63ff, $8000, $3bff) ; player_a_x, player_b_x, player_a_y, player_b_y, respawn_x, respawn_y
; Platforms
PLATFORM($28, $d0, $7f, $ef) ; left, right, top, bot
SMOOTH_PLATFORM($40, $c0, $63) ; left, right, top
END_OF_STAGE

; Illustration
.(
BAC = 0
#define SMO TILE_MENU_CHAR_SELECT_STAGE_SMOOTH
#define PLT TILE_MENU_CHAR_SELECT_STAGE_PLATFORM
C_A = TILE_CHAR_A
C_B = C_A + 1
C_C = C_A + 2
C_D = C_A + 3
C_E = C_A + 4
C_F = C_A + 5
C_G = C_A + 6
C_H = C_A + 7
C_I = C_A + 8
C_J = C_A + 9
C_K = C_A + 10
C_L = C_A + 11
C_M = C_A + 12
C_N = C_A + 13
C_O = C_A + 14
C_P = C_A + 15
C_Q = C_A + 16
C_R = C_A + 17
C_S = C_A + 18
C_T = C_A + 19
C_U = C_A + 20
C_V = C_A + 21
C_W = C_A + 22
C_X = C_A + 23
C_Y = C_A + 24
C_Z = C_A + 25

+stage_theplank_illustration:
.byt BAC, BAC, BAC, BAC, BAC, BAC, BAC, BAC, BAC, BAC, BAC, BAC
.byt BAC, BAC, BAC, BAC, BAC, BAC, BAC, BAC, BAC, BAC, BAC, BAC
.byt BAC, BAC, BAC, BAC, BAC, BAC, BAC, BAC, BAC, BAC, BAC, BAC
.byt C_T, BAC, BAC, BAC, BAC, BAC, PLT, PLT, PLT, PLT, PLT, PLT
.byt C_H, BAC, BAC, BAC, BAC, BAC, PLT, PLT, PLT, PLT, PLT, PLT
.byt C_E, BAC, BAC, BAC, SMO, BAC, PLT, PLT, PLT, PLT, PLT, PLT
.byt BAC, BAC, BAC, BAC, SMO, BAC, PLT, PLT, PLT, PLT, PLT, PLT
.byt C_P, BAC, BAC, BAC, SMO, BAC, PLT, PLT, PLT, PLT, PLT, PLT
.byt C_L, BAC, BAC, BAC, SMO, BAC, PLT, PLT, PLT, PLT, PLT, PLT
.byt C_A, BAC, BAC, BAC, SMO, BAC, PLT, PLT, PLT, PLT, PLT, PLT
.byt C_N, BAC, BAC, BAC, SMO, BAC, PLT, PLT, PLT, PLT, PLT, PLT
.byt C_K, BAC, BAC, BAC, BAC, BAC, PLT, PLT, PLT, PLT, PLT, PLT
.byt BAC, BAC, BAC, BAC, BAC, BAC, PLT, PLT, PLT, PLT, PLT, PLT
.byt BAC, BAC, BAC, BAC, BAC, BAC, BAC, BAC, BAC, BAC, BAC, BAC
.byt BAC, BAC, BAC, BAC, BAC, BAC, BAC, BAC, BAC, BAC, BAC, BAC
.byt BAC, BAC, BAC, BAC, BAC, BAC, BAC, BAC, BAC, BAC, BAC, BAC

#undef SMO
#undef PLT
.)

#include "game/data/stages/theplank/screen.asm"
#include "game/data/stages/theplank/logic.built.asm"
.)

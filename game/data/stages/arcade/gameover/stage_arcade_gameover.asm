.(
+STAGE_ARCADE_GAMEOVER_BANK_NUMBER = CURRENT_BANK_NUMBER

+stage_arcade_gameover_data:
STAGE_HEADER($4c00, $ac00, $6fff, $6fff, $7c00, $3fff) ; player_a_x, player_b_x, player_a_y, player_b_y, respawn_x, respawn_y
; Platforms
OOS_PLATFORM($ffc8, $012f, $006f, $0101) ; left, right, top, bot
OOS_PLATFORM($ffc8, $012f, $ffe5, $002f) ; left, right, top, bot
END_OF_STAGE

#include "game/data/stages/arcade/gameover/screen.asm"
#include "game/data/stages/arcade/gameover/logic.built.asm"
.)

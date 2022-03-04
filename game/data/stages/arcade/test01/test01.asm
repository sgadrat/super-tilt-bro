STAGE_ARCADE_TEST01_BANK_NUMBER = CURRENT_BANK_NUMBER

#define ARCADE_EXIT(left,right,top,bot) .byt <left, >left, <right, >right, <top, >top, <bot, >bot

stage_arcade_test01_data_header:
ARCADE_EXIT($ff00, $01ff, $48, $58)
stage_arcade_test01_data:
STAGE_HEADER($4000, $a000, $80ff, $80ff, $8000, $9000) ; player_a_x, player_b_x, player_a_y, player_b_y, respawn_x, respawn_y
stage_arcade_test01_elements:
PLATFORM($28, $d0, $a8, $ff) ; left, right, top, bot
SMOOTH_PLATFORM($18, $68, $80) ; left, right, top
SMOOTH_PLATFORM($90, $e0, $80) ; left, right, top
SMOOTH_PLATFORM($48, $b0, $50) ; left, right, top
END_OF_STAGE

#include "game/data/stages/arcade/test01/screen.asm"

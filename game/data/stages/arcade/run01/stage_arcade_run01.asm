STAGE_ARCADE_RUN01_BANK_NUMBER = CURRENT_BANK_NUMBER

stage_arcade_run01_data_header:
ARCADE_EXIT($00c0, $00c7, $0028, $002f) ; left, right, top, bot
stage_arcade_run01_data:
STAGE_HEADER($2800, $8000, $c7ff, $8000, $8000, $8000) ; player_a_x, player_b_x, player_a_y, player_b_y, respawn_x, respawn_y
stage_arcade_run01_platforms:
PLATFORM($01, $fe, $00, $17) ; left, right, top, bot
PLATFORM($01, $18, $07, $ef) ; left, right, top, bot
PLATFORM($e0, $fe, $07, $ef) ; left, right, top, bot
PLATFORM($38, $60, $7f, $ef) ; left, right, top, bot
PLATFORM($10, $40, $c7, $ef) ; left, right, top, bot
PLATFORM($58, $e8, $c7, $ef) ; left, right, top, bot
SMOOTH_PLATFORM($b1, $cf, $29) ; left, right, top
SMOOTH_PLATFORM($91, $bf, $59) ; left, right, top
SMOOTH_PLATFORM($99, $d7, $81) ; left, right, top
SMOOTH_PLATFORM($11, $27, $99) ; left, right, top
SMOOTH_PLATFORM($81, $bf, $a9) ; left, right, top
END_OF_STAGE

#include "game/data/stages/arcade/run01/screen.asm"

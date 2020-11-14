STAGE_SHELF_BANK_NUMBER = CURRENT_BANK_NUMBER

stage_shelf_data:
STAGE_HEADER($4000, $a000, $80ff, $80ff, $8000, $9000) ; player_a_x, player_b_x, player_a_y, player_b_y, respawn_x, respawn_y
stage_shelf_elements:
PLATFORM($28, $d0, $a8, $ff) ; left, right, top, bot
SMOOTH_PLATFORM($18, $68, $80) ; left, right, top
SMOOTH_PLATFORM($90, $e0, $80) ; left, right, top
SMOOTH_PLATFORM($48, $b0, $50) ; left, right, top
END_OF_STAGE

#include "game/data/stages/shelf/screen.asm"

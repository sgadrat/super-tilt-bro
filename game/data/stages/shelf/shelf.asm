STAGE_SHELF_BANK_NUMBER = CURRENT_BANK_NUMBER

stage_shelf_data:
STAGE_HEADER($4000, $a000, $82ff, $82ff, $8000, $9000) ; player_a_x, player_b_x, player_a_y, player_b_y, respawn_x, respawn_y
stage_shelf_platforms:
PLATFORM($29, $cf, $a9, $ff) ; left, right, top, bot
SMOOTH_PLATFORM($19, $67, $83) ; left, right, top
SMOOTH_PLATFORM($91, $df, $83) ; left, right, top
SMOOTH_PLATFORM($49, $af, $53) ; left, right, top
END_OF_STAGE

#include "game/data/stages/shelf/screen.asm"

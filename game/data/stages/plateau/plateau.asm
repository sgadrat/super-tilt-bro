STAGE_PLATEAU_BANK_NUMBER = CURRENT_BANK_NUMBER

stage_plateau_data:
STAGE_HEADER($4000, $a000, $80ff, $80ff, $7000, $6000) ; player_a_x, player_b_x, player_a_y, player_b_y, respawn_x, respawn_y
stage_plateau_platforms:
PLATFORM($21, $d7, $81, $ff)
END_OF_STAGE

#include "game/data/stages/plateau/screen.asm"

STAGE_SKYRIDE_BANK_NUMBER = CURRENT_BANK_NUMBER

STAGE_SKYRIDE_BLAST_LEFT = -48
STAGE_SKYRIDE_BLAST_RIGHT = 296
STAGE_SKYRIDE_BLAST_TOP = -40
STAGE_SKYRIDE_BLAST_BOTTOM = STAGE_BLAST_BOTTOM

stage_skyride_data:
STAGE_HEADER($4000, $a000, $80ff, $80ff, $8000, $9000) ; player_a_x, player_b_x, player_a_y, player_b_y, respawn_x, respawn_y
stage_skyride_elements:
PLATFORM($28, $d0, $a8, $ff) ; left, right, top, bot
SMOOTH_PLATFORM($18, $68, $80) ; left, right, top
SMOOTH_PLATFORM($90, $e0, $80) ; left, right, top
SMOOTH_PLATFORM($48, $b0, $50) ; left, right, top
END_OF_STAGE

#include "game/data/stages/skyride/screen.asm"
#include "game/data/stages/skyride/illustration.asm"
#include "game/data/stages/skyride/logic.built.asm"

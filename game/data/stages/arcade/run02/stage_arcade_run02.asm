.(
+STAGE_ARCADE_RUN02_BANK_NUMBER = CURRENT_BANK_NUMBER

+stage_arcade_run02_data_header:
ARCADE_EXIT($00ec, $0103, $0028, $0057) ; left, right, top, bot
+stage_arcade_run02_data:
STAGE_HEADER($1800, $8000, $afff, $8000, $8000, $8000) ; player_a_x, player_b_x, player_a_y, player_b_y, respawn_x, respawn_y
stage_arcade_run02_platforms:
PLATFORM($01, $fe, $00, $1f) ; left, right, top, bot
PLATFORM($01, $08, $0f, $cf) ; left, right, top, bot
STAGE_BUMPER($90, $a0, $0f, $2f, $06, $0200, $00, $01, $01) ; left, right, top, bot, damages, base, force, horizontal_direction, vertical_direction
PLATFORM($98, $fe, $0f, $2f) ; left, right, top, bot
STAGE_BUMPER($70, $88, $27, $3f, $06, $0200, $00, $01, $01) ; left, right, top, bot, damages, base, force, horizontal_direction, vertical_direction
PLATFORM($70, $88, $2f, $a7) ; left, right, top, bot
PLATFORM($38, $60, $3f, $b7) ; left, right, top, bot
PLATFORM($98, $fe, $3f, $cf) ; left, right, top, bot
PLATFORM($01, $a0, $af, $cf) ; left, right, top, bot
SMOOTH_PLATFORM($80, $a0, $3f) ; left, right, top
SMOOTH_PLATFORM($01, $20, $7f) ; left, right, top
SMOOTH_PLATFORM($80, $a0, $7f) ; left, right, top
END_OF_STAGE

#include "game/data/stages/arcade/run02/screen.asm"
.)

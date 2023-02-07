.(
+STAGE_ARCADE_RUN01_BANK_NUMBER = CURRENT_BANK_NUMBER

+stage_arcade_run01_data_header:
ARCADE_EXIT($00ee, $010b, $0011, $0038) ; left, right, top, bot
+stage_arcade_run01_data:
STAGE_HEADER($2800, $8000, $9fff, $8000, $8000, $8000) ; player_a_x, player_b_x, player_a_y, player_b_y, respawn_x, respawn_y
; Platforms
OOS_PLATFORM($ff7f, $0018, $0048, $00df) ; left, right, top, bot
PLATFORM($10, $20, $41, $df) ; left, right, top, bot
PLATFORM($18, $40, $9f, $cf) ; left, right, top, bot
PLATFORM($38, $60, $57, $ef) ; left, right, top, bot
PLATFORM($01, $e0, $cd, $ef) ; left, right, top, bot
PLATFORM($d8, $fe, $27, $ef) ; left, right, top, bot
SMOOTH_PLATFORM($18, $30, $70) ; left, right, top
SMOOTH_PLATFORM($80, $c0, $a8) ; left, right, top
SMOOTH_PLATFORM($98, $e0, $80) ; left, right, top
SMOOTH_PLATFORM($90, $c0, $58) ; left, right, top
SMOOTH_PLATFORM($b0, $e0, $27) ; left, right, top
END_OF_STAGE

#include "game/data/stages/arcade/run01/screen.asm"
#include "game/data/stages/arcade/run01/logic.built.asm"
.)

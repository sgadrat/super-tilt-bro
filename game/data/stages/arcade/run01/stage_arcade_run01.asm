.(
+STAGE_ARCADE_RUN01_BANK_NUMBER = CURRENT_BANK_NUMBER

+stage_arcade_run01_data_header:
ARCADE_EXIT($00ee, $010b, $0011, $0038) ; left, right, top, bot
+stage_arcade_run01_data:
STAGE_HEADER($2800, $8000, $c7ff, $8000, $8000, $8000) ; player_a_x, player_b_x, player_a_y, player_b_y, respawn_x, respawn_y
; Platforms
PLATFORM($01, $fe, $00, $17) ; left, right, top, bot
PLATFORM($01, $18, $07, $ef) ; left, right, top, bot
PLATFORM($e0, $fe, $27, $ef) ; left, right, top, bot
PLATFORM($38, $60, $7f, $ef) ; left, right, top, bot
PLATFORM($10, $40, $c7, $ef) ; left, right, top, bot
PLATFORM($58, $e8, $c7, $ef) ; left, right, top, bot
SMOOTH_PLATFORM($b0, $e8, $27) ; left, right, top
SMOOTH_PLATFORM($90, $c0, $57) ; left, right, top
SMOOTH_PLATFORM($98, $d8, $7f) ; left, right, top
SMOOTH_PLATFORM($10, $28, $97) ; left, right, top
SMOOTH_PLATFORM($80, $c0, $a7) ; left, right, top
END_OF_STAGE

#include "game/data/stages/arcade/run01/screen.asm"
.)

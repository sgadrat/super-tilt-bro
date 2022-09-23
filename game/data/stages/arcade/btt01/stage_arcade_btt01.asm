.(
+STAGE_ARCADE_BTT01_BANK_NUMBER = CURRENT_BANK_NUMBER

+stage_arcade_btt01_data_header:
ARCADE_TARGET($9c, $81)
ARCADE_TARGET($60, $4f)
ARCADE_TARGET($18, $1f)
ARCADE_TARGET($18, $5f)
ARCADE_TARGET($20, $97)
ARCADE_TARGET($c8, $37)
ARCADE_TARGET($fe, $fe)
ARCADE_TARGET($fe, $fe)
ARCADE_TARGET($fe, $fe)
ARCADE_TARGET($fe, $fe)
+stage_arcade_btt01_data:
STAGE_HEADER($5000, $8000, $afff, $8000, $8000, $8000) ; player_a_x, player_b_x, player_a_y, player_b_y, respawn_x, respawn_y
; Platforms
PLATFORM($40, $80, $00, $17) ; left, right, top, bot
PLATFORM($70, $80, $07, $47) ; left, right, top, bot
PLATFORM($48, $68, $1f, $47) ; left, right, top, bot
PLATFORM($48, $80, $4f, $67) ; left, right, top, bot
PLATFORM($88, $b0, $67, $7f) ; left, right, top, bot
PLATFORM($88, $98, $6f, $a7) ; left, right, top, bot
PLATFORM($a0, $b0, $6f, $a7) ; left, right, top, bot
PLATFORM($a8, $c0, $7f, $97) ; left, right, top, bot
PLATFORM($28, $c0, $af, $c7) ; left, right, top, bot
PLATFORM($38, $b0, $b7, $cf) ; left, right, top, bot
PLATFORM($48, $a8, $bf, $d7) ; left, right, top, bot
END_OF_STAGE

#include "game/data/stages/arcade/btt01/screen.asm"
#include "game/data/stages/arcade/btt01/logic.asm"
.)

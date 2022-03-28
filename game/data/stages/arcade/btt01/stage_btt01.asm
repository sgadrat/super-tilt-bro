STAGE_BTT01_BANK_NUMBER = CURRENT_BANK_NUMBER

stage_btt01_data_header:
ARCADE_TARGET($9c, $82)
ARCADE_TARGET($60, $50)
ARCADE_TARGET($18, $20)
ARCADE_TARGET($18, $60)
ARCADE_TARGET($20, $98)
ARCADE_TARGET($c8, $38)
ARCADE_TARGET($fe, $fe)
ARCADE_TARGET($fe, $fe)
ARCADE_TARGET($fe, $fe)
ARCADE_TARGET($fe, $fe)
stage_btt01_data:
STAGE_HEADER($8000, $8000, $8000, $8000, $8000, $8000) ; player_a_x, player_b_x, player_a_y, player_b_y, respawn_x, respawn_y
stage_btt01_platforms:
PLATFORM($41, $7f, $01, $17) ; left, right, top, bot
PLATFORM($71, $7f, $09, $47) ; left, right, top, bot
PLATFORM($49, $67, $21, $47) ; left, right, top, bot
PLATFORM($49, $7f, $51, $67) ; left, right, top, bot
PLATFORM($89, $af, $69, $7f) ; left, right, top, bot
PLATFORM($89, $97, $71, $a7) ; left, right, top, bot
PLATFORM($a1, $af, $71, $a7) ; left, right, top, bot
PLATFORM($a9, $bf, $81, $97) ; left, right, top, bot
PLATFORM($29, $bf, $b1, $c7) ; left, right, top, bot
PLATFORM($39, $af, $b9, $cf) ; left, right, top, bot
PLATFORM($49, $a7, $c1, $d7) ; left, right, top, bot
END_OF_STAGE

#include "game/data/stages/arcade/btt01/screen.asm"

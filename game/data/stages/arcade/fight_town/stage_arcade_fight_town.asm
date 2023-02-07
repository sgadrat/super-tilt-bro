.(
+STAGE_ARCADE_FIGHT_TOWN_BANK_NUMBER = CURRENT_BANK_NUMBER

+stage_arcade_fight_town_data:
STAGE_HEADER($4c00, $ac00, $7fff, $7fff, $7b00, $47ff) ; player_a_x, player_b_x, player_a_y, player_b_y, respawn_x, respawn_y
; Platforms
PLATFORM($28, $d0, $1f, $3f) ; left, right, top, bot
PLATFORM($28, $d0, $9f, $ef) ; left, right, top, bot
SMOOTH_PLATFORM($58, $a0, $5f) ; left, right, top
SMOOTH_PLATFORM($40, $78, $7f) ; left, right, top
SMOOTH_PLATFORM($80, $b8, $7f) ; left, right, top
END_OF_STAGE

#include "game/data/stages/arcade/fight_town/screen.asm"
#include "game/data/stages/arcade/fight_town/logic.built.asm"
.)

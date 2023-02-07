.(
+STAGE_ARCADE_FIGHT_WALL_BANK_NUMBER = CURRENT_BANK_NUMBER

+stage_arcade_fight_wall_data:
STAGE_HEADER($2800, $d000, $6dff, $6eff, $7c00, $2bff) ; player_a_x, player_b_x, player_a_y, player_b_y, respawn_x, respawn_y
; Platforms
PLATFORM($28, $d0, $8d, $ef) ; left, right, top, bot
SMOOTH_PLATFORM($10, $70, $6e) ; left, right, top
SMOOTH_PLATFORM($88, $e8, $6e) ; left, right, top
SMOOTH_PLATFORM($40, $b8, $4e) ; left, right, top
END_OF_STAGE

#include "game/data/stages/arcade/fight_wall/screen.asm"
#include "game/data/stages/arcade/fight_wall/logic.built.asm"
.)

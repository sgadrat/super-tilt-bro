.(
+STAGE_ARCADE_FIGHT_PORT_BANK_NUMBER = CURRENT_BANK_NUMBER

+stage_arcade_fight_port_data:
STAGE_HEADER($4c00, $ac00, $6fff, $6fff, $7c00, $3fff) ; player_a_x, player_b_x, player_a_y, player_b_y, respawn_x, respawn_y
; Platforms
PLATFORM($28, $d0, $6f, $ef) ; left, right, top, bot
PLATFORM($18, $30, $8f, $af) ; left, right, top, bot
PLATFORM($c8, $e0, $8f, $af) ; left, right, top, bot
END_OF_STAGE

#include "game/data/stages/arcade/fight_port/screen.asm"
#include "game/data/stages/arcade/fight_port/logic.built.asm"
.)

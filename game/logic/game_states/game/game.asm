#include "game/logic/game_states/game/game_logic.asm"
#include "game/logic/game_states/game/game_mode_local.asm"
#include "game/logic/game_states/game/game_mode_online.asm"
#include "game/logic/game_states/game/game_mode_server.asm"

game_modes_init_lsb:
.byt <game_mode_local_init
.byt <game_mode_online_init
.byt <game_mode_arcade_init
.byt <game_mode_server_init

game_modes_init_msb:
.byt >game_mode_local_init
.byt >game_mode_online_init
.byt >game_mode_arcade_init
.byt >game_mode_server_init

game_modes_pre_update_lsb:
.byt <game_mode_local_pre_update
.byt <game_mode_online_pre_update
.byt <game_mode_arcade_pre_update
.byt <game_mode_server_pre_update

game_modes_pre_update_msb:
.byt >game_mode_local_pre_update
.byt >game_mode_online_pre_update
.byt >game_mode_arcade_pre_update
.byt >game_mode_server_pre_update

game_modes_gameover_lsb:
.byt <game_mode_goto_gameover
.byt <game_mode_online_gameover
.byt <game_mode_arcade_gameover
.byt <game_mode_goto_gameover

game_modes_gameover_msb:
.byt >game_mode_goto_gameover
.byt >game_mode_online_gameover
.byt >game_mode_arcade_gameover
.byt >game_mode_goto_gameover

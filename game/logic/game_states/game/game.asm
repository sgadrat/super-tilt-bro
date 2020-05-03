game_modes_init_lsb:
.byt <game_mode_local_init
.byt <game_mode_online_init

game_modes_init_msb:
.byt >game_mode_local_init
.byt >game_mode_online_init

game_modes_pre_update_lsb:
.byt <game_mode_local_pre_update
.byt <game_mode_online_pre_update

game_modes_pre_update_msb:
.byt >game_mode_local_pre_update
.byt >game_mode_online_pre_update

#include "game/logic/game_states/game/game_logic.asm"
#include "game/logic/game_states/game/game_mode_local.asm"
#include "game/logic/game_states/game/game_mode_online.asm"

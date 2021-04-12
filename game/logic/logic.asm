fixed_bank_particles_begin:
#include "game/logic/particles.asm"
#echo logic size for particles:
#print *-fixed_bank_particles_begin

fixed_bank_audio_begin:
#include "game/logic/audio.asm"
#echo logic size for audio:
#print *-fixed_bank_audio_begin

fixed_bank_init_begin:
#include "game/logic/init.asm"
#echo logic size for init:
#print *-fixed_bank_init_begin

fixed_bank_game_states_begin:
#include "game/logic/game_states/game_states.asm"
#echo logic size for game_states:
#print *-fixed_bank_game_states_begin

fixed_bank_menu_common_begin:
#include "game/logic/menu_common.asm"
#echo logic size for menu_common:
#print *-fixed_bank_menu_common_begin

fixed_bank_stages_begin:
#include "game/logic/stages/stages.asm"
#echo logic size for stages:
#print *-fixed_bank_stages_begin

fixed_bank_ai_begin:
#include "game/logic/ai.asm"
#echo logic size for ai:
#print *-fixed_bank_ai_begin

fixed_bank_network_begin:
#include "game/logic/network.asm"
#echo logic size for network:
#print *-fixed_bank_network_begin

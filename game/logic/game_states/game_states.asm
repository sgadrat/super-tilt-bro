; Subroutine called when the state change to this state
game_states_init:
VECTOR(init_game_state)
VECTOR(init_title_screen)
VECTOR(init_gameover_screen)
VECTOR(init_credits_screen)
VECTOR(init_config_screen)
VECTOR(init_stage_selection_screen)
VECTOR(init_character_selection_screen)
VECTOR(init_mode_selection_screen)
VECTOR(init_netplay_launch_screen)
VECTOR(init_social_screen)
VECTOR(init_online_mode_screen)
VECTOR(init_wifi_settings_screen)
VECTOR(init_arcade_mode)
VECTOR(init_jukebox_screen)

; Subroutine called each frame
game_states_tick:
VECTOR(game_tick)
VECTOR(title_screen_tick)
VECTOR(gameover_screen_tick)
VECTOR(credits_screen_tick)
VECTOR(config_screen_tick)
VECTOR(stage_selection_screen_tick)
VECTOR(character_selection_screen_tick)
VECTOR(mode_selection_screen_tick)
VECTOR(netplay_launch_screen_tick)
VECTOR(social_screen_tick)
VECTOR(online_mode_screen_tick)
VECTOR(wifi_settings_screen_tick)
VECTOR(arcade_mode_tick)
VECTOR(jukebox_screen_tick)

#echo logic size for game_states (routines table):
#print *-fixed_bank_game_states_begin

;NOTE if you change these tables, do not forget to update GAME_STATE_* constants

game_state_logic_begin_character_selection_screen:
#include "game/logic/game_states/character_selection_screen.asm"
#echo logic size for game_states (character_selection_screen)
#print *-game_state_logic_begin_character_selection_screen

game_state_logic_begin_config_screen:
#include "game/logic/game_states/config_screen.asm"
#echo logic size for game_states (config_screen)
#print *-game_state_logic_begin_config_screen

game_state_logic_begin_credits_screen:
#include "game/logic/game_states/credits_screen.asm"
#echo logic size for game_states (credits_screen)
#print *-game_state_logic_begin_credits_screen

game_state_logic_begin_social_screen:
#include "game/logic/game_states/social_screen.asm"
#echo logic size for game_states (social_screen)
#print *-game_state_logic_begin_social_screen

game_state_logic_begin_game:
#include "game/logic/game_states/game/game.asm"
#echo logic size for game_states (game)
#print *-game_state_logic_begin_game

game_state_logic_begin_gameover_screen:
#include "game/logic/game_states/gameover_screen.asm"
#echo logic size for game_states (gameover_screen)
#print *-game_state_logic_begin_gameover_screen

game_state_logic_begin_mode_selection_screen:
#include "game/logic/game_states/mode_selection_screen.asm"
#echo logic size for game_states (mode_selection_screen)
#print *-game_state_logic_begin_mode_selection_screen

game_state_logic_begin_netplay_launch_screen:
#include "game/logic/game_states/netplay_launch_screen.asm"
#echo logic size for game_states (netplay_launch_screen)
#print *-game_state_logic_begin_netplay_launch_screen

game_state_logic_begin_online_mode_screen:
#include "game/logic/game_states/online_mode_screen.asm"
#echo logic size for game_states (online_mode_screen)
#print *-game_state_logic_begin_online_mode_screen

game_state_logic_begin_stage_selection_screen:
#include "game/logic/game_states/stage_selection_screen.asm"
#echo logic size for game_states (stage_selection_screen)
#print *-game_state_logic_begin_stage_selection_screen

game_state_logic_begin_title_screen:
#include "game/logic/game_states/title_screen.asm"
#echo logic size for game_states (title_screen)
#print *-game_state_logic_begin_title_screen

game_state_logic_begin_transitions:
#include "game/logic/game_states/transitions/transitions.asm"
#echo logic size for game_states (transitions)
#print *-game_state_logic_begin_transitions

game_state_logic_begin_wifi_settings_screen:
#include "game/logic/game_states/wifi_settings_screen.asm"
#echo logic size for game_states (wifi_settings_screen)
#print *-game_state_logic_begin_wifi_settings_screen

game_state_logic_begin_arcade_mode:
#include "game/logic/game_states/arcade_mode.asm"
#echo logic size for game_states (arcade_mode)
#print *-game_state_logic_begin_arcade_mode

game_state_logic_begin_jukebox_screen:
#include "game/logic/game_states/jukebox_screen.asm"
#echo logic size for game_states (jukebox_screen)
#print *-game_state_logic_begin_jukebox_screen


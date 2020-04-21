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
VECTOR(init_donation_screen)
VECTOR(init_donation_btc_screen)
VECTOR(init_donation_paypal_screen)
VECTOR(init_no_local_screen)

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
VECTOR(donation_screen_tick)
VECTOR(donation_qr_screen_tick)
VECTOR(donation_qr_screen_tick)
VECTOR(no_local_screen_tick)

#define GAME_STATE_INGAME $00
#define GAME_STATE_TITLE $01
#define GAME_STATE_GAMEOVER $02
#define GAME_STATE_CREDITS $03
#define GAME_STATE_CONFIG $04
#define GAME_STATE_STAGE_SELECTION $05
#define GAME_STATE_CHARACTER_SELECTION $06
#define GAME_STATE_MODE_SELECTION $07
#define GAME_STATE_NETPLAY_LAUNCH $08
#define GAME_STATE_DONATION $09
#define GAME_STATE_DONATION_BTC $0a
#define GAME_STATE_DONATION_PAYPAL $0b
#define GAME_STATE_NO_LOCAL $0c
;NOTE maximum supported value is $0f, because get_transition_id returns an ID on one byte. To handle more than 16 states, it should be changed.

#include "game/logic/game_states/character_selection_screen.asm"
#include "game/logic/game_states/config_screen.asm"
#include "game/logic/game_states/credits_screen.asm"
#include "game/logic/game_states/donation_screen.asm"
#include "game/logic/game_states/donation_qr.asm"
#include "game/logic/game_states/game.asm"
#include "game/logic/game_states/gameover_screen.asm"
#include "game/logic/game_states/mode_selection_screen.asm"
#include "game/logic/game_states/netplay_launch_screen.asm"
#include "game/logic/game_states/no_local_screen.asm"
#include "game/logic/game_states/stage_selection_screen.asm"
#include "game/logic/game_states/title_screen.asm"
#include "game/logic/game_states/transitions/transitions.asm"

STAGE_ARCADE_TEST01_BANK_NUMBER = CURRENT_BANK_NUMBER

stage_arcade_test01_data_header:
ARCADE_EXIT(200, 208, 40, 48) ; left, right, top, bot
stage_arcade_test01_data:
STAGE_HEADER($3000, $0000, $c8ff, $0000, $0000, $0000) ; player_a_x, player_b_x, player_a_y, player_b_y, respawn_x, respawn_y
stage_arcade_test01_elements:
; Border, all closed stages should have it (hard walls, forcing to stay in title-safe area
PLATFORM($00,  23, $00, $ff) ; left, right, top, bot
PLATFORM($00, $ff, $00,  23) ; left, right, top, bot
PLATFORM(232, $ff, $00, $ff) ; left, right, top, bot
PLATFORM($00, $ff, $c8, $ff) ; left, right, top, bot

; Stage platforms
PLATFORM(64-8, 96, 144-16, $ff) ; left, right, top, bot
SMOOTH_PLATFORM(24-8, 40, 168-16) ; left, right, top
SMOOTH_PLATFORM(144-8, 200, 176-16) ; left, right, top
SMOOTH_PLATFORM(184-8, 224, 136-16) ; left, right, top
SMOOTH_PLATFORM(168-8, 200, 96-16) ; left, right, top
SMOOTH_PLATFORM(192-8, 216, 56-16) ; left, right, top
END_OF_STAGE

#include "game/data/stages/arcade/test01/screen.asm"

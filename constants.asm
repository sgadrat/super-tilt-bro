#define STAGE_EDGE_LEFT #$21
#define STAGE_EDGE_RIGHT #$d7
#define STAGE_EDGE_TOP #$81
#define STAGE_EDGE_BOTTOM #$ff

#define RESPAWN_X #$70
#define RESPAWN_Y #$60

#define PLAYER_STATE_STANDING #$00
#define PLAYER_STATE_RUNNING #$01
#define PLAYER_STATE_FALLING #$02
#define PLAYER_STATE_JUMPING #$03
#define PLAYER_STATE_JABBING #$04
#define PLAYER_STATE_THROWN #$05
#define PLAYER_STATE_RESPAWN #$06
#define PLAYER_STATE_SIDE_TILT #$07
#define PLAYER_STATE_SPECIAL #$08
#define PLAYER_STATE_SIDE_SPECIAL #$09
#define PLAYER_STATE_HELPLESS #$0a
#define PLAYER_STATE_LANDING #$0b
#define PLAYER_STATE_CRASHING #$0c
#define PLAYER_STATE_DOWN_TILT #$0d
#define PLAYER_STATE_AERIAL_SIDE #$0e
#define PLAYER_STATE_AERIAL_DOWN #$0f
#define PLAYER_STATE_AERIAL_UP #$10
#define PLAYER_STATE_AERIAL_NEUTRAL #$11
#define PLAYER_STATE_AERIAL_SPE_NEUTRAL #$12
#define PLAYER_STATE_SPE_UP #$13
#define PLAYER_STATE_SPE_DOWN #$14
#define PLAYER_STATE_UP_TILT #$15
#define PLAYER_STATE_SHIELDING #$16

#define DIRECTION_LEFT #$00
#define DIRECTION_RIGHT #$01

#define HITBOX_DISABLED #$00
#define HITBOX_ENABLED #$01

#define HITSTUN_PARRY_NB_FRAMES 10
#define SCREENSHAKE_PARRY_NB_FRAMES 2

#define MAX_STOCKS 4

#define TILENUM_NT_CHAR_0 #$14

#define CONTROLLER_BTN_A      %10000000
#define CONTROLLER_BTN_B      %01000000
#define CONTROLLER_BTN_SELECT %00100000
#define CONTROLLER_BTN_START  %00010000
#define CONTROLLER_BTN_UP     %00001000
#define CONTROLLER_BTN_DOWN   %00000100
#define CONTROLLER_BTN_LEFT   %00000010
#define CONTROLLER_BTN_RIGHT  %00000001

#define CONTROLLER_INPUT_JUMP          CONTROLLER_BTN_UP
#define CONTROLLER_INPUT_JAB           CONTROLLER_BTN_A
#define CONTROLLER_INPUT_LEFT          CONTROLLER_BTN_LEFT
#define CONTROLLER_INPUT_RIGHT         CONTROLLER_BTN_RIGHT
#define CONTROLLER_INPUT_JUMP_RIGHT    CONTROLLER_BTN_UP | CONTROLLER_BTN_RIGHT
#define CONTROLLER_INPUT_JUMP_LEFT     CONTROLLER_BTN_UP | CONTROLLER_BTN_LEFT
#define CONTROLLER_INPUT_ATTACK_LEFT   CONTROLLER_BTN_LEFT | CONTROLLER_BTN_A
#define CONTROLLER_INPUT_ATTACK_RIGHT  CONTROLLER_BTN_RIGHT | CONTROLLER_BTN_A
#define CONTROLLER_INPUT_ATTACK_UP     CONTROLLER_BTN_UP | CONTROLLER_BTN_A
#define CONTROLLER_INPUT_SPECIAL       CONTROLLER_BTN_B
#define CONTROLLER_INPUT_SPECIAL_RIGHT CONTROLLER_BTN_B | CONTROLLER_BTN_RIGHT
#define CONTROLLER_INPUT_SPECIAL_LEFT  CONTROLLER_BTN_B | CONTROLLER_BTN_LEFT
#define CONTROLLER_INPUT_SPECIAL_DOWN  CONTROLLER_BTN_B | CONTROLLER_BTN_DOWN
#define CONTROLLER_INPUT_SPECIAL_UP    CONTROLLER_BTN_B | CONTROLLER_BTN_UP
#define CONTROLLER_INPUT_TECH          CONTROLLER_BTN_DOWN
#define CONTROLLER_INPUT_TECH_RIGHT    CONTROLLER_BTN_DOWN | CONTROLLER_BTN_RIGHT
#define CONTROLLER_INPUT_TECH_LEFT     CONTROLLER_BTN_DOWN | CONTROLLER_BTN_LEFT
#define CONTROLLER_INPUT_DOWN_TILT     CONTROLLER_BTN_DOWN | CONTROLLER_BTN_A

#define GAME_STATE_INGAME $00
#define GAME_STATE_TITLE $01
#define GAME_STATE_GAMEOVER $02
#define GAME_STATE_CREDITS $03
#define GAME_STATE_CONFIG $04

#define ZERO_PAGE_GLOBAL_FIELDS_BEGIN $d0

#define AUDIO_CHANNEL_SQUARE $00
#define AUDIO_CHANNEL_TRIANGLE $01

#define NOTE_O1_A $760
#define NOTE_O1_B $692
#define NOTE_O1_C $634
#define NOTE_O1_D $586
#define NOTE_O1_E $4ec
#define NOTE_O1_F $4a5
#define NOTE_O1_G $423
#define NOTE_O2_A $3b0
#define NOTE_O2_B $349
#define NOTE_O2_C $319
#define NOTE_O2_D $2c3
#define NOTE_O2_E $275
#define NOTE_O2_F $252
#define NOTE_O2_G $211
#define NOTE_O3_A $1D7
#define NOTE_O3_B $1A4
#define NOTE_O3_C $18C
#define NOTE_O3_D $161
#define NOTE_O3_E $13A
#define NOTE_O3_F $129
#define NOTE_O3_G $108
#define NOTE_O4_A $0EB
#define NOTE_O4_B $0D1
#define NOTE_O4_C $0C6
#define NOTE_O4_D $0B0
#define NOTE_O4_E $09D
#define NOTE_O4_F $094
#define NOTE_O4_G $084
#define NOTE_O5_A $075
#define NOTE_O5_B $068
#define NOTE_O5_C $062
#define NOTE_O5_D $057
#define NOTE_O5_E $04E
#define NOTE_O5_F $049
#define NOTE_O5_G $041
#define NOTE_O6_A $03A
#define NOTE_O6_B $034
#define NOTE_O6_C $031
#define NOTE_O6_D $02B
#define NOTE_O6_E $026
#define NOTE_O6_F $024
#define NOTE_O6_G $020
#define NOTE_O7_A $01D
#define NOTE_O7_B $019
#define NOTE_O7_C $018
#define NOTE_O7_D $015
#define NOTE_O7_E $013
#define NOTE_O7_F $012
#define NOTE_O7_G $010
#define NOTE_O8_A $00E
#define NOTE_O8_B $00C
#define NOTE_O8_C $00B
#define NOTE_O8_D $00A
#define NOTE_O8_E $009
#define NOTE_O8_F $008

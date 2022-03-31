#echo
#echo ====== DATA-09-BANK =====
* = $8000

bank_data09_begin:

bank_data_netplay_launch_screen_extra_data_begin:
#include "game/data/menu_netplay_launch/illustration_map.asm"
#include "game/data/menu_netplay_launch/anims.asm"
#echo
#echo netplay launch extra data size:
#print *-bank_data_netplay_launch_screen_extra_data_begin

bank_data_netplay_launch_screen_extra_code_begin:
#include "game/logic/game_states/netplay_launch_screen/netplay_launch_screen_extra_code.asm"
#echo
#echo netplay launch extra code size:
#print *-bank_data_netplay_launch_screen_extra_code_begin

bank_data_title_screen_extra_data_begin:
#include "game/data/title_screen/screen.asm"
#include "game/data/title_screen/tilesets.asm"
#echo
#echo Title screen extra data size:
#print *-bank_data_title_screen_extra_data_begin

bank_data_title_screen_extra_code_begin:
#include "game/logic/game_states/title_screen/title_screen_extra_code.asm"
#echo
#echo Title screen extra code size:
#print *-bank_data_title_screen_extra_code_begin

bank_data_arcade_mode_extra_code_begin:
#include "game/logic/game_states/arcade_mode/arcade_mode_extra_code.asm"
#echo
#echo arcade mode extra code size:
#print *-bank_data_arcade_mode_extra_code_begin

bank_data_arcade_mode_screen_begin:
#include "game/data/arcade/screen.asm"
#echo
#echo arcade mode screen size:
#print *-bank_data_arcade_mode_screen_begin

bank_data_arcade_stage_test01_begin:
#include "game/data/stages/arcade/test01/test01.asm"
#include "game/data/stages/arcade/test_tileset.asm"
#echo
#echo arcade stage test01 size:
#print *-bank_data_arcade_stage_test01_begin

bank_data_arcade_anims_begin:
#include "game/data/arcade/animations/animations.asm"
#echo
#echo arcade animations size:
#print *-bank_data_arcade_anims_begin

bank_data09_end:

#echo
#echo DATA-09-bank used size:
#print bank_data09_end-bank_data09_begin
#echo
#echo DATA-09-bank free space:
#print $c000-*

#if $c000-* < 0
#error Data bank occupies too much space
#else
.dsb $c000-*, CURRENT_BANK_NUMBER
#endif

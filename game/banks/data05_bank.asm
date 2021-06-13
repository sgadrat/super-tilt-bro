#echo
#echo ====== DATA-05-BANK =====
* = $8000

bank_data05_begin:

bank_data_netplay_launch_screen_extra_data_begin:
#include "game/data/menu_netplay_launch/screen.asm"
#echo
#echo netplay launch extra data size:
#print *-bank_data_netplay_launch_screen_extra_data_begin

bank_data_netplay_launch_screen_extra_code_begin:
#include "game/logic/game_states/netplay_launch_screen/netplay_launch_screen_extra_code.asm"
#echo
#echo netplay launch extra code size:
#print *-bank_data_netplay_launch_screen_extra_code_begin

bank_data_theme_sinbad_begin:
#include "game/data/music/theme_sinbad.asm"
#echo
#echo theme sinbad size:
#print *-bank_data_theme_sinbad_begin

bank_data_stage_selection_extra_code_begin:
#include "game/logic/game_states/stage_selection_screen/stage_selection_extra_code.asm"
#echo
#echo Stage selection extra code size:
#print *-bank_data_stage_selection_extra_code_begin

bank_data_stage_selection_extra_data_begin:
#include "game/data/menu_stage_select/anims.asm"
#include "game/data/menu_stage_select/screen.asm"
#echo
#echo Stage selection extra data size:
#print *-bank_data_stage_selection_extra_data_begin

bank_data_theme_adventure_begin:
#include "game/data/music/theme_adventure.asm"
#echo
#echo Theme adventure size:
#print *-bank_data_theme_adventure_begin

bank_data05_end:

#echo
#echo DATA-05-bank used size:
#print bank_data05_end-bank_data05_begin
#echo
#echo DATA-05-bank free space:
#print $c000-*

#if $c000-* < 0
#error Data bank occupies too much space
#else
.dsb $c000-*, CURRENT_BANK_NUMBER
#endif

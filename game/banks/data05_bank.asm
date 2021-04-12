#echo
#echo ====== DATA-05-BANK =====
* = $8000

bank_data05_begin:

bank_data_netplay_launch_screen_extra_data_begin:
#include "game/data/menu_netplay_launch/screen.asm"
bank_data_netplay_launch_screen_extra_data_end:

bank_data_netplay_launch_screen_extra_code_begin:
#include "game/logic/game_states/netplay_launch_screen/netplay_launch_screen_extra_code.asm"
bank_data_netplay_launch_screen_extra_code_end:

bank_data05_end:

#echo
#echo DATA-05-bank used size:
#print bank_data05_end-bank_data05_begin
#echo
#echo DATA-05-bank netplay launch extra data size:
#print bank_data_netplay_launch_screen_extra_data_end-bank_data_netplay_launch_screen_extra_data_begin
#echo
#echo DATA-05-bank netplay launch extra code size:
#print bank_data_netplay_launch_screen_extra_code_end-bank_data_netplay_launch_screen_extra_code_begin
#echo
#echo DATA-05-bank free space:
#print $c000-*

#if $c000-* < 0
#error Data bank occupies too much space
#else
.dsb $c000-*, CURRENT_BANK_NUMBER
#endif

#echo
#echo ====== DATA-06-BANK =====
* = $8000

bank_data06_begin:

bank_data_online_mode_screen_fadein_begin:
#include "game/logic/game_states/online_mode_screen/online_mode_screen_fadein.asm"
#echo
#echo Online mode screen fade-in:
#print *-bank_data_online_mode_screen_fadein_begin

bank_data_menu_mode_select_data_begin:
#include "game/data/menu_mode_select/screen.asm"
#include "game/data/menu_mode_select/tileset.asm"
#echo
#echo Menu mode selection data:
#print *-bank_data_menu_mode_select_data_begin

bank_data06_end:

#echo
#echo DATA-06-bank used size:
#print bank_data06_end-bank_data06_begin
#echo
#echo DATA-06-bank free space:
#print $c000-*

#if $c000-* < 0
#error Data bank occupies too much space
#else
.dsb $c000-*, CURRENT_BANK_NUMBER
#endif

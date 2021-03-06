#echo
#echo ====== DATA-BANK =====
* = $8000

bank_data_begin:
#include "game/data/data.asm"
#echo
#echo DATA-bank data size:
#print *-bank_data_begin

bank_data_online_mode_extra_data_begin:
#include "game/data/menu_online_mode/anims.asm"
#include "game/data/menu_online_mode/screen.asm"
#echo
#echo Online mode extra data size:
#print *-bank_data_online_mode_extra_data_begin

bank_data_online_mode_extra_code_begin:
#include "game/logic/game_states/online_mode_screen/online_mode_screen_extra_code.asm"
#echo
#echo Online mode extra code size:
#print *-bank_data_online_mode_extra_code_begin

bank_data_credits_begin:
#include "game/data/credits.asm"
#echo
#echo Credits size:
#print *-bank_data_credits_begin

bank_data_end:

#echo
#echo DATA-bank used size:
#print bank_data_end-bank_data_begin
#echo
#echo DATA-bank free space:
#print $c000-*

#if $c000-* < 0
#error Data bank occupies too much space
#else
.dsb $c000-*, CURRENT_BANK_NUMBER
#endif

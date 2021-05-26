#echo
#echo ====== DATA-BANK =====
* = $8000

bank_data_begin:
#include "game/data/data.asm"

bank_data_stage_selection_extra_data_begin:
#include "game/data/menu_stage_select/anims.asm"
#include "game/data/menu_stage_select/screen.asm"
bank_data_stage_selection_extra_data_end:

bank_data_stage_selection_extra_code_begin:
#include "game/logic/game_states/stage_selection_screen/stage_selection_extra_code.asm"
bank_data_stage_selection_extra_code_end:

bank_data_online_mode_extra_data_begin:
#include "game/data/menu_online_mode/anims.asm"
#include "game/data/menu_online_mode/screen.asm"
bank_data_online_mode_extra_data_end:

bank_data_online_mode_extra_code_begin:
#include "game/logic/game_states/online_mode_screen/online_mode_screen_extra_code.asm"
bank_data_online_mode_extra_code_end:

bank_data_credits_begin:
#include "game/data/credits.asm"
#echo
#echo FIXED-bank (updatable) credits size:
#print *-bank_data_credits_begin

bank_data_end:

#echo
#echo DATA-bank used size:
#print bank_data_end-bank_data_begin
#echo
#echo DATA-bank data size:
#print data_end-data_begin
#echo
#echo DATA-bank nametables size:
#print data_nt_end-data_nt_begin
#echo
#echo DATA-bank stage select extra data size:
#print bank_data_stage_selection_extra_data_end-bank_data_stage_selection_extra_data_begin
#echo
#echo DATA-bank stage select extra code size:
#print bank_data_stage_selection_extra_code_end-bank_data_stage_selection_extra_code_begin
#echo
#echo DATA-bank online mode extra data size:
#print bank_data_online_mode_extra_data_end-bank_data_online_mode_extra_data_begin
#echo
#echo DATA-bank online mode extra code size:
#print bank_data_online_mode_extra_code_end-bank_data_online_mode_extra_code_begin
#echo
#echo DATA-bank free space:
#print $c000-*

#if $c000-* < 0
#error Data bank occupies too much space
#else
.dsb $c000-*, CURRENT_BANK_NUMBER
#endif

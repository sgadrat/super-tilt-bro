.(
#echo
#echo ====== DATA-15-BANK =====
* = $8000

.byt CURRENT_BANK_NUMBER

bank_data15_begin:

bank_data_cutscene_logic_begin:
#include "game/logic/cutscenes.asm"
#echo
#echo cutscenes logic size
#print *-bank_data_cutscene_logic_begin

bank_data_cutscene_sinbad_story_bird_msg_begin:
#include "game/data/cutscenes/sinbad_story/bird_msg/cutscene.asm"
#echo
#echo arcade cutscene sinbad story bird size:
#print *-bank_data_cutscene_sinbad_story_bird_msg_begin

.(
bank_data_begin:
#include "game/logic/game_states/arcade_mode/arcade_mode_extra_code.asm"
#echo
#echo arcade mode extra code size:
#print *-bank_data_begin
.)

.(
bank_data_begin:
#include "game/data/arcade/screen.asm"
#echo
#echo arcade mode screen size:
#print *-bank_data_begin
.)

.(
bank_data_begin:
#include "game/data/stages/arcade/btt02/stage_arcade_btt02.asm"
#echo
#echo stage arcade btt02 size:
#print *-bank_data_begin
.)

bank_data15_end:

#echo
#echo DATA-15-bank used size:
#print bank_data15_end-bank_data15_begin
#echo
#echo DATA-15-bank free space:
#print $c000-*

#if $c000-* < 0
#error Data bank occupies too much space
#else
.dsb $c000-*, $ff
#endif
.)

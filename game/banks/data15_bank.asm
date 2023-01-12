.(
#echo
#echo ====== DATA-15-BANK =====
* = $8000

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
.dsb $c000-*, CURRENT_BANK_NUMBER
#endif
.)

#echo
#echo ====== DATA-10-BANK =====
* = $8000

bank_data10_begin:

bank_data_cutscene_sinbad_story_bird_msg_begin:
#include "game/data/cutscenes/sinbad_story_bird_msg/cutscene.asm"
#echo
#echo arcade cutscene sinbad story bird size:
#print *-bank_data_cutscene_sinbad_story_bird_msg_begin

bank_data10_end:

#echo
#echo DATA-10-bank used size:
#print bank_data10_end-bank_data10_begin
#echo
#echo DATA-10-bank free space:
#print $c000-*

#if $c000-* < 0
#error Data bank occupies too much space
#else
.dsb $c000-*, CURRENT_BANK_NUMBER
#endif

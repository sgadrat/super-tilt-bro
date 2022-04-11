.(
#echo
#echo ====== DATA-11-BANK =====
* = $8000

bank_data11_begin:

bank_data_cutscene_logic_begin:
#include "game/logic/cutscenes.asm"
#echo
#echo cutscenes logic size
#print *-bank_data_cutscene_logic_begin

bank_data_cutscene_sinbad_story_sinbad_encounter_begin:
#include "game/data/cutscenes/sinbad_story_sinbad_encounter/cutscene.asm"
#echo
#echo arcade cutscene sinbad story sinbad encounter size:
#print *-bank_data_cutscene_sinbad_story_sinbad_encounter_begin

bank_data11_end:

#echo
#echo DATA-11-bank used size:
#print bank_data11_end-bank_data11_begin
#echo
#echo DATA-11-bank free space:
#print $c000-*

#if $c000-* < 0
#error Data bank occupies too much space
#else
.dsb $c000-*, CURRENT_BANK_NUMBER
#endif
.)

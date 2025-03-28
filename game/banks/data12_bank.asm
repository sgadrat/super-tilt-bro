.(
#echo
#echo ====== DATA-12-BANK =====
* = $8000

.byt CURRENT_BANK_NUMBER

bank_data12_begin:

bank_data_cutscene_logic_begin:
#include "game/logic/cutscenes.asm"
#echo
#echo cutscenes logic size
#print *-bank_data_cutscene_logic_begin

.(
bank_data_begin:
#include "game/data/cutscenes/sinbad_story/meteor/cutscene.asm"
#echo
#echo arcade cutscene sinbad story meteor size:
#print *-bank_data_begin
.)

.(
bank_data_begin:
#include "game/data/cutscenes/sinbad_story/ending/cutscene.asm"
#echo
#echo arcade cutscene sinbad story ending size::
#print *-bank_data_begin
.)

bank_data_stage_arcade_run02_begin:
#include "game/data/stages/arcade/run02/stage_arcade_run02.asm"
#echo
#echo stage arcade run02 size:
#print *-bank_data_stage_arcade_run02_begin

.(
bank_data_begin:
#include "game/data/stages/arcade/tilesets/roof_extras.asm"
#echo
#echo Arcade tileset roof extras
#print *-bank_data_begin
.)

.(
bank_data_begin:
#include "game/data/stages/arcade/gameover/stage_arcade_gameover.asm"
#echo
#echo stage arcade gameover size:
#print *-bank_data_begin
.)

.(
bank_data_begin:
#include "game/data/stages/arcade/btt02/stage_arcade_btt02.asm"
#echo
#echo stage arcade btt02 size:
#print *-bank_data_begin
.)

bank_data12_end:

#echo
#echo DATA-12-bank used size:
#print bank_data12_end-bank_data12_begin
#echo
#echo DATA-12-bank free space:
#print $c000-*

#if $c000-* < 0
#error Data bank occupies too much space
#else
.dsb $c000-*, $ff
#endif
.)

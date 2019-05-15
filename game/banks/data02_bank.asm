#echo
#echo ===== DATA02-BANK =====
* = $8000

bank_data02_begin:
bank_data02_stage_pit_begin:
#include "game/data/stages/pit/pit.asm"
bank_data02_stage_pit_end:

bank_data02_stage_shelf_begin:
#include "game/data/stages/shelf/shelf.asm"
bank_data02_stage_shelf_end:

bank_data02_stage_gem_begin:
#include "game/data/stages/gem/gem.asm"
bank_data02_stage_gem_end:
bank_data02_end:

#echo
#echo DATA02-bank data size:
#print bank_data02_end-bank_data02_begin
#echo
#echo DATA02-bank Pit size:
#print bank_data02_stage_pit_end-bank_data02_stage_pit_begin
#echo
#echo DATA02-bank Shelf size:
#print bank_data02_stage_shelf_end-bank_data02_stage_shelf_begin
#echo
#echo DATA02-bank Gem size:
#print bank_data02_stage_gem_end-bank_data02_stage_gem_begin
#echo
#echo DATA02-bank free space:
#print $c000-*

#if $c000-* < 0
#echo *** Error: DATA02 bank occupies too much space
#else
.dsb $c000-*, CURRENT_BANK_NUMBER
#endif

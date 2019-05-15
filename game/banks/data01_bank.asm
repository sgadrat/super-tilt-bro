#echo
#echo ===== DATA01-BANK =====
* = $8000

bank_data01_begin:
bank_data01_sinbad_begin:
#include "game/data/characters/sinbad/sinbad.asm"
bank_data01_sinbad_end:
bank_data01_end:

#echo
#echo DATA01-bank data size:
#print bank_data01_end-bank_data01_begin
#echo
#echo DATA01-bank Sinbad size:
#print bank_data01_sinbad_end-bank_data01_sinbad_begin
#echo
#echo DATA01-bank free space:
#print $c000-*

#if $c000-* < 0
#echo *** Error: DATA01 bank occupies too much space
#else
.dsb $c000-*, CURRENT_BANK_NUMBER
#endif

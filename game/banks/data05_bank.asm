#echo
#echo ===== DATA05-BANK =====
* = $8000

bank_data05_begin:
bank_data05_character_sinbad_begin:
#include "game/data/characters/sinbad/sinbad.asm"
bank_data05_character_sinbad_end:
bank_data05_end:

#echo
#echo DATA05-bank data size:
#print bank_data05_end-bank_data05_begin
#echo
#echo DATA05-bank sinbad size:
#print bank_data05_character_sinbad_end-bank_data05_character_sinbad_begin
#echo
#echo DATA05-bank free space:
#print $c000-*

#if $c000-* < 0
#error DATADATA05 bank occupies too much space
#else
.dsb $c000-*, CURRENT_BANK_NUMBER
#endif

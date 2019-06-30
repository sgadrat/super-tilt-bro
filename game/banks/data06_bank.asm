#echo
#echo ===== DATA06-BANK =====
* = $8000

bank_data06_begin:
bank_data06_character_squareman_begin:
#include "game/data/characters/squareman/squareman.asm"
bank_data06_character_squareman_end:
bank_data06_end:

#echo
#echo DATA06-bank data size:
#print bank_data06_end-bank_data06_begin
#echo
#echo DATA06-bank squareman size:
#print bank_data06_character_squareman_end-bank_data06_character_squareman_begin
#echo
#echo DATA06-bank free space:
#print $c000-*

#if $c000-* < 0
#error DATADATA06 bank occupies too much space
#else
.dsb $c000-*, CURRENT_BANK_NUMBER
#endif

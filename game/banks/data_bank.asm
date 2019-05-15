#echo
#echo ====== DATA-BANK =====
* = $8000

#include "game/data/data.asm"

#echo
#echo DATA-bank data size:
#print data_end-data_begin
#echo
#echo DATA-bank nametables size:
#print data_nt_end-data_nt_begin
#echo
#echo DATA-bank free space:
#print $c000-*

#if $c000-* < 0
#echo *** Error: Data bank occupies too much space
#else
.dsb $c000-*, CURRENT_BANK_NUMBER
#endif

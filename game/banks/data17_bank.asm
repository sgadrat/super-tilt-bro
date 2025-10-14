.(
#echo
#echo ====== DATA-17-BANK =====
* = $8000

.byt CURRENT_BANK_NUMBER

bank_data17_begin:

.(
bank_data_begin:
#include "game/data/music/theme_sagely_concerto.asm"
#echo
#echo Theme A Sagely Concerto size:
#print *-bank_data_begin
.)

bank_data17_end:

#echo
#echo DATA-17-bank used size:
#print bank_data17_end-bank_data17_begin
#echo
#echo DATA-17-bank free space:
#print $c000-*

#if $c000-* < 0
#error Data bank occupies too much space
#else
.dsb $c000-*, $ff
#endif
.)

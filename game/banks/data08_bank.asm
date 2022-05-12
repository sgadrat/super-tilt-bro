#echo
#echo ====== DATA-08-BANK =====
* = $8000

bank_data08_begin:

bank_data_theme_kiki_begin:
#include "game/data/music/theme_kiki.asm"
#echo
#echo Theme kiki size:
#print *-bank_data_theme_kiki_begin

bank_data_stage_arcade_btt02_begin:
#include "game/data/stages/arcade/btt02/stage_arcade_btt02.asm"
#echo
#echo stage arcade btt02 size:
#print *-bank_data_stage_arcade_btt02_begin

bank_data08_end:

#echo
#echo DATA-08-bank used size:
#print bank_data08_end-bank_data08_begin
#echo
#echo DATA-08-bank free space:
#print $c000-*

#if $c000-* < 0
#error Data bank occupies too much space
#else
.dsb $c000-*, CURRENT_BANK_NUMBER
#endif

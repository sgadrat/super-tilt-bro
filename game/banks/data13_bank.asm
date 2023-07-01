.(
#echo
#echo ====== DATA-13-BANK =====
* = $8000

.byt CURRENT_BANK_NUMBER

bank_data13_begin:

.(
bank_data_begin:
#include "game/data/music/theme_sinbad2.asm"
#echo
#echo Sinbad2 theme size:
#print *-bank_data_begin
.)

.(
bank_data_begin:
#include "game/data/stages/arcade/fight_port/stage_arcade_fight_port.asm"
#echo
#echo Stage fight port
#print *-bank_data_begin
.)

.(
bank_data_begin:
#include "game/data/stages/arcade/fight_town/stage_arcade_fight_town.asm"
#echo
#echo Stage fight town
#print *-bank_data_begin
.)

bank_data13_end:

#echo
#echo DATA-13-bank used size:
#print bank_data13_end-bank_data13_begin
#echo
#echo DATA-13-bank free space:
#print $c000-*

#if $c000-* < 0
#error Data bank occupies too much space
#else
.dsb $c000-*, $ff
#endif
.)

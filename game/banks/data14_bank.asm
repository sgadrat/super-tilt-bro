.(
#echo
#echo ====== DATA-14-BANK =====
* = $8000

bank_data14_begin:

bank_data_music_pepper_begin:
#include "game/data/music/theme_pepper.asm"
#echo
#echo Pepper theme size:
#print *-bank_data_music_pepper_begin

.(
bank_data_begin:
#include "game/data/arcade/congratz/screen.asm"
#include "game/data/arcade/congratz/bg_tileset.asm"
#include "game/data/arcade/congratz/tiny_medal_tileset.asm"
#echo
#echo Arcade congratz screen data
#print *-bank_data_begin
.)

bank_data14_end:

#echo
#echo DATA-14-bank used size:
#print bank_data14_end-bank_data14_begin
#echo
#echo DATA-14-bank free space:
#print $c000-*

#if $c000-* < 0
#error Data bank occupies too much space
#else
.dsb $c000-*, CURRENT_BANK_NUMBER
#endif
.)

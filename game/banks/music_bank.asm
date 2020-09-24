#echo
#echo ===== MUSIC-BANK =====
* = $8000

#define MUSIC_BANK_NUMBER CURRENT_BANK_NUMBER

bank_music_begin:
#include "game/data/music/music.asm"
bank_music_end:

#echo
#echo MUSIC-bank data size:
#print bank_music_end-bank_music_begin
#echo
#echo MUSIC-bank free space:
#print $c000-*

#if $c000-* < 0
#error MUSIC bank occupies too much space
#else
.dsb $c000-*, CURRENT_BANK_NUMBER
#endif

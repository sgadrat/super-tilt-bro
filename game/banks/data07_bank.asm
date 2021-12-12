#echo
#echo ====== DATA-07-BANK =====
* = $8000

bank_data07_begin:

bank_data_credits_illustration_graphics_begin:
#include "game/data/menu_credits/illustration_graphics.asm"
#echo
#echo Credits illustration graphics data size:
#print *-bank_data_credits_illustration_graphics_begin

bank_data_credits_illustration_music_begin:
#include "game/data/menu_credits/illustration_music.asm"
#echo
#echo Credits illustration music data size:
#print *-bank_data_credits_illustration_music_begin

bank_data_credits_illustration_characters_begin:
#include "game/data/menu_credits/illustration_characters.asm"
#echo
#echo Credits illustration characters data size:
#print *-bank_data_credits_illustration_characters_begin

bank_data_credits_illustration_special_thanks_begin:
#include "game/data/menu_credits/illustration_special_thanks.asm"
#echo
#echo Credits illustration special_thanks data size:
#print *-bank_data_credits_illustration_special_thanks_begin

bank_data_credits_illustration_author_begin:
#include "game/data/menu_credits/illustration_author.asm"
#echo
#echo Credits illustration author data size:
#print *-bank_data_credits_illustration_author_begin

bank_data07_end:

#echo
#echo DATA-07-bank used size:
#print bank_data07_end-bank_data07_begin
#echo
#echo DATA-07-bank free space:
#print $c000-*

#if $c000-* < 0
#error Data bank occupies too much space
#else
.dsb $c000-*, CURRENT_BANK_NUMBER
#endif

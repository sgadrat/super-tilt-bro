#echo
#echo ====== DATA-03-BANK =====
* = $8000

bank_data03_begin:

bank_data03_theme_jump_rope_begin:
#include "game/data/music/theme_jump_rope.asm"
bank_data03_theme_jump_rope_end:
#echo
#echo DATA-03-bank theme jump_rope size:
#print bank_data03_theme_jump_rope_end-bank_data03_theme_jump_rope_begin

bank_data03_theme_perihelium_begin:
#include "game/data/music/theme_perihelium.asm"
bank_data03_theme_perihelium_end:
#echo
#echo DATA-03-bank theme perihelium size:
#print bank_data03_theme_perihelium_end-bank_data03_theme_perihelium_begin

bank_data03_theme_title_begin:
#include "game/data/music/theme_title.asm"
bank_data03_theme_title_end:
#echo
#echo DATA-03-bank theme title size:
#print bank_data03_theme_title_end-bank_data03_theme_title_begin

bank_data03_end:

#echo
#echo DATA-03-bank used size:
#print bank_data03_end-bank_data03_begin
#echo
#echo DATA-03-bank free space:
#print $c000-*

#if $c000-* < 0
#error Data bank occupies too much space
#else
.dsb $c000-*, CURRENT_BANK_NUMBER
#endif

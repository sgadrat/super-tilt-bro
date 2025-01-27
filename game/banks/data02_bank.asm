#echo
#echo ====== DATA-02-BANK =====
* = $8000

.byt CURRENT_BANK_NUMBER

bank_data02_begin:

bank_data_online_mode_extra_data_begin:
#include "game/data/menu_online_mode/anims.asm"
#include "game/data/menu_online_mode/screen.asm"
#echo
#echo Online mode extra data size:
#print *-bank_data_online_mode_extra_data_begin

bank_data_online_mode_extra_code_begin:
#include "game/logic/game_states/online_mode_screen/online_mode_screen_extra_code.asm"
#echo
#echo Online mode extra code size:
#print *-bank_data_online_mode_extra_code_begin

bank_data_charset_alphanum_fg1_bg2_begin:
#include "game/data/tilesets/charset_alphanum_fg1_bg2.asm"
#echo
#echo Charset alphanum (fg=1 bg=2):
#print *-bank_data_charset_alphanum_fg1_bg2_begin

bank_data_stage_flatland_begin:
#include "game/data/stages/plateau/plateau.asm"
#echo
#echo Stage Flatland size:
#print *-bank_data_stage_flatland_begin

bank_data_tileset_common_features_begin:
#include "game/data/tilesets/common_features.asm"
#echo
#echo Tilesets common features:
#print *-bank_data_tileset_common_features_begin

bank_data_common_ingame_sprites_begin:
#include "game/data/tilesets/common_ingame_sprites.asm"
#echo
#echo Tileset common ingame sprites:
#print *-bank_data_common_ingame_sprites_begin

.(
bank_data_begin:
#include "game/logic/utils_banked.asm"
#echo
#echo Banked utils:
#print *-bank_data_begin
.)

bank_data02_end:

#echo
#echo DATA-02-bank used size:
#print bank_data02_end-bank_data02_begin
#echo
#echo DATA-02-bank free space:
#print $c000-*

#if $c000-* < 0
#error Data bank occupies too much space
#else
.dsb $c000-*, $ff
#endif

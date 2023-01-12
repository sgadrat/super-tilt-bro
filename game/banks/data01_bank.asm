#echo
#echo ===== DATA01-BANK =====
* = $8000

bank_data01_begin:
bank_data01_tileset_green_grass_begin:
#include "game/data/tilesets/green_grass.asm"
bank_data01_tileset_green_grass_end:
bank_data01_tileset_menus_begin:
#include "game/data/tilesets/menus_tileset.asm"
bank_data01_tileset_menus_end:
bank_data01_char_select_screen_extra_data_begin:
#include "game/data/menu_char_select/screen.asm"
#include "game/data/menu_char_select/tilesets.asm"
#include "game/data/menu_char_select/anims.asm"
bank_data01_char_select_screen_extra_data_end:
bank_data01_char_select_screen_extra_code_begin:
#include "game/logic/game_states/character_selection_screen/character_selection_screen_extra_code.asm"
bank_data01_char_select_screen_extra_code_end:

.(
bank_data01_gameover_data_begin:
#include "game/data/menu_gameover/tilesets.asm"
#include "game/data/menu_gameover/screen.asm"
#echo
#echo DATA01-bank Gameover screen data:
#print *-bank_data01_gameover_data_begin
.)

bank_data_sfx:
#include "game/data/sfx.asm"
#echo
#echo Sound effects size:
#print *-bank_data_sfx

bank_data_charset_alphanum_fg0_bg2_begin:
#include "game/data/tilesets/charset_alphanum_fg0_bg2.asm"
#echo
#echo Charset alphanum (fg=0 bg=2):
#print *-bank_data_charset_alphanum_fg0_bg2_begin

.(
bank_data_extra_game_logic:
#include "game/logic/game_states/game/game_extra_logic.asm"
#echo
#echo Extra game logic:
#print *-bank_data_extra_game_logic
.)

.(
bank_data_extra_jukebox_data:
#include "game/data/menu_jukebox/tilesets.asm"
#include "game/data/menu_jukebox/screen.asm"
#include "game/data/menu_jukebox/anims.asm"
#echo
#echo Extra jukebox data:
#print *-bank_data_extra_jukebox_data
.)

.(
bank_data_cutscene_sinbad_common_tilesets:
#include "game/data/cutscenes/sinbad_story/common/tilesets.asm"
#echo
#echo Cutscene Sinbad common tilesets
#print *-bank_data_cutscene_sinbad_common_tilesets
.)

bank_data01_end:

#echo
#echo DATA01-bank data size:
#print bank_data01_end-bank_data01_begin
#echo
#echo DATA01-bank Green grass tileset size:
#print bank_data01_tileset_green_grass_end-bank_data01_tileset_green_grass_begin
#echo
#echo DATA01-bank Menus tileset size:
#print bank_data01_tileset_menus_end-bank_data01_tileset_menus_begin
#echo
#echo DATA01-bank Character selection screen extra data:
#print bank_data01_char_select_screen_extra_data_end-bank_data01_char_select_screen_extra_data_begin
#echo
#echo DATA01-bank Character selection screen extra code:
#print bank_data01_char_select_screen_extra_code_end-bank_data01_char_select_screen_extra_code_begin
#echo
#echo DATA01-bank free space:
#print $c000-*

#if $c000-* < 0
#error DATA01 bank occupies too much space
#else
.dsb $c000-*, CURRENT_BANK_NUMBER
#endif

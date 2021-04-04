#echo
#echo ===== DATA02-BANK =====
* = $8000

bank_data02_begin:
bank_data02_stage_pit_begin:
#include "game/data/stages/pit/pit.asm"
bank_data02_stage_pit_end:

bank_data02_stage_shelf_begin:
#include "game/data/stages/shelf/shelf.asm"
bank_data02_stage_shelf_end:

bank_data02_stage_gem_begin:
#include "game/data/stages/gem/gem.asm"
bank_data02_stage_gem_end:

bank_data02_stage_miniatures_begin:
#include "game/data/tilesets/stage_miniatures.asm"
bank_data02_stage_miniatures_end:

bank_data02_online_mode_extra_data_begin:
#include "game/data/menu_online_mode/tileset.asm"
bank_data02_online_mode_extra_data_end:

bank_data02_tileset_ascii_begin:
#include "game/data/tilesets/ascii.asm"
bank_data02_tileset_ascii_end:

bank_data02_wifi_settings_extra_data_begin:
#include "game/data/menu_wifi_settings/screen.asm"
#include "game/data/menu_wifi_settings/tileset.asm"
bank_data02_wifi_settings_extra_data_end:

bank_data02_wifi_settings_extra_code_begin:
#include "game/logic/game_states/wifi_settings_screen/wifi_settings_screen_extra_code.asm"
bank_data02_wifi_settings_extra_code_end:

bank_data02_end:

#echo
#echo DATA02-bank data size:
#print bank_data02_end-bank_data02_begin
#echo
#echo DATA02-bank Pit size:
#print bank_data02_stage_pit_end-bank_data02_stage_pit_begin
#echo
#echo DATA02-bank Shelf size:
#print bank_data02_stage_shelf_end-bank_data02_stage_shelf_begin
#echo
#echo DATA02-bank Gem size:
#print bank_data02_stage_gem_end-bank_data02_stage_gem_begin
#echo
#echo DATA02-bank Gem size:
#print bank_data02_stage_miniatures_end-bank_data02_stage_miniatures_begin
#echo
#echo DATA02-bank online mode extra data size:
#print bank_data02_online_mode_extra_data_end-bank_data02_online_mode_extra_data_begin
#echo
#echo DATA02-bank tileset ascii size:
#print bank_data02_tileset_ascii_end-bank_data02_tileset_ascii_begin
#echo
#echo DATA02-bank WiFi settings extra data size:
#print bank_data02_wifi_settings_extra_data_end-bank_data02_wifi_settings_extra_data_begin
#echo
#echo DATA02-bank WiFi settings extra code size:
#print bank_data02_wifi_settings_extra_code_end-bank_data02_wifi_settings_extra_code_begin
#echo
#echo DATA02-bank free space:
#print $c000-*

#if $c000-* < 0
#error DATA02 bank occupies too much space
#else
.dsb $c000-*, CURRENT_BANK_NUMBER
#endif

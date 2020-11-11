#echo
#echo ===== DATA01-BANK =====
* = $8000

bank_data01_begin:
bank_data01_tileset_common_begin:
#include "game/data/tilesets/common.asm"
bank_data01_tileset_common_end:
bank_data01_stage_plateau_begin:
#include "game/data/stages/plateau/plateau.asm"
bank_data01_stage_plateau_end:
bank_data01_tileset_green_grass_begin:
#include "game/data/tilesets/green_grass.asm"
bank_data01_tileset_green_grass_end:
bank_data01_tileset_menus_begin:
#include "game/data/tilesets/menus_tileset.asm"
bank_data01_tileset_menus_end:
bank_data01_tileset_logo_begin:
#include "game/data/tilesets/logo.asm"
bank_data01_tileset_logo_end:
bank_data01_config_screen_extra_begin:
#include "game/logic/game_states/config_screen_extra_bank.asm"
bank_data01_config_screen_extra_end:
bank_data01_end:

#echo
#echo DATA01-bank data size:
#print bank_data01_end-bank_data01_begin
#echo
#echo DATA01-bank Plateau size:
#print bank_data01_stage_plateau_end-bank_data01_stage_plateau_begin
#echo
#echo DATA01-bank Green grass tileset size:
#print bank_data01_tileset_green_grass_end-bank_data01_tileset_green_grass_begin
#echo
#echo DATA01-bank Menus tileset size:
#print bank_data01_tileset_menus_end-bank_data01_tileset_menus_begin
#echo
#echo DATA01-bank Common tileset size:
#print bank_data01_tileset_common_end-bank_data01_tileset_common_begin
#echo
#echo DATA01-bank Logo tileset size:
#print bank_data01_tileset_logo_end-bank_data01_tileset_logo_begin
#echo
#echo DATA01-bank Configuration screen extras:
#print bank_data01_config_screen_extra_end-bank_data01_config_screen_extra_begin
#echo
#echo DATA01-bank free space:
#print $c000-*

#if $c000-* < 0
#echo *** Error: DATA01 bank occupies too much space
#else
.dsb $c000-*, CURRENT_BANK_NUMBER
#endif

#echo
#echo ===== DATA04-BANK =====
* = $8000

.byt CURRENT_BANK_NUMBER

bank_data04_begin:

bank_data04_stage_skyride_begin:
#include "game/data/stages/skyride/stage_skyride.asm"
bank_data04_stage_skyride_end:

bank_data04_stage_thehunt_begin:
#include "game/data/stages/thehunt/stage_thehunt.asm"
bank_data04_stage_thehunt_end:

bank_data04_stage_miniatures_begin:
#include "game/data/tilesets/stage_miniatures.asm"
bank_data04_stage_miniatures_end:

bank_data04_online_mode_extra_data_begin:
#include "game/data/menu_online_mode/tileset.asm"
bank_data04_online_mode_extra_data_end:

bank_data04_tileset_ascii_begin:
#include "game/data/tilesets/ascii.asm"
bank_data04_tileset_ascii_end:

bank_data_config_screen_extra_begin:
#include "game/logic/game_states/config_screen/config_screen_extra_bank.asm"
#echo
#echo Configuration screen extras:
#print *-bank_data_config_screen_extra_begin

.(
bank_data_char_select_screen_extra_data:
#include "game/data/menu_char_select/screen.asm"
#include "game/data/menu_char_select/tilesets.asm"
#include "game/data/menu_char_select/anims.asm"
#echo
#echo Character selection screen extra data:
#print *-bank_data_char_select_screen_extra_data
.)

.(
bank_data_begin:
#include "game/logic/game_states/social_screen/social_screen_extra_code.asm"
#include "game/data/menu_social/anims.asm"
#echo
#echo Social screen extra code:
#print *-bank_data_begin
.)

bank_data04_end:

#echo
#echo DATA04-bank data size:
#print bank_data04_end-bank_data04_begin
#echo
#echo DATA04-bank Shelf size:
#print bank_data04_stage_skyride_end-bank_data04_stage_skyride_begin
#echo
#echo DATA04-bank Gem size:
#print bank_data04_stage_thehunt_end-bank_data04_stage_thehunt_begin
#echo
#echo DATA04-bank Gem size:
#print bank_data04_stage_miniatures_end-bank_data04_stage_miniatures_begin
#echo
#echo DATA04-bank online mode extra data size:
#print bank_data04_online_mode_extra_data_end-bank_data04_online_mode_extra_data_begin
#echo
#echo DATA04-bank tileset ascii size:
#print bank_data04_tileset_ascii_end-bank_data04_tileset_ascii_begin
#echo
#echo DATA04-bank free space:
#print $c000-*

#if $c000-* < 0
#error DATA04 bank occupies too much space
#else
.dsb $c000-*, $ff
#endif

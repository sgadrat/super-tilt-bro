.(
#echo
#echo ====== DATA-10-BANK =====
* = $8000

.byt CURRENT_BANK_NUMBER

bank_data10_begin:

bank_data_cutscene_logic_begin:
#include "game/logic/cutscenes.asm"
#echo
#echo cutscenes logic size
#print *-bank_data_cutscene_logic_begin

bank_data_stage_arcade_btt01_begin:
#include "game/data/stages/arcade/btt01/stage_arcade_btt01.asm"
#echo
#echo stage arcade btt01 size:
#print *-bank_data_stage_arcade_btt01_begin

bank_data_arcade_btt_sprites_begin:
#include "game/data/arcade/btt_sprites_tileset.asm"
#echo
#echo arcade btt sprites size:
#print *-bank_data_arcade_btt_sprites_begin

.(
bank_data_begin:
#include "game/data/cutscenes/sinbad_story/common/utils.asm"
#echo
#echo Cutscene Sinbad story utils
#print *-bank_data_begin
.)

bank_data_cutscene_sinbad_story_kiki_encounter_begin:
#include "game/data/cutscenes/sinbad_story/kiki_encounter/cutscene.asm"
#echo
#echo arcade cutscene sinbad story kiki encounter size:
#print *-bank_data_cutscene_sinbad_story_kiki_encounter_begin

bank_data_stage_arcade_boss_begin:
#include "game/data/stages/arcade/boss/stage_arcade_boss.asm"
#echo
#echo arcade stage boss size:
#print *-bank_data_stage_arcade_boss_begin

.(
bank_data_extra_jukebox_logic:
#include "game/logic/game_states/jukebox_screen/jukebox_screen_extra_logic.asm"
#echo
#echo Extra jukebox logic:
#print *-bank_data_extra_jukebox_logic
.)

.(
bank_data:
#include "game/data/cutscenes/sinbad_story/common/sinbad_dialog.asm"
#echo
#echo Sinbad dialog illustration size:
#print *-bank_data
.)

.(
bank_data:
#include "game/data/cutscenes/sinbad_story/pepper_encounter/tileset_pepper.asm"
#echo
#echo Pepper dialog illustration size:
#print *-bank_data
.)

.(
bank_data_begin:
#include "game/data/stages/arcade/tilesets/gameplay_elements.asm"
#echo
#echo Arcade tileset gameplay elements
#print *-bank_data_begin
.)

.(
bank_data_begin:
#include "game/data/stages/arcade/tilesets/town.asm"
#echo
#echo Arcade tileset town
#print *-bank_data_begin
.)

.(
bank_data_begin:
#include "game/data/stages/arcade/run01/tileset_port.asm"
#echo
#echo Arcade tileset port
#print *-bank_data_begin
.)

.(
bank_data_begin:
#include "game/data/stages/arcade/tilesets/wall.asm"
#echo
#echo Arcade tileset wall
#print *-bank_data_begin
.)

bank_data10_end:

#echo
#echo DATA-10-bank used size:
#print bank_data10_end-bank_data10_begin
#echo
#echo DATA-10-bank free space:
#print $c000-*

#if $c000-* < 0
#error Data bank occupies too much space
#else
.dsb $c000-*, $ff
#endif
.)

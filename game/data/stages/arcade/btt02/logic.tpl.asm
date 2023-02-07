!define "stage_name" {stage_arcade_btt02}
!define "cloud" {bg + 4*16}
!define "wall" {!place "cloud" + tileset_new_cloud_size}
!define "trees" {!place "wall" + arcade_wall_tileset_size}
!define "gameplay" {!place "trees" + arcade_trees_tileset_size}
!define "extra_init" {
	; Load colon tile
	TRAMPOLINE(arcade_write_colon_tile, #cutscene_sinbad_story_dialog_encounter_utils_bank, #CURRENT_BANK_NUMBER)

	; Load tilesets
	bg = $1000
	TRAMPOLINE(write_solid_bg_tiles, #BANKED_UTILS_BANK_NUMBER, #CURRENT_BANK_NUMBER)

	LOAD_TILESET(tileset_new_cloud, TILESET_NEW_CLOUD_BANK_NUMBER, !place "cloud", CURRENT_BANK_NUMBER)
	LOAD_TILESET(arcade_wall_tileset, ARCADE_WALL_TILESET_BANK_NUMBER, !place "wall", CURRENT_BANK_NUMBER)
	LOAD_TILESET(arcade_trees_tileset, ARCADE_TREES_TILESET_BANK_NUMBER, !place "trees", CURRENT_BANK_NUMBER)
	LOAD_TILESET(arcade_gameplay_elements_tileset, ARCADE_GAMEPLAY_ELEMENTS_TILESET_BANK_NUMBER, !place "gameplay", CURRENT_BANK_NUMBER)

	; Initialize moving targets
	jsr stage_actor_target_mover_init
	.word top_target_x, top_target_path

	jsr stage_actor_target_mover_init
	.word circle_target_x, circle_target_path

	jsr stage_actor_target_mover_init
	.word bot_target_x, bot_target_path
}
!define "extra_tick" {
	; Tick moving targets
	TOP_TARGET_INDEX = 6
	jsr stage_actor_target_mover
	.byt TOP_TARGET_INDEX
	.word top_target_x, top_target_path
	.byt 48-4, 40-4
	.byt 1

	CIRCLE_TARGET_INDEX = 9
	jsr stage_actor_target_mover
	.byt CIRCLE_TARGET_INDEX
	.word circle_target_x, circle_target_path
	.byt 84-4, 52-4
	.byt 2

	BOT_TARGET_INDEX = 7
	jsr stage_actor_target_mover
	.byt BOT_TARGET_INDEX
	.word bot_target_x, bot_target_path
	.byt 149-4, 139-4
	.byt 2
}

.(
cursor = stage_state_begin
&circle_target_x = cursor : -cursor += 1
&circle_target_y = cursor : -cursor += 1
&circle_target_current_waypoint = cursor : -cursor += 1

&top_target_x = cursor : -cursor += 1
&top_target_y = cursor : -cursor += 1
&top_target_current_waypoint = cursor : -cursor += 1

&bot_target_x = cursor : -cursor += 1
&bot_target_y = cursor : -cursor += 1
&bot_target_current_waypoint = cursor : -cursor += 1

#if cursor - stage_state_begin >= $10
#error arcade stage BTT02 uses to much memory
#endif
.)

#include "game/data/stages/arcade/btt02/stages_lib.asm"
!include "stages/std_stage.asm"

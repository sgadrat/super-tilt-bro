!define "stage_name" {stage_arcade_run01}
!define "extra_init" {
	; Load colon tile
	TRAMPOLINE(arcade_write_colon_tile, #cutscene_sinbad_story_dialog_encounter_utils_bank, #CURRENT_BANK_NUMBER)

	; Load tilesets
	bg = $1000
	TRAMPOLINE(write_solid_bg_tiles, #BANKED_UTILS_BANK_NUMBER, #CURRENT_BANK_NUMBER)
	water = bg+4*16
	LOAD_TILESET(cutscene_sinbad_story_common_water_tileset, cutscene_sinbad_story_common_tilesets_bank, water, CURRENT_BANK_NUMBER)
	cloud = water + cutscene_sinbad_story_common_water_tileset_end - cutscene_sinbad_story_common_water_tileset_tiles
	LOAD_TILESET_REMAP(tileset_new_cloud, TILESET_NEW_CLOUD_BANK_NUMBER, cloud, #2,#1,#2,#3 , CURRENT_BANK_NUMBER)
	port = cloud + tileset_new_cloud_end - tileset_new_cloud_tiles
	LOAD_TILESET(arcade_run01_port_tileset, ARCADE_RUN01_PORT_TILESET_BANK_NUMBER, port, CURRENT_BANK_NUMBER)
	town = port + arcade_run01_port_tileset_size
	LOAD_TILESET(arcade_town_tileset, ARCADE_TOWN_TILESET_BANK_NUMBER, town, CURRENT_BANK_NUMBER)
	gameplay = town + arcade_town_tileset_size
	LOAD_TILESET(arcade_gameplay_elements_tileset, ARCADE_GAMEPLAY_ELEMENTS_TILESET_BANK_NUMBER, gameplay, CURRENT_BANK_NUMBER)
}
!define "extra_tick" {}
!include "stages/std_stage.asm"

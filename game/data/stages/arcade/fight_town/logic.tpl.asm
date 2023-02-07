!define "stage_name" {stage_arcade_fight_town}
!define "water" {bg + 4*16}
!define "cloud" {!place "water" + cutscene_sinbad_story_common_water_tileset_size}
!define "port" {!place "cloud" + tileset_new_cloud_size}
!define "town" {!place "port" + arcade_run01_port_tileset_size}
!define "extra_init" {
	; Load colon tile
	TRAMPOLINE(arcade_write_colon_tile, #cutscene_sinbad_story_dialog_encounter_utils_bank, #CURRENT_BANK_NUMBER)

	; Load tilesets
	bg = $1000
	TRAMPOLINE(write_solid_bg_tiles, #BANKED_UTILS_BANK_NUMBER, #CURRENT_BANK_NUMBER)

	LOAD_TILESET(cutscene_sinbad_story_common_water_tileset, cutscene_sinbad_story_common_tilesets_bank, !place "water", CURRENT_BANK_NUMBER)
	LOAD_TILESET_REMAP(tileset_new_cloud, TILESET_NEW_CLOUD_BANK_NUMBER, !place "cloud", #3,#1,#3,#2, CURRENT_BANK_NUMBER)
	LOAD_TILESET(arcade_run01_port_tileset, ARCADE_RUN01_PORT_TILESET_BANK_NUMBER, !place "port", CURRENT_BANK_NUMBER)
	LOAD_TILESET(arcade_town_tileset, ARCADE_TOWN_TILESET_BANK_NUMBER, !place "town", CURRENT_BANK_NUMBER)
}
!define "extra_tick" {}
!include "stages/std_stage.asm"

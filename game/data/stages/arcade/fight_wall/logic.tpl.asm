!define "stage_name" {stage_arcade_fight_wall}
!define "cloud" {bg + 4*16}
!define "town" {!place "cloud" + tileset_new_cloud_size}
!define "wall" {!place "town" + arcade_town_tileset_size}
!define "gameplay" {!place "wall" + arcade_wall_tileset_size}
!define "extra_init" {
	; Load colon tile
    TRAMPOLINE(arcade_write_colon_tile, #cutscene_sinbad_story_dialog_encounter_utils_bank, #CURRENT_BANK_NUMBER)

    ; Load tilesets
    bg = $1000
    TRAMPOLINE(write_solid_bg_tiles, #BANKED_UTILS_BANK_NUMBER, #CURRENT_BANK_NUMBER)

    LOAD_TILESET_REMAP(tileset_new_cloud, TILESET_NEW_CLOUD_BANK_NUMBER, !place "cloud", #3,#1,#3,#2, CURRENT_BANK_NUMBER)
    LOAD_TILESET(arcade_town_tileset, ARCADE_TOWN_TILESET_BANK_NUMBER, !place "town", CURRENT_BANK_NUMBER)
	LOAD_TILESET(arcade_wall_tileset, ARCADE_WALL_TILESET_BANK_NUMBER, !place "wall", CURRENT_BANK_NUMBER)
	LOAD_TILESET(arcade_gameplay_elements_tileset, ARCADE_GAMEPLAY_ELEMENTS_TILESET_BANK_NUMBER, !place "gameplay", CURRENT_BANK_NUMBER)
}
!define "extra_tick" {}
!include "stages/std_stage.asm"

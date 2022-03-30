stages_init_routine:
RAW_VECTOR(stage_generic_init) ; Plateau
RAW_VECTOR(stage_pit_init) ; Pit
RAW_VECTOR(stage_generic_init) ; Shelf
RAW_VECTOR(stage_gem_init) ; Gem

stage_arcade_first_index = (* - stages_init_routine) / 2
RAW_VECTOR(stage_generic_init) ; arcade test01
RAW_VECTOR(stage_generic_init) ; arcade btt01

stages_tick_routine:
RAW_VECTOR(dummy_routine) ; Plateau
RAW_VECTOR(stage_pit_tick) ; Pit
RAW_VECTOR(dummy_routine) ; Shelf
RAW_VECTOR(stage_gem_tick) ; Gem

RAW_VECTOR(dummy_routine) ; arcade test01
RAW_VECTOR(dummy_routine) ; arcade btt01

stages_freezed_tick_routine_lsb:
.byt <dummy_routine ; Plateau
.byt <dummy_routine ; Pit
.byt <dummy_routine ; Shelf
.byt <stage_gem_freezed_tick ; Gem

.byt <dummy_routine ; arcade test01
.byt <dummy_routine ; arcade btt01

stages_freezed_tick_routine_msb:
.byt >dummy_routine ; Plateau
.byt >dummy_routine ; Pit
.byt >dummy_routine ; Shelf
.byt >stage_gem_freezed_tick ; Gem

.byt >dummy_routine ; arcade test01
.byt >dummy_routine ; arcade btt01

stages_nametable:
RAW_VECTOR(nametable_flatland) ; Plateau
RAW_VECTOR(nametable_stage_pit) ; Pit
RAW_VECTOR(nametable_stage_shelf) ; Shelf
RAW_VECTOR(nametable_stage_gem) ; Gem

RAW_VECTOR(stage_arcade_test01_nametable)
RAW_VECTOR(stage_btt01_nametable)

stage_palettes:
RAW_VECTOR(stage_plateau_palette_data) ; Plateau
RAW_VECTOR(stage_pit_palette_data) ; Pit
RAW_VECTOR(stage_shelf_palette_data) ; Shelf
RAW_VECTOR(stage_gem_palette_data) ; Gem

RAW_VECTOR(stage_arcade_test01_palette_data)
RAW_VECTOR(stage_btt01_palette_data)

stages_data:
RAW_VECTOR(stage_plateau_data) ; Plateau
RAW_VECTOR(stage_pit_data) ; Pit
RAW_VECTOR(stage_shelf_data) ; Shelf
RAW_VECTOR(stage_gem_data) ; Gem

RAW_VECTOR(stage_arcade_test01_data)
RAW_VECTOR(stage_btt01_data)

stages_illustration:
RAW_VECTOR(stage_plateau_illustration) ; Plateau
RAW_VECTOR(stage_pit_illustration) ; Pit
RAW_VECTOR(stage_shelf_illustration) ; Shelf
RAW_VECTOR(stage_gem_illustration) ; Gem

RAW_VECTOR($0000) ; dummy value, unused for arcade stages
RAW_VECTOR($0000) ; dummy value, unused for arcade stages

stages_netload_routine_lsb:
.byt <dummy_routine ; Plateau
.byt <stage_pit_netload ; Pit
.byt <dummy_routine ; Shelf
.byt <stage_gem_netload ; Gem

.byt <dummy_routine
.byt <dummy_routine

stages_netload_routine_msb:
.byt >dummy_routine ; Plateau
.byt >stage_pit_netload ; Pit
.byt >dummy_routine ; Shelf
.byt >stage_gem_netload ; Gem

.byt >dummy_routine
.byt >dummy_routine

stages_bank:
.byt STAGE_PLATEAU_BANK_NUMBER ; Plateau
.byt STAGE_PIT_BANK_NUMBER ; Pit
.byt STAGE_SHELF_BANK_NUMBER ; Shelf
.byt STAGE_GEM_BANK_NUMBER ; Gem

.byt STAGE_ARCADE_TEST01_BANK_NUMBER
.byt STAGE_BTT01_BANK_NUMBER

stages_tileset_lsb:
.byt <tileset_ruins ; Plateau
.byt <tileset_jungle ; Pit
.byt <tileset_ruins ; Shelf
.byt <tileset_magma ; Gem

.byt <arcade_test_stage_tileset ; arcade test01
.byt <arcade_test_stage_tileset ; arcade btt01

stages_tileset_msb:
.byt >tileset_ruins ; Plateau
.byt >tileset_jungle ; Pit
.byt >tileset_ruins ; Shelf
.byt >tileset_magma ; Gem

.byt >arcade_test_stage_tileset ; arcade test01
.byt >arcade_test_stage_tileset ; arcade btt01

stages_tileset_bank:
.byt TILESET_RUINS_BANK_NUMBER ; Plateau
.byt TILESET_JUNGLE_BANK_NUMBER ; Pit
.byt TILESET_RUINS_BANK_NUMBER ; Shelf
.byt TILESET_MAGMA_BANK_NUMBER ; Gem

.byt ARCADE_TEST_STAGE_TILESET_BANK_NUMBER ; arcade test01
.byt ARCADE_TEST_STAGE_TILESET_BANK_NUMBER ; arcade btt01

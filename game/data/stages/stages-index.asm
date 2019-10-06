stages_init_routine:
RAW_VECTOR(stage_generic_init) ; Plateau
RAW_VECTOR(stage_pit_init) ; Pit
RAW_VECTOR(stage_generic_init) ; Shelf
RAW_VECTOR(stage_gem_init) ; Gem

stages_tick_routine:
RAW_VECTOR(dummy_routine) ; Plateau
RAW_VECTOR(stage_pit_tick) ; Pit
RAW_VECTOR(dummy_routine) ; Shelf
RAW_VECTOR(stage_gem_tick) ; Gem

stages_nametable:
RAW_VECTOR(nametable_flatland) ; Plateau
RAW_VECTOR(nametable_stage_pit) ; Pit
RAW_VECTOR(nametable_stage_shelf) ; Shelf
RAW_VECTOR(nametable_stage_gem) ; Gem

stage_palettes:
RAW_VECTOR(stage_plateau_palette_data) ; Plateau
RAW_VECTOR(stage_pit_palette_data) ; Pit
RAW_VECTOR(stage_shelf_palette_data) ; Shelf
RAW_VECTOR(stage_gem_palette_data) ; Gem

stages_data:
RAW_VECTOR(stage_plateau_data) ; Plateau
RAW_VECTOR(stage_pit_data) ; Pit
RAW_VECTOR(stage_shelf_data) ; Shelf
RAW_VECTOR(stage_gem_data) ; Gem

stages_bank:
.byt STAGE_PLATEAU_BANK_NUMBER ; Plateau
.byt STAGE_PIT_BANK_NUMBER ; Pit
.byt STAGE_SHELF_BANK_NUMBER ; Shelf
.byt STAGE_GEM_BANK_NUMBER ; Gem

stages_tileset_lsb:
.byt <tileset_ruins ; Plateau
.byt <tileset_jungle ; Pit
.byt <tileset_ruins ; Shelf
.byt <tileset_magma ; Gem

stages_tileset_msb:
.byt >tileset_ruins ; Plateau
.byt >tileset_jungle ; Pit
.byt >tileset_ruins ; Shelf
.byt >tileset_magma ; Gem

stages_tileset_bank:
.byt TILESET_RUINS_BANK_NUMBER ; Plateau
.byt TILESET_JUNGLE_BANK_NUMBER ; Pit
.byt TILESET_RUINS_BANK_NUMBER ; Shelf
.byt TILESET_MAGMA_BANK_NUMBER ; Gem

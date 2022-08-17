stages_init_routine:
RAW_VECTOR(dummy_routine) ; Flatland
RAW_VECTOR(stage_pit_init) ; Pit
RAW_VECTOR(dummy_routine) ; Skyride
RAW_VECTOR(stage_thehunt_init) ; The Hunt

stage_versus_end_index = (* - stages_init_routine) / 2
RAW_VECTOR(stage_arcade_boss_init) ; arcade boss

stage_arcade_first_index = (* - stages_init_routine) / 2
RAW_VECTOR(dummy_routine) ; arcade run01
RAW_VECTOR(dummy_routine) ; arcade btt01
RAW_VECTOR(dummy_routine) ; arcade run02
RAW_VECTOR(stage_arcade_btt02_init) ; arcade btt02

stages_tick_routine:
RAW_VECTOR(dummy_routine) ; Flatland
RAW_VECTOR(stage_pit_tick) ; Pit
RAW_VECTOR(dummy_routine) ; Skyride
RAW_VECTOR(stage_thehunt_tick) ; The Hunt

RAW_VECTOR(stage_arcade_boss_tick) ; arcade boss

RAW_VECTOR(dummy_routine) ; arcade run01
RAW_VECTOR(dummy_routine) ; arcade btt01
RAW_VECTOR(dummy_routine) ; arcade run02
RAW_VECTOR(stage_arcade_btt02_tick) ; arcade btt02

stages_freezed_tick_routine_lsb:
.byt <dummy_routine ; Flatland
.byt <dummy_routine ; Pit
.byt <dummy_routine ; Skyride
.byt <stage_thehunt_freezed_tick ; The Hunt

.byt <stage_arcade_boss_freezed_tick ; arcade boss

.byt <dummy_routine ; arcade run01
.byt <dummy_routine ; arcade btt01
.byt <dummy_routine ; arcade run02
.byt <dummy_routine ; arcade btt02

stages_freezed_tick_routine_msb:
.byt >dummy_routine ; Flatland
.byt >dummy_routine ; Pit
.byt >dummy_routine ; Skyride
.byt >stage_thehunt_freezed_tick ; The Hunt

.byt >stage_arcade_boss_freezed_tick ; arcade boss

.byt >dummy_routine ; arcade run01
.byt >dummy_routine ; arcade btt01
.byt >dummy_routine ; arcade run02
.byt >dummy_routine ; arcade btt02

stages_nametable:
RAW_VECTOR(nametable_flatland) ; Flatland
RAW_VECTOR(nametable_stage_pit) ; Pit
RAW_VECTOR(nametable_stage_skyride) ; Skyride
RAW_VECTOR(nametable_stage_thehunt) ; The Hunt

RAW_VECTOR(stage_arcade_boss_space_nametable) ; arcade boss

RAW_VECTOR(stage_arcade_run01_nametable)
RAW_VECTOR(stage_arcade_btt01_nametable)
RAW_VECTOR(stage_arcade_run02_nametable)
RAW_VECTOR(stage_arcade_btt02_nametable)

stage_palettes:
RAW_VECTOR(stage_flatland_palette) ; Flatland
RAW_VECTOR(stage_pit_palette) ; Pit
RAW_VECTOR(stage_skyride_palette) ; Skyride
RAW_VECTOR(stage_thehunt_palette) ; The Hunt

RAW_VECTOR(stage_arcade_boss_space_palette_data) ; arcade boss

RAW_VECTOR(stage_arcade_run01_palette_data)
RAW_VECTOR(stage_arcade_btt01_palette_data)
RAW_VECTOR(stage_arcade_run02_palette_data)
RAW_VECTOR(stage_arcade_btt02_palette_data)

stage_routine_fadeout_lsb:
.byt <stage_flatland_fadeout ; Flatland
.byt <stage_pit_fadeout ; Pit
.byt <stage_skyride_fadeout ; Skyride
.byt <stage_thehunt_fadeout ; The Hunt
.byt <dummy_routine ; arcade boss
.byt <dummy_routine ; arcade run01
.byt <dummy_routine ; arcade btt01
.byt <dummy_routine ; arcade run02
.byt <dummy_routine ; arcade btt02
stage_routine_fadeout_msb:
.byt >stage_flatland_fadeout ; Flatland
.byt >stage_pit_fadeout ; Pit
.byt >stage_skyride_fadeout ; Skyride
.byt >stage_thehunt_fadeout ; The Hunt
.byt >dummy_routine ; arcade boss
.byt >dummy_routine ; arcade run01
.byt >dummy_routine ; arcade btt01
.byt >dummy_routine ; arcade run02
.byt >dummy_routine ; arcade btt02

stages_data:
RAW_VECTOR(stage_flatland_data) ; Flatland
RAW_VECTOR(stage_pit_data) ; Pit
RAW_VECTOR(stage_skyride_data) ; Skyride
RAW_VECTOR(stage_thehunt_data) ; The Hunt

RAW_VECTOR(stage_arcade_boss_space_data) ; arcade boss

RAW_VECTOR(stage_arcade_run01_data)
RAW_VECTOR(stage_arcade_btt01_data)
RAW_VECTOR(stage_arcade_run02_data)
RAW_VECTOR(stage_arcade_btt02_data)

stages_illustration:
RAW_VECTOR(stage_flatland_illustration) ; Flatland
RAW_VECTOR(stage_pit_illustration) ; Pit
RAW_VECTOR(stage_skyride_illustration) ; Skyride
RAW_VECTOR(stage_thehunt_illustration) ; The Hunt

RAW_VECTOR($0000) ; arcade boss

RAW_VECTOR($0000) ; dummy value, unused for arcade stages
RAW_VECTOR($0000) ; dummy value, unused for arcade stages
RAW_VECTOR($0000) ; dummy value, unused for arcade stages
RAW_VECTOR($0000) ; dummy value, unused for arcade stages

stages_netload_routine_lsb:
.byt <dummy_routine ; Flatland
.byt <stage_pit_netload ; Pit
.byt <dummy_routine ; Skyride
.byt <stage_thehunt_netload ; The Hunt

.byt <dummy_routine ; arcade boss

.byt <dummy_routine
.byt <dummy_routine
.byt <dummy_routine
.byt <dummy_routine

stages_netload_routine_msb:
.byt >dummy_routine ; Flatland
.byt >stage_pit_netload ; Pit
.byt >dummy_routine ; Skyride
.byt >stage_thehunt_netload ; The Hunt

.byt >dummy_routine ; arcade boss

.byt >dummy_routine
.byt >dummy_routine
.byt >dummy_routine
.byt >dummy_routine

stages_bank:
.byt STAGE_FLATLAND_BANK_NUMBER ; Flatland
.byt STAGE_PIT_BANK_NUMBER ; Pit
.byt STAGE_SKYRIDE_BANK_NUMBER ; Skyride
.byt STAGE_THEHUNT_BANK_NUMBER ; The Hunt

.byt STAGE_ARCADE_BOSS_BANK_NUMBER ; arcade boss

.byt STAGE_ARCADE_RUN01_BANK_NUMBER
.byt STAGE_ARCADE_BTT01_BANK_NUMBER
.byt STAGE_ARCADE_RUN02_BANK_NUMBER
.byt STAGE_ARCADE_BTT02_BANK_NUMBER

stages_tileset_lsb:
.byt <tileset_ruins ; Flatland
.byt <tileset_jungle ; Pit
.byt <tileset_ruins ; Skyride
.byt <tileset_magma ; The Hunt

.byt <tileset_magma ; arcade boss

.byt <arcade_test_stage_tileset ; arcade run01
.byt <arcade_test_stage_tileset ; arcade btt01
.byt <arcade_test_stage_tileset ; arcade run02
.byt <arcade_test_stage_tileset ; arcade btt02

stages_tileset_msb:
.byt >tileset_ruins ; Flatland
.byt >tileset_jungle ; Pit
.byt >tileset_ruins ; Skyride
.byt >tileset_magma ; The Hunt

.byt >tileset_magma ; arcade boss

.byt >arcade_test_stage_tileset ; arcade run01
.byt >arcade_test_stage_tileset ; arcade btt01
.byt >arcade_test_stage_tileset ; arcade run02
.byt >arcade_test_stage_tileset ; arcade btt02

stages_tileset_bank:
.byt TILESET_RUINS_BANK_NUMBER ; Flatland
.byt TILESET_JUNGLE_BANK_NUMBER ; Pit
.byt TILESET_RUINS_BANK_NUMBER ; Skyride
.byt TILESET_MAGMA_BANK_NUMBER ; The Hunt

.byt TILESET_MAGMA_BANK_NUMBER ; arcade boss

.byt ARCADE_TEST_STAGE_TILESET_BANK_NUMBER ; arcade run01
.byt ARCADE_TEST_STAGE_TILESET_BANK_NUMBER ; arcade btt01
.byt ARCADE_TEST_STAGE_TILESET_BANK_NUMBER ; arcade run02
.byt ARCADE_TEST_STAGE_TILESET_BANK_NUMBER ; arcade btt02

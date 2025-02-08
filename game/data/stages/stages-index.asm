stages_init_routine:
RAW_VECTOR(stage_flatland_init) : stage_flatland_index = ((* - stages_init_routine) / 2) - 1 ; Flatland
RAW_VECTOR(stage_pit_init) : stage_pit_index = ((* - stages_init_routine) / 2) - 1 ; Pit
RAW_VECTOR(stage_skyride_init) : stage_skyride_index = ((* - stages_init_routine) / 2) - 1 ; Skyride
RAW_VECTOR(stage_thehunt_init) : stage_thehunt_index = ((* - stages_init_routine) / 2) - 1 ; The Hunt
RAW_VECTOR(stage_theplank_init) : stage_theplank_index = ((* - stages_init_routine) / 2) - 1 ; The Plank
RAW_VECTOR(stage_deeprock_init) : stage_deeprock_index = ((* - stages_init_routine) / 2) - 1 ; Deep Rock

stage_versus_end_index = (* - stages_init_routine) / 2
RAW_VECTOR(stage_arcade_boss_init) : stage_arcade_boss_index = ((* - stages_init_routine) / 2) - 1 ; arcade boss
RAW_VECTOR(stage_arcade_fight_port_init): stage_arcade_fight_port_index = ((* - stages_init_routine) / 2) - 1 ; Port
RAW_VECTOR(stage_arcade_fight_town_init): stage_arcade_fight_town_index = ((* - stages_init_routine) / 2) - 1 ; Town
RAW_VECTOR(stage_arcade_fight_wall_init): stage_arcade_fight_wall_index = ((* - stages_init_routine) / 2) - 1 ; Wall
RAW_VECTOR(stage_arcade_gameover_init): stage_arcade_gameover_index = ((* - stages_init_routine) / 2) - 1 ; Gameover

stage_arcade_first_index = (* - stages_init_routine) / 2
RAW_VECTOR(stage_arcade_run01_init) : stage_arcade_run01_index = ((* - stages_init_routine) / 2) - stage_arcade_first_index - 1 ; arcade run01
RAW_VECTOR(stage_arcade_btt01_init) : stage_arcade_btt01_index = ((* - stages_init_routine) / 2) - stage_arcade_first_index - 1 ; arcade btt01
RAW_VECTOR(stage_arcade_run02_init) : stage_arcade_run02_index = ((* - stages_init_routine) / 2) - stage_arcade_first_index - 1 ; arcade run02
RAW_VECTOR(stage_arcade_btt02_init) : stage_arcade_btt02_index = ((* - stages_init_routine) / 2) - stage_arcade_first_index - 1 ; arcade btt02

stages_tick_routine:
RAW_VECTOR(stage_flatland_tick) ; Flatland
RAW_VECTOR(stage_pit_tick) ; Pit
RAW_VECTOR(stage_skyride_tick) ; Skyride
RAW_VECTOR(stage_thehunt_tick) ; The Hunt
RAW_VECTOR(stage_theplank_tick) ; The Plank
RAW_VECTOR(stage_deeprock_tick) ; Deep Rock

RAW_VECTOR(stage_arcade_boss_tick) ; arcade boss
RAW_VECTOR(stage_arcade_fight_port_tick) ; Port
RAW_VECTOR(stage_arcade_fight_town_tick) ; Town
RAW_VECTOR(stage_arcade_fight_wall_tick) ; Wall
RAW_VECTOR(stage_arcade_gameover_tick) ; Gameover

RAW_VECTOR(stage_arcade_run01_tick) ; arcade run01
RAW_VECTOR(stage_arcade_btt01_tick) ; arcade btt01
RAW_VECTOR(stage_arcade_run02_tick) ; arcade run02
RAW_VECTOR(stage_arcade_btt02_tick) ; arcade btt02

stages_freezed_tick_routine_lsb:
.byt <dummy_routine ; Flatland
.byt <dummy_routine ; Pit
.byt <dummy_routine ; Skyride
.byt <stage_thehunt_freezed_tick ; The Hunt
.byt <dummy_routine ; The Plank
.byt <stage_deeprock_tick ; Deep Rock

.byt <stage_arcade_boss_freezed_tick ; arcade boss
.byt <dummy_routine ; Port
.byt <dummy_routine ; Town
.byt <dummy_routine ; Wall
.byt <dummy_routine ; Gameover

.byt <dummy_routine ; arcade run01
.byt <dummy_routine ; arcade btt01
.byt <dummy_routine ; arcade run02
.byt <dummy_routine ; arcade btt02

stages_freezed_tick_routine_msb:
.byt >dummy_routine ; Flatland
.byt >dummy_routine ; Pit
.byt >dummy_routine ; Skyride
.byt >stage_thehunt_freezed_tick ; The Hunt
.byt >dummy_routine ; The Plank
.byt >stage_deeprock_tick ; Deep Rock

.byt >stage_arcade_boss_freezed_tick ; arcade boss
.byt >dummy_routine ; Port
.byt >dummy_routine ; Town
.byt >dummy_routine ; Wall
.byt >dummy_routine ; Gameover

.byt >dummy_routine ; arcade run01
.byt >dummy_routine ; arcade btt01
.byt >dummy_routine ; arcade run02
.byt >dummy_routine ; arcade btt02

stages_ringout_routine_lsb:
.byt <stage_flatland_ringout_check ; Flatland
.byt <stage_pit_ringout_check ; Pit
.byt <stage_skyride_ringout_check ; Skyride
.byt <stage_thehunt_ringout_check ; The Hunt
.byt <stage_theplank_ringout_check ; The Plank
.byt <stage_deeprock_ringout_check ; Deep Rock

.byt <stage_arcade_boss_ringout_check ; arcade boss
.byt <stage_arcade_fight_port_ringout_check ; Port
.byt <stage_arcade_fight_town_ringout_check ; Town
.byt <stage_arcade_fight_wall_ringout_check ; Wall
.byt <stage_arcade_gameover_ringout_check ; Gameover

.byt <stage_arcade_run01_ringout_check ; arcade run01
.byt <stage_arcade_btt01_ringout_check ; arcade btt01
.byt <stage_arcade_run02_ringout_check ; arcade run02
.byt <stage_arcade_btt02_ringout_check ; arcade btt02

stages_ringout_routine_msb:
.byt >stage_flatland_ringout_check ; Flatland
.byt >stage_pit_ringout_check ; Pit
.byt >stage_skyride_ringout_check ; Skyride
.byt >stage_thehunt_ringout_check ; The Hunt
.byt >stage_theplank_ringout_check ; The Plank
.byt >stage_deeprock_ringout_check ; Deep Rock

.byt >stage_arcade_boss_ringout_check ; arcade boss
.byt >stage_arcade_fight_port_ringout_check ; Port
.byt >stage_arcade_fight_town_ringout_check ; Town
.byt >stage_arcade_fight_wall_ringout_check ; Wall
.byt >stage_arcade_gameover_ringout_check ; Gameover

.byt >stage_arcade_run01_ringout_check ; arcade run01
.byt >stage_arcade_btt01_ringout_check ; arcade btt01
.byt >stage_arcade_run02_ringout_check ; arcade run02
.byt >stage_arcade_btt02_ringout_check ; arcade btt02

stages_nametable:
RAW_VECTOR(nametable_flatland) ; Flatland
RAW_VECTOR(nametable_stage_pit) ; Pit
RAW_VECTOR(nametable_stage_skyride) ; Skyride
RAW_VECTOR(nametable_stage_thehunt) ; The Hunt
RAW_VECTOR(stage_theplank_nametable) ; The Plank
RAW_VECTOR(stage_deeprock_nametable) ; Deep Rock

RAW_VECTOR(stage_arcade_boss_space_nametable) ; arcade boss
RAW_VECTOR(stage_arcade_fight_port_nametable) ; Port
RAW_VECTOR(stage_arcade_fight_town_nametable) ; Town
RAW_VECTOR(stage_arcade_fight_wall_nametable) ; Wall
RAW_VECTOR(stage_arcade_gameover_nametable) ; Gameover

RAW_VECTOR(stage_arcade_run01_nametable)
RAW_VECTOR(stage_arcade_btt01_nametable)
RAW_VECTOR(stage_arcade_run02_nametable)
RAW_VECTOR(stage_arcade_btt02_nametable)

stage_palettes:
RAW_VECTOR(stage_flatland_palette) ; Flatland
RAW_VECTOR(stage_pit_palette) ; Pit
RAW_VECTOR(stage_skyride_palette) ; Skyride
RAW_VECTOR(stage_thehunt_palette) ; The Hunt
RAW_VECTOR(stage_theplank_palette) ; The Plank
RAW_VECTOR(stage_deeprock_palette) ; Deep Rock

RAW_VECTOR(stage_arcade_boss_space_palette) ; arcade boss
RAW_VECTOR(stage_arcade_fight_port_palette) ; Port
RAW_VECTOR(stage_arcade_fight_town_palette) ; Town
RAW_VECTOR(stage_arcade_fight_wall_palette) ; Wall
RAW_VECTOR(stage_arcade_gameover_palette) ; Gameover

RAW_VECTOR(stage_arcade_run01_palette)
RAW_VECTOR(stage_arcade_btt01_palette)
RAW_VECTOR(stage_arcade_run02_palette)
RAW_VECTOR(stage_arcade_btt02_palette)

stage_routine_fadeout_lsb:
.byt <stage_flatland_fadeout ; Flatland
.byt <stage_pit_fadeout ; Pit
.byt <stage_skyride_fadeout ; Skyride
.byt <stage_thehunt_fadeout ; The Hunt
.byt <stage_theplank_fadeout ; The Plank
.byt <stage_deeprock_fadeout ; Deep Rock
.byt <dummy_routine ; arcade boss
.byt <stage_arcade_fight_port_fadeout ; Port
.byt <stage_arcade_fight_town_fadeout ; Town
.byt <stage_arcade_fight_wall_fadeout ; Wall
.byt <stage_arcade_gameover_fadeout ; Gameover
.byt <dummy_routine ; arcade run01
.byt <dummy_routine ; arcade btt01
.byt <dummy_routine ; arcade run02
.byt <dummy_routine ; arcade btt02
stage_routine_fadeout_msb:
.byt >stage_flatland_fadeout ; Flatland
.byt >stage_pit_fadeout ; Pit
.byt >stage_skyride_fadeout ; Skyride
.byt >stage_thehunt_fadeout ; The Hunt
.byt >stage_theplank_fadeout ; The Plank
.byt >stage_deeprock_fadeout ; Deep Rock
.byt >dummy_routine ; arcade boss
.byt >stage_arcade_fight_port_fadeout ; Port
.byt >stage_arcade_fight_town_fadeout ; Town
.byt >stage_arcade_fight_wall_fadeout ; Wall
.byt >stage_arcade_gameover_fadeout ; Gameover
.byt >dummy_routine ; arcade run01
.byt >dummy_routine ; arcade btt01
.byt >dummy_routine ; arcade run02
.byt >dummy_routine ; arcade btt02

stages_data:
RAW_VECTOR(stage_flatland_data) ; Flatland
RAW_VECTOR(stage_pit_data) ; Pit
RAW_VECTOR(stage_skyride_data) ; Skyride
RAW_VECTOR(stage_thehunt_data) ; The Hunt
RAW_VECTOR(stage_theplank_data) ; The Plank
RAW_VECTOR(stage_deeprock_data) ; Deep Rock

RAW_VECTOR(stage_arcade_boss_space_data) ; arcade boss
RAW_VECTOR(stage_arcade_fight_port_data) ; Port
RAW_VECTOR(stage_arcade_fight_town_data) ; Town
RAW_VECTOR(stage_arcade_fight_wall_data) ; Wall
RAW_VECTOR(stage_arcade_gameover_data) ; Gameover

RAW_VECTOR(stage_arcade_run01_data)
RAW_VECTOR(stage_arcade_btt01_data)
RAW_VECTOR(stage_arcade_run02_data)
RAW_VECTOR(stage_arcade_btt02_data)

stages_illustration:
RAW_VECTOR(stage_flatland_illustration) ; Flatland
RAW_VECTOR(stage_pit_illustration) ; Pit
RAW_VECTOR(stage_skyride_illustration) ; Skyride
RAW_VECTOR(stage_thehunt_illustration) ; The Hunt
RAW_VECTOR(stage_theplank_illustration) ; The Plank
RAW_VECTOR(stage_deeprock_illustration) ; Deep Rock

RAW_VECTOR($0000) ; arcade boss
RAW_VECTOR($0000) ; Port
RAW_VECTOR($0000) ; Town
RAW_VECTOR($0000) ; Wall
RAW_VECTOR($0000) ; Gameover

RAW_VECTOR($0000) ; dummy value, unused for arcade stages
RAW_VECTOR($0000) ; dummy value, unused for arcade stages
RAW_VECTOR($0000) ; dummy value, unused for arcade stages
RAW_VECTOR($0000) ; dummy value, unused for arcade stages

stages_netload_routine_lsb:
.byt <dummy_routine ; Flatland
.byt <stage_pit_netload ; Pit
.byt <dummy_routine ; Skyride
.byt <stage_thehunt_netload ; The Hunt
.byt <dummy_routine ; The Plank
.byt <dummy_routine ; Deep Rock

.byt <dummy_routine ; arcade boss
.byt <dummy_routine ; Port
.byt <dummy_routine ; Town
.byt <dummy_routine ; Wall
.byt <dummy_routine ; Gameover

.byt <dummy_routine
.byt <dummy_routine
.byt <dummy_routine
.byt <dummy_routine

stages_netload_routine_msb:
.byt >dummy_routine ; Flatland
.byt >stage_pit_netload ; Pit
.byt >dummy_routine ; Skyride
.byt >stage_thehunt_netload ; The Hunt
.byt >dummy_routine ; The Plank
.byt >dummy_routine ; Deep Rock

.byt >dummy_routine ; arcade boss
.byt >dummy_routine ; Port
.byt >dummy_routine ; Town
.byt >dummy_routine ; Wall
.byt >dummy_routine ; Gameover

.byt >dummy_routine
.byt >dummy_routine
.byt >dummy_routine
.byt >dummy_routine

stages_bank:
.byt STAGE_FLATLAND_BANK_NUMBER ; Flatland
.byt STAGE_PIT_BANK_NUMBER ; Pit
.byt STAGE_SKYRIDE_BANK_NUMBER ; Skyride
.byt STAGE_THEHUNT_BANK_NUMBER ; The Hunt
.byt STAGE_THEPLANK_BANK_NUMBER ; The Plank
.byt STAGE_DEEPROCK_BANK_NUMBER ; Deep Rock

.byt STAGE_ARCADE_BOSS_BANK_NUMBER ; arcade boss
.byt STAGE_ARCADE_FIGHT_PORT_BANK_NUMBER ; Port
.byt STAGE_ARCADE_FIGHT_TOWN_BANK_NUMBER ; Town
.byt STAGE_ARCADE_FIGHT_WALL_BANK_NUMBER ; Wall
.byt STAGE_ARCADE_GAMEOVER_BANK_NUMBER ; Gameover

.byt STAGE_ARCADE_RUN01_BANK_NUMBER
.byt STAGE_ARCADE_BTT01_BANK_NUMBER
.byt STAGE_ARCADE_RUN02_BANK_NUMBER
.byt STAGE_ARCADE_BTT02_BANK_NUMBER

stages_tileset_lsb:
.byt <tileset_ruins ; Flatland
.byt <tileset_jungle ; Pit
.byt <tileset_ruins ; Skyride
.byt <tileset_magma ; The Hunt
.byt <tileset_jungle ; The Plank
.byt <tileset_magma ; Deep Rock

.byt <tileset_magma ; arcade boss
.byt <tileset_ruins ; Port ;NOTE should support null pointer (overriden by custom init)
.byt <tileset_ruins ; Town (overriden by custom init)
.byt <tileset_ruins ; Wall (overriden by custom init)
.byt <arcade_gameover_bg_tileset ; Gameover

.byt <arcade_test_stage_tileset ; arcade run01
.byt <arcade_test_stage_tileset ; arcade btt01
.byt <arcade_test_stage_tileset ; arcade run02
.byt <arcade_test_stage_tileset ; arcade btt02

stages_tileset_msb:
.byt >tileset_ruins ; Flatland
.byt >tileset_jungle ; Pit
.byt >tileset_ruins ; Skyride
.byt >tileset_magma ; The Hunt
.byt >tileset_jungle ; The Plank
.byt >tileset_magma ; Deep Rock

.byt >tileset_magma ; arcade boss
.byt >tileset_ruins ; Port (overriden by custom init)
.byt >tileset_ruins ; Town (overriden by custom init)
.byt >tileset_ruins ; Wall
.byt >arcade_gameover_bg_tileset ; Gameover

.byt >arcade_test_stage_tileset ; arcade run01
.byt >arcade_test_stage_tileset ; arcade btt01
.byt >arcade_test_stage_tileset ; arcade run02
.byt >arcade_test_stage_tileset ; arcade btt02

stages_tileset_bank:
.byt TILESET_RUINS_BANK_NUMBER ; Flatland
.byt TILESET_JUNGLE_BANK_NUMBER ; Pit
.byt TILESET_RUINS_BANK_NUMBER ; Skyride
.byt TILESET_MAGMA_BANK_NUMBER ; The Hunt
.byt TILESET_JUNGLE_BANK_NUMBER ; The Plank
.byt TILESET_MAGMA_BANK_NUMBER ; Deep Rock

.byt TILESET_MAGMA_BANK_NUMBER ; arcade boss
.byt TILESET_RUINS_BANK_NUMBER ; Port
.byt TILESET_RUINS_BANK_NUMBER ; Town
.byt TILESET_RUINS_BANK_NUMBER ; Wall
.byt ARCADE_GAMEOVER_BG_TILESET_BANK_NUMBER  ; Gameover

.byt ARCADE_TEST_STAGE_TILESET_BANK_NUMBER ; arcade run01
.byt ARCADE_TEST_STAGE_TILESET_BANK_NUMBER ; arcade btt01
.byt ARCADE_TEST_STAGE_TILESET_BANK_NUMBER ; arcade run02
.byt ARCADE_TEST_STAGE_TILESET_BANK_NUMBER ; arcade btt02

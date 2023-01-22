CUTSCENE_SINBAD_STORY_SINBAD_ENCOUNTER_BG_TILESET_BANK_NUMBER = CURRENT_BANK_NUMBER

cutscene_sinbad_story_sinbad_encounter_bg_tileset:

; Tileset's size in tiles (zero means 256)
.byt (cutscene_sinbad_story_sinbad_encounter_bg_tileset_end-cutscene_sinbad_story_sinbad_encounter_bg_tileset_tiles)/16

cutscene_sinbad_story_sinbad_encounter_bg_tileset_tiles:
;TODO create a utility function that writes solid sprites with ppu_fill (more speed, and less rom than using tilesets)
.byt %00000000, %00000000, %00000000, %00000000, %00000000, %00000000, %00000000, %00000000
.byt %00000000, %00000000, %00000000, %00000000, %00000000, %00000000, %00000000, %00000000
.byt %11111111, %11111111, %11111111, %11111111, %11111111, %11111111, %11111111, %11111111
.byt %00000000, %00000000, %00000000, %00000000, %00000000, %00000000, %00000000, %00000000
.byt %00000000, %00000000, %00000000, %00000000, %00000000, %00000000, %00000000, %00000000
.byt %11111111, %11111111, %11111111, %11111111, %11111111, %11111111, %11111111, %11111111
.byt %11111111, %11111111, %11111111, %11111111, %11111111, %11111111, %11111111, %11111111
.byt %11111111, %11111111, %11111111, %11111111, %11111111, %11111111, %11111111, %11111111
cutscene_sinbad_story_sinbad_encounter_bg_tileset_end:

; Number of characters referenced in following tables
CHARACTERS_NUMBER = 2

; Bank in which each character is stored
characters_bank_number:
.byt SINBAD_BANK_NUMBER ; Sinbad
.byt SQUAREMAN_BANK_NUMBER ; Squareman

; Begining of tiles data for each character
characters_tiles_data_lsb:
.byt <sinbad_chr_tiles ; Sinbad
.byt <squareman_chr_tiles ; Squareman

characters_tiles_data_msb:
.byt >sinbad_chr_tiles ; Sinbad
.byt >squareman_chr_tiles ; Squareman

; Number of CHR tiles per character
characters_tiles_number:
.byt SINBAD_SPRITE_TILES_NUMBER ; Sinbad
.byt SQUAREMAN_SPRITE_TILES_NUMBER ; Squareman

; Standard animations
characters_std_animations_lsb:
.byt <sinbad_std_anim ; Sinbad
.byt <squareman_std_anim ; Squareman

characters_std_animations_msb:
.byt >sinbad_std_anim ; Sinbad
.byt >squareman_std_anim ; Squareman

; Colorswap information
characters_palettes_lsb:
.byt <character_palettes ; Sinbad
.byt <squareman_palettes ; Squareman

characters_palettes_msb:
.byt >character_palettes ; Sinbad
.byt >squareman_palettes ; Squareman

characters_alternate_palettes_lsb:
.byt <character_palettes_alternate ; Sinbad
.byt <squareman_palettes_alternate ; Squareman

characters_alternate_palettes_msb:
.byt >character_palettes_alternate ; Sinbad
.byt >squareman_palettes_alternate ; Squareman

characters_weapon_palettes_lsb:
.byt <weapon_palettes ; Sinbad
.byt <squareman_weapon_palettes ; Squareman

characters_weapon_palettes_msb:
.byt >weapon_palettes ; Sinbad
.byt >squareman_weapon_palettes ; Squareman

; Begining of character's jump tables
characters_start_routines_table_lsb:
.byt <sinbad_state_start_routines ; Sinbad
.byt <squareman_state_start_routines ; Squareman

characters_start_routines_table_msb:
.byt >sinbad_state_start_routines ; Sinbad
.byt >squareman_state_start_routines ; Squareman

characters_update_routines_table_lsb:
.byt <sinbad_state_update_routines ; Sinbad
.byt <squareman_state_update_routines ; Squareman

characters_update_routines_table_msb:
.byt >sinbad_state_update_routines ; Sinbad
.byt >squareman_state_update_routines ; Squareman

characters_offground_routines_table_lsb:
.byt <sinbad_state_offground_routines ; Sinbad
.byt <squareman_state_offground_routines ; Squareman

characters_offground_routines_table_msb:
.byt >sinbad_state_offground_routines ; Sinbad
.byt >squareman_state_offground_routines ; Squareman

characters_onground_routines_table_lsb:
.byt <sinbad_state_onground_routines ; Sinbad
.byt <squareman_state_onground_routines ; Squareman

characters_onground_routines_table_msb:
.byt >sinbad_state_onground_routines ; Sinbad
.byt >squareman_state_onground_routines ; Squareman

characters_input_routines_table_lsb:
.byt <sinbad_state_input_routines ; Sinbad
.byt <squareman_state_input_routines ; Squareman

characters_input_routines_table_msb:
.byt >sinbad_state_input_routines ; Sinbad
.byt >squareman_state_input_routines ; Squareman

characters_onhurt_routines_table_lsb:
.byt <sinbad_state_onhurt_routines ; Sinbad
.byt <squareman_state_onhurt_routines ; Squareman

characters_onhurt_routines_table_msb:
.byt >sinbad_state_onhurt_routines ; Sinbad
.byt >squareman_state_onhurt_routines ; Squareman

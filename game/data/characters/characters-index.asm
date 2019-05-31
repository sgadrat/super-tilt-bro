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

; Begining of character's jump tables
;TODO rename to characters_start_routine_table_*sb
characters_routines_table_lsb:
.byt <sinbad_state_start_routines ; Sinbad
.byt <squareman_state_start_routines ; Squareman

characters_routines_table_msb:
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

; Number of entries in character's jump tables
;TODO check if better to store just that or a vector per table
;characters_routines_table_length:
;.byt SINBAD_NUM_STATES ; Sinbad
;.byt SQUAREMAN_NUM_STATES ; Squareman

; Number of CHR tiles per character
characters_tiles_number:
.byt SINBAD_SPRITE_TILES_NUMBER ; Sinbad
.byt SQUAREMAN_SPRITE_TILES_NUMBER ; Squareman

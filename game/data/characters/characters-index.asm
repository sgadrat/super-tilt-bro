; Number of characters referenced in following tables
CHARACTERS_NUMBER = 1

; Bank in which each character is stored
characters_bank_number:
.byt SINBAD_BANK_NUMBER ; Sinbad

; Begining of tiles data for each character
characters_tiles_data_lsb:
.byt <sinbad_chr_tiles ; Sinbad

characters_tiles_data_msb:
.byt >sinbad_chr_tiles ; Sinbad

characters_tiles_number:
.byt 94 ; Sinbad

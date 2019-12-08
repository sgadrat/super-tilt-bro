.asc "NES", $1A ; iNES magic
.byt 32         ; PRG section occupies 32*16KiB memory
.byt 0          ; CHR-ROM section occupies 0*8KiB memory (we use CHR-RAM)
.byt %11100010  ; Flags 6 NNNN FTBM - mapper 3870, no four screen, no trainer, persistent memory, horizontal mirroring
.byt %00011000  ; Flags 7 NNNN 10TT - mapper 3870, NES 2.0, NES/Famicom
.byt %00001111  ; Flags 8 SSSS NNNN - submapper 0, mapper 3870
.byt %00000000  ; Flags 9 CCCC PPPP - CHR-ROM size MSB = 0, PRG-ROM size MSB = 0
.byt 0          ; Flags 10
.byt %00000111 ; Flags 11 cccc CCCC - CHR-NVRAM, CHR-RAM
.byt %00000001  ; Flags 12 .... ..VV - PAL timing
.byt 0          ; Flags 13
.byt 0          ; Flags 14
.byt 0          ; Flags 15

.asc "NES", $1A ; iNES magic
.byt MAPPER_PRG_SIZE/16 ; PRG section occupies 32*16KiB memory
.byt 0          ; CHR-ROM section occupies 0*8KiB memory (we use CHR-RAM)
.byt ((MAPPER_NUMBER & $00f) << 4) + (MAPPER_BATTERY_FLAG << 1) ; Flags 6 NNNN FTBM - mapper low nibble, no four screen, no trainer, persistent memory, horizontal mirroring
.byt (MAPPER_NUMBER & $0f0) + %00001000 ; Flags 7 NNNN 10TT - mapper mid nibble, NES 2.0, NES/Famicom
.byt (SUBMAPPER_NUMBER << 4) + ((MAPPER_NUMBER & $f00) >> 8) ; Flags 8 SSSS NNNN - submapper, mapper high nibble
.byt %00000000  ; Flags 9 CCCC PPPP - CHR-ROM size MSB = 0, PRG-ROM size MSB = 0
#ifndef MAPPER_RAINBOW
.byt 0          ; Flags 10 pppp PPPP - PRG-RAM non-volatile = 0, volatile = 0
#else
;TODO Maybe we don't want to depend on it (for sure it is not needed, but it is convenient)
.byt %00001001  ; Flags 10 pppp PPPP - PRG-RAM non-volatile = 0, volatile = 64 << 9 = 32 KB
#endif
.byt (%0000 << 4) + (MAPPER_CHR_SHIFTS & $0f) ; Flags 11 cccc CCCC - CHR-NVRAM, CHR-RAM
.byt %00000001  ; Flags 12 .... ..VV - PAL timing
.byt 0          ; Flags 13
.byt 0          ; Flags 14
.byt 0          ; Flags 15

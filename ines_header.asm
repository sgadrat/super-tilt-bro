.asc "NES", $1A         ;iNES magic
.byt 1                  ;PRG section occupies 1*16KiB memory
.byt 1                  ;CHR section occupies 1* 8KiB memory
.byt %00000000          ;ROM options - horizontal mirroring
.byt 0                  ;mapper #0 (no mapper)
.dsb 8,0                ;trailing zeros

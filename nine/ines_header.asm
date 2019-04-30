.asc "NES", $1A ; iNES magic
.byt 32         ; PRG section occupies 32*16KiB memory
.byt 0          ; CHR-ROM section occupies 0*8KiB memory (we use CHR-RAM)
.byt %11100010  ; Flags 6 - mapper 30, Horizontal mirroring, no trainer, persistent memory
.byt %00010000  ; Flags 7 - mapper 30, not NES 2.0, not PlayChoice10, not VS unisystem
.byt 0          ; Size of PRG-RAM
.byt %00000001  ; Flags 9 - PAL
.byt 0          ;
.byt 0          ;
.byt 0          ; Unused in iNES
.byt 0          ;
.byt 0          ;
.byt 0          ;

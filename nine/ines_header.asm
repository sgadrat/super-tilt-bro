.asc "NES", $1A ; iNES magic
.byt 2          ; PRG section occupies 2*16KiB memory
.byt 1          ; CHR section occupies 1* 8KiB memory
.byt %00000000  ; Flags 6 - mapper 0, horizontal mirroring, no trainer, no persistent memory
.byt 0          ; Flags 7 - mapper 0, not NES 2.0, not PlayChoice10, not VS unisystem
.byt 0          ; Size of PRG-RAM
.byt %00000001  ; Flags 9 - PAL
.byt 0          ;
.byt 0          ;
.byt 0          ; Unused in iNES
.byt 0          ;
.byt 0          ;
.byt 0          ;

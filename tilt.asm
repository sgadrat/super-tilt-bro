; Building the project
;  xa tilt.asm -C -o tilt\(E\).nes
;
; Building raw ROMs
;  xa tilt.asm -DNO_INES_HEADER -DNO_CHR_ROM -C -o tilt_prg.bin
;  xa tilt.asm -DNO_INES_HEADER -DNO_PRG_ROM -C -o tilt_chr.bin

#ifndef NO_INES_HEADER
#include "ines_header.asm"
#endif

#ifndef NO_PRG_ROM
#include "constants.asm"
#include "macros.asm"
#include "nes_labels.asm"
#include "mem_labels.asm"
#include "prg_rom/prg_rom.asm"
#endif

#ifndef NO_CHR_ROM
#include "chr_rom.asm"
#endif

; Building the project
;  xa tilt.asm -C -o tilt\(E\).nes
;
; Building raw ROMs
;  xa tilt.asm -DNO_INES_HEADER -DNO_CHR_ROM -C -o tilt_prg.bin
;  xa tilt.asm -DNO_INES_HEADER -DNO_PRG_ROM -C -o tilt_chr.bin

; iNES header

#ifndef NO_INES_HEADER
#include "nine/ines_header.asm"
#endif

; No-data declarations

#include "game/constants.asm"
#include "nine/macros.asm"
#include "game/macros.asm"
#include "nine/nes_labels.asm"
#include "game/mem_labels.asm"

; PRG-ROM

#ifndef NO_PRG_ROM
* = $8000 ; $8000 is where the PRG rom is mapped in CPU space, so code position is relative to it
code_begin:
#include "game/logic/animation_opcodes.asm"
#include "nine/prg_rom/prg_rom.asm"
#include "game/logic/logic.asm"
code_end:
#include "game/data/data.asm"
#include "game/prg_rom_filler.asm"
#endif

; CHR-ROM
#ifndef NO_CHR_ROM
#include "game/chr_rom.asm"
#endif

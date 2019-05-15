; Building the project
;  xa tilt.asm -C -o tilt\(E\).nes
;
; Building raw ROMs
;  xa tilt.asm -DNO_INES_HEADER -C -o tilt_prg.bin

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

#include "game/extra_banks.asm"

#echo
#echo ===== FIXED-BANK =====
* = $c000 ; $c000 is where the PRG fixed bank rom is mapped in CPU space, so code position is relative to it
code_begin:
#include "game/logic/animation_opcodes.asm"
#include "nine/prg_rom/prg_rom.asm"
#include "game/logic/logic.asm"
code_end:
#include "game/data/fixed-bank-data.asm"
#include "game/fixed_bank_filler.asm"
#endif

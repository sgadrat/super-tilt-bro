;
; "Static bank" contents
;
; This "bank" is the last 4KB of the PRG ROM (last quarter of the 16K fixed bank.)
; It is called static, as flashing it is inherently unsafe. A power shutdown after the
; erase would leave the three interrupt vectors to $FFFF.
;
; Ideally, the content of this bank should never change. It contains a self-flashing
; rescue routine, so any damage to other sectors can be recovered (without the
; need of an INL retrodumper.)
;

#if * <> $f000
#error static bank mis-aligned
#endif

#echo
#echo ===== FIXED-BANK (static) =====

;
; Files that have to be in the static bank
;

#include "game/logic/mapper_init.asm"

;
; Dependencies of files that have to be in the static bank
;

#include "game/logic/rainbow_lib.asm"
#include "nine/static_bank.asm"

;
; Generic utilities to fill unused space
;

#include "game/logic/utils_static.asm"
#include "game/data/music/notes_table.asm"
#include "game/data/rom_constants_static.asm"
#include "game/data/pal_to_ntsc_velocity.asm"
#include "game/data/random_table.asm"

;
; Filler
;

#ifdef SERVER_BYTECODE
#include "game/logic/server_bytecode_extras.asm"
#endif
#include "game/fixed_bank_filler.asm"
#endif

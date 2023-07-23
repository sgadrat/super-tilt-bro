; No-data declarations

* = 0

#include "game/rainbow_lib_declarations.asm"
#include "nine/nes_labels.asm"
#include "game/c_labels.asm"

#if * <> 0
#error "data in no-data declarations"
#endif

; Constants that must match their counterpart when building the ROM

FIXED_BANK_NUMBER = 4+$1f

; Bottom sector

#define CURRENT_BANK_NUMBER $00
#include "game/banks/rainbow00_bank.asm"
#define CURRENT_BANK_NUMBER $01
#include "game/banks/rainbow01_bank.asm"
#define CURRENT_BANK_NUMBER $02
#include "game/banks/rainbow02_bank.asm"
#define CURRENT_BANK_NUMBER $03
#include "game/banks/rainbow03_bank.asm"

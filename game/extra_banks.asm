;
; Contents of the 31 swappable banks
;
; The fixed bank is handled separately
;


#define CHR_BANK_NUMBER $00
#define CURRENT_BANK_NUMBER CHR_BANK_NUMBER
#include "game/banks/chr_data.asm"

#define CURRENT_BANK_NUMBER $01
#include "game/banks/data01_bank.asm"

#define DATA_BANK_NUMBER $02
#define CURRENT_BANK_NUMBER DATA_BANK_NUMBER
#include "game/banks/data_bank.asm"

#define CURRENT_BANK_NUMBER $03
#include "game/banks/empty_bank.asm"
#define CURRENT_BANK_NUMBER $04
#include "game/banks/empty_bank.asm"
#define CURRENT_BANK_NUMBER $05
#include "game/banks/empty_bank.asm"
#define CURRENT_BANK_NUMBER $06
#include "game/banks/empty_bank.asm"
#define CURRENT_BANK_NUMBER $07
#include "game/banks/empty_bank.asm"
#define CURRENT_BANK_NUMBER $08
#include "game/banks/empty_bank.asm"
#define CURRENT_BANK_NUMBER $09
#include "game/banks/empty_bank.asm"
#define CURRENT_BANK_NUMBER $0a
#include "game/banks/empty_bank.asm"
#define CURRENT_BANK_NUMBER $0b
#include "game/banks/empty_bank.asm"
#define CURRENT_BANK_NUMBER $0c
#include "game/banks/empty_bank.asm"
#define CURRENT_BANK_NUMBER $0d
#include "game/banks/empty_bank.asm"
#define CURRENT_BANK_NUMBER $0e
#include "game/banks/empty_bank.asm"
#define CURRENT_BANK_NUMBER $0f
#include "game/banks/empty_bank.asm"
#define CURRENT_BANK_NUMBER $11
#include "game/banks/empty_bank.asm"
#define CURRENT_BANK_NUMBER $12
#include "game/banks/empty_bank.asm"
#define CURRENT_BANK_NUMBER $13
#include "game/banks/empty_bank.asm"
#define CURRENT_BANK_NUMBER $14
#include "game/banks/empty_bank.asm"
#define CURRENT_BANK_NUMBER $15
#include "game/banks/empty_bank.asm"
#define CURRENT_BANK_NUMBER $16
#include "game/banks/empty_bank.asm"
#define CURRENT_BANK_NUMBER $17
#include "game/banks/empty_bank.asm"
#define CURRENT_BANK_NUMBER $18
#include "game/banks/empty_bank.asm"
#define CURRENT_BANK_NUMBER $19
#include "game/banks/empty_bank.asm"
#define CURRENT_BANK_NUMBER $1a
#include "game/banks/empty_bank.asm"
#define CURRENT_BANK_NUMBER $1b
#include "game/banks/empty_bank.asm"
#define CURRENT_BANK_NUMBER $1c
#include "game/banks/empty_bank.asm"
#define CURRENT_BANK_NUMBER $1d
#include "game/banks/empty_bank.asm"
#define CURRENT_BANK_NUMBER $1e
#include "game/banks/empty_bank.asm"
#define CURRENT_BANK_NUMBER $1f
#include "game/banks/empty_bank.asm"

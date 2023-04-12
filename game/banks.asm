;
; Contents of the 32 PRG banks
;
; Special care for the fixed bank which depends on mapper type.
; Allocation of game-mod data to bank is done at compile time.
;

#ifdef MAPPER_RAINBOW
; First 64K of Rainbow can be a 64K sector, multiple smaller sectors.
; Also it contains the init vectors.
;
; To avoid the mess of flashing different-sized models, use it to store
; rainbow-specific boot code and rescue code
#define CURRENT_BANK_NUMBER $00
#include "game/banks/rainbow00_bank.asm"
#define CURRENT_BANK_NUMBER $01
#include "game/banks/rainbow01_bank.asm"
#define CURRENT_BANK_NUMBER $02
#include "game/banks/rainbow02_bank.asm"
#define CURRENT_BANK_NUMBER $03
#include "game/banks/rainbow03_bank.asm"
#define FIRST_GAME_BANK $04
#else
#define FIRST_GAME_BANK $00
#endif

#define CHR_BANK_NUMBER FIRST_GAME_BANK+$00
#define CURRENT_BANK_NUMBER CHR_BANK_NUMBER
#include "game/banks/chr_data.asm"

#define CURRENT_BANK_NUMBER FIRST_GAME_BANK+$01
#include "game/banks/data01_bank.asm"

#define CURRENT_BANK_NUMBER FIRST_GAME_BANK+$02
#include "game/banks/data02_bank.asm"

#define CURRENT_BANK_NUMBER FIRST_GAME_BANK+$03
#include "game/banks/data03_bank.asm"

#define CURRENT_BANK_NUMBER FIRST_GAME_BANK+$04
#include "game/banks/data04_bank.asm"

#define CURRENT_BANK_NUMBER FIRST_GAME_BANK+$05
#include "game/banks/data05_bank.asm"

#define CURRENT_BANK_NUMBER FIRST_GAME_BANK+$06
#include "game/banks/data06_bank.asm"

#define CURRENT_BANK_NUMBER FIRST_GAME_BANK+$07
#include "game/banks/data07_bank.asm"

#define CURRENT_BANK_NUMBER FIRST_GAME_BANK+$08
#include "game/banks/data08_bank.asm"

#define CURRENT_BANK_NUMBER FIRST_GAME_BANK+$09
#include "game/banks/data09_bank.asm"

#define CURRENT_BANK_NUMBER FIRST_GAME_BANK+$0a
#include "game/banks/data10_bank.asm"

#define CURRENT_BANK_NUMBER FIRST_GAME_BANK+$0b
#include "game/banks/data11_bank.asm"

#define CURRENT_BANK_NUMBER FIRST_GAME_BANK+$0c
#include "game/banks/data12_bank.asm"

#define CURRENT_BANK_NUMBER FIRST_GAME_BANK+$0d
#include "game/banks/data13_bank.asm"

#define CURRENT_BANK_NUMBER FIRST_GAME_BANK+$0e
#include "game/banks/data14_bank.asm"

#define CURRENT_BANK_NUMBER FIRST_GAME_BANK+$0f
#include "game/banks/data15_bank.asm"

#define CURRENT_BANK_NUMBER FIRST_GAME_BANK+$10
#include "game/banks/data16_bank.asm"

;; mod banks (this line will be replaced by mod compilation tool)

#define CURRENT_BANK_NUMBER FIRST_GAME_BANK+$1f
#include "game/fixed_bank_updatable.asm"
#include "game/static_bank.asm"

; Rainbow mapper needs 1024 bytes ROMS, fill it with empty banks
#ifdef MAPPER_RAINBOW
#define CURRENT_BANK_NUMBER FIRST_GAME_BANK+$20
#include "game/banks/empty_bank.asm"
#define CURRENT_BANK_NUMBER FIRST_GAME_BANK+$21
#include "game/banks/empty_bank.asm"
#define CURRENT_BANK_NUMBER FIRST_GAME_BANK+$22
#include "game/banks/empty_bank.asm"
#define CURRENT_BANK_NUMBER FIRST_GAME_BANK+$23
#include "game/banks/empty_bank.asm"
#define CURRENT_BANK_NUMBER FIRST_GAME_BANK+$24
#include "game/banks/empty_bank.asm"
#define CURRENT_BANK_NUMBER FIRST_GAME_BANK+$25
#include "game/banks/empty_bank.asm"
#define CURRENT_BANK_NUMBER FIRST_GAME_BANK+$26
#include "game/banks/empty_bank.asm"
#define CURRENT_BANK_NUMBER FIRST_GAME_BANK+$27
#include "game/banks/empty_bank.asm"
#define CURRENT_BANK_NUMBER FIRST_GAME_BANK+$28
#include "game/banks/empty_bank.asm"
#define CURRENT_BANK_NUMBER FIRST_GAME_BANK+$29
#include "game/banks/empty_bank.asm"
#define CURRENT_BANK_NUMBER FIRST_GAME_BANK+$2a
#include "game/banks/empty_bank.asm"
#define CURRENT_BANK_NUMBER FIRST_GAME_BANK+$2b
#include "game/banks/empty_bank.asm"
#define CURRENT_BANK_NUMBER FIRST_GAME_BANK+$2c
#include "game/banks/empty_bank.asm"
#define CURRENT_BANK_NUMBER FIRST_GAME_BANK+$2d
#include "game/banks/empty_bank.asm"
#define CURRENT_BANK_NUMBER FIRST_GAME_BANK+$2e
#include "game/banks/empty_bank.asm"
#define CURRENT_BANK_NUMBER FIRST_GAME_BANK+$2f
#include "game/banks/empty_bank.asm"
#define CURRENT_BANK_NUMBER FIRST_GAME_BANK+$30
#include "game/banks/empty_bank.asm"
#define CURRENT_BANK_NUMBER FIRST_GAME_BANK+$31
#include "game/banks/empty_bank.asm"
#define CURRENT_BANK_NUMBER FIRST_GAME_BANK+$32
#include "game/banks/empty_bank.asm"
#define CURRENT_BANK_NUMBER FIRST_GAME_BANK+$33
#include "game/banks/empty_bank.asm"
#define CURRENT_BANK_NUMBER FIRST_GAME_BANK+$34
#include "game/banks/empty_bank.asm"
#define CURRENT_BANK_NUMBER FIRST_GAME_BANK+$35
#include "game/banks/empty_bank.asm"
#define CURRENT_BANK_NUMBER FIRST_GAME_BANK+$36
#include "game/banks/empty_bank.asm"
#define CURRENT_BANK_NUMBER FIRST_GAME_BANK+$37
#include "game/banks/empty_bank.asm"

; NOTE These banks can be a single 64K sector or multiple smaller ones.
;      Better save it for data that will never change.
#define CURRENT_BANK_NUMBER FIRST_GAME_BANK+$38
#include "game/banks/empty_bank.asm"
#define CURRENT_BANK_NUMBER FIRST_GAME_BANK+$39
#include "game/banks/empty_bank.asm"
#define CURRENT_BANK_NUMBER FIRST_GAME_BANK+$3a
#include "game/banks/empty_bank.asm"
#define CURRENT_BANK_NUMBER FIRST_GAME_BANK+$3b
#include "game/banks/empty_bank.asm"
#endif

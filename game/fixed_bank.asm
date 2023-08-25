;
; Fixed bank. This one is permanently mapped at $c000-$ffff CPU space.
;

#echo
#echo ===== FIXED-BANK =====

* = $c000 ; $c000 is where the PRG fixed bank rom is mapped in CPU space, so code position is relative to it

FIXED_BANK_NUMBER = CURRENT_BANK_NUMBER

; Note - data before code, some address changes in data may require server update (notably anim_invisible)
fixed_bank_data_begin:
#include "game/data/fixed-bank-data.asm"
#echo
#echo FIXED-bank data size:
#print *-fixed_bank_data_begin

fixed_bank_code_begin:

fixed_bank_main_begin:
#include "nine/main.asm"
#echo
#echo FIXED-bank main loop and interrupts size:
#print *-fixed_bank_main_begin

fixed_bank_code_begin_stnp_lib:
#include "game/logic/stnp_lib.asm"
#echo
#echo FIXED-bank code size (stnp_lib)
#print *-fixed_bank_code_begin_stnp_lib

fixed_bank_code_begin_animation_extra:
#include "game/logic/animation_extra.asm"
#echo
#echo FIXED-bank code size (animation_extra)
#print *-fixed_bank_code_begin_animation_extra

fixed_bank_code_begin_logic:
#include "game/logic/logic.asm"
#echo
#echo FIXED-bank code size (logic)
#print *-fixed_bank_code_begin_logic

fixed_bank_code_begin_utils:
#include "game/logic/utils.asm"
#echo
#echo FIXED-bank code size (utils)
#print *-fixed_bank_code_begin_utils

fixed_bank_code_begin_fixed_bank:
#include "nine/fixed_bank.asm"
#echo
#echo FIXED-bank code size (fixed_bank)
#print *-fixed_bank_code_begin_fixed_bank

.(
bank_data_begin:
#include "game/logic/mapper_init.asm"
#echo
#echo Mapper initialization size:
#print *-bank_data_begin
.)

.(
bank_data_begin:
#include "game/logic/rainbow_lib.asm"
#echo
#echo Rainbow lib:
#print *-bank_data_begin
.)

.(
bank_data_begin:
#include "game/data/music/notes_table.asm"
#echo
#echo Notes table:
#print *-bank_data_begin
.)

.(
bank_data_begin:
#include "game/data/pal_to_ntsc_velocity.asm"
#echo
#echo PAL to NTSC velocity:
#print *-bank_data_begin
.)

.(
bank_data_begin:
#include "game/data/random_table.asm"
#echo
#echo Random table:
#print *-bank_data_begin
.)

;
; Filler
;

#ifdef SERVER_BYTECODE
#include "game/logic/server_bytecode_extras.asm"
#endif
#include "game/fixed_bank_filler.asm"

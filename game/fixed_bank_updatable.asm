;
; First quarters of the fixed bank.
;
; No caveat there, unlike in the last quarter. See "static_bank.asm".
;

#echo
#echo ===== FIXED-BANK (updatable) =====

* = $c000 ; $c000 is where the PRG fixed bank rom is mapped in CPU space, so code position is relative to it

; Note - interruption handlers and main loop first, their location being constant is critical (impacts static bank)
fixed_bank_main_begin:
#include "nine/main.asm"
fixed_bank_main_end:

; Note - data before code, some address changes in data may require server update (notably anim_invisible)
fixed_bank_data_begin:
#include "game/data/fixed-bank-data.asm"
fixed_bank_data_end:

fixed_bank_code_begin:
#include "game/logic/animation_opcodes.asm"
#include "game/logic/logic.asm"
#include "game/logic/utils.asm"
#include "nine/fixed_bank.asm"
fixed_bank_code_end:

credits_begin:
.asc "           credits",$0a
.asc $0a
.asc "           authors",$0a
.asc $0a
.asc "sylvain gadrat",$0a
.asc $0a
.asc "         art-sources",$0a
.asc $0a
.asc "backgrounds   by m le borgne",$0a
.asc "kiki            by tyson tan",$0a
.asc "sinbad              by zi ye",$0a
.asc "i like jump rope    by ozzed",$0a
.asc "perihelium          by ozzed",$0a
.asc "super tilt bro        by tui",$0a
.asc $0a
.asc "           thanks",$0a
.asc $0a
.asc "antoine gohin   bacteriamage",$0a
.asc "benoit ryder       bjorn nah",$0a
.asc "dennis van den broek     fei",$0a
.asc "keenan hecht",$0a
.asc "margarita gadrat",$0a
.asc "supergameland            tui",$0a
.asc $0a
.asc $0a
.asc $0a
.asc $0a
.asc $0a
.asc $0a
.byt $00
credits_end:

#echo
#echo FIXED-bank (updatable) total space:
#print $f000-$c000
#echo
#echo FIXED-bank (updatable) data size:
#print fixed_bank_data_end-fixed_bank_data_begin
#echo
#echo FIXED-bank (updatable) main loop and interrupts size:
#print fixed_bank_main_end-fixed_bank_main_begin
#echo
#echo FIXED-bank (updatable) code size:
#print fixed_bank_code_end-fixed_bank_code_begin
#echo
#echo FIXED-bank (updatable) credits size:
#print credits_end-credits_begin
#echo
#echo FIXED-BANK (updatable) free space:
#print $f000-*

;
; Credits in the rom
;

#if $f000-* < 0
#error updatable fixed bank occupies too much space
#endif
.dsb $f000-*, 0

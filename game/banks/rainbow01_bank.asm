.(
#echo
#echo ====== RAINBOW-01-BANK =====
* = $c000

.byt CURRENT_BANK_NUMBER

bank_rainbow01_begin:

.(
bank_data_begin:
#include "game/logic/rainbow_boot/startup.asm"
#echo
#echo Startup code:
#print *-bank_data_begin
.)

.(
bank_data_begin:
#include "game/logic/rainbow_boot/rescue.built.asm"
#echo
#echo Rescue code:
#print *-bank_data_begin
.)

bank_rainbow01_end:

;
; Print some bank's space usage information
;

#echo
#echo RAINBOW-01-bank used size:
#print bank_rainbow01_end-bank_rainbow01_begin
#echo
#echo RAINBOW-01-bank free space:
#echo FIXED-bank (static) free space:
#print $fffa-*

#if $fffa-* < 0
#error rainbow01 bank is full
#endif

;
; Fill bank's empty space
;

.dsb $fffa-*, $ff

;
; Set entry points vectors
;

.word rainbow_nmi   ; NMI
.word rainbow_reset ; RESET
.word rainbow_irq   ; IRQ

.)

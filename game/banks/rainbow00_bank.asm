.(
#echo
#echo ====== RAINBOW-00-BANK =====
* = $8000

.byt CURRENT_BANK_NUMBER

bank_rainbow00_begin:

.(
bank_data_begin:
#include "rainbow-boot/memory_map.asm"
#echo
#echo no-data boot code declarations:
#print *-bank_data_begin

#if *-bank_data_begin <> 0
#error "data in no-data declarations"
#endif
.)

.(
bank_data_begin:
#include "rainbow-boot/charset.asm"
#echo
#echo charset:
#print *-bank_data_begin
.)

.(
bank_data_begin:
#include "rainbow-boot/tileset_segments.asm"
#echo
#echo tileset segments:
#print *-bank_data_begin
.)

bank_rainbow00_end:

;
; Print some bank's space usage information
;

#echo
#echo RAINBOW-00-bank used size:
#print bank_rainbow00_end-bank_rainbow00_begin
#echo
#echo RAINBOW-00-bank free space:
#print $c000-*

;
; Fill bank's empty space
;

#if $c000-* < 0
#error Rainbow bank occupies too much space
#else
.dsb $c000-*, $ff
#endif
.)

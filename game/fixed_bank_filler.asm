
;
; Print some interesting addresses for debug
;

#echo
#echo wait_frame_loop:
#print wait_next_frame+4
#echo nmi_begin:
#print nmi
#echo vblank_end:
#print reset-11
#echo game_tick:
#print game_tick
#echo update_players:
#print update_players
#echo update_sprites
#print update_sprites

;
; Print some PRG-ROM space usage information
;

#echo
#echo FIXED-bank total space:
#print $10000-$c000
#echo
#echo FIXED-bank free space:
#print $fff8-*

#if $fff8-* < 0
#error FIXED-bank is full
#endif

;
; Fill bank's empty space
;

.dsb $fff8-*, $ff

;
; Set entry points vectors
;

#ifdef SERVER_BYTECODE
.word server_bytecode_init  ; Rainbow-safe RESET
.word server_bytecode_tick  ; NMI
.word server_bytecode_init  ; RESET
.word server_bytecode_error ; IRQ
#else
.word mapper_init   ; Rainbow-safe RESET
.word nmi           ; NMI
.word mapper_init   ; RESET
.word cursed        ; IRQ
#endif

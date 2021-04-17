
;
; Print some interesting addresses for debug
;

#echo
#echo wait_frame_loop:
#print wait_next_real_frame+4
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
#echo game_tick_end:
#print slowdown-1

;
; Print some PRG-ROM space usage information
;

#echo
#echo FIXED-bank (static) total space:
#print $10000-$f000
#echo
#echo FIXED-bank (static) free space:
#print $fffa-*

#if $fffa-* < 0
#error static bank is full
#endif

;
; Fill bank's empty space
;

.dsb $fffa-*, 0

;
; Set entry points vectors
;

#ifdef SERVER_BYTECODE
.word server_bytecode_tick  ; NMI
.word server_bytecode_init  ; RESET
.word server_bytecode_error ; IRQ
#else
.word nmi           ; NMI
.word mapper_init   ; RESET
.word cursed        ; IRQ
#endif

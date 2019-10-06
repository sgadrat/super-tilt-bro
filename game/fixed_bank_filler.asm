;
; Credits in the rom
;

credits_begin:
.asc "           credits",$0a
.asc $0a
.asc "           authors",$0a
.asc $0a
.asc "sylvain gadrat",$0a
.asc $0a
.asc "         art-sources",$0a
.asc $0a
.asc "backgrounds",$0a
.asc "    by martin le borgne",$0a
.asc "kiki",$0a
.asc "    by tyson tan",$0a
.asc "twin dragons",$0a
.asc "    by surt",$0a
.asc "sinbad",$0a
.asc "    by zi ye",$0a
.asc "i like jump rope",$0a
.asc "perihelium",$0a
.asc "termosdynamik",$0a
.asc "    by ozzed",$0a
.asc $0a
.asc "           thanks",$0a
.asc $0a
.asc "antoine gohin   bacteriamage",$0a
.asc "benoit ryder       bjorn nah",$0a
.asc "fei         margarita gadrat",$0a
.asc "supergameland",$0a
.byt $00
credits_end:

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
#echo FIXED-bank total space:
#print $10000-$c000
#echo
#echo FIXED-bank code size:
#print code_end-$c000
#echo
#echo FIXED-bank credits size:
#print credits_end-credits_begin
#echo
#echo FIXED-bank free space:
#print $fffa-*

;
; Fill code bank and set entry points vectors (also from nesmine)
;

#if $fffa-* < 0
#echo *** Error: Code occupies too much space
#else
.dsb $fffa-*, 0     ;aligning
.word nmi           ;entry point for VBlank interrupt  (NMI)
.word reset         ;entry point for program start     (RESET)
.word cursed        ;entry point for masking interrupt (IRQ)
#endif

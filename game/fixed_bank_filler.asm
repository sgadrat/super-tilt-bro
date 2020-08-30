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

ANIM_INVISIBLE_SIZE = 8
ANIM_INVISIBLE_ADDR = $fffa-ANIM_INVISIBLE_SIZE

#echo
#echo FIXED-bank total space:
#print $10000-$c000
#echo
#echo FIXED-bank audio engine size:
#print ninegine_audio_engine_end-ninegine_audio_engine_begin
#echo
#echo FIXED-bank code size:
#print code_end-$c000
#echo
#echo FIXED-bank credits size:
#print credits_end-credits_begin
#echo
#echo FIXED-bank free space:
#print ANIM_INVISIBLE_ADDR-*

;
; Fill bank's empty space
;

#if ANIM_INVISIBLE_ADDR-* < 0
#error Fixed bank overflow
#endif
.dsb ANIM_INVISIBLE_ADDR-*, 0

;
; Place anim invisible (see comment in characters-common-animations.asm)
;

#include "game/data/characters/characters-common-animations/invisible.asm"

;
; Set entry points vectors (also from nesmine)
;

.word nmi           ;entry point for VBlank interrupt  (NMI)
.word mapper_init   ;entry point for program start     (RESET)
.word cursed        ;entry point for masking interrupt (IRQ)

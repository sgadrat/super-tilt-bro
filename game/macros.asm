;
; Character data
;

#define STATE_ROUTINE(x) .word x

;
; Character AI
;

#define AI_ATTACK_HITBOX(cond,left,right,top,bottom) .byt cond,left, right, top, bottom

#define AI_STEP_FINAL $ff
#define AI_ACTION_STEP(buttons,time) .byt buttons, time
#define AI_ACTION_END_STEPS .byt AI_STEP_FINAL

;
; Utility macros
;

; Compute color parameter for "cpu_to_ppu_copy_charset"
#define CHARSET_COLOR(fg,bg) (fg<<2)+bg

; Convenience macro for utility routine "far_lda_tmpfield1_y"
#define FAR_LDA_TMPFIELD1_Y(bank) stx extra_tmpfield1 : lda bank : jsr far_lda_tmpfield1_y : ldx extra_tmpfield1

; Call a routine with another active bank
#define TRAMPOLINE(routine,call_bank,return_bank) .( :\
	lda #<routine :\
	sta extra_tmpfield1 :\
	lda #>routine :\
	sta extra_tmpfield2 :\
	lda call_bank :\
	sta extra_tmpfield3 :\
	lda return_bank :\
	sta extra_tmpfield4 :\
	jsr trampoline :\
.)

; Call a routine with another active bank
#define TRAMPOLINE_POINTED(routine_lsb,routine_msb,call_bank,return_bank) .( :\
	lda routine_lsb :\
	sta extra_tmpfield1 :\
	lda routine_msb :\
	sta extra_tmpfield2 :\
	lda call_bank :\
	sta extra_tmpfield3 :\
	lda return_bank :\
	sta extra_tmpfield4 :\
	jsr trampoline :\
.)

#define LOAD_TILESET(addr,bank,ppu_addr,return_bank) .( :\
	jsr load_tileset :\
	.byt >ppu_addr, <ppu_addr :\
	.word modifier_identity :\
	.byt bank :\
	.byt return_bank :\
	.word addr :\
.)

#define LOAD_TILESET_BG(addr,bank,return_bank) .( :\
	ppu_addr = $1000 :\
	jsr load_tileset :\
	.byt >ppu_addr, <ppu_addr :\
	.word modifier_identity :\
	.byt bank :\
	.byt return_bank :\
	.word addr :\
.)

#define LOAD_TILESET_FLIP(addr,bank,ppu_addr,return_bank) .( :\
	jsr load_tileset :\
	.byt >ppu_addr, <ppu_addr :\
	.word modifier_horizontal_flip :\
	.byt bank :\
	.byt return_bank :\
	.word addr :\
.)

#define LOAD_TILESET_REMAP(addr,bank,ppu_addr,p0,p1,p2,p3,return_bank) .( :\
	lda p0:sta tmpfield8 :\
	lda p1:sta tmpfield9 :\
	lda p2:sta tmpfield10 :\
	lda p3:sta tmpfield11 :\
	jsr load_tileset :\
	.byt >ppu_addr, <ppu_addr :\
	.word modifier_remap :\
	.byt bank :\
	.byt return_bank :\
	.word addr :\
.)

#define LOAD_TILESET_SPRITES(addr,bank,return_bank) .( :\
	ppu_addr = $0000 :\
	jsr load_tileset :\
	.byt >ppu_addr, <ppu_addr :\
	.word modifier_identity :\
	.byt bank :\
	.byt return_bank :\
	.word addr :\
.)

; Rainbow-based performance profiling
;  Adapted from Matt Hughson's Witch n' Wiz: https://github.com/mhughson/mbh-A53-witchnwiz
PROF_CLEAR = $1e ; none
PROF_R_TINT = $3e ; red
PROF_G_TINT = $5e ; green
PROF_B_TINT = $9e ; blue
PROF_W_TINT = $1e ; white
PROF_R = $3f ; red + grey
PROF_G = $5f ; green + grey
PROF_B = $9f ; blue + grey
PROF_W = $1f ; white + grey

#define PROFILE_POKE(value) .( :\
	lda #value :\
	sta PPUMASK :\
.)

;
; Stage specific macros
;

#include "game/data/stages/stages-macros.asm"

;
; Game mode specific macros
;

#include "game/data/arcade/arcade-macros.asm"

;
; PAL to NTSC
;

; Create a table with pal and ntsc equivalent durations
;  Note value is rounded, which does not match animation engine behavior (ceiling), do not use for frame-perfect durations
#define duration_table(pal_dur, lbl) \
lbl:\
	.byt (pal_dur), (pal_dur)+((((pal_dur)*10)/5)+5)/10

; Create a table with pal and ntsc equivalent durations
;  Value is ceiled which is appropriate for frame-perfect duration in animations
#define anim_duration_table(pal_dur, lbl) \
lbl:\
	.byt (pal_dur), (pal_dur)+((((pal_dur)*10)/5)+9)/10

; Create a table with pal and ntsc equivalent 2-bytes velocity
#define velocity_table(pal_vel, lbl_msb, lbl_lsb) \
lbl_msb:\
	.byt >(pal_vel), >(((pal_vel)*5)/6) :\
lbl_lsb:\
	.byt <(pal_vel), <(((pal_vel)*5)/6) :\

; Create a table with pal and ntsc equivalent 1-byte velocity
#define velocity_table_u8(pal_vel, lbl) \
lbl: \
	.byt (pal_vel), ((pal_vel)*5)/6

; Create a table with pal and ntsc equivalent 1-byte acceleration
#define acceleration_table(pal_acc, lbl) \
lbl: \
	.byt (pal_acc), ((pal_acc)*50)/72

; Multiply an unsigned 16 bit integer by 0.8333333333333334
;  Overwrites register Y, and register A
#define PAL_TO_NTSC_VELOCITY_POSITIVE(orig_lsb,orig_msb,result_lsb,result_msb) \
.( :\
	ldy orig_lsb :\
	lda pal_to_ntsc_velocity_high_byte, y :\
	:\
	ldy orig_msb :\
	clc :\
	adc pal_to_ntsc_velocity_low_byte, y :\
	sta result_lsb :\
	lda pal_to_ntsc_velocity_high_byte, y :\
	adc #0 :\
	sta result_msb :\
.)

; Multiply a negative 16 bit integer by 0.8333333333333334
;  Overwrites register Y, and register A
#define PAL_TO_NTSC_VELOCITY_NEGATIVE(orig_lsb,orig_msb,result_lsb,result_msb) \
.( :\
	ldy orig_lsb :\
	lda pal_to_ntsc_velocity_high_byte, y :\
	:\
	ldy orig_msb :\
	clc :\
	adc pal_to_ntsc_velocity_neg_low_byte, y :\
	sta result_lsb :\
	lda pal_to_ntsc_velocity_neg_high_byte, y :\
	adc #0 :\
	sta result_msb :\
.)

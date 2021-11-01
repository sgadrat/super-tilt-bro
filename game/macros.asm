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
; Stage specific macros
;

#include "game/data/stages/stages-macros.asm"

;
; PAL to NTSC
;

; Create a table with pal and ntsc equivalent durations
;  Note value is rounded, which does not match animation engine behavior (ceiling), do not use for frame-perfect durations
#define duration_table(pal_dur, lbl) \
lbl:\
	.byt (pal_dur), (pal_dur)+((((pal_dur)*10)/5)+5)/10

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

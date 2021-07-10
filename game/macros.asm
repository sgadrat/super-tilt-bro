;
; Extra animation fields
;

#define ANIM_HITBOX(enabled,damages,base_h,base_v,force_h,force_v,left,right,top,bottom) .byt $2f, enabled, damages, >base_h, <base_h, >base_v, <base_v, >force_h, <force_h, >force_v, <force_v, left, right, top, bottom
#define ANIM_HURTBOX(left,right,top,bottom) .byt $35, left, right, top, bottom

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

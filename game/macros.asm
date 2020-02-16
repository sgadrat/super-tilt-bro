;
; Extra animation fields
;

#define ANIM_HITBOX(enabled,damages,base_h,base_v,force_h,force_v,left,right,top,bottom) .byt $2f, enabled, damages, >base_h, <base_h, >base_v, <base_v, >force_h, <force_h, >force_v, <force_v, left, right, top, bottom
#define ANIM_HURTBOX(left,right,top,bottom) .byt $35, left, right, top, bottom

;
; Character data
;

#define STATE_ROUTINE(x) .byt >(x-1), <(x-1)

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

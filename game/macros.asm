;
; Extra animation fields
;

#define ANIM_HITBOX(enabled,damages,base_h,base_v,force_h,force_v,left,right,top,bottom) .byt $2f, enabled, damages, >base_h, <base_h, >base_v, <base_v, >force_h, <force_h, >force_v, <force_v, left, right, top, bottom
#define ANIM_HURTBOX(left,right,top,bottom) .byt $35, left, right, top, bottom

;
; Stage specific macros
;

#include "game/data/stages/stages-macros.asm"

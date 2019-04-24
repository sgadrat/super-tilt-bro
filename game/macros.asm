;
; Extra animation fields
;

#define ANIM_HITBOX(enabled,damages,base_h,base_v,force_h,force_v,left,right,top,bottom) .byt $08, enabled, damages, >base_h, <base_h, >base_v, <base_v, >force_h, <force_h, >force_v, <force_v, left, right, top, bottom
#define ANIM_HURTBOX(left,right,top,bottom) .byt $04, left, right, top, bottom

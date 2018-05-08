;
; Animations
;

#define ANIM_FRAME_BEGIN(duration) .byt duration
#define ANIM_FRAME_END .byt $00

#define ANIM_ANIMATION_END .byt $00

#define ANIM_HITBOX(enabled,damages,base_h,base_v,force_h,force_v,left,right,top,bottom) .byt $08, enabled, damages, >base_h, <base_h, >base_v, <base_v, >force_h, <force_h, >force_v, <force_v, left, right, top, bottom
#define ANIM_HURTBOX(left,right,top,bottom) .byt $04, left, right, top, bottom
#define ANIM_SPRITE(y,tile,attr,x) .byt $01, y, tile, attr, x
#define ANIM_SPRITE_FOREGROUND(y,tile,attr,x) .byt $11, y, tile, attr, x

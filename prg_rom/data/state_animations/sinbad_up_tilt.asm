anim_sinbad_up_tilt:
; Frame 1
ANIM_FRAME_BEGIN(16)
ANIM_HURTBOX($00, $07, $00, $0f) ; left, right, top, bottom
ANIM_HITBOX($01, $06, $0000, $fa00, $0000, $fff8, $02, $07, $f4, $ff) ; enabled, damages, base_h, base_v, force_h, force_v, left, right, top, bottom
ANIM_SPRITE($f4, TILE_VERTICAL_SCIMITAR_BLADE, $01, $00) ; Y, tile, attr, X
ANIM_SPRITE($fc, TILE_VERTICAL_SCIMITAR_HANDLE, $01, $00)
ANIM_SPRITE($00, TILE_JUMPING_SINBAD_3_HEAD, $00, $00)
ANIM_SPRITE($08, TILE_JUMPING_SINBAD_3_BODY, $00, $00)
ANIM_FRAME_END
; Frame 2
ANIM_FRAME_BEGIN(4)
ANIM_HURTBOX($00, $07, $00, $0f) ; left, right, top, bottom
ANIM_SPRITE($fc, TILE_VERTICAL_SCIMITAR_BLADE, $01, $00) ; Y, tile, attr, X
ANIM_SPRITE($00, TILE_VERTICAL_SCIMITAR_HANDLE, $01, $00)
ANIM_SPRITE($00, TILE_JUMPING_SINBAD_3_HEAD, $00, $00)
ANIM_SPRITE($08, TILE_JUMPING_SINBAD_3_BODY, $00, $00)
ANIM_FRAME_END
; End of animation
ANIM_ANIMATION_END

#print anim_sinbad_up_tilt

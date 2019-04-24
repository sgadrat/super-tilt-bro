anim_sinbad_aerial_neutral:
; Frame 1
ANIM_FRAME_BEGIN(3)
ANIM_HURTBOX($00, $07, $00, $0f) ; left, right, top, bottom
ANIM_HITBOX($01, $01, $ff00, $fe00, $fffe, $fffb, $07, $11, $fc, $03) ; enabled, damages, base_h, base_v, force_h, force_v, left, right, top, bottom
ANIM_SPRITE($fc, TILE_ANGLED_DOWN_SCIMITAR_BLADE, $c1, $0a)
ANIM_SPRITE($fc, TILE_ANGLED_DOWN_SCIMITAR_HANDLE, $c1, $02)
ANIM_SPRITE($00, TILE_JUMPING_SINBAD_3_HEAD, $00, $00) ; Y, tile, attr, X
ANIM_SPRITE($08, TILE_JUMPING_SINBAD_3_BODY, $00, $00)
ANIM_FRAME_END
; Frame 2
ANIM_FRAME_BEGIN(2)
ANIM_HURTBOX($00, $07, $00, $0f)
ANIM_HITBOX($00, $01, $ff00, $fe00, $fffe, $fffb, $ff, $04, $f7, $02) ; enabled, damages, base_h, base_v, force_h, force_v, left, right, top, bottom
ANIM_SPRITE($f7, TILE_VERTICAL_SCIMITAR_BLADE, $01, $fd)
ANIM_SPRITE($ff, TILE_VERTICAL_SCIMITAR_HANDLE, $01, $fd)
ANIM_SPRITE($00, TILE_JUMPING_SINBAD_3_HEAD, $00, $00) ; Y, tile, attr, X
ANIM_SPRITE($08, TILE_JUMPING_SINBAD_3_BODY, $00, $00)
ANIM_FRAME_END
; Frame 3
ANIM_FRAME_BEGIN(2)
ANIM_HURTBOX($00, $07, $00, $0f)
ANIM_HITBOX($00, $01, $ff00, $fe00, $fffe, $fffb, $f2, $fd, $04, $09) ; enabled, damages, base_h, base_v, force_h, force_v, left, right, top, bottom
ANIM_SPRITE($04, TILE_SCIMITAR_BLADE, $01, $f2)
ANIM_SPRITE($04, TILE_SCIMITAR_HANDLE, $01, $fa)
ANIM_SPRITE($00, TILE_JUMPING_SINBAD_3_HEAD, $00, $00) ; Y, tile, attr, X
ANIM_SPRITE($08, TILE_JUMPING_SINBAD_3_BODY, $00, $00)
ANIM_FRAME_END
; Frame 4
ANIM_FRAME_BEGIN(2)
ANIM_HURTBOX($00, $07, $00, $0f)
ANIM_HITBOX($00, $01, $ff00, $fe00, $fffe, $fffb, $f9, $03, $0e, $15) ; enabled, damages, base_h, base_v, force_h, force_v, left, right, top, bottom
ANIM_SPRITE($0e, TILE_ANGLED_DOWN_SCIMITAR_BLADE, $01, $f9)
ANIM_SPRITE($0e, TILE_ANGLED_DOWN_SCIMITAR_HANDLE, $01, $01)
ANIM_SPRITE($00, TILE_JUMPING_SINBAD_3_HEAD, $00, $00) ; Y, tile, attr, X
ANIM_SPRITE($08, TILE_JUMPING_SINBAD_3_BODY, $00, $00)
ANIM_FRAME_END
; Frame 5
ANIM_FRAME_BEGIN(3)
ANIM_HURTBOX($00, $07, $00, $0f)
ANIM_SPRITE($0e, TILE_VERTICAL_SCIMITAR_BLADE, $c1, $04)
ANIM_SPRITE($06, TILE_VERTICAL_SCIMITAR_HANDLE, $c1, $04)
ANIM_SPRITE($00, TILE_JUMPING_SINBAD_3_HEAD, $00, $00) ; Y, tile, attr, X
ANIM_SPRITE($08, TILE_JUMPING_SINBAD_3_BODY, $00, $00)
ANIM_FRAME_END
; End of animation
ANIM_ANIMATION_END

anim_sinbad_crashing:
; Frame 1
ANIM_FRAME_BEGIN(3)
ANIM_HURTBOX($f8, $07, $0a, $0f) ; left, right, top, bottom
ANIM_SPRITE($08, TILE_CHRASHING_SINBAD_1_SIDE, $01, $f0) ; Y, tile, attr, X
ANIM_SPRITE($08, TILE_CHRASHING_SINBAD_1_HEAD, $00, $f8)
ANIM_SPRITE($08, TILE_CHRASHING_SINBAD_1_BODY, $00, $00)
ANIM_SPRITE($08, TILE_CHRASHING_SINBAD_1_SIDE, $41, $08)
ANIM_FRAME_END
; Frame 2
ANIM_FRAME_BEGIN(3)
ANIM_HURTBOX($f8, $07, $06, $0d)
ANIM_SPRITE($08, TILE_CHRASHING_SINBAD_2_SIDE, $01, $f3) ; Y, tile, attr, X
ANIM_SPRITE($08, TILE_CHRASHING_SINBAD_2_MIDDLE, $01, $fc)
ANIM_SPRITE($08, TILE_CHRASHING_SINBAD_2_SIDE, $41, $05)
ANIM_SPRITE($06, TILE_CRASHED_SINBAD_HEAD, $00, $f8)
ANIM_SPRITE($06, TILE_CRASHED_SINBAD_BODY, $00, $00)
ANIM_FRAME_END
; Frame 3
ANIM_FRAME_BEGIN(3)
ANIM_HURTBOX($f8, $07, $08, $0f)
ANIM_SPRITE($08, TILE_CHRASHING_SINBAD_2_SIDE, $01, $f3) ; Y, tile, attr, X
ANIM_SPRITE($08, TILE_CHRASHING_SINBAD_2_MIDDLE, $01, $fc)
ANIM_SPRITE($08, TILE_CHRASHING_SINBAD_2_SIDE, $41, $05)
ANIM_SPRITE($08, TILE_CRASHED_SINBAD_HEAD, $00, $f8) ; Y, tile, attr, X
ANIM_SPRITE($08, TILE_CRASHED_SINBAD_BODY, $00, $00)
ANIM_FRAME_END
; Frame 4
ANIM_FRAME_BEGIN(13)
ANIM_HURTBOX($f8, $07, $08, $0f)
ANIM_SPRITE($08, TILE_CRASHED_SINBAD_HEAD, $00, $f8) ; Y, tile, attr, X
ANIM_SPRITE($08, TILE_CRASHED_SINBAD_BODY, $00, $00)
ANIM_FRAME_END
; Frame 5
ANIM_FRAME_BEGIN(4)
ANIM_HURTBOX($fc, $07, $00, $0f)
ANIM_SPRITE($07, TILE_SCIMITAR_BLADE, $01, $fa)
ANIM_SPRITE($07, TILE_SCIMITAR_HANDLE, $01, $02)
ANIM_SPRITE($00, TILE_SIDE_TILT_SINBAD_3_1, $00, $f8) ; Y, tile, attr, X
ANIM_SPRITE($00, TILE_SIDE_TILT_SINBAD_3_2, $00, $00)
ANIM_SPRITE($08, TILE_SIDE_TILT_SINBAD_3_3, $00, $00)
ANIM_FRAME_END
; Frame 6
ANIM_FRAME_BEGIN(4)
ANIM_HURTBOX($00, $07, $02, $0f)
ANIM_SPRITE($09, TILE_SCIMITAR_BLADE, $01, $fa)
ANIM_SPRITE($09, TILE_SCIMITAR_HANDLE, $01, $02)
ANIM_SPRITE($00, TILE_LANDING_SINBAD_2_TOP, $00, $00) ; Y, tile, attr, X
ANIM_SPRITE($08, TILE_LANDING_SINBAD_2_BOT, $00, $00)
ANIM_FRAME_END
; End of animation
ANIM_ANIMATION_END

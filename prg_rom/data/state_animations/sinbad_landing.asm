anim_sinbad_landing_left:
; Frame 1
ANIM_FRAME_BEGIN(1)
ANIM_HURTBOX($00, $08, $01, $10)
ANIM_SPRITE($08, TILE_SCIMITAR_BLADE, $01, $fa)
ANIM_SPRITE($08, TILE_SCIMITAR_HANDLE, $01, $02)
ANIM_SPRITE($00, TILE_LANDING_SINBAD_1_TOP, $00, $00) ; Y, tile, attr, X
ANIM_SPRITE($08, TILE_LANDING_SINBAD_1_BOT, $00, $00)
ANIM_FRAME_END
; Frame 2
ANIM_FRAME_BEGIN(3)
ANIM_HURTBOX($00, $08, $02, $10)
ANIM_SPRITE($09, TILE_SCIMITAR_BLADE, $01, $fa)
ANIM_SPRITE($09, TILE_SCIMITAR_HANDLE, $01, $02)
ANIM_SPRITE($00, TILE_LANDING_SINBAD_2_TOP, $00, $00) ; Y, tile, attr, X
ANIM_SPRITE($08, TILE_LANDING_SINBAD_2_BOT, $00, $00)
ANIM_FRAME_END
; Frame 3
ANIM_FRAME_BEGIN(2)
ANIM_HURTBOX($00, $08, $01, $10)
ANIM_SPRITE($08, TILE_SCIMITAR_BLADE, $01, $fa)
ANIM_SPRITE($08, TILE_SCIMITAR_HANDLE, $01, $02)
ANIM_SPRITE($00, TILE_LANDING_SINBAD_1_TOP, $00, $00) ; Y, tile, attr, X
ANIM_SPRITE($08, TILE_LANDING_SINBAD_1_BOT, $00, $00)
ANIM_FRAME_END
; End of animation
ANIM_ANIMATION_END

anim_sinbad_landing_right:
; Frame 1
ANIM_FRAME_BEGIN(1)
ANIM_HURTBOX($00, $08, $01, $10)
ANIM_SPRITE($00, TILE_LANDING_SINBAD_1_TOP, $40, $00) ; Y, tile, attr, X
ANIM_SPRITE($08, TILE_LANDING_SINBAD_1_BOT, $40, $00)
ANIM_SPRITE($08, TILE_SCIMITAR_BLADE, $41, $06)
ANIM_SPRITE($08, TILE_SCIMITAR_HANDLE, $41, $fe)
ANIM_FRAME_END
; Frame 2
ANIM_FRAME_BEGIN(3)
ANIM_HURTBOX($00, $08, $02, $10)
ANIM_SPRITE($00, TILE_LANDING_SINBAD_2_TOP, $40, $00) ; Y, tile, attr, X
ANIM_SPRITE($08, TILE_LANDING_SINBAD_2_BOT, $40, $00)
ANIM_SPRITE($09, TILE_SCIMITAR_BLADE, $41, $06)
ANIM_SPRITE($09, TILE_SCIMITAR_HANDLE, $41, $fe)
ANIM_FRAME_END
; Frame 3
ANIM_FRAME_BEGIN(2)
ANIM_HURTBOX($00, $08, $01, $10)
ANIM_SPRITE($00, TILE_LANDING_SINBAD_1_TOP, $40, $00) ; Y, tile, attr, X
ANIM_SPRITE($08, TILE_LANDING_SINBAD_1_BOT, $40, $00)
ANIM_SPRITE($08, TILE_SCIMITAR_BLADE, $41, $06)
ANIM_SPRITE($08, TILE_SCIMITAR_HANDLE, $41, $fe)
ANIM_FRAME_END
; End of animation
ANIM_ANIMATION_END
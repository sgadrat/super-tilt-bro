anim_sinbad_thrown_left:
; Frame 1
ANIM_FRAME_BEGIN(4)
ANIM_HURTBOX($f8, $08, $00, $10)
ANIM_SPRITE($00, TILE_CRASHING_SINBAD_1_NW, $00, $f8) ; Y, tile, attr, X
ANIM_SPRITE($00, TILE_CRASHING_SINBAD_1_NE, $00, $00)
ANIM_SPRITE($08, TILE_CRASHING_SINBAD_1_SW, $00, $f8)
ANIM_SPRITE($08, TILE_CRASHING_SINBAD_1_SE, $00, $00)
ANIM_FRAME_END
; Frame 2
ANIM_FRAME_BEGIN(4)
ANIM_HURTBOX($f8, $08, $00, $10)
ANIM_SPRITE($00, TILE_THROWN_SINBAD_2_NW, $00, $f8) ; Y, tile, attr, X
ANIM_SPRITE($00, TILE_THROWN_SINBAD_2_NE, $00, $00)
ANIM_SPRITE($08, TILE_THROWN_SINBAD_2_SW, $00, $f8)
ANIM_SPRITE($08, TILE_THROWN_SINBAD_2_SE, $00, $00)
ANIM_FRAME_END
; End of animation
ANIM_ANIMATION_END

anim_sinbad_thrown_right:
; Frame 1
ANIM_FRAME_BEGIN(4)
ANIM_HURTBOX($f8, $08, $00, $10)
ANIM_SPRITE($00, TILE_CRASHING_SINBAD_1_NW, $40, $00) ; Y, tile, attr, X
ANIM_SPRITE($00, TILE_CRASHING_SINBAD_1_NE, $40, $f8)
ANIM_SPRITE($08, TILE_CRASHING_SINBAD_1_SW, $40, $00)
ANIM_SPRITE($08, TILE_CRASHING_SINBAD_1_SE, $40, $f8)
ANIM_FRAME_END
; Frame 2
ANIM_FRAME_BEGIN(4)
ANIM_HURTBOX($f8, $08, $00, $10)
ANIM_SPRITE($00, TILE_THROWN_SINBAD_2_NW, $40, $00) ; Y, tile, attr, X
ANIM_SPRITE($00, TILE_THROWN_SINBAD_2_NE, $40, $f8)
ANIM_SPRITE($08, TILE_THROWN_SINBAD_2_SW, $40, $00)
ANIM_SPRITE($08, TILE_THROWN_SINBAD_2_SE, $40, $f8)
ANIM_FRAME_END
; End of animation
ANIM_ANIMATION_END
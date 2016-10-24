anim_sinbad_falling_left:
; Frame 1
.byt 100 ; Frame duration
.byt $04 ; Hurtbox positioning
.byt $00, $08, $00, $10 ; left, right, top, bottom
.byt $01 ; Sprite - Scimitar's blade
.byt $fa, $0f, $01, $01
.byt $01 ; Sprite - Scimitar's handle
.byt $02, $10, $01, $01
.byt $01 ; Sprite - Sinbad
.byt $00, $3d, $00, $00 ; Y, tile, attr, X
.byt $01 ; Sprite - Sinbad
.byt $08, $3e, $00, $00
.byt $00
; End of animation
.byt $00

anim_sinbad_falling_right:
; Frame 1
.byt 100 ; Frame duration
.byt $04 ; Hurtbox positioning
.byt $00, $08, $00, $10 ; left, right, top, bottom
.byt $01 ; Sprite - Sinbad
.byt $00, $3d, $40, $00 ; Y, tile, attr, X
.byt $01 ; Sprite - Sinbad
.byt $08, $3e, $40, $00
.byt $01 ; Sprite - Scimitar's blade
.byt $fa, $0f, $41, $ff
.byt $01 ; Sprite - Scimitar's handle
.byt $02, $10, $41, $ff
.byt $00
; End of animation
.byt $00

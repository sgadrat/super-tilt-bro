anim_sinbad_side_special_left:
; Frame 1
.byt 30 ; Frame duration
.byt $04 ; Hurtbox positioning
.byt $fc, $08, $00, $10 ; left, right, top, bottom
.byt $01 ; Sprite - Sinbad
.byt $00, $19, $00, $f8 ; Y, tile, attr, X
.byt $01 ; Sprite - Sinbad
.byt $00, $1a, $00, $00
.byt $01 ; Sprite - Sinbad
.byt $08, $1b, $00, $00
.byt $00
; Frame 2a
.byt 1; Frame duration
.byt $04 ; Hurtbox positioning
.byt $00, $10, $00, $10 ; left, right, top, bottom
.byt $08 ; Hitbox positioning
.byt $01, $0a, $01, $00, $02, $00, $00, $00, $00, $00, $f8, $04, $06, $0c ; enabled, damages, base_h (2 Bytes), base_v (2 Bytes), force_h (2 Bytes), force_v (2 Bytes), left, right, top, bottom
.byt $01 ; Sprite - Scimitar's blade
.byt $06, $02, $01, $f8
.byt $01 ; Sprite - Scimitar's handle
.byt $06, $03, $01, $00
.byt $01
.byt $00, $04, $00, $00 ; Y, tile, attr, X
.byt $01
.byt $00, $05, $00, $08
.byt $01
.byt $08, $06, $00, $00
.byt $01
.byt $08, $07, $00, $08
.byt $00
; Frame 2b
.byt 60; Frame duration
.byt $04 ; Hurtbox positioning
.byt $00, $10, $00, $10 ; left, right, top, bottom
.byt $08 ; Hitbox positioning
.byt $00, $0a, $01, $00, $02, $00, $00, $00, $00, $00, $f8, $04, $06, $0c ; enabled, damages, base_h (2 Bytes), base_v (2 Bytes), force_h (2 Bytes), force_v (2 Bytes), left, right, top, bottom
.byt $01 ; Sprite - Scimitar's blade
.byt $06, $02, $01, $f8
.byt $01 ; Sprite - Scimitar's handle
.byt $06, $03, $01, $00
.byt $01
.byt $00, $04, $00, $00 ; Y, tile, attr, X
.byt $01
.byt $00, $05, $00, $08
.byt $01
.byt $08, $06, $00, $00
.byt $01
.byt $08, $07, $00, $08
.byt $00
; End of animation
.byt $00

anim_sinbad_side_special_right:
; Frame 1
.byt 30 ; Frame duration
.byt $04 ; Hurtbox positioning
.byt $f8, $04, $00, $10 ; left, right, top, bottom
.byt $01 ; Sprite - Sinbad
.byt $00, $19, $40, $00 ; Y, tile, attr, X
.byt $01 ; Sprite - Sinbad
.byt $00, $1a, $40, $f8
.byt $01 ; Sprite - Sinbad
.byt $08, $1b, $40, $f8
.byt $00
; Frame 2a
.byt 1 ; Frame duration
.byt $04 ; Hurtbox positioning
.byt $f8, $08, $00, $10 ; left, right, top, bottom
.byt $08 ; Hitbox positioning
.byt $01, $0a, $ff, $00, $02, $00, $00, $00, $00, $00, $04, $10, $06, $0c ; enabled, damages, base_h (2 Bytes), base_v (2 Bytes), force_h (2 Bytes), force_v (2 Bytes), left, right, top, bottom
.byt $01 ; Sprite - Scimitar's blade
.byt $06, $02, $41, $08
.byt $01 ; Sprite - Scimitar's handle
.byt $06, $03, $41, $00
.byt $01
.byt $00, $04, $40, $00 ; Y, tile, attr, X
.byt $01
.byt $00, $05, $40, $f8
.byt $01
.byt $08, $06, $40, $00
.byt $01
.byt $08, $07, $40, $f8
.byt $00
; Frame 2b
.byt 60 ; Frame duration
.byt $04 ; Hurtbox positioning
.byt $f8, $08, $00, $10 ; left, right, top, bottom
.byt $08 ; Hitbox positioning
.byt $00, $0a, $ff, $00, $02, $00, $00, $00, $00, $00, $04, $10, $06, $0c ; enabled, damages, base_h (2 Bytes), base_v (2 Bytes), force_h (2 Bytes), force_v (2 Bytes), left, right, top, bottom
.byt $01 ; Sprite - Scimitar's blade
.byt $06, $02, $41, $08
.byt $01 ; Sprite - Scimitar's handle
.byt $06, $03, $41, $00
.byt $01
.byt $00, $04, $40, $00 ; Y, tile, attr, X
.byt $01
.byt $00, $05, $40, $f8
.byt $01
.byt $08, $06, $40, $00
.byt $01
.byt $08, $07, $40, $f8
.byt $00
; End of animation
.byt $00

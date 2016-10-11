anim_sinbad_side_tilt_left:
; Frame 1a (first tick of the Frame 1, enables the hitbox)
.byt 1 ; Frame duration
.byt $04 ; Hurtbox positioning
.byt $00, $0c, $00, $10 ; left, right, top, bottom
.byt $08 ; Hitbox positioning
.byt $01, $0a, $fd, $00, $fd, $00, $ff, $fb, $ff, $fe, $04, $0a, $f4, $00 ; enabled, damages, base_h (2 Bytes), base_v (2 Bytes), force_h (2 Bytes), force_v (2 Bytes), left, right, top, bottom
.byt $01 ; Sprite - Scimitar's blade
.byt $f4, $0f, $01, $02
.byt $01 ; Sprite - Scimitar's handle
.byt $fc, $10, $01, $02
.byt $01 ; Sprite - Sinbad
.byt $00, $13, $00, $fc ; Y, tile, attr, X
.byt $01 ; Sprite - Sinbad
.byt $00, $14, $00, $04
.byt $01 ; Sprite - Sinbad
.byt $08, $15, $00, $fc
.byt $01 ; Sprite - Sinbad
.byt $08, $16, $00, $04
.byt $00
; Frame 1b
.byt 6 ; Frame duration
.byt $04 ; Hurtbox positioning
.byt $00, $0c, $00, $10 ; left, right, top, bottom
.byt $08 ; Hitbox positioning
.byt $00, $0a, $fd, $00, $fd, $00, $ff, $fb, $ff, $fe, $04, $0a, $f4, $00 ; enabled, damages, base_h (2 Bytes), base_v (2 Bytes), force_h (2 Bytes), force_v (2 Bytes), left, right, top, bottom
.byt $01 ; Sprite - Scimitar's blade
.byt $f4, $0f, $01, $02
.byt $01 ; Sprite - Scimitar's handle
.byt $fc, $10, $01, $02
.byt $01 ; Sprite - Sinbad
.byt $00, $13, $00, $fc ; Y, tile, attr, X
.byt $01 ; Sprite - Sinbad
.byt $00, $14, $00, $04
.byt $01 ; Sprite - Sinbad
.byt $08, $15, $00, $fc
.byt $01 ; Sprite - Sinbad
.byt $08, $16, $00, $04
.byt $00
; Frame 2
.byt 7 ; Frame duration
.byt $04 ; Hurtbox positioning
.byt $00, $08, $00, $10 ; left, right, top, bottom
.byt $08 ; Hitbox positioning
.byt $00, $0a, $fd, $00, $fd, $00, $ff, $fb, $ff, $fe, $f9, $01, $fc, $08 ; enabled, damages, base_h (2 Bytes), base_v (2 Bytes), force_h (2 Bytes), force_v (2 Bytes), left, right, top, bottom
.byt $01 ; Sprite - Scimitar's blade
.byt $fc, $11, $01, $f9 ; Y, tile, attr, X
.byt $01 ; Sprite - Scimitar's handle
.byt $04, $12, $01, $f9
.byt $01 ; Sprite - Sinbad
.byt $00, $17, $00, $00
.byt $01 ; Sprite - Sinbad
.byt $08, $18, $00, $00
.byt $00
; Frame 3
.byt 7 ; Frame duration
.byt $04 ; Hurtbox positioning
.byt $fc, $08, $00, $10 ; left, right, top, bottom
.byt $08 ; Hitbox positioning
.byt $00, $0a, $fd, $00, $fd, $00, $ff, $fb, $ff, $fe, $f4, $00, $06, $0c ; enabled, damages, base_h (2 Bytes), base_v (2 Bytes), force_h (2 Bytes), force_v (2 Bytes), left, right, top, bottom
.byt $01 ; Sprite - Scimitar's blade
.byt $06, $02, $01, $f4 ; Y, tile, attr, X
.byt $01 ; Sprite - Scimitar's handle
.byt $06, $03, $01, $fc
.byt $01 ; Sprite - Sinbad
.byt $00, $19, $00, $f8
.byt $01 ; Sprite - Sinbad
.byt $00, $1a, $00, $00
.byt $01 ; Sprite - Sinbad
.byt $08, $1b, $00, $00
.byt $00
; End of animation
.byt $00

anim_sinbad_side_tilt_right:
; Frame 1a
.byt 1 ; Frame duration
.byt $04 ; Hurtbox positioning
.byt $fc, $08, $00, $10 ; left, right, top, bottom
.byt $08 ; Hitbox positioning
.byt $01, $0a, $04, $00, $fd, $00, $00, $05, $ff, $fe, $fe, $04, $f4, $00 ; enabled, damages, base_h (2 Bytes), base_v (2 Bytes), force_h (2 Bytes), force_v (2 Bytes), left, right, top, bottom
.byt $01 ; Sprite - Sinbad
.byt $00, $13, $40, $04 ; Y, tile, attr, X
.byt $01 ; Sprite - Sinbad
.byt $00, $14, $40, $fc
.byt $01 ; Sprite - Sinbad
.byt $08, $15, $40, $04
.byt $01 ; Sprite - Sinbad
.byt $08, $16, $40, $fc
.byt $01 ; Sprite - Scimitar's blade
.byt $f4, $0f, $41, $fe
.byt $01 ; Sprite - Scimitar's handle
.byt $fc, $10, $41, $fe
.byt $00
; Frame 1
.byt 6 ; Frame duration
.byt $04 ; Hurtbox positioning
.byt $fc, $08, $00, $10 ; left, right, top, bottom
.byt $08 ; Hitbox positioning
.byt $00, $0a, $04, $00, $fd, $00, $00, $05, $ff, $fe, $fe, $04, $f4, $00 ; enabled, damages, base_h (2 Bytes), base_v (2 Bytes), force_h (2 Bytes), force_v (2 Bytes), left, right, top, bottom
.byt $01 ; Sprite - Sinbad
.byt $00, $13, $40, $04 ; Y, tile, attr, X
.byt $01 ; Sprite - Sinbad
.byt $00, $14, $40, $fc
.byt $01 ; Sprite - Sinbad
.byt $08, $15, $40, $04
.byt $01 ; Sprite - Sinbad
.byt $08, $16, $40, $fc
.byt $01 ; Sprite - Scimitar's blade
.byt $f4, $0f, $41, $fe
.byt $01 ; Sprite - Scimitar's handle
.byt $fc, $10, $41, $fe
.byt $00
; Frame 2
.byt 7 ; Frame duration
.byt $04 ; Hurtbox positioning
.byt $00, $08, $00, $10 ; left, right, top, bottom
.byt $08 ; Hitbox positioning
.byt $00, $0a, $04, $00, $fd, $00, $00, $05, $ff, $fe, $07, $0f, $fc, $08 ; enabled, damages, base_h (2 Bytes), base_v (2 Bytes), force_h (2 Bytes), force_v (2 Bytes), left, right, top, bottom
.byt $01 ; Sprite - Sinbad
.byt $00, $17, $40, $00 ; Y, tile, attr, X
.byt $01 ; Sprite - Sinbad
.byt $08, $18, $40, $00
.byt $01 ; Sprite - Scimitar's blade
.byt $fc, $11, $41, $07
.byt $01 ; Sprite - Scimitar's handle
.byt $04, $12, $41, $07
.byt $00
; Frame 3
.byt 7 ; Frame duration
.byt $04 ; Hurtbox positioning
.byt $f8, $04, $00, $10 ; left, right, top, bottom
.byt $08 ; Hitbox positioning
.byt $00, $0a, $04, $00, $fd, $00, $00, $05, $ff, $fe, $00, $0c, $06, $0c ; enabled, damages, base_h (2 Bytes), base_v (2 Bytes), force_h (2 Bytes), force_v (2 Bytes), left, right, top, bottom
.byt $01 ; Sprite - Sinbad
.byt $00, $19, $40, $00 ; Y, tile, attr, X
.byt $01 ; Sprite - Sinbad
.byt $00, $1a, $40, $f8
.byt $01 ; Sprite - Sinbad
.byt $08, $1b, $40, $f8
.byt $01 ; Sprite - Scimitar's blade
.byt $06, $02, $41, $04
.byt $01 ; Sprite - Scimitar's handle
.byt $06, $03, $41, $fc
.byt $00
; End of animation
.byt $00

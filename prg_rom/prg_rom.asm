* = $C000 ; $C000 is where the PRG rom is mapped in CPU space, so code position is relative to it

palette_data:
; Background
.byt $21,$07,$1a,$2a,$21,$1a,$18,$09,$21,$39,$3A,$3B,$21,$00,$10,$30
; Sprites
.byt $21,$08,$1a,$20,$21,$08,$10,$37,$21,$1C,$15,$14,$21,$16,$37,$3C

nametable:
.byt $00, $00, $00, $00,  $00, $00, $00, $00,  $00, $00, $00, $00,  $00, $00, $00, $00,  $00, $00, $00, $00,  $00, $00, $00, $00,  $00, $00, $00, $00,  $00, $00, $00, $00
.byt $00, $00, $00, $00,  $00, $00, $00, $00,  $00, $00, $00, $00,  $00, $00, $00, $00,  $00, $00, $00, $00,  $00, $00, $00, $00,  $00, $00, $00, $00,  $00, $00, $00, $00
.byt $00, $00, $00, $00,  $00, $00, $00, $00,  $00, $00, $00, $00,  $00, $00, $00, $00,  $00, $00, $00, $00,  $00, $00, $00, $00,  $00, $00, $00, $00,  $00, $00, $00, $00
.byt $00, $00, $00, $00,  $00, $00, $00, $00,  $00, $00, $00, $00,  $00, $00, $00, $00,  $00, $00, $00, $00,  $00, $00, $00, $00,  $00, $00, $00, $00,  $00, $00, $00, $00

.byt $00, $00, $00, $00,  $00, $00, $00, $00,  $00, $00, $00, $00,  $00, $00, $00, $00,  $00, $00, $00, $00,  $00, $00, $00, $00,  $00, $00, $00, $00,  $00, $00, $00, $00
.byt $00, $00, $00, $00,  $00, $00, $00, $00,  $00, $00, $00, $00,  $00, $00, $00, $00,  $00, $00, $00, $00,  $00, $00, $00, $00,  $00, $00, $00, $00,  $00, $00, $00, $00
.byt $00, $00, $00, $00,  $00, $00, $00, $00,  $00, $00, $00, $00,  $00, $00, $00, $00,  $00, $00, $00, $00,  $00, $00, $00, $00,  $00, $00, $00, $00,  $00, $00, $00, $00
.byt $00, $00, $00, $00,  $00, $00, $00, $00,  $00, $00, $00, $00,  $00, $00, $00, $00,  $00, $00, $00, $00,  $00, $00, $00, $00,  $00, $00, $00, $00,  $00, $00, $00, $00

.byt $00, $00, $00, $00,  $00, $00, $00, $00,  $00, $00, $00, $00,  $00, $00, $00, $00,  $00, $00, $00, $00,  $00, $00, $00, $00,  $00, $00, $00, $00,  $00, $00, $00, $00
.byt $00, $00, $00, $00,  $00, $00, $00, $00,  $00, $00, $00, $00,  $00, $00, $00, $00,  $00, $00, $00, $00,  $00, $00, $00, $00,  $00, $00, $00, $00,  $00, $00, $00, $00
.byt $00, $00, $00, $00,  $00, $00, $00, $00,  $00, $00, $00, $00,  $00, $00, $00, $00,  $00, $00, $00, $00,  $00, $00, $00, $00,  $00, $00, $00, $00,  $00, $00, $00, $00
.byt $00, $00, $00, $00,  $00, $00, $00, $00,  $00, $00, $00, $00,  $00, $00, $00, $00,  $00, $00, $00, $00,  $00, $00, $00, $00,  $00, $00, $00, $00,  $00, $00, $00, $00

.byt $00, $00, $00, $00,  $00, $00, $00, $00,  $00, $00, $00, $00,  $00, $00, $00, $00,  $00, $00, $00, $00,  $00, $00, $00, $00,  $00, $00, $00, $00,  $00, $00, $00, $00
.byt $00, $00, $00, $00,  $00, $00, $00, $00,  $00, $00, $00, $00,  $00, $00, $00, $00,  $00, $00, $00, $00,  $00, $00, $00, $00,  $00, $00, $00, $00,  $00, $00, $00, $00
.byt $00, $00, $00, $00,  $00, $00, $00, $00,  $00, $00, $00, $03,  $04, $05, $06, $00,  $00, $00, $00, $00,  $00, $00, $00, $00,  $00, $00, $00, $00,  $00, $00, $00, $00
.byt $00, $00, $00, $00,  $00, $00, $00, $00,  $00, $00, $00, $07,  $08, $09, $0a, $00,  $00, $00, $00, $00,  $00, $00, $00, $00,  $00, $00, $00, $00,  $00, $00, $00, $00

.byt $00, $00, $00, $00,  $00, $00, $00, $00,  $00, $00, $00, $0b,  $0c, $0d, $0e, $00,  $00, $00, $00, $00,  $00, $00, $00, $00,  $00, $00, $00, $00,  $00, $00, $00, $00
.byt $00, $00, $00, $00,  $00, $00, $00, $00,  $00, $00, $00, $0f,  $10, $11, $12, $00,  $00, $00, $00, $00,  $00, $00, $00, $00,  $00, $00, $00, $00,  $00, $00, $00, $00
.byt $00, $00, $00, $00,  $00, $00, $00, $02,  $02, $02, $02, $02,  $02, $02, $02, $02,  $02, $02, $02, $02,  $02, $02, $00, $00,  $00, $00, $00, $00,  $00, $00, $00, $00
.byt $00, $00, $00, $00,  $00, $00, $00, $01,  $01, $01, $01, $01,  $01, $01, $01, $01,  $01, $01, $01, $01,  $01, $01, $00, $00,  $00, $00, $00, $00,  $00, $00, $00, $00

.byt $00, $00, $00, $00,  $00, $00, $00, $01,  $01, $01, $01, $01,  $01, $01, $01, $01,  $01, $01, $01, $01,  $01, $01, $00, $00,  $00, $00, $00, $00,  $00, $00, $00, $00
.byt $00, $00, $00, $00,  $00, $00, $00, $01,  $01, $01, $01, $01,  $01, $01, $01, $01,  $01, $01, $01, $01,  $01, $01, $00, $00,  $00, $00, $00, $00,  $00, $00, $00, $00
.byt $00, $00, $00, $00,  $00, $00, $00, $01,  $01, $01, $01, $01,  $01, $01, $01, $01,  $01, $01, $01, $01,  $01, $01, $00, $00,  $00, $00, $00, $00,  $00, $00, $00, $00
.byt $00, $00, $00, $00,  $00, $00, $00, $01,  $01, $01, $01, $01,  $01, $01, $01, $01,  $01, $01, $01, $01,  $01, $01, $00, $00,  $00, $00, $00, $00,  $00, $00, $00, $00

.byt $00, $00, $00, $00,  $00, $00, $00, $01,  $01, $01, $01, $01,  $01, $01, $01, $01,  $01, $01, $01, $01,  $01, $01, $00, $00,  $00, $00, $00, $00,  $00, $00, $00, $00
.byt $00, $00, $00, $00,  $00, $00, $00, $01,  $01, $01, $01, $01,  $01, $01, $01, $01,  $01, $01, $01, $01,  $01, $01, $00, $00,  $00, $00, $00, $00,  $00, $00, $00, $00
.byt $00, $00, $00, $00,  $00, $00, $00, $01,  $01, $01, $01, $01,  $01, $01, $01, $01,  $01, $01, $01, $01,  $01, $01, $00, $00,  $00, $00, $00, $00,  $00, $00, $00, $00
.byt $00, $00, $00, $00,  $00, $00, $00, $01,  $01, $01, $01, $01,  $01, $01, $01, $01,  $01, $01, $01, $01,  $01, $01, $00, $00,  $00, $00, $00, $00,  $00, $00, $00, $00

.byt $00, $00, $00, $00,  $00, $00, $00, $01,  $13, $13, $13, $1d,  $01, $01, $01, $01,  $01, $13, $13, $13,  $1d, $01, $00, $00,  $00, $00, $00, $00,  $00, $00, $00, $00
.byt $00, $00, $00, $00,  $00, $00, $00, $01,  $01, $01, $01, $01,  $01, $01, $01, $01,  $01, $01, $01, $01,  $01, $01, $00, $00,  $00, $00, $00, $00,  $00, $00, $00, $00
nametable_attributes:
.byt %00000000, %00000000, %00000000, %00000000, %00000000, %00000000, %00000000, %00000000
.byt %00000000, %00000000, %00000000, %00000000, %00000000, %00000000, %00000000, %00000000
.byt %00000000, %00000000, %00000000, %00000000, %00000000, %00000000, %00000000, %00000000
.byt %00000000, %00000000, %01000000, %01010000, %00000000, %00000000, %00000000, %00000000
.byt %00000000, %00000000, %00000100, %00000101, %00000000, %00000000, %00000000, %00000000
.byt %00000000, %00000000, %00000000, %00000000, %00000000, %00000000, %00000000, %00000000
.byt %00000000, %00000000, %00000000, %00000000, %00000000, %00000000, %00000000, %00000000
.byt %00000000, %00000000, %00000000, %00000000, %00000000, %00000000, %00000000, %00000000
nametable_end:

anim_sinbad_idle_left:
; Frame 1
.byt 60 ; Frame duration
.byt $04 ; Hurtbox positioning
.byt $00, $08, $00, $10 ; left, right, top, bottom
.byt $01 ; Sprite 1 - Scimitar's blade
.byt $07, $02, $01, $fa
.byt $01 ; Sprite 2 - Scimitar's handle
.byt $07, $03, $01, $02
.byt $01 ; Sprite 3 - Sinbad's head
.byt $00, $00, $00, $00 ; Y, tile, attr, X
.byt $01 ; Sprite 4 - Sinbad's body
.byt $08, $01, $00, $00
.byt $00
; Frame 2
.byt 60 ; Frame duration
.byt $04 ; Hurtbox positioning
.byt $00, $08, $00, $10 ; left, right, top, bottom
.byt $01 ; Sprite 1 - Scimitar's blade
.byt $06, $02, $01, $fa
.byt $01 ; Sprite 2 - Scimitar's handle
.byt $06, $03, $01, $02
.byt $01 ; Sprite 3 - Sinbad's head
.byt $00, $00, $00, $00 ; Y, tile, attr, X
.byt $01 ; Sprite 4 - Sinbad's body
.byt $08, $01, $00, $00
.byt $00
; End of animation
.byt $00

anim_sinbad_idle_right:
; Frame 1
.byt 60 ; Frame duration
.byt $04 ; Hurtbox positioning
.byt $00, $08, $00, $10 ; left, right, top, bottom
.byt $01 ; Sprite 1 - Sinbad's head
.byt $00, $00, $40, $00 ; Y, tile, attr, X
.byt $01 ; Sprite 2 - Sinbad's body
.byt $08, $01, $40, $00
.byt $01 ; Sprite 3 - Scimitar's blade
.byt $07, $02, $41, $06
.byt $01 ; Sprite 4 - Scimitar's handle
.byt $07, $03, $41, $fe
.byt $00
; Frame 2
.byt 60 ; Frame duration
.byt $04 ; Hurtbox positioning
.byt $00, $08, $00, $10 ; left, right, top, bottom
.byt $01 ; Sprite 1 - Sinbad's head
.byt $00, $00, $40, $00 ; Y, tile, attr, X
.byt $01 ; Sprite 2 - Sinbad's body
.byt $08, $01, $40, $00
.byt $01 ; Sprite 3 - Scimitar's blade
.byt $06, $02, $41, $06
.byt $01 ; Sprite 4 - Scimitar's handle
.byt $06, $03, $41, $fe
.byt $00
; End of animation
.byt $00

anim_sinbad_run_left:
; Frame 1
.byt 5 ; Frame duration
.byt $04 ; Hurtbox positioning
.byt $00, $10, $00, $10 ; left, right, top, bottom
.byt $01
.byt $00, $04, $00, $00 ; Y, tile, attr, X
.byt $01
.byt $00, $05, $00, $08
.byt $01
.byt $08, $06, $00, $00
.byt $01
.byt $08, $07, $00, $08
.byt $00
; Frame 2
.byt 5 ; Frame duration
.byt $04 ; Hurtbox positioning
.byt $00, $10, $00, $10 ; left, right, top, bottom
.byt $01
.byt $00, $08, $00, $00 ; Y, tile, attr, X
.byt $01
.byt $00, $05, $00, $08
.byt $01
.byt $08, $09, $00, $00
.byt $01
.byt $08, $0a, $00, $08
.byt $00
; Frame 3
.byt 5 ; Frame duration
.byt $04 ; Hurtbox positioning
.byt $00, $10, $00, $10 ; left, right, top, bottom
.byt $01
.byt $00, $04, $00, $00 ; Y, tile, attr, X
.byt $01
.byt $00, $05, $00, $08
.byt $01
.byt $08, $0b, $00, $00
.byt $01
.byt $08, $0c, $00, $08
.byt $00
; End of animation
.byt $00

anim_sinbad_run_right:
; Frame 1
.byt 5 ; Frame duration
.byt $04 ; Hurtbox positioning
.byt $f8, $08, $00, $10 ; left, right, top, bottom
.byt $01
.byt $00, $04, $40, $00 ; Y, tile, attr, X
.byt $01
.byt $00, $05, $40, $f8
.byt $01
.byt $08, $06, $40, $00
.byt $01
.byt $08, $07, $40, $f8
.byt $00
; Frame 2
.byt 5 ; Frame duration
.byt $04 ; Hurtbox positioning
.byt $f8, $08, $00, $10 ; left, right, top, bottom
.byt $01
.byt $00, $08, $40, $00 ; Y, tile, attr, X
.byt $01
.byt $00, $05, $40, $f8
.byt $01
.byt $08, $09, $40, $00
.byt $01
.byt $08, $0a, $40, $f8
.byt $00
; Frame 3
.byt 5 ; Frame duration
.byt $04 ; Hurtbox positioning
.byt $f8, $08, $00, $10 ; left, right, top, bottom
.byt $01
.byt $00, $04, $40, $00 ; Y, tile, attr, X
.byt $01
.byt $00, $05, $40, $f8
.byt $01
.byt $08, $0b, $40, $00
.byt $01
.byt $08, $0c, $40, $f8
.byt $00
; End of animation
.byt $00

#define ANIM_SINBAD_JAB_DURATION #8
anim_sinbad_jab_left:
; Frame 1
.byt 1 ; Frame duration
.byt $04 ; Hurtbox positioning
.byt $00, $08, $00, $10 ; left, right, top, bottom
.byt $08 ; Hitbox positioning
.byt $01, $01, $ff, $ff, $f4, $04, $02, $0a ; enabled, damages, force_h, force_v, left, right, top, bottom
.byt $01 ; Sprite 3 - Scimitar's blade
.byt $02, $02, $01, $f4
.byt $01 ; Sprite 4 - Scimitar's handle
.byt $02, $03, $01, $fc
.byt $01 ; Sprite 1 - Sinbad's head
.byt $00, $00, $00, $00 ; Y, tile, attr, X
.byt $01 ; Sprite 2 - Sinbad's body
.byt $08, $01, $00, $00
.byt $00
; Frame 2
.byt 1 ; Frame duration
.byt $04 ; Hurtbox positioning
.byt $00, $08, $00, $10 ; left, right, top, bottom
.byt $08 ; Hitbox positioning
.byt $01, $01, $ff, $ff, $f4, $04, $03, $0b ; enabled, damages, force_h, force_v, left, right, top, bottom
.byt $01 ; Sprite 3 - Scimitar's blade
.byt $03, $02, $01, $f4
.byt $01 ; Sprite 4 - Scimitar's handle
.byt $03, $03, $01, $fc
.byt $01 ; Sprite 1 - Sinbad's head
.byt $00, $00, $00, $00 ; Y, tile, attr, X
.byt $01 ; Sprite 2 - Sinbad's body
.byt $08, $01, $00, $00
.byt $00
; Frame 3
.byt 1 ; Frame duration
.byt $04 ; Hurtbox positioning
.byt $00, $08, $00, $10 ; left, right, top, bottom
.byt $08 ; Hitbox positioning
.byt $01, $01, $ff, $ff, $f4, $04, $04, $0c ; enabled, damages, force_h, force_v, left, right, top, bottom
.byt $01 ; Sprite 3 - Scimitar's blade
.byt $04, $02, $01, $f4
.byt $01 ; Sprite 4 - Scimitar's handle
.byt $04, $03, $01, $fc
.byt $01 ; Sprite 1 - Sinbad's head
.byt $00, $00, $00, $00 ; Y, tile, attr, X
.byt $01 ; Sprite 2 - Sinbad's body
.byt $08, $01, $00, $00
.byt $00
; Frame 4
.byt 1 ; Frame duration
.byt $04 ; Hurtbox positioning
.byt $00, $08, $00, $10 ; left, right, top, bottom
.byt $08 ; Hitbox positioning
.byt $01, $01, $ff, $ff, $f4, $04, $05, $0d ; enabled, damages, force_h, force_v, left, right, top, bottom
.byt $01 ; Sprite 3 - Scimitar's blade
.byt $05, $02, $01, $f4
.byt $01 ; Sprite 4 - Scimitar's handle
.byt $05, $03, $01, $fc
.byt $01 ; Sprite 1 - Sinbad's head
.byt $00, $00, $00, $00 ; Y, tile, attr, X
.byt $01 ; Sprite 2 - Sinbad's body
.byt $08, $01, $00, $00
.byt $00
; Frame 5
.byt 1 ; Frame duration
.byt $04 ; Hurtbox positioning
.byt $00, $08, $00, $10 ; left, right, top, bottom
.byt $08 ; Hitbox positioning
.byt $01, $01, $ff, $ff, $f4, $04, $06, $0e ; enabled, damages, force_h, force_v, left, right, top, bottom
.byt $01 ; Sprite 3 - Scimitar's blade
.byt $06, $02, $01, $f4
.byt $01 ; Sprite 4 - Scimitar's handle
.byt $06, $03, $01, $fc
.byt $01 ; Sprite 1 - Sinbad's head
.byt $00, $00, $00, $00 ; Y, tile, attr, X
.byt $01 ; Sprite 2 - Sinbad's body
.byt $08, $01, $00, $00
.byt $00
; Frame 6
.byt 1 ; Frame duration
.byt $04 ; Hurtbox positioning
.byt $00, $08, $00, $10 ; left, right, top, bottom
.byt $08 ; Hitbox positioning
.byt $01, $01, $ff, $ff, $f4, $04, $07, $0f ; enabled, damages, force_h, force_v, left, right, top, bottom
.byt $01 ; Sprite 3 - Scimitar's blade
.byt $07, $02, $01, $f4
.byt $01 ; Sprite 4 - Scimitar's handle
.byt $07, $03, $01, $fc
.byt $01 ; Sprite 1 - Sinbad's head
.byt $00, $00, $00, $00 ; Y, tile, attr, X
.byt $01 ; Sprite 2 - Sinbad's body
.byt $08, $01, $00, $00
.byt $00
; Frame 7
.byt 1 ; Frame duration
.byt $04 ; Hurtbox positioning
.byt $00, $08, $00, $10 ; left, right, top, bottom
.byt $08 ; Hitbox positioning
.byt $01, $01, $ff, $ff, $f4, $04, $08, $10 ; enabled, damages, force_h, force_v, left, right, top, bottom
.byt $01 ; Sprite 3 - Scimitar's blade
.byt $08, $02, $01, $f4
.byt $01 ; Sprite 4 - Scimitar's handle
.byt $08, $03, $01, $fc
.byt $01 ; Sprite 1 - Sinbad's head
.byt $00, $00, $00, $00 ; Y, tile, attr, X
.byt $01 ; Sprite 2 - Sinbad's body
.byt $08, $01, $00, $00
.byt $00
; Frame 8
.byt 1 ; Frame duration
.byt $04 ; Hurtbox positioning
.byt $00, $08, $00, $10 ; left, right, top, bottom
.byt $08 ; Hitbox positioning
.byt $01, $01, $ff, $ff, $f4, $04, $09, $11 ; enabled, damages, force_h, force_v, left, right, top, bottom
.byt $01 ; Sprite 3 - Scimitar's blade
.byt $09, $02, $01, $f4
.byt $01 ; Sprite 4 - Scimitar's handle
.byt $09, $03, $01, $fc
.byt $01 ; Sprite 1 - Sinbad's head
.byt $00, $00, $00, $00 ; Y, tile, attr, X
.byt $01 ; Sprite 2 - Sinbad's body
.byt $08, $01, $00, $00
.byt $00
; End of animation
.byt $00

anim_sinbad_jab_right:
; Frame 1
.byt 1 ; Frame duration
.byt $04 ; Hurtbox positioning
.byt $00, $08, $00, $10 ; left, right, top, bottom
.byt $08 ; Hitbox positioning
.byt $01, $01, $01, $ff, $04, $14, $02, $0a ; enabled, damages, force_h, force_v, left, right, top, bottom
.byt $01 ; Sprite 1 - Sinbad's head
.byt $00, $00, $40, $00 ; Y, tile, attr, X
.byt $01 ; Sprite 2 - Sinbad's body
.byt $08, $01, $40, $00
.byt $01 ; Sprite 3 - Scimitar's blade
.byt $02, $02, $41, $0c
.byt $01 ; Sprite 4 - Scimitar's handle
.byt $02, $03, $41, $04
.byt $00
; Frame 2
.byt 1 ; Frame duration
.byt $04 ; Hurtbox positioning
.byt $00, $08, $00, $10 ; left, right, top, bottom
.byt $08 ; Hitbox positioning
.byt $01, $01, $01, $ff, $04, $14, $03, $0b ; enabled, damages, force_h, force_v, left, right, top, bottom
.byt $01 ; Sprite 1 - Sinbad's head
.byt $00, $00, $40, $00 ; Y, tile, attr, X
.byt $01 ; Sprite 2 - Sinbad's body
.byt $08, $01, $40, $00
.byt $01 ; Sprite 3 - Scimitar's blade
.byt $03, $02, $41, $0c
.byt $01 ; Sprite 4 - Scimitar's handle
.byt $03, $03, $41, $04
.byt $00
; Frame 3
.byt 1 ; Frame duration
.byt $04 ; Hurtbox positioning
.byt $00, $08, $00, $10 ; left, right, top, bottom
.byt $08 ; Hitbox positioning
.byt $01, $01, $01, $ff, $04, $14, $04, $0c ; enabled, damages, force_h, force_v, left, right, top, bottom
.byt $01 ; Sprite 1 - Sinbad's head
.byt $00, $00, $40, $00 ; Y, tile, attr, X
.byt $01 ; Sprite 2 - Sinbad's body
.byt $08, $01, $40, $00
.byt $01 ; Sprite 3 - Scimitar's blade
.byt $04, $02, $41, $0c
.byt $01 ; Sprite 4 - Scimitar's handle
.byt $04, $03, $41, $04
.byt $00
; Frame 4
.byt 1 ; Frame duration
.byt $04 ; Hurtbox positioning
.byt $00, $08, $00, $10 ; left, right, top, bottom
.byt $08 ; Hitbox positioning
.byt $01, $01, $01, $ff, $04, $14, $05, $0d ; enabled, damages, force_h, force_v, left, right, top, bottom
.byt $01 ; Sprite 1 - Sinbad's head
.byt $00, $00, $40, $00 ; Y, tile, attr, X
.byt $01 ; Sprite 2 - Sinbad's body
.byt $08, $01, $40, $00
.byt $01 ; Sprite 3 - Scimitar's blade
.byt $05, $02, $41, $0c
.byt $01 ; Sprite 4 - Scimitar's handle
.byt $05, $03, $41, $04
.byt $00
; Frame 5
.byt 1 ; Frame duration
.byt $04 ; Hurtbox positioning
.byt $00, $08, $00, $10 ; left, right, top, bottom
.byt $08 ; Hitbox positioning
.byt $01, $01, $01, $ff, $04, $14, $06, $0e ; enabled, damages, force_h, force_v, left, right, top, bottom
.byt $01 ; Sprite 1 - Sinbad's head
.byt $00, $00, $40, $00 ; Y, tile, attr, X
.byt $01 ; Sprite 2 - Sinbad's body
.byt $08, $01, $40, $00
.byt $01 ; Sprite 3 - Scimitar's blade
.byt $06, $02, $41, $0c
.byt $01 ; Sprite 4 - Scimitar's handle
.byt $06, $03, $41, $04
.byt $00
; Frame 6
.byt 1 ; Frame duration
.byt $04 ; Hurtbox positioning
.byt $00, $08, $00, $10 ; left, right, top, bottom
.byt $08 ; Hitbox positioning
.byt $01, $01, $01, $ff, $04, $14, $07, $0f ; enabled, damages, force_h, force_v, left, right, top, bottom
.byt $01 ; Sprite 1 - Sinbad's head
.byt $00, $00, $40, $00 ; Y, tile, attr, X
.byt $01 ; Sprite 2 - Sinbad's body
.byt $08, $01, $40, $00
.byt $01 ; Sprite 3 - Scimitar's blade
.byt $07, $02, $41, $0c
.byt $01 ; Sprite 4 - Scimitar's handle
.byt $07, $03, $41, $04
.byt $00
; Frame 7
.byt 1 ; Frame duration
.byt $04 ; Hurtbox positioning
.byt $00, $08, $00, $10 ; left, right, top, bottom
.byt $08 ; Hitbox positioning
.byt $01, $01, $01, $ff, $04, $14, $08, $10 ; enabled, damages, force_h, force_v, left, right, top, bottom
.byt $01 ; Sprite 1 - Sinbad's head
.byt $00, $00, $40, $00 ; Y, tile, attr, X
.byt $01 ; Sprite 2 - Sinbad's body
.byt $08, $01, $40, $00
.byt $01 ; Sprite 3 - Scimitar's blade
.byt $08, $02, $41, $0c
.byt $01 ; Sprite 4 - Scimitar's handle
.byt $08, $03, $41, $04
.byt $00
; Frame 8
.byt 1 ; Frame duration
.byt $04 ; Hurtbox positioning
.byt $00, $08, $00, $10 ; left, right, top, bottom
.byt $08 ; Hitbox positioning
.byt $01, $01, $01, $ff, $04, $14, $09, $11 ; enabled, damages, force_h, force_v, left, right, top, bottom
.byt $01 ; Sprite 1 - Sinbad's head
.byt $00, $00, $40, $00 ; Y, tile, attr, X
.byt $01 ; Sprite 2 - Sinbad's body
.byt $08, $01, $40, $00
.byt $01 ; Sprite 3 - Scimitar's blade
.byt $09, $02, $41, $0c
.byt $01 ; Sprite 4 - Scimitar's handle
.byt $09, $03, $41, $04
.byt $00
; End of animation
.byt $00

#define ANIM_SINBAD_SIDE_TILT_DURATION #15
anim_sinbad_side_tilt_left:
; Frame 1
.byt 15 ; Frame duration
.byt $04 ; Hurtbox positioning
.byt $00, $0c, $00, $10 ; left, right, top, bottom
.byt $08 ; Hitbox positioning
.byt $01, $0a, $fc, $ff, $04, $0a, $f4, $00 ; enabled, damages, force_h, force_v, left, right, top, bottom
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
; End of animation
.byt $00

#include "prg_rom/utils.asm"
#include "prg_rom/game.asm"
#include "prg_rom/player_states.asm"
#include "prg_rom/collisions.asm"

cursed:
rti

nmi:
.(
; Save CPU registers
php
pha
txa
pha
tya
pha

; reload PPU OAM (Objects Attributes Memory) with frash data from cpu memory
lda #$00
sta OAMADDR
lda #$02
sta OAMDMA

; Copy nametable buffers to PPU nametable
; A nametable buffer has the following pattern:
;   continuation (1 byte), address (2 bytes), number of tiles (1 byte), tiles (N bytes)
;   continuation - 1 there is a buffer, 0 work done
;   address - address where to write in PPU address space (big endian)
;   number of tiles - Number of tiles in this buffer
;   tiles - One byte per tile, representing the tile number
.(
ldx #$00
handle_nt_buffer:

lda nametable_buffers, x ; Check continuation byte
beq end_buffers          ;
inx                      ;

lda PPUSTATUS            ; Set PPU destination address
lda nametable_buffers, x ;
sta PPUADDR              ;
inx                      ;
lda nametable_buffers, x ;
sta PPUADDR              ;
inx                      ;

lda nametable_buffers, x ; Save tiles counter to tmpfield1
sta tmpfield1            ;
inx                      ;

write_one_tile:
lda tmpfield1            ; Check if there is still a tile to write
beq handle_nt_buffer     ;

lda nametable_buffers, x ; Write current tile to PPU
sta PPUDATA              ;

dec tmpfield1            ; Next tile
inx                      ;
jmp write_one_tile       ;

end_buffers:
.)

; no scroll
lda #$00
sta PPUSCROLL
sta PPUSCROLL

; Inform that NMI is handled
lda #$00
sta nmi_processing

; Restore CPU registers
pla
tay
pla
tax
pla
plp

rti
.)

reset:

sei               ; disable IRQs
cld               ; disable decimal mode
ldx #$40
stx APU_FRAMECNT  ; disable APU frame IRQ
ldx #$FF
txs               ; Set up stack
inx               ; now X = 0
stx PPUCTRL       ; disable NMI
stx PPUMASK       ; disable rendering
stx APU_DMC_FLAGS ; disable DMC IRQs

vblankwait1:       ; First wait for vblank to make sure PPU is ready
bit PPUSTATUS
bpl vblankwait1

clrmem:
lda #$00
sta $0000, x
sta $0100, x
sta $0300, x
sta $0400, x
sta $0500, x
sta $0600, x
sta $0700, x
lda #$FE
sta oam_mirror, x    ;move all sprites off screen
inx
bne clrmem

vblankwait2:      ; Second wait for vblank, PPU is ready after this
bit PPUSTATUS
bpl vblankwait2

; Point PPU to Background palette 0 (see http://wiki.nesdev.com/w/index.php/PPU_palettes)
lda PPUSTATUS
lda #$3f
sta PPUADDR
lda #$00
sta PPUADDR

; Write palette_data in actual ppu palettes
ldx $00
copy_palette:
lda palette_data, x
sta PPUDATA
inx
cpx #$20
bne copy_palette

; Copy background from PRG-rom to PPU nametable
lda #<nametable
sta $40
lda #>nametable
sta $41
lda PPUSTATUS
lda #$20
sta PPUADDR
lda #$00
sta PPUADDR
ldy #$00
load_background:
lda ($40), y
sta PPUDATA
inc $40
bne end_inc_vector
inc $41
end_inc_vector:
lda #<nametable_end
cmp $40
bne load_background
lda #>nametable_end
cmp $41
bne load_background

jsr init_game_state
jsr update_sprites

; Setup PPU
lda #%10010000
sta PPUCTRL
lda #%00011110
sta PPUMASK

forever:

jsr wait_next_frame
jsr fetch_controllers
jsr update_players
jsr update_sprites

jmp forever

;
; Credits in the rom
;

.asc "Credits:",$0a
.asc "Authors:",$0a
.asc "    Sylvain Gadrat",$0a
.asc "Art sources:",$0a
.asc "    www.opengameart.org/content/bomb-party from Matt Hackett of Lost Decade Games",$0a
.asc "    www.opengameart.org/content/twin-dragons from Surt",$0a
.asc "    Sinbad from Zi Ye",$0a

;
; Fill code bank and set entry points vectors (also from nesmine)
;

#if $fffa-* < 0
#echo *** Error: Code occupies too much space
#else
.dsb $fffa-*, 0     ;aligning
.word nmi           ;entry point for VBlank interrupt  (NMI)
.word reset         ;entry point for program start     (RESET)
.word cursed        ;entry point for masking interrupt (IRQ)
#endif

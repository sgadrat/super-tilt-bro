+stage_arcade_boss_impact_data:
STAGE_HEADER($2e00, $ca00, $80ff, $70ff, $6800, $7fff) ; player_a_x, player_b_x, player_a_y, player_b_y, respawn_x, respawn_y
; Platforms
PLATFORM($30, $70, $b7, $d7) ; left, right, top, bot
PLATFORM($38, $c0, $c7, $df) ; left, right, top, bot
PLATFORM($40, $b8, $cf, $e7) ; left, right, top, bot
PLATFORM($88, $c8, $bf, $d7) ; left, right, top, bot
STAGE_BUMPER($68, $90, $a8, $d7, $06, $07d0, $00, $02, $01) ; left, right, top, bot, damages, base, force, horizontal_direction, vertical_direction
PLATFORM($28, $70, $a0, $c7) ; left, right, top, bot
PLATFORM($88, $d0, $a0, $cf) ; left, right, top, bot
SMOOTH_PLATFORM($20, $50, $80) ; left, right, top
SMOOTH_PLATFORM($b0, $e0, $70) ; left, right, top
END_OF_STAGE

+stage_arcade_boss_impact_nametable:
.byt $00,$ff, $00,$f8
.byt
.byt
.byt
;    -------------------  -------------------  -------------------  -------------------  -------------------  -------------------  -------------------  -------------------
.byt
.byt
.byt
.byt
;    -------------------  -------------------  -------------------  -------------------  -------------------  -------------------  -------------------  -------------------
.byt
.byt
.byt
.byt
;    -------------------  -------------------  -------------------  -------------------  -------------------  -------------------  -------------------  -------------------
.byt
.byt
.byt
.byt                                                                                                                         $04,  $05, $20, $06, $07,  $00,$0d
;    -------------------  -------------------  -------------------  -------------------  -------------------  -------------------  -------------------  -------------------
.byt                                                $0f, $00,$0d,                                                            $08,  $0a, $09, $09, $0b,  $00,$09
.byt                           $06, $07, $06,  $04, $05, $00,$0e,                                                                  $13, $12, $0c, $0d,  $00,$09
.byt                           $08, $09, $0a,  $09, $0b, $00,$0d,                                                            $10,  $14, $16, $13, $00,$0a
.byt                           $10, $0c, $0d,  $0e, $00,$0d,                                                            $12, $13,  $0e, $10, $00,$0c
;    -------------------  -------------------  -------------------  -------------------  -------------------  -------------------  -------------------  -------------------
.byt                                $16, $13,  $14, $12, $00,$0b,                                                  $16, $13, $13,  $14, $00,$0e
.byt                                     $0c,  $13, $16, $10, ZIPZ, $06, $07, $00,$05,                  $06,  ZIPZ,$0c, $0c, $0d,  $12, $00,$0d
.byt                                $17, $18,  $19, $18, $19, $18,  $18, $19, $20, $20,  $20, $20, $19, $18,  $19, $18, $18, $19,  $19, $1a, $00,$0c
.byt                                $1b, $2c,  $1d, $1c, $1d, $1c,  $1d, $2c, $28, $28,  $28, $28, $2c, $1c,  $1d, $1c, $1d, $1c,  $1d, $1f, $00,$0c
;    -------------------  -------------------  -------------------  -------------------  -------------------  -------------------  -------------------  -------------------
.byt                                $21, $25,  ZIPZ,$d1, $d2, ZIPZ, $29, $26, $01, $01,  $01, $01, $25, $1e,  ZIPZ,$d6, $d7, ZIPZ, $26, $27, $00,$0d
.byt                                     $1b,  ZIPZ,$d3, $d4, ZIPZ, $29, $2a, $02, $02,  $02, $02, $2c, $24,  ZIPZ,$d8, $d9, ZIPZ, $1e, $1f, $00,$0d
.byt                                     $21,  $dc, $dc, $dc, $db,  $2c, $23, $01, $01,  $01, $01, $1e, $2f,  $dc, $dc, $dc, $db,  $1f, $00,$0f
.byt                                           $1b, $25, $23, $24,  $25, $2c, $02, $02,  $02, $02, $2f, $2c,  $29, $26, $23, $1f,  $00,$11
;    -------------------  -------------------  -------------------  -------------------  -------------------  -------------------  -------------------  -------------------
.byt                                                $1b, $29, $2a,  $29, $1e, $01, $01,  $01, $01, $31, $25,  $2c, $2a, $1f, $00,$17
.byt                                                                          $02, $02,  $02, $02, $00,$0e
.byt 
; Attributes
.byt $00,$2b,$40,$10,$00,$06,$44,$11,$00,$06,$04,$01,$00,$03
; End
.byt ZIPNT_END

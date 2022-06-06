+stage_arcade_boss_space_data:
STAGE_HEADER($2e00, $ca00, $70ff, $70ff, $7c00, $4fff) ; player_a_x, player_b_x, player_a_y, player_b_y, respawn_x, respawn_y
; Platforms
OOS_PLATFORM($ffd0, $0128, $0070, $0140) ; left, right, top, bot
END_OF_STAGE

+stage_arcade_boss_space_palette_data:
;    ground,          unused,          animated lava,   unused
.byt $0f,$07,$16,$27, $0f,$07,$16,$27, $0f,$00,$10,$20, $0f,$00,$10,$20

animated_lava_cycle:
.byt $3f, $05, $03, $21, $16, $27
.byt $3f, $05, $03, $27, $27, $16
.byt $3f, $05, $03, $16, $16, $27
.byt $3f, $05, $03, $07, $27, $16
.byt $3f, $05, $03, $16, $16, $27
.byt $3f, $05, $03, $27, $27, $16
animated_lava_cycle_nt_buff_lsb:
.byt <animated_lava_cycle, <(animated_lava_cycle+6), <(animated_lava_cycle+6*2), <(animated_lava_cycle+6*3), <(animated_lava_cycle+6*4), <(animated_lava_cycle+6*5)
animated_lava_cycle_nt_buff_msb:
.byt >animated_lava_cycle, >(animated_lava_cycle+6), >(animated_lava_cycle+6*2), >(animated_lava_cycle+6*3), >(animated_lava_cycle+6*4), >(animated_lava_cycle+6*5)
animated_lava_cycle_length = * - animated_lava_cycle_nt_buff_msb

+stage_arcade_boss_space_nametable:
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
.byt                                                                                                                         $04,  $05, $20, $06, $07,  $00,$04
;    -------------------  -------------------  -------------------  -------------------  -------------------  -------------------  -------------------  -------------------
.byt $18, $19, $19, $18,  $19, $18, $0a, $0a,  $18, $19, $18, $19,  $0a, $0a, $19, $18,  $18, $19, $19, $18,  $18, $19, $19, $18,  $19, $18, $18, $0a,  $18, $0a, $18, $0a
.byt $1c, $1d, $1d, $1d,  $1c, $1d, $2c, $1c,  $1d, $1d, $1c, $1d,  $1d, $1c, $1d, $1c,  $1d, $29, $1d, $1c,  $1c, $1d, $2c, $1c,  $1d, $1c, $1d, $29,  $1c, $1c, $1c, $1d
.byt $25, $26, $26, $25,  $26, $25, $26, $26,  $25, $26, $25, $26,  $26, $25, $26, $25,  $26, $26, $25, $26,  $25, $26, $26, $25,  $26, $25, $26, $26,  $25, $26, $25, $26
.byt $25, $23, $24, $30,  $31, $25, $23, $24,  $30, $31, $25, $23,  $26, $30, $31, $25,  $23, $26, $30, $31,  $25, $25, $24, $30,  $31, $25, $23, $24,  $30, $31, $25, $23
;    -------------------  -------------------  -------------------  -------------------  -------------------  -------------------  -------------------  -------------------
.byt $25, $29, $2a, $2c,  $26, $26, $26, $25,  $26, $25, $25, $29,  $2a, $2c, $25, $25,  $29, $2a, $2c, $25,  $25, $29, $2b, $2c,  $25, $25, $2c, $2a,  $2c, $25, $25, $29
.byt $29, $26, $25, $26,  $25, $23, $23, $30,  $31, $2c, $29, $26,  $23, $24, $2c, $29,  $26, $25, $24, $2c,  $29, $26, $23, $23,  $2c, $29, $26, $23,  $23, $2c, $29, $26
.byt $26, $2a, $2c, $2a,  $26, $29, $2a, $2c,  $25, $1e, $26, $2a,  $2c, $29, $1e, $26,  $2a, $29, $2a, $1e,  $26, $2a, $29, $2a,  $1e, $26, $2a, $29,  $2a, $1e, $26, $2a
.byt $25, $26, $26, $25,  $29, $26, $25, $26,  $2c, $2b, $2b, $23,  $2b, $26, $25, $25,  $26, $30, $31, $25,  $25, $26, $24, $25,  $26, $26, $26, $25,  $26, $26, $25, $26
;    -------------------  -------------------  -------------------  -------------------  -------------------  -------------------  -------------------  -------------------
.byt $25, $23, $24, $30,  $26, $2a, $29, $2a,  ZIPZ,$d1, $d2, ZIPZ, $25, $26, $25, $29,  $2a, $2c, $25, $1e,  ZIPZ,$d6, $d7, ZIPZ, $25, $23, $24, $30,  $31, $24, $30, $31
.byt $25, $29, $2c, $2c,  $25, $26, $26, $25,  ZIPZ,$d3, $d4, ZIPZ, $29, $2a, $25, $26,  $26, $25, $26, $24,  ZIPZ,$d8, $d9, ZIPZ, $25, $29, $2b, $2c,  $25, $2a, $2c, $25
.byt $29, $26, $23, $24,  $25, $23, $24, $30,  $db, $db, $db, $e5,  $2c, $23, $25, $23,  $26, $30, $31, $2f,  $db, $db, $db, $e5,  $29, $26, $25, $26,  $2c, $23, $26, $2c
.byt $26, $2a, $29, $2b,  $26, $2c, $2a, $2c,  $25, $25, $23, $26,  $25, $2c, $25, $29,  $2a, $2c, $25, $25,  $26, $26, $25, $26,  $26, $2a, $2c, $2a,  $1e, $29, $2a, $1e
;    -------------------  -------------------  -------------------  -------------------  -------------------  -------------------  -------------------  -------------------
.byt $25, $26, $26, $25,  $29, $26, $23, $26,  $2c, $22, $29, $2a,  $29, $1e, $29, $26,  $23, $24, $2c, $25,  $25, $24, $30, $31,  $25, $26, $26, $25,  $26, $25, $26, $26
.byt $25, $23, $24, $30,  $26, $2a, $29, $2a,  $1e, $22, $30, $31,  $22, $22, $26, $2a,  $29, $2b, $1e, $25,  $29, $2a, $2c, $25,  $25, $23, $24, $30,  $31, $25, $23, $24
.byt 
; Attributes
.byt $00,$40
; End
.byt ZIPNT_END

+stage_arcade_fight_town_palette:
.byt $0f,$07,$17,$21, $0f,$07,$19,$21, $0f,$22,$32,$21, $0f,$08,$18,$08
.byt $0f,$07,$07,$21, $0f,$07,$09,$21, $0f,$22,$22,$21, $0f,$08,$08,$08
.byt $0f,$0f,$07,$11, $0f,$0f,$09,$11, $0f,$12,$12,$11, $0f,$0f,$08,$0f
.byt $0f,$0f,$0f,$01, $0f,$0f,$0f,$01, $0f,$02,$02,$01, $0f,$0f,$0f,$0f
.byt $0f,$0f,$0f,$0f, $0f,$0f,$0f,$0f, $0f,$0f,$0f,$0f, $0f,$0f,$0f,$0f

stage_arcade_fight_town_fadeout_lsb:
.byt <stage_arcade_fight_town_palette+(16*4), <stage_arcade_fight_town_palette+(16*3), <stage_arcade_fight_town_palette+(16*2), <stage_arcade_fight_town_palette+(16*1), <stage_arcade_fight_town_palette
stage_arcade_fight_town_fadeout_msb:
.byt >stage_arcade_fight_town_palette+(16*4), >stage_arcade_fight_town_palette+(16*3), >stage_arcade_fight_town_palette+(16*2), >stage_arcade_fight_town_palette+(16*1), >stage_arcade_fight_town_palette

+stage_arcade_fight_town_nametable:
.byt $03, $03, $03, $03,  $03, $03, $03, $03,  $03, $03, $03, $03,  $03, $03, $03, $03,  $03, $03, $03, $03,  $03, $03, $03, $03,  $03, $03, $03, $03,  $03, $03, $03, $03
.byt $03, $03, $03, $03,  $03, $03, $03, $03,  $03, $03, $03, $03,  $03, $03, $03, $03,  $03, $03, $03, $03,  $03, $03, $03, $03,  $03, $03, $03, $03,  $03, $03, $03, $03
.byt $03, $03, $03, $03,  $03, $03, $03, $03,  $03, $03, $03, $03,  $03, $03, $03, $03,  $03, $03, $03, $03,  $03, $03, $03, $03,  $03, $03, $03, $03,  $03, $03, $03, $03
.byt $03, $03, $03, $03,  $03, $03, $03, $03,  $03, $03, $03, $03,  $03, $03, $03, $03,  $03, $03, $03, $03,  $03, $03, $03, $03,  $03, $03, $03, $03,  $03, $03, $03, $03
;    -------------------  -------------------  -------------------  -------------------  -------------------  -------------------  -------------------  -------------------
.byt $03, $03, $03, $03,  $03, $03, $03, $03,  $03, $03, $03, $03,  $03, $03, $03, $03,  $03, $03, $03, $03,  $03, $03, $03, $03,  $03, $03, $03, $03,  $03, $03, $03, $03
.byt $03, $03, $03, $03,  $03, $03, $03, $6c,  $6d, $6d, $6d, $6d,  $6d, $6d, $6d, $6d,  $6d, $6d, $6d, $6d,  $6d, $6d, $6d, $6d,  $6e, $03, $03, $03,  $03, $03, $03, $03
.byt $03, $03, $03, $03,  $03, $03, $5f, $61,  $69, $63, $65, $65,  $65, $63, $61, $63,  $60, $68, $64, $64,  $61, $63, $61, $6a,  $60, $6b, $03, $03,  $03, $03, $03, $03
.byt $03, $03, $03, $03,  $03, $03, $63, $60,  $61, $62, $63, $6a,  $67, $66, $60, $67,  $69, $60, $64, $66,  $62, $63, $64, $65,  $66, $68, $03, $03,  $03, $03, $03, $03
;    -------------------  -------------------  -------------------  -------------------  -------------------  -------------------  -------------------  -------------------
.byt $03, $03, $03, $03,  $03, $03, $7a, $74,  $74, $75, $75, $74,  $74, $75, $74, $74,  $75, $74, $74, $75,  $74, $75, $74, $75,  $74, $79, $03, $03,  $03, $03, $03, $03
.byt $03, $03, $03, $03,  $03, $03, $75, $03,  $03, $03, $03, $03,  $03, $03, $03, $03,  $03, $03, $03, $7a,  $03, $03, $03, $03,  $03, $78, $03, $03,  $03, $03, $03, $03
.byt $03, $03, $03, $03,  $03, $03, $7b, $03,  $7a, $03, $03, $03,  $03, $7b, $03, $03,  $03, $03, $03, $03,  $03, $03, $03, $03,  $03, $7b, $03, $03,  $03, $03, $03, $03
.byt $03, $03, $03, $03,  $03, $03, $79, $03,  $03, $03, $03, $03,  $03, $03, $03, $03,  $03, $03, $03, $03,  $03, $03, $03, $7b,  $03, $7b, $03, $03,  $03, $03, $03, $03
;    -------------------  -------------------  -------------------  -------------------  -------------------  -------------------  -------------------  -------------------
.byt $03, $03, $03, $03,  $03, $03, $7b, $03,  $03, $03, $03, $03,  $03, $03, $03, $03,  $03, $03, $03, $03,  $03, $03, $03, $03,  $03, $7a, $03, $03,  $03, $03, $03, $03
.byt $03, $03, $03, $03,  $03, $03, $79, $03,  $03, $03, $03, $03,  $6c, $6d, $6d, $6d,  $6d, $6d, $6d, $6e,  $03, $03, $03, $03,  $03, $78, $03, $03,  $03, $03, $03, $03
.byt $03, $03, $03, $03,  $03, $03, $74, $03,  $03, $03, $03, $79,  $03, $03, $03, $03,  $03, $03, $03, $03,  $03, $03, $03, $03,  $03, $7b, $03, $03,  $03, $03, $03, $03
.byt $03, $03, $03, $03,  $03, $03, $79, $03,  $03, $03, $78, $03,  $03, $03, $03, $03,  $03, $03, $03, $03,  $03, $03, $03, $7b,  $03, $7a, $03, $03,  $03, $03, $03, $03
;    -------------------  -------------------  -------------------  -------------------  -------------------  -------------------  -------------------  -------------------
.byt $03, $03, $03, $03,  $03, $03, $7a, $03,  $03, $03, $03, $03,  $03, $03, $03, $03,  $78, $03, $03, $03,  $03, $03, $03, $03,  $03, $7b, $03, $03,  $03, $03, $03, $03
.byt $03, $03, $03, $03,  $03, $03, $7a, $03,  $03, $6c, $6d, $6d,  $6d, $6d, $6e, $03,  $03, $6c, $6d, $6d,  $6d, $6d, $6e, $03,  $03, $79, $5f, $60,  $6b, $03, $03, $03
.byt $6b, $03, $03, $03,  $03, $03, $80, $03,  $03, $03, $03, $03,  $03, $03, $03, $03,  $03, $03, $03, $03,  $03, $03, $03, $03,  $03, $81, $68, $68,  $69, $6b, $03, $03
.byt $61, $6b, $03, $03,  $03, $03, $82, $03,  $03, $03, $03, $03,  $03, $03, $03, $03,  $78, $03, $03, $03,  $03, $03, $03, $03,  $03, $83, $61, $6a,  $66, $67, $6b, $03
;    -------------------  -------------------  -------------------  -------------------  -------------------  -------------------  -------------------  -------------------
.byt $64, $62, $6b, $09,  $0a, $0b, $75, $4f,  $50, $03, $03, $4f,  $50, $03, $03, $4f,  $50, $03, $03, $4f,  $50, $03, $03, $4f,  $50, $7a, $66, $60,  $69, $64, $67, $6b
.byt $6a, $65, $66, $6b,  $0e, $11, $78, $51,  $52, $7b, $79, $51,  $52, $7a, $7b, $51,  $52, $79, $79, $51,  $52, $79, $78, $51,  $52, $78, $60, $67,  $6a, $62, $69, $67
.byt $66, $60, $68, $6a,  $6b, $03, $84, $84,  $84, $84, $84, $84,  $84, $84, $84, $84,  $84, $84, $84, $84,  $84, $84, $84, $84,  $84, $84, $65, $67,  $60, $64, $62, $63
.byt $63, $67, $62, $61,  $68, $6b, $85, $85,  $85, $85, $85, $85,  $85, $85, $85, $85,  $85, $85, $85, $85,  $85, $85, $85, $85,  $85, $85, $81, $74,  $75, $75, $75, $75
;    -------------------  -------------------  -------------------  -------------------  -------------------  -------------------  -------------------  -------------------
.byt $74, $80, $81, $74,  $75, $74, $73, $75,  $da, $d1, $d2, $da,  $75, $74, $75, $75,  $74, $74, $75, $74,  $da, $d6, $d7, $da,  $75, $76, $83, $75,  $75, $74, $75, $74
.byt $74, $82, $83, $75,  $74, $74, $70, $79,  $da, $d3, $d4, $da,  $74, $79, $7b, $75,  $74, $79, $75, $7a,  $da, $d8, $d9, $da,  $7a, $76, $84, $84,  $84, $84, $84, $84
.byt $84, $84, $84, $84,  $84, $84, $71, $74,  $dc, $dc, $dc, $db,  $75, $74, $74, $75,  $74, $7a, $79, $75,  $dc, $dc, $dc, $db,  $78, $77, $85, $85,  $85, $85, $85, $85
.byt $85, $85, $85, $85,  $85, $85, $71, $79,  $79, $79, $7a, $75,  $78, $74, $74, $75,  $74, $79, $7a, $75,  $78, $75, $7a, $74,  $74, $76, $75, $74,  $74, $75, $74, $74
;    -------------------  -------------------  -------------------  -------------------  -------------------  -------------------  -------------------  -------------------
.byt $75, $74, $75, $74,  $75, $75, $71, $78,  $74, $79, $75, $74,  $74, $75, $7a, $7b,  $74, $7a, $75, $75,  $74, $74, $78, $75,  $74, $76, $74, $75,  $74, $75, $75, $75
.byt $74, $74, $74, $75,  $75, $74, $70, $7b,  $75, $7b, $7a, $75,  $7b, $7a, $79, $7b,  $79, $75, $7b, $78,  $75, $74, $7a, $7a,  $74, $76, $74, $75,  $74, $74, $74, $75
.byt 
; Attributes
.byt $00,$09,$40,$50,$50,$50,$50,$10,$00,$02,$cc,$ff,$ff,$ff,$ff,$33,$00,$02,$cc,$ff,$ff,$ff,$ff,$33,ZIPZ,$a0,$ec,$ff,$ff,$ff,$ff,$bb,$aa,$aa,$2e,$0f,$0f,$0f,$0f,$8b,$aa,$aa,$22,$00,$04,$88,$aa,$0a,$02,$00,$04,$08,$0a
; End
.byt ZIPNT_END

stage_arcade_fight_town_top_attributes:
.byt $23, $c0, $20
.byt $00, $00, $00, $00, $00, $00, $00, $00
.byt $00, $40, $50, $50, $50, $50, $10, $00
.byt $00, $cc, $ff, $ff, $ff, $ff, $33, $00
.byt $00, $cc, $ff, $ff, $ff, $ff, $33, $00
stage_arcade_fight_town_bot_attributes:
.byt $23, $e0, $20
.byt $a0, $ec, $ff, $ff, $ff, $ff, $bb, $aa
.byt $aa, $2e, $0f, $0f, $0f, $0f, $8b, $aa
.byt $aa, $22, $00, $00, $00, $00, $88, $aa
.byt $0a, $02, $00, $00, $00, $00, $08, $0a

cutscene_sinbad_story_kiki_encounter_palette:
; Background
.byt $0f,$11,$21,$20, $0f,$18,$21,$2a, $0f,$18,$10,$2a, $0f,$34,$21,$20 ; 0-cloud/water, 1-sinbad/island, 2-sinbad, 3-kiki
; Sprites
.byt $0f,$00,$00,$00, $0f,$00,$00,$00, $00,$00,$00,$00, $0f,$00,$00,$00 ; 0-, 1-, 2-, 3-


cutscene_sinbad_story_kiki_encounter_nametable:
.(
;NOTE not labels - value depends on later labels, making these conflict with labels from other scopes

#define C00 cloud_tiles_begin + TILE_TILESET_NEW_CLOUD_0
#define C01 cloud_tiles_begin + 1
#define C02 cloud_tiles_begin + 2
#define C03 cloud_tiles_begin + 3
#define C04 cloud_tiles_begin + 4
#define C05 cloud_tiles_begin + 5
#define C06 cloud_tiles_begin + 6

#define I00 island_tiles_begin + TILE_CUTSCENE_SINBAD_ISLAND_0
#define I01 island_tiles_begin + 1
#define I02 island_tiles_begin + 2
#define I03 island_tiles_begin + 3
#define I04 island_tiles_begin + 4
#define I05 island_tiles_begin + 5
#define I06 island_tiles_begin + 6
#define I07 island_tiles_begin + 7
#define I08 island_tiles_begin + 8
#define I09 island_tiles_begin + 9
#define I0a island_tiles_begin + 10
#define I0b island_tiles_begin + 11
#define I0c island_tiles_begin + 12
#define I0d island_tiles_begin + 13
#define I0e island_tiles_begin + 14
#define I0f island_tiles_begin + 15

#define W00 water_tiles_begin + TILE_CUTSCENE_SINBAD_WATER_0
#define W01 water_tiles_begin + 1
#define W02 water_tiles_begin + 2
#define W03 water_tiles_begin + 3
#define W04 water_tiles_begin + 4
#define W05 water_tiles_begin + 5
#define W06 water_tiles_begin + 6
#define W07 water_tiles_begin + 7
#define W08 water_tiles_begin + 8
#define W09 water_tiles_begin + 9
#define W0a water_tiles_begin + 10
#define W0b water_tiles_begin + 11
#define W0c water_tiles_begin + 12
#define W0d water_tiles_begin + 13

#define S00 sinbad_tiles_begin
#define S01 sinbad_tiles_begin + 1
#define S02 sinbad_tiles_begin + 2
#define S03 sinbad_tiles_begin + 3
#define S04 sinbad_tiles_begin + 4
#define S05 sinbad_tiles_begin + 5
#define S06 sinbad_tiles_begin + 6
#define S07 sinbad_tiles_begin + 7
#define S08 sinbad_tiles_begin + 8
#define S09 sinbad_tiles_begin + 9
#define S0a sinbad_tiles_begin + 10
#define S0b sinbad_tiles_begin + 11
#define S0c sinbad_tiles_begin + 12
#define S0d sinbad_tiles_begin + 13
#define S0e sinbad_tiles_begin + 14
#define S0f sinbad_tiles_begin + 15
#define S10 sinbad_tiles_begin + 16
#define S11 sinbad_tiles_begin + 17
#define S12 sinbad_tiles_begin + 18
#define S13 sinbad_tiles_begin + 19
#define S14 sinbad_tiles_begin + 20
#define S15 sinbad_tiles_begin + 21
#define S16 sinbad_tiles_begin + 22
#define S17 sinbad_tiles_begin + 23
#define S18 sinbad_tiles_begin + 24
#define S19 sinbad_tiles_begin + 25
#define S1a sinbad_tiles_begin + 26
#define S1b sinbad_tiles_begin + 27
#define S1c sinbad_tiles_begin + 28
#define S1d sinbad_tiles_begin + 29
#define S1e sinbad_tiles_begin + 30
#define S1f sinbad_tiles_begin + 31
#define S20 sinbad_tiles_begin + 32
#define S21 sinbad_tiles_begin + 33
#define S22 sinbad_tiles_begin + 34
#define S23 sinbad_tiles_begin + 35
#define S24 sinbad_tiles_begin + 36
#define S25 sinbad_tiles_begin + 37
#define S26 sinbad_tiles_begin + 38
#define S27 sinbad_tiles_begin + 39
#define S28 sinbad_tiles_begin + 40
#define S29 sinbad_tiles_begin + 41
#define S2a sinbad_tiles_begin + 42
#define S2b sinbad_tiles_begin + 43
#define S2c sinbad_tiles_begin + 44
#define S2d sinbad_tiles_begin + 45
#define S2e sinbad_tiles_begin + 46
#define S2f sinbad_tiles_begin + 47
#define S30 sinbad_tiles_begin + 48
#define S31 sinbad_tiles_begin + 49
#define S32 sinbad_tiles_begin + 50
#define S33 sinbad_tiles_begin + 51
#define S34 sinbad_tiles_begin + 52
#define S35 sinbad_tiles_begin + 53
#define S36 sinbad_tiles_begin + 54
#define S37 sinbad_tiles_begin + 55
#define S38 sinbad_tiles_begin + 56
#define S39 sinbad_tiles_begin + 57
#define S3a sinbad_tiles_begin + 58
#define S3b sinbad_tiles_begin + 59
#define S3c sinbad_tiles_begin + 60
#define S3d sinbad_tiles_begin + 61
#define S3e sinbad_tiles_begin + 62
#define S3f sinbad_tiles_begin + 63
#define S40 sinbad_tiles_begin + 64
#define S41 sinbad_tiles_begin + 65
#define S42 sinbad_tiles_begin + 66
#define S43 sinbad_tiles_begin + 67
#define S44 sinbad_tiles_begin + 68
#define S45 sinbad_tiles_begin + 69
#define S46 sinbad_tiles_begin + 70
#define S47 sinbad_tiles_begin + 71
#define S48 sinbad_tiles_begin + 72
#define S49 sinbad_tiles_begin + 73
#define S4a sinbad_tiles_begin + 74
#define S4b sinbad_tiles_begin + 75
#define S4c sinbad_tiles_begin + 76

#define K00 kiki_tiles_begin
#define K01 kiki_tiles_begin + 1
#define K02 kiki_tiles_begin + 2
#define K03 kiki_tiles_begin + 3
#define K04 kiki_tiles_begin + 4
#define K05 kiki_tiles_begin + 5
#define K06 kiki_tiles_begin + 6
#define K07 kiki_tiles_begin + 7
#define K08 kiki_tiles_begin + 8
#define K09 kiki_tiles_begin + 9
#define K0a kiki_tiles_begin + 10
#define K0b kiki_tiles_begin + 11
#define K0c kiki_tiles_begin + 12
#define K0d kiki_tiles_begin + 13
#define K0e kiki_tiles_begin + 14
#define K0f kiki_tiles_begin + 15
#define K10 kiki_tiles_begin + 16
#define K11 kiki_tiles_begin + 17
#define K12 kiki_tiles_begin + 18
#define K13 kiki_tiles_begin + 19
#define K14 kiki_tiles_begin + 20
#define K15 kiki_tiles_begin + 21
#define K16 kiki_tiles_begin + 22
#define K17 kiki_tiles_begin + 23
#define K18 kiki_tiles_begin + 24
#define K19 kiki_tiles_begin + 25
#define K1a kiki_tiles_begin + 26
#define K1b kiki_tiles_begin + 27
#define K1c kiki_tiles_begin + 28
#define K1d kiki_tiles_begin + 29
#define K1e kiki_tiles_begin + 30
#define K1f kiki_tiles_begin + 31
#define K20 kiki_tiles_begin + 32
#define K21 kiki_tiles_begin + 33
#define K22 kiki_tiles_begin + 34
#define K23 kiki_tiles_begin + 35
#define K24 kiki_tiles_begin + 36
#define K25 kiki_tiles_begin + 37
#define K26 kiki_tiles_begin + 38
#define K27 kiki_tiles_begin + 39
#define K28 kiki_tiles_begin + 40
#define K29 kiki_tiles_begin + 41
#define K2a kiki_tiles_begin + 42
#define K2b kiki_tiles_begin + 43
#define K2c kiki_tiles_begin + 44
#define K2d kiki_tiles_begin + 45
#define K2e kiki_tiles_begin + 46
#define K2f kiki_tiles_begin + 47
#define K30 kiki_tiles_begin + 48
#define K31 kiki_tiles_begin + 49
#define K32 kiki_tiles_begin + 50
#define K33 kiki_tiles_begin + 51
#define K34 kiki_tiles_begin + 52
#define K35 kiki_tiles_begin + 53
#define K36 kiki_tiles_begin + 54
#define K37 kiki_tiles_begin + 55
#define K38 kiki_tiles_begin + 56
#define K39 kiki_tiles_begin + 57
#define K3a kiki_tiles_begin + 58
#define K3b kiki_tiles_begin + 59
#define K3c kiki_tiles_begin + 60
#define K3d kiki_tiles_begin + 61
#define K3e kiki_tiles_begin + 62
#define K3f kiki_tiles_begin + 63
#define K40 kiki_tiles_begin + 64
#define K41 kiki_tiles_begin + 65
#define K42 kiki_tiles_begin + 66
#define K43 kiki_tiles_begin + 67
#define K44 kiki_tiles_begin + 68
#define K45 kiki_tiles_begin + 69
#define K46 kiki_tiles_begin + 70
#define K47 kiki_tiles_begin + 71
#define K48 kiki_tiles_begin + 72
#define K49 kiki_tiles_begin + 73
#define K4a kiki_tiles_begin + 74
#define K4b kiki_tiles_begin + 75
#define K4c kiki_tiles_begin + 76
#define K4d kiki_tiles_begin + 77
#define K4e kiki_tiles_begin + 78
#define K4f kiki_tiles_begin + 79

.byt $00,$c0
.byt
.byt
.byt
;    -------------------  -------------------  -------------------  -------------------  -------------------  -------------------  -------------------  -------------------
.byt
.byt
.byt $02, $02, $02, S00,  S01, $01, $01, $01,  $01, S02, $02, $02,  $02, $02, $02, $02,  $02, $02, $02, $02,  K00, K01, $03, K02,  K03, K04, K05, K06,  K07, K08, $02, $02
.byt $02, S03, $02, S04,  S05, $01, $01, $01,  $01, S06, S07, S08,  C00, C05, C01, $02,  $02, $02, $02, $02,  K09, $03, $03, $03,  K0a, K0b, K0c, $03,  $03, K0d, $02, $02
;    -------------------  -------------------  -------------------  -------------------  -------------------  -------------------  -------------------  -------------------
.byt $02, S09, S0a, S0b,  S0c, S0d, S0e, S0f,  S0d, S10, S11, S12,  C02, C06, C03, C04,  $02, $02, $02, $02,  K0e, K0f, $03, $03,  K10, K11, $03, $03,  $03, K12, $02, $02
.byt $02, S13, S14, S15,  S16, S17, S18, S19,  S17, S1a, S1b, $02,  $02, $02, $02, $02,  $02, $02, $02, $02,  K13, K14, $03, $03,  $03, $03, $03, $03,  K15, K16, $02, $02
.byt $02, $02, S1c, S1d,  $03, S1e, S1f, S20,  S1e, S21, S22, $02,  $02, $02, $02, $02,  $02, $02, $02, $02,  K17, K18, K19, K1a,  $03, $03, K1b, K1c,  K1d, K1e, $02, $02
.byt $02, $02, $02, S23,  S24, S25, $03, S26,  S25, S27, $02, $02,  $02, $02, C00, C05,  C01, $02, $02, $02,  K1f, K20, K21, K22,  K23, K24, K25, K26,  K27, $02, C00, C01
;    -------------------  -------------------  -------------------  -------------------  -------------------  -------------------  -------------------  -------------------
.byt $02, $02, S28, $03,  S29, S2a, S2b, S2b,  S2c, S2d, $02, $02,  $02, $02, C02, C06,  C03, C04, $02, $02,  K28, K29, K2a, K2b,  K2c, K2d, K2e, $02,  $02, $02, C02, C03
.byt $02, $02, S2e, S2f,  S30, S31, S32, S32,  S33, S34, $02, $02,  $02, $02, $02, $02,  $02, $02, $02, $02,  K2f, K30, K31, K32,  K33, K34, K35, $02,  $02, $02, $02, $02
.byt I0b, $02, S35, S36,  S37, S38, S39, S1b,  S3a, S3b, $02, $02,  I00, I01, I02, I08,  I09, I0a, I0b, $02,  $02, K36, K37, K38,  K39, K3a, K3b, K3c,  I00, I01, I02, I08
.byt I0e, I0f, $02, S3c,  S3d, S3e, S3f, S40,  S41, S3d, $02, $02,  I03, I04, I05, I06,  I0c, I0d, I0e, I0f,  $02, K3d, K3e, K3f,  K40, K41, K42, K43,  I03, I04, I05, I06
;    -------------------  -------------------  -------------------  -------------------  -------------------  -------------------  -------------------  -------------------
.byt W02, W07, $02, S09,  S42, S42, $03, S43,  S44, S45, S46, $02,  W00, W01, W02, W03,  W04, W05, W06, W07,  $02, K44, K45, K46,  K46, K47, K48, K49,  W00, W01, W02, W07
.byt W0a, W0d, $02, $02,  S47, S48, S49, S4a,  S3a, S4b, S4c, $02,  W08, W09, W0a, W0b,  W0c, W09, W0a, W0d,  $02, K4a, K4b, K4c,  K4d, K4e, K4f, $02,  W08, W09, W0a, W0b
.byt $00,$ff, $00,$81
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
; Attributes
.byt $00,$08,$50,$50,$50,ZIPZ,$c0,$f0,$f0,$30,$55,$aa,$66,ZIPZ,$cc,$ff,$ff,$33,$54,$aa,$66,$50,$50,$ff,$ff,$53,$04,$0a,$06,$00,$02,$0f,$0f,$00,$19
; End
.byt ZIPNT_END

#undef C00
#undef C01
#undef C02
#undef C03
#undef C04
#undef C05
#undef C06

#undef I00
#undef I01
#undef I02
#undef I03
#undef I04
#undef I05
#undef I06
#undef I07
#undef I08
#undef I09
#undef I0a
#undef I0b
#undef I0c
#undef I0d
#undef I0e
#undef I0f

#undef W00
#undef W01
#undef W02
#undef W03
#undef W04
#undef W05
#undef W06
#undef W07
#undef W08
#undef W09
#undef W0a
#undef W0b
#undef W0c
#undef W0d

#undef S00
#undef S01
#undef S02
#undef S03
#undef S04
#undef S05
#undef S06
#undef S07
#undef S08
#undef S09
#undef S0a
#undef S0b
#undef S0c
#undef S0d
#undef S0e
#undef S0f
#undef S10
#undef S11
#undef S12
#undef S13
#undef S14
#undef S15
#undef S16
#undef S17
#undef S18
#undef S19
#undef S1a
#undef S1b
#undef S1c
#undef S1d
#undef S1e
#undef S1f
#undef S20
#undef S21
#undef S22
#undef S23
#undef S24
#undef S25
#undef S26
#undef S27
#undef S28
#undef S29
#undef S2a
#undef S2b
#undef S2c
#undef S2d
#undef S2e
#undef S2f
#undef S30
#undef S31
#undef S32
#undef S33
#undef S34
#undef S35
#undef S36
#undef S37
#undef S38
#undef S39
#undef S3a
#undef S3b
#undef S3c
#undef S3d
#undef S3e
#undef S3f
#undef S40
#undef S41
#undef S42
#undef S43
#undef S44
#undef S45
#undef S46
#undef S47
#undef S48
#undef S49
#undef S4a
#undef S4b
#undef S4c

#undef K00
#undef K01
#undef K02
#undef K03
#undef K04
#undef K05
#undef K06
#undef K07
#undef K08
#undef K09
#undef K0a
#undef K0b
#undef K0c
#undef K0d
#undef K0e
#undef K0f
#undef K10
#undef K11
#undef K12
#undef K13
#undef K14
#undef K15
#undef K16
#undef K17
#undef K18
#undef K19
#undef K1a
#undef K1b
#undef K1c
#undef K1d
#undef K1e
#undef K1f
#undef K20
#undef K21
#undef K22
#undef K23
#undef K24
#undef K25
#undef K26
#undef K27
#undef K28
#undef K29
#undef K2a
#undef K2b
#undef K2c
#undef K2d
#undef K2e
#undef K2f
#undef K30
#undef K31
#undef K32
#undef K33
#undef K34
#undef K35
#undef K36
#undef K37
#undef K38
#undef K39
#undef K3a
#undef K3b
#undef K3c
#undef K3d
#undef K3e
#undef K3f
#undef K40
#undef K41
#undef K42
#undef K43
#undef K44
#undef K45
#undef K46
#undef K47
#undef K48
#undef K49
#undef K4a
#undef K4b
#undef K4c
#undef K4d
#undef K4e
#undef K4f
.)

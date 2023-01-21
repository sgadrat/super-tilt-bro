cutscene_sinbad_story_pepper_encounter_palette:
; Background
.byt $0f,$11,$21,$20, $0f,$18,$21,$2a, $0f,$18,$10,$2a, $0f,$37,$21,$20 ; 0-cloud/water, 1-sinbad/island, 2-sinbad, 3-pepper
; Sprites
.byt $0f,$00,$00,$00, $0f,$00,$00,$00, $00,$00,$00,$00, $0f,$00,$00,$00 ; 0-, 1-, 2-, 3-

cutscene_sinbad_story_pepper_encounter_nametable:
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

#define P00 pepper_tiles_begin
#define P01 pepper_tiles_begin + 1
#define P02 pepper_tiles_begin + 2
#define P03 pepper_tiles_begin + 3
#define P04 pepper_tiles_begin + 4
#define P05 pepper_tiles_begin + 5
#define P06 pepper_tiles_begin + 6
#define P07 pepper_tiles_begin + 7
#define P08 pepper_tiles_begin + 8
#define P09 pepper_tiles_begin + 9
#define P0a pepper_tiles_begin + 10
#define P0b pepper_tiles_begin + 11
#define P0c pepper_tiles_begin + 12
#define P0d pepper_tiles_begin + 13
#define P0e pepper_tiles_begin + 14
#define P0f pepper_tiles_begin + 15
#define P10 pepper_tiles_begin + 16
#define P11 pepper_tiles_begin + 17
#define P12 pepper_tiles_begin + 18
#define P13 pepper_tiles_begin + 19
#define P14 pepper_tiles_begin + 20
#define P15 pepper_tiles_begin + 21
#define P16 pepper_tiles_begin + 22
#define P17 pepper_tiles_begin + 23
#define P18 pepper_tiles_begin + 24
#define P19 pepper_tiles_begin + 25
#define P1a pepper_tiles_begin + 26
#define P1b pepper_tiles_begin + 27
#define P1c pepper_tiles_begin + 28
#define P1d pepper_tiles_begin + 29
#define P1e pepper_tiles_begin + 30
#define P1f pepper_tiles_begin + 31
#define P20 pepper_tiles_begin + 32
#define P21 pepper_tiles_begin + 33
#define P22 pepper_tiles_begin + 34
#define P23 pepper_tiles_begin + 35
#define P24 pepper_tiles_begin + 36
#define P25 pepper_tiles_begin + 37
#define P26 pepper_tiles_begin + 38
#define P27 pepper_tiles_begin + 39
#define P28 pepper_tiles_begin + 40
#define P29 pepper_tiles_begin + 41
#define P2a pepper_tiles_begin + 42
#define P2b pepper_tiles_begin + 43
#define P2c pepper_tiles_begin + 44
#define P2d pepper_tiles_begin + 45
#define P2e pepper_tiles_begin + 46
#define P2f pepper_tiles_begin + 47
#define P30 pepper_tiles_begin + 48
#define P31 pepper_tiles_begin + 49
#define P32 pepper_tiles_begin + 50
#define P33 pepper_tiles_begin + 51
#define P34 pepper_tiles_begin + 52
#define P35 pepper_tiles_begin + 53
#define P36 pepper_tiles_begin + 54
#define P37 pepper_tiles_begin + 55
#define P38 pepper_tiles_begin + 56
#define P39 pepper_tiles_begin + 57
#define P3a pepper_tiles_begin + 58
#define P3b pepper_tiles_begin + 59
#define P3c pepper_tiles_begin + 60
#define P3d pepper_tiles_begin + 61
#define P3e pepper_tiles_begin + 62
#define P3f pepper_tiles_begin + 63
#define P40 pepper_tiles_begin + 64
#define P41 pepper_tiles_begin + 65
#define P42 pepper_tiles_begin + 66
#define P43 pepper_tiles_begin + 67
#define P44 pepper_tiles_begin + 68
#define P45 pepper_tiles_begin + 69
#define P46 pepper_tiles_begin + 70
#define P47 pepper_tiles_begin + 71
#define P48 pepper_tiles_begin + 72
#define P49 pepper_tiles_begin + 73
#define P4a pepper_tiles_begin + 74
#define P4b pepper_tiles_begin + 75
#define P4c pepper_tiles_begin + 76
#define P4d pepper_tiles_begin + 77

.byt $00,$c0
.byt
.byt
.byt
;    -------------------  -------------------  -------------------  -------------------  -------------------  -------------------  -------------------  -------------------
.byt
.byt
.byt $02, $02, $02, S00,  S01, $01, $01, $01,  $01, S02, $02, $02,  $02, $02, $02, $02,  $02, $02, $02, $02,  $02, $02, P00, P01,  P01, P01, P02, P03,  P04, $02, $02, $02
.byt $02, S03, $02, S04,  S05, $01, $01, $01,  $01, S06, S07, S08,  C00, C05, C01, $02,  $02, $02, $02, $02,  P05, P06, P07, $01,  $01, $01, $01, $01,  P08, P04, $02, $02
;    -------------------  -------------------  -------------------  -------------------  -------------------  -------------------  -------------------  -------------------
.byt $02, S09, S0a, S0b,  S0c, S0d, S0e, S0f,  S0d, S10, S11, S12,  C02, C06, C03, C04,  $02, $02, $02, P09,  P0a, P0b, P0c, P0d,  P0e, P0f, P10, $01,  $01, P11, $02, $02
.byt $02, S13, S14, S15,  S16, S17, S18, S19,  S17, S1a, S1b, $02,  $02, $02, $02, $02,  $02, $02, $02, P12,  P13, P14, P15, $01,  P16, P17, P18, P19,  $01, P1a, $02, $02
.byt $02, $02, S1c, S1d,  $03, S1e, S1f, S20,  S1e, S21, S22, $02,  $02, $02, $02, $02,  $02, $02, $02, P1b,  P1c,ZIPZ, P1d, P1e,  $01, P1f, P20,ZIPZ,  $01, P1a, $02, $02
.byt $02, $02, $02, S23,  S24, S25, $03, S26,  S25, S27, $02, $02,  $02, $02, C00, C05,  C01, $02, $02, $02,  P21,ZIPZ, P22, P23,  $01, P24, P25,ZIPZ,  $01, P26, C00, C01
;    -------------------  -------------------  -------------------  -------------------  -------------------  -------------------  -------------------  -------------------
.byt $02, $02, S28, $03,  S29, S2a, S2b, S2b,  S2c, S2d, $02, $02,  $02, $02, C02, C06,  C03, C04, $02, $02,  P27, P28, P29, P2a,  P2b, P2c, P2d, P2e,  P2f, $02, C02, C03
.byt $02, $02, S2e, S2f,  S30, S31, S32, S32,  S33, S34, $02, $02,  $02, $02, $02, $02,  $02, $02, $02, $02,  P30, $02, P31, $01,  P32, P33, P34, P35,  $02, $02, $02, $02
.byt I0b, $02, S35, S36,  S37, S38, S39, S1b,  S3a, S3b, $02, $02,  I00, I01, I02, I08,  I09, I0a, I0b, $02,  $02, $02, P36, P37,  P38, P39, P3a, P3b,  I00, I01, I02, I08
.byt I0e, I0f, $02, S3c,  S3d, S3e, S3f, S40,  S41, S3d, $02, $02,  I03, I04, I05, I06,  I0c, I0d, I0e, I0f,  $02, $02, P3c, P3d,  P3e, P3f, P40, P41,  I03, I04, I05, I06
;    -------------------  -------------------  -------------------  -------------------  -------------------  -------------------  -------------------  -------------------
.byt W02, W07, $02, S09,  S42, S42, $03, S43,  S44, S45, S46, $02,  W00, W01, W02, W03,  W04, W05, W06, W07,  $02, $02, P42, P43,  P44, P45, P46, P47,  W00, W01, W02, W07
.byt W0a, W0d, $02, $02,  S47, S48, S49, S4a,  S3a, S4b, S4c, $02,  W08, W09, W0a, W0b,  W0c, W09, W0a, W0d,  $02, P48, P49, P4a,  P4b, P4c, P4d, $02,  W08, W09, W0a, W0b
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

#undef P00
#undef P01
#undef P02
#undef P03
#undef P04
#undef P05
#undef P06
#undef P07
#undef P08
#undef P09
#undef P0a
#undef P0b
#undef P0c
#undef P0d
#undef P0e
#undef P0f
#undef P10
#undef P11
#undef P12
#undef P13
#undef P14
#undef P15
#undef P16
#undef P17
#undef P18
#undef P19
#undef P1a
#undef P1b
#undef P1c
#undef P1d
#undef P1e
#undef P1f
#undef P20
#undef P21
#undef P22
#undef P23
#undef P24
#undef P25
#undef P26
#undef P27
#undef P28
#undef P29
#undef P2a
#undef P2b
#undef P2c
#undef P2d
#undef P2e
#undef P2f
#undef P30
#undef P31
#undef P32
#undef P33
#undef P34
#undef P35
#undef P36
#undef P37
#undef P38
#undef P39
#undef P3a
#undef P3b
#undef P3c
#undef P3d
#undef P3e
#undef P3f
#undef P40
#undef P41
#undef P42
#undef P43
#undef P44
#undef P45
#undef P46
#undef P47
#undef P48
#undef P49
#undef P4a
#undef P4b
#undef P4c
#undef P4d
.)


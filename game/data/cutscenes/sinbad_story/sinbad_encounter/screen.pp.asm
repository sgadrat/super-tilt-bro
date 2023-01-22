cutscene_sinbad_story_sinbad_encounter_palette:
; Background
.byt $0f,$11,$21,$20, $0f,$18,$21,$2a, $0f,$18,$10,$2a, $0f,$34,$21,$20 ; 0-cloud/water, 1-sinbad/island, 2-sinbad, 3-unused
; Sprites
.byt $0f,$00,$00,$00, $0f,$00,$00,$00, $00,$00,$00,$00, $0f,$00,$00,$00 ; 0-, 1-, 2-, 3-


cutscene_sinbad_story_sinbad_encounter_nametable:
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

#define G00 opponent_tiles_begin
#define G01 opponent_tiles_begin + 1
#define G02 opponent_tiles_begin + 2
#define G03 opponent_tiles_begin + 3
#define G04 opponent_tiles_begin + 4
#define G05 opponent_tiles_begin + 5
#define G06 opponent_tiles_begin + 6
#define G07 opponent_tiles_begin + 7
#define G08 opponent_tiles_begin + 8
#define G09 opponent_tiles_begin + 9
#define G0a opponent_tiles_begin + 10
#define G0b opponent_tiles_begin + 11
#define G0c opponent_tiles_begin + 12
#define G0d opponent_tiles_begin + 13
#define G0e opponent_tiles_begin + 14
#define G0f opponent_tiles_begin + 15
#define G10 opponent_tiles_begin + 16
#define G11 opponent_tiles_begin + 17
#define G12 opponent_tiles_begin + 18
#define G13 opponent_tiles_begin + 19
#define G14 opponent_tiles_begin + 20
#define G15 opponent_tiles_begin + 21
#define G16 opponent_tiles_begin + 22
#define G17 opponent_tiles_begin + 23
#define G18 opponent_tiles_begin + 24
#define G19 opponent_tiles_begin + 25
#define G1a opponent_tiles_begin + 26
#define G1b opponent_tiles_begin + 27
#define G1c opponent_tiles_begin + 28
#define G1d opponent_tiles_begin + 29
#define G1e opponent_tiles_begin + 30
#define G1f opponent_tiles_begin + 31
#define G20 opponent_tiles_begin + 32
#define G21 opponent_tiles_begin + 33
#define G22 opponent_tiles_begin + 34
#define G23 opponent_tiles_begin + 35
#define G24 opponent_tiles_begin + 36
#define G25 opponent_tiles_begin + 37
#define G26 opponent_tiles_begin + 38
#define G27 opponent_tiles_begin + 39
#define G28 opponent_tiles_begin + 40
#define G29 opponent_tiles_begin + 41
#define G2a opponent_tiles_begin + 42
#define G2b opponent_tiles_begin + 43
#define G2c opponent_tiles_begin + 44
#define G2d opponent_tiles_begin + 45
#define G2e opponent_tiles_begin + 46
#define G2f opponent_tiles_begin + 47
#define G30 opponent_tiles_begin + 48
#define G31 opponent_tiles_begin + 49
#define G32 opponent_tiles_begin + 50
#define G33 opponent_tiles_begin + 51
#define G34 opponent_tiles_begin + 52
#define G35 opponent_tiles_begin + 53
#define G36 opponent_tiles_begin + 54
#define G37 opponent_tiles_begin + 55
#define G38 opponent_tiles_begin + 56
#define G39 opponent_tiles_begin + 57
#define G3a opponent_tiles_begin + 58
#define G3b opponent_tiles_begin + 59
#define G3c opponent_tiles_begin + 60
#define G3d opponent_tiles_begin + 61
#define G3e opponent_tiles_begin + 62
#define G3f opponent_tiles_begin + 63
#define G40 opponent_tiles_begin + 64
#define G41 opponent_tiles_begin + 65
#define G42 opponent_tiles_begin + 66
#define G43 opponent_tiles_begin + 67
#define G44 opponent_tiles_begin + 68
#define G45 opponent_tiles_begin + 69
#define G46 opponent_tiles_begin + 70
#define G47 opponent_tiles_begin + 71
#define G48 opponent_tiles_begin + 72
#define G49 opponent_tiles_begin + 73
#define G4a opponent_tiles_begin + 74
#define G4b opponent_tiles_begin + 75
#define G4c opponent_tiles_begin + 76

.byt $00,$c0
.byt
.byt
.byt
;    -------------------  -------------------  -------------------  -------------------  -------------------  -------------------  -------------------  -------------------
.byt
.byt
.byt $02, $02, $02, S00,  S01, $01, $01, $01,  $01, S02, $02, $02,  $02, $02, $02, $02,  $02, $02, $02, $02,  $02, $02, G02, $01,  $01, $01, $01, G01,  G00, $02, $02, $02
.byt $02, S03, $02, S04,  S05, $01, $01, $01,  $01, S06, S07, S08,  C00, C05, C01, $02,  $02, $02, $02, $02,  G08, G07, G06, $01,  $01, $01, $01, G05,  G04, $02, G03, $02
;    -------------------  -------------------  -------------------  -------------------  -------------------  -------------------  -------------------  -------------------
.byt $02, S09, S0a, S0b,  S0c, S0d, S0e, S0f,  S0d, S10, S11, S12,  C02, C06, C03, C04,  $02, $02, $02, $02,  G12, G11, G10, G0d,  G0f, G0e, G0d, G0c,  G0b, G0a, G09, $02
.byt $02, S13, S14, S15,  S16, S17, S18, S19,  S17, S1a, S1b, $02,  $02, $02, $02, $02,  $02, $02, $02, $02,  $02, G1b, G1a, G17,  G19, G18, G17, G16,  G15, G14, G13, $02
.byt $02, $02, S1c, S1d,  $03, S1e, S1f, S20,  S1e, S21, S22, $02,  $02, $02, $02, $02,  $02, $02, $02, $02,  $02, G22, G21, G1e,  G20, G1f, G1e, $03,  G1d, G1c, $02, $02
.byt $02, $02, $02, S23,  S24, S25, $03, S26,  S25, S27, $02, $02,  $02, $02, C00, C05,  C01, $02, $02, $02,  $02, $02, G27, G25,  G26, $03, G25, G24,  G23, $02, C00, C01
;    -------------------  -------------------  -------------------  -------------------  -------------------  -------------------  -------------------  -------------------
.byt $02, $02, S28, $03,  S29, S2a, S2b, S2b,  S2c, S2d, $02, $02,  $02, $02, C02, C06,  C03, C04, $02, $02,  $02, $02, G2d, G2c,  G2b, G2b, G2a, G29,  $03, G28, C02, C03
.byt $02, $02, S2e, S2f,  S30, S31, S32, S32,  S33, S34, $02, $02,  $02, $02, $02, $02,  $02, $02, $02, $02,  $02, $02, G34, G33,  G32, G32, G31, G30,  G2f, G2e, $02, $02
.byt I0b, $02, S35, S36,  S37, S38, S39, S1b,  S3a, S3b, $02, $02,  I00, I01, I02, I08,  I09, I0a, I0b, $02,  $02, $02, G3b, G3a,  G1b, G39, G38, G37,  G36, G35, I02, I08
.byt I0e, I0f, $02, S3c,  S3d, S3e, S3f, S40,  S41, S3d, $02, $02,  I03, I04, I05, I06,  I0c, I0d, I0e, I0f,  $02, $02, G3d, G41,  G40, G3f, G3e, G3d,  G3c, $02, I05, I06
;    -------------------  -------------------  -------------------  -------------------  -------------------  -------------------  -------------------  -------------------
.byt W02, W07, $02, S09,  S42, S42, $03, S43,  S44, S45, S46, $02,  W00, W01, W02, W03,  W04, W05, W06, W07,  $02, G46, G45, G44,  G43, $03, G42, G42,  G09, $02, W02, W07
.byt W0a, W0d, $02, $02,  S47, S48, S49, S4a,  S3a, S4b, S4c, $02,  W08, W09, W0a, W0b,  W0c, W09, W0a, W0d,  $02, G4c, G4b, G3a,  G4a, G49, G48, G47,  $02, $02, W0a, W0b
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
.byt $00,$08,$50,$50,$50,$00,$02,$50,$50,$50,$55,$aa,$66,$00,$02,$99,$aa,$55,$54,$aa,$66,$50,$50,$99,$aa,$51,$04,$0a,$06,$00,$02,$09,$0a,$01,$00,$18
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

#undef G00
#undef G01
#undef G02
#undef G03
#undef G04
#undef G05
#undef G06
#undef G07
#undef G08
#undef G09
#undef G0a
#undef G0b
#undef G0c
#undef G0d
#undef G0e
#undef G0f
#undef G10
#undef G11
#undef G12
#undef G13
#undef G14
#undef G15
#undef G16
#undef G17
#undef G18
#undef G19
#undef G1a
#undef G1b
#undef G1c
#undef G1d
#undef G1e
#undef G1f
#undef G20
#undef G21
#undef G22
#undef G23
#undef G24
#undef G25
#undef G26
#undef G27
#undef G28
#undef G29
#undef G2a
#undef G2b
#undef G2c
#undef G2d
#undef G2e
#undef G2f
#undef G30
#undef G31
#undef G32
#undef G33
#undef G34
#undef G35
#undef G36
#undef G37
#undef G38
#undef G39
#undef G3a
#undef G3b
#undef G3c
#undef G3d
#undef G3e
#undef G3f
#undef G40
#undef G41
#undef G42
#undef G43
#undef G44
#undef G45
#undef G46
#undef G47
#undef G48
#undef G49
#undef G4a
#undef G4b
#undef G4c
.)

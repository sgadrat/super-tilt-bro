#include "prg_rom/data/music/theme_main/samples.asm"

track_main_square1:
.word theme_main_square1_intro
.word theme_main_square1_sample1
.word theme_main_square1_sample2
.word theme_main_square1_sample3
.word theme_main_square1_sample4
.word theme_main_square1_sample5
.word theme_main_square1_sample4
.word theme_main_square1_sample6
;.word theme_main_square1_sample4
MUSIC_END

track_main_square2:
.word theme_main_square2_intro
.word theme_main_square2_sample1
.word theme_main_square2_sample2
.word theme_main_square2_sample3
.word theme_main_square2_sample4
.word theme_main_square2_sample5
.word theme_main_square2_sample4
.word theme_main_square2_sample6
;.word theme_main_square2_sample4
MUSIC_END

track_main_triangle:
.word theme_main_triangle_intro

.word theme_main_triangle_helicopter, theme_main_triangle_helicopter, theme_main_triangle_helicopter, theme_main_triangle_helicopter

; ftm file - $0300
.word theme_main_triangle_bass_c3_x4
.word theme_main_triangle_bass_f2_x2
.word theme_main_triangle_bass_g2_x2
.word theme_main_triangle_bass_c3_x4
.word theme_main_triangle_bass_f2_x2
.word theme_main_triangle_bass_g2_x2
.word theme_main_triangle_bass_c3_x4
.word theme_main_triangle_bass_f2_x2
.word theme_main_triangle_bass_g2_x2
.word theme_main_triangle_bass_c3_x4
.word theme_main_triangle_bass_c3_x4

; ftm file - $0600
.word theme_main_triangle_bass2_f2_x4
.word theme_main_triangle_bass2_g2_x4
.word theme_main_triangle_bass2_f2_x4
.word theme_main_triangle_bass2_g2_x4

; ftm file - $0780
.word theme_main_triangle_bass_c3_x4
.word theme_main_triangle_bass_f2_x2
.word theme_main_triangle_bass_g2_x2
.word theme_main_triangle_bass_c3_x4
.word theme_main_triangle_bass_f2_x2
.word theme_main_triangle_bass_g2_x2
.word theme_main_triangle_bass_c3_x4
.word theme_main_triangle_bass_f2_x2
.word theme_main_triangle_bass_g2_x2
.word theme_main_triangle_bass_c3_x4
.word theme_main_triangle_bass_c3_x4

; ftm file - $0a80
.word theme_main_triangle_bass2_g2_x4
.word theme_main_triangle_bass2_f2_x4
.word theme_main_triangle_bass2_c3_x4

; ftm file - $0ba0
.word theme_main_triangle_bass2_g2_x4
.word theme_main_triangle_bass2_g2_x4
.word theme_main_triangle_bass2_f2_x4
.word theme_main_triangle_bass2_c3_x4
.word theme_main_triangle_bass2_g2_x4

; ftm file - $0d80
.word theme_main_triangle_bass_c3_x4
.word theme_main_triangle_bass_f2_x2
.word theme_main_triangle_bass_g2_x2

; ftm file - $0e40
.word theme_main_triangle_bass_c3_x4
.word theme_main_triangle_bass_f2_x2
.word theme_main_triangle_bass_g2_x2

; ftm file - $0f00
.word theme_main_triangle_bass_c3_x4
.word theme_main_triangle_bass_f2_x2
.word theme_main_triangle_bass_g2_x2

; ftm file - $0fc0
.word theme_main_triangle_bass_c3_x4, theme_main_triangle_bass_c3_x4
.word theme_main_triangle_bass_a2_x4
.word theme_main_triangle_bass_f2_x2, theme_main_triangle_bass_f2_x2
.word theme_main_triangle_bass_g2_x2, theme_main_triangle_bass_g2_x2

; ftm file - $11a0
.word theme_main_triangle_bass_a2_x4, theme_main_triangle_bass_a2_x4
.word theme_main_triangle_bass_f2_x2, theme_main_triangle_bass_f2_x2
.word theme_main_triangle_bass_g2_x2, theme_main_triangle_bass_g2_x2
.word theme_main_triangle_bass_a2_x4

; ftm file - $1380
.word theme_main_triangle_bass_c3_x4
.word theme_main_triangle_bass_f2_x2
.word theme_main_triangle_bass_g2_x2

; ftm file - $1440
.word theme_main_triangle_bass_c3_x4
.word theme_main_triangle_bass_f2_x2
.word theme_main_triangle_bass_g2_x2

; ftm file - $1500
.word theme_main_triangle_bass_c3_x4
.word theme_main_triangle_bass_f2_x2
.word theme_main_triangle_bass_g2_x2

; ftm file - $15c0
.word theme_main_triangle_bass_c3_x4, theme_main_triangle_bass_c3_x4

; ftm file - $1680
.word theme_main_triangle_epilog

MUSIC_END

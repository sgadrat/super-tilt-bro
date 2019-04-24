#include "game/data/music/theme_menus/samples.asm"

; Samples followed by their duration in full note unit
track_menus_square1:
.word theme_menus_square1_intro ; 12
.word theme_menus_square1_chorus_1, theme_menus_square1_chorus_2 ; 12 + 36.5 + 33.5 = 12 + 70 = 82
.word theme_menus_square1_chorus_1, theme_menus_square1_chorus_2 ; 82 + 70 = 152
.word theme_menus_square1_chorus_1, theme_menus_square1_chorus_2 ; 152 + 70 = 222
.word theme_menus_square1_chorus_1, theme_menus_square1_chorus_2 ; 222 + 70 = 292
.word theme_menus_square1_chorus_1 ; 292 + 36.5 = 328.5
MUSIC_END

track_menus_square2:
.word theme_menus_square2_intro ; 17
.word theme_menus_square2_chorus ; 17 + 31 = 48
.word theme_menus_square2_sample1 ; 48 + 32 = 80
.word theme_menus_square2_chorus ; 80 + 31 = 111
.word theme_menus_square2_sample2, theme_menus_square2_sample2 ; 111 + 32 = 143
.word theme_menus_square2_sample3, theme_menus_square2_sample3 ; 143 + 32 = 175
.word theme_menus_square2_sample4, theme_menus_square2_sample4 ; 175 + 32 = 207
.word theme_menus_square2_sample5, theme_menus_square2_sample5 ; 207 + 32 = 239
.word theme_menus_square2_sample6, theme_menus_square2_sample6 ; 239 + 32 = 271
.word theme_menus_square2_chorus ; 271 + 31 = 302

.word theme_menus_square2_sync ; 328.5 - 302 = 26.5
MUSIC_END

track_menus_triangle:
.word theme_menus_square2_sync ; Hack, the engine needs at least a valid sample, even for muted tracks
MUSIC_END

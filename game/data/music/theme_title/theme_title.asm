music_theme_title_begin:
#include "game/data/music/theme_title/samples_square1.asm"
#include "game/data/music/theme_title/samples_square2.asm"
#include "game/data/music/theme_title/samples_triangle.asm"

track_title_info:
.word track_title_square1
.word track_title_square2
.word track_title_triangle
.word track_title_noise

track_title_noise:
.word noise_sample_1
.word noise_sample_2
MUSIC_END

noise_sample_1:
AUDIO_NOISE_PITCH_SLIDE_UP(1)
AUDIO_NOISE_PLAY_TIMED_FREQ(15, 15)
SAMPLE_END

noise_sample_2:
AUDIO_NOISE_PITCH_SLIDE_DOWN(1)
AUDIO_NOISE_WAIT(14)
SAMPLE_END

halt_sample:
HALT(7)
SAMPLE_END

track_title_square1:
.word halt_sample
MUSIC_END
.word sample_1
.word sample_2
.word sample_3
.word sample_4
.word sample_5
.word sample_6
.word sample_7
.word sample_8
.word sample_9
.word sample_10
.word sample_11
.word sample_12
.word sample_13
.word sample_14
.word sample_15
.word sample_16
.word sample_17
MUSIC_END

track_title_square2:
.word halt_sample
MUSIC_END
.word square2_sample_1
.word square2_sample_2
.word square2_sample_3
.word square2_sample_4
.word square2_sample_5
.word square2_sample_6
.word square2_sample_7
.word square2_sample_8
.word square2_sample_9
.word square2_sample_10
.word square2_sample_11
.word square2_sample_12
.word square2_sample_13
.word square2_sample_14
.word square2_sample_15
.word square2_sample_16
.word square2_sample_17
MUSIC_END

track_title_triangle:
.word halt_sample
MUSIC_END
.word triangle_sample_1
.word triangle_sample_2
.word triangle_sample_3
.word triangle_sample_4
.word triangle_sample_5
.word triangle_sample_6
.word triangle_sample_7
.word triangle_sample_8
.word triangle_sample_9
.word triangle_sample_10
.word triangle_sample_11
.word triangle_sample_12
.word triangle_sample_13
.word triangle_sample_14
.word triangle_sample_15
.word triangle_sample_16
.word triangle_sample_17
MUSIC_END

#echo
#echo theme title size:
#print *-music_theme_title_begin

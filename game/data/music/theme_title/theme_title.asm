#include "game/data/music/theme_title/samples_square1.asm"
#include "game/data/music/theme_title/samples_square2.asm"

track_title_info:
.word track_title_square1
.word track_title_square2
.word track_title_triangle

track_title_square1:
.word mute_sample
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
.word mute_sample
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
.word triangle_sample
MUSIC_END

mute_sample:
HALT(7)
MUSIC_END

triangle_sample:
.(
    LONG_WAIT(20)
    PITCH_SLIDE(3)
    WAIT(2)
    PITCH_SLIDE(-3)
    WAIT(4)
    PITCH_SLIDE(3)
    WAIT(4)
    PITCH_SLIDE(-3)
    WAIT(4)
    PITCH_SLIDE(3)
    WAIT(1)
    PITCH_SLIDE(0)
    HALT(7)
    WAIT(1)
    PLAY_NOTE(1,1,41)
    PITCH_SLIDE(-56)
    WAIT(1)
    PITCH_SLIDE(0)
    PLAY_TIMED_FREQ(176,8)
    PLAY_NOTE(1,1,48)
    PITCH_SLIDE(6)
    LONG_WAIT(10)
    PITCH_SLIDE(0)
    PLAY_TIMED_FREQ(235,13)
    PLAY_NOTE(0,1,44)
    PLAY_TIMED_FREQ(264,3)
    PLAY_NOTE(0,1,42)
    PLAY_NOTE(1,2,41)
    HALT(2)
    PLAY_TIMED_FREQ(264,12)
    PLAY_TIMED_FREQ(235,15)
    SAMPLE_END
.)

track_gameover_square1:
.word theme_gameover_square_sample1
MUSIC_END

track_gameover_square2:
.word theme_gameover_square_sample2
MUSIC_END

track_gameover_triangle:
.word theme_gameover_triangle_sample1
MUSIC_END

theme_gameover_square_sample1:
; 00
TIMED_O2_G(22)
TIMED_O3_C(10)
TIMED_O3_E(4)
TIMED_O3_E(4)
TIMED_O3_E(10)
TIMED_O3_C(10)
TIMED_O2_G(10)
TIMED_O3_C(10)

TIMED_O3_F(22)
TIMED_O3_F(10)
TIMED_O3_E(4)
TIMED_O3_E(4)

TIMED_O3_E(10)
TIMED_O3_C(10)
TIMED_O2_G(10)
TIMED_O3_C(9)
SAMPLE_END

theme_gameover_square_sample2:
; 00
TIMED_O3_C(22)
TIMED_O3_E(10)
TIMED_O3_G(4)
TIMED_O3_G(4)
TIMED_O3_G(10)
TIMED_O3_E(10)
TIMED_O3_D(10)
TIMED_O3_E(10)

TIMED_O3_A(22)
TIMED_O3_A(10)
TIMED_O3_G(4)
TIMED_O3_G(4)

TIMED_O3_G(10)
TIMED_O3_E(10)
TIMED_O3_D(10)
TIMED_O3_D(9)
SAMPLE_END

theme_gameover_triangle_sample1:
; 00
TIMED_O2_B(31)
TIMED_O2_B(31)
TIMED_O2_B(30)
AUDIO_SILENCE(0)
TIMED_O2_F(31)
TIMED_O2_F(14)
AUDIO_SILENCE(0)
TIMED_O2_G(31)
TIMED_O2_G(14)
AUDIO_SILENCE(0)
SAMPLE_END

#ifdef FULL_NOTE
#undef FULL_NOTE
#undef HALF_NOTE
#undef QUARTER_NOTE
#endif
#DEFINE FULL_NOTE 20
#DEFINE HALF_NOTE 10
#DEFINE QUARTER_NOTE 5

music_gameover_info:
.word track_gameover_square1
.word track_gameover_square2
.word music_gameover_triangle
.word music_gameover_noise

music_gameover_sample_noise_halt:
AUDIO_NOISE_HALT(7)
SAMPLE_END

music_gameover_noise:
.word music_gameover_sample_noise_halt
MUSIC_END

music_gameover_sample_triangle_halt:
HALT(7)
SAMPLE_END

music_gameover_triangle:
.word music_gameover_sample_triangle_halt
MUSIC_END

#include "game/data/music/theme_gameover/samples_square1.asm"
#include "game/data/music/theme_gameover/samples_square2.asm"

track_gameover_square1:
.word theme_gameover_square1_intro
.word theme_gameover_square1_chorus
.word theme_gameover_square1_chorus
.word theme_gameover_square1_verse1
.word theme_gameover_square1_chorus
MUSIC_END

track_gameover_square2:
.word theme_gameover_square2_intro
.word theme_gameover_square2_chorus
.word theme_gameover_square2_chorus
.word theme_gameover_square2_verse1
.word theme_gameover_square2_chorus
MUSIC_END

track_gameover_triangle:
.word theme_gameover_square2_chorus ; Hack, the engine needs at least a valid sample, even for muted tracks
MUSIC_END

#echo
#echo music_gameover_size:
#print *-music_gameover_info

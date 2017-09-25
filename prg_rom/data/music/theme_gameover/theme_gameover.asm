#ifdef FULL_NOTE
#undef FULL_NOTE
#undef HALF_NOTE
#undef QUARTER_NOTE
#endif
#DEFINE FULL_NOTE 20
#DEFINE HALF_NOTE 10
#DEFINE QUARTER_NOTE 5

#include "prg_rom/data/music/theme_gameover/samples_square1.asm"
#include "prg_rom/data/music/theme_gameover/samples_square2.asm"

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

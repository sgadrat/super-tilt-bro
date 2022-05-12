.(
+STAGE_ARCADE_BTT02_BANK_NUMBER = CURRENT_BANK_NUMBER

+stage_arcade_btt02_data_header:
ARCADE_TARGET($52, $5a)
ARCADE_TARGET($c4, $63)
ARCADE_TARGET($cd, $ad)
ARCADE_TARGET($9b, $23)
ARCADE_TARGET($70, $97)
ARCADE_TARGET($c8, $37)
ARCADE_TARGET($fe, $fe)
ARCADE_TARGET($fe, $fe)
ARCADE_TARGET($fe, $fe)
ARCADE_TARGET($fe, $fe)
+stage_arcade_btt02_data:
STAGE_HEADER($2000, $8000, $6fff, $8000, $8000, $8000) ; player_a_x, player_b_x, player_a_y, player_b_y, respawn_x, respawn_y
stage_arcade_btt02_platforms:
STAGE_BUMPER($58, $78, $2f, $57, $06, $0200, $00, $01, $01) ; left, right, top, bot, damages, base, force, horizontal_direction, vertical_direction
PLATFORM($80, $b8, $47, $5f) ; left, right, top, bot
PLATFORM($d0, $e8, $47, $9f) ; left, right, top, bot
PLATFORM($a0, $b8, $4f, $9f) ; left, right, top, bot
PLATFORM($01, $40, $6f, $8f) ; left, right, top, bot
SMOOTH_PLATFORM($18, $50, $3f) ; left, right, top
SMOOTH_PLATFORM($b0, $d8, $87) ; left, right, top
SMOOTH_PLATFORM($28, $88, $a7) ; left, right, top
END_OF_STAGE
circle_target_path:
.byt 8 ; number of waypoints
.byt $10, $0c, $10, $00, $f0, $f4, $f0, $00 ; velocity H
.byt $f8, $00, $08, $10, $08, $00, $f8, $f0 ; velocity V
.byt $40, $7c, $bc, $bc, $7c, $40, $00, $00 ; waypoint's end position X
.byt $00, $00, $20, $a0, $c0, $c0, $a0, $20 ; waypoint's end position Y
#if * - circle_target_path > 256
#error waypoints list too big
#endif

top_target_path:
.byt 2 ; number of waypoints
.byt $fe, $02 ; velocity H
.byt $00, $00 ; velocity V
.byt $00, $e0 ; waypoint's end position X
.byt $00, $00 ; waypoint's end position Y
#if * - top_target_path > 256
#error waypoints list too big
#endif

bot_target_path:
.byt 7 ; number of waypoints
.byt $00, $fc, $fc, $fc, $00, $fc, $06 ; velocity H
.byt $fc, $fc, $00, $04, $04, $00, $01 ; velocity V
.byt $f0, $dc, $c0, $ac, $ac, $00, $f0 ; waypoint's end position X
.byt $14, $00, $00, $14, $78, $78, $a0 ; waypoint's end position Y
#if * - bot_target_path > 256
#error waypoints list too big
#endif


#include "game/data/stages/arcade/btt02/screen.asm"
#include "game/data/stages/arcade/btt02/logic.asm"
.)

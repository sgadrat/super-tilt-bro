stage_pit_data:
STAGE_HEADER($1800, $e000, $80ff, $80ff, $1800, $5800) ; player_a_x, player_b_x, player_a_y, player_b_y, respawn_x, respawn_y
stage_pit_platforms:
PLATFORM($01, $3f, $81, $ff) ; left, right, top, bot
PLATFORM($b9, $fe, $81, $ff) ; left, right, top, bot
SMOOTH_PLATFORM($49, $6f, $93) ; left, right, top
SMOOTH_PLATFORM($89, $af, $b3) ; left, right, top
END_OF_STAGE

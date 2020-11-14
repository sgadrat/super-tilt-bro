stage_pit_data:
STAGE_HEADER($1800, $e000, $80ff, $80ff, $8000, $3000) ; player_a_x, player_b_x, player_a_y, player_b_y, respawn_x, respawn_y
OOS_PLATFORM($ffe1, $0040, $0080, $0100) ; left, right, top, bot
OOS_PLATFORM($00b8, $0121, $0080, $0100) ; left, right, top, bot
SMOOTH_PLATFORM($49, $6f, $89) ; left, right, top
SMOOTH_PLATFORM($89, $af, $89) ; left, right, top
END_OF_STAGE

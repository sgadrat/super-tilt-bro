#define STAGE_HEADER(player_a_x,player_b_x,player_a_y,player_b_y,respawn_x,respawn_y) .byt <player_a_x, <player_b_x, >player_a_x, >player_b_x, <player_a_y, <player_b_y, >player_a_y, >player_b_y, <respawn_x, >respawn_x, <respawn_y, >respawn_y
#define PLATFORM(left,right,top,bot) .byt STAGE_ELEMENT_PLATFORM, left, right, top, bot
#define SMOOTH_PLATFORM(left,right,top) .byt STAGE_ELEMENT_SMOOTH_PLATFORM, left, right, top
#define END_OF_STAGE .byt STAGE_ELEMENT_END

#define STAGE_BLAST_LEFT $ffe0
#define STAGE_BLAST_RIGHT $0120
#define STAGE_BLAST_TOP $ffe0
#define STAGE_BLAST_BOTTOM $00ff

#define STAGE_COUNT 4

#define RAW_VECTOR(x) .byt <x, >x

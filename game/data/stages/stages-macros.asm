#define STAGE_HEADER(player_a_x,player_b_x,player_a_y,player_b_y,respawn_x,respawn_y) .byt <player_a_x, <player_b_x, >player_a_x, >player_b_x, <player_a_y, <player_b_y, >player_a_y, >player_b_y, <respawn_x, >respawn_x, <respawn_y, >respawn_y
#define PLATFORM(left,right,top,bot)        .byt STAGE_ELEMENT_PLATFORM,            left,  right, top,     bot,   0,    0,    0,    0
#define SMOOTH_PLATFORM(left,right,top)     .byt STAGE_ELEMENT_SMOOTH_PLATFORM,     left,  right, top,     0,     0,    0,    0,    0
#define OOS_PLATFORM(left,right,top,bot)    .byt STAGE_ELEMENT_OOS_PLATFORM,        <left, >left, <right, >right, <top, >top, <bot, >bot
#define OOS_SMOOTH_PLATFORM(left,right,top) .byt STAGE_ELEMENT_OOS_SMOOTH_PLATFORM, <left, >left, <right, >right, <top, >top, 0,    0
#define END_OF_STAGE .byt STAGE_ELEMENT_END

#if STAGE_ELEMENT_SIZE <> 9
#error definitions above expects 9 bytes per stage element
#endif

#define STAGE_BLAST_LEFT $ffe0
#define STAGE_BLAST_RIGHT $0120
#define STAGE_BLAST_TOP $ffe0
#define STAGE_BLAST_BOTTOM $00ff

#define STAGE_COUNT 4

#define RAW_VECTOR(x) .byt <x, >x

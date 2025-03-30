#define STAGE_HEADER(player_a_x,player_b_x,player_a_y,player_b_y,respawn_x,respawn_y) \
	.byt <player_a_x, <player_b_x, >player_a_x, >player_b_x, <player_a_y, <player_b_y, >player_a_y, >player_b_y, <respawn_x, >respawn_x, <respawn_y, >respawn_y
#define PLATFORM(left,right,top,bot) \
	.byt STAGE_ELEMENT_PLATFORM,            left,  right, top,     bot,   0,       0,     0,     0
#define SMOOTH_PLATFORM(left,right,top) \
	.byt STAGE_ELEMENT_SMOOTH_PLATFORM,     left,  right, top,     0,     0,       0,     0,     0
#define OOS_PLATFORM(left,right,top,bot) \
	.byt STAGE_ELEMENT_OOS_PLATFORM,        <left, >left, <right, >right, <top,    >top,  <bot,  >bot
#define OOS_SMOOTH_PLATFORM(left,right,top) \
	.byt STAGE_ELEMENT_OOS_SMOOTH_PLATFORM, <left, >left, <right, >right, <top,    >top,  0,     0

; base is a 16 bits unsigned value, always under $8000
; force is a 8 bits unsigned value, always under $80
; damages byte layout - HVhvDDDD
;      H - horizontal knockback sign
;      V - vertical knockback sign
;      h - disable horizontal knockback on top/bottom edges
;      v - disable vertical knockback on left/right edges
;   DDDD - dammages
#define STAGE_BUMPER(left,right,top,bot,damages,base,force,horiz,vertical) \
	.byt \
	STAGE_ELEMENT_BUMPER, \
	left, right, top, bot, \
	((horiz & 1) << 7) + ((vertical & 1) << 6) + (((horiz >> 1) & 1) << 5) + (((vertical >> 1) & 1) << 4) + damages, \
	<base, >base, force

#define END_OF_STAGE .byt STAGE_ELEMENT_END

#if STAGE_ELEMENT_SIZE <> 9
#error definitions above expects 9 bytes per stage element
#endif

#define STAGE_BLAST_LEFT -$0020
#define STAGE_BLAST_RIGHT $0120
#define STAGE_BLAST_TOP -$0020
#define STAGE_BLAST_BOTTOM $00ff

#define STAGE_COUNT 4

#define RAW_VECTOR(x) .word x

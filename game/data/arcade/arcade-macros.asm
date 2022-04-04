#define ARCADE_EXIT(left,right,top,bot) .byt <left, >left, <right, >right, <top, >top, <bot, >bot
#define ARCADE_TARGET(left,top) .byt left, top

ARCADE_FIRST_TILE = $c0

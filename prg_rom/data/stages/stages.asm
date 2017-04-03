#define PLATFORM(left,right,top,bot) .byt $01, left, right, top, bot
#define END_OF_STAGE .byt $00

#include "prg_rom/data/stages/plateau.asm"

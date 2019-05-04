#define STAGE_HEADER(player_a_x,player_b_x,player_a_y,player_b_y,respawn_x,respawn_y) .byt <player_a_x, <player_b_x, >player_a_x, >player_b_x, <player_a_y, <player_b_y, >player_a_y, >player_b_y, <respawn_x, >respawn_x, <respawn_y, >respawn_y
#define PLATFORM(left,right,top,bot) .byt $01, left, right, top, bot
#define SMOOTH_PLATFORM(left,right,top) .byt $02, left, right, top
#define END_OF_STAGE .byt $00

#define STAGE_BLAST_LEFT $ffe0
#define STAGE_BLAST_RIGHT $0120
#define STAGE_BLAST_TOP $ffe0
#define STAGE_BLAST_BOTTOM $00ff

#include "game/data/stages/pit.asm"
#include "game/data/stages/plateau.asm"
#include "game/data/stages/shelf.asm"
#include "game/data/stages/gem.asm"

#define RAW_VECTOR(x) .byt <x, >x
stages_init_routine:
RAW_VECTOR(stage_generic_init) ; Plateau
RAW_VECTOR(stage_pit_init) ; Pit
RAW_VECTOR(stage_generic_init) ; Shelf
RAW_VECTOR(stage_gem_init) ; Gem

stages_tick_routine:
RAW_VECTOR(dummy_routine) ; Plateau
RAW_VECTOR(stage_pit_tick) ; Pit
RAW_VECTOR(dummy_routine) ; Shelf
RAW_VECTOR(stage_gem_tick) ; Gem

stages_nametable:
RAW_VECTOR(nametable) ; Plateau
RAW_VECTOR(nametable_stage_pit) ; Pit
RAW_VECTOR(nametable_stage_shelf) ; Shelf
RAW_VECTOR(nametable_stage_gem) ; Gem

stages_data:
RAW_VECTOR(stage_plateau_data) ; Plateau
RAW_VECTOR(stage_pit_data) ; Pit
RAW_VECTOR(stage_shelf_data) ; Shelf
RAW_VECTOR(stage_gem_data) ; Gem

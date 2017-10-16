#define STAGE_HEADER(player_a_x,player_b_x,player_a_y,player_b_y,respawn_x,respawn_y) .byt <player_a_x, <player_b_x, >player_a_x, >player_b_x, <player_a_y, <player_b_y, >player_a_y, >player_b_y, <respawn_x, >respawn_x, <respawn_y, >respawn_y
#define PLATFORM(left,right,top,bot) .byt $01, left, right, top, bot
#define SMOOTH_PLATFORM(left,right,top) .byt $02, left, right, top
#define END_OF_STAGE .byt $00

#include "prg_rom/data/stages/pit.asm"
#include "prg_rom/data/stages/plateau.asm"
#include "prg_rom/data/stages/shelf.asm"

#define RAW_VECTOR(x) .byt <x, >x
stages_init_routine:
RAW_VECTOR(stage_generic_init) ; Plateau
RAW_VECTOR(stage_pit_init) ; Pit
RAW_VECTOR(stage_generic_init) ; Shelf

stages_tick_routine:
RAW_VECTOR(dummy_routine) ; Plateau
RAW_VECTOR(stage_pit_tick) ; Pit
RAW_VECTOR(dummy_routine) ; Shelf

stages_nametable:
RAW_VECTOR(nametable) ; Plateau
RAW_VECTOR(nametable_stage_pit) ; Pit
RAW_VECTOR(nametable_stage_shelf) ; Shelf

stages_data:
RAW_VECTOR(stage_plateau_data) ; Plateau
RAW_VECTOR(stage_pit_data) ; Pit
RAW_VECTOR(stage_shelf_data) ; Shelf

; Deactivate all particle handlers
particle_handlers_reinit:
.(
; Deactivate directional indicator
lda #0
sta directional_indicator_player_a_counter
sta directional_indicator_player_b_counter

; Deactivate death particles
lda #12
sta death_particles_player_a_counter
sta death_particles_player_b_counter

; Deactivate particle blocks
lda #<deactivate_particle_block
sta tmpfield1
lda #>deactivate_particle_block
sta tmpfield2
jsr loop_on_particle_boxes

rts
.)

; Call a subroutine for each block
;  tmpfield1, tmpfield2 - adress of the subroutine to call
;
;  For each call, Y is the offset of the block's first byte from particle_blocks
loop_on_particle_boxes:
.(
action = tmpfield1

ldy #0
loop:
jsr call_pointed_subroutine
tya
clc
adc #PARTICLE_BLOCK_SIZE
tay
cmp #PARTICLE_NB_BLOCKS * PARTICLE_BLOCK_SIZE
bne loop

rts
.)

; Call a subroutine for each particle in a block
;  tmpfield1, tmpfield2 - adress of the subroutine to call
;  Y - offset of the block's first byte from particle_blocks
;
;  For each call, Y is the offset of the particle's first byte and
;  tmpfield3 is the particle number (from 1)
loop_on_particles:
.(
action = tmpfield1
particle_counter = tmpfield3

lda #0                           ;
sta particle_counter             ;
next_particle:                   ;
lda particle_counter             ; Loop on each particle position
cmp #PARTICLE_BLOCK_NB_PARTICLES ;
beq end                          ;
inc particle_counter             ;

iny ;
iny ; Y points on the current particle
iny ;
iny ;

jsr call_pointed_subroutine

jmp next_particle
end:
rts
.)

; Deactivate the particle block begining at "particle_blocks, y"
deactivate_particle_block:
.(
lda #0
sta particle_blocks+PARTICLE_BLOCK_OFFSET_PARAM, y
rts
.)

; Hide all particles in the block begining at "particle_blocks, y"
hide_particles:
.(
lda #<hide_one_particle
sta tmpfield1
lda #>hide_one_particle
sta tmpfield2
jsr loop_on_particles
rts

hide_one_particle:
.(
lda #$fe                                              ;
sta particle_blocks+PARTICLE_POSITION_OFFSET_X_MSB, y ; Move the particle out of screen
sta particle_blocks+PARTICLE_POSITION_OFFSET_Y_MSB, y ;
rts
.)
.)

; Start directional indicator particles for a player
;  X - player number
;
; Uses particle box number 0 for player A or 1 for player B
; Deactivate any particle handler on the same box
particle_directional_indicator_start:
.(
; Initialize handler state
lda #10
sta directional_indicator_player_a_counter, x
lda player_a_velocity_v_low, x
sta directional_indicator_player_a_direction_y_low, x
lda player_a_velocity_v, x
sta directional_indicator_player_a_direction_y_high, x
lda player_a_velocity_h_low, x
sta directional_indicator_player_a_direction_x_low, x
lda player_a_velocity_h, x
sta directional_indicator_player_a_direction_x_high, x

; Deactivate death particles
lda #12
sta death_particles_player_a_counter, x

; Initialize particles
txa ;
asl ;
asl ;
asl ; Y points on the particle box of the player
asl ;
asl ;
tay ;

lda #1                                                ;
sta particle_blocks+PARTICLE_BLOCK_OFFSET_PARAM, y    ;
lda #TILE_BLOOD_PARTICLE                              ;
sta particle_blocks+PARTICLE_BLOCK_OFFSET_TILENUM, y  ; Box header
txa                                                   ;
asl                                                   ;
sta particle_blocks+PARTICLE_BLOCK_OFFSET_TILEATTR, y ;

lda #<set_particle_position ;
sta tmpfield1               ;
lda #>set_particle_position ; Set particles initial position
sta tmpfield2               ;
jsr loop_on_particles       ;

rts

set_particle_position:
.(
; Position all particles on the player
lda player_a_x_low, x
sta particle_blocks+PARTICLE_POSITION_OFFSET_X_LSB, y
lda player_a_x, x
sta particle_blocks+PARTICLE_POSITION_OFFSET_X_MSB, y
lda player_a_y_low, x
sta particle_blocks+PARTICLE_POSITION_OFFSET_Y_LSB, y
lda player_a_y, x
sta particle_blocks+PARTICLE_POSITION_OFFSET_Y_MSB, y
rts
.)
.)

; Move directional indicator particles of a player
;  X - player number
particle_directional_indicator_tick:
.(
; Avoid doing anything if not activated (counter at zero)
lda directional_indicator_player_a_counter, x
bne do_something
rts
do_something:

; Decrement counter
dec directional_indicator_player_a_counter, x

; Y points on the particle box of the player
txa
asl
asl
asl
asl
asl
tay

; Chose what to do depending on the counter
lda directional_indicator_player_a_counter, x
beq go_disable_box
cmp #1
bne move_particles
jmp hide_particles
go_disable_box:
jmp deactivate_particle_block

move_particles:
.(
particle_y_direction_low = tmpfield4
particle_y_direction_high = tmpfield5

lda #<move_one_particle
sta tmpfield1
lda #>move_one_particle
sta tmpfield2
jsr loop_on_particles

rts

move_one_particle:
.(
particle_counter = tmpfield3

lda directional_indicator_player_a_direction_x_low, x  ;
clc                                                    ;
adc particle_blocks+PARTICLE_POSITION_OFFSET_X_LSB, y  ;
sta particle_blocks+PARTICLE_POSITION_OFFSET_X_LSB, y  ; Apply horizontal velocity
lda directional_indicator_player_a_direction_x_high, x ;
adc particle_blocks+PARTICLE_POSITION_OFFSET_X_MSB, y  ;
sta particle_blocks+PARTICLE_POSITION_OFFSET_X_MSB, y  ;

lda directional_indicator_player_a_direction_y_low, x  ;
sta particle_y_direction_low                           ;
lda directional_indicator_player_a_counter, x          ;
cmp #6                                                 ;
bpl separate                                           ;
lda directional_indicator_player_a_direction_y_high, x ; Modify vertical velocity depending on particle number
jmp set_y_direction                                    ;
separate:                                              ;
lda particle_counter                                   ;
clc                                                    ;
adc directional_indicator_player_a_direction_y_high, x ;
set_y_direction:                                       ;
sta particle_y_direction_high                          ;

lda particle_y_direction_low                           ;
clc                                                    ;
adc particle_blocks+PARTICLE_POSITION_OFFSET_Y_LSB, y  ;
sta particle_blocks+PARTICLE_POSITION_OFFSET_Y_LSB, y  ; Apply vertical velocity
lda particle_y_direction_high                          ;
adc particle_blocks+PARTICLE_POSITION_OFFSET_Y_MSB, y  ;
sta particle_blocks+PARTICLE_POSITION_OFFSET_Y_MSB, y  ;
rts
.)
.)
.)

; Start death particles for a player
;  X - player number
;  tmpfield1 - player X position before death
;  tmpfield2 - player Y position before death
;
; Uses particle box number 0 for player A or 1 for player B
; Deactivate any particle handler on the same box
particle_death_start:
.(
position_x_param = tmpfield1
position_y_param = tmpfield2
; tmpfiel3 used by loop on particles
orientation_x = tmpfield4
orientation_y = tmpfield5
position_x_store = tmpfield6
position_y_store = tmpfield7

; Initialize handler's state
lda #0
sta death_particles_player_a_counter, x

; Deactivate directional indicator in the same box
sta directional_indicator_player_a_counter, x

; Store position to unused space
lda position_x_param
sta position_x_store
lda position_y_param
sta position_y_store

; Compute particles orientation
lda player_a_velocity_h, x
eor #%11111111
clc
adc #$01
sta orientation_x

lda player_a_velocity_v, x
eor #%11111111
clc
adc #$01
sta orientation_y

; Initialize particles
txa    ;
clc    ;
asl    ;
asl    ;
asl    ; Y points on the particle box of the player
asl    ;
asl    ;
tay    ;

lda #1                                                ;
sta particle_blocks+PARTICLE_BLOCK_OFFSET_PARAM, y    ;
lda #TILE_EXPLOSION_1                                 ;
sta particle_blocks+PARTICLE_BLOCK_OFFSET_TILENUM, y  ; Box header
txa                                                   ;
asl                                                   ;
sta particle_blocks+PARTICLE_BLOCK_OFFSET_TILEATTR, y ;

lda #<place_one_particle ;
sta tmpfield1            ;
lda #>place_one_particle ; Particles position
sta tmpfield2            ;
jsr loop_on_particles    ;

rts

place_one_particle:
.(
particle_counter = tmpfield3
position_x = position_x_store
position_y = position_y_store

lda #0                                                ;
sta particle_blocks+PARTICLE_POSITION_OFFSET_X_LSB, y ; Set position LSBs to zero
sta particle_blocks+PARTICLE_POSITION_OFFSET_Y_LSB, y ;

lda position_x                                        ;
cmp #248                                              ;
bcc no_reposition_x                                   ; Set particle's horizontal position
lda #248                                              ;
no_reposition_x:                                      ;
sta particle_blocks+PARTICLE_POSITION_OFFSET_X_MSB, y ;

clc               ;
adc orientation_x ;
clc               ; Compute next particle's horizontal position
adc orientation_x ;
sta position_x    ;

lda position_y                                        ;
cmp #232                                              ;
bcc no_reposition_y                                   ; Set particle's vertical position
lda #232                                              ;
no_reposition_y:                                      ;
sta particle_blocks+PARTICLE_POSITION_OFFSET_Y_MSB, y ;

clc               ;
adc orientation_y ;
clc               ; Compute next particle's vertical position
adc orientation_y ;
sta position_y    ;

txa                                                   ;
pha                                                   ;
lda particle_counter                                  ;
tax                                                   ;
dex                                                   ;
lda particle_blocks+PARTICLE_POSITION_OFFSET_X_MSB, y ;
clc                                                   ;
adc particles_start_position_offset_x, x              ; Apply particle's offset position
sta particle_blocks+PARTICLE_POSITION_OFFSET_X_MSB, y ;
lda particle_blocks+PARTICLE_POSITION_OFFSET_Y_MSB, y ;
clc                                                   ;
adc particles_start_position_offset_y, x              ;
sta particle_blocks+PARTICLE_POSITION_OFFSET_Y_MSB, y ;
pla                                                   ;
tax                                                   ;

rts

particles_start_position_offset_x:
.byt $00, $fc, $fc, $00, $00, $04, $04
particles_start_position_offset_y:
.byt $00, $fc, $04, $f8, $08, $fc, $04
.)
.)

; Update death particles of a player
;  X - player number
particle_death_tick:
.(
particle_counter = tmpfield1

; Do nothing if deactivated
lda death_particles_player_a_counter, x
cmp #12
beq do_nothing

; Y points on the particle box of the player
txa
clc
asl
asl
asl
asl
asl
tay

; Choose what to do depending on counter
lda death_particles_player_a_counter, x
cmp #10
beq go_hide_particles
cmp #11
beq go_disable_box

; Update particles tile to animate the explosion
lsr
clc
adc #TILE_EXPLOSION_1
sta particle_blocks+PARTICLE_BLOCK_OFFSET_TILENUM, y

end:
inc death_particles_player_a_counter, x
do_nothing:
rts

go_hide_particles:
.(
jsr hide_particles
jmp end
.)

go_disable_box:
.(
jsr deactivate_particle_block
jmp end
.)
.)

; Start directional indicator particles for a player
;  X - player number
;
; Uses particle box number 0 for player A or 1 for player B
particle_directional_indicator_start:
.(
particle_counter = tmpfield1

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

lda player_a_x_low, x                                 ;
sta particle_blocks+PARTICLE_POSITION_OFFSET_X_LSB, y ;
lda player_a_x, x                                     ;
sta particle_blocks+PARTICLE_POSITION_OFFSET_X_MSB, y ;
lda player_a_y_low, x                                 ; Set particle's initial position
sta particle_blocks+PARTICLE_POSITION_OFFSET_Y_LSB, y ;
lda player_a_y, x                                     ;
sta particle_blocks+PARTICLE_POSITION_OFFSET_Y_MSB, y ;

jmp next_particle

end:
rts
.)

; Move directional indicator particles of a player
;  X - player number
particle_directional_indicator_tick:
.(
particle_counter = tmpfield1

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
jmp disable_box

move_particles:
.(
particle_y_direction_low = tmpfield2
particle_y_direction_high = tmpfield3

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


jmp next_particle
end:
rts
.)

hide_particles:
.(
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

lda #$fe                                              ;
sta particle_blocks+PARTICLE_POSITION_OFFSET_X_MSB, y ; Move the particle out of screen
sta particle_blocks+PARTICLE_POSITION_OFFSET_Y_MSB, y ;

jmp next_particle
end:
rts
.)

disable_box:
.(
lda #0
sta particle_blocks+PARTICLE_BLOCK_OFFSET_PARAM, y
rts
.)
.)

; Start death particles for a player
;  X - player number
;  tmpfield1 - player X position before death
;  tmpfield2 - player Y position before death
;
; Uses particle box number 2 for player A or 3 for player B
particle_death_start:
.(
position_x = tmpfield1
position_y = tmpfield2
orientation_x = tmpfield3
orientation_y = tmpfield4
particle_counter = tmpfield5

; Initialize handler's state
lda #0
sta death_particles_player_a_counter, x

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
adc #2 ;
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
lda particle_blocks+PARTICLE_POSITION_OFFSET_X_MSB, y ; Apply particle's offset position
clc                                                   ;
adc particles_start_position_offset_x, x              ;
sta particle_blocks+PARTICLE_POSITION_OFFSET_X_MSB, y ;
lda particle_blocks+PARTICLE_POSITION_OFFSET_Y_MSB, y ;
clc                                                   ;
adc particles_start_position_offset_y, x              ;
sta particle_blocks+PARTICLE_POSITION_OFFSET_Y_MSB, y ;
pla
tax

jmp next_particle
end:

rts

particles_start_position_offset_x:
.byt $00, $fc, $fc, $00, $00, $04, $04
particles_start_position_offset_y:
.byt $00, $fc, $04, $f8, $08, $fc, $04
.)

; Update death particles of a player
;  X - player number
particle_death_tick:
.(
particle_counter = tmpfield1

lda death_particles_player_a_counter, x
cmp #12
beq do_nothing

txa    ;
clc    ;
adc #2 ;
asl    ;
asl    ;
asl    ; Y points on the particle box of the player
asl    ;
asl    ;
tay    ;

lda death_particles_player_a_counter, x
cmp #10
beq hide_particles
cmp #11
beq disable_box

lsr
clc
adc #TILE_EXPLOSION_1
sta particle_blocks+PARTICLE_BLOCK_OFFSET_TILENUM, y

end:
inc death_particles_player_a_counter, x
do_nothing:
rts

hide_particles:
.(
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

lda #$fe                                              ;
sta particle_blocks+PARTICLE_POSITION_OFFSET_X_MSB, y ; Move the particle out of screen
sta particle_blocks+PARTICLE_POSITION_OFFSET_Y_MSB, y ;

jmp next_particle
.)

disable_box:
.(
lda #0
sta particle_blocks+PARTICLE_BLOCK_OFFSET_PARAM, y
jmp end
.)
.)

start_standing_player:
.(
; Set the appropriate animation (depending on player's direction)
lda player_a_direction, x
beq set_anim_left

txa ;
asl ; X = X * 2 (we use it to reference a 2 bytes field)
tax ;

lda #<anim_sinbad_idle_right
sta player_a_animation, x
lda #>anim_sinbad_idle_right
inx
sta player_a_animation, x
dex

jmp reset_anim_clock

set_anim_left:

txa ;
asl ; X = X * 2 (we use it to reference a 2 bytes field)
tax ;

lda #<anim_sinbad_idle_left
sta player_a_animation, x
lda #>anim_sinbad_idle_left
inx
sta player_a_animation, x
dex

reset_anim_clock:

txa ;
lsr ; Reset X to it's original value
tax ;

lda #$00
sta player_a_anim_clock, x

; Set the player's state
lda PLAYER_STATE_STANDING
sta player_a_state, x
rts
.)

; Update a player that is standing on ground
;  register X must contain the player number
standing_player:
.(
; Set the velocity to zero (do not move anymore)
lda #$00
sta player_a_velocity_v, x
sta player_a_velocity_h, x

; Check left input
lda controller_a_btns, x
cmp CONTROLLER_INPUT_LEFT
bne check_right

; Player is now running left
lda DIRECTION_LEFT
sta player_a_direction, x
jsr start_running_player
jmp end

; Check right input
check_right:
cmp CONTROLLER_INPUT_RIGHT
bne check_jump

; Player is now running right
lda DIRECTION_RIGHT
sta player_a_direction, x
jsr start_running_player
jmp end

; Check jump input
check_jump:
cmp CONTROLLER_INPUT_JUMP
beq jump_input
cmp CONTROLLER_INPUT_JUMP_RIGHT
beq jump_input_right
cmp CONTROLLER_INPUT_JUMP_LEFT
bne check_jab

; Player is now jumping
jump_input_left:
lda DIRECTION_LEFT
sta player_a_direction, x
jmp jump_input
jump_input_right:
lda DIRECTION_RIGHT
sta player_a_direction, x
jump_input:
jsr start_jumping_player
jmp end

; Check jab input
check_jab:
cmp CONTROLLER_INPUT_JAB
bne check_tilt

; Player is now jabbing
jsr start_jabbing_player
jmp end

; Check tilt input
check_tilt:
cmp CONTROLLER_INPUT_ATTACK_RIGHT
beq tilt_input_right
cmp CONTROLLER_INPUT_ATTACK_LEFT
bne end

; Player is now tilting
tilt_input_left:
lda DIRECTION_LEFT
sta player_a_direction, x
jmp tilt_input
tilt_input_right:
lda DIRECTION_RIGHT
sta player_a_direction, x
tilt_input:
jsr start_side_tilt_player

end:
rts
.)

start_running_player:
lda PLAYER_STATE_RUNNING
sta player_a_state, x
set_running_anmation:
.(
; Set the appropriate animation (depending on player's direction)
lda player_a_direction, x
beq set_anim_left

txa ;
asl ; X = X * 2 (we use it to reference a 2 bytes field)
tax ;

lda #<anim_sinbad_run_right
sta player_a_animation, x
lda #>anim_sinbad_run_right
inx
sta player_a_animation, x
dex

jmp reset_anim_clock

set_anim_left:

txa ;
asl ; X = X * 2 (we use it to reference a 2 bytes field)
tax ;

lda #<anim_sinbad_run_left
sta player_a_animation, x
lda #>anim_sinbad_run_left
inx
sta player_a_animation, x
dex

reset_anim_clock:

txa ;
lsr ; Reset X to it's original value
tax ;

lda #$00
sta player_a_anim_clock, x

rts
.)

; Update a player that is running
;  register X must contain the player number
running_player:
.(
; Move the player to the direction he is watching
lda player_a_direction, x
beq run_left

; Running right, velocity tends toward vector (4,0)
lda #$04
sta tmpfield4
lda #$00
sta tmpfield3
sta tmpfield2
sta tmpfield1
lda #$ff
sta tmpfield5
jsr merge_to_player_velocity
jmp check_state_changes

; Running left, velocity tends toward vector (-4,0)
run_left:
lda #$fc
sta tmpfield4
lda #$00
sta tmpfield3
sta tmpfield2
sta tmpfield1
lda #$ff
sta tmpfield5
jsr merge_to_player_velocity

check_state_changes:

; Check left input
lda controller_a_btns, x
cmp CONTROLLER_INPUT_LEFT
bne check_right

; Player is now watching left
lda DIRECTION_LEFT
cmp player_a_direction, x
beq end
sta player_a_direction, x
jsr set_running_anmation
jmp end

; Check right input
check_right:
cmp CONTROLLER_INPUT_RIGHT
bne check_jump

; Player is now watching right
lda DIRECTION_RIGHT
cmp player_a_direction, x
beq end
sta player_a_direction, x
jsr set_running_anmation
jmp end

; Check jump input
check_jump:
cmp CONTROLLER_INPUT_JUMP
beq jump_input
cmp CONTROLLER_INPUT_JUMP_RIGHT
beq jump_input
cmp CONTROLLER_INPUT_JUMP_LEFT
bne check_tilt

; Player is now jumping
jump_input:
jsr start_jumping_player
jmp end

; Check tilt input
check_tilt:
cmp CONTROLLER_INPUT_ATTACK_RIGHT
beq tilt_input_right
cmp CONTROLLER_INPUT_ATTACK_LEFT
bne no_input

; Player is now tilting
tilt_input_left:
lda DIRECTION_LEFT
sta player_a_direction, x
jmp tilt_input
tilt_input_right:
lda DIRECTION_RIGHT
sta player_a_direction, x
tilt_input:
jsr start_side_tilt_player
jmp end

; When no input is handled return to standing state
no_input:
jsr start_standing_player

end:
rts
.)

; Update a player that is falling
;  register X must contain the player number
falling_player:
.(
lda #$00 ; Horizontal component
pha      ; - high
pha      ; - low
lda #$01  ; Vertical component
pha       ; - high
lda #$00  ;
pha       ; - low
jsr add_to_player_velocity
rts
.)

start_jumping_player:
.(
lda #$f7
sta player_a_state_field1, x
lda PLAYER_STATE_JUMPING
sta player_a_state, x
rts
.)

jumping_player:
.(
lda player_a_state_field1, x
beq top_reached

; The top is not reached, add up velocity
sta player_a_velocity_v, x
inc player_a_state_field1, x
jmp end

top_reached:
lda PLAYER_STATE_FALLING
sta player_a_state, x

end:
rts
.)

start_jabbing_player:
lda PLAYER_STATE_JABBING
sta player_a_state, x
set_jabbing_animation:
.(
; Set the appropriate animation (depending on player's direction)
lda player_a_direction, x
beq set_anim_left

txa ;
asl ; X = X * 2 (we use it to reference a 2 bytes field)
tax ;

lda #<anim_sinbad_jab_right
sta player_a_animation, x
lda #>anim_sinbad_jab_right
inx
sta player_a_animation, x
dex

jmp reset_anim_clock

set_anim_left:

txa ;
asl ; X = X * 2 (we use it to reference a 2 bytes field)
tax ;

lda #<anim_sinbad_jab_left
sta player_a_animation, x
lda #>anim_sinbad_jab_left
inx
sta player_a_animation, x
dex

reset_anim_clock:

txa ;
lsr ; Reset X to it's original value
tax ;

lda #$00
sta player_a_anim_clock, x

rts
.)

jabbing_player:
.(
lda player_a_anim_clock, x
cmp ANIM_SINBAD_JAB_DURATION
bne end
jsr start_standing_player

end:
rts
.)

start_thrown_player:
.(
lda PLAYER_STATE_THROWN
sta player_a_state, x
rts
.)

thrown_player:
.(
rts
.)

start_respawn_player:
.(
lda PLAYER_STATE_RESPAWN
sta player_a_state, x
lda RESPAWN_X
sta player_a_x, x
lda RESPAWN_Y
sta player_a_y, x
lda #$00
sta player_a_velocity_h, x
sta player_a_velocity_v, x
sta player_a_damages, x
rts
.)

respawn_player:
.(
rts
.)

start_side_tilt_player:
.(
; Set the appropriate animation (depending on player's direction)
lda player_a_direction, x
beq set_anim_left

txa ;
asl ; X = X * 2 (we use it to reference a 2 bytes field)
tax ;

lda #<anim_sinbad_side_tilt_right
sta player_a_animation, x
lda #>anim_sinbad_side_tilt_right
inx
sta player_a_animation, x
dex

jmp reset_anim_clock

set_anim_left:

txa ;
asl ; X = X * 2 (we use it to reference a 2 bytes field)
tax ;

lda #<anim_sinbad_side_tilt_left
sta player_a_animation, x
lda #>anim_sinbad_side_tilt_left
inx
sta player_a_animation, x
dex

reset_anim_clock:

txa ;
lsr ; Reset X to it's original value
tax ;

lda #$00
sta player_a_anim_clock, x

; Set the player's state
lda PLAYER_STATE_SIDE_TILT
sta player_a_state, x

; Set initial velocity
lda #$fe
sta player_a_velocity_v, x

rts
.)

; Update a player that is performing a side tilt
;  register X must contain the player number
side_tilt_player:
.(
lda player_a_anim_clock, x
cmp ANIM_SINBAD_SIDE_TILT_DURATION
bne update_velocity
jsr start_standing_player
jmp end

update_velocity:
cmp ANIM_SINBAD_SIDE_TILT_JUMP_FRAMES
bcc end
lda #$01
sta tmpfield3
lda #$00
sta tmpfield4
sta tmpfield1
sta tmpfield2
lda #$ff
sta tmpfield5
jsr merge_to_player_velocity

end:
rts
.)

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

; Store the controller state to a known location
;  it is needed to bitmask it, BIT opcode support only absolute addressing
lda controller_a_btns, x
sta tmpfield1

; check left button
lda #%00000010
bit tmpfield1
beq check_right

; Player is now watching left
lda #$00
sta player_a_direction, x

; Player is now running
jsr start_running_player

jmp check_up

; check right button
check_right:
lda #%00000001
bit tmpfield1
beq check_up

; Player is now watching right
lda DIRECTION_RIGHT
sta player_a_direction, x

; Player is now running
jsr start_running_player

; Check up button
check_up:
lda #%00001000
bit tmpfield1
beq check_a
jsr start_jumping_player

check_a:
lda #%10000000
bit tmpfield1
beq end
jsr start_jabbing_player

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
; Set max velocity
lda #$04
sta player_a_max_velocity, x

; Move the player to the direction he is watching
lda player_a_direction, x
beq run_left

; Running right, add vector (1,0) to velocity
lda #$01
pha
lda #$00
pha
jsr merge_player_velocity
jmp check_state_changes

; Running left, add vector (-1,0) to velocity
run_left:
lda #$ff
pha
lda #$00
pha
jsr merge_player_velocity

check_state_changes:

; Store the constroller state to a known location
lda controller_a_btns, x
sta tmpfield1

; check left button
lda #%00000010
bit tmpfield1
beq check_right

; Player is now watching left
lda DIRECTION_LEFT
cmp player_a_direction, x
beq check_up
sta player_a_direction, x
jsr set_running_anmation

jmp check_up

; check right button
check_right:
lda #%00000001
bit tmpfield1
beq check_up

; Player is now watching right
lda DIRECTION_RIGHT
cmp player_a_direction, x
beq check_up
sta player_a_direction, x
jsr set_running_anmation

; Check up button
check_up:
lda #%00001000
bit tmpfield1
beq nothing_pressed
jsr start_jumping_player

jmp end

; When no direction button is pressed, return to standing state
nothing_pressed:
lda #%00001011
bit tmpfield1
bne end
jsr start_standing_player

end:
rts
.)

; Update a player that is falling
;  register X must contain the player number
falling_player:
.(
lda #$00
pha
lda #$01
pha
jsr merge_player_velocity
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

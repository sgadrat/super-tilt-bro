fetch_controllers:
.(
; Fetch controllers state
lda #$01
sta CONTROLLER_A
lda #$00
sta CONTROLLER_A

; x will contain the controller number to fetch (0 or 1)
ldx #$00

fetch_one_controller:

; Reset the controller's byte
lda #$00
sta controller_a_btns, x

; Fetch the controller's byte button by button
ldy #$08
next_btn:
lda CONTROLLER_A, x
lsr
rol controller_a_btns, x
dey
bne next_btn

; Next controller
inx
cpx #$02
bne fetch_one_controller

rts
.)

wait_next_frame:
.(
lda #$01
sta nmi_processing
waiting:
lda nmi_processing
bne waiting
rts
.)

init_game_state:
.(
lda DIRECTION_LEFT
sta player_b_direction

lda DIRECTION_RIGHT
sta player_a_direction

lda #$80
sta player_a_y
sta player_b_y
lda #$40
sta player_a_x
lda #$a0
sta player_b_x

lda #$7f
sta player_a_max_velocity
sta player_b_max_velocity

ldx #$00
jsr start_standing_player
ldx #$01
jsr start_standing_player

rts
.)

update_players:
.(
ldx #$00 ; player number

update_one_player:

; Check state 0 - standing
lda player_a_state, x
bne check_running
jsr standing_player
jmp player_updated

; Check state 1 - running
check_running:
cmp PLAYER_STATE_RUNNING
bne check_falling
jsr running_player
jmp player_updated

; Check state 2 - falling
check_falling:
cmp PLAYER_STATE_FALLING
bne check_jumping
jsr falling_player
jmp player_updated

; Check state 3 - jumping
check_jumping:
cmp PLAYER_STATE_JUMPING
bne player_updated
jsr jumping_player

player_updated:
jsr move_player
jsr check_player_position
inx
cpx #$02
bne update_one_player

rts
.)

move_player:
.(
; Save old position
lda player_a_x, x
sta tmpfield1
lda player_a_y, x
sta tmpfield2

; Apply velocity to position
lda player_a_velocity_h, x
clc
adc player_a_x, x
sta tmpfield3

lda player_a_velocity_v, x
clc
adc player_a_y, x
sta tmpfield4

; Check collisions with stage plaform
lda STAGE_EDGE_LEFT
sta tmpfield5
lda STAGE_EDGE_TOP
sta tmpfield6
lda STAGE_EDGE_RIGHT
sta tmpfield7
lda STAGE_EDGE_BOTTOM
sta tmpfield8

jsr check_collision
lda tmpfield3
sta player_a_x, x
lda tmpfield4
sta player_a_y, x

rts
.)

; Check if a movement collide with an obstacle
;  tmpfield1 - Original position X
;  tmpfield2 - Original position Y
;  tmpfield3 - Final position X
;  tmpfield4 - Final position Y
;  tmpfield5 - Obstacle top-left X
;  tmpfield6 - Obstacle top-left Y
;  tmpfield7 - Obstacle bottom-right X
;  tmpfield8 - Obstacle bottom-right Y
;
; tmpfield3 and tmpfield4 are rewritten with a final position that do not pass through obstacle.
check_collision:
.(
; Better names for labels
orig_x = tmpfield1
orig_y = tmpfield2
final_x = tmpfield3
final_y = tmpfield4
obstacle_left = tmpfield5
obstacle_top = tmpfield6
obstacle_right = tmpfield7
obstacle_bottom = tmpfield8

; Check collision with left edge
lda final_y         ;
cmp obstacle_top    ;
bcc top_edge        ; Skip lateral edges collision checks if
lda obstacle_bottom ; the player is over or under the obstacle
cmp final_y         ;
bcc top_edge        ;

lda obstacle_left   ;
cmp orig_x          ;
bcc right_edge      ; Set final_x to obstacle_left if original position
cmp final_x         ; is on the left of the edge and final position on
bcs right_edge      ; the right of the edge
sta final_x         ;

; Check collision with right edge
right_edge:
lda orig_x
cmp obstacle_right
bcc top_edge
lda obstacle_right
cmp final_x
bcc top_edge
sta final_x

; Check collision with top edge
top_edge:
lda final_x        ;
cmp obstacle_left  ;
bcc end            ; Skip horizontal edges collistion checks if
lda obstacle_right ; the player is aside of the obstacle
cmp final_x        ;
bcc end            ;

lda obstacle_top
cmp orig_y
bcc bot_edge
cmp final_y
bcs bot_edge
sta final_y

; Check collision with bottom edge
bot_edge:
lda orig_y
cmp obstacle_bottom
bcc end
lda obstacle_bottom
cmp final_y
bcc end
sta final_y

end:
rts
.)

; Check the player's position and modify the current state accordingly
;  register X must contain the player number
check_player_position:
.(
; Jumping players obey their own physics
lda player_a_state, x
cmp PLAYER_STATE_JUMPING
beq end

; Check if on ground
;  Not grounded players must be falling
lda player_a_x, x
cmp STAGE_EDGE_LEFT
bcc set_falling_state
cmp STAGE_EDGE_RIGHT
bcs set_falling_state
lda player_a_y, x
cmp STAGE_EDGE_TOP
bne set_falling_state

; On ground
;  Check if we are on a state that needs to be updated
lda player_a_state, x
cmp PLAYER_STATE_FALLING
beq set_standing_state

; No state change is required
jmp end

set_standing_state:
jsr start_standing_player
jmp end

set_falling_state:
lda PLAYER_STATE_FALLING
sta player_a_state, x

end:
rts
.)

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
beq end
jsr start_jumping_player

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

; Update the player's velocity
;  X - player number
;  Stack#0 - Y component of the vector to merge
;  Stack#1 - X component of the vector to merge
merge_player_velocity:
.(
; Save the return address
pla
sta tmpfield1
pla
sta tmpfield2

; Store current player's max velocity to an address accessible
; independently from X
lda player_a_max_velocity, x
sta tmpfield4

; Count iteraction, one per vector's component
ldy #$00

add_component:

; Store the value to add in A and int tmpfield3
pla
sta tmpfield3

; Add the component to the player's velocity
clc
adc player_a_velocity_v, x
sta player_a_velocity_v, x

; If the new velocity is <= immediatly handle next component
jsr absolute_a
cmp tmpfield4
bcc next_component
beq next_component

; If the value to add is positive, go to set the component to it's positive maximum
lda tmpfield3
bpl set_positive_max_h

; Set the component to it's negative maximum
lda tmpfield4
eor #%11111111
clc
adc #$01
sta player_a_velocity_v, x
jmp next_component

; Set the component to it's positive maximum
set_positive_max_h:
lda tmpfield4
sta player_a_velocity_v, x

; Handle next component
next_component:
inx
inx
iny
cpy #$02
bne add_component
dex
dex
dex
dex

; Restore return addr on stack and return
lda tmpfield2
pha
lda tmpfield1
pha
rts
.)

; Change A to it's absolute unsigned value
absolute_a:
.(
cmp #$00
bpl end
eor #%11111111
clc
adc #$01

end:
rts
.)

update_sprites:
.(
ldx #$00

player_animation:
ldy #$00
lda #$00
sta tmpfield1

; Store current player's animation vector to a player independent location
cpx #$00
bne select_anim_player_b
lda player_a_animation
sta tmpfield3
lda player_a_animation+1
sta tmpfield4
lda #$00
sta tmpfield5
jmp new_frame
select_anim_player_b:
lda player_b_animation
sta tmpfield3
lda player_b_animation+1
sta tmpfield4
lda #$08
sta tmpfield5

; New frame (search for the frame on time with clock)
new_frame:
lda (tmpfield3), y ; Load frame duration
beq loop_animation ; Frame of duration 0 means end of animation
clc           ;
adc tmpfield1 ; Store current frame clock end in tmpfield1
sta tmpfield1 ;

; If the current frame ends after the clock time, draw it
cmp player_a_anim_clock, x
bcs draw_current_frame

; Search the next frame
iny ; Skip frame duration field
skip_sprite:
lda (tmpfield3), y ; Check current sprite continuation byte
beq end_skip_frame ;
tya      ;
clc      ; Add 5 to Y, to point on the next continuation byte
adc #$05 ;
tay      ;
jmp skip_sprite
end_skip_frame:
iny ; Skip the last continuation byte
jmp new_frame

draw_current_frame:
; Animation location is player's location
lda player_a_x, x
sta tmpfield1
lda player_a_y, x
sta tmpfield2

; Add Y to the animation vector, to point to the good frame
iny ; Inc Y to skip the frame duration field
tya
clc
adc tmpfield3
sta tmpfield3
lda #$00
adc tmpfield4
sta tmpfield4

txa
pha
jsr draw_anim_frame
pla
tax

tick_clock:
inc player_a_anim_clock, x
jmp next_player

loop_animation:
lda #$00
sta player_a_anim_clock, x

next_player:
inx
cpx #$02
bne player_animation

rts
.)

; Draw an animation frame on screen
;  tmpfield1 - Position X
;  tmpfield2 - Position Y
;  tmpfield3, tmpfield4 - Vector pointing to the frame to draw
;  tmpfield5 - First sprite index to use
;
; Overwrites tmpfield5, tmpfield6, tmpfield7 and all registers
draw_anim_frame:
.(
; Pretty names
anim_pos_x = tmpfield1
anim_pos_y = tmpfield2
frame_vector = tmpfield3
sprite_index = tmpfield5
sprite_orig_x = tmpfield6
sprite_orig_y = tmpfield7

ldy #$00

; Check continuity byte
draw_one_sprite:
lda (frame_vector), y
beq end
cmp #$02
bne set_relative
lda #$00
sta sprite_orig_x
sta sprite_orig_y
jmp end_continuation_byte
set_relative:
lda anim_pos_x
sta sprite_orig_x
lda anim_pos_y
sta sprite_orig_y
end_continuation_byte:
iny

; Copy sprite data
lda sprite_index
asl
asl
tax
; Y value, must be relative to animation Y position
lda (frame_vector), y
clc
adc sprite_orig_y
sta oam_mirror, x
inx
iny
; Tile number
lda (frame_vector), y
sta oam_mirror, x
inx
iny
; Attributes
lda (frame_vector), y
sta oam_mirror, x
inx
iny
; X value, must be relative to animation X position
lda (frame_vector), y
clc
adc sprite_orig_x
sta oam_mirror, x
iny

; Next sprite
inc sprite_index
jmp draw_one_sprite

end:
rts
.)

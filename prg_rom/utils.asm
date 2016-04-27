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
lda PLAYER_STATE_STANDING
sta player_a_state
sta player_b_state

; Player B direction set to left (same value as PLAYER_STATE_STANDING)
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
lda PLAYER_STATE_STANDING
sta player_a_state, x
jmp end

set_falling_state:
lda PLAYER_STATE_FALLING
sta player_a_state, x

end:
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
lda PLAYER_STATE_RUNNING
sta player_a_state, x

jmp check_up

; check right button
check_right:
lda #%00000001
bit tmpfield1
beq check_up

; Player is now watching right
lda DIRECTION_RIGHT
sta player_a_direction, x

; Player is now running (running is #$01, the same as right direction)
sta player_a_state, x

; Check up button
check_up:
lda #%00001000
bit tmpfield1
beq end
jsr start_jumping_player

end:
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
lda #$00
sta player_a_direction, x

jmp check_up

; check right button
check_right:
lda #%00000001
bit tmpfield1
beq check_up

; Player is now watching right
lda DIRECTION_RIGHT
sta player_a_direction, x

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
lda PLAYER_STATE_STANDING
sta player_a_state, x

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
; Place sprites 0 and 1 to the player A position
lda player_a_x
sta sprite_0_x
sta sprite_1_x
lda player_a_y
sta sprite_0_y
clc
adc #$08
sta sprite_1_y

; Place sprites 2 and 3 to the player B position
lda player_b_x
sta sprite_2_x
sta sprite_3_x
lda player_b_y
sta sprite_2_y
clc
adc #$08
sta sprite_3_y

rts
.)

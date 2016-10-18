; Start a new animation for the player
;  X - Player number
;  tmpfield1 - Animation's vector (low byte)
;  tmpfield2 - Animation's vector (high byte)
set_player_animation:
.(
new_animation = tmpfield1

; X = X * 2 (we use it to reference a 2 bytes field)
txa
asl
tax

; Set the player's animation
lda new_animation
sta player_a_animation, x
lda new_animation+1
sta player_a_animation+1, x

; Reset x to it's original value
txa
lsr
tax

; Reset animation's clock
lda #$00
sta player_a_anim_clock, x

rts
.)

; Start a new animation for the player depending on the player's direction
;  X - Player number
;  tmpfield1 - Animation's vector for left-facing player (low byte)
;  tmpfield2 - Animation's vector for left-facing player (high byte)
;  tmpfield3 - Animation's vector for right-facing player (low byte)
;  tmpfield4 - Animation's vector for right-facing player (high byte)
set_player_animation_oriented:
.(
right_animation = tmpfield3
shown_animation = tmpfield1

; If the player is right-facing, set the right animation as shown
lda player_a_direction, x
beq set_anim
lda right_animation
sta shown_animation
lda right_animation+1
sta shown_animation+1

; Start the selected animation
set_anim:
jsr set_player_animation

rts
.)

; Jump to a callback according to player's controller state
;  X - Player number
;  tmpfield1 - Callbacks table (high byte)
;  tmpfield2 - Callbacks table (low byte)
;  tmpfield3 - number of states in the callbacks table
;
;  Overwrites register Y, tmpfield4, tmpfield5 and tmpfield6
;
;  Note - The callback is called with jmp, controller_callbacks never
;         returns using rts.
controller_callbacks:
.(
callbacks_table = tmpfield1
num_states = tmpfield3
callback_addr = tmpfield4
matching_index = tmpfield6

; Initialize loop, Y on first element and A on controller's state
ldy #$00
lda controller_a_btns, x

check_controller_state:
; Compare controller state to the current table element
cmp (callbacks_table), y
bne next_controller_state

; Store the low byte of the callback address
tya                ;
sta matching_index ; Save Y, it contains the index of the matching entry
clc                       ;
adc num_states            ;
tay                       ; low_byte = callbacks_table[y + num_states]
lda (callbacks_table), y  ;
sta callback_addr         ;

; Store the high byte of the callback address
tya                       ;
clc                       ;
adc num_states            ; high_byte = callbacks_table[matching_index + num_states * 2]
tay                       ;
lda (callbacks_table), y  ;
sta callback_addr+1       ;

; Controller state is current element, jump to the callback
jmp (callback_addr)

next_controller_state:
; Check next element on the state table
iny
cpy num_states
bne check_controller_state

; The state was not listed on the table, call the default callback at table's end
tya            ;
asl            ;
clc            ; Y = num_states * 3
adc num_states ;
tay            ;
lda (callbacks_table), y ;
sta callback_addr        ;
iny                      ; Store default callback address
lda (callbacks_table), y ;
sta callback_addr+1      ;
jmp (callback_addr) ; Jump to stored address
.)

; Change the player's state if an aerial move is input on the controller
;  register X - Player number
;
;  Overwrites tmpfield15 and tmpfield2 plus the ones overriten by the state starting subroutine
check_aerial_inputs:
.(
input_marker = tmpfield15
player_btn = tmpfield2

.(
; Save current direction
lda player_a_direction, x
pha

; Change player's direction according to input direction
lda controller_a_btns, x
sta player_btn
lda #CONTROLLER_BTN_LEFT
bit player_btn
beq check_direction_right
lda DIRECTION_LEFT
jmp set_direction
check_direction_right:
lda #CONTROLLER_BTN_RIGHT
bit player_btn
beq no_direction
lda DIRECTION_RIGHT
set_direction:
sta player_a_direction, x
no_direction:

; Start the good state according to input
jsr take_input

; Restore player's direction if there was no input, else discard saved direction
lda input_marker
beq restore_direction
pla
jmp end
restore_direction:
pla
sta player_a_direction, x

end:
rts
.)

take_input:
.(
; Mark input
lda #01
sta input_marker

; Call aerial subroutines, in case of input it will return with input marked
lda #<controller_inputs
sta tmpfield1
lda #>controller_inputs
sta tmpfield2
lda #$02
sta tmpfield3
jmp controller_callbacks

; If no input, unmark the input flag and return
no_input:
lda #$00
sta input_marker
rts

; Impactful controller states and associated callbacks
; Note - We have to put subroutines as callbacks since we do not expect a return unless we used the default callback
controller_inputs:
.byt CONTROLLER_INPUT_SPECIAL_RIGHT, CONTROLLER_INPUT_SPECIAL_LEFT
controller_callbacks_lo:
.byt <start_side_special_player,     <start_side_special_player
controller_callbacks_hi:
.byt >start_side_special_player,     >start_side_special_player
controller_default_callback:
.word no_input
.)
.)

start_standing_player:
.(
; Set the appropriate animation (depending on player's direction)
lda #<anim_sinbad_idle_left
sta tmpfield1
lda #>anim_sinbad_idle_left
sta tmpfield2
lda #<anim_sinbad_idle_right
sta tmpfield3
lda #>anim_sinbad_idle_right
sta tmpfield4
jsr set_player_animation_oriented

; Set the player's state
lda PLAYER_STATE_STANDING
sta player_a_state, x
rts
.)

; Update a player that is standing on ground
;  register X must contain the player number
standing_player:
.(
; Do not move, velocity tends toward vector (0,0)
lda #$00
sta tmpfield4
sta tmpfield3
sta tmpfield2
sta tmpfield1
lda #$ff
sta tmpfield5
jsr merge_to_player_velocity

; Check state changes
lda #<controller_inputs
sta tmpfield1
lda #>controller_inputs
sta tmpfield2
lda #$0b
sta tmpfield3
jmp controller_callbacks

; Player is now running left
input_left:
lda DIRECTION_LEFT
sta player_a_direction, x
jsr start_running_player
jmp end

; Player is now running right
input_right:
lda DIRECTION_RIGHT
sta player_a_direction, x
jsr start_running_player
jmp end

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

; Player is now side specialing
side_special_input_left:
lda DIRECTION_LEFT
sta player_a_direction, x
jmp side_special_input
side_special_input_right:
lda DIRECTION_RIGHT
sta player_a_direction, x
side_special_input:
jsr start_side_special_player
jmp end

end:
rts

; Impactful controller states and associated callbacks
; Note - We can put subroutines as callbacks because we have nothing to do after calling it
;        (sourboutines return to our caller since "called" with jmp)
controller_inputs:
.byt CONTROLLER_INPUT_LEFT,        CONTROLLER_INPUT_RIGHT,        CONTROLLER_INPUT_JUMP,         CONTROLLER_INPUT_JUMP_RIGHT, CONTROLLER_INPUT_JUMP_LEFT
.byt CONTROLLER_INPUT_JAB,         CONTROLLER_INPUT_ATTACK_LEFT,  CONTROLLER_INPUT_ATTACK_RIGHT, CONTROLLER_INPUT_SPECIAL,    CONTROLLER_INPUT_SPECIAL_RIGHT
.byt CONTROLLER_INPUT_SPECIAL_LEFT
controller_callbacks_lo:
.byt <input_left,                  <input_right,                  <jump_input,                   <jump_input_right,           <jump_input_left
.byt <start_jabbing_player,        <tilt_input_left,              <tilt_input_right,             <start_special_player,       <side_special_input_right
.byt <side_special_input_left
controller_callbacks_hi:
.byt >input_left,                  >input_right,                  >jump_input,                   >jump_input_right,           >jump_input_left
.byt >start_jabbing_player,        >tilt_input_left,              >tilt_input_right,             >start_special_player,       >side_special_input_right
.byt >side_special_input_left
controller_default_callback:
.word end
.)

start_running_player:
lda PLAYER_STATE_RUNNING
sta player_a_state, x
set_running_animation:
.(
; Set the appropriate animation (depending on player's direction)
lda #<anim_sinbad_run_left
sta tmpfield1
lda #>anim_sinbad_run_left
sta tmpfield2
lda #<anim_sinbad_run_right
sta tmpfield3
lda #>anim_sinbad_run_right
sta tmpfield4
jsr set_player_animation_oriented

; Set initial velocity
lda #$00
sta player_a_velocity_h_low, x
lda player_a_direction, x
cmp DIRECTION_LEFT
bne direction_right
lda #$ff
jmp set_high_byte
direction_right
lda #$01
set_high_byte:
sta player_a_velocity_h, x

rts
.)

; Update a player that is running
;  register X must contain the player number
running_player:
.(
; Move the player to the direction he is watching
lda player_a_direction, x
beq run_left

; Running right, velocity tends toward vector (2,0)
lda #$02
sta tmpfield4
lda #$00
sta tmpfield3
sta tmpfield2
sta tmpfield1
lda #$40
sta tmpfield5
jsr merge_to_player_velocity
jmp check_state_changes

; Running left, velocity tends toward vector (-2,0)
run_left:
lda #$fe
sta tmpfield4
lda #$00
sta tmpfield3
sta tmpfield2
sta tmpfield1
lda #$40
sta tmpfield5
jsr merge_to_player_velocity

check_state_changes:
lda #<controller_inputs
sta tmpfield1
lda #>controller_inputs
sta tmpfield2
lda #$0a
sta tmpfield3
jmp controller_callbacks

; Player is now watching left
input_left:
lda DIRECTION_LEFT
cmp player_a_direction, x
beq end
sta player_a_direction, x
jsr set_running_animation
jmp end

; Player is now watching right
input_right:
lda DIRECTION_RIGHT
cmp player_a_direction, x
beq end
sta player_a_direction, x
jsr set_running_animation
jmp end

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

end:
rts

; Impactful controller states and associated callbacks
; Note - We can put subroutines as callbacks because we have nothing to do after calling it
;        (sourboutines return to our caller since "called" with jmp)
controller_inputs:
.byt CONTROLLER_INPUT_LEFT,        CONTROLLER_INPUT_RIGHT,        CONTROLLER_INPUT_JUMP,    CONTROLLER_INPUT_JUMP_RIGHT,    CONTROLLER_INPUT_JUMP_LEFT
.byt CONTROLLER_INPUT_ATTACK_LEFT, CONTROLLER_INPUT_ATTACK_RIGHT, CONTROLLER_INPUT_SPECIAL, CONTROLLER_INPUT_SPECIAL_RIGHT, CONTROLLER_INPUT_SPECIAL_LEFT
controller_callbacks_lo:
.byt <input_left,                  <input_right,                  <start_jumping_player,    <start_jumping_player,          <start_jumping_player
.byt <tilt_input_left,             <tilt_input_right,             <start_special_player,    <start_side_special_player,     <start_side_special_player
controller_callbacks_hi:
.byt >input_left,                  >input_right,                  >start_jumping_player,    >start_jumping_player,          >start_jumping_player
.byt >tilt_input_left,             >tilt_input_right,             >start_special_player,    >start_side_special_player,     >start_side_special_player
controller_default_callback:
.word start_standing_player
.)

start_falling_player:
.(
lda PLAYER_STATE_FALLING
sta player_a_state, x
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

jsr check_aerial_inputs
rts
.)

start_jumping_player:
.(
lda #$fa
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
lda #<anim_sinbad_jab_left
sta tmpfield1
lda #>anim_sinbad_jab_left
sta tmpfield2
lda #<anim_sinbad_jab_right
sta tmpfield3
lda #>anim_sinbad_jab_right
sta tmpfield4
jsr set_player_animation_oriented

rts
.)

#define STATE_SINBAD_JAB_DURATION #8
jabbing_player:
.(
lda player_a_anim_clock, x
cmp STATE_SINBAD_JAB_DURATION
bne end
jsr start_standing_player

end:
rts
.)

start_thrown_player:
.(
; Set player's state
lda PLAYER_STATE_THROWN
sta player_a_state, x

; Initialize tech counter
lda #0
sta player_a_state_field1, x

; Fallthrough to set the animation
.)
set_thrown_animation:
.(
; Set the appropriate animation (depending on player's velocity)
lda player_a_velocity_h, x
bmi set_anim_left
lda #<anim_sinbad_thrown_right
sta tmpfield1
lda #>anim_sinbad_thrown_right
sta tmpfield2
jmp set_anim
set_anim_left:
lda #<anim_sinbad_thrown_left
sta tmpfield1
lda #>anim_sinbad_thrown_left
sta tmpfield2
set_anim:
jsr set_player_animation

rts
.)

thrown_player:
.(
; Add gravity to velocity
lda #$00 ; Horizontal component
pha      ; - high
pha      ; - low
lda #$01  ; Vertical component
pha       ; - high
lda #$00  ;
pha       ; - low
jsr add_to_player_velocity

; Decrement tech counter (to zero minimum)
lda player_a_state_field1, x
beq end_dec_tech_cnt
dec player_a_state_field1, x
end_dec_tech_cnt:

; Handle controller inputs
lda #<controller_inputs
sta tmpfield1
lda #>controller_inputs
sta tmpfield2
lda #$03
sta tmpfield3
jmp controller_callbacks

; If a tech is entered, store it's direction in state_field2
; and if the counter is at 0, reset it to it's max value.
tech_neutral:
lda #$00
jmp tech_common
tech_right:
lda #$01
jmp tech_common
tech_left:
lda #$02
tech_common:
sta player_a_state_field2, x
lda player_a_state_field1, x
bne end
lda #40
sta player_a_state_field1, x

end:
rts

; Impactful controller states and associated callbacks
; Note - We can put subroutines as callbacks because we have nothing to do after calling it
;        (sourboutines return to our caller since "called" with jmp)
controller_inputs:
.byt CONTROLLER_INPUT_TECH,        CONTROLLER_INPUT_TECH_RIGHT,   CONTROLLER_INPUT_TECH_LEFT
controller_callbacks_lo:
.byt <tech_neutral,                <tech_right,                   <tech_left
controller_callbacks_hi:
.byt >tech_neutral,                >tech_right,                   >tech_left
controller_default_callback:
.word end
.)

; Routine to be called when hitting the ground from thrown state
thrown_player_on_ground:
.(
; If the tech counter is bellow the threshold, just crash
lda #20
cmp player_a_state_field1, x
bcs crash

; A valid tech was entered, land with momentum depending on tech's direction
jsr start_landing_player
lda player_a_state_field2, x
beq no_momentum
cmp #$01
beq momentum_right
lda #$fc
sta player_a_velocity_h, x
lda #$00
sta player_a_velocity_h_low, x
jmp end
no_momentum:
lda #$00
sta player_a_velocity_h, x
sta player_a_velocity_h_low, x
jmp end
momentum_right:
lda #$04
sta player_a_velocity_h, x
lda #$00
sta player_a_velocity_h_low, x
jmp end

crash:
jsr start_crashing_player

end:
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
lda #<anim_sinbad_side_tilt_left
sta tmpfield1
lda #>anim_sinbad_side_tilt_left
sta tmpfield2
lda #<anim_sinbad_side_tilt_right
sta tmpfield3
lda #>anim_sinbad_side_tilt_right
sta tmpfield4
jsr set_player_animation_oriented

; Set the player's state
lda PLAYER_STATE_SIDE_TILT
sta player_a_state, x

; Set initial velocity
lda #$fd
sta player_a_velocity_v, x
lda #$80
sta player_a_velocity_v_low, x
lda player_a_direction, x
beq set_velocity_left
lda #$04
sta player_a_velocity_h, x
jmp end_set_velocity
set_velocity_left:
lda #$fb
sta player_a_velocity_h, x
end_set_velocity:
lda #$80
sta player_a_velocity_h_low, x

rts
.)

; Update a player that is performing a side tilt
;  register X must contain the player number
#define STATE_SINBAD_SIDE_TILT_DURATION #21
side_tilt_player:
.(
lda player_a_anim_clock, x
cmp STATE_SINBAD_SIDE_TILT_DURATION
bne update_velocity
jsr start_standing_player
jmp end

update_velocity:
lda #$01
sta tmpfield3
lda #$00
sta tmpfield4
sta tmpfield1
sta tmpfield2
lda #$80
sta tmpfield5
jsr merge_to_player_velocity

end:
rts
.)

start_special_player:
.(
; Set the appropriate animation
lda #<anim_sinbad_special
sta tmpfield1
lda #>anim_sinbad_special
sta tmpfield2
jsr set_player_animation

; Set the player's state
lda PLAYER_STATE_SPECIAL
sta player_a_state, x

; Place the player above ground
lda player_a_y, x
sec
sbc #$10
sta player_a_y, x

rts
.)

; Update a player that is performing a grounded neutral special move
;  register X must contain the player number
special_player:
.(
lda controller_a_btns, x
cmp #CONTROLLER_INPUT_SPECIAL
beq end
jsr start_standing_player

end:
rts
.)

start_side_special_player:
.(
; Set state
lda PLAYER_STATE_SIDE_SPECIAL
sta player_a_state, x

; Set initial velocity
lda #$00
sta player_a_velocity_h_low, x
sta player_a_velocity_h, x
sta player_a_velocity_v_low, x
sta player_a_velocity_v, x

; Set substate to "charging"
sta player_a_state_field1, x

; Fallthrough to set the animation
.)
set_side_special_animation:
.(
; Set the appropriate animation (depending on player's direction)
lda #<anim_sinbad_side_special_left_charge
sta tmpfield1
lda #>anim_sinbad_side_special_left_charge
sta tmpfield2
lda #<anim_sinbad_side_special_right_charge
sta tmpfield3
lda #>anim_sinbad_side_special_right_charge
sta tmpfield4
jsr set_player_animation_oriented

rts
.)

#define STATE_SINBAD_SIDE_SPECIAL_PREPARATION_DURATION #120
side_special_player:
.(
; Move if the substate is set to moving
lda player_a_state_field1, x
bne moving

; Check if there is reason to begin to move
lda player_a_anim_clock, x
cmp STATE_SINBAD_SIDE_SPECIAL_PREPARATION_DURATION
bcs start_moving
lda controller_a_btns, x
cmp #CONTROLLER_INPUT_SPECIAL_RIGHT
beq not_moving
cmp #CONTROLLER_INPUT_SPECIAL_LEFT
bne start_moving

not_moving:
jmp end

start_moving:
; Set substate to "moving"
lda #$01
sta player_a_state_field1, x

; Store fly duration (fly_duration = 5 + charge_duration / 8)
lda player_a_anim_clock, x
lsr
lsr
lsr
clc
adc #5
sta player_a_state_field2, x

; Set the movement animation
lda #<anim_sinbad_side_special_left_jump
sta tmpfield1
lda #>anim_sinbad_side_special_left_jump
sta tmpfield2
lda #<anim_sinbad_side_special_right_jump
sta tmpfield3
lda #>anim_sinbad_side_special_right_jump
sta tmpfield4
jsr set_player_animation_oriented

moving:
; Set vertical velocity (fixed)
lda #$ff
sta player_a_velocity_v, x
lda #$80
sta player_a_velocity_v_low, x

; Set horizontal velocity (depending on direction)
lda player_a_direction, x
cmp DIRECTION_LEFT
bne right_velocity
lda #$fc
jmp set_h_velocity
right_velocity:
lda #$04
set_h_velocity:
sta player_a_velocity_h, x
lda #$00
sta player_a_velocity_h_low, x

; After move's time is out, go to helpless state
lda player_a_anim_clock, x
cmp player_a_state_field2, x
bne end
jsr start_helpless_player

end:
rts
.)

start_helpless_player:
.(
; Set state
lda PLAYER_STATE_HELPLESS
sta player_a_state, x

; Fallthrough to set the animation
.)
set_helpless_animation:
.(
; Set the appropriate animation (depending on player's direction)
lda #<anim_sinbad_helpless_left
sta tmpfield1
lda #>anim_sinbad_helpless_left
sta tmpfield2
lda #<anim_sinbad_helpless_right
sta tmpfield3
lda #>anim_sinbad_helpless_right
sta tmpfield4
jsr set_player_animation_oriented

rts
.)

; Update a player that is helplessly falling
helpless_player:
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

start_landing_player:
.(
; Set state
lda PLAYER_STATE_LANDING
sta player_a_state, x

; Cap initial velocity
lda player_a_velocity_h, x
jsr absolute_a
cmp #$03
bcs set_cap
jmp set_landing_animation
set_cap:
lda player_a_velocity_h, x
bmi negative_cap
lda #$02
sta player_a_velocity_h, x
lda #$00
sta player_a_velocity_h_low, x
jmp set_landing_animation
negative_cap:
lda #$fe
sta player_a_velocity_h, x
lda #$00
sta player_a_velocity_h_low, x

; Fallthrough to set the animation
.)
set_landing_animation:
.(
; Set the appropriate animation (depending on player's direction)
lda #<anim_sinbad_landing_left
sta tmpfield1
lda #>anim_sinbad_landing_left
sta tmpfield2
lda #<anim_sinbad_landing_right
sta tmpfield3
lda #>anim_sinbad_landing_right
sta tmpfield4
jsr set_player_animation_oriented

rts
.)

#define STATE_SINBAD_LANDING_DURATION #20
landing_player:
.(
; Do not move, velocity tends toward vector (0,0)
lda #$00
sta tmpfield4
sta tmpfield3
sta tmpfield2
sta tmpfield1
lda #$40
sta tmpfield5
jsr merge_to_player_velocity

; After move's time is out, go to standing state
lda player_a_anim_clock, x
cmp STATE_SINBAD_LANDING_DURATION
bne end
jsr start_standing_player

end:
rts
.)

start_crashing_player:
.(
; Set state
lda PLAYER_STATE_CRASHING
sta player_a_state, x

; Fallthrough to set the animation
.)
set_crashing_animation:
.(
; Set the appropriate animation (depending on player's direction)
lda #<anim_sinbad_crashing_left
sta tmpfield1
lda #>anim_sinbad_crashing_left
sta tmpfield2
lda #<anim_sinbad_crashing_right
sta tmpfield3
lda #>anim_sinbad_crashing_right
sta tmpfield4
jsr set_player_animation_oriented

rts
.)

#define STATE_SINBAD_CRASHING_DURATION #60
crashing_player:
.(
; Do not move, velocity tends toward vector (0,0)
lda #$00
sta tmpfield4
sta tmpfield3
sta tmpfield2
sta tmpfield1
lda #$80
sta tmpfield5
jsr merge_to_player_velocity

; After move's time is out, go to standing state
lda player_a_anim_clock, x
cmp STATE_SINBAD_CRASHING_DURATION
bne end
jsr start_standing_player

end:
rts
.)

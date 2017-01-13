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

; Set animation's direction
lda player_a_direction, x
sta player_a_animation_direction, x

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
; Refuse to do anything if under hitstun
lda player_a_hitstun, x
bne end

; Assuming we are called from an input event
; Do nothing if the only changes concern the left-right buttons
lda controller_a_btns, x
eor controller_a_last_frame_btns, x
and #CONTROLLER_BTN_A | CONTROLLER_BTN_B | CONTROLLER_BTN_UP | CONTROLLER_BTN_DOWN
beq end

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
lda #13
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
.byt CONTROLLER_INPUT_SPECIAL_RIGHT, CONTROLLER_INPUT_SPECIAL_LEFT, CONTROLLER_INPUT_JUMP,        CONTROLLER_INPUT_JUMP_RIGHT,  CONTROLLER_INPUT_JUMP_LEFT
.byt CONTROLLER_INPUT_ATTACK_LEFT,   CONTROLLER_INPUT_ATTACK_RIGHT, CONTROLLER_INPUT_DOWN_TILT,   CONTROLLER_INPUT_ATTACK_UP,   CONTROLLER_INPUT_JAB
.byt CONTROLLER_INPUT_SPECIAL,       CONTROLLER_INPUT_SPECIAL_UP,   CONTROLLER_INPUT_SPECIAL_DOWN
controller_callbacks_lo:
.byt <start_side_special_player,     <start_side_special_player,    <start_aerial_jumping_player, <start_aerial_jumping_player, <start_aerial_jumping_player
.byt <start_aerial_side_player,      <start_aerial_side_player,     <start_aerial_down_player,    <start_aerial_up_player,      <start_aerial_neutral_player
.byt <start_aerial_spe_player,       <start_spe_up_player,          <start_spe_down_player
controller_callbacks_hi:
.byt >start_side_special_player,     >start_side_special_player,    >start_aerial_jumping_player, >start_aerial_jumping_player, >start_aerial_jumping_player
.byt >start_aerial_side_player,      >start_aerial_side_player,     >start_aerial_down_player,    >start_aerial_up_player,      >start_aerial_neutral_player
.byt >start_aerial_spe_player,       >start_spe_up_player,          >start_spe_down_player
controller_default_callback:
.word no_input
.)
.)

; Simple way to apply the standard gravity effect
;  register X - player number
apply_gravity:
.(
lda player_a_velocity_h_low, x
sta tmpfield2
lda player_a_velocity_h, x
sta tmpfield4
lda #$00
sta tmpfield1
lda #$03
sta tmpfield3
lda #$60
sta tmpfield5
jsr merge_to_player_velocity

rts
.)

aerial_directional_influence:
.(
lda controller_a_btns, x
and #CONTROLLER_INPUT_LEFT
bne go_left

lda controller_a_btns, x
and #CONTROLLER_INPUT_RIGHT
bne go_right

jmp end

go_left:
lda #$00
sta tmpfield6
lda #$ff
sta tmpfield7
lda player_a_velocity_h_low, x
sta tmpfield8
lda player_a_velocity_h, x
sta tmpfield9
jsr signed_cmp
bpl end

lda player_a_velocity_v_low, x
sta tmpfield1
lda player_a_velocity_v, x
sta tmpfield3
lda #$00
sta tmpfield2
lda #$ff
sta tmpfield4
lda #$80
sta tmpfield5
jsr merge_to_player_velocity
jmp end

go_right:
lda player_a_velocity_h_low, x
sta tmpfield6
lda player_a_velocity_h, x
sta tmpfield7
lda #$00
sta tmpfield8
lda #$01
sta tmpfield9
jsr signed_cmp
bpl end

lda player_a_velocity_v_low, x
sta tmpfield1
lda player_a_velocity_v, x
sta tmpfield3
lda #$00
sta tmpfield2
lda #$01
sta tmpfield4
lda #$80
sta tmpfield5
jsr merge_to_player_velocity

end:
rts
.)

start_standing_player:
.(
; Set the appropriate animation
lda #<anim_sinbad_idle
sta tmpfield1
lda #>anim_sinbad_idle
sta tmpfield2
jsr set_player_animation

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

; Force the handling of directional controls
lda controller_a_btns, x
cmp #CONTROLLER_INPUT_LEFT
bne no_left
jsr standing_player_input_left
jmp end
no_left:
cmp #CONTROLLER_INPUT_RIGHT
bne end
jsr standing_player_input_right

end:
rts
.)

; Player is now running left
standing_player_input_left:
.(
lda DIRECTION_LEFT
sta player_a_direction, x
jsr start_running_player
rts
.)

; Player is now running right
standing_player_input_right:
.(
lda DIRECTION_RIGHT
sta player_a_direction, x
jsr start_running_player
rts
.)

standing_player_input:
.(
; Do not handle any input if under hitstun
lda player_a_hitstun, x
bne end

; Check state changes
lda #<controller_inputs
sta tmpfield1
lda #>controller_inputs
sta tmpfield2
lda #16
sta tmpfield3
jmp controller_callbacks

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
.byt CONTROLLER_INPUT_LEFT,         CONTROLLER_INPUT_RIGHT,        CONTROLLER_INPUT_JUMP,         CONTROLLER_INPUT_JUMP_RIGHT,   CONTROLLER_INPUT_JUMP_LEFT
.byt CONTROLLER_INPUT_JAB,          CONTROLLER_INPUT_ATTACK_LEFT,  CONTROLLER_INPUT_ATTACK_RIGHT, CONTROLLER_INPUT_SPECIAL,      CONTROLLER_INPUT_SPECIAL_RIGHT
.byt CONTROLLER_INPUT_SPECIAL_LEFT, CONTROLLER_INPUT_DOWN_TILT,    CONTROLLER_INPUT_SPECIAL_UP,   CONTROLLER_INPUT_SPECIAL_DOWN, CONTROLLER_INPUT_ATTACK_UP
.byt CONTROLLER_INPUT_TECH
controller_callbacks_lo:
.byt <standing_player_input_left,  <standing_player_input_right,  <jump_input,                   <jump_input_right,             <jump_input_left
.byt <start_jabbing_player,        <tilt_input_left,              <tilt_input_right,             <start_special_player,         <side_special_input_right
.byt <side_special_input_left,     <start_down_tilt_player,       <start_spe_up_player,          <start_spe_down_player,        <start_up_tilt_player
.byt <start_shielding_player
controller_callbacks_hi:
.byt >standing_player_input_left,  >standing_player_input_right,  >jump_input,                   >jump_input_right,             >jump_input_left
.byt >start_jabbing_player,        >tilt_input_left,              >tilt_input_right,             >start_special_player,         >side_special_input_right
.byt >side_special_input_left,     >start_down_tilt_player,       >start_spe_up_player,          >start_spe_down_player,        >start_up_tilt_player
.byt >start_shielding_player
controller_default_callback:
.word end
.)

start_running_player:
lda PLAYER_STATE_RUNNING
sta player_a_state, x
set_running_animation:
.(
; Set the appropriate animation
lda #<anim_sinbad_run
sta tmpfield1
lda #>anim_sinbad_run
sta tmpfield2
jsr set_player_animation

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
jmp end

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

end:
rts
.)

running_player_input:
.(
; If in hitstun, stop running
lda player_a_hitstun, x
beq take_input
jsr start_standing_player
jmp end
take_input:

lda #<controller_inputs
sta tmpfield1
lda #>controller_inputs
sta tmpfield2
lda #12
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
.byt CONTROLLER_INPUT_SPECIAL_UP,  CONTROLLER_INPUT_SPECIAL_DOWN
controller_callbacks_lo:
.byt <input_left,                  <input_right,                  <start_jumping_player,    <start_jumping_player,          <start_jumping_player
.byt <tilt_input_left,             <tilt_input_right,             <start_special_player,    <start_side_special_player,     <start_side_special_player
.byt <start_spe_up_player,         <start_spe_down_player
controller_callbacks_hi:
.byt >input_left,                  >input_right,                  >start_jumping_player,    >start_jumping_player,          >start_jumping_player
.byt >tilt_input_left,             >tilt_input_right,             >start_special_player,    >start_side_special_player,     >start_side_special_player
.byt >start_spe_up_player,         >start_spe_down_player
controller_default_callback:
.word start_standing_player
.)

start_falling_player:
.(
lda PLAYER_STATE_FALLING
sta player_a_state, x

; Fallthrough to set the animation
.)
set_falling_animation:
.(
; Set the appropriate animation
lda #<anim_sinbad_falling
sta tmpfield1
lda #>anim_sinbad_falling
sta tmpfield2
jsr set_player_animation

rts
.)

; Update a player that is falling
;  register X must contain the player number
falling_player:
.(
jsr aerial_directional_influence
jsr apply_gravity
rts
.)

start_jumping_player:
.(
lda PLAYER_STATE_JUMPING
sta player_a_state, x

; Fallthrough to set the animation
.)
set_jumping_animation:
.(
; Set the appropriate animation
lda #<anim_sinbad_jumping
sta tmpfield1
lda #>anim_sinbad_jumping
sta tmpfield2
jsr set_player_animation

rts
.)

#define STATE_SINBAD_JUMP_PREPARATION_END #4
jumping_player:
.(
; Wait for the preparation to end to begin to jump
lda player_a_anim_clock, x
cmp STATE_SINBAD_JUMP_PREPARATION_END
bcc end
beq begin_to_jump

; Return to falling when the top is reached
lda player_a_velocity_v, x
beq top_reached
bpl top_reached

; The top is not reached, stay in jumping state but apply gravity and directional influence
jsr falling_player ; Hack - We just use falling_player which do exactly what we want
jmp end

top_reached:
jsr start_falling_player
jmp end

begin_to_jump:
lda #$fb
sta player_a_velocity_v, x
lda #$00
sta player_a_velocity_v_low, x

end:
rts
.)

jumping_player_input:
.(
; The jump is cancellable by grounded movements during preparation
; and by aerial movements after that
lda player_a_anim_clock, x
cmp STATE_SINBAD_JUMP_PREPARATION_END
bcc grounded

jsr check_aerial_inputs
jmp end

grounded:
lda #<controller_inputs
sta tmpfield1
lda #>controller_inputs
sta tmpfield2
lda #2
sta tmpfield3
jmp controller_callbacks

end:
rts

; Impactful controller states and associated callbacks (when still grounded)
; Note - We can put subroutines as callbacks because we have nothing to do after calling it
;        (sourboutines return to our caller since "called" with jmp)
controller_inputs:
.byt CONTROLLER_INPUT_ATTACK_UP, CONTROLLER_INPUT_SPECIAL_UP
controller_callbacks_lo:
.byt <start_up_tilt_player, <start_spe_up_player
controller_callbacks_hi:
.byt >start_up_tilt_player, >start_spe_up_player
controller_default_callback:
.word end
.)

#define MAX_NUM_AERIAL_JUMPS 1
start_aerial_jumping_player:
.(
; Deny to start jump state if the player used all it's jumps
lda #MAX_NUM_AERIAL_JUMPS
cmp player_a_num_aerial_jumps, x
bne jump_ok
rts
jump_ok:
inc player_a_num_aerial_jumps, x

; Trick - aerial_jumping set the state to jumping. It is the same state with
; the starting conditions as the only differences
lda PLAYER_STATE_JUMPING
sta player_a_state, x

lda #$00
sta player_a_velocity_v, x
lda #$00
sta player_a_velocity_v_low, x

; Fallthrough to set the animation
.)
set_aerial_jumping_animation:
.(
; Set the appropriate animation
lda #<anim_sinbad_aerial_jumping
sta tmpfield1
lda #>anim_sinbad_aerial_jumping
sta tmpfield2
jsr set_player_animation

rts
.)

start_jabbing_player:
lda PLAYER_STATE_JABBING
sta player_a_state, x
set_jabbing_animation:
.(
; Set the appropriate animation
lda #<anim_sinbad_jab
sta tmpfield1
lda #>anim_sinbad_jab
sta tmpfield2
jsr set_player_animation

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
lda #<anim_sinbad_thrown
sta tmpfield1
lda #>anim_sinbad_thrown
sta tmpfield2
jsr set_player_animation

; Set the appropriate animation direction (depending on player's velocity)
lda player_a_velocity_h, x
bmi set_anim_left
lda DIRECTION_RIGHT
jmp set_anim_dir
set_anim_left:
lda DIRECTION_LEFT
set_anim_dir:
sta player_a_animation_direction, x

rts
.)

; To tech successfully the tech must be input at maximum TECH_MAX_FRAMES_BEFORE_COLLISION frames before hitting the ground.
; After expiration of a tech input, it is not possible to input another tech for TECH_NB_FORBIDDEN_FRAMES frames.
#define TECH_MAX_FRAMES_BEFORE_COLLISION 5
#define TECH_NB_FORBIDDEN_FRAMES 60
thrown_player:
.(
; Update velocity
lda player_a_hitstun, x
bne gravity
jsr aerial_directional_influence
gravity:
jsr apply_gravity

; Decrement tech counter (to zero minimum)
lda player_a_state_field1, x
beq end_dec_tech_cnt
dec player_a_state_field1, x
end_dec_tech_cnt:

rts
.)

thrown_player_input:
.(
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
lda #TECH_MAX_FRAMES_BEFORE_COLLISION+TECH_NB_FORBIDDEN_FRAMES
sta player_a_state_field1, x

no_tech:
jsr check_aerial_inputs

end:
rts

; Impactful controller states and associated callbacks
controller_inputs:
.byt CONTROLLER_INPUT_TECH,        CONTROLLER_INPUT_TECH_RIGHT,   CONTROLLER_INPUT_TECH_LEFT
controller_callbacks_lo:
.byt <tech_neutral,                <tech_right,                   <tech_left
controller_callbacks_hi:
.byt >tech_neutral,                >tech_right,                   >tech_left
controller_default_callback:
.word no_tech
.)

; Routine to be called when hitting the ground from thrown state
thrown_player_on_ground:
.(
; If the tech counter is bellow the threshold, just crash
lda #TECH_NB_FORBIDDEN_FRAMES
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
; Set the appropriate animation
lda #<anim_sinbad_side_tilt
sta tmpfield1
lda #>anim_sinbad_side_tilt
sta tmpfield2
jsr set_player_animation

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
rts
.)

special_player_input:
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
; Set the appropriate animation
lda #<anim_sinbad_side_special_charge
sta tmpfield1
lda #>anim_sinbad_side_special_charge
sta tmpfield2
jsr set_player_animation

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
lda #<anim_sinbad_side_special_jump
sta tmpfield1
lda #>anim_sinbad_side_special_jump
sta tmpfield2
jsr set_player_animation

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
; Set the appropriate animation
lda #<anim_sinbad_helpless
sta tmpfield1
lda #>anim_sinbad_helpless
sta tmpfield2
jsr set_player_animation

rts
.)

; Update a player that is helplessly falling
helpless_player:
.(
jsr falling_player
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
; Set the appropriate animation
lda #<anim_sinbad_landing
sta tmpfield1
lda #>anim_sinbad_landing
sta tmpfield2
jsr set_player_animation

rts
.)

#define STATE_SINBAD_LANDING_DURATION #6
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
; Set the appropriate animation
lda #<anim_sinbad_crashing
sta tmpfield1
lda #>anim_sinbad_crashing
sta tmpfield2
jsr set_player_animation

; Play crash sound
jsr audio_play_crash

rts
.)

#define STATE_SINBAD_CRASHING_DURATION #30
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

start_down_tilt_player:
.(
; Set state
lda PLAYER_STATE_DOWN_TILT
sta player_a_state, x

; Fallthrough to set the animation
.)
set_down_tilt_animation:
.(
; Set the appropriate animation
lda #<anim_sinbad_down_tilt
sta tmpfield1
lda #>anim_sinbad_down_tilt
sta tmpfield2
jsr set_player_animation

rts
.)

#define STATE_SINBAD_DOWNTILT_DURATION #21
down_tilt_player:
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
cmp STATE_SINBAD_DOWNTILT_DURATION
bne end
jsr start_standing_player

end:
rts
.)

start_aerial_side_player:
.(
; Set state
lda PLAYER_STATE_AERIAL_SIDE
sta player_a_state, x

; Fallthrough to set the animation
.)
set_aerial_side_animation:
.(
; Set the appropriate animation
lda #<anim_sinbad_aerial_side
sta tmpfield1
lda #>anim_sinbad_aerial_side
sta tmpfield2
jsr set_player_animation

rts
.)

#define STATE_SINBAD_AERIAL_SIDE_DURATION #25
aerial_side_player:
.(
jsr apply_gravity

; Wait for move's timeout
lda player_a_anim_clock, x
cmp STATE_SINBAD_AERIAL_SIDE_DURATION
bne end
jsr start_falling_player

end:
rts
.)

start_aerial_down_player:
.(
; Set state
lda PLAYER_STATE_AERIAL_DOWN
sta player_a_state, x

; Fallthrough to set the animation
.)
set_aerial_down_animation:
.(
; Set the appropriate animation
lda #<anim_sinbad_aerial_down
sta tmpfield1
lda #>anim_sinbad_aerial_down
sta tmpfield2
jsr set_player_animation

rts
.)

#define STATE_SINBAD_AERIAL_DOWN_DURATION #21
aerial_down_player:
.(
jsr apply_gravity

; Wait for move's timeout
lda player_a_anim_clock, x
cmp STATE_SINBAD_AERIAL_DOWN_DURATION
bne end
jsr start_falling_player

end:
rts
.)

start_aerial_up_player:
.(
; Set state
lda PLAYER_STATE_AERIAL_UP
sta player_a_state, x

; Fallthrough to set the animation
.)
set_aerial_up_animation:
.(
; Set the appropriate animation
lda #<anim_sinbad_aerial_up
sta tmpfield1
lda #>anim_sinbad_aerial_up
sta tmpfield2
jsr set_player_animation

rts
.)

#define STATE_SINBAD_AERIAL_UP_DURATION #32
aerial_up_player:
.(
jsr apply_gravity

; Wait for move's timeout
lda player_a_anim_clock, x
cmp STATE_SINBAD_AERIAL_UP_DURATION
bne end
jsr start_falling_player

end:
rts
.)

start_aerial_neutral_player:
.(
; Set state
lda PLAYER_STATE_AERIAL_NEUTRAL
sta player_a_state, x

; Fallthrough to set the animation
.)
set_aerial_neutral_animation:
.(
; Set the appropriate animation
lda #<anim_sinbad_aerial_neutral
sta tmpfield1
lda #>anim_sinbad_aerial_neutral
sta tmpfield2
jsr set_player_animation

rts
.)

#define STATE_SINBAD_AERIAL_NEUTRAL_DURATION #12
aerial_neutral_player:
.(
jsr apply_gravity

; Wait for move's timeout
lda player_a_anim_clock, x
cmp STATE_SINBAD_AERIAL_NEUTRAL_DURATION
bne end
jsr start_falling_player

end:
rts
.)

start_aerial_spe_player:
.(
; Set state
lda PLAYER_STATE_AERIAL_SPE_NEUTRAL
sta player_a_state, x

; Fallthrough to set the animation
.)
set_aerial_spe_animation:
.(
; Set the appropriate animation
lda #<anim_sinbad_aerial_spe
sta tmpfield1
lda #>anim_sinbad_aerial_spe
sta tmpfield2
jsr set_player_animation

rts
.)

aerial_spe_player:
.(
jsr aerial_directional_influence

; Never move upward in this state
lda player_a_velocity_v, x
bpl end_max_velocity
lda #$00
sta player_a_velocity_v, x
sta player_a_velocity_v_low, x
end_max_velocity:

; Special fall speed - particularily slow
lda player_a_velocity_h, x
sta tmpfield4
lda player_a_velocity_h_low, x
sta tmpfield2
lda #$01
sta tmpfield3
lda #$00
sta tmpfield1
lda #$10
sta tmpfield5
jsr merge_to_player_velocity

rts
.)

start_spe_up_player:
.(
; Set state
lda PLAYER_STATE_SPE_UP
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
set_spe_up_animation:
.(
; Set the appropriate animation
lda #<anim_sinbad_spe_up_prepare
sta tmpfield1
lda #>anim_sinbad_spe_up_prepare
sta tmpfield2
jsr set_player_animation

rts
.)

#define STATE_SINBAD_SPE_UP_PREPARATION_DURATION #3
spe_up_player:
.(
; Move if the substate is set to moving
lda player_a_state_field1, x
bne moving

; Check if there is reason to begin to move
lda player_a_anim_clock, x
cmp STATE_SINBAD_SPE_UP_PREPARATION_DURATION
bcs start_moving

not_moving:
jmp end

start_moving:
; Set substate to "moving"
lda #$01
sta player_a_state_field1, x

; Set jumping velocity
lda #$fa
sta player_a_velocity_v, x
lda #$00
sta player_a_velocity_v_low, x

; Set the movement animation
lda #<anim_sinbad_spe_up_jump
sta tmpfield1
lda #>anim_sinbad_spe_up_jump
sta tmpfield2
jsr set_player_animation

moving:

; Return to falling when the top is reached
lda player_a_velocity_v, x
beq top_reached
bpl top_reached

; The top is not reached, stay in special upward state but apply gravity and directional influence
jsr aerial_directional_influence
jsr apply_gravity
jmp end

top_reached:
jsr start_helpless_player
jmp end

end:
rts
.)

start_spe_down_player:
.(
; Set state
lda PLAYER_STATE_SPE_DOWN
sta player_a_state, x

; Fallthrough to set the animation
.)
set_spe_down_animation:
.(
; Set the appropriate animation
lda #<anim_sinbad_spe_down
sta tmpfield1
lda #>anim_sinbad_spe_down
sta tmpfield2
jsr set_player_animation

rts
.)

#define STATE_SINBAD_SPE_DOWN_DURATION #21
spe_down_player:
.(
jsr apply_gravity

; Wait for move's timeout
lda player_a_anim_clock, x
cmp STATE_SINBAD_SPE_DOWN_DURATION
bne end

; Return to falling or standing
jsr check_on_ground
beq on_ground
jsr start_falling_player
jmp end
on_ground
jsr start_standing_player

end:
rts
.)

start_up_tilt_player:
.(
; Set state
lda PLAYER_STATE_UP_TILT
sta player_a_state, x

; Fallthrough to set the animation
.)
set_up_tilt_animation:
.(
; Set the appropriate animation
lda #<anim_sinbad_up_tilt
sta tmpfield1
lda #>anim_sinbad_up_tilt
sta tmpfield2
jsr set_player_animation

rts
.)

#define STATE_SINBAD_UPTILT_DURATION #20
up_tilt_player:
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
cmp STATE_SINBAD_UPTILT_DURATION
bne end
jsr start_standing_player

end:
rts
.)

start_shielding_player:
.(
; Set state
lda PLAYER_STATE_SHIELDING
sta player_a_state, x

; Fallthrough to set the animation
.)
set_shielding_animation:
.(
; Set the appropriate animation
lda #<anim_sinbad_shielding_full
sta tmpfield1
lda #>anim_sinbad_shielding_full
sta tmpfield2
jsr set_player_animation

; Cancel momentum
lda #$00
sta player_a_velocity_h_low
sta player_a_velocity_h

; Set shield as full life
lda #2
sta player_a_state_field1, x

rts
.)

shielding_player:
.(
; After move's time is out, go to standing state
lda player_a_anim_clock, x
cmp STATE_SINBAD_UPTILT_DURATION
bne end
jsr start_standing_player

end:
rts
.)

shielding_player_input:
.(
; Do the same as standing player, except all buttons are released (start standing in this case)
lda controller_a_btns, x
beq end_shield

jsr standing_player_input
jmp end

end_shield:
jsr start_standing_player

end:
rts
.)

shielding_player_hurt:
.(
stroke_player = tmpfield11

; Reduce shield's life
dec player_a_state_field1, x

; Select what to do according to shield's life
lda player_a_state_field1, x
beq limit_shield
cmp #1
beq partial_shield

; Break the shield, derived from normal hurt with:
;  Knockback * 2
;  Screen shaking * 4
;  Special sound
jsr hurt_player
ldx stroke_player
asl player_a_velocity_h_low, x
rol player_a_velocity_h, x
asl player_a_velocity_v_low, x
rol player_a_velocity_v, x
asl player_a_hitstun, x
asl screen_shake_counter
asl screen_shake_counter
jsr audio_play_shield_break
jmp end

; Get the animation corresponding to the shield's life
partial_shield:
lda #<anim_sinbad_shielding_partial
sta tmpfield1
lda #>anim_sinbad_shielding_partial
jmp still_shield
limit_shield:
lda #<anim_sinbad_shielding_limit
sta tmpfield1
lda #>anim_sinbad_shielding_limit

still_shield:
; Set the new shield animation
sta tmpfield2
jsr set_player_animation

; Play sound
jsr audio_play_shield_hit

end:
; Disable the hitbox to avoid multi-hits
jsr switch_selected_player
lda HITBOX_DISABLED
sta player_a_hitbox_enabled, x

rts
.)

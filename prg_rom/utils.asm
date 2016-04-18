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
lda #$00
sta player_a_state
sta player_b_state
sta player_b_direction

lda #$01
sta player_a_direction

lda #$80
sta player_a_y
sta player_b_y
lda #$40
sta player_a_x
lda #$a0
sta player_b_x

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
cmp #$01
bne player_updated
jsr running_player

player_updated:
jsr move_player
inx
cpx #$02
bne update_one_player

rts
.)

move_player:
.(
lda player_a_velocity_v, x
clc
adc player_a_y, x
sta player_a_y, x

lda player_a_velocity_h, x
clc
adc player_a_x, x
sta player_a_x, x

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
lda #$01
sta player_a_state, x

jmp end

; check right button
check_right:
lda #%00000001
bit tmpfield1
beq end

; Player is now watching right
lda #$01
sta player_a_direction, x

; Player is now running
sta player_a_state, x

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

jmp end

; check right button
check_right:
lda #%00000001
bit tmpfield1
beq nothing_pressed

; Player is now watching right
lda #$01
sta player_a_direction, x

jmp end

; When no direction button is pressed, return to standing state
nothing_pressed:
lda #$00
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

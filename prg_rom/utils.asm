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
inx
cpx #$02
bne update_one_player

rts
.)

; Update a player that is standing on ground
;  register X must contain the player number
standing_player:
.(
; Store the constroller state to a known location
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
; Move the player to the direction he is watching
lda player_a_direction, x
beq run_left
inc player_a_x, x
jmp check_state_changes
run_left:
dec player_a_x, x

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

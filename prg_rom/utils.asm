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

move_sprites:
.(
lda #%00001000
bit controller_a_btns
beq check_down
dec sprite_0_y

check_down:
lda #%00000100
bit controller_a_btns
beq check_left
inc sprite_0_y

check_left:
lda #%00000010
bit controller_a_btns
beq check_right
dec sprite_0_x

check_right:
lda #%00000001
bit controller_a_btns
beq end
inc sprite_0_x

end:
rts
.)

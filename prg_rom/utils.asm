fetch_controllers:
.(
lda #$01
sta CONTROLLER_A
lda #$00
sta CONTROLLER_A
lda CONTROLLER_A ; a
lda CONTROLLER_A ; b
lda CONTROLLER_A ; select
lda CONTROLLER_A ; start
lda CONTROLLER_A ; up
and #%00000001
beq fetch_down
dec $0200
fetch_down:
lda CONTROLLER_A ; down
and #%00000001
beq fetch_left
inc $0200
fetch_left:
lda CONTROLLER_A ; left
and #%00000001
beq fetch_right
dec $0203
fetch_right:
lda CONTROLLER_A ; right
and #%00000001
beq end_control
inc $0203
end_control:
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

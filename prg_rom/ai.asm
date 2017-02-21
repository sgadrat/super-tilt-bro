#define AI_ATTACK_HITBOX(left,right,top,bottom) .byt left, right, top, bottom

#define AI_NB_ATTACKS 3
attacks:
AI_ATTACK_HITBOX($f0, $fd, $f4, $0c)
.byt CONTROLLER_INPUT_ATTACK_LEFT
AI_ATTACK_HITBOX($0a, $17, $f4, $0c)
.byt CONTROLLER_INPUT_ATTACK_RIGHT
AI_ATTACK_HITBOX($f1, $17, $08, $0f)
.byt CONTROLLER_INPUT_DOWN_TILT

; Set controller B state
;
; Can watch game state to inteligently set controller B state
ai_tick:
.(
; Reset controller's state
lda #$00
sta controller_b_btns

; Search for an attack that can hit
ldy #AI_NB_ATTACKS
ldx #$00
check_one_attack:
lda attacks, x
clc
adc player_b_x
sta tmpfield1
inx
lda attacks, x
clc
adc player_b_x
sta tmpfield2
inx
lda attacks, x
clc
adc player_b_y
sta tmpfield3
inx
lda attacks, x
clc
adc player_b_y
sta tmpfield4
inx
txa
pha

lda player_a_hurtbox_left
sta tmpfield5
lda player_a_hurtbox_right
sta tmpfield6
lda player_a_hurtbox_top
sta tmpfield7
lda player_a_hurtbox_bottom
sta tmpfield8

jsr boxes_overlap
pla
tax
lda tmpfield9
bne next_attack
lda attacks, x
sta controller_b_btns
jmp end

next_attack:
inx
dey
bne check_one_attack

; Move in the direction of the opponent
lda player_a_y             ;
cmp player_b_y             ;
bcs check_directions       ; Jump if the opponent is higher
lda #CONTROLLER_INPUT_JUMP ;
sta controller_b_btns      ;
check_directions:
lda player_a_x              ;
cmp player_b_x              ;
bcs go_right                ;
lda #CONTROLLER_INPUT_LEFT  ;
jmp direction_choosen       ; Choose left or right
go_right:                   ; (independently of jumping)
lda #CONTROLLER_INPUT_RIGHT ;
direction_choosen:          ;
ora controller_b_btns       ;
sta controller_b_btns       ;

end:
rts
.)

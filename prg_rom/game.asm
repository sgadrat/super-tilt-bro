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
beq set_falling_state
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

; Check if a movement collide with an obstacle
;  tmpfield1 - Original position X
;  tmpfield2 - Original position Y
;  tmpfield3 - Final position X (high byte)
;  tmpfield4 - Final position Y (high byte)
;  tmpfield5 - Obstacle top-left X
;  tmpfield6 - Obstacle top-left Y
;  tmpfield7 - Obstacle bottom-right X
;  tmpfield8 - Obstacle bottom-right Y
;  tmpfield9 - Final position X (low byte)
;  tmpfield10 - Final position Y (low byte)
;
; tmpfield3, tmpfield4, tmpfield9 and tmpfield10 are rewritten with a final position that do not pass through obstacle.
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
final_x_low = tmpfield9
final_y_low = tmpfield10

; Check collision with left edge
lda final_y         ;
cmp obstacle_top    ;
bcc top_edge        ; Skip lateral edges collision checks if
lda obstacle_bottom ; the player is over or under the obstacle
cmp final_y         ;
bcc top_edge        ;

lda orig_x          ; Set final_x to obstacle_left if original position
cmp obstacle_left   ; is on the left of the edge and final position on
bcs right_edge      ; the right of the edge.
lda final_x         ;
cmp obstacle_left   ; When high bytes are equal to obstacle_left ensure low byte
bcc right_edge      ; is 0, this is a limitation if origx_x_low differs from 0
lda obstacle_left   ; since the point is already inside the obstacle. Should
sta final_x         ; work as long as points never fo in obstacles. Else inside
dec final_x         ; obstacle for less than one pixel is considered outside.
lda #$ff            ;
sta final_x_low     ;

; Check collision with right edge
right_edge:
lda obstacle_right
cmp orig_x
bcs top_edge
lda obstacle_right
cmp final_x
bcc top_edge
sta final_x
inc final_x
lda #$00
sta final_x_low

; Check collision with top edge
top_edge:
lda final_x        ;
cmp obstacle_left  ;
bcc end            ; Skip horizontal edges collision checks if
lda obstacle_right ; the player is aside of the obstacle
cmp final_x        ;
bcc end            ;

lda orig_y
cmp obstacle_top
bcs bot_edge
lda final_y
cmp obstacle_top
bcc bot_edge
lda obstacle_top
sta final_y
dec final_y
lda #$ff
sta final_y_low

; Check collision with bottom edge
bot_edge:
lda obstacle_bottom
cmp orig_y
bcs end
lda obstacle_bottom
cmp final_y
bcc end
sta final_y
inc final_y
lda #$00
sta final_y_low

end:
rts
.)

; Check if a movement passes through a line from above to under
;  tmpfield2 - Original position Y
;  tmpfield3 - Final position X (high byte)
;  tmpfield4 - Final position Y (high byte)
;  tmpfield5 - Obstacle top-left X
;  tmpfield6 - Obstacle top-left Y
;  tmpfield7 - Obstacle bottom-right X
;  tmpfield10 - Final position Y (low byte)
;
; tmpfield3, tmpfield4, tmpfield9 and tmpfield10 are rewritten with a final position that do not pass through obstacle.
check_top_collision:
.(
; Better names for labels
orig_y = tmpfield2
final_x = tmpfield3
final_y = tmpfield4
obstacle_left = tmpfield5
obstacle_top = tmpfield6
obstacle_right = tmpfield7
final_y_low = tmpfield10

lda final_x        ;
cmp obstacle_left  ;
bcc end            ; Skip horizontal edges collision checks if
lda obstacle_right ; the player is aside of the obstacle
cmp final_x        ;
bcc end            ;

lda orig_y
cmp obstacle_top
bcs end
lda final_y
cmp obstacle_top
bcc end
lda obstacle_top
sta final_y
dec final_y
lda #$ff
sta final_y_low

end:
rts
.)

; Check if two rectangles collide
;  tmpfield1 - Rectangle 1 left
;  tmpfield2 - Rectangle 1 right
;  tmpfield3 - Rectangle 1 top
;  tmpfield4 - Rectangle 1 bottom
;  tmpfield5 - Rectangle 2 left
;  tmpfield6 - Rectangle 2 right
;  tmpfield7 - Rectangle 2 top
;  tmpfield8 - Rectangle 2 botto
;
; tmpfield9 is set to #$00 if rectangles overlap, or to #$01 otherwise
boxes_overlap:
.(
rect1_left = tmpfield1
rect1_right = tmpfield2
rect1_top = tmpfield3
rect1_bottom = tmpfield4
rect2_left = tmpfield5
rect2_right = tmpfield6
rect2_top = tmpfield7
rect2_bottom = tmpfield8

; No overlap possible if left of rect1 is on the right of rect2
lda rect1_left
cmp rect2_right
bcs no_overlap

; No overlap possible if left of rect2 is on the right of rect1
lda rect2_left
cmp rect1_right
bcs no_overlap

; No overlap possible if top of rect1 is lower than bottom of rect2
lda rect1_top
cmp rect2_bottom
bcs no_overlap

; No overlap possible if top of rect1 is lower than bottom of rect2
lda rect2_top
cmp rect1_bottom
bcs no_overlap

; No impossibility found, rectangles overlap at least partially
lda #$00
sta tmpfield9
jmp end

; No overlap found
no_overlap:
lda #$01
sta tmpfield9

end:
rts
.)

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

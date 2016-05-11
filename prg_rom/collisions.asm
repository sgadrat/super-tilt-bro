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

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
;  tmpfiedl11 - Final position X (screen byte)
;  tmpfield12 - Final position Y (screen byte)
;  tmpfield13 - Original position X (screen byte)
;  tmpfield14 - Original position y (screen byte)
;  stack+6 - Obstacle top-left X (screen byte)
;  stack+5 - Obstacle top-left Y (screen byte)
;  stack+4 - Obstacle bottom-right X (screen byte)
;  stack+3 - Obstacle bottom-right Y (screen byte)
;
; Overwrites register X and tmpfield15
;  tmpfield3, tmpfield4, tmpfield9, tmpfield10, tmpfield11 and tmpfield12 are rewritten with a final position that do not pass through obstacle.
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
	final_x_screen = tmpfield11
	final_y_screen = tmpfield12
	orig_x_screen = tmpfield13
	orig_y_screen = tmpfield14
#define LDA_OBSTACLE_LEFT_SCREEN() tsx:lda stack+6, x
#define LDA_OBSTACLE_TOP_SCREEN() tsx:lda stack+5, x
#define LDA_OBSTACLE_RIGHT_SCREEN() tsx:lda stack+4, x
#define LDA_OBSTACLE_BOTTOM_SCREEN() tsx:lda stack+3, x
;TODO we do not use x, so call tsx just once at the begining
	obstacle_top_screen = tmpfield15
	obstacle_bottom_screen = tmpfield15
	obstacle_left_screen = tmpfield15
	obstacle_right_screen = tmpfield15

	; Skip vertical edges collision checks if the player is over or under the obstacle
	LDA_OBSTACLE_TOP_SCREEN()
	sta obstacle_top_screen
	SIGNED_CMP(final_y, final_y_screen, obstacle_top, obstacle_top_screen)
	bmi horizontal_edges
	LDA_OBSTACLE_BOTTOM_SCREEN()
	sta obstacle_bottom_screen
	SIGNED_CMP(obstacle_bottom, obstacle_bottom_screen, final_y, final_y_screen)
	bmi horizontal_edges

	; Check collision with left edge
	left_edge:
		LDA_OBSTACLE_LEFT_SCREEN()                                                   ;
		sta obstacle_left_screen                                                     ;
		SIGNED_CMP(obstacle_left, obstacle_left_screen, orig_x, orig_x_screen)       ; Do not collide if original position is on the right of the edge
		bmi right_edge                                                               ; nor if final position is on the left of the edge
			SIGNED_CMP(final_x, final_x_screen, obstacle_left, obstacle_left_screen) ;
			bmi right_edge                                                           ;

				lda #$ff                 ;
				sta final_x_low          ;
				lda obstacle_left        ;
				sec                      ; Collide against the left edge
				sbc #1                   ;  Sets final position to edge position minus one sub-pixel
				sta final_x              ;
				lda obstacle_left_screen ;
				sbc #0                   ;
				sta final_x_screen       ;

	; Check collision with right edge
	right_edge:
		LDA_OBSTACLE_RIGHT_SCREEN()                                                    ;
		sta obstacle_right_screen                                                      ;
		SIGNED_CMP(orig_x, orig_x_screen, obstacle_right, obstacle_right_screen)       ; Do not collide if original position is on the left of the edge
		bmi horizontal_edges                                                           ; nor if final position is on the right of the edge
			SIGNED_CMP(obstacle_right, obstacle_right_screen, final_x, final_x_screen) ;
			bmi horizontal_edges                                                       ;

				lda #$00                  ;
				sta final_x_low           ;
				lda obstacle_right        ;
				clc                       ; Collide against the right edge
				adc #1                    ;  Sets final position to edge position plus one pixel (consider the obstacle filling its last pixel)
				sta final_x               ;
				lda obstacle_right_screen ;
				adc #0                    ;
				sta final_x_screen        ;

	horizontal_edges:
	; Skip horizontal edges collision checks if the player is aside of the obstacle
	LDA_OBSTACLE_LEFT_SCREEN()
	sta obstacle_left_screen
	SIGNED_CMP(final_x, final_x_screen, obstacle_left, obstacle_left_screen)
	bmi end
	LDA_OBSTACLE_RIGHT_SCREEN()
	sta obstacle_right_screen
	SIGNED_CMP(obstacle_right, obstacle_right_screen, final_x, final_x_screen)
	bmi end

	; Check collision with top edge
	top_edge:
		LDA_OBSTACLE_TOP_SCREEN()                                                  ;
		sta obstacle_top_screen                                                    ;
		SIGNED_CMP(obstacle_top, obstacle_top_screen, orig_y, orig_y_screen)       ; Do not collide if original position is on the under of edge
		bmi bot_edge                                                               ; nor if final position is on above the edge
			SIGNED_CMP(final_y, final_y_screen, obstacle_top, obstacle_top_screen) ;
			bmi bot_edge                                                           ;

				lda #$ff                ;
				sta final_y_low         ;
				lda obstacle_top        ;
				sec                     ; Collide against the top edge
				sbc #1                  ;  Sets final position to edge position minus one sub-pixel
				sta final_y             ;
				lda obstacle_top_screen ;
				sbc #0                  ;
				sta final_y_screen      ;

	; Check collision with bottom edge
	bot_edge:
		LDA_OBSTACLE_BOTTOM_SCREEN()                                                     ;
		sta obstacle_bottom_screen                                                       ;
		SIGNED_CMP(obstacle_bottom, obstacle_bottom_screen, orig_y, orig_y_screen)       ; Do not collide if original position is on the under of edge
		bmi end                                                                          ; nor if final position is on above the edge
			SIGNED_CMP(final_y, final_y_screen, obstacle_bottom, obstacle_bottom_screen) ;
			bmi end                                                                      ;

				lda #$00                   ;
				sta final_y_low            ;
				lda obstacle_bottom        ;
				clc                        ; Collide against the bottom edge
				adc #1                     ;  Sets final position to edge position plus one pixel (consider the obstacle filling its last pixel)
				sta final_y                ;
				lda obstacle_bottom_screen ;
				adc #0                     ;
				sta final_y_screen         ;

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
;  tmpfiedl11 - Final position X (screen byte)
;  tmpfield12 - Final position Y (screen byte)
;  tmpfield14 - Original position y (screen byte)
;  stack+5 - Obstacle top-left X (screen byte)
;  stack+4 - Obstacle top-left Y (screen byte)
;  stack+3 - Obstacle bottom-right X (screen byte)
;
; Overwrites register X and tmpfield15
;  tmpfield3, tmpfield4, tmpfield10, tmpfield11 and tmpfield12 are rewritten with a final position that do not pass through obstacle.
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
	final_x_screen = tmpfield11
	final_y_screen = tmpfield12
	orig_y_screen = tmpfield14
#define LDA_OBSTACLE_LEFT_SCREEN() tsx:lda stack+5, x
#define LDA_OBSTACLE_TOP_SCREEN() tsx:lda stack+4, x
#define LDA_OBSTACLE_RIGHT_SCREEN() tsx:lda stack+3, x
	obstacle_top_screen = tmpfield15
	obstacle_left_screen = tmpfield15
	obstacle_right_screen = tmpfield15

	; Skip horizontal edges collision checks if the player is aside of the obstacle
	LDA_OBSTACLE_LEFT_SCREEN()
	sta obstacle_left_screen
	SIGNED_CMP(final_x, final_x_screen, obstacle_left, obstacle_left_screen)
	bmi end
	LDA_OBSTACLE_RIGHT_SCREEN()
	sta obstacle_right_screen
	SIGNED_CMP(obstacle_right, obstacle_right_screen, final_x, final_x_screen)
	bmi end

		LDA_OBSTACLE_TOP_SCREEN()                                                  ;
		sta obstacle_top_screen                                                    ;
		SIGNED_CMP(obstacle_top, obstacle_top_screen, orig_y, orig_y_screen)       ; Do not collide if original position is under the edge
		bmi end                                                                    ; nor if final position is above the edge
			SIGNED_CMP(final_y, final_y_screen, obstacle_top, obstacle_top_screen) ;
			bmi end                                                                ;

				lda #$ff                ;
				sta final_y_low         ;
				lda obstacle_top        ;
				sec                     ; Collide against the top edge
				sbc #1                  ;  Sets final position to edge position minus one sub-pixel
				sta final_y             ;
				lda obstacle_top_screen ;
				sbc #0                  ;
				sta final_y_screen      ;

	end:
	rts
.)

; Check if two rectangles collide
;  tmpfield1 - Rectangle 1 left (pixel)
;  tmpfield2 - Rectangle 1 right (pixel)
;  tmpfield3 - Rectangle 1 top (pixel)
;  tmpfield4 - Rectangle 1 bottom (pixel)
;  tmpfield5 - Rectangle 2 left (pixel)
;  tmpfield6 - Rectangle 2 right (pixel)
;  tmpfield7 - Rectangle 2 top (pixel)
;  tmpfield8 - Rectangle 2 bottom (pixel)
;  tmpfield9 - Rectangle 1 left (screen)
;  tmpfield10 - Rectangle 1 right (screen)
;  tmpfield11 - Rectangle 1 top (screen)
;  tmpfield12 - Rectangle 1 bottom (screen)
;  tmpfield13 - Rectangle 2 left (screen)
;  tmpfield14 - Rectangle 2 right (screen)
;  tmpfield15 - Rectangle 2 top (screen)
;  tmpfield16 - Rectangle 2 bottom (screen)
;
; register A is set to #$00 if rectangles overlap, or to #$01 otherwise
; zero flag is set if rectangles overlap, or not set otherwise
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
	rect1_left_msb = tmpfield9
	rect1_right_msb = tmpfield10
	rect1_top_msb = tmpfield11
	rect1_bottom_msb = tmpfield12
	rect2_left_msb = tmpfield13
	rect2_right_msb = tmpfield14
	rect2_top_msb = tmpfield15
	rect2_bottom_msb = tmpfield16

	; No overlap possible if right of rect2 is on the left of rect1
	SIGNED_CMP(rect2_right, rect2_right_msb, rect1_left, rect1_left_msb)
	bmi no_overlap

	; No overlap possible if right of rect1 is on the left of rect2
	SIGNED_CMP(rect1_right, rect1_right_msb, rect2_left, rect2_left_msb)
	bmi no_overlap

	; No overlap possible if bottom of rect2 is higher than top of rect1
	SIGNED_CMP(rect2_bottom, rect2_bottom_msb, rect1_top, rect1_top_msb)
	bmi no_overlap

	; No overlap possible if bottom of rect1 is higher than top of rect2
	SIGNED_CMP(rect1_bottom, rect1_bottom_msb, rect2_top, rect2_top_msb)
	bmi no_overlap

	; No impossibility found, rectangles overlap at least partially
	lda #$00
	jmp end

	; No overlap found
	no_overlap:
	lda #$01

	end:
	rts
.)

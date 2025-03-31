;
; Standard ringout check behaviour
;

; stage_name - Lowercase name of the stage (stage_name's definition is not undefined at the end of this template.)
; blastline_left - Position of the left blastline (defaults to STAGE_BLAST_LEFT)
; blastline_right - Position of the  blastline (defaults to STAGE_BLAST_RIGHT)
; blastline_top - Position of the  blastline (defaults to STAGE_BLAST_TOP)
; blastline_bottom - Position of the  blastline (defaults to STAGE_BLAST_BOTTOM)

!default "blastline_left" {STAGE_BLAST_LEFT}
!default "blastline_right" {STAGE_BLAST_RIGHT}
!default "blastline_top" {STAGE_BLAST_TOP}
!default "blastline_bottom" {STAGE_BLAST_BOTTOM}

; Check if a player is out of the stage's bounds
;  register X - player number
;  tmpfield4 - player's current X pixel
;  tmpfield7 - player's current Y pixel
;  tmpfield5 - player's current X screen
;  tmpfield8 - player's current Y screen
;
; Output:
;  tmpfield1 - 0 if no collision happened, 1 i player is behind a blastline
;
; Implementation is allowed to modify tmpfield1 to tmpfield3, register A and register Y
+{stage_name}_ringout_check:
.(
	current_x_pixel = tmpfield4
	current_x_screen = tmpfield5
	current_y_pixel = tmpfield7
	current_y_screen = tmpfield8

	SIGNED_CMP(current_x_pixel, current_x_screen, #<{blastline_left}, #>{blastline_left})
	bmi ringout
	SIGNED_CMP(#<{blastline_right}, #>{blastline_right}, current_x_pixel, current_x_screen)
	bmi ringout
	SIGNED_CMP(current_y_pixel, current_y_screen, #<{blastline_top}, #>{blastline_top})
	bmi ringout
	SIGNED_CMP(#<{blastline_bottom}, #>{blastline_bottom}, current_y_pixel, current_y_screen)
	bmi ringout
		on_stage:
			lda #0
			sta tmpfield1
			rts
		ringout:
			lda #1
			sta tmpfield1
			rts
	;rts ; useless, no branch returns
.)

!undef "blastline_left"
!undef "blastline_right"
!undef "blastline_top"
!undef "blastline_bottom"

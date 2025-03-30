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

	SIGNED_CMP(current_x_pixel, current_x_screen, #<STAGE_BLAST_LEFT, #>STAGE_BLAST_LEFT)
	bmi ringout
	SIGNED_CMP(#<STAGE_BLAST_RIGHT, #>STAGE_BLAST_RIGHT, current_x_pixel, current_x_screen)
	bmi ringout
	SIGNED_CMP(current_y_pixel, current_y_screen, #<STAGE_BLAST_TOP, #>STAGE_BLAST_TOP)
	bmi ringout
	SIGNED_CMP(#<STAGE_BLAST_BOTTOM, #>STAGE_BLAST_BOTTOM, current_y_pixel, current_y_screen)
	bmi ringout
		on_stage:
			lda #0
			sta tmpfield1
			rts
		ringout:
			lda 1
			sta tmpfield1
			rts
	;rts ; useless, no branch returns
.)

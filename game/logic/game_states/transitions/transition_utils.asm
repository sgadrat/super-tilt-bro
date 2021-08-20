#iflused dummy_transition

; Dummy transition, just ensuring the camera is place on top of the top nametable and re-enabling rendering
dummy_transition:
.(
	lda #0
	sta scroll_y

	lda #%10010000 ; NMI enabled, background pattern table at $1000, base nametable is top left
	sta ppuctrl_val
	sta PPUCTRL

	jsr sleep_frame  ; Avoid re-enabling mid-frame

	lda #%00011110 ; Enable sprites and background rendering
	sta PPUMASK    ;

	rts
.)
#endif

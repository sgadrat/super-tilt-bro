+rescue_fetch_controllers:
.(
	; Fetch controllers state
	lda #$01
	sta CONTROLLER_A
	lda #$00
	sta CONTROLLER_A

	; x will contain the controller number to fetch (0 or 1)
	ldx #$00

	fetch_one_controller:

	; Reset the controller's byte
	lda #$00
	sta rescue_controller_a_btns, x

	; Fetch the controller's byte button by button
	ldy #$08
	next_btn:
		lda CONTROLLER_A, x
		and #%00000011
		cmp #1
		rol rescue_controller_a_btns, x
		dey
		bne next_btn

	; Next controller
	inx
	cpx #$02
	bne fetch_one_controller

	rts
.)

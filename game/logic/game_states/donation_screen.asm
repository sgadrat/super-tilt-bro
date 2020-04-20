init_donation_screen:
.(
	SWITCH_BANK(#DATA_BANK_NUMBER)

	; Construct nt buffers for palettes (to avoid changing it mid-frame)
	lda #<palette_donation
	sta tmpfield1
	lda #>palette_donation
	sta tmpfield2
	jsr construct_palettes_nt_buffer

	; Copy background from PRG-rom to PPU nametable
	lda #<nametable_donation
	sta tmpfield1
	lda #>nametable_donation
	sta tmpfield2
	jsr draw_zipped_nametable

	; Initialize common menus effects
	jsr re_init_menu

	; Initialize state
	lda #0
	sta donation_method

	rts
.)

donation_screen_tick:
.(
	jsr reset_nt_buffers
	SWITCH_BANK(#DATA_BANK_NUMBER)

	; Play common menus effects
	jsr tick_menu

	; Check inputs
	ldx #0
	check_one_controller:
		lda controller_a_btns, x
		bne next_controller
		lda controller_a_last_frame_btns, x
		beq next_controller

			cmp #CONTROLLER_BTN_LEFT
			beq go_left

			cmp #CONTROLLER_BTN_RIGHT
			beq go_right

			cmp #CONTROLLER_BTN_B
			beq go_back

			cmp #CONTROLLER_BTN_START
			beq go_next_screen

			cmp #CONTROLLER_BTN_A
			beq go_next_screen

		next_controller:
			inx
			cpx #2
			bne check_one_controller

		jmp no_press

		go_back:
		.(
			lda #GAME_STATE_MODE_SELECTION
			jsr change_global_game_state
			;jmp no_press ; useless, change_global_game_state does not return
		.)

		go_next_screen:
		.(
			ldx donation_method
			lda option_to_game_state, x
			jsr change_global_game_state
			;jmp no_press ; useless, change_global_game_state does not return
		.)

		go_left:
		go_right:
		.(
			dec donation_method
			bpl ok
				lda #1
				sta donation_method
			ok:
			;jmp no_press ; fallthrough
		.)

	no_press:


	; Highlight currently selected option
	lda #<nt_header
	sta tmpfield1
	lda #>nt_header
	sta tmpfield2

	ldx donation_method
	lda nt_payload_addr_lsb, x
	sta tmpfield3
	lda nt_payload_addr_msb, x
	sta tmpfield4

	jsr construct_nt_buffer


	end:
	rts

	option_to_game_state:
		.byt GAME_STATE_DONATION_BTC, GAME_STATE_DONATION_PAYPAL

	nt_header:
		.byt $23, $f1, $06
	nt_payload_btc:
		.byt %00001010, %00001010, %00001010, %00000000, %00000000, %00000000
	nt_payload_paypal:
		.byt %00000000, %00000000, %00000000, %00001010, %00001010, %00001010

	nt_payload_addr_lsb:
		.byt <nt_payload_btc, <nt_payload_paypal
	nt_payload_addr_msb:
		.byt >nt_payload_btc, >nt_payload_paypal
.)

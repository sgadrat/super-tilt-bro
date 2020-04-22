init_mode_selection_screen:
.(
	; Copy menus tileset in CHR-RAM
	jsr set_menu_chr

	SWITCH_BANK(#DATA_BANK_NUMBER)

	; Construct nt buffers for palettes (to avoid changing it mid-frame)
	lda #<palette_mode_selection
	sta tmpfield1
	lda #>palette_mode_selection
	sta tmpfield2
	jsr construct_palettes_nt_buffer

	; Copy background from PRG-rom to PPU nametable
	lda #<nametable_mode_selection
	sta tmpfield1
	lda #>nametable_mode_selection
	sta tmpfield2
	jsr draw_zipped_nametable

	; Initialize common menus effects
	jsr re_init_menu

	; Initialize state
	lda #1
	sta mode_selection_current_option

	rts
.)

mode_selection_screen_tick:
.(
	.(
		jsr reset_nt_buffers

		; Play common menus effects
		jsr tick_menu

		; Go to a screen or another depending on button released this frame
		ldx #0
		check_one_controller:
			lda controller_a_btns, x
			bne next_controller
			lda controller_a_last_frame_btns, x
			beq next_controller

				cmp #CONTROLLER_BTN_UP
				beq go_up

				cmp #CONTROLLER_BTN_DOWN
				beq go_down

				cmp #CONTROLLER_BTN_LEFT
				beq go_left

				cmp #CONTROLLER_BTN_RIGHT
				beq go_right

				cmp #CONTROLLER_BTN_B
				beq go_title

				cmp #CONTROLLER_BTN_START
				beq go_next_screen

				cmp #CONTROLLER_BTN_A
				beq go_next_screen

			next_controller:
				inx
				cpx #2
				bne check_one_controller

		no_press:
			jmp end

		go_down:
		go_up:
		.(
			lda mode_selection_current_option
			cmp #2
			beq from_donation
				lda #2
				.byt $2c ; absolute BIT, effectively skipping the next LDA
			from_donation:
				lda #0
			sta mode_selection_current_option
			jmp end
		.)

		go_left:
			dec mode_selection_current_option
			bpl end
				lda #2
				sta mode_selection_current_option
			jmp end

		go_right:
			inc mode_selection_current_option
			lda mode_selection_current_option
			cmp #3
			bne end
				lda #0
				sta mode_selection_current_option
			jmp end

		go_title:
			lda #GAME_STATE_TITLE
			jsr change_global_game_state

		go_next_screen:
			ldx mode_selection_current_option
			lda option_to_game_state, x
			jsr change_global_game_state

		end:
			jsr show_selected_option
			rts

		option_to_game_state:
			.byt GAME_STATE_NO_LOCAL, GAME_STATE_NETPLAY_LAUNCH, GAME_STATE_DONATION
	.)

	show_selected_option:
	.(
		lda #<nt_header
		sta tmpfield1
		lda #>nt_header
		sta tmpfield2

		ldx mode_selection_current_option
		lda nt_payload_addr_lsb, x
		sta tmpfield3
		lda nt_payload_addr_msb, x
		sta tmpfield4

		jsr construct_nt_buffer

		rts

		nt_header:
			.byt $23, $d1, $15
		nt_payload_local:
			.byt %01010101, %01010101, %01010101, 0, 0, 0 ,0, 0, %01010101, %01010101, %01010101, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
		nt_payload_online:
			.byt 0, 0, 0, %01010101, %01010101, %01010101, %01010101, 0, 0, 0, 0, %01010101, %01010101, %01010101, %01010101, 0, 0, 0, 0, 0, 0
		nt_payload_donation:
			.byt 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, %01010101, %01010101, %01010101, %01010101

		nt_payload_addr_lsb:
			.byt <nt_payload_local, <nt_payload_online, <nt_payload_donation
		nt_payload_addr_msb:
			.byt >nt_payload_local, >nt_payload_online, >nt_payload_donation
	.)
.)

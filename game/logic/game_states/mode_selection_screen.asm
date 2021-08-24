init_mode_selection_screen:
.(
	SWITCH_BANK(#MENU_MODE_SELECTION_SCREEN_BANK)

	; Construct nt buffers for palettes (to avoid changing it mid-frame)
	lda #<menu_mode_selection_palette
	sta tmpfield1
	lda #>menu_mode_selection_palette
	sta tmpfield2
	jsr construct_palettes_nt_buffer

	; Copy background from PRG-rom to PPU nametable
	lda #<nametable_mode_selection
	sta tmpfield1
	lda #>nametable_mode_selection
	sta tmpfield2
	jsr draw_zipped_nametable

	SWITCH_BANK(#MENU_MODE_SELECTION_TILESET_BANK)

	lda #<tileset_menu_mode_selection
	sta tmpfield1
	lda #>tileset_menu_mode_selection
	sta tmpfield2
	jsr cpu_to_ppu_copy_tileset_background

	SWITCH_BANK(#CHARSET_ALPHANUM_BANK_NUMBER)

	lda #<charset_alphanum
	sta tmpfield3
	lda #>charset_alphanum
	sta tmpfield4
	lda PPUSTATUS
	lda #$1d
	sta PPUADDR
	lda #$c0
	sta PPUADDR
	ldx #%00000111
	jsr cpu_to_ppu_copy_charset

	; Initialize common menus effects
	jsr re_init_menu

	; Initialize state
	lda config_game_mode
	sta mode_selection_current_option
	jmp mode_selection_screen_show_selected_option

	;rts ; Useless, jump to subroutine
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
#ifdef NO_NETWORK
			cpx #GAME_MODE_ONLINE
			beq end
#endif
			stx config_game_mode
			lda option_to_game_state, x
			jsr change_global_game_state

		end:
			jmp mode_selection_screen_show_selected_option
			;rts ; useless, jump to subroutine

		option_to_game_state:
			.byt GAME_STATE_CONFIG, GAME_STATE_ONLINE_MODE_SELECTION, GAME_STATE_DONATION
	.)
.)

mode_selection_screen_show_selected_option:
.(
	lda #<nt_highlight_header
	sta tmpfield1
	lda #>nt_highlight_header
	sta tmpfield2

	ldx mode_selection_current_option
	lda nt_highlight_payload_addr_lsb, x
	sta tmpfield3
	lda nt_highlight_payload_addr_msb, x
	sta tmpfield4

	jsr construct_nt_buffer

	rts

#ifndef NO_NETWORK
	nt_highlight_header:
		.byt $23, $d1, $15
	nt_highlight_payload_local:
		.byt            %01010101, %01010101, %01010101, %00000000, %00000000, %00000000, %00000000,
		.byt %00000000, %01010101, %01010101, %01010101, %00000000, %00000000, %00000000, %00000000,
		.byt %00000000, %00000000, %00000000, %00000000, %00000000, %00000000,
	nt_highlight_payload_online:
		.byt            %00000000, %00000000, %00000000, %01010101, %01010101, %01010101, %01010101,
		.byt %00000000, %00000000, %00000000, %00000000, %01010101, %01010101, %01010101, %01010101,
		.byt %00000000, %00000000, %00000000, %00000000, %00000000, %00000000,
	nt_highlight_payload_donation:
		.byt            %00000000, %00000000, %00000000, %00000000, %00000000, %00000000, %00000000,
		.byt %00000000, %00000000, %00000000, %00000000, %00000000, %00000000, %00000000, %00000000,
		.byt %00000000, %00000000, %01010101, %01010101, %01010101, %01010101
#else
	nt_highlight_header:
		.byt $23, $d1, $15
	nt_highlight_payload_local:
		.byt            %01010101, %01010101, %01010101, %10101010, %10101010, %10101010, %10101010,
		.byt %00000000, %01010101, %01010101, %01010101, %10101010, %10101010, %10101010, %10101010,
		.byt %00000000, %00000000, %00000000, %00000000, %00000000, %00000000,
	nt_highlight_payload_online:
		.byt            %00000000, %00000000, %00000000, %11111111, %11111111, %11111111, %11111111,
		.byt %00000000, %00000000, %00000000, %00000000, %11111111, %11111111, %11111111, %11111111,
		.byt %00000000, %00000000, %00000000, %00000000, %00000000, %00000000,
	nt_highlight_payload_donation:
		.byt            %00000000, %00000000, %00000000, %10101010, %10101010, %10101010, %10101010,
		.byt %00000000, %00000000, %00000000, %00000000, %10101010, %10101010, %10101010, %10101010,
		.byt %00000000, %00000000, %01010101, %01010101, %01010101, %01010101
#endif

	nt_highlight_payload_addr_lsb:
		.byt <nt_highlight_payload_local, <nt_highlight_payload_online, <nt_highlight_payload_donation
	nt_highlight_payload_addr_msb:
		.byt >nt_highlight_payload_local, >nt_highlight_payload_online, >nt_highlight_payload_donation
.)

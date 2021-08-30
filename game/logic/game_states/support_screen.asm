init_support_screen:
.(
	; Copy tileset in CHR-RAM
	SWITCH_BANK(#CHARSET_QR_CODE_BANK_NUMBER)
	lda PPUSTATUS
	lda #$19
	sta PPUADDR
	lda #$00
	sta PPUADDR
	lda #<charset_qr_code
	sta tmpfield3
	lda #>charset_qr_code
	sta tmpfield4
	ldx #%00000111
	jsr cpu_to_ppu_copy_charset

	SWITCH_BANK(#CHARSET_ASCII_BANK_NUMBER)
	lda #<charset_ascii
	sta tmpfield3
	lda #>charset_ascii
	sta tmpfield4
	ldx #%00000111
	jsr cpu_to_ppu_copy_charset ; Note - expects PPUADDR to be at the end of QR code tiles ($1a00)

	SWITCH_BANK(#MENU_SUPPORT_TILESETS_BANK_NUMBER)
	lda #<tileset_menu_support_background
	sta tmpfield1
	lda #>tileset_menu_support_background
	sta tmpfield2
	jsr cpu_to_ppu_copy_tileset_background

	; Construct nt buffers for palettes (to avoid changing it mid-frame)
	SWITCH_BANK(#MENU_SUPPORT_SCREEN_BANK_NUMBER)
	lda #<palette_support
	sta tmpfield1
	lda #>palette_support
	sta tmpfield2
	jsr construct_palettes_nt_buffer

	; Copy background from PRG-rom to PPU nametable
	lda #<menu_support_nametable_bg
	sta tmpfield1
	lda #>menu_support_nametable_bg
	sta tmpfield2
	jsr draw_zipped_nametable

	; Draw text
	SWITCH_BANK(#MENU_SUPPORT_SCREEN_BANK_NUMBER)
	lda #<menu_support_contents
	sta tmpfield1
	lda #>menu_support_contents
	sta tmpfield2
	jsr support_screen_draw_contents

	; Initialize common menus effects
	jsr re_init_menu

	; Initialize state
	lda #0
	sta support_method

	rts
.)

support_screen_draw_contents:
.(
	txt_ptr = tmpfield1
	txt_ptr_msb = tmpfield2
	screen_offset = tmpfield3
	screen_offset_msb = tmpfield4

	CHARS_PER_LINE = 24
	NB_LINES = 18

	lda #$04
	sta screen_offset
	lda #$21
	sta screen_offset_msb

	ldx #NB_LINES
	copy_one_line:
	.(
		; Point PPU to the first char of the line
		lda PPUSTATUS
		lda screen_offset_msb
		sta PPUADDR
		lda screen_offset
		sta PPUADDR

		; Copy characters
		ldy #0
		copy_one_char:
			; Get tile index
			;  Printable ascii are converted to equivalent tile index,
			;  others are kept raw.
			lda (txt_ptr), y
			cmp #32
			bcc tile_value_ok
			cmp #128
			bcs tile_value_ok
				clc
				adc #128
			tile_value_ok:

			; Write character in nametable
			sta PPUDATA

			; Loop
			iny
			cpy #CHARS_PER_LINE
			bne copy_one_char

		; Update PPU and CPU addresses
		.(
			lda txt_ptr
			clc
			adc #CHARS_PER_LINE
			sta txt_ptr
			bcc ok
				inc txt_ptr_msb
			ok:
		.)
		.(
			lda screen_offset
			clc
			adc #32
			sta screen_offset
			bcc ok
				inc screen_offset_msb
			ok:
		.)

		; Loop
		dex
		bne copy_one_line
	.)

	rts
.)

support_screen_tick:
.(
	jsr reset_nt_buffers

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
			ldx support_method
			lda option_to_game_state, x
			jsr change_global_game_state
			;jmp no_press ; useless, change_global_game_state does not return
		.)

		go_left:
		go_right:
		.(
			dec support_method
			bpl ok
				lda #1
				sta support_method
			ok:
			;jmp no_press ; fallthrough
		.)

	no_press:


	; Highlight currently selected option
	lda #<nt_header
	sta tmpfield1
	lda #>nt_header
	sta tmpfield2

	ldx support_method
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

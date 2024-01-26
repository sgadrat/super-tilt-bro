+SOCIAL_SCREEN_EXTRA_BANK_NUMBER = CURRENT_BANK_NUMBER

link_position_x = 96
first_link_position_y = 160
link_position_y:
	.byt first_link_position_y, first_link_position_y+8, first_link_position_y+16
NB_LINKS = * - link_position_y
link_contents_lsb:
	.byt <menu_social_website_link, <menu_social_twitter_link, <menu_social_discord_link
link_contents_msb:
	.byt >menu_social_website_link, >menu_social_twitter_link, >menu_social_discord_link

CURSOR_ANIM_FIRST_SPRITE = 1
CURSOR_ANIM_LAST_SPRITE = 31
CURSOR_ANIM_NUM_SPRITES = CURSOR_ANIM_LAST_SPRITE-CURSOR_ANIM_FIRST_SPRITE+1

+init_social_screen_extra:
.(
	; Copy tileset in CHR-RAM
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
	TRAMPOLINE(cpu_to_ppu_copy_charset, #CHARSET_QR_CODE_BANK_NUMBER, #CURRENT_BANK_NUMBER)

	;lda PPUSTATUS
	;lda #$1a
	;sta PPUADDR
	;lda #$00
	;sta PPUADDR ; Useless, already here after qr code charset copy
	lda #<charset_ascii
	sta tmpfield3
	lda #>charset_ascii
	sta tmpfield4
	ldx #CHARSET_COLOR(1, 3)
	TRAMPOLINE(cpu_to_ppu_copy_charset, #CHARSET_ASCII_BANK_NUMBER, #CURRENT_BANK_NUMBER)

	lda #<tileset_menu_social_background :sta tmpfield1
	lda #>tileset_menu_social_background : sta tmpfield2
	TRAMPOLINE(cpu_to_ppu_copy_tileset_background, #MENU_SOCIAL_TILESETS_BANK_NUMBER, #CURRENT_BANK_NUMBER)

	lda #<tileset_menu_social_sprites : sta tmpfield1
	lda #>tileset_menu_social_sprites : sta tmpfield2
	TRAMPOLINE(cpu_to_ppu_copy_tileset_sprites, #MENU_SOCIAL_TILESETS_BANK_NUMBER, #CURRENT_BANK_NUMBER)

	; Construct nt buffers for palettes (to avoid changing it mid-frame)
	lda #<palette_social
	sta tmpfield1
	lda #>palette_social
	sta tmpfield2
	TRAMPOLINE(construct_palettes_nt_buffer, #MENU_SOCIAL_SCREEN_BANK_NUMBER, #CURRENT_BANK_NUMBER)

	; Copy background from PRG-rom to PPU nametable
	lda #<menu_social_nametable_bg
	sta tmpfield1
	lda #>menu_social_nametable_bg
	sta tmpfield2
	TRAMPOLINE(draw_zipped_nametable, #MENU_SOCIAL_SCREEN_BANK_NUMBER, #CURRENT_BANK_NUMBER)

	; Initialize common menus effects
	jsr re_init_menu

	; Initialize state
	lda #0
	sta social_link
	sta social_link_state
	sta social_draw_step
	lda #<menu_social_contents : sta social_draw_line_addr_lsb
	lda #>menu_social_contents : sta social_draw_line_addr_msb

	; Init animations
	ANIM_INIT(social_cursor_anim, menu_social_anim_cursor)
	ANIM_SET_SPRITES(social_cursor_anim, #CURSOR_ANIM_FIRST_SPRITE, #CURSOR_ANIM_LAST_SPRITE)
	lda #first_link_position_y : sta social_cursor_anim+ANIMATION_STATE_OFFSET_Y_LSB
	lda #link_position_x : sta social_cursor_anim+ANIMATION_STATE_OFFSET_X_LSB

	rts
.)

social_screen_draw_contents:
.(
	CHARS_PER_LINE = 24
	NB_LINES = 18
	NB_STEPS = 9
	NB_LINES_PER_STEP = NB_LINES / NB_STEPS

	line_count = social_mem_buffer+3

	; Do nothing if we are after the last step
	.(
		ldx social_draw_step
		cpx #NB_STEPS
		bcc ok
			rts
		ok:
	.)

	; Construct first nt header
	ldx social_draw_step
	lda step_ppu_addr_msb, x
	sta social_mem_buffer+0
	lda step_ppu_addr_lsb, x
	sta social_mem_buffer+1
	lda #CHARS_PER_LINE
	sta social_mem_buffer+2

	; Construct nt buffers for all lines to draw this step
	lda #NB_LINES_PER_STEP
	sta line_count
	draw_one_line:
		; Construct nt buffer and point to next line's cpu address
		lda #<social_mem_buffer : sta tmpfield1
		lda #>social_mem_buffer : sta tmpfield2
		lda social_draw_line_addr_lsb : sta tmpfield3
		clc : adc #CHARS_PER_LINE : sta social_draw_line_addr_lsb
		lda social_draw_line_addr_msb : sta tmpfield4
		adc #0 : sta social_draw_line_addr_msb
		TRAMPOLINE(construct_nt_buffer, #MENU_SOCIAL_SCREEN_BANK_NUMBER, #CURRENT_BANK_NUMBER)

		; Set next line's PPU address in nt header
		lda social_mem_buffer+1
		clc : adc #32 : sta social_mem_buffer+1
		lda social_mem_buffer+0
		adc #0 : sta social_mem_buffer+0

		; Loop
		dec line_count
		bne draw_one_line

	; Change step
	inc social_draw_step

	rts

	first_line_ppu_addr = $2104
	step_ppu_addr_lsb:
		.byt <first_line_ppu_addr
		.byt <(first_line_ppu_addr+(32*1*NB_LINES_PER_STEP))
		.byt <(first_line_ppu_addr+(32*2*NB_LINES_PER_STEP))
		.byt <(first_line_ppu_addr+(32*3*NB_LINES_PER_STEP))
		.byt <(first_line_ppu_addr+(32*4*NB_LINES_PER_STEP))
		.byt <(first_line_ppu_addr+(32*5*NB_LINES_PER_STEP))
		.byt <(first_line_ppu_addr+(32*6*NB_LINES_PER_STEP))
		.byt <(first_line_ppu_addr+(32*7*NB_LINES_PER_STEP))
		.byt <(first_line_ppu_addr+(32*8*NB_LINES_PER_STEP))
	step_ppu_addr_msb:
		.byt >first_line_ppu_addr
		.byt >(first_line_ppu_addr+(32*1*NB_LINES_PER_STEP))
		.byt >(first_line_ppu_addr+(32*2*NB_LINES_PER_STEP))
		.byt >(first_line_ppu_addr+(32*3*NB_LINES_PER_STEP))
		.byt >(first_line_ppu_addr+(32*4*NB_LINES_PER_STEP))
		.byt >(first_line_ppu_addr+(32*5*NB_LINES_PER_STEP))
		.byt >(first_line_ppu_addr+(32*6*NB_LINES_PER_STEP))
		.byt >(first_line_ppu_addr+(32*7*NB_LINES_PER_STEP))
		.byt >(first_line_ppu_addr+(32*8*NB_LINES_PER_STEP))
#if * - step_ppu_addr_msb <> NB_STEPS
#error steps ppu address table missmatch number of steps
#endif
.)

+social_screen_tick_extra:
.(
	; Play common menus effects
	jsr tick_menu

	; Draw lines of text if needed
	jsr social_screen_draw_contents

	; Call tick routine
	lda social_link_state
	beq social_screen_tick_links_page
	jmp social_screen_tick_link_display

	;rts ; useless, jump to subroutine
.)

social_screen_tick_links_page:
.(
	; Check inputs
	.(
		ldx #0
		check_one_controller:
			lda controller_a_btns, x
			bne next_controller
			cmp controller_a_last_frame_btns, x
			beq next_controller

				jsr audio_play_interface_click

				lda controller_a_last_frame_btns, x
				cmp #CONTROLLER_BTN_DOWN
				beq next_link
				cmp #CONTROLLER_BTN_UP
				beq previous_link
				cmp #CONTROLLER_BTN_B
				beq go_back
				cmp #CONTROLLER_BTN_START
				beq go_link
				cmp #CONTROLLER_BTN_A
				beq go_link

			next_controller:
				inx
				cpx #2
				bne check_one_controller

			jmp ok

			go_back:
			.(
				lda #GAME_STATE_MODE_SELECTION
				jsr change_global_game_state
				;jmp ok ; useless, change_global_game_state does not return
			.)

			next_link:
			.(
				inc social_link
				lda #NB_LINKS
				cmp social_link
				bne ok
					lda #0 : sta social_link
					jmp ok
			.)

			previous_link:
			.(
				dec social_link
				bpl ok
					lda #NB_LINKS-1
					sta social_link
					jmp ok
			.)

			go_link:
			.(
				ldx social_link
				lda link_contents_lsb, x : sta social_draw_line_addr_lsb
				lda link_contents_msb, x : sta social_draw_line_addr_msb

				lda #0
				sta social_draw_step

				inc social_link_state

				jmp ok
			.)

		ok:
	.)

	; Place cursor
	ldx social_link
	lda link_position_y, x : sta social_cursor_anim+ANIMATION_STATE_OFFSET_Y_LSB

	; Update animation
	ANIM_UPDATE(social_cursor_anim)

	rts
.)

social_screen_tick_link_display:
.(
	; Check inputs
	.(
		ldx #0
		check_one_controller:
			lda controller_a_btns, x
			bne next_controller
			cmp controller_a_last_frame_btns, x
			beq next_controller

				jsr audio_play_interface_click

				lda controller_a_last_frame_btns, x
				cmp #CONTROLLER_BTN_A
				beq go_back
				cmp #CONTROLLER_BTN_B
				beq go_back
				cmp #CONTROLLER_BTN_START
				beq go_back

			next_controller:
				inx
				cpx #2
				bne check_one_controller

			jmp ok

			go_back:
			.(
				; Reinitialize page state, and redraw original page contents
				lda #0
				sta social_link_state
				sta social_draw_step
				lda #<menu_social_contents : sta social_draw_line_addr_lsb
				lda #>menu_social_contents : sta social_draw_line_addr_msb
				;jmp ok ; useless, fallthrough
			.)

		ok:
	.)

	; Hide cursor animation
	ldy #CURSOR_ANIM_NUM_SPRITES
	ldx #CURSOR_ANIM_FIRST_SPRITE*4
	lda #$fe
	hide_one_sprite:
		sta oam_mirror, x
		inx:inx:inx:inx
		dey
		bne hide_one_sprite

	rts
.)

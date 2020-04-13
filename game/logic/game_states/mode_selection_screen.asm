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

				cmp #CONTROLLER_BTN_SELECT
				beq go_online

				cmp #CONTROLLER_BTN_B
				beq go_title

				jmp go_local

			next_controller:
				inx
				cpx #2
				bne check_one_controller

		no_press:
			jmp end

		go_online:
			jmp end ; TODO

		go_local:
			lda #GAME_STATE_CONFIG
			jsr change_global_game_state

		go_title:
			lda #GAME_STATE_TITLE
			jsr change_global_game_state

		end:
			rts
	.)
.)

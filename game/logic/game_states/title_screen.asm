init_title_screen:
.(
	; This state only use the generic data bank
	SWITCH_BANK(#DATA_BANK_NUMBER)

	; Clear background of nametable 2
	jsr clear_bg_bot_left

	; Construct nt buffers for palettes (to avoid changing it mid-frame)
	lda #<palette_title
	sta tmpfield1
	lda #>palette_title
	sta tmpfield2
	jsr construct_palettes_nt_buffer

	; Copy background from PRG-rom to PPU nametable
	lda #<nametable_title
	sta tmpfield1
	lda #>nametable_title
	sta tmpfield2
	jsr draw_zipped_nametable

	; Place version number's dot
	lda #213           ; Y
	sta oam_mirror
	lda #TILE_TEXT_DOT ; Tile
	sta oam_mirror+1
	lda #$00           ; Attributes
	sta oam_mirror+2
	lda #215           ; X
	sta oam_mirror+3

	; Reinit cheat code state
	lda #0
	sta title_cheatstate

	; Copy title screen's tileset in CHR-RAM
	jsr set_title_chr

	; Choose between soft (keep continuity) or hard (reboot) initialization of music and menu animations
	lda previous_global_game_state
	cmp #GAME_STATE_CONFIG
	beq soft_init
	cmp #GAME_STATE_CREDITS
	beq soft_init

		; Complete reinitialization
		SWITCH_BANK(#DATA_BANK_NUMBER)
		jsr init_menu
		jsr audio_music_weak
		jmp end_menu_init

	soft_init:
		; Soft reinitialization - keep continuity with previous menu
		jsr re_init_menu

	end_menu_init:

	rts

	; Set the CHR-RAM contents as expected by title screen
	;
	; Overwrites register A, registerY, tmpfield1, tmpfield2, tmpfield3
	;
	; Shall only be called while PPU rendering is turned off
	set_title_chr:
	.(
		tileset_addr = tmpfield1 ; Not movable, used by cpu_to_ppu_copy_tiles
		;tileset_addr_msb = tmpfield2 ; Not movable, used by cpu_to_ppu_copy_tiles
		tiles_count = tmpfield3 ; Not movable, used by cpu_to_ppu_copy_tiles

		lda #<(tileset_logo+1)
		sta tileset_addr
		lda #>(tileset_logo+1)
		sta tileset_addr+1

		SWITCH_BANK(#TILESET_LOGO_BANK_NUMBER)

		lda tileset_logo
		sta tiles_count

		lda PPUSTATUS
		lda #$10
		sta PPUADDR
		lda #$00
		sta PPUADDR

		jsr cpu_to_ppu_copy_tiles

		rts
	.)
.)

title_screen_tick:
.(
	SWITCH_BANK(#DATA_BANK_NUMBER)

	; Play common menus effects
	jsr tick_menu

	; Check for cheat code (controller A only)
	ldx title_cheatstate
	lda controller_a_btns
	cmp controller_a_last_frame_btns
	beq press_any_key
	cmp cheatcode, x
	beq update_cheatcode
	jmp press_any_key

	update_cheatcode:
		cpx #19
		beq cheat_succeed
		inx
		txa
		sta title_cheatstate
		jmp end

		cheat_succeed:
			lda #GAME_STATE_CREDITS
			jsr change_global_game_state

	; If all buttons of any controller are released on this frame, got to the next screen
	press_any_key:
		lda controller_a_btns
		bne check_controller_b
		cmp controller_a_last_frame_btns
		bne next_screen
		check_controller_b:
		lda controller_b_btns
		bne end
		cmp controller_b_last_frame_btns
		bne next_screen
		jmp end

		next_screen:
			lda #GAME_STATE_CONFIG
			jsr change_global_game_state

	end:
		rts

	cheatcode:
		.byt CONTROLLER_BTN_UP, 0, CONTROLLER_BTN_UP, 0, CONTROLLER_BTN_DOWN, 0, CONTROLLER_BTN_DOWN, 0
		.byt CONTROLLER_BTN_LEFT, 0, CONTROLLER_BTN_RIGHT, 0, CONTROLLER_BTN_LEFT, 0, CONTROLLER_BTN_RIGHT, 0
		.byt CONTROLLER_BTN_B, 0, CONTROLLER_BTN_A, 0
.)

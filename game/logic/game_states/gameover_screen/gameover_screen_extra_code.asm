GAMEOVER_SCREEN_EXTRA_CODE_BANK_NUMBER = CURRENT_BANK_NUMBER

#define OAM_BALLOONS 4*32

init_gameover_screen_extra:
.(
	; Set background tileset
	.(
		tileset_addr = tmpfield1 ; Not movable, used by cpu_to_ppu_copy_tileset_background
		;tileset_addr_msb = tmpfield2 ; Not movable, used by cpu_to_ppu_copy_tileset_background

		; Copy grass tileset
		lda #<tileset_green_grass
		sta tileset_addr
		lda #>tileset_green_grass
		sta tileset_addr+1

		TRAMPOLINE(cpu_to_ppu_copy_tileset_background, #TILESET_GREEN_GRASS_BANK_NUMBER, #CURRENT_BANK_NUMBER)

		; Copy special tiles
        ;  - An empty, solid 0 tile
        ;  - Numerics (fg=1 bg=3)
        ;  - "%"
		;  - Alpha (fg=1 bg=2)
		NUM_SPECIAL_TILES = 1+10+1+26
		PPU_SPECIAL_TILES_ADDR = ($2000-(NUM_SPECIAL_TILES*16))
        lda PPUSTATUS
        lda #>PPU_SPECIAL_TILES_ADDR
        sta PPUADDR
        lda #<PPU_SPECIAL_TILES_ADDR
        sta PPUADDR

        ldx #16
        lda #%00000000
        jsr ppu_fill

        lda #<charset_alphanum_tiles
        sta tmpfield3
        lda #>charset_alphanum_tiles
        sta tmpfield4
        lda #10
        sta tmpfield7
        ldx #CHARSET_COLOR(1,3)
        TRAMPOLINE(cpu_to_ppu_copy_charset_raw, #CHARSET_ALPHANUM_BANK_NUMBER, #CURRENT_BANK_NUMBER)

        lda #<char_pct
        sta tmpfield3
        lda #>char_pct
        sta tmpfield4
        lda #1
        sta tmpfield7
        ldx #CHARSET_COLOR(0,3)
        TRAMPOLINE(cpu_to_ppu_copy_charset_raw, #CHARSET_SYMBOLS_BANK_NUMBER, #CURRENT_BANK_NUMBER)

        lda #<(charset_alphanum_tiles+(10*8))
        sta tmpfield3
        lda #>(charset_alphanum_tiles+(10*8))
        sta tmpfield4
        lda #26
        sta tmpfield7
        ldx #CHARSET_COLOR(1,2)
        TRAMPOLINE(cpu_to_ppu_copy_charset_raw, #CHARSET_ALPHANUM_BANK_NUMBER, #CURRENT_BANK_NUMBER)
	.)

	; Set sprites tileset
	.(
		tileset_addr = tmpfield1 ; Not movable, used by cpu_to_ppu_copy_tileset
		;tileset_addr_msb = tmpfield2 ; Not movable, used by cpu_to_ppu_copy_tileset

		lda #<tileset_gameover_sprites
		sta tileset_addr
		lda #>tileset_gameover_sprites
		sta tileset_addr+1

		lda PPUSTATUS
		lda #>CHARACTERS_END_TILES_OFFSET
		sta PPUADDR
		lda #<CHARACTERS_END_TILES_OFFSET
		sta PPUADDR

		TRAMPOLINE(cpu_to_ppu_copy_tileset, #TILESET_GAMEOVER_BANK_NUMBER, #CURRENT_BANK_NUMBER)
	.)

	; Copy background from PRG-rom to PPU nametable
	lda #<gameover_nametable
	sta tmpfield1
	lda #>gameover_nametable
	sta tmpfield2
	TRAMPOLINE(draw_zipped_nametable, #GAMEOVER_SCREEN_DATA_BANK_NUMBER, #CURRENT_BANK_NUMBER)

	; Wait the begining of a VBI before writing data to PPU's palettes
	jsr wait_vbi

	; Write screen's palettes in PPU
	lda PPUSTATUS ;
	lda #$3f      ; Point PPU to Background palette 0
	sta PPUADDR   ; (see http://wiki.nesdev.com/w/index.php/PPU_palettes)
	ldx #$00      ;
	stx PPUADDR   ;

	lda #<gameover_palette
	sta tmpfield1
	lda #>gameover_palette
	sta tmpfield2
	lda #$20
	sta tmpfield3
	TRAMPOLINE(cpu_to_ppu_copy_bytes, #GAMEOVER_SCREEN_DATA_BANK_NUMBER, #CURRENT_BANK_NUMBER)

	; Initialize sprites palettes regarding configuration
	ldy config_player_a_character

	lda characters_palettes_lsb, y
	sta tmpfield2
	lda characters_palettes_msb, y
	sta tmpfield3

	ldx #$11
	lda config_player_a_character_palette
	sta tmpfield1
	TRAMPOLINE(copy_palette_to_ppu, characters_bank_number COMMA y, #CURRENT_BANK_NUMBER)

	ldy config_player_b_character

	lda characters_palettes_lsb, y
	sta tmpfield2
	lda characters_palettes_msb, y
	sta tmpfield3

	ldx #$19
	lda config_player_b_character_palette
	sta tmpfield1
	TRAMPOLINE(copy_palette_to_ppu, characters_bank_number COMMA y, #CURRENT_BANK_NUMBER)

	; Write winner's name
	lda PPUSTATUS
	lda #$20
	sta PPUADDR
	lda #$ba
	sta PPUADDR
	ldx gameover_winner
	ldy #0
	winner_name_writing:
		lda player_names, x
		sta PPUDATA
		inx
		inx
		iny
		cpy #3
		bne winner_name_writing

	; Set winner's animation
	ldy gameover_winner
	ldx config_player_a_character, y

	lda characters_properties_lsb, x
	sta tmpfield1
	lda characters_properties_msb, x
	sta tmpfield2

	lda #<player_a_animation
	sta tmpfield11
	lda #>player_a_animation
	sta tmpfield12
	ldy #CHARACTERS_PROPERTIES_VICTORY_ANIM_OFFSET
	FAR_LDA_TMPFIELD1_Y(characters_bank_number COMMA x)
	sta tmpfield13
	iny
	FAR_LDA_TMPFIELD1_Y(characters_bank_number COMMA x)
	sta tmpfield14
	jsr animation_init_state

	lda #$71
	sta player_a_animation+ANIMATION_STATE_OFFSET_Y_LSB
	lda #$64
	sta player_a_animation+ANIMATION_STATE_OFFSET_X_LSB
	lda #$00
	sta player_a_animation+ANIMATION_STATE_OFFSET_FIRST_SPRITE_NUM
	lda #$0f
	sta player_a_animation+ANIMATION_STATE_OFFSET_LAST_SPRITE_NUM

	; Set loser's animation
	ldx gameover_winner
	jsr switch_selected_player
	txa:tay
	ldx config_player_a_character, y

	lda characters_properties_lsb, x
	sta tmpfield1
	lda characters_properties_msb, x
	sta tmpfield2

	lda #<player_b_animation
	sta tmpfield11
	lda #>player_b_animation
	sta tmpfield12
	ldy #CHARACTERS_PROPERTIES_DEFEAT_ANIM_OFFSET
	FAR_LDA_TMPFIELD1_Y(characters_bank_number COMMA x)
	sta tmpfield13
	iny
	FAR_LDA_TMPFIELD1_Y(characters_bank_number COMMA x)
	sta tmpfield14
	jsr animation_init_state

	lda #$76
	sta player_b_animation+ANIMATION_STATE_OFFSET_Y_LSB
	lda #$3c
	sta player_b_animation+ANIMATION_STATE_OFFSET_X_LSB
	lda #$10
	sta player_b_animation+ANIMATION_STATE_OFFSET_FIRST_SPRITE_NUM
	lda #$1f
	sta player_b_animation+ANIMATION_STATE_OFFSET_LAST_SPRITE_NUM

	; Initialize balloon sprites
	ldx #0
	initialize_a_balloon:
		lda #TILE_BALLOON
		sta oam_mirror+OAM_BALLOONS+1, x
		lda #TILE_BALLOON_TAIL
		sta oam_mirror+OAM_BALLOONS+5, x
		lda #$23
		sta oam_mirror+OAM_BALLOONS+2, x
		sta oam_mirror+OAM_BALLOONS+6, x
		txa
		clc
		adc #8
		tax
		cpx #8*6
		bne initialize_a_balloon

	ldx #0
	position_a_balloon:

		; Position higher than #$80
		jsr gameover_random_byte
		lsr
		sta gameover_balloon0_y, x

		; Laterally near the podium
		jsr gameover_random_byte
		lsr
		clc
		adc #$20
		sta gameover_balloon0_x, x
		inx
		cpx #6
		bne position_a_balloon

	; Change for music for gameover theme
	jsr audio_music_gameover

	; Set both gamepads as non-ready
	lda #%00000000
	sta gameover_gamepads_ready_a
	sta gameover_gamepads_ready_b

	rts

	player_names:
	.byt $f4, $f9
	.byt $f3, $fc
	.byt $ea, $f4
.)

gameover_screen_tick_extra:
.(
	.(
		; Check if gamepads are ready
		;  "ready" is - all buttons have been released, then some button has been pressed
		;  The goal is to avoid unintentional gameover skip because of a button pressed at the end of the game,
		;  as well as unintentional action on next screen (by going to next screen while a button is pressed)
		ldx #0
		check_ready:
			lda controller_a_last_frame_btns, x
			bne controller_a_ok
			lda controller_a_btns, x
			beq controller_a_ok
				lda #%00000001
				sta gameover_gamepads_ready_a, x
			controller_a_ok:

			inx
			cpx #2
			bne check_ready

		; If a button is released from any ready controller, go to next screen
		ldx #0
		check_one_controller:
			lda gameover_gamepads_ready_a, x
			beq next_controller

			lda controller_a_btns, x
			bne next_controller
				lda controller_a_last_frame_btns, x
				cmp #CONTROLLER_BTN_START
				beq next_screen
				cmp #CONTROLLER_BTN_A
				beq next_screen
				cmp #CONTROLLER_BTN_B
				beq next_screen

			next_controller:
			inx
			cpx #2
			bne check_one_controller
			jmp update_animations

		next_screen:
			; Return to the best menu screen to jump back into battle as soon as possible
			ldx config_game_mode
			lda next_screen_by_game_mode, x
			jmp change_global_game_state

		update_animations:
			jsr gamover_update_players
			jmp update_balloons
			;rts ; useless, jump to subroutine

		next_screen_by_game_mode:
		.byt GAME_STATE_CHARACTER_SELECTION, GAME_STATE_CHARACTER_SELECTION
	.)

	gamover_update_players:
	.(
		; Update winner's animation
		lda #<player_a_animation
		sta tmpfield11
		lda #>player_a_animation
		sta tmpfield12
		ldx gameover_winner
		stx player_number
		ldy config_player_a_character, x
		tya:pha
		TRAMPOLINE(animation_draw, characters_bank_number COMMA y, #CURRENT_BANK_NUMBER)
		pla:tay
		TRAMPOLINE(animation_tick, characters_bank_number COMMA y, #CURRENT_BANK_NUMBER)

		; Update loser's animation
		lda #<player_b_animation
		sta tmpfield11
		lda #>player_b_animation
		sta tmpfield12
		ldx gameover_winner
		jsr switch_selected_player
		stx player_number
		ldy config_player_a_character, x
		tya:pha
		TRAMPOLINE(animation_draw, characters_bank_number COMMA y, #CURRENT_BANK_NUMBER)
		pla:tay
		TRAMPOLINE(animation_tick, characters_bank_number COMMA y, #CURRENT_BANK_NUMBER)

		rts
	.)

	update_balloons:
	.(
		ldx #0
		ldy #0
		update_one_balloon:

			; Update Y
			jsr gameover_random_byte
			and #%00000011
			clc
			adc #$80
			clc
			adc gameover_balloon0_y_low, x
			sta gameover_balloon0_y_low, x
			lda #$ff
			adc gameover_balloon0_y, x
			sta gameover_balloon0_y, x
			cmp #$80
			bmi end_y
				lda #$80
				sta gameover_balloon0_y, x
			end_y:

			; Update horizontal velocity
			jsr gameover_random_byte
			and #%00000111
			clc
			adc gameover_balloon0_velocity_h, x
			sta gameover_balloon0_velocity_h, x

			; Update X
			lda gameover_balloon0_velocity_h, x
			clc
			adc gameover_balloon0_x_low, x
			sta gameover_balloon0_x_low, x
			lda gameover_balloon0_velocity_h, x
			bpl positive
				lda #$ff
				jmp high_byte_set
			positive:
				lda #$00
			high_byte_set:
			adc gameover_balloon0_x, x
			sta gameover_balloon0_x, x

			; Move balloon's sprite
			lda gameover_balloon0_y, x
			sta oam_mirror+OAM_BALLOONS, y
			clc
			adc #8
			sta oam_mirror+OAM_BALLOONS+4, y

			lda gameover_balloon0_x, x
			sta oam_mirror+OAM_BALLOONS+3, y
			sta oam_mirror+OAM_BALLOONS+7, y

			lda gameover_balloon0_y, x
			cmp #$40
			bcs background
				lda #$03
				sta oam_mirror+OAM_BALLOONS+2, y
				sta oam_mirror+OAM_BALLOONS+6, y
				jmp end_sprite_layer
			background:
				lda #$23
				sta oam_mirror+OAM_BALLOONS+2, y
				sta oam_mirror+OAM_BALLOONS+6, y
			end_sprite_layer:

			; Loop
			tya
			clc
			adc #8
			tay
			inx
			cpx #6
			bne update_one_balloon

		rts
	.)
.)

gameover_random_byte:
.(
	lda gameover_random
	rol
	rol
	rol
	rol
	adc gameover_random
	adc #1
	sta gameover_random

	rts
.)

#define OAM_BALLOONS 4*32

init_gameover_screen:
.(
	; Set background tileset
	.(
		tileset_addr = tmpfield1 ; Not movable, used by cpu_to_ppu_copy_tiles
		;tileset_addr_msb = tmpfield2 ; Not movable, used by cpu_to_ppu_copy_tiles
		tiles_count = tmpfield3 ; Not movable, used by cpu_to_ppu_copy_tiles

		lda #<(tileset_green_grass+1)
		sta tileset_addr
		lda #>(tileset_green_grass+1)
		sta tileset_addr+1

		SWITCH_BANK(#TILESET_GREEN_GRASS_BANK_NUMBER)

		lda tileset_green_grass
		sta tiles_count

		lda PPUSTATUS
		lda #$10
		sta PPUADDR
		lda #$00
		sta PPUADDR

		jsr cpu_to_ppu_copy_tiles
	.)

	; Set sprites tileset
	.(
		tileset_addr = tmpfield1 ; Not movable, used by cpu_to_ppu_copy_tiles
		;tileset_addr_msb = tmpfield2 ; Not movable, used by cpu_to_ppu_copy_tiles
		tiles_count = tmpfield3 ; Not movable, used by cpu_to_ppu_copy_tiles

		lda #<(tileset_gameover_sprites+1)
		sta tileset_addr
		lda #>(tileset_gameover_sprites+1)
		sta tileset_addr+1

		SWITCH_BANK(#TILESET_GAMEOVER_BANK_NUMBER)

		lda tileset_gameover_sprites
		sta tiles_count

		lda PPUSTATUS
		lda #>CHARACTERS_END_TILES_OFFSET
		sta PPUADDR
		lda #<CHARACTERS_END_TILES_OFFSET
		sta PPUADDR

		jsr cpu_to_ppu_copy_tiles
	.)

	SWITCH_BANK(#DATA_BANK_NUMBER)

	; Copy background from PRG-rom to PPU nametable
	lda #<nametable_gameover
	sta tmpfield1
	lda #>nametable_gameover
	sta tmpfield2
	jsr draw_zipped_nametable

	; Wait the begining of a VBI before writing data to PPU's palettes
	bit PPUSTATUS
	lda #$80
	wait_vbi:
		bit PPUSTATUS
		beq wait_vbi

	; Write screen's palettes in PPU
	lda PPUSTATUS ;
	lda #$3f      ; Point PPU to Background palette 0
	sta PPUADDR   ; (see http://wiki.nesdev.com/w/index.php/PPU_palettes)
	lda #$00      ;
	sta PPUADDR   ;

	ldx #$00                    ;
	copy_palette:               ;
		lda palette_gameover, x ;
		sta PPUDATA             ; Write palette_data in actual ppu palettes
		inx                     ;
		cpx #$20                ;
		bne copy_palette        ;

	; Initialize sprites palettes regarding configuration
	ldy config_player_a_character
	SWITCH_BANK(characters_bank_number COMMA y)

	lda characters_palettes_lsb, y
	sta tmpfield2
	lda characters_palettes_msb, y
	sta tmpfield3

	ldx #$11
	lda config_player_a_character_palette
	sta tmpfield1
	jsr copy_palette_to_ppu

	ldy config_player_b_character
	SWITCH_BANK(characters_bank_number COMMA y)

	lda characters_palettes_lsb, y
	sta tmpfield2
	lda characters_palettes_msb, y
	sta tmpfield3

	ldx #$19
	lda config_player_b_character_palette
	sta tmpfield1
	jsr copy_palette_to_ppu

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
	ldx gameover_winner
	ldy config_player_a_character, x
	SWITCH_BANK(characters_bank_number COMMA y)
	ldy config_player_a_character, x
	lda characters_properties_lsb, y
	sta tmpfield1
	lda characters_properties_msb, y
	sta tmpfield2

	lda #<player_a_animation
	sta tmpfield11
	lda #>player_a_animation
	sta tmpfield12
	ldy #CHARACTERS_PROPERTIES_VICTORY_ANIM_OFFSET
	lda (tmpfield1), y
	sta tmpfield13
	iny
	lda (tmpfield1), y
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
	ldy config_player_a_character, x
	SWITCH_BANK(characters_bank_number COMMA y)
	ldy config_player_a_character, x
	lda characters_properties_lsb, y
	sta tmpfield1
	lda characters_properties_msb, y
	sta tmpfield2

	lda #<player_b_animation
	sta tmpfield11
	lda #>player_b_animation
	sta tmpfield12
	ldy #CHARACTERS_PROPERTIES_DEFEAT_ANIM_OFFSET
	lda (tmpfield1), y
	sta tmpfield13
	iny
	lda (tmpfield1), y
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

	rts

	player_names:
	.byt $f4, $f9
	.byt $f3, $fc
	.byt $ea, $f4
.)

gameover_screen_tick:
.(
	.(
		; If start button is released from any controller, go to next screen
		ldx #0
		check_one_controller:
			lda controller_a_last_frame_btns, x
			sta tmpfield1
			lda controller_a_btns, x
			sta tmpfield2
			lda #CONTROLLER_BTN_START
			bit tmpfield1
			beq next_controller
			bit tmpfield2
			bne next_controller
			jmp next_screen
			next_controller:
			inx
			cpx #2
			bne check_one_controller
			jmp update_animations

		next_screen:
			ldx config_game_mode
			lda next_screen_by_game_mode, x
			jmp change_global_game_state

		update_animations:
			jsr gamover_update_players
			jsr update_balloons
			rts

		next_screen_by_game_mode:
		.byt GAME_STATE_CHARACTER_SELECTION, GAME_STATE_TITLE
	.)

	gamover_update_players:
	.(
		; Update winner's animation
		lda #<player_a_animation
		sta tmpfield11
		lda #>player_a_animation
		sta tmpfield12
		lda #0
		sta tmpfield13
		sta tmpfield14
		sta tmpfield15
		sta tmpfield16
		ldx gameover_winner
		stx player_number
		ldy config_player_a_character, x
		SWITCH_BANK(characters_bank_number COMMA y)
		jsr animation_draw
		jsr animation_tick

		; Update loser's animation
		lda #<player_b_animation
		sta tmpfield11
		lda #>player_b_animation
		sta tmpfield12
		lda #0
		sta tmpfield13
		sta tmpfield14
		sta tmpfield15
		sta tmpfield16
		ldx gameover_winner
		jsr switch_selected_player
		stx player_number
		ldy config_player_a_character, x
		SWITCH_BANK(characters_bank_number COMMA y)
		jsr animation_draw
		jsr animation_tick

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

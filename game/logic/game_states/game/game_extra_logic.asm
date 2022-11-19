+GAMESTATE_GAME_EXTRA_BANK = CURRENT_BANK_NUMBER

+extra_init_game_state:
.(
	.(
		; Clear background of nametable 2
		jsr clear_bg_bot_left

		; Store characters' tiles in CHR
		.(
			ldx #3
			loop:
				jsr place_character_ppu_illustrations
				TRAMPOLINE(place_character_ppu_tiles, #0, #CURRENT_BANK_NUMBER)
				dex
				bpl loop
		.)

		; Place characters' portraits sprites
		.(
			ldy #INGAME_PORTRAIT_LAST_SPRITE*4
			ldx #7
			loop:
				lda portrait_sprite_y, x
				sta oam_mirror+0, y
				lda portrait_sprite_tile, x
				sta oam_mirror+1, y
				lda portrait_sprite_attr, x
				sta oam_mirror+2, y
				lda portrait_sprite_x, x
				sta oam_mirror+3, y

				dey:dey:dey:dey
				dex
				bpl loop
		.)

		; Ensure game state is zero
		ldx #$00
		txa
		zero_game_state:
			sta $00, x
			inx
			cpx #ZERO_PAGE_GLOBAL_FIELDS_BEGIN
			bne zero_game_state

		; Copy common tileset
		;  - An empty, solid 1 tile
		;  - "%"
		;  - Numerics (fg=1 bg=3)
		lda PPUSTATUS
		lda #>($1000+(TILE_EMPTY_STOCK_ICON*16))
		sta PPUADDR
		lda #<($1000+(TILE_EMPTY_STOCK_ICON*16))
		sta PPUADDR

		ldx #8
		lda #%11111111
		jsr ppu_fill
		ldx #8
		lda #%00000000
		jsr ppu_fill

		lda #<char_pct
		sta tmpfield3
		lda #>char_pct
		sta tmpfield4
		lda #1
		sta tmpfield7
		ldx #CHARSET_COLOR(0,3)
		TRAMPOLINE(cpu_to_ppu_copy_charset_raw, #CHARSET_SYMBOLS_BANK_NUMBER, #CURRENT_BANK_NUMBER)

		lda #<charset_alphanum_tiles
		sta tmpfield3
		lda #>charset_alphanum_tiles
		sta tmpfield4
		lda #10
		sta tmpfield7
		ldx #CHARSET_COLOR(0,3)
		TRAMPOLINE(cpu_to_ppu_copy_charset_raw, #CHARSET_ALPHANUM_BANK_NUMBER, #CURRENT_BANK_NUMBER)

		; Copy common sprites
		lda #<tileset_common_ingame_sprites
		sta tmpfield1
		lda #>tileset_common_ingame_sprites
		sta tmpfield2

		lda PPUSTATUS
		lda #>INGAME_COMMON_FIRST_SPRITE_TILE_OFFSET
		sta PPUADDR
		lda #<INGAME_COMMON_FIRST_SPRITE_TILE_OFFSET
		sta PPUADDR

		TRAMPOLINE(cpu_to_ppu_copy_tileset, #TILESET_COMMON_INGAME_SPRITES_BANK_NUMBER, #CURRENT_BANK_NUMBER)

		; Copy stage's tileset
		.(
			tileset_addr = tmpfield1 ; Not movable, used by cpu_to_ppu_copy_tiles
			;tileset_addr_msb = tmpfield2 ; Not movable, used by cpu_to_ppu_copy_tiles
			tiles_count = tmpfield3 ; Not movable, used by cpu_to_ppu_copy_tiles

			; Save tileset's vector
			ldx config_selected_stage
			lda stages_tileset_lsb, x
			sta tileset_addr
			lda stages_tileset_msb, x
			sta tileset_addr+1

			; Copy tileset
			TRAMPOLINE(cpu_to_ppu_copy_tileset_background, stages_tileset_bank COMMA x, #CURRENT_BANK_NUMBER)
		.)

		; Common stage initialization
		jsr stage_generic_init

		; Reset screen shaking
		lda #0
		sta screen_shake_counter

		; Disable deathplosion
		lda #$ff
		sta deathplosion_step
		lda #0
		sta deathplosion_pos
		sta deathplosion_origin

		; Setup logical game state to the game startup configuration
		lda DIRECTION_LEFT
		sta player_b_direction

		lda DIRECTION_RIGHT
		sta player_a_direction

		lda #HITBOX_DISABLED
		sta player_a_hitbox_enabled
		sta player_b_hitbox_enabled

		ldx #0
		position_player_loop:
			lda #0
			sta player_a_x_screen, x
			sta player_a_y_screen, x
			lda stage_data+STAGE_HEADER_OFFSET_PAY_HIGH, x
			sta player_a_y, x
			lda stage_data+STAGE_HEADER_OFFSET_PAY_LOW, x
			sta player_a_y_low, x
			lda stage_data+STAGE_HEADER_OFFSET_PAX_HIGH, x
			sta player_a_x, x
			lda stage_data+STAGE_HEADER_OFFSET_PAX_LOW, x
			sta player_a_x_low, x
			inx
			cpx #2
			bne position_player_loop

		ldx #0
		jsr reset_default_gravity
		ldx #1
		jsr reset_default_gravity

		lda config_initial_stocks
		sta player_a_stocks
		sta player_b_stocks

		lda #$ff ; impossible value in screen damage meter cache, forcing it to redraw
		sta player_a_last_shown_damage
		sta player_b_last_shown_damage
		sta player_a_last_shown_stocks
		sta player_b_last_shown_stocks

		lda #<player_a_animation                                       ;
		sta tmpfield11                                                 ;
		lda #>player_a_animation                                       ;
		sta tmpfield12                                                 ;
		jsr animation_init_state                                       ;
		lda #INGAME_PLAYER_A_FIRST_SPRITE                              ;
		sta player_a_animation+ANIMATION_STATE_OFFSET_FIRST_SPRITE_NUM ;
		lda #INGAME_PLAYER_A_LAST_SPRITE                               ;
		sta player_a_animation+ANIMATION_STATE_OFFSET_LAST_SPRITE_NUM  ; Initialize players animation state
		lda #<player_b_animation                                       ; (voluntarily let garbage in data vector, it will be overriden by initializing player's state)
		sta tmpfield11                                                 ;
		lda #>player_b_animation                                       ;
		sta tmpfield12                                                 ;
		jsr animation_init_state                                       ;
		lda #INGAME_PLAYER_B_FIRST_SPRITE                              ;
		sta player_b_animation+ANIMATION_STATE_OFFSET_FIRST_SPRITE_NUM ;
		lda #INGAME_PLAYER_B_LAST_SPRITE                               ;
		sta player_b_animation+ANIMATION_STATE_OFFSET_LAST_SPRITE_NUM  ;

		; Initialize out of screen indicators animation state
		lda #<player_a_out_of_screen_indicator
		sta tmpfield11
		lda #>player_a_out_of_screen_indicator
		sta tmpfield12
		lda #<anim_out_of_screen_bubble
		sta tmpfield13
		lda #>anim_out_of_screen_bubble
		sta tmpfield14
		jsr animation_init_state
		lda #INGAME_PLAYER_A_FIRST_SPRITE
		sta player_a_out_of_screen_indicator+ANIMATION_STATE_OFFSET_FIRST_SPRITE_NUM
		lda #INGAME_PLAYER_A_LAST_SPRITE
		sta player_a_out_of_screen_indicator+ANIMATION_STATE_OFFSET_LAST_SPRITE_NUM

		lda #<player_b_out_of_screen_indicator
		sta tmpfield11
		lda #>player_b_out_of_screen_indicator
		sta tmpfield12
		jsr animation_init_state
		lda #INGAME_PLAYER_B_FIRST_SPRITE
		sta player_b_out_of_screen_indicator+ANIMATION_STATE_OFFSET_FIRST_SPRITE_NUM
		lda #INGAME_PLAYER_B_LAST_SPRITE
		sta player_b_out_of_screen_indicator+ANIMATION_STATE_OFFSET_LAST_SPRITE_NUM

		; Clear players' elements
		lda #STAGE_ELEMENT_END
		sta player_a_objects
		sta player_b_objects

		; Initialize players' state
		ldx #1
		initialize_one_player:
			; Call character's start routine
			ldy config_player_a_character, x
			lda #PLAYER_STATE_SPAWN
			sta player_a_state, x
			lda characters_start_routines_table_lsb, y
			sta tmpfield1
			lda characters_start_routines_table_msb, y
			sta tmpfield2
			ldy config_player_a_character, x
			TRAMPOLINE(player_state_action, characters_bank_number COMMA y, #CURRENT_BANK_NUMBER)

			; Next player
			dex
			bpl initialize_one_player

		; Construct players palette swap buffers
		ldx #0 ; X points on players_palettes's next byte
		jsr place_player_a_header
		ldy #0
		jsr place_character_normal_palette
		jsr place_player_a_header
		ldy #0
		jsr place_character_alternate_palette

		jsr place_player_b_header
		ldy #1
		jsr place_character_normal_palette
		jsr place_player_b_header
		ldy #1
		jsr place_character_alternate_palette

		; If both players have the same character with same colors, lighten player B's colors
		.(
			lda config_player_a_character
			cmp config_player_b_character
			bne ok
			lda config_player_a_character_palette
			cmp config_player_b_character_palette
			bne ok
				ldx #16+4 ; Player B's normal palette, first color
				ldy #3
				lighten_one_color:
					; Get color
					lda players_palettes, x

					; Skip if cannot be lightened, special handling for black
					cmp #$0f
					beq lighten_black
					cmp #$30
					bcs end_color

						ligthen_normal:
							; Up color to the lighter value
							clc
							adc #$10
							sta players_palettes, x
							jmp end_color

						lighten_black:
							; Change to dark-grey
							lda #$00
							sta players_palettes, x

					; Loop on three colors
					end_color:
					inx
					dey
					bne lighten_one_color
			ok:
		.)

		; Initialize weapons palettes
		jsr wait_vbi ; Wait the begining of a VBI before writing data to PPU's palettes

		ldy config_player_a_character

		lda characters_weapon_palettes_lsb, y
		sta tmpfield2
		lda characters_weapon_palettes_msb, y
		sta tmpfield3

		ldx #$15
		lda config_player_a_weapon_palette
		sta tmpfield1
		TRAMPOLINE(copy_palette_to_ppu, characters_bank_number COMMA y, #CURRENT_BANK_NUMBER)

		ldy config_player_b_character

		lda characters_weapon_palettes_lsb, y
		sta tmpfield2
		lda characters_weapon_palettes_msb, y
		sta tmpfield3

		ldx #$1d
		lda config_player_b_weapon_palette
		sta tmpfield1
		TRAMPOLINE(copy_palette_to_ppu, characters_bank_number COMMA y, #CURRENT_BANK_NUMBER)

		; Move sprites according to the initial state
		TRAMPOLINE(update_sprites, #0, #CURRENT_BANK_NUMBER)

		; Change for ingame music
		jsr audio_music_ingame

		; Initialize game mode
		ldx config_game_mode
		lda game_modes_init_lsb, x
		sta tmpfield1
		lda game_modes_init_msb, x
		sta tmpfield2
		TRAMPOLINE(call_pointed_subroutine, #0, #CURRENT_BANK_NUMBER)

		; Call stage init routine
		lda config_selected_stage
		asl
		tax
		lda stages_init_routine, x
		sta tmpfield1
		lda stages_init_routine+1, x
		sta tmpfield2

		ldx config_selected_stage
		TRAMPOLINE(call_pointed_subroutine, stages_bank COMMA x, #CURRENT_BANK_NUMBER)

		rts
	.)

	place_player_a_header:
	.(
		ldy #0
		copy_one_byte:
			lda header_player_a, y
			sta players_palettes, x
			iny
			inx
			cpy #4
			bne copy_one_byte
		rts
	.)

	place_player_b_header:
	.(
		ldy #0
		copy_one_byte:
		lda header_player_b, y
		sta players_palettes, x
		iny
		inx
		cpy #4
		bne copy_one_byte
		rts
	.)

	; Copy character's normal palette in players_palettes
	;  X - current offset in players_palettes
	;  Y - player number
	;
	; Output
	;  X -  Updated offset in players_palettes
	;
	; Overwrites all registers, tmpfield1 to tmpfield3
	place_character_normal_palette:
	.(
		txa
		pha

		ldx config_player_a_character, y
		lda characters_palettes_lsb, x
		sta tmpfield1
		lda characters_palettes_msb, x
		sta tmpfield2
		lda characters_bank_number, x
		sta tmpfield3

		pla
		tax

		jmp place_character_palette
		;rts ; useless, jump to subroutine
	.)

	place_character_alternate_palette:
	.(
		txa
		pha

		ldx config_player_a_character, y
		lda characters_alternate_palettes_lsb, x
		sta tmpfield1
		lda characters_alternate_palettes_msb, x
		sta tmpfield2
		lda characters_bank_number, x
		sta tmpfield3

		pla
		tax

		; Fallthrough to place_character_palette
	.)

	; Copy pointed palette in players_palettes
	;  X - current offset in players_palettes
	;  Y - player number
	;  tmpfield1, tmpfield2 - palettes table of player's character
	;  tmpfield3 - bank containing palettes table
	;
	; Output
	;  X -  Updated offset in players_palettes
	;
	; Overwrites all registers, tmpfield1 and tmpfield2
	place_character_palette:
	.(
		lda config_player_a_character_palette, y
		asl
		;clc ; useless, asl shall not overflow
		adc config_player_a_character_palette, y
		tay

		FAR_LDA_TMPFIELD1_Y(tmpfield3)
		sta players_palettes, x
		iny
		inx
		FAR_LDA_TMPFIELD1_Y(tmpfield3)
		sta players_palettes, x
		iny
		inx
		FAR_LDA_TMPFIELD1_Y(tmpfield3)
		sta players_palettes, x
		iny
		inx

		lda #0
		sta players_palettes, x
		inx

		rts
	.)

	; Place characters illustrations in CHR RAM
	;  X - illustation number (0-player A background, 1-player B background, 2-player A sprites, 3-player B sprites)
	;  token + small in background tiles
	;  small in sprite tiles
	;
	; NOTE deserve 2 routines, one for bg, one for sprites
	place_character_ppu_illustrations:
	.(
		illustration_addr = tmpfield1
		illustration_size = tmpfield3
		illustration_addr_tmp = tmpfield4
		char_bank = tmpfield6
		bitmask = tmpfield7

		; Save X
		txa:pha

		; Place PPU on the tiles to write
		lda PPUSTATUS
		lda illustrations_addr_msb, x
		sta PPUADDR
		lda illustrations_addr_lsb, x
		sta PPUADDR

		; Read character info
		txa
		pha
		and #%00000001
		tax
		ldy config_player_a_character, x
		pla
		tax

		lda characters_properties_lsb, y
		sta tmpfield1
		lda characters_properties_msb, y
		sta tmpfield2

		lda characters_bank_number, y
		sta char_bank

		ldy #CHARACTERS_PROPERTIES_ILLUSTRATIONS_ADDR_OFFSET
		FAR_LDA_TMPFIELD1_Y(char_bank)
		sta illustration_addr_tmp
		iny
		FAR_LDA_TMPFIELD1_Y(char_bank)
		sta illustration_addr_tmp+1

		; For sprites, skip token illustration
		.(
			cpx #2
			bcc copy_background_tiles
				copy_sprite_tiles:
					; Skip TOKEN illustration
					;NOTE it is important to store result in "illustration_addr", far fetching expects it to be tmpfield1
					lda illustration_addr_tmp
					clc
					adc #CHARACTERS_ILLUSTRATION_SMALL_OFFSET*16
					sta illustration_addr
					lda illustration_addr_tmp+1
					adc #0
					sta illustration_addr+1

					; Copy illustration tiles
					lda illustrations_size, x
					tax
					copy_one_tile:
						.(
							; Save X
							txa:pha

							; Copy the lines LSBs
							;  We want to swap colors 0 and 1
							;  so, when a bit in the second byte of a line is 0, the equivalent bit in first line must be swapped
							ldx #8-1
							copy_line_lsb:
							.(
								; Swap bits as necessary
								ldy #8
								FAR_LDA_TMPFIELD1_Y(char_bank)
								eor #%11111111
								sta bitmask

								ldy #0
								FAR_LDA_TMPFIELD1_Y(char_bank)
								eor bitmask

								; Write VRAM
								sta PPUDATA

								; Loop
								inc illustration_addr
								bne inc_done
									inc illustration_addr+1
								inc_done:

								dex
								bpl copy_line_lsb
							.)

							; Copy the line MSBs
							ldx #8-1 ;FIXME dbg, should be 8
							ldy #0
							copy_line_msb:
							.(
								; Read byte
								FAR_LDA_TMPFIELD1_Y(char_bank)

								; Write VRAM
								sta PPUDATA

								; Loop
								inc illustration_addr
								bne inc_done
									inc illustration_addr+1
								inc_done:

								dex
								bpl copy_line_msb
							.)

							; Restore X
							pla:tax
						.)

						dex
						bne copy_one_tile

					jmp ok

				copy_background_tiles:
					lda illustration_addr_tmp
					sta illustration_addr
					lda illustration_addr_tmp+1
					sta illustration_addr+1
					lda illustrations_size, x
					sta illustration_size

					TRAMPOLINE(cpu_to_ppu_copy_tiles, char_bank, #CURRENT_BANK_NUMBER)

			ok:
		.)

		; Restore X
		pla
		tax

		rts

		illustrations_addr_msb:
		.byt $1d, $1d ; Background
		.byt $0f, $0f ; Sprites
		illustrations_addr_lsb:
		.byt $00, $50 ; Background
		.byt $80, $c0 ; Sprites
		illustrations_size:
		.byt $05, $05 ; Background - we want token + small = 5 tiles
		.byt $04, $04 ; Sprites - we want only small = 4 tiles
	.)

	header_player_a:
	.byt $01, $3f, $11, $03
	header_player_b:
	.byt $01, $3f, $19, $03

	.(
		T = INGAME_CHARACTER_A_PORTRAIT_FIRST_SPRITE_TILE
		&portrait_sprite_y:
			.byt $bf,$bf,$c7,$c7, $bf,$bf,$c7,$c7
		&portrait_sprite_tile:
			.byt T+0,T+1,T+2,T+3, T+4,T+5,T+6,T+7
		&portrait_sprite_attr:
			.byt $00,$00,$00,$00, $02,$02,$02,$02
		&portrait_sprite_x:
			.byt $48,$50,$48,$50, $a8,$b0,$a8,$b0
	.)
.)

; Code common to most stage initialization
;
; Overwrites all registers, tmpfield1, tmpfield2 and tmpfield15
stage_generic_init:
.(
	stage_table_index = tmpfield15
	element_length = tmpfield15 ; warning reuse, take care of not mixing usages

	; Point stage_table_index to the byte offset of selected stage entry in vector tables
	lda config_selected_stage
	asl
	sta stage_table_index

	; Write palette_data in actual ppu palettes
	jsr wait_vbi ; Wait the begining of a VBI before writing data to PPU's palettes

	lda PPUSTATUS ;
	lda #$3f      ; Point PPU to Background palette 0
	sta PPUADDR   ; (see http://wiki.nesdev.com/w/index.php/PPU_palettes)
	lda #$00      ;
	sta PPUADDR   ;

	ldx stage_table_index   ;
	lda stage_palettes, x   ;
	sta tmpfield1           ;
	lda stage_palettes+1, x ;
	sta tmpfield2           ;
	lda #$10
	sta tmpfield3
	ldx config_selected_stage
	TRAMPOLINE(cpu_to_ppu_copy_bytes, stages_bank COMMA x, #CURRENT_BANK_NUMBER)

	; Copy background from PRG-rom to PPU nametable
	ldx stage_table_index
	lda stages_nametable, x
	sta tmpfield1
	lda stages_nametable+1, x
	sta tmpfield2
	ldx config_selected_stage
	TRAMPOLINE(draw_zipped_nametable, stages_bank COMMA x, #CURRENT_BANK_NUMBER)

	; Copy stage data to its fixed location
	lda #<stage_data
	sta tmpfield1
	lda #>stage_data
	sta tmpfield2

	ldx stage_table_index
	lda stages_data, x
	sta tmpfield3
	lda stages_data+1, x
	sta tmpfield4

	lda #player_a_objects-stage_data
	sta tmpfield5

	ldx config_selected_stage
	TRAMPOLINE(fixed_memcpy, stages_bank COMMA x, #CURRENT_BANK_NUMBER)

	rts
.)

audio_music_ingame:
.(
	; Change selected track, so it varies from game to game
	dec config_ingame_track
	bpl ok
		lda #LAST_INGAME_TRACK
		sta config_ingame_track
	ok:

	; Play selected track
	ldx config_ingame_track
	lda ingame_themes_lsb, x
	sta audio_current_track_lsb
	lda ingame_themes_msb, x
	sta audio_current_track_msb
	lda ingame_themes_bank, x
	sta audio_current_track_bank
	TRAMPOLINE(audio_play_music_direct, #0, #CURRENT_BANK_NUMBER)

	rts

	ingame_themes_lsb:
		.byt <music_perihelium_info, <music_sinbad2_info, <music_adventure_info, <music_sinbad_info, <music_volcano_info, <music_kiki_info
	ingame_themes_msb:
		.byt >music_perihelium_info, >music_sinbad2_info, >music_adventure_info, >music_sinbad_info, >music_volcano_info, >music_kiki_info
	ingame_themes_bank:
		.byt music_perihelium_bank, music_sinbad2_bank, music_sinbad_bank, music_adventure_bank, music_volcano_bank, music_kiki_bank
	LAST_INGAME_TRACK = ingame_themes_msb - ingame_themes_lsb - 1
.)

; Tick deathplosion animation
;  deathplosion_step - Current frame of the animation (begins at DEATHPLOSION_FRAME_COUNT-1)
;  deathplosion_pos - Offset of the animation from top-left corner
;  deathplosion_origin - Blastline in which the deathplosion hapened
;
; NOTE - deathplosion_pos value depends on deathplosion_origin
;  Vertical   - set deathplosion_pos to the offset from screen's left edge
;  Horizontal - set deathplosion_pos to 8 * the offset from screen's top edge
;
; Overwrites all registers, tmpfield1 to tmpfield3
+vfx_deathplosion:
.(
	; Do nothing if inactive
	.(
		ldy deathplosion_step
		bpl ok
			rts
		ok:
	.)

	; Do not draw buffers in rollback
	.(
		lda network_rollback_mode
		beq ok
			jmp end_draw
		ok:
	.)

		; Draw current step
		.(
			ldx nt_buffers_end

			lda #NT_BUFFER_STEP
			sta nametable_buffers, x
			inx

			lda anim_width, y
			sta nametable_buffers, x
			inx

			sta tmpfield3

			;ldy deathplosion_step ; useless, done above
			lda #$23
			sta nametable_buffers, x
			inx

			.(
				lda deathplosion_origin
				beq bottom
				bpl top
				and #%01000000
				beq right
					left:
						lda anim_left_pos, y
						jmp ok
					right:
						lda anim_right_pos, y
						jmp ok
					top:
						lda anim_top_pos, y
						jmp ok
					bottom:
						lda anim_bottom_pos, y
				ok:
			.)
			clc
			adc deathplosion_pos
			sta nametable_buffers, x
			inx

			.(
				bit deathplosion_origin
				bpl vertical
					horizontal:
						lda #1
						jmp ok
					vertical:
						lda #8
				ok:
				sta nametable_buffers, x
				inx
			.)

			lda anim_payload_lsb, y
			sta tmpfield1
			lda anim_payload_msb, y
			sta tmpfield2

			.(
				bit deathplosion_origin
				bvs mirrored

					natural:
					.(
						ldy #0
						copy_one_byte:
							lda (tmpfield1), y
							sta nametable_buffers, x
							inx
							iny

							cpy tmpfield3
							bne copy_one_byte

						jmp payload_ok
					.)

					mirrored:
					.(
						ldy tmpfield3
						copy_one_byte:
							dey
							lda (tmpfield1), y
							sta nametable_buffers, x
							inx

							cpy #0
							bne copy_one_byte
					.)
			.)
			payload_ok:

			lda #NT_BUFFER_END
			sta nametable_buffers, x
			stx nt_buffers_end
		.)

	end_draw:

	; Next step (and repair screen if it was the last)
	.(
		dec deathplosion_step
		bpl ok
			dec stage_screen_effect
		ok:
	.)

	rts

	; Addresses of the content of animation's frame, one per frame (last frame listed first)
	anim_payload_lsb:
		.byt <anim_frame15
		.byt <anim_frame14
		.byt <anim_frame13
		.byt <anim_frame12
		.byt <anim_frame11
		.byt <anim_frame10
		.byt <anim_frame9
		.byt <anim_frame8
		.byt <anim_frame7
		.byt <anim_frame6
		.byt <anim_frame5
		.byt <anim_frame4
		.byt <anim_frame3
		.byt <anim_frame2
		.byt <anim_frame1
	anim_payload_msb:
		.byt >anim_frame15
		.byt >anim_frame14
		.byt >anim_frame13
		.byt >anim_frame12
		.byt >anim_frame11
		.byt >anim_frame10
		.byt >anim_frame9
		.byt >anim_frame8
		.byt >anim_frame7
		.byt >anim_frame6
		.byt >anim_frame5
		.byt >anim_frame4
		.byt >anim_frame3
		.byt >anim_frame2
		.byt >anim_frame1

	; Frame's content size
	anim_width:
		.byt anim_frame15_width
		.byt anim_frame14_width
		.byt anim_frame13_width
		.byt anim_frame12_width
		.byt anim_frame11_width
		.byt anim_frame10_width
		.byt anim_frame9_width
		.byt anim_frame8_width
		.byt anim_frame7_width
		.byt anim_frame6_width
		.byt anim_frame5_width
		.byt anim_frame4_width
		.byt anim_frame3_width
		.byt anim_frame2_width
		.byt anim_frame1_width

	+DEATHPLOSION_FRAME_COUNT = *-anim_width

	; Position of the animation
	anim_right_pos:
		.byt $c0+anim_frame15_right_pos
		.byt $c0+anim_frame14_right_pos
		.byt $c0+anim_frame13_right_pos
		.byt $c0+anim_frame12_right_pos
		.byt $c0+anim_frame11_right_pos
		.byt $c0+anim_frame10_right_pos
		.byt $c0+anim_frame9_right_pos
		.byt $c0+anim_frame8_right_pos
		.byt $c0+anim_frame7_right_pos
		.byt $c0+anim_frame6_right_pos
		.byt $c0+anim_frame5_right_pos
		.byt $c0+anim_frame4_right_pos
		.byt $c0+anim_frame3_right_pos
		.byt $c0+anim_frame2_right_pos
		.byt $c0+anim_frame1_right_pos
	anim_left_pos:
		.byt $c0+anim_frame15_left_pos
		.byt $c0+anim_frame14_left_pos
		.byt $c0+anim_frame13_left_pos
		.byt $c0+anim_frame12_left_pos
		.byt $c0+anim_frame11_left_pos
		.byt $c0+anim_frame10_left_pos
		.byt $c0+anim_frame9_left_pos
		.byt $c0+anim_frame8_left_pos
		.byt $c0+anim_frame7_left_pos
		.byt $c0+anim_frame6_left_pos
		.byt $c0+anim_frame5_left_pos
		.byt $c0+anim_frame4_left_pos
		.byt $c0+anim_frame3_left_pos
		.byt $c0+anim_frame2_left_pos
		.byt $c0+anim_frame1_left_pos
	anim_top_pos:
		.byt $c0+anim_frame15_top_pos
		.byt $c0+anim_frame14_top_pos
		.byt $c0+anim_frame13_top_pos
		.byt $c0+anim_frame12_top_pos
		.byt $c0+anim_frame11_top_pos
		.byt $c0+anim_frame10_top_pos
		.byt $c0+anim_frame9_top_pos
		.byt $c0+anim_frame8_top_pos
		.byt $c0+anim_frame7_top_pos
		.byt $c0+anim_frame6_top_pos
		.byt $c0+anim_frame5_top_pos
		.byt $c0+anim_frame4_top_pos
		.byt $c0+anim_frame3_top_pos
		.byt $c0+anim_frame2_top_pos
		.byt $c0+anim_frame1_top_pos
	anim_bottom_pos:
		.byt $c0+anim_frame15_bottom_pos
		.byt $c0+anim_frame14_bottom_pos
		.byt $c0+anim_frame13_bottom_pos
		.byt $c0+anim_frame12_bottom_pos
		.byt $c0+anim_frame11_bottom_pos
		.byt $c0+anim_frame10_bottom_pos
		.byt $c0+anim_frame9_bottom_pos
		.byt $c0+anim_frame8_bottom_pos
		.byt $c0+anim_frame7_bottom_pos
		.byt $c0+anim_frame6_bottom_pos
		.byt $c0+anim_frame5_bottom_pos
		.byt $c0+anim_frame4_bottom_pos
		.byt $c0+anim_frame3_bottom_pos
		.byt $c0+anim_frame2_bottom_pos
		.byt $c0+anim_frame1_bottom_pos

#define ATT(br,bl,tr,tl) ((br << 6) + (bl << 4) + (tr << 2) + tl)
	anim_frame1:
		.byt                             ATT(3,3,3,3), ATT(3,3,3,3), ATT(3,3,3,3), ATT(3,3,3,3), ATT(3,3,3,3)
		anim_frame1_width = *-anim_frame1
		anim_frame1_right_pos = 8*1+(8-(*-anim_frame1))
		anim_frame1_left_pos = 8*1
		anim_frame1_top_pos = 1
		anim_frame1_bottom_pos = 1+8*(8-(*-anim_frame1))
	anim_frame2:
		.byt ATT(3,3,3,3), ATT(3,3,3,3), ATT(3,3,3,3), ATT(3,3,3,3), ATT(3,3,3,3), ATT(3,3,3,3), ATT(3,3,3,3)
		anim_frame2_width = *-anim_frame2
		anim_frame2_right_pos = 8*1+(8-(*-anim_frame2))
		anim_frame2_left_pos = 8*1
		anim_frame2_top_pos = 1
		anim_frame2_bottom_pos = 1+8*(8-(*-anim_frame2))
	anim_frame3:
		.byt               ATT(3,3,3,3), ATT(3,3,3,3), ATT(3,3,3,3), ATT(3,3,3,3), ATT(3,3,3,3), ATT(3,3,3,3)
		anim_frame3_width = *-anim_frame3
		anim_frame3_right_pos = 8*2+(8-(*-anim_frame3))
		anim_frame3_left_pos = 8*2
		anim_frame3_top_pos = 2
		anim_frame3_bottom_pos = 2+8*(8-(*-anim_frame3))

	anim_frame4:
		.byt ATT(3,3,3,3), ATT(3,3,3,3), ATT(3,3,3,3), ATT(3,3,3,3), ATT(3,3,3,3), ATT(0,3,0,0), ATT(0,0,0,0)
		anim_frame4_width = *-anim_frame4
		anim_frame4_right_pos = 8*1+(8-(*-anim_frame4))
		anim_frame4_left_pos = 8*1
		anim_frame4_top_pos = 1
		anim_frame4_bottom_pos = 1+8*(8-(*-anim_frame4))
	anim_frame5:
		.byt ATT(3,0,0,0), ATT(3,3,3,3), ATT(3,3,3,3), ATT(3,3,3,3), ATT(3,3,3,3), ATT(3,3,3,3), ATT(0,0,0,0)
		anim_frame5_width = *-anim_frame5
		anim_frame5_right_pos = 8*0+(8-(*-anim_frame5))
		anim_frame5_left_pos = 8*0
		anim_frame5_top_pos = 0
		anim_frame5_bottom_pos = 0+8*(8-(*-anim_frame5))
	anim_frame6:
		.byt ATT(0,0,3,3), ATT(3,0,3,3), ATT(3,3,3,3), ATT(3,3,3,3), ATT(3,3,3,3), ATT(3,3,3,3), ATT(3,3,3,3)
		anim_frame6_width = *-anim_frame6
		anim_frame6_right_pos = 8*2+(8-(*-anim_frame6))
		anim_frame6_left_pos = 8*2
		anim_frame6_top_pos = 2
		anim_frame6_bottom_pos = 2+8*(8-(*-anim_frame6))

	anim_frame7:
		.byt ATT(0,3,3,0), ATT(3,3,3,3), ATT(3,3,3,3), ATT(3,3,3,3), ATT(0,0,0,0), ATT(0,0,0,0), ATT(0,0,0,0)
		anim_frame7_width = *-anim_frame7
		anim_frame7_right_pos = 8*1+(8-(*-anim_frame7))
		anim_frame7_left_pos = 8*1
		anim_frame7_top_pos = 1
		anim_frame7_bottom_pos = 1+8*(8-(*-anim_frame7))
	anim_frame8:
		.byt ATT(0,0,0,0), ATT(0,3,3,3), ATT(3,3,3,3), ATT(3,3,3,3), ATT(3,0,0,3), ATT(0,0,0,3), ATT(0,0,0,0)
		anim_frame8_width = *-anim_frame8
		anim_frame8_right_pos = 8*0+(8-(*-anim_frame8))
		anim_frame8_left_pos = 8*0
		anim_frame8_top_pos = 0
		anim_frame8_bottom_pos = 0+8*(8-(*-anim_frame8))
	anim_frame9:
		.byt ATT(0,0,3,3), ATT(3,0,3,3), ATT(3,3,3,3), ATT(3,3,3,3), ATT(0,0,3,0), ATT(3,0,0,0), ATT(0,0,0,0)
		anim_frame9_width = *-anim_frame9
		anim_frame9_right_pos = 8*2+(8-(*-anim_frame9))
		anim_frame9_left_pos = 8*2
		anim_frame9_top_pos = 2
		anim_frame9_bottom_pos = 2+8*(8-(*-anim_frame9))

	anim_frame10:
		.byt ATT(3,0,0,3), ATT(3,3,3,3), ATT(3,3,3,3), ATT(3,3,3,3), ATT(0,0,0,0), ATT(0,0,0,0), ATT(0,0,0,0)
		anim_frame10_width = *-anim_frame10
		anim_frame10_right_pos = 8*1+(8-(*-anim_frame10))
		anim_frame10_left_pos = 8*1
		anim_frame10_top_pos = 1
		anim_frame10_bottom_pos = 1+8*(8-(*-anim_frame10))
	anim_frame11:
		.byt ATT(0,0,0,0), ATT(3,0,0,0), ATT(3,3,3,3), ATT(3,3,3,3), ATT(0,0,3,0), ATT(0,0,0,0), ATT(0,0,0,0)
		anim_frame11_width = *-anim_frame11
		anim_frame11_right_pos = 8*0+(8-(*-anim_frame11))
		anim_frame11_left_pos = 8*0
		anim_frame11_top_pos = 0
		anim_frame11_bottom_pos = 0+8*(8-(*-anim_frame11))
	anim_frame12:
		.byt ATT(3,0,0,3), ATT(0,3,3,0), ATT(3,3,3,3), ATT(3,3,3,3), ATT(0,3,0,0), ATT(0,0,0,0), ATT(0,0,0,0)
		anim_frame12_width = *-anim_frame12
		anim_frame12_right_pos = 8*2+(8-(*-anim_frame12))
		anim_frame12_left_pos = 8*2
		anim_frame12_top_pos = 2
		anim_frame12_bottom_pos = 2+8*(8-(*-anim_frame12))

	anim_frame13:
		.byt ATT(0,3,3,0), ATT(3,3,3,3), ATT(0,3,3,0), ATT(0,0,0,0), ATT(0,0,0,0), ATT(0,0,0,0), ATT(0,0,0,0)
		anim_frame13_width = *-anim_frame13
		anim_frame13_right_pos = 8*1+(8-(*-anim_frame13))
		anim_frame13_left_pos = 8*1
		anim_frame13_top_pos = 1
		anim_frame13_bottom_pos = 1+8*(8-(*-anim_frame13))
	anim_frame14:
		.byt ATT(0,0,0,0), ATT(0,3,0,0), ATT(0,3,0,3), ATT(0,0,0,3), ATT(0,0,0,0), ATT(0,0,0,0), ATT(0,0,0,0)
		anim_frame14_width = *-anim_frame14
		anim_frame14_right_pos = 8*0+(8-(*-anim_frame14))
		anim_frame14_left_pos = 8*0
		anim_frame14_top_pos = 0
		anim_frame14_bottom_pos = 0+8*(8-(*-anim_frame14))
	anim_frame15:
		.byt ATT(0,3,3,0), ATT(0,3,3,0), ATT(3,0,3,0), ATT(0,3,0,0), ATT(0,0,0,0), ATT(0,0,0,0), ATT(0,0,0,0)
		anim_frame15_width = *-anim_frame15
		anim_frame15_right_pos = 8*2+(8-(*-anim_frame15))
		anim_frame15_left_pos = 8*2
		anim_frame15_top_pos = 2
		anim_frame15_bottom_pos = 2+8*(8-(*-anim_frame15))
#undef ATT
.)

; Set Z flag to 1 if the current frame need to be skipped, follow to gameover
; screen when the counter goes to zero
+slowdown:
.(
    dec slow_down_counter
    beq next_screen
		check_if_skip_frame:
			lda slow_down_counter
			and #%00000011
			rts

		next_screen:
			; Call game mode handler for end-game. It shall never return (should call change_global_gamestate)
			ldx config_game_mode
			lda game_modes_gameover_lsb, x
			sta tmpfield1
			lda game_modes_gameover_msb, x
			sta tmpfield2
			jmp (tmpfield1) ;NOTE beware if a mode wants to return, we are not in the fixed bank (our caller may be)
			; No return, jump to subroutine
.)

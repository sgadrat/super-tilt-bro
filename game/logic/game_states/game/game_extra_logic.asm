+GAMESTATE_GAME_EXTRA_BANK = CURRENT_BANK_NUMBER

+extra_init_game_state:
.(
	.(
		; Clear background of nametable 2
		jsr clear_bg_bot_left

		; Store characters' tiles in CHR
		.(
			ldx #1
			loop:
				jsr place_character_ppu_illustrations
				TRAMPOLINE(place_character_ppu_tiles, #0, #CURRENT_BANK_NUMBER)
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

		; Setup logical game state to the game startup configuration
		lda DIRECTION_LEFT
		sta player_b_direction

		lda DIRECTION_RIGHT
		sta player_a_direction

		lda HITBOX_DISABLED
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

	place_character_ppu_illustrations:
	.(
		illustration_addr = tmpfield1
		illustration_size = tmpfield3
		illustration_addr_tmp = tmpfield4
		char_bank = tmpfield6

		lda PPUSTATUS
		lda illustrations_addr_msb, x
		sta PPUADDR
		lda illustrations_addr_lsb, x
		sta PPUADDR

		ldy config_player_a_character, x
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

		lda illustration_addr_tmp
		sta illustration_addr
		lda illustration_addr_tmp+1
		sta illustration_addr+1
		lda #5
		sta illustration_size

		TRAMPOLINE(cpu_to_ppu_copy_tiles, char_bank, #CURRENT_BANK_NUMBER)

		rts

		illustrations_addr_msb:
		.byt $1d, $1d
		illustrations_addr_lsb:
		.byt $00, $50
	.)

	header_player_a:
	.byt $01, $3f, $11, $03
	header_player_b:
	.byt $01, $3f, $19, $03
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
		.byt <music_perihelium_info, <music_sinbad_info, <music_adventure_info, <music_volcano_info, <music_kiki_info
	ingame_themes_msb:
		.byt >music_perihelium_info, >music_sinbad_info, >music_adventure_info, >music_volcano_info, >music_kiki_info
	ingame_themes_bank:
		.byt music_perihelium_bank, music_sinbad_bank, music_adventure_bank, music_volcano_bank, music_kiki_bank
	LAST_INGAME_TRACK = ingame_themes_msb - ingame_themes_lsb - 1
.)

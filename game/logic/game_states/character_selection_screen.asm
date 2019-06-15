#define NB_OPTIONS 3
#define CHARACTER_SELECTION_OPTION_CHARACTER_PALETTE 0
#define CHARACTER_SELECTION_OPTION_WEAPON 1
#define CHARACTER_SELECTION_OPTION_CHARACTER 2

init_character_selection_screen:
.(
	.(
		SWITCH_BANK(#DATA_BANK_NUMBER)

		; Construct nt buffers for palettes (to avoid changing it mid-frame)
		lda #<palette_character_selection
		sta tmpfield1
		lda #>palette_character_selection
		sta tmpfield2
		jsr construct_palettes_nt_buffer

		; Copy background from PRG-rom to PPU nametable
		lda #<nametable_character_selection
		sta tmpfield1
		lda #>nametable_character_selection
		sta tmpfield2
		jsr draw_zipped_nametable

		; Store characters' tiles in CHR
		; TODO avoid palette change midframe (can wait vblank or create an nt buffers)
		ldx #0
		jsr place_character_ppu_tiles
		ldx #1
		jsr place_character_ppu_tiles

		; Initialize player A's animation state
		; TODO have a menu-select animation instead of using victory
		ldx #0
		ldy config_player_a_character, x
		SWITCH_BANK(characters_bank_number COMMA y)

		lda #<character_selection_player_a_animation
		sta tmpfield11
		lda #>character_selection_player_a_animation
		sta tmpfield12

		lda characters_properties_lsb, y
		sta tmpfield1
		lda characters_properties_msb, y
		sta tmpfield2
		ldy #CHARACTERS_PROPERTIES_VICTORY_ANIM_OFFSET
		lda (tmpfield1), y
		sta tmpfield13
		iny
		lda (tmpfield1), y
		sta tmpfield14

		jsr animation_init_state

		lda #INGAME_PLAYER_A_FIRST_SPRITE
		sta character_selection_player_a_animation+ANIMATION_STATE_OFFSET_FIRST_SPRITE_NUM
		lda #INGAME_PLAYER_A_LAST_SPRITE
		sta character_selection_player_a_animation+ANIMATION_STATE_OFFSET_LAST_SPRITE_NUM
		lda #$44
		sta character_selection_player_a_animation+ANIMATION_STATE_OFFSET_X_LSB
		lda #$58
		sta character_selection_player_a_animation+ANIMATION_STATE_OFFSET_Y_LSB

		; Initialize player B's animation state
		; TODO have a menu-select animation instead of using victory
		ldx #1
		ldy config_player_a_character, x
		SWITCH_BANK(characters_bank_number COMMA y)

		lda #<character_selection_player_b_animation
		sta tmpfield11
		lda #>character_selection_player_b_animation
		sta tmpfield12

		lda characters_properties_lsb, y
		sta tmpfield1
		lda characters_properties_msb, y
		sta tmpfield2
		ldy #CHARACTERS_PROPERTIES_VICTORY_ANIM_OFFSET
		lda (tmpfield1), y
		sta tmpfield13
		iny
		lda (tmpfield1), y
		sta tmpfield14

		jsr animation_init_state

		lda #INGAME_PLAYER_B_FIRST_SPRITE
		sta character_selection_player_b_animation+ANIMATION_STATE_OFFSET_FIRST_SPRITE_NUM
		lda #INGAME_PLAYER_B_LAST_SPRITE
		sta character_selection_player_b_animation+ANIMATION_STATE_OFFSET_LAST_SPRITE_NUM
		lda #$b4
		sta character_selection_player_b_animation+ANIMATION_STATE_OFFSET_X_LSB
		lda #$58
		sta character_selection_player_b_animation+ANIMATION_STATE_OFFSET_Y_LSB

		; Init local options values from global state
		lda #0
		sta character_selection_player_a_selected_option
		sta character_selection_player_b_selected_option

		; Adapt to configuration's state
		jsr character_selection_update_screen

		; Wait VBI to process nt buffers
		bit PPUSTATUS ; Clear PPUSTATUS bit 7 to avoid starting at the middle of the current VBI

		lda #$80          ;
		wait_vbi:         ; Wait for PPUSTATUS bit 7 to be set
			bit PPUSTATUS ; indicating the begining of a VBI
			beq wait_vbi  ;

		; Process the batch of nt buffers immediately (while the PPU is disabled)
		jsr process_nt_buffers
		jsr reset_nt_buffers

		rts
	.)
.)

character_selection_screen_tick:
.(
	.(
		; Clear already written buffers
		jsr reset_nt_buffers

		; Refresh players animations
		jsr character_selection_tick_animations

		; Check if a button is released and trigger correct action
		ldx #0
		check_one_controller:

		lda controller_a_btns, x
		bne next_controller

		ldy #0
		btn_search_loop:
		lda buttons_numbering, y
		cmp controller_a_last_frame_btns, x
		beq jump_from_table
		iny
		cpy #7
		bne btn_search_loop

		next_controller:
		inx
		cpx #2
		bne check_one_controller
		jmp end

		jump_from_table:
		tya
		asl
		tay
		lda buttons_actions, y
		sta tmpfield1
		lda buttons_actions+1, y
		sta tmpfield2
		jmp (tmpfield1)

		; Go to the next screen
		next_screen:
		.(
			lda #GAME_STATE_STAGE_SELECTION
			jsr change_global_game_state
			; jmp end ; not needed, change_global_game_state does not return
		.)

		previous_screen:
		.(
			lda #GAME_STATE_CONFIG
			jsr change_global_game_state
			; jmp end ; not needed, change_global_game_state does not return
		.)

		next_value:
		.(
			txa
			pha
			lda character_selection_player_a_selected_option, x
			asl
			tax
			lda next_value_handlers, x
			sta tmpfield1
			lda next_value_handlers+1, x
			sta tmpfield2
			pla
			tax
			jmp (tmpfield1)
			jmp end
		.)

		previous_value:
		.(
			txa
			pha
			lda character_selection_player_a_selected_option, x
			asl
			tax
			lda previous_value_handlers, x
			sta tmpfield1
			lda previous_value_handlers+1, x
			sta tmpfield2
			pla
			tax
			jmp (tmpfield1)
			jmp end
		.)

		next_option:
		.(
			inc character_selection_player_a_selected_option, x
			lda character_selection_player_a_selected_option, x
			cmp #NB_OPTIONS
			bne refresh_player_highlighting
			lda #0
			sta character_selection_player_a_selected_option, x

			jmp refresh_player_highlighting
		.)

		previous_option:
		.(
			dec character_selection_player_a_selected_option, x
			bpl refresh_player_highlighting
			lda #NB_OPTIONS-1
			sta character_selection_player_a_selected_option, x
			jmp refresh_player_highlighting
		.)

		refresh_player_highlighting:
		.(
			txa
			pha
			lda #CHARACTER_SELECTION_OPTION_CHARACTER_PALETTE
			sta tmpfield1
			jsr character_selection_highligh_option

			pla
			tax
			pha
			lda #CHARACTER_SELECTION_OPTION_WEAPON
			sta tmpfield1
			jsr character_selection_highligh_option

			pla
			tax
			lda #CHARACTER_SELECTION_OPTION_CHARACTER
			sta tmpfield1
			jsr character_selection_highligh_option

			jmp end
		.)

		next_character_color:
		.(
			inc config_player_a_character_palette, x
			lda config_player_a_character_palette, x
			cmp #NB_CHARACTER_PALETTES
			bne refresh_player_character_color
			lda #0
			sta config_player_a_character_palette, x
			jmp refresh_player_character_color
		.)

		previous_character_color:
		.(
			dec config_player_a_character_palette, x
			bpl refresh_player_character_color
			lda #NB_CHARACTER_PALETTES-1
			sta config_player_a_character_palette, x
			jmp refresh_player_character_color
		.)

		refresh_player_character_color:
		.(
			lda #CHARACTER_SELECTION_OPTION_CHARACTER_PALETTE
			sta tmpfield1
			jsr character_selection_draw_value
			jmp end
		.)

		next_weapon_color:
		.(
			inc config_player_a_weapon_palette, x
			lda config_player_a_weapon_palette, x
			cmp #NB_WEAPON_PALETTES
			bne refresh_player_weapon
			lda #0
			sta config_player_a_weapon_palette, x
			jmp refresh_player_weapon
		.)

		previous_weapon_color:
		.(
			dec config_player_a_weapon_palette, x
			bpl refresh_player_weapon
			lda #NB_WEAPON_PALETTES-1
			sta config_player_a_weapon_palette, x
			jmp refresh_player_weapon
		.)

		refresh_player_weapon:
		.(
			lda #CHARACTER_SELECTION_OPTION_WEAPON
			sta tmpfield1
			jsr character_selection_draw_value
			jmp end
		.)

		next_character:
		.(
			inc config_player_a_character, x
			lda config_player_a_character, x
			cmp #CHARACTERS_NUMBER
			bne refresh_player_character
			lda #0
			sta config_player_a_character, x
			jmp refresh_player_character
		.)

		previous_character:
		.(
			dec config_player_a_character, x
			bpl refresh_player_character
			lda #CHARACTERS_NUMBER-1
			sta config_player_a_character, x
			jmp refresh_player_character
		.)

		refresh_player_character:
		.(
			prg_tiles = tmpfield2 ; do not use tmpfield1, NMI handle overwrites it
			prg_tiles_msb = tmpfield3
			ppu_tiles = tmpfield4
			ppu_tiles_msb = tmpfield5
			ppu_write_count = tmpfield6

			; Select new character's bank
			ldy config_player_a_character, x
			SWITCH_BANK(characters_bank_number COMMA y)

			; Change current animation to the new character's one
			lda animation_states_addresses_lsb, x
			sta tmpfield11
			lda animation_states_addresses_msb, x
			sta tmpfield12
			lda #<anim_invisible
			sta tmpfield13
			lda #>anim_invisible
			sta tmpfield14
			jsr animation_state_change_animation

			; Write new character's tiles in PPU-RAM
			txa
			pha
			.(
				; Put PRG tiles address in a fixed location
				ldy config_player_a_character, x
				lda characters_tiles_data_lsb, y
				sta prg_tiles
				lda characters_tiles_data_msb, y
				sta prg_tiles_msb

				; Set CHR tiles address in a fixed location
				cpx #0
				bne player_b
					lda #<CHARACTERS_CHARACTER_A_TILES_OFFSET
					sta ppu_tiles
					lda #>CHARACTERS_CHARACTER_A_TILES_OFFSET
					jmp end_set_ppu_addr
				player_b:
					lda #<CHARACTERS_CHARACTER_B_TILES_OFFSET
					sta ppu_tiles
					lda #>CHARACTERS_CHARACTER_B_TILES_OFFSET
				end_set_ppu_addr:
				sta ppu_tiles_msb

				; Copy character's tiles to PPU
				;  create a series a nt buffers to be processed in consecutive NMIs to avoid disabling rendering
				;  TODO Do it asynchronously to let the other player continue to configure its character during the copy
				BYTES_PER_ITERATIONS = 48
				NB_ITERATIONS = 32
#if NB_ITERATIONS*BYTES_PER_ITERATIONS <> CHARACTERS_NUM_TILES_PER_CHAR*16
#error "Incorrect number of copied bytes"
#endif
				lda #NB_ITERATIONS-1
				sta ppu_write_count
				write_ppu:
					; Clear any potential nt buffer
					jsr wait_next_frame
					jsr reset_nt_buffers

					; Tick animations
					lda prg_tiles
					pha
					lda prg_tiles_msb
					pha
					lda ppu_tiles
					pha
					lda ppu_tiles_msb
					pha
					lda ppu_write_count
					pha
					jsr character_selection_tick_animations
					pla
					sta ppu_write_count
					pla
					sta ppu_tiles_msb
					pla
					sta ppu_tiles
					pla
					sta prg_tiles_msb
					pla
					sta prg_tiles

					; Re-select the new character's bank (tick_animations may have changed that)
					pla
					pha
					tax
					ldy config_player_a_character, x
					SWITCH_BANK(characters_bank_number COMMA y)

					; Copy a chunk of bytes
					jsr last_nt_buffer
					lda #$01
					sta nametable_buffers, x
					inx
					lda ppu_tiles_msb
					sta nametable_buffers, x
					inx
					lda ppu_tiles
					sta nametable_buffers, x
					inx
					lda #BYTES_PER_ITERATIONS
					sta nametable_buffers, x
					inx

					ldy #0
					copy_one_byte:
						lda (prg_tiles), y
						sta nametable_buffers, x
						iny
						inx

						cpy #BYTES_PER_ITERATIONS
						bne copy_one_byte

					lda #0
					sta nametable_buffers, x

					; Update tiles addresses to the next byte to copy
					lda #BYTES_PER_ITERATIONS
					clc
					adc prg_tiles
					sta prg_tiles
					lda #0
					adc prg_tiles_msb
					sta prg_tiles_msb

					lda #BYTES_PER_ITERATIONS
					clc
					adc ppu_tiles
					sta ppu_tiles
					lda #0
					adc ppu_tiles_msb
					sta ppu_tiles_msb

					; Loop
#if NB_ITERATIONS >= 128
#error "This loop code expects that bit 7 of any valid ppu_write_count is not set"
#endif
					dec ppu_write_count
					bpl write_ppu
			.)
			pla
			tax

			; Change current animation to the new character's one
			lda animation_states_addresses_lsb, x
			sta tmpfield11
			lda animation_states_addresses_msb, x
			sta tmpfield12

			ldy config_player_a_character, x

			lda characters_properties_lsb, y
			sta tmpfield1
			lda characters_properties_msb, y
			sta tmpfield2
			ldy #CHARACTERS_PROPERTIES_VICTORY_ANIM_OFFSET
			lda (tmpfield1), y
			sta tmpfield13
			iny
			lda (tmpfield1), y
			sta tmpfield14

			jsr animation_state_change_animation

			; Refresh character palette options (and set it to #0 to avoid any overflow)
			txa
			pha
			jsr wait_next_frame
			jsr reset_nt_buffers
			jsr character_selection_tick_animations
			pla
			tax

			option = tmpfield1
			ldy #CHARACTER_SELECTION_OPTION_CHARACTER_PALETTE
			sty option
			lda #0
			sta config_player_a_character_palette, x
			txa
			pha
			jsr character_selection_draw_value
			pla
			tax

			ldy #CHARACTER_SELECTION_OPTION_WEAPON
			sty option
			lda #0
			sta config_player_a_weapon_palette, x
			txa
			pha
			jsr character_selection_draw_value
			pla
			tax

			jmp end

			animation_states_addresses_lsb:
			.byt <character_selection_player_a_animation, <character_selection_player_b_animation
			animation_states_addresses_msb:
			.byt >character_selection_player_a_animation, >character_selection_player_b_animation
		.)

		end:
		rts

		buttons_numbering:
		.byt CONTROLLER_BTN_RIGHT, CONTROLLER_BTN_LEFT, CONTROLLER_BTN_DOWN, CONTROLLER_BTN_UP, CONTROLLER_BTN_START, CONTROLLER_BTN_B, CONTROLLER_BTN_A
		buttons_actions:
		.word next_value,          previous_value,      next_option,         previous_option,   next_screen,          previous_screen,  next_value

		next_value_handlers:
		.word next_character_color, next_weapon_color, next_character

		previous_value_handlers:
		.word previous_character_color, previous_weapon_color, previous_character
	.)
.)

; Tick animations in characters portraits
; Overwrites all registers and all tmpfields
character_selection_tick_animations:
.(
		; Tick character A's animation
		ldx #0
		stx player_number
		ldy config_player_a_character, x
        SWITCH_BANK(characters_bank_number COMMA y)

		lda #<character_selection_player_a_animation
		sta tmpfield11
		lda #>character_selection_player_a_animation
		sta tmpfield12
		lda #0
		sta tmpfield13
		sta tmpfield14
		sta tmpfield15
		sta tmpfield16
		jsr animation_draw
		jsr animation_tick

		; Tick character B's animation
		ldx #1
		stx player_number
		ldy config_player_a_character, x
        SWITCH_BANK(characters_bank_number COMMA y)

		lda #<character_selection_player_b_animation
		sta tmpfield11
		lda #>character_selection_player_b_animation
		sta tmpfield12
		lda #0
		sta tmpfield13
		sta tmpfield14
		sta tmpfield15
		sta tmpfield16
		jsr animation_draw
		jsr animation_tick

		rts
.)

character_selection_update_screen:
.(
	option = tmpfield1

	lda #0
	sta option

	highlight_one_option:
	ldx #0
	jsr character_selection_highligh_option
	ldx #0
	jsr character_selection_draw_value
	ldx #1
	jsr character_selection_highligh_option
	ldx #1
	jsr character_selection_draw_value

	inc option
	lda option
	cmp #NB_OPTIONS
	bne highlight_one_option

	rts
.)

; Change the higlighting of an option to match its selection state
;  register X - player's number
;  tmpfield1 - Option to change
;
;  Overwrites registers, tmpfield2, tmpfield3, tmpfield4 and tmpfield5
character_selection_highligh_option:
.(
	option = tmpfield1
	buffer_index = tmpfield2
	buffer_length = tmpfield3
	buffer_vector = tmpfield4
	; tmpfield5 is buffer_vector's MSB

	; Compute the index of the buffer corresponding to the option
	;  index = 4*option + 2*X + status
	;  (with status being 0 for inactive, 1 for active)

	lda character_selection_player_a_selected_option, x
	cmp option
	bne status_inactive
	lda #1
	jmp write_status_component
	status_inactive:
	lda #0
	write_status_component:
	sta buffer_index

	txa
	asl
	; clc ; useless, asl shall not overflow
	adc buffer_index
	sta buffer_index

	lda option
	asl
	asl
	; clc ; useless, asl shall not overflow
	adc buffer_index
	sta buffer_index

	; Store buffer's information in fixed memory location

	lda buffer_index
	tax
	lda options_buffer_length, x
	sta buffer_length
	lda options_buffer_lsb, x
	sta buffer_vector
	lda options_buffer_msb, x
	sta buffer_vector+1

	; Copy the buffer to the list of buffers to be processed

	jsr last_nt_buffer
	ldy #0
	copy_one_byte:
	lda (buffer_vector), y
	sta nametable_buffers, x
	inx
	iny
	cpy buffer_length
	bne copy_one_byte
	lda #$00
	sta nametable_buffers, x

	rts

	options_buffer_length:
	.byt 14, 14, 14, 14, 7, 7, 7, 7, 7, 7, 7, 7
	options_buffer_lsb:
	.byt <buffer_player_a_character_palette_inactive, <buffer_player_a_character_palette_active
	.byt <buffer_player_b_character_palette_inactive, <buffer_player_b_character_palette_active
	.byt <buffer_player_a_weapon_inactive,            <buffer_player_a_weapon_active
	.byt <buffer_player_b_weapon_inactive,            <buffer_player_b_weapon_active
	.byt <buffer_player_a_character_inactive,         <buffer_player_a_character_active
	.byt <buffer_player_b_character_inactive,         <buffer_player_b_character_active
	options_buffer_msb:
	.byt >buffer_player_a_character_palette_inactive, >buffer_player_a_character_palette_active
	.byt >buffer_player_b_character_palette_inactive, >buffer_player_b_character_palette_active
	.byt >buffer_player_a_weapon_inactive,            >buffer_player_a_weapon_active
	.byt >buffer_player_b_weapon_inactive,            >buffer_player_b_weapon_active
	.byt >buffer_player_a_character_inactive,         >buffer_player_a_character_active
	.byt >buffer_player_b_character_inactive,         >buffer_player_b_character_active

	buffer_player_a_character_palette_active:
	.byt $01, $23, $d9, $03, %01011000, %01011010, %01010000
	.byt $01, $23, $e1, $03, %00000101, %00000101, %00000101
	buffer_player_a_character_palette_inactive:
	.byt $01, $23, $d9, $03, %00001000, %00001010, %00000000
	.byt $01, $23, $e1, $03, %00000000, %00000000, %00000000
	buffer_player_b_character_palette_active:
	.byt $01, $23, $dc, $03, %01010000, %01011010, %01010010
	.byt $01, $23, $e4, $03, %00000101, %00000101, %00000101
	buffer_player_b_character_palette_inactive:
	.byt $01, $23, $dc, $03, %00000000, %00001010, %00000010
	.byt $01, $23, $e4, $03, %00000000, %00000000, %00000000
	buffer_player_a_weapon_active:
	.byt $01, $23, $e9, $03, %00000101, %00000101, %00000101
	buffer_player_a_weapon_inactive:
	.byt $01, $23, $e9, $03, %00000000, %00000000, %00000000
	buffer_player_b_weapon_active:
	.byt $01, $23, $ec, $03, %00000101, %00000101, %00000101
	buffer_player_b_weapon_inactive:
	.byt $01, $23, $ec, $03, %00000000, %00000000, %00000000
	buffer_player_a_character_inactive:
	.byt $01, $23, $d1, $03, %10000000, %10100000, %00000000
	buffer_player_a_character_active:
	.byt $01, $23, $d1, $03, %10010000, %10100000, %00010000
	buffer_player_b_character_inactive:
	.byt $01, $23, $d4, $03, %00000000, %10100000, %00100000
	buffer_player_b_character_active:
	.byt $01, $23, $d4, $03, %01000000, %10100000, %01100000
.)

; Reflects an option's value on screen
;  register X - player's number
;  tmpfield1 - Option to change
;
;  Overwrites registers, tmpfield2, tmpfield3, tmpfield4, tmpfield5, tmpfield6, tmpfield7
character_selection_draw_value:
.(
	option = tmpfield1
	; tmpfield2 used as temporary register for some computations and for jumping to option specific routine
	; tmpfield3 used for jumping to option specific routine
	; tmpfield4 used by option specific routines
	header_offset = tmpfield5
	name_offset = tmpfield6
	palette_offset = tmpfield7
	character_number = tmpfield8
	table_addr_lsb = tmpfield9
	table_addr_msb = tmpfield10

	; Save option number
	lda option
	pha

	; Nothing to do for character option
	; TODO actually it should write character name and weapon name
	cmp #CHARACTER_SELECTION_OPTION_CHARACTER
	beq end

	; Compute buffer header's offset
	txa
	sta header_offset
	asl
	;clc ; useless, asl shall not overflow
	adc header_offset
	sta header_offset

	; Store character number and switch to character's bank
	ldy config_player_a_character, x
	sty character_number
	SWITCH_BANK(characters_bank_number COMMA y)

	; Compute palette offset
	lda option    ;
	asl           ;
	sta tmpfield2 ;
	txa           ; X = 2*option_num + X
	clc           ; X now points to weapon or character option
	adc tmpfield2 ;
	tax           ;

	lda config_player_a_character_palette, x
	sta palette_offset
	asl
	;clc ; useless, asl shall not overflow
	adc palette_offset
	sta palette_offset

	; Compute name offset
	lda config_player_a_character_palette, x
	asl
	asl
	asl
	sta name_offset

	; Jump to the good label regarding option
	lda option
	asl
	tay
	lda values_handlers, y
	sta tmpfield2
	lda values_handlers+1, y
	sta tmpfield3
	jmp (tmpfield2)

	end:
	pla        ; Restore option number
	sta option ;
	rts

	draw_character:
	.(
	; Contruct palette buffer
	lda #<buffer_header_player_a_character_palette ;
	clc                                            ;
	adc header_offset                              ;
	sta tmpfield1                                  ; header's address = first_header_address + header_offset
	lda #>buffer_header_player_a_character_palette ;
	adc #0                                         ;
	sta tmpfield2                                  ;

	ldy character_number           ;
	lda characters_palettes_lsb, y ;
	clc                            ;
	adc palette_offset             ;
	sta tmpfield3                  ; payload_address = first_palette_address + palette_offset
	lda characters_palettes_msb, y ;
	adc #0                         ;
	sta tmpfield4                  ;

	jsr construct_nt_buffer

	; Construct name buffer
	lda #<buffer_header_player_a_character_name ;
	clc                                         ;
	adc header_offset                           ;
	sta tmpfield1                               ; header's offser = first_header_address + header_offset
	lda #>buffer_header_player_a_character_name ;
	adc #0                                      ;
	sta tmpfield2                               ;

    ldy character_number                 ;
	lda characters_palettes_names_lsb, y ;
	clc                                  ;
	adc name_offset                      ;
	sta tmpfield3                        ; payload_address = first_name_address + name_offset
	lda characters_palettes_names_msb, y ;
	adc #0                               ;
	sta tmpfield4                        ;

	jsr construct_nt_buffer

	jmp end
	.)

	draw_weapon:
	.(
	; Contruct palette buffer
	lda #<buffer_header_player_a_weapon_palette ;
	clc                                         ;
	adc header_offset                           ;
	sta tmpfield1                               ; header's address = first_header_address + header_offset
	lda #>buffer_header_player_a_weapon_palette ;
	adc #0                                      ;
	sta tmpfield2                               ;

	ldy character_number                  ;
	lda characters_weapon_palettes_lsb, y ;
	clc                                   ;
	adc palette_offset                    ;
	sta tmpfield3                         ; payload_address = first_palette_address + palette_offset
	lda characters_weapon_palettes_msb, y ;
	adc #0                                ;
	sta tmpfield4                         ;

	jsr construct_nt_buffer

	; Construct name buffer
	lda #<buffer_header_player_a_weapon_name ;
	clc                                      ;
	adc header_offset                        ;
	sta tmpfield1                            ; header's offser = first_header_address + header_offset
	lda #>buffer_header_player_a_weapon_name ;
	adc #0                                   ;
	sta tmpfield2                            ;

	ldy character_number
	lda characters_weapon_names_lsb, y ;
	clc                                ;
	adc name_offset                    ;
	sta tmpfield3                      ; payload_address = first_name_address + name_offset
	lda characters_weapon_names_msb, y ;
	adc #0                             ;
	sta tmpfield4                      ;

	jsr construct_nt_buffer
	jmp end
	.)

	values_handlers:
	.word draw_character, draw_weapon

	buffer_header_player_a_character_palette:
	.byt $3f, $11, $03
	buffer_header_player_b_character_palette:
	.byt $3f, $19, $03
	buffer_header_player_a_character_name:
	.byt $21, $e5, $08
	buffer_header_player_b_character_name:
	.byt $21, $f3, $08
	buffer_header_player_a_weapon_palette:
	.byt $3f, $15, $03
	buffer_header_player_b_weapon_palette:
	.byt $3f, $1d, $03
	buffer_header_player_a_weapon_name:
	.byt $22, $85, $08
	buffer_header_player_b_weapon_name:
	.byt $22, $93, $08
.)

;  tmpfield1, tmpfield2 - header address
;  tmpfield3, tmpfield4 - payload address
;
;  Overwrites registers, tmpfield1
construct_nt_buffer:
.(
	header = tmpfield1
	payload = tmpfield3
	payload_size = tmpfield1

	jsr last_nt_buffer

	lda #$01
	sta nametable_buffers, x
	inx

	ldy #0
	copy_header_byte:
	lda (header), y
	sta nametable_buffers, x
	inx
	iny
	cpy #3
	bne copy_header_byte

	sta payload_size
	ldy #0
	copy_payload_byte:
	lda (payload), y
	sta nametable_buffers, x
	inx
	iny
	cpy payload_size
	bne copy_payload_byte

	lda #$00
	sta nametable_buffers, x

	rts
.)

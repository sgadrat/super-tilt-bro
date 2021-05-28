init_character_selection_screen:
.(
	; Initialize C stack
	jsr reinit_c_stack

	; Call C init routine
	SWITCH_BANK(#CHAR_SELECT_SCREEN_EXTRA_BANK_NUMBER)
	jmp init_character_selection_screen_extra

	;rts ; useless, jump to subroutine
.)

character_selection_screen_tick:
.(
	; Call C tick routine
	SWITCH_BANK(#CHAR_SELECT_SCREEN_EXTRA_BANK_NUMBER)
	jmp character_selection_screen_tick_extra

	;rts ; useless, jump to subroutine
.)

; Copy a character's property tiles to RAM buffer
;  tmpfield1 - character number
;  tmpfield2 - property offset
;  tmpfield3 - num bytes to copy
;
;  Overwrites all registers, tmpfield1 to tmpfield 5
character_selection_screen_copy_property:
.(
	char_num = tmpfield1
	property_offset = tmpfield2
	num_bytes = tmpfield3
	property_table = tmpfield4
	property_table_msb = tmpfield5

	; Switch to character's bank
	ldy char_num
	SWITCH_BANK(characters_bank_number COMMA y)

	; Get properties table address
	lda characters_properties_lsb, y
	sta property_table
	lda characters_properties_msb, y
	sta property_table_msb

	; Copy tiles in RAM
	ldy property_offset
	ldx #0
	copy_one_byte:
		lda (property_table), y
		sta character_selection_mem_buffer, x

		iny
		inx
		cpx num_bytes
		bne copy_one_byte

	; Return to caller
	SWITCH_BANK(#CHAR_SELECT_SCREEN_EXTRA_BANK_NUMBER)
	rts
.)

; Copy a character's portrait tiles to RAM buffer
;  tmpfield1 - character number
;
;  Overwrites all registers, tmpfield1 to tmpfield 5
character_selection_screen_copy_portrait:
.(
	; Switch to character's bank
	ldy tmpfield1
	SWITCH_BANK(characters_bank_number COMMA y)

	; Get illustration address in (tmpfield1)
	lda characters_properties_lsb, y
	sta tmpfield4
	lda characters_properties_msb, y
	sta tmpfield5

	ldy #CHARACTERS_PROPERTIES_ILLUSTRATIONS_ADDR_OFFSET
	lda (tmpfield4), y
	clc
	adc #16
	sta tmpfield1
	iny
	lda (tmpfield4), y
	adc #0
	sta tmpfield2

	; Copy tiles in RAM
	ldy #4*16
	copy_one_byte:
		lda (tmpfield1), y
		sta character_selection_mem_buffer, y
		dey
		bpl copy_one_byte

	; Return to caller
	SWITCH_BANK(#CHAR_SELECT_SCREEN_EXTRA_BANK_NUMBER)
	rts
.)

character_selection_copy_to_nt_buffer:
.(
	char_number = tmpfield1
	ppu_tiles_lsb = tmpfield2
	ppu_tiles_msb = tmpfield3
	buffer_size = tmpfield4
	prg_tiles_lsb = tmpfield5
	prg_tiles_msb = tmpfield6

	; Switch to character bank
	ldy char_number
	cpy #CHARACTERS_NUMBER
	bcs stay_on_menu_bank
		SWITCH_BANK(characters_bank_number COMMA y)
	stay_on_menu_bank:

	; Construct nt buffer
	jsr last_nt_buffer
	lda #$01
	sta nametable_buffers, x
	inx
	lda ppu_tiles_msb
	sta nametable_buffers, x
	inx
	lda ppu_tiles_lsb
	sta nametable_buffers, x
	inx
	lda buffer_size
	sta nametable_buffers, x
	inx

	ldy #0
	copy_one_byte:
		lda (prg_tiles_lsb), y
		sta nametable_buffers, x
		iny
		inx

		cpy buffer_size
		bne copy_one_byte

	lda #0
	sta nametable_buffers, x

	; Return to caller
	SWITCH_BANK(#CHAR_SELECT_SCREEN_EXTRA_BANK_NUMBER)
	rts
.)

character_selection_tick_char_anims:
.(
	ldx #0
	stx player_number
	ldy config_requested_player_a_character
	SWITCH_BANK(characters_bank_number COMMA y)
	lda #<character_selection_player_a_char_anim
	sta tmpfield11
	lda #>character_selection_player_a_char_anim
	jsr tick_it

	ldx #1
	stx player_number
	ldy config_requested_player_b_character
	SWITCH_BANK(characters_bank_number COMMA y)
	lda #<character_selection_player_b_char_anim
	sta tmpfield11
	lda #>character_selection_player_b_char_anim
	jsr tick_it

	SWITCH_BANK(#CHAR_SELECT_SCREEN_EXTRA_BANK_NUMBER)
	rts

	tick_it:
	.(
		sta tmpfield12
		lda #0
		sta tmpfield13
		sta tmpfield14
		sta tmpfield15
		sta tmpfield16
		jsr animation_draw
		jmp animation_tick
		;rts ; useless, jump to subroutine
	.)
.)

character_selection_get_char_property:
.(
	char_num = tmpfield1
	property_offset = tmpfield2
	prop_addr_lsb = tmpfield3
	prop_addr_msb = tmpfield4
	prop_value_lsb = tmpfield5
	prop_value_msb = tmpfield6

	ldy char_num
	SWITCH_BANK(characters_bank_number COMMA y)

	lda characters_properties_lsb, y
	sta prop_addr_lsb
	lda characters_properties_msb, y
	sta prop_addr_msb

	ldy property_offset
	lda (prop_addr_lsb), y
	sta prop_value_lsb
	iny
	lda (prop_addr_lsb), y
	sta prop_value_msb

	SWITCH_BANK(#CHAR_SELECT_SCREEN_EXTRA_BANK_NUMBER)
	rts
.)

character_selection_construct_char_nt_buffer:
.(
	;tmpfields 1 to 4 passed to construct_nt_buffer
	char_num = tmpfield5

	ldy char_num
	SWITCH_BANK(characters_bank_number COMMA y)

	jsr construct_nt_buffer

	SWITCH_BANK(#CHAR_SELECT_SCREEN_EXTRA_BANK_NUMBER)
	rts
.)

; Change global game state, without trigerring any transition code
;  Never returns, jumps to main loop
;  Hardcoded destination state to stage selection menu
character_selection_change_global_game_state_lite:
.(
	; Save previous game state and set the global_game_state variable
	lda global_game_state
	sta previous_global_game_state
	lda #GAME_STATE_STAGE_SELECTION
	sta global_game_state

	; Move all sprites offscreen
	ldx #$00
	lda #$fe
	clr_sprites:
		sta oam_mirror, x    ;move all sprites off screen
		inx
		inx
		inx
		inx
		bne clr_sprites

	; Call the appropriate initialization routine
	jsr init_stage_selection_screen

	; Clear stack
	ldx #$ff
	txs

	; Go straight to the main loop
	jmp forever
.)

character_selection_reset_music:
.(
	SWITCH_BANK(#DATA_BANK_NUMBER)
	jsr audio_music_weak
	SWITCH_BANK(#CONFIG_SCREEN_EXTRA_BANK_NUMBER)
	rts
.)

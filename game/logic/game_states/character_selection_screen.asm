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
	SWITCH_BANK(#CHAR_SELECT_SCREEN_EXTRA_BANK_NUMBER)
	rts
.)

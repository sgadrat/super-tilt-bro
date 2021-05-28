init_stage_selection_screen:
.(
	; Initialize C stack
	jsr reinit_c_stack

	; Call C init routine
	SWITCH_BANK(#STAGE_SELECT_SCREEN_EXTRA_BANK_NUMBER)
	jmp init_stage_selection_screen_extra

	;rts ; useless, jump to subroutine
.)

stage_selection_screen_tick:
.(
	; Call C tick routine
	SWITCH_BANK(#STAGE_SELECT_SCREEN_EXTRA_BANK_NUMBER)
	jmp stage_selection_screen_tick_extra

	;rts ; useless, jump to subroutine
.)

; Copy 12 bytes from another bank in RAM
stage_selection_screen_long_memcopy:
.(
	dest = tmpfield1
	dest_msb = tmpfield2
	src_bank = tmpfield3
	src = tmpfield4
	src_msb = tmpfield5

	SWITCH_BANK(src_bank)

	ldy #11
	copy_one_byte:
		lda (src), y
		sta (dest), y
		dey
		bpl copy_one_byte

	SWITCH_BANK(#STAGE_SELECT_SCREEN_EXTRA_BANK_NUMBER)
	rts
.)

stage_selection_tick_music:
.(
	jsr audio_music_tick
	SWITCH_BANK(#STAGE_SELECT_SCREEN_EXTRA_BANK_NUMBER)
	rts
.)

stage_selection_back_to_char_select:
.(
	SWITCH_BANK(#CHAR_SELECT_SCREEN_EXTRA_BANK_NUMBER)

	lda #GAME_STATE_CHARACTER_SELECTION
	sta tmpfield3
	lda #<character_selection_reinit
	sta tmpfield1
	lda #>character_selection_reinit
	sta tmpfield2

	jmp change_global_game_state_lite
	;rts
.)

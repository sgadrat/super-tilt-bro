default_config:
.(
	lda #MAX_STOCKS
	sta config_initial_stocks
	lda #$01
	sta config_ai_level
	sta config_player_b_character
	lda #$00
	sta config_selected_stage
	sta config_player_a_character_palette
	sta config_player_a_weapon_palette
	sta config_player_a_character
	sta config_player_b_character_palette
	sta config_player_b_weapon_palette
	sta config_game_mode
	rts
.)

init_config_screen:
.(
	.(
		; Copy background from PRG-rom to PPU nametable
		SWITCH_BANK(#DATA_BANK_NUMBER)
		lda #<nametable_config
		sta tmpfield1
		lda #>nametable_config
		sta tmpfield2
		jsr draw_zipped_nametable

		; Initialize C stack
		lda #<c_stack_end
		sta _sp0
		lda #>c_stack_end
		sta _sp1

		; Call code exported to extra bank
		SWITCH_BANK(#CONFIG_SCREEN_EXTRA_BANK_NUMBER)
		jsr init_config_screen_extra

		; Construct nt buffers for palettes (to avoid changing it mid-frame)
		SWITCH_BANK(#DATA_BANK_NUMBER)
		lda #<palette_config
		sta tmpfield1
		lda #>palette_config
		sta tmpfield2
		jmp construct_palettes_nt_buffer

		;rts ; useless, jump to a subroutine
	.)
.)

config_screen_tick:
.(
	SWITCH_BANK(#CONFIG_SCREEN_EXTRA_BANK_NUMBER)
	jmp config_screen_tick_extra
	;rts ; useless, jump to a subroutine
.)

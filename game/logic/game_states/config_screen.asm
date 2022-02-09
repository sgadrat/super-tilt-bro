default_config:
.(
	lda #MAX_STOCKS
	sta config_initial_stocks

	lda #$01
	sta config_ai_level
	sta config_player_b_character
	sta config_requested_player_b_character
	sta config_ticks_per_frame

	lda #$00
	sta config_selected_stage
	sta config_requested_stage

	sta config_player_a_character_palette
	sta config_player_a_weapon_palette
	sta config_requested_player_a_palette

	sta config_player_a_character
	sta config_requested_player_a_character

	sta config_player_b_character_palette
	sta config_player_b_weapon_palette
	sta config_requested_player_b_palette

	sta config_game_mode

	sta config_ingame_track

	rts
.)

init_config_screen:
.(
	; Initialize C stack
	jsr reinit_c_stack

	; Call code exported to extra bank
	SWITCH_BANK(#CONFIG_SCREEN_EXTRA_BANK_NUMBER)
	jmp init_config_screen_extra
	;rts ; useless, jump to a subroutine
.)

config_screen_tick:
.(
	SWITCH_BANK(#CONFIG_SCREEN_EXTRA_BANK_NUMBER)
	jmp config_screen_tick_extra
	;rts ; useless, jump to a subroutine
.)

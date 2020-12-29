#define RETURN_FROM_BYTECODE lda #0:sta $ffff
#define CRASH_FROM_BYTECODE lda #1:sta $ffff

server_bytecode_error:
.(
	CRASH_FROM_BYTECODE
.)

server_bytecode_init:
.(
	; Name parameters passed to this routine
	param_stage_num = $00
	character_a = $01
	character_b = $02

	; Set game's configuration
	jsr default_config

	lda param_stage_num
	sta config_selected_stage
	lda character_a
	sta config_player_a_character
	lda character_b
	sta config_player_b_character

	lda #3
	sta config_initial_stocks

    lda #0
    sta config_ai_level
	sta config_game_mode ; 0 is local, we don't want online (1) as it implies input-lag and ignoring controller B

	lda #1
	sta network_rollback_mode

	; Standard game's initialization
	jsr init_game_state

	RETURN_FROM_BYTECODE
.)

server_bytecode_tick:
.(
	jsr game_tick

	RETURN_FROM_BYTECODE
.)

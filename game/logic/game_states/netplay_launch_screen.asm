init_netplay_launch_screen:
.(
	SWITCH_BANK(#DATA_BANK_NUMBER)

	; Enable ESP
	lda #1
	sta RAINBOW_FLAGS

	; Construct nt buffers for palettes (to avoid changing it mid-frame)
	lda #<palette_netplay_launch
	sta tmpfield1
	lda #>palette_netplay_launch
	sta tmpfield2
	jsr construct_palettes_nt_buffer

	; Copy background from PRG-rom to PPU nametable
	lda #<nametable_netplay_launch
	sta tmpfield1
	lda #>nametable_netplay_launch
	sta tmpfield2
	jsr draw_zipped_nametable

	; Initialize common menus effects
	jsr re_init_menu

	; Set initial state
	lda #0
	sta netplay_launch_state

	; Initialize UDP socket
	ESP_SEND_CMD(set_udp_cmd)
	ESP_SEND_CMD(connect_cmd)
	;TODO set IP/port if not configured

	rts

	set_udp_cmd:
		.byt 2, TOESP_MSG_SET_SERVER_PROTOCOL, ESP_PROTOCOL_UDP
	connect_cmd:
		.byt 1, TOESP_MSG_CONNECT_TO_SERVER
.)

netplay_launch_screen_tick:
.(
	.(
		jsr reset_nt_buffers

		; Play common menus effects
		jsr tick_menu

		; Go to a screen or another depending on button released this frame
		ldx netplay_launch_state
		lda state_routines_lsb, x
		sta tmpfield1
		lda state_routines_msb, x
		sta tmpfield2
		jsr call_pointed_subroutine

		rts
	.)

	state_routines_lsb:
	.byt <the_purge
	.byt <client_id_request_rnd, <client_id_set_low, <client_id_request_rnd, <client_id_set_hi
	.byt <estimate_latency_1, <estimate_latency_2
	.byt <connection_1, <connection_2
	.byt <wait_game
	error_state_routines_lsb:
	.byt <no_contact, <bad_ping

	state_routines_msb:
	.byt >the_purge
	.byt >client_id_request_rnd, >client_id_set_low, >client_id_request_rnd, >client_id_set_hi
	.byt >estimate_latency_1, >estimate_latency_2
	.byt >connection_1, >connection_2
	.byt >wait_game
	error_state_routines_msb:
	.byt >no_contact, >bad_ping

	FIRST_ERROR_STATE = error_state_routines_lsb - state_routines_lsb
	ERROR_STATE_NO_CONTACT = FIRST_ERROR_STATE
	ERROR_STATE_BAD_PING = FIRST_ERROR_STATE + 1

	the_purge:
	.(
		; Show progress to the user
		lda #<step_title
		ldy #>step_title
		jsr show_step_name

		; Purge buffers
		lda #1
		sta RAINBOW_DATA
		lda #TOESP_MSG_CLEAR_BUFFERS
		sta RAINBOW_DATA

		; Next step
		inc netplay_launch_state

		rts

		step_title:
			.byt $ee, $f3, $ee, $f9, $ee, $e6, $f1, $ee, $02, $ee, $f3, $ec, $02, $f8, $f9, $fa, $eb, $eb, $02, $02
	.)

	client_id_request_rnd:
	.(
		lda #1
		sta RAINBOW_DATA
		lda #TOESP_MSG_GET_RND_WORD
		sta RAINBOW_DATA

		inc netplay_launch_state
		rts
	.)

	client_id_set_generic:
	.(
		bit RAINBOW_FLAGS
		bpl end

			; Read random bytes from ESP
			lda RAINBOW_DATA ; Garbage byte
			nop
			lda RAINBOW_DATA ; Size (should be 3)
			nop
			lda RAINBOW_DATA ; Type - TODO verify that it is actually FROMESP_MSG_RND_WORD
			nop

			lda RAINBOW_DATA ; Random byte
			sta network_client_id_byte0, x
			inx
			lda RAINBOW_DATA ; Random byte
			sta network_client_id_byte0, x

			; Next step
			inc netplay_launch_state

		end:
		rts
	.)

	client_id_set_low:
	.(
		ldx #0
		jmp client_id_set_generic
	.)

	client_id_set_hi:
	.(
		ldx #2
		jmp client_id_set_generic
	.)

	estimate_latency_1:
	.(
		; Show progress to the user
		lda #<estimate_latency_msg
		ldy #>estimate_latency_msg
		jsr show_step_name

		; Send ping requests to the server
		ESP_SEND_CMD(cmd_ping)

		; Next step - wait for replies
		inc netplay_launch_state

		rts

		estimate_latency_msg:
			.byt $ea, $f8, $f9, $ee, $f2, $e6, $f9, $ea, $02, $f1, $e6, $f9, $ea, $f3, $e8, $fe, $02, $02, $02, $02
		cmd_ping:
			.byt 2, TOESP_MSG_GET_SERVER_PING, 3
	.)

	estimate_latency_2:
	.(
		; Ping value from which we refuse to connect to the server (in milliseconds)
		OUTRAGEOUS_PING = 200

		; Do nothing until ping responses are received
		bit RAINBOW_FLAGS
		bpl end

			; Store ping value
			lda RAINBOW_DATA ; garbage byte
			nop

			lda RAINBOW_DATA ; message size
			cmp #5
			bne error_no_contact

			lda RAINBOW_DATA ; message type
			nop
			lda RAINBOW_DATA ; min
			nop

			lda RAINBOW_DATA ; max
			sta netplay_launch_ping
			cmp #OUTRAGEOUS_PING/4
			bcs error_bad_ping

			lda RAINBOW_DATA ; avg
			nop

			lda RAINBOW_DATA ; lost
			bne error_bad_ping

			;TODO show ping
			;  find a good way for bin to dec conversion
			;  construct buffer payload in memory
			;  call construct_nt_buffer (with buffer header in ROM)

			; Next step
			inc netplay_launch_state
			jmp end

		error_no_contact:
			lda #ERROR_STATE_NO_CONTACT
			sta netplay_launch_state
			jmp end

		error_bad_ping:
			lda #ERROR_STATE_BAD_PING
			sta netplay_launch_state
			;jmp end

		end:
		rts
	.)

	connection_1:
	.(
		; Show progress to the user
		lda #<step_title
		ldy #>step_title
		jsr show_step_name

		; Send connection message
		lda #7                                ; ESP header
		sta RAINBOW_DATA
		lda #TOESP_MSG_SEND_MESSAGE_TO_SERVER
		sta RAINBOW_DATA

		lda #STNP_CLI_MSG_TYPE_CONNECTION ; message_type
		sta RAINBOW_DATA
		lda network_client_id_byte0 ; client_id
		sta RAINBOW_DATA
		lda network_client_id_byte1
		sta RAINBOW_DATA
		lda network_client_id_byte2
		sta RAINBOW_DATA
		lda network_client_id_byte3
		sta RAINBOW_DATA
		lda netplay_launch_ping ; ping
		sta RAINBOW_DATA

		; Next step - wait for a response
		inc netplay_launch_state

		rts

		step_title:
			.byt $e8, $f4, $f3, $f3, $ea, $e8, $f9, $ee, $f3, $ec, $02, $f9, $f4, $02, $f8, $ea, $f7, $fb, $ea, $f7
	.)

	connection_2:
	.(
		bit RAINBOW_FLAGS
		bpl end

			; Skip message
			;TODO check that it is effectively a Connected message from server
			lda RAINBOW_DATA ; garbage byte
			nop
			lda RAINBOW_DATA ; message length
			nop
			lda RAINBOW_DATA ; ESP message type
			nop

			lda RAINBOW_DATA ; STNP message type
			nop
			lda RAINBOW_DATA ; player_number
			sta network_local_player_number

			; Next step
			inc netplay_launch_state

		end:
		rts
	.)

	wait_game:
	.(
		; Show progress to the user
		lda #<step_title
		ldy #>step_title
		jsr show_step_name

		bit RAINBOW_FLAGS
		bpl end

			; Skip message
			;TODO check that it is effectively a GameStart message from server
			lda RAINBOW_DATA ; garbage byte
			nop
			ldx RAINBOW_DATA ; message length
			nop
			skip_one_byte:
				lda RAINBOW_DATA
				dex
				bne skip_one_byte

			; Configure game
			lda #0
			sta config_ai_level
			sta config_selected_stage
			sta config_player_a_character
			sta config_player_b_character
			sta config_player_a_character_palette
			sta config_player_a_weapon_palette
			lda #1
			sta config_player_b_character_palette
			sta config_player_b_weapon_palette
			lda #4
			sta config_initial_stocks

			; Start game
			lda #GAME_STATE_INGAME
			jsr change_global_game_state

		end:
		rts

		step_title:
			.byt $fc, $e6, $ee, $f9, $ee, $f3, $ec, $02, $eb, $f4, $f7, $02, $e6, $02, $f7, $ee, $fb, $e6, $f1, $02
	.)

	no_contact:
	.(
		; Show progress to the user
		lda #<step_title
		ldy #>step_title
		jsr show_step_name

		jmp error_common

		step_title:
			.byt $ea, $f7, $f7, $f4, $f7, $02, $f3, $f4, $02, $e8, $f4, $f3, $f9, $e6, $e8, $f9, $02, $02, $02, $02
	.)

	bad_ping:
	.(
		; Show progress to the user
		lda #<step_title
		ldy #>step_title
		jsr show_step_name

		jmp error_common

		step_title:
			.byt $ea, $f7, $f7, $f4, $f7, $02, $e7, $e6, $e9, $02, $f5, $ee, $f3, $ec, $02, $02, $02, $02, $02, $02
	.)

	error_common:
	.(
		lda controller_a_btns
		bne end
		lda controller_a_last_frame_btns
		beq end

			lda #GAME_STATE_TITLE
			jsr change_global_game_state

		end:
		rts
	.)

	; Show the step's title on screen
	;  A - title address LSB
	;  Y - title address MSB
	;
	;  Overwrites all registers, and tmpfield1
	show_step_name:
	.(
		sta tmpfield3
		sty tmpfield4
		lda #<buffer_header
		sta tmpfield1
		lda #>buffer_header
		sta tmpfield2
		jsr construct_nt_buffer

		rts

		buffer_header:
			.byt $21, $86, 20
	.)
.)

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
	NETPLAY_LAUNCH_REEMISSION_TIMER = 60 ; Time before reemiting a packet, in frames

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
	.byt <connection_title, <connection_send_msg, <connection_wait_msg
	.byt <wait_game
	error_state_routines_lsb:
	.byt <no_contact, <bad_ping, <crazy_msg

	state_routines_msb:
	.byt >the_purge
	.byt >client_id_request_rnd, >client_id_set_low, >client_id_request_rnd, >client_id_set_hi
	.byt >estimate_latency_1, >estimate_latency_2
	.byt >connection_title, >connection_send_msg, >connection_wait_msg
	.byt >wait_game
	error_state_routines_msb:
	.byt >no_contact, >bad_ping, >crazy_msg

	FIRST_ERROR_STATE = error_state_routines_lsb - state_routines_lsb
	ERROR_STATE_NO_CONTACT = FIRST_ERROR_STATE
	ERROR_STATE_BAD_PING = FIRST_ERROR_STATE + 1
	ERROR_STATE_CRAZY_MESSAGE = FIRST_ERROR_STATE + 2

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

	connection_title:
	.(
		; Show progress to the user
		lda #<step_title
		ldy #>step_title
		jsr show_step_name

		; Next step
		inc netplay_launch_state

		rts

		step_title:
			.byt $e8, $f4, $f3, $f3, $ea, $e8, $f9, $ee, $f3, $ec, $02, $f9, $f4, $02, $f8, $ea, $f7, $fb, $ea, $f7
	.)

	connection_send_msg:
	.(
		; Send connection message
		lda #8                                ; ESP header
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
		lda #0 ; protocol_version
		sta RAINBOW_DATA

		; Next step - wait for a response
		lda #NETPLAY_LAUNCH_REEMISSION_TIMER
		sta netplay_launch_counter
		inc netplay_launch_state

		rts
	.)

	connection_wait_msg:
	.(
		; Get ESP message
		lda #<netplay_launch_received_msg
		sta tmpfield1
		lda #>netplay_launch_received_msg
		sta tmpfield2
		jsr esp_get_msg

		; No message, wait a frame, or reemit connection message after some time
		cpy #0
		bne handle_message
			dec netplay_launch_counter
			bne end
				dec netplay_launch_state
				jmp end
		handle_message:

		; Not a message from server, go in error mode
		lda netplay_launch_received_msg+1
		cmp #FROMESP_MSG_MESSAGE_FROM_SERVER
		bne error_crazy_msg

		; Check STNP message type
		lda netplay_launch_received_msg+2
		cmp #STNP_SRV_MSG_TYPE_CONNECTED
		beq connected_msg
		cmp #STNP_SRV_MSG_TYPE_START_GAME
		bne error_crazy_msg

		start_game_msg:
			jmp got_start_game_msg
			; does not return (jmp to a routine)

		connected_msg:
			; Next step
			inc netplay_launch_state
			jmp end

		error_crazy_msg:
			lda #ERROR_STATE_CRAZY_MESSAGE
			sta netplay_launch_state
			;jmp end

		end:
		rts
	.)

	wait_game:
	.(
		; Show progress to the user
		lda #<step_title
		ldy #>step_title
		jsr show_step_name

		; Actually come back to connected_2 state which waits for
		;  - reemission time, we want it to keep the connection alive
		;  - connected message, we should not receive it (but nothing bad in handling it)
		;  - start game message, our job
		lda #NETPLAY_LAUNCH_REEMISSION_TIMER
		sta netplay_launch_counter
		dec netplay_launch_state

		rts

		step_title:
			.byt $fc, $e6, $ee, $f9, $ee, $f3, $ec, $02, $eb, $f4, $f7, $02, $e6, $02, $f7, $ee, $fb, $e6, $f1, $02
	.)

	got_start_game_msg:
	.(
		; Configure game
		lda #0
#ifndef NETWORK_AI
		sta config_ai_level
#endif
		sta config_player_a_character
		sta config_player_b_character
		sta config_player_a_character_palette
		sta config_player_a_weapon_palette
		lda #1
		sta config_player_b_character_palette
		sta config_player_b_weapon_palette

		lda netplay_launch_received_msg+2+STNP_START_GAME_FIELD_STAGE
		sta config_selected_stage

		lda netplay_launch_received_msg+2+STNP_START_GAME_FIELD_STOCK
		sta config_initial_stocks

		lda netplay_launch_received_msg+2+STNP_START_GAME_FIELD_PLAYER_NUMBER
		sta network_local_player_number

		; Start game
		lda #GAME_STATE_INGAME
		jsr change_global_game_state

		;rts ; change_global_game_state does not return
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

	crazy_msg:
	.(
		; Show progress to the user
		lda #<step_title
		ldy #>step_title
		jsr show_step_name

		jmp error_common

		step_title:
			.byt $ea, $f7, $f7, $f4, $f7, $02, $e8, $f7, $e6, $ff, $fe, $02, $f2, $ea, $f8, $f8, $e6, $ec, $ea, $f8
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

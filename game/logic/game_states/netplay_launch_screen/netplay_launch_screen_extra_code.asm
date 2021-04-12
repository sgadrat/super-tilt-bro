NETPLAY_LAUNCH_SCREEN_EXTRA_BANK_NUMBER = CURRENT_BANK_NUMBER

init_netplay_launch_screen_extra:
.(
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

	; Wait for ESP to be ready
	wait_esp:
	.(
		ESP_SEND_CMD(esp_status_cmd)
		lda #<netplay_launch_received_msg
		sta tmpfield1
		lda #>netplay_launch_received_msg
		sta tmpfield2
		jsr esp_get_msg

		cpy #0
		beq wait_esp
	.)

	; Initialize UDP socket
	ESP_SEND_CMD(set_udp_cmd)

	rts

	esp_status_cmd:
		.byt 1, TOESP_MSG_GET_ESP_STATUS

	set_udp_cmd:
		.byt 2, TOESP_MSG_SERVER_SET_PROTOCOL, ESP_PROTOCOL_UDP
.)

netplay_launch_screen_tick_extra:
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
	.byt <connecting_wifi_query, <connecting_wifi_wait
	.byt <select_server_query_settings, <select_server_draw, <select_server
	.byt <estimate_latency_1, <estimate_latency_2
	.byt <connection_title, <connection_send_msg, <connection_wait_msg
	.byt <wait_game
	error_state_routines_lsb:
	.byt <no_contact, <bad_ping, <crazy_msg, <disconnected

	state_routines_msb:
	.byt >the_purge
	.byt >connecting_wifi_query, >connecting_wifi_wait
	.byt >select_server_query_settings, >select_server_draw, >select_server
	.byt >estimate_latency_1, >estimate_latency_2
	.byt >connection_title, >connection_send_msg, >connection_wait_msg
	.byt >wait_game
	error_state_routines_msb:
	.byt >no_contact, >bad_ping, >crazy_msg, >disconnected

	FIRST_ERROR_STATE = error_state_routines_lsb - state_routines_lsb
	ERROR_STATE_NO_CONTACT = FIRST_ERROR_STATE
	ERROR_STATE_BAD_PING = FIRST_ERROR_STATE + 1
	ERROR_STATE_CRAZY_MESSAGE = FIRST_ERROR_STATE + 2
	ERROR_STATE_DISCONNECTED = FIRST_ERROR_STATE + 3

	connecting_wifi_query:
	.(
		; Show progress to the user
		lda #<step_title
		ldy #>step_title
		jsr show_step_name

		ESP_SEND_CMD(cmd_get_wifi_status)

		inc netplay_launch_state
		jmp back_on_b

		step_title:
			.byt $02, $02, $e8, $f4, $f3, $f3, $ea, $e8, $f9, $ee, $f3, $ec, $02, $fc, $ee, $eb, $ee, $02, $02, $02

		cmd_get_wifi_status:
			.byt 1, TOESP_MSG_GET_WIFI_STATUS
	.)

	connecting_wifi_wait:
	.(
		; Wait for wifi status info
		lda #<netplay_launch_received_msg
		sta tmpfield1
		lda #>netplay_launch_received_msg
		sta tmpfield2
		jsr esp_get_msg

		cpy #0
		beq end

			ldx netplay_launch_received_msg+2
			cpx #wifi_status_action_msb-wifi_status_action_lsb
			bcs crazy

			lda wifi_status_action_lsb, x
			sta tmpfield1
			lda wifi_status_action_msb, x
			sta tmpfield2
			jmp (tmpfield1)

			connected:
				inc netplay_launch_state
				jmp end

			failed:
				lda #ERROR_STATE_NO_CONTACT
				sta netplay_launch_state
				jmp end

			crazy:
				lda #ERROR_STATE_CRAZY_MESSAGE
				sta netplay_launch_state
				jmp end

			in_progress:
				dec netplay_launch_state
				; Fallthrough

		end:
		jmp back_on_b

		wifi_status_action_lsb:
			;    IDLE_STATUS   NO_SSID_AVAIL SCAN_COMPLETED CONNECTED   CONNECT_FAILED CONNECTION_LOST DISCONNECTED
			.byt <in_progress, <in_progress, <in_progress,  <connected, <failed,       <failed,        <failed
		wifi_status_action_msb:
			.byt >in_progress, >in_progress, >in_progress,  >connected, >failed,       >failed,        >failed
	.)

	select_server_query_settings:
	.(
		; Show progress to the user
		lda #<step_title
		ldy #>step_title
		jsr show_step_name

		; Send querry for server settings
		ESP_SEND_CMD(cmd_get_server_settings)

		; Next step
		inc netplay_launch_state

		jmp back_on_b

		step_title:
			.byt $e8, $ed, $ea, $e8, $f0, $02, $f3, $ea, $f9, $fc, $f4, $f7, $f0, $02, $e8, $f4, $f3, $eb, $ee, $ec
		cmd_get_server_settings:
			.byt 1, TOESP_MSG_SERVER_GET_CONFIG_SETTINGS
	.)

	NB_KNOWN_SERVERS = 2
	CUSTOM_SERVER_IDX = NB_KNOWN_SERVERS
	select_server_draw:
	.(
		esp_msg_length = netplay_launch_received_msg

		; Show progress to the user
		lda #<step_title
		ldy #>step_title
		jsr show_step_name

		; Display choices
		lda #<server1_buffer_header
		sta tmpfield1
		lda #>server1_buffer_header
		sta tmpfield2
		lda #<server1_name
		sta tmpfield3
		lda #>server1_name
		sta tmpfield4
		jsr construct_nt_buffer

		lda #<server2_buffer_header
		sta tmpfield1
		lda #>server2_buffer_header
		sta tmpfield2
		lda #<server2_name
		sta tmpfield3
		lda #>server2_name
		sta tmpfield4
		jsr construct_nt_buffer

		; Set info about servers list
		lda #0
		sta netplay_launch_server
		lda #NB_KNOWN_SERVERS
		sta netplay_launch_nb_servers

		; Prepare selection sprite
		lda #TILE_OUT_OF_SCREEN_BUBBLE
		sta oam_mirror+1
		lda #0
		sta oam_mirror+2
		lda #55
		sta oam_mirror+3

		; Wait for server settings
		lda #<netplay_launch_received_msg
		sta tmpfield1
		lda #>netplay_launch_received_msg
		sta tmpfield2
		jsr esp_get_msg

		cpy #0
		beq end

			; Display custom server if configured
			lda esp_msg_length
			cmp #1
			beq end_custom_server
				lda #<server3_buffer_header
				sta tmpfield1
				lda #>server3_buffer_header
				sta tmpfield2
				lda #<server3_name
				sta tmpfield3
				lda #>server3_name
				sta tmpfield4
				jsr construct_nt_buffer

				lda #CUSTOM_SERVER_IDX
				sta netplay_launch_server
				lda #CUSTOM_SERVER_IDX+1
				sta netplay_launch_nb_servers
			end_custom_server:

			; Next step
			inc netplay_launch_state

		end:
		jmp back_on_b

		step_title:
			.byt $f8, $ea, $f1, $ea, $e8, $f9, $02, $fe, $f4, $fa, $f7, $02, $f8, $ea, $f7, $fb, $ea, $f7, $02, $02

		server1_name:
			.byt $f3, $f4, $f7, $f9, $ed, $02, $e6, $f2, $ea, $f7, $ee, $e8, $e6
		server2_name:
			.byt $ea, $fa, $f7, $f4, $f5, $ea
		server3_name:
			.byt $e8, $fa, $f8, $f9, $f4, $f2
	.)
	server1_buffer_header:
		.byt $21, $c8, 13
	server2_buffer_header:
		.byt $21, $e8, 6
	server3_buffer_header:
		.byt $22, $08, 6

	select_server:
	.(
		; Handle input
		lda controller_a_btns
		bne end
		lda controller_a_last_frame_btns
		cmp #CONTROLLER_BTN_A
		beq next_state
		cmp #CONTROLLER_BTN_START
		beq next_state
		cmp #CONTROLLER_BTN_DOWN
		beq next_server
		cmp #CONTROLLER_BTN_SELECT
		beq next_server
		cmp #CONTROLLER_BTN_UP
		beq previous_server
		jmp end_inputs

			next_server:
				inc netplay_launch_server
				lda netplay_launch_server
				cmp netplay_launch_nb_servers
				bcc end_inputs
					lda #0
					sta netplay_launch_server
					jmp end_inputs

			previous_server:
				dec netplay_launch_server
				bpl end_inputs
					ldx netplay_launch_nb_servers
					dex
					stx netplay_launch_server
					;jmp end_inputs ; useless, fallthrough

		end_inputs:

		; Place selection sprite
		lda netplay_launch_server
		asl
		asl
		asl
		clc
		adc #111
		sta oam_mirror ; Y position of sprite 0

		end:
		jmp back_on_b
		;rts ; useless, jmp to a routine

		next_state:
		.(
			; Hide selection sprite
			lda #$fe
			sta oam_mirror ; Y position of sprite 0

			; Set server settings and connect
			ldx netplay_launch_server
			cpx #CUSTOM_SERVER_IDX
			beq custom_server

				standard_server:
					; Set server settings for the selected server
					lda server_cfg_lsb, x
					sta tmpfield1
					lda server_cfg_msb, x
					sta tmpfield2
					jsr esp_send_cmd
					jmp server_set

				custom_server:
					; Pre-configured server, restore server settings from configuration
					ESP_SEND_CMD(restore_server_config_cmd)

			server_set:
			ESP_SEND_CMD(connect_cmd)

			; Clear servers list
			lda #<server1_buffer_header
			sta tmpfield1
			lda #>server1_buffer_header
			sta tmpfield2
			lda #<server_name_hidden
			sta tmpfield3
			lda #>server_name_hidden
			sta tmpfield4
			jsr construct_nt_buffer

			lda #<server2_buffer_header
			sta tmpfield1
			lda #>server2_buffer_header
			sta tmpfield2
			jsr construct_nt_buffer

			lda #<server3_buffer_header
			sta tmpfield1
			lda #>server3_buffer_header
			sta tmpfield2
			jsr construct_nt_buffer

			; Hide selection sprite
			lda #$fe
			sta oam_mirror ; Y position of sprite 0

			; Next state
			inc netplay_launch_state
			jmp end
		.)

		restore_server_config_cmd:
			.byt 1, TOESP_MSG_SERVER_RESTORE_SETTINGS

		connect_cmd:
			.byt 1, TOESP_MSG_SERVER_CONNECT

		server_north_america_settings:
			.byt 21, TOESP_MSG_SERVER_SET_SETTINGS, >3000, <3000, "stb-nae.wontfix.it"
		server_europe_settings:
			.byt 21, TOESP_MSG_SERVER_SET_SETTINGS, >3000, <3000, "stb-euw.wontfix.it"
		server_cfg_msb:
			.byt >server_north_america_settings, >server_europe_settings
		server_cfg_lsb:
			.byt <server_north_america_settings, <server_europe_settings

		server_name_hidden:
			.byt $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	.)

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

		jmp back_on_b

		step_title:
			.byt $ee, $f3, $ee, $f9, $ee, $e6, $f1, $ee, $ff, $ea, $02, $f8, $f9, $fa, $eb, $eb, $02, $02, $02, $02
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

		jmp back_on_b

		estimate_latency_msg:
			.byt $ea, $f8, $f9, $ee, $f2, $e6, $f9, $ea, $02, $f1, $e6, $f9, $ea, $f3, $e8, $fe, $02, $02, $02, $02
		cmd_ping:
			.byt 2, TOESP_MSG_SERVER_PING, 3
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
			sta netplay_launch_ping_min

			lda RAINBOW_DATA ; max
			sta netplay_launch_ping_max
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
		jmp back_on_b
	.)

	connection_title:
	.(
		; Show progress to the user
		lda #<step_title
		ldy #>step_title
		jsr show_step_name

		; Next step
		inc netplay_launch_state

		jmp back_on_b

		step_title:
			.byt $e8, $f4, $f3, $f3, $ea, $e8, $f9, $ee, $f3, $ec, $02, $f9, $f4, $02, $f8, $ea, $f7, $fb, $ea, $f7
	.)

	connection_send_msg:
	.(
		flags_byte = tmpfield1

		; Send connection message
		lda #31                                ; ESP header
		sta RAINBOW_DATA
		lda #TOESP_MSG_SERVER_SEND_MESSAGE
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
		lda netplay_launch_ping_min ; min ping
		sta RAINBOW_DATA
		lda #5 ; protocol_version
		sta RAINBOW_DATA
		lda netplay_launch_ping_max ; max ping
		sta RAINBOW_DATA

		lda skip_frames_to_50hz
		clc
		ror
		ror
		sta flags_byte ; framerate

		lda RAINBOW_MAPPER_VERSION
		and #%01100000
		ora flags_byte ; support

		ora #>GAME_VERSION ; release_type + version_major
		sta RAINBOW_DATA

		lda #<GAME_VERSION ; version_minor
		sta RAINBOW_DATA

		lda config_player_a_character ; selected_character
		sta RAINBOW_DATA
		lda config_player_a_character_palette ; selected_palette
		sta RAINBOW_DATA
		lda config_selected_stage ; selected_stage
		sta RAINBOW_DATA

		lda network_ranked ; ranked_play
		sta RAINBOW_DATA

		.( ; password
			ldx #0
			copy_one_byte:
				lda network_game_password, x
				sta RAINBOW_DATA
				inx
				cpx #16
				bne copy_one_byte
		.)

		; Next step - wait for a response
		lda #NETPLAY_LAUNCH_REEMISSION_TIMER
		sta netplay_launch_counter
		inc netplay_launch_state

		jmp back_on_b
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
		beq start_game_msg
		cmp #STNP_SRV_MSG_TYPE_DISCONNECTED
		bne error_crazy_msg

		disconnected_msg:
			lda #ERROR_STATE_DISCONNECTED
			sta netplay_launch_state
			jmp end

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
		jmp back_on_b
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

		jmp back_on_b

		step_title:
			.byt $fc, $e6, $ee, $f9, $ee, $f3, $ec, $02, $eb, $f4, $f7, $02, $e6, $02, $f7, $ee, $fb, $e6, $f1, $02
	.)

	got_start_game_msg:
	.(
		; Configure game
#ifndef NETWORK_AI
		lda #0
		sta config_ai_level
#endif

		lda netplay_launch_received_msg+2+STNP_START_GAME_FIELD_STAGE
		sta config_selected_stage

		lda netplay_launch_received_msg+2+STNP_START_GAME_FIELD_STOCK
		sta config_initial_stocks

		lda netplay_launch_received_msg+2+STNP_START_GAME_FIELD_PLAYER_NUMBER
		sta network_local_player_number

		lda netplay_launch_received_msg+2+STNP_START_GAME_FIELD_PA_CHARACTER
		sta config_player_a_character

		lda netplay_launch_received_msg+2+STNP_START_GAME_FIELD_PB_CHARACTER
		sta config_player_b_character

		lda netplay_launch_received_msg+2+STNP_START_GAME_FIELD_PA_PALETTE
		sta config_player_a_character_palette
		sta config_player_a_weapon_palette

		lda netplay_launch_received_msg+2+STNP_START_GAME_FIELD_PB_PALETTE
		sta config_player_b_character_palette
		sta config_player_b_weapon_palette

		; Draw info on players connection
		ldx network_local_player_number
		lda buffers_you_are_addr_lsb, x
		ldy buffers_you_are_addr_msb, x
		jsr push_nt_buffer
		jsr bank_safe_sleep_frame

		lda #<buffer_player_a_ping
		ldy #>buffer_player_a_ping
		jsr push_nt_buffer
		lda #<buffer_player_b_ping
		ldy #>buffer_player_b_ping
		jsr push_nt_buffer
		jsr bank_safe_sleep_frame

		lda netplay_launch_received_msg+2+STNP_START_GAME_FIELD_PLAYER_CONNECTIONS
		lsr
		lsr
		lsr
		lsr
		tax
		lda indicator_lsb, x
		sta tmpfield3
		lda indicator_msb, x
		sta tmpfield4
		lda #<header_player_a_indicator
		sta tmpfield1
		lda #>header_player_a_indicator
		sta tmpfield2
		jsr construct_nt_buffer

		lda netplay_launch_received_msg+2+STNP_START_GAME_FIELD_PLAYER_CONNECTIONS
		and #%00000011
		tax
		lda indicator_lsb, x
		sta tmpfield3
		lda indicator_msb, x
		sta tmpfield4
		lda #<header_player_b_indicator
		sta tmpfield1
		lda #>header_player_b_indicator
		sta tmpfield2
		jsr construct_nt_buffer

		; Wait some frames
		lda #200
		wait_one_frame:
			pha
			jsr bank_safe_sleep_frame
			pla
			sec
			sbc #1
			bne wait_one_frame

		; Start game
		lda #GAME_STATE_INGAME
		jsr change_global_game_state

		;rts ; change_global_game_state does not return

		bank_safe_sleep_frame:
		.(
			lda #<sleep_frame
			sta extra_tmpfield1
			lda #>sleep_frame
			sta extra_tmpfield2
			lda #CURRENT_BANK_NUMBER
			sta extra_tmpfield3
			sta extra_tmpfield4
			jmp trampoline
			;rts ; useless, jump to subroutine
		.)

		buffer_you_are_player_a:
			.byt $21, $c6, 16, $fe, $f4, $fa, $02, $e6, $f7, $ea, $02, $f5, $f1, $e6, $fe, $ea, $f7, $02, $e6
		buffer_you_are_player_b:
			.byt $21, $c6, 16, $fe, $f4, $fa, $02, $e6, $f7, $ea, $02, $f5, $f1, $e6, $fe, $ea, $f7, $02, $e7
		buffers_you_are_addr_lsb:
			.byt <buffer_you_are_player_a, <buffer_you_are_player_b
		buffers_you_are_addr_msb:
			.byt >buffer_you_are_player_a, >buffer_you_are_player_b

		buffer_player_a_ping:
			.byt $21, $e6, 15, $f5, $f1, $e6, $fe, $ea, $f7, $02, $e6, $02, $f5, $ee, $f3, $ec, $02, $02
		buffer_player_b_ping:
			.byt $22, $06, 15, $f5, $f1, $e6, $fe, $ea, $f7, $02, $e7, $02, $f5, $ee, $f3, $ec, $02, $02

		header_player_a_indicator:
			.byt $21, $f5, 9
		header_player_b_indicator:
			.byt $22, $15, 9
		indicator_excellent:
			.byt $ea, $fd, $e8, $ea, $f1, $f1, $ea, $f3, $f9
		indicator_good:
			.byt $ec, $f4, $f4, $e9, $02, $02, $02, $02, $02
		indicator_poor:
			.byt $f5, $f4, $f4, $f7, $02, $02, $02, $02, $02
		indicator_lsb:
			.byt <indicator_excellent, <indicator_good, <indicator_poor
		indicator_msb:
			.byt >indicator_excellent, >indicator_good, >indicator_poor
	.)

	no_contact:
	.(
		; Show progress to the user
		lda #<step_title
		ldy #>step_title
		jsr show_step_name

		jmp back_on_b

		step_title:
			.byt $ea, $f7, $f7, $f4, $f7, $02, $f3, $f4, $02, $e8, $f4, $f3, $f9, $e6, $e8, $f9, $02, $02, $02, $02
	.)

	bad_ping:
	.(
		; Show progress to the user
		lda #<step_title
		ldy #>step_title
		jsr show_step_name

		jmp back_on_b

		step_title:
			.byt $ea, $f7, $f7, $f4, $f7, $02, $e7, $e6, $e9, $02, $f5, $ee, $f3, $ec, $02, $02, $02, $02, $02, $02
	.)

	crazy_msg:
	.(
		; Show progress to the user
		lda #<step_title
		ldy #>step_title
		jsr show_step_name

		jmp back_on_b

		step_title:
			.byt $ea, $f7, $f7, $f4, $f7, $02, $e8, $f7, $e6, $ff, $fe, $02, $f2, $ea, $f8, $f8, $e6, $ec, $ea, $f8
	.)

	disconnected:
	.(
		; Write text from server (one line per frame)
		lda #1 ; continuation byte
		sta nametable_buffers

		inc netplay_launch_counter ; netplay_launch_counter = current line number
		lda netplay_launch_counter
		and #%00000111
		sta netplay_launch_counter

		asl
		asl
		asl
		asl
		asl
		clc
		adc #$85
		sta nametable_buffers+2 ; address lsb
		lda #0
		adc #$21
		sta nametable_buffers+1 ; address msb
		lda #24
		sta nametable_buffers+3 ; tiles count

		lda netplay_launch_counter ; Y = current line * 24
		asl
		asl
		asl
		sta tmpfield1
		asl
		clc
		adc tmpfield1
		tay

		ldx #4
		lda #24
		sta tmpfield1
		copy_one_byte:
			lda netplay_launch_received_msg+2+STNP_DISCONNECTED_FIELD_REASON, y
			cmp #32 ; ascii space
			beq space
				clc
				adc #133
				jmp char_ok
			space:
				lda #$02
			char_ok:
			sta nametable_buffers, x

			inx
			iny
			dec tmpfield1
			bne copy_one_byte

		lda #0
		sta nametable_buffers, x ; stop byte

		; Common error code
		jmp back_on_b
	.)

	back_on_b:
	.(
		lda controller_a_btns
		bne end
		lda controller_a_last_frame_btns
		cmp #CONTROLLER_BTN_B
		bne end

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

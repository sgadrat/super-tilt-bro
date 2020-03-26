; STNP lib

MESSAGE_TYPE_NEWSTATE = 2

;TODO this is a copy of the first network experiment, adapted to rainbow mapper
;     - adapt update_state routine to the new game engine
;     - bring back prediction-rollback
network_init_stage:
.(
	; Enable ESP
	lda #1
	sta RAINBOW_FLAGS

	; Reinit frame counter
	lda #$00
	sta network_current_frame_byte0
	sta network_current_frame_byte1
	sta network_current_frame_byte2
	sta network_current_frame_byte3

	; Set client id
	sta network_client_id_byte0
	sta network_client_id_byte1
	sta network_client_id_byte2
	ldx audio_music_enabled ; Hack to easilly configure the player number - activate music on player A's system
	jsr switch_selected_player
	stx network_client_id_byte3

	; Initialize controllers state
	sta network_last_sent_btns
	sta network_last_received_btns

	; Initialize UDP socket
	ESP_SEND_CMD(set_udp_cmd)
	ESP_SEND_CMD(connect_cmd)

	rts

	set_udp_cmd:
		.byt 2, TOESP_MSG_SET_SERVER_PROTOCOL, ESP_PROTOCOL_UDP
	connect_cmd:
		.byt 1, TOESP_MSG_CONNECT_TO_SERVER
.)

network_tick_ingame:
.(
	network_opponent_number = audio_music_enabled ; Hack to easilly configure the player number - activate music on player A's system

	.(
		; Force opponent's buttons to not change
		ldx network_opponent_number
		lda network_last_received_btns
		sta controller_a_btns, x

		; Send controller's state
		jsr switch_selected_player
		lda network_last_sent_btns
		cmp controller_a_btns, x
		beq controller_sent

#ifdef ESP_DBG
			; Log that we are about to send controller data
			ESP_DEBUG_LOG(23):.asc "sending controller data"
#endif

			; ESP header
			lda #11          ; Message length (10 bytes of payload + 1 byte for ESP message type)
			sta RAINBOW_DATA

			lda #TOESP_MSG_SEND_MESSAGE_TO_SERVER ; ESP message type
			sta RAINBOW_DATA

			; Payload
			lda #$1          ; message_type
			sta RAINBOW_DATA

			lda network_client_id_byte0 ; client_id
			sta RAINBOW_DATA
			lda network_client_id_byte1
			sta RAINBOW_DATA
			lda network_client_id_byte2
			sta RAINBOW_DATA
			lda network_client_id_byte3
			sta RAINBOW_DATA

			lda network_current_frame_byte0 ; timestamp
			sta RAINBOW_DATA
			lda network_current_frame_byte1
			sta RAINBOW_DATA
			lda network_current_frame_byte2
			sta RAINBOW_DATA
			lda network_current_frame_byte3
			sta RAINBOW_DATA

			lda controller_a_btns, x ; controller state
			sta RAINBOW_DATA
			sta network_last_sent_btns

		controller_sent:

		; Receive new state
		bit RAINBOW_FLAGS
#ifdef ESP_DBG
		; Avoid out of reach branching
		; only when ESP debug is activated as it is not necessary without these debug message in the midle of the code
		; and we love to spare some cycle in the nominal case
		bmi handle_msg
			jmp state_updated
		handle_msg:
#else
		bpl state_updated
#endif

#ifdef ESP_DBG
			ESP_DEBUG_LOG(21):.asc "received msg from esp"
#endif

			; Burn garbage byte
			lda RAINBOW_DATA
			nop

			; Check length
			lda RAINBOW_DATA
			cmp #133 ; 132 bytes for payload length + 1 for ESP type
#ifdef ESP_DBG
			; Avoid out of reach branching
			beq no_skip
				jmp skip_message
			no_skip:
#else
			bne skip_message
#endif

#ifdef ESP_DBG
				ESP_DEBUG_LOG(21):.asc "msg is 133 bytes long"
#endif

				lda RAINBOW_DATA ; Burn ESP message type, length match and there is no reason it is not MESSAGE_FROM_SERVER
				nop

				lda RAINBOW_DATA ; Message type from payload
				cmp #MESSAGE_TYPE_NEWSTATE
				bne skip_message

#ifdef ESP_DBG
					ESP_DEBUG_LOG(15):.asc "msg is newstate"
#endif

					; Burn prediction ID
					; TODO use it to avoid useless state reset
					lda RAINBOW_DATA

					; Override gamestate with the one in message's payload
					jsr update_state

					jmp state_updated

			skip_message:
				; Clear buffered message
				lda #1
				sta RAINBOW_DATA
				lda #TOESP_MSG_CLEAR_BUFFERS
				sta RAINBOW_DATA

		state_updated:

		; Increment frame counter
		inc network_current_frame_byte0
		bne inc_ok
		inc network_current_frame_byte1
		bne inc_ok
		inc network_current_frame_byte2
		bne inc_ok
		inc network_current_frame_byte3
		inc_ok:

		rts
	.)

	update_state:
	.(
#ifdef ESP_DBG
					ESP_DEBUG_LOG(37):.asc "received message (minus burnt bytes):"
					ESP_DEBUG_LOG_HEADER(127)
#define LOAD_RAINBOW_BYTE lda RAINBOW_DATA:sta RAINBOW_DATA
#else
#define LOAD_RAINBOW_BYTE lda RAINBOW_DATA
#endif

		; Reset frame counter
		;  TODO if in the past, reroll game updates
		LOAD_RAINBOW_BYTE
		sta network_current_frame_byte0
		LOAD_RAINBOW_BYTE
		sta network_current_frame_byte1
		LOAD_RAINBOW_BYTE
		sta network_current_frame_byte2
		LOAD_RAINBOW_BYTE
		sta network_current_frame_byte3

		; Copy gamestate
		.(
			ldx #0
			copy_one_byte:

				LOAD_RAINBOW_BYTE ; 4 cycles
				sta $00, x        ; 4 cycles

			inx ; 2 cycles
			cpx #$4f ; 3 cycles
			bne copy_one_byte ; 3 cycles
		.)

		; Note
		;  Total - (4+4+2+3+3) * 79 = 16 * 79 = 1264
		;  Unroll - (4+3) * 79 = 7 * 79 = 553

		; Copy hitboxes MSB
		.(
			ldx #0
			copy_one_byte:

				LOAD_RAINBOW_BYTE                ; 4 cycles
				sta player_a_hurtbox_left_msb, x ; 4 cycles

			inx ; 2 cycles
			cpx #$10 ; 3 cycles
			bne copy_one_byte ; 3 cycles
		.)

		; Note
		;  Total - (4+4+2+3+3) * 16 = 16 * 16 = 256
		;  Unroll - (4+3) * 16 = 7 * 16 = 112

		; Copy special state
		LOAD_RAINBOW_BYTE
		sta screen_shake_counter

		; Copy controllers state
		LOAD_RAINBOW_BYTE
		sta controller_a_btns
		LOAD_RAINBOW_BYTE
		sta controller_b_btns
		LOAD_RAINBOW_BYTE
		sta controller_a_last_frame_btns
		LOAD_RAINBOW_BYTE
		sta controller_b_last_frame_btns

		; Copy actually pressed opponent btns (keep_input_dirty may mess with normal values, but not this one)
		.(
			lda network_opponent_number
			beq player_a

				player_b:
					; Opponent is player B, burn player A's buttons
					LOAD_RAINBOW_BYTE
					nop
					LOAD_RAINBOW_BYTE
					sta network_last_received_btns
					jmp ok

				player_a:
					; Opponent is player A, burn player B's buttons
					LOAD_RAINBOW_BYTE
					sta network_last_received_btns
					LOAD_RAINBOW_BYTE
			ok:
		.)
		; Note - we are zero cycles after a load of rainbow byte, next instruction cannot be another load (add a nop if necessary)

		; Copy animation states
		.(
			ldx #0
			copy_one_byte:

				LOAD_RAINBOW_BYTE ; 4 cycles
				sta player_a_animation, x ; 5 cycles

			inx ; 2 cycles
			cpx #12*2 ; 3 cycles
			bne copy_one_byte ; 3 cycles
		.)

		rts
	.)

.)

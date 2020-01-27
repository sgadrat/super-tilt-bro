; Rainbow lib
; TODO (investigate) may be better in its own file - would complexify moving all network related code in its own bank

TOESP_MSG_GET_ESP_STATUS = 0          ; Get ESP status
TOESP_MSG_DEBUG_LOG = 1               ; Debug / Log data
TOESP_MSG_CLEAR_BUFFERS = 2           ; Clear RX/TX buffers
TOESP_MSG_GET_WIFI_STATUS = 3         ; Get WiFi connection status
TOESP_MSG_GET_RND_BYTE = 4            ; Get random byte
TOESP_MSG_GET_RND_BYTE_RANGE = 5      ; Get random byte between custom min/max
TOESP_MSG_GET_RND_WORD = 6            ; Get random word
TOESP_MSG_GET_RND_WORD_RANGE = 7      ; Get random word between custom min/max
TOESP_MSG_GET_SERVER_STATUS = 8       ; Get server connection status
TOESP_MSG_CONNECT_TO_SERVER = 9       ; Connect to server
TOESP_MSG_DISCONNECT_FROM_SERVER = 10 ; Disconnect from server
TOESP_MSG_SEND_MESSAGE_TO_SERVER = 11 ; Send message to rainbow server
TOESP_MSG_SEND_MESSAGE_TO_GAME = 12   ; Send message to game server
TOESP_MSG_SEND_UDP_TO_GAME = 13       ; Send an UDP datagram to game server
TOESP_MSG_FILE_OPEN = 14              ; Open working file
TOESP_MSG_FILE_CLOSE = 15             ; Close working file
TOESP_MSG_FILE_EXISTS = 16            ; Check if file exists
TOESP_MSG_FILE_DELETE = 17            ; Delete a file
TOESP_MSG_FILE_SET_CUR = 18           ; Set working file cursor position a file
TOESP_MSG_FILE_READ = 19              ; Read working file (at specific position)
TOESP_MSG_FILE_WRITE = 20             ; Write working file (at specific position)
TOESP_MSG_FILE_APPEND = 21            ; Append data to working file
TOESP_MSG_GET_FILE_LIST = 22          ; Get list of existing files in a path

FROMESP_MSG_READY = 0               ; ESP is ready
FROMESP_MSG_FILE_EXISTS = 1         ; Returns if file exists or not
FROMESP_MSG_FILE_LIST = 2           ; Returns path file list
FROMESP_MSG_FILE_DATA = 3           ; Returns file data (FILE_READ / FILE_READ_AUTO)
FROMESP_MSG_WIFI_STATUS = 4         ; Returns WiFi connection status
FROMESP_MSG_SERVER_STATUS = 5       ; Returns server connection status
FROMESP_MSG_RND_BYTE = 6            ; Returns random byte value
FROMESP_MSG_RND_WORD = 7            ; Returns random word value
FROMESP_MSG_MESSAGE_FROM_SERVER = 8 ; Message from server

ESP_FILE_PATH_SAVE = 0
ESP_FILE_PATH_ROMS = 1
ESP_FILE_PATH_USER = 2

RAINBOW_DATA = $5000
RAINBOW_FLAGS = $5001

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

	rts
.)

network_tick_ingame:
.(
	.(
		network_opponent_number = audio_music_enabled ; Hack to easilly configure the player number - activate music on player A's system

		; Force opponent's buttons to not change
		ldx network_opponent_number
		lda network_last_received_btns
		sta controller_a_btns, x

		; Send controller's state
		jsr switch_selected_player
		lda network_last_sent_btns
		cmp controller_a_btns, x
		beq controller_sent

			; ESP header
			lda #11          ; Message length (10 bytes of payload + 1 byte for ESP message type)
			sta RAINBOW_DATA

			lda #TOESP_MSG_SEND_UDP_TO_GAME ; ESP message type
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
		bpl state_updated

			; Burn garbage byte
			lda RAINBOW_DATA
			nop

			; Check length
			lda RAINBOW_DATA
			cmp #130 ; 129 bytes for payload length + 1 for ESP type
			bne skip_message

				lda RAINBOW_DATA ; Burn ESP message type, length match and there is no reason it is not MESSAGE_FROM_SERVER

				lda RAINBOW_DATA ; Message type from payload
				cmp #MESSAGE_TYPE_NEWSTATE
				bne skip_message

					; Burn prediction ID
					; TODO use it to avoid useless state reset
					lda RAINBOW_DATA

					; Override gamestate with the one in message's payload
					jsr update_state

					; Save received opponent's buttons
					ldx network_opponent_number
					lda controller_a_btns, x
					sta network_last_received_btns

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
		; Reset frame counter
		;  TODO if in the past, reroll game updates
		lda RAINBOW_DATA
		sta network_current_frame_byte0
		lda RAINBOW_DATA
		sta network_current_frame_byte1
		lda RAINBOW_DATA
		sta network_current_frame_byte2
		lda RAINBOW_DATA
		sta network_current_frame_byte3

		; Copy gamestate
		.(
			ldx #0
			copy_one_byte:

				lda RAINBOW_DATA ; 4 cycles
				sta $00, x       ; 4 cycles

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

				lda RAINBOW_DATA                 ; 4 cycles
				sta player_a_hurtbox_left_msb, x ; 4 cycles

			inx ; 2 cycles
			cpx #$10 ; 3 cycles
			bne copy_one_byte ; 3 cycles
		.)

		; Note
		;  Total - (4+4+2+3+3) * 16 = 16 * 16 = 256
		;  Unroll - (4+3) * 16 = 7 * 16 = 112

		; Copy controllers state, the game state shall have run one frame, last_frame_btns and btns became equal
		lda RAINBOW_DATA
		sta controller_a_btns
		lda RAINBOW_DATA
		sta controller_b_btns
		lda RAINBOW_DATA
		sta controller_a_last_frame_btns
		lda RAINBOW_DATA
		sta controller_b_last_frame_btns

		; Copy animation states
		.(
			ldx #0
			copy_one_byte:

				lda RAINBOW_DATA ; 4 cycles
				sta player_a_animation, x ; 5 cycles

			inx ; 2 cycles
			cpx #12*2 ; 3 cycles
			bne copy_one_byte ; 3 cycles
		.)

		rts
	.)

.)

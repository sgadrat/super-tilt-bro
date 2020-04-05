; STNP lib

MESSAGE_TYPE_NEWSTATE = 2

network_init_stage:
.(
	; Enable ESP
	lda #1
	sta RAINBOW_FLAGS

	; Clear rolling mode
	lda #0
	sta network_rollback_mode

	; Clear input history
	; lda #0 ; ensured by above code
	ldx #0
	clear_one_input:
		sta network_btns_history

		inx
		cpx #32
		bne clear_one_input

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
		; Do nothing in rollback mode, it would be recursive
		lda network_rollback_mode
		beq do_tick
		jmp end
		do_tick:

		; Force opponent's buttons to not change
		ldx network_opponent_number
		lda network_last_received_btns
		sta controller_a_btns, x

		; Update local controller's history
		jsr switch_selected_player
		lda network_current_frame_byte0
		and #%00011111
		tay
		lda controller_a_btns, x
		sta network_btns_history, y

		; Send controller's state
		lda network_last_sent_btns
		cmp controller_a_btns, x
		beq controller_sent

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
		bpl state_updated

			; Burn garbage byte
			lda RAINBOW_DATA
			nop

			; Check length
			lda RAINBOW_DATA
			cmp #133 ; 132 bytes for payload length + 1 for ESP type
			bne skip_message

				lda RAINBOW_DATA ; Burn ESP message type, length match and there is no reason it is not MESSAGE_FROM_SERVER
				nop

				lda RAINBOW_DATA ; Message type from payload
				cmp #MESSAGE_TYPE_NEWSTATE
				bne skip_message

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

		end:
		rts
	.)

	update_state:
	.(
		; Extract frame counter
		lda RAINBOW_DATA
		sta server_current_frame_byte0
		lda RAINBOW_DATA
		sta server_current_frame_byte1
		lda RAINBOW_DATA
		sta server_current_frame_byte2
		lda RAINBOW_DATA
		sta server_current_frame_byte3

		; Copy gamestate
		.(
			ldx #0
			copy_one_byte:

				lda RAINBOW_DATA  ; 4 cycles
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

				lda RAINBOW_DATA                 ; 4 cycles
				sta player_a_hurtbox_left_msb, x ; 4 cycles

			inx ; 2 cycles
			cpx #$10 ; 3 cycles
			bne copy_one_byte ; 3 cycles
		.)

		; Note
		;  Total - (4+4+2+3+3) * 16 = 16 * 16 = 256
		;  Unroll - (4+3) * 16 = 7 * 16 = 112

		; Copy special state
		lda RAINBOW_DATA
		sta screen_shake_counter
		bne screen_shake_updated
			; Received a "no screen shake", ensure that scrolling is reset
			;lda #$00 ; useless - ensured by bne
			sta scroll_y
			sta scroll_x
			lda #%10010000
			sta ppuctrl_val
		screen_shake_updated:

		; Copy controllers state
		lda RAINBOW_DATA
		sta controller_a_btns
		lda RAINBOW_DATA
		sta controller_b_btns
		lda RAINBOW_DATA
		sta controller_a_last_frame_btns
		lda RAINBOW_DATA
		sta controller_b_last_frame_btns

		; Copy actually pressed opponent btns (keep_input_dirty may mess with normal values, but not this one)
		.(
			lda network_opponent_number
			beq player_a

				player_b:
					; Opponent is player B, burn player A's buttons
					lda RAINBOW_DATA
					nop
					lda RAINBOW_DATA
					sta network_last_received_btns
					jmp ok

				player_a:
					; Opponent is player A, burn player B's buttons
					lda RAINBOW_DATA
					sta network_last_received_btns
					lda RAINBOW_DATA
			ok:
		.)
		; Note - we are zero cycles after a load of rainbow byte, next instruction cannot be another load (add a nop if necessary)

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

		; Update game state until the current frame is at least equal to the one we where before reading the message
		lda #1
		sta network_rollback_mode
		roll_forward_one_step:
		.(
			; If sever's frame is inferior to local frame
			; TODO optimization - could be implemented like in signed_cmp
			;      one CMP, followed by SBCs, branching at the end on carry flag
			;      to be determined, but considering 255 out of 256 times only the LSB is changing, it should be speeder
			lda server_current_frame_byte3
			cmp network_current_frame_byte3
			bcc do_it
			bne dont_do_it
			lda server_current_frame_byte2
			cmp network_current_frame_byte2
			bcc do_it
			bne dont_do_it
			lda server_current_frame_byte1
			cmp network_current_frame_byte1
			bcc do_it
			bne dont_do_it
			lda server_current_frame_byte0
			cmp network_current_frame_byte0
			bcc do_it
			jmp dont_do_it

			do_it:

				; Set local player input according to history
				ldx network_opponent_number ; X = local player number
				jsr switch_selected_player

				lda server_current_frame_byte0 ; Y = input offset in history
				and #%00011111
				tay

				lda network_btns_history, y ; write current input
				sta controller_a_btns, x
				dey
				lda network_btns_history, y
				sta controller_a_last_frame_btns, x

				; Update game state
				jsr game_tick

				; Inc server_current_frame_byte
				inc server_current_frame_byte0
				bne end_inc
				inc server_current_frame_byte1
				bne end_inc
				inc server_current_frame_byte2
				bne end_inc
				inc server_current_frame_byte3
				end_inc:

				; Loop
				jmp roll_forward_one_step

			end_loop:
			dont_do_it:
		.)
		lda #0
		sta network_rollback_mode

		; Copy (updated) server frame number to the local one
		lda server_current_frame_byte0
		sta network_current_frame_byte0
		lda server_current_frame_byte1
		sta network_current_frame_byte1
		lda server_current_frame_byte2
		sta network_current_frame_byte2
		lda server_current_frame_byte3
		sta network_current_frame_byte3

		rts
	.)

.)

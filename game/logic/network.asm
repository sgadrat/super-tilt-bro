;
; STNP lib
;

STNP_CLI_MSG_TYPE_CONNECTION = 0
STNP_CLI_MSG_TYPE_CONTROLLER_STATE = 1

STNP_SRV_MSG_TYPE_CONNECTED = 0
STNP_SRV_MSG_TYPE_START_GAME = 1
STNP_SRV_MSG_TYPE_NEWSTATE = 2
STNP_SRV_MSG_TYPE_GAMEOVER = 3
STNP_SRV_MSG_TYPE_DISCONNECTED = 4

STNP_START_GAME_FIELD_STAGE = 1
STNP_START_GAME_FIELD_STOCK = 2
STNP_START_GAME_FIELD_PLAYER_NUMBER = 3
STNP_START_GAME_FIELD_PLAYER_A_CONNECTION = 4
STNP_START_GAME_FIELD_PLAYER_B_CONNECTION = 5
STNP_DISCONNECTED_FIELD_REASON = 1

;
; Netcode
;

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
		sta network_player_local_btns_history, x
		sta network_player_remote_btns_history, x

		inx
		cpx #32
		bne clear_one_input

	sta network_last_known_remote_input

	; Reinit frame counter
	lda #$00
	sta network_current_frame_byte0
	sta network_current_frame_byte1
	sta network_current_frame_byte2
	sta network_current_frame_byte3

	; Initialize controllers state
	sta network_last_sent_btns

	rts
.)

network_tick_ingame:
.(
	.(
		; Do nothing in rollback mode, it would be recursive
		lda network_rollback_mode
		beq do_tick
		jmp end
		do_tick:

		; Update local controller's history
		lda network_current_frame_byte0
		clc
		adc #NETWORK_INPUT_LAG
		and #%00011111
		tay
		lda controller_a_btns
		sta network_player_local_btns_history, y

		; Send controller's state
		lda network_last_sent_btns ; NOTE - optimizable as "controller_a_btns" is already in register A
		cmp controller_a_btns
		beq controller_sent

			; ESP header
			lda #11          ; Message length (10 bytes of payload + 1 byte for ESP message type)
			sta RAINBOW_DATA

			lda #TOESP_MSG_SEND_MESSAGE_TO_SERVER ; ESP message type
			sta RAINBOW_DATA

			; Payload
			lda #STNP_CLI_MSG_TYPE_CONTROLLER_STATE ; message_type
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

			lda controller_a_btns ; controller state
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
			cmp #133+NETWORK_INPUT_LAG ; 1 byte for ESP type + 132 for fixed payload length + delayed inputs
			bne skip_message

				lda RAINBOW_DATA ; Burn ESP message type, length match and there is no reason it is not MESSAGE_FROM_SERVER
				nop

				lda RAINBOW_DATA ; Message type from payload
				cmp #STNP_SRV_MSG_TYPE_NEWSTATE
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

		; Overwrite players input with delayed input
		ldx network_local_player_number ; X = local player number

		lda network_current_frame_byte0 ; Y = input offset in history ;FIXME if just got a message in the futur, it may be in garbage part of the input history (should rewrite next four inputs when receiving a message in the futur)
		and #%00011111
		tay

		lda network_player_local_btns_history, y ; write current input
		sta controller_a_btns, x

		jsr switch_selected_player
		jsr set_opponent_buttons_from_history

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

		;TODO select action from message type -  ancient, past or futur
		;NOTE in a first draft the current rollback implementation should handle all cases
		;     correctly, even if sub-optimal (notably doing unecessary rollbacks for "past"
		;     messages.
		;     one advantage of this solution is to resync with server on any occasion

		ancient:
			jsr rollback_state
			jmp end

		past:
			;TODO

		future:
			;TODO

		end:
		rts
	.)

	rollback_state:
	.(
		; Copy delayed inputs from message in opponent's input history
		.(
			; Get first delayed input index in history
			lda server_current_frame_byte0
			clc
			adc #1
			and #%00011111
			tay

			; Copy delayed inputs
			ldx #NETWORK_INPUT_LAG
			copy_one_byte:
				lda RAINBOW_DATA
				sta network_player_remote_btns_history, y
				sty network_last_known_remote_input

				iny
				tya
				and #%00011111
				tay

				dex
				bne copy_one_byte
		.)

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
			;TODO Investigate
			;     We may want to write received buttons in local player history instead of burning it
			;       That would avoid desynchronizing if a ControllerState packet is lost (= not seen by server)
			;     Beware of race conditions, if the server receives the ControllerState packet after sending the NewState
			;       That would cause desychronization (until next NewGameState received), because we updated history with predicted info from server
			lda network_local_player_number
			bne player_b

				player_a:
					; Local player is player A, burn its buttons (already in our history)
					lda RAINBOW_DATA
					nop
					lda RAINBOW_DATA
					pha
					jmp ok

				player_b:
					; Local player is player B, burn its buttons (already in our history)
					lda RAINBOW_DATA
					pha
					lda RAINBOW_DATA
			ok:

			; Register it in opponent's input history
			lda server_current_frame_byte0
			and #%00011111
			tay
			pla
			sta network_player_remote_btns_history, y
		.)

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

				; Update last_frame_btns
				;  it is not done by fetch_controller because we don't use the main loop
				lda controller_a_btns
				sta controller_a_last_frame_btns
				lda controller_b_btns
				sta controller_b_last_frame_btns

				; Set local player input according to history
				ldx network_local_player_number ; X = local player number

				lda server_current_frame_byte0 ; Y = input offset in history
				and #%00011111
				tay

				lda network_player_local_btns_history, y ; write current input
				sta controller_a_btns, x

				; Set remote player input according to history
				jsr switch_selected_player
				jsr set_opponent_buttons_from_history

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

	; Get opponent'input if known, else predict it
	set_opponent_buttons_from_history:
	.(
		; Determine if we know the next input or have to predict it
		cpy network_last_known_remote_input
		beq mark_nexts_unknown
		lda network_last_known_remote_input
		cmp #$80
		bcc known

		unknown:
			and #%00011111
			tay
			jmp known ; not known per see, but we predict it being the same as last known
		mark_nexts_unknown:
			lda #$80
			ora network_last_known_remote_input
			sta network_last_known_remote_input
		known:
			lda network_player_remote_btns_history, y
			sta controller_a_btns, x

		rts
	.)

.)

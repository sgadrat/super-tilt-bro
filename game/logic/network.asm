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
STNP_START_GAME_FIELD_PLAYER_CONNECTIONS = 4
STNP_START_GAME_FIELD_PA_CHARACTER = 5
STNP_START_GAME_FIELD_PB_CHARACTER = 6
STNP_START_GAME_FIELD_PA_PALETTE = 7
STNP_START_GAME_FIELD_PB_PALETTE = 8

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

	sta network_last_known_remote_input ;TODO could be init at $80 to be marked as "unknown, predict it", it would change nothing though predicting expects at least one known input

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
		;lda controller_a_btns ; useless  - "controller_a_btns" is already in register A
		cmp network_last_sent_btns
		beq controller_sent

			; ESP header
			lda #11          ; Message length (10 bytes of payload + 1 byte for ESP message type)
			sta RAINBOW_DATA

			lda #TOESP_MSG_SERVER_SEND_MESSAGE ; ESP message type
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

			; Trash length byte (consistency check is not trivial as message has variable length)
			lda RAINBOW_DATA
			nop

			; Check message type
			lda RAINBOW_DATA
			cmp #FROMESP_MSG_MESSAGE_FROM_SERVER
			bne skip_message

			lda RAINBOW_DATA ; Message type from payload
			cmp #STNP_SRV_MSG_TYPE_NEWSTATE
			bne skip_message

				; Burn prediction ID
				; TODO use it to avoid useless state reset
				lda RAINBOW_DATA

				; Override gamestate with the one in message's payload
				jsr update_state

				; Update last_frame_btns
				;  "update_state" leaves buttons as after the "game_tick", before "fetch_controllers"
				;  So, it needs a full refresh, update only "last_frame_btns" here since "controller_*_btns" will be ubdated below
				lda controller_a_btns
				sta controller_a_last_frame_btns
				lda controller_b_btns
				sta controller_b_last_frame_btns

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

		lda network_current_frame_byte0 ; Y = input offset in history
		and #%00011111
		tay

		lda network_player_local_btns_history, y ; write current input
		sta controller_a_btns, x

		SWITCH_SELECTED_PLAYER
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
		packet_time_flag = tmpfield1
		PACKET_TIME_PAST = 0
		PACKET_TIME_FUTURE = 1

		.(
			; Extract frame counter, and compare it to local timestamp
			lda RAINBOW_DATA
			sta server_current_frame_byte0
			cmp network_current_frame_byte0
			lda RAINBOW_DATA
			sta server_current_frame_byte1
			sbc network_current_frame_byte1
			lda RAINBOW_DATA
			sta server_current_frame_byte2
			sbc network_current_frame_byte2
			lda RAINBOW_DATA
			sta server_current_frame_byte3
			sbc network_current_frame_byte3

			; Select action from message type -  ancient, past or futur
			;NOTE in a first draft the current rollback implementation should handle all cases
			;     correctly, even if sub-optimal (notably doing unecessary rollbacks for "past")
			;     messages.
			;     one advantage of this solution is to resync with server on any occasion
			bcc past
			lda server_current_frame_byte0
			cmp network_current_frame_byte0 ; one-byte equality, we'll have other troubles if difference is more than 255 frames anyway
			beq present

			future:
				lda #PACKET_TIME_FUTURE
				jmp end

			present:
			past:
				lda #PACKET_TIME_PAST

			end:
			sta packet_time_flag
			;rts ; Fallthrough to rollback_state
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
				;  Keep local inputs from message only if packet is in the future, we know our past inputs (and the server may not yet have the last one)
				ldx #NETWORK_INPUT_LAG
				lda packet_time_flag
				cmp #PACKET_TIME_FUTURE
				beq local_keep
					local_trash:
					.(
						copy_one_byte:
							; Local input buffer
							lda RAINBOW_DATA
							nop

							; Remote input buffer
							lda RAINBOW_DATA
							sta network_player_remote_btns_history, y

							; Loop
							dex
							beq end_delayed_inputs
								; Increment circular buffer index
								iny
								tya
								and #%00011111
								tay

								; Loop
								jmp copy_one_byte
					.)
					local_keep:
					.(
						copy_one_byte:
							; Local input buffer
							lda RAINBOW_DATA
							sta network_player_local_btns_history, y

							; Remote input buffer
							lda RAINBOW_DATA
							sta network_player_remote_btns_history, y

							; Loop
							dex
							beq end_delayed_inputs
								; Increment circular buffer index
								iny
								tya
								and #%00011111
								tay

								; Loop
								jmp copy_one_byte
					.)
				end_delayed_inputs:
				sty network_last_known_remote_input
			.)

			; Copy gamestate
			.(
				ldx #0
				copy_one_byte:

					lda RAINBOW_DATA  ; 4 cycles
					sta $00, x        ; 4 cycles
					inx ; 2 cycles

					lda RAINBOW_DATA  ; 4 cycles
					sta $00, x        ; 4 cycles
					inx ; 2 cycles

					lda RAINBOW_DATA  ; 4 cycles
					sta $00, x        ; 4 cycles
					inx ; 2 cycles

					lda RAINBOW_DATA  ; 4 cycles
					sta $00, x        ; 4 cycles
					inx ; 2 cycles

				cpx #$68 ; 3 cycles
				bne copy_one_byte ; 3 cycles
			.)

			; Note
			;  Rolled - (4+4+2+3+3) * 104 = 16 * 104 = 1664
			;  Unroll - (4+3) * 104 = 7 * 104 = 728
			;  4x rolled - ((4+4+2)*4 + 3 + 3) * (104/4) = 46 * 26 = 1196

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

			; Copy actually pressed opponent btns (keep_input_dirty may mess with normal values, but not this one)
			.(
				;TODO Investigate
				;     We may want to write received buttons in local player history instead of burning it
				;       That would avoid desynchronizing if a ControllerState packet is lost (= not seen by server)
				;     Beware of race conditions, if the server receives the ControllerState packet after sending the NewState
				;       That would cause desychronization (until next NewGameState received), because we updated history with predicted info from server
#if 1
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
#else
				lda server_current_frame_byte0
				and #%00011111
				tay

				lda network_local_player_number
				bne player_b

					player_a:
						; Local player is player A
						lda RAINBOW_DATA
						sta network_player_local_btns_history, y
						lda RAINBOW_DATA
						sta network_player_remote_btns_history, y
						jmp ok

					player_b:
						; Local player is player B
						lda RAINBOW_DATA
						sta network_player_remote_btns_history, y
						lda RAINBOW_DATA
						sta network_player_local_btns_history, y
				ok:
#endif
			.)

			; Copy animation states
			.(
				lda RAINBOW_DATA
				sta player_a_animation+ANIMATION_STATE_OFFSET_DATA_VECTOR_LSB
				lda RAINBOW_DATA
				sta player_a_animation+ANIMATION_STATE_OFFSET_DATA_VECTOR_MSB
				lda RAINBOW_DATA
				sta player_a_animation+ANIMATION_STATE_OFFSET_DIRECTION
				lda RAINBOW_DATA
				sta player_a_animation+ANIMATION_STATE_OFFSET_CLOCK
				lda RAINBOW_DATA
				sta player_a_animation+ANIMATION_STATE_OFFSET_FRAME_VECTOR_LSB
				lda RAINBOW_DATA
				sta player_a_animation+ANIMATION_STATE_OFFSET_FRAME_VECTOR_MSB
				lda RAINBOW_DATA
				sta player_a_animation+ANIMATION_STATE_OFFSET_NTSC_CNT

				lda RAINBOW_DATA
				sta player_b_animation+ANIMATION_STATE_OFFSET_DATA_VECTOR_LSB
				lda RAINBOW_DATA
				sta player_b_animation+ANIMATION_STATE_OFFSET_DATA_VECTOR_MSB
				lda RAINBOW_DATA
				sta player_b_animation+ANIMATION_STATE_OFFSET_DIRECTION
				lda RAINBOW_DATA
				sta player_b_animation+ANIMATION_STATE_OFFSET_CLOCK
				lda RAINBOW_DATA
				sta player_b_animation+ANIMATION_STATE_OFFSET_FRAME_VECTOR_LSB
				lda RAINBOW_DATA
				sta player_b_animation+ANIMATION_STATE_OFFSET_FRAME_VECTOR_MSB
				lda RAINBOW_DATA
				sta player_b_animation+ANIMATION_STATE_OFFSET_NTSC_CNT
			.)

			; Copy character specific data
			.(
				ldx #0
				copy_one_char:
					ldy config_player_a_character, x

					lda characters_netload_routine_lsb, y
					sta tmpfield1
					lda characters_netload_routine_msb, y
					sta tmpfield2

					SWITCH_BANK(characters_bank_number COMMA y)
					stx player_number
					jsr call_pointed_subroutine
					ldx player_number

					inx
					cpx #2
					bne copy_one_char
			.)

			; Copy stage specific data
			.(
				ldy config_selected_stage

				lda stages_netload_routine_lsb, y
				sta tmpfield1
				lda stages_netload_routine_msb, y
				sta tmpfield2

				SWITCH_BANK(stages_bank COMMA y)
				jsr call_pointed_subroutine
			.)

			; Compute difference between server and local frame counters
			; NOTE - expects less than 128 frames between both
			lda network_current_frame_byte0
			sec
			sbc server_current_frame_byte0

			; Do not rollback frames if server's frame is >= local frame
			bmi no_rollback
			beq no_rollback
			sta network_frame_diff

			; Update game state until the current frame is at least equal to the one we where before reading the message
			lda #1
			sta network_rollback_mode
			roll_forward_one_step:
			.(
				; If sever's frame is inferior to local frame
				lda network_frame_diff
				beq dont_do_it

				do_it:

					; Emulate controllers updates not done by "fetch_controllers" since we are mocking the main loop
					.(
						; Update last_frame_btns
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
						SWITCH_SELECTED_PLAYER
						jsr set_opponent_buttons_from_history
					.)

					; Update game state
					jsr game_tick

					; Loop
					dec network_frame_diff
					jmp roll_forward_one_step

				end_loop:
				dont_do_it:
			.)
			lda #0
			sta network_rollback_mode

			rts

			no_rollback:

			; Local frame number = server frame number
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

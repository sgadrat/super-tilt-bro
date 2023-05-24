network_init_stage:
.(
	; Change music
	TRAMPOLINE(audio_music_ingame, #GAMESTATE_GAME_EXTRA_BANK, #0)

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

	sta network_last_known_remote_input ;NOTE could be init at $80 to be marked as "unknown, predict it", it would change nothing though predicting expects at least one known input

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
			jmp end ; optimizable, could be inlined, would be even better to not call the routine in rollback mode
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

			; Wait mapper to be ready
			.(
				wait_mapper:
					bit RAINBOW_WIFI_TX
					bpl wait_mapper
			.)

			; ESP header
			lda #11          ; Message length (10 bytes of payload + 1 byte for ESP message type)
			sta esp_tx_buffer+ESP_MSG_SIZE

			lda #TOESP_MSG_SERVER_SEND_MESSAGE ; ESP message type
			sta esp_tx_buffer+ESP_MSG_TYPE

			; Payload
			lda #STNP_CLI_MSG_TYPE_CONTROLLER_STATE ; message_type
			sta esp_tx_buffer+ESP_MSG_PAYLOAD+0

			lda network_client_id_byte0 ; client_id
			sta esp_tx_buffer+ESP_MSG_PAYLOAD+1
			lda network_client_id_byte1
			sta esp_tx_buffer+ESP_MSG_PAYLOAD+2
			lda network_client_id_byte2
			sta esp_tx_buffer+ESP_MSG_PAYLOAD+3
			lda network_client_id_byte3
			sta esp_tx_buffer+ESP_MSG_PAYLOAD+4

			lda network_current_frame_byte0 ; timestamp
			sta esp_tx_buffer+ESP_MSG_PAYLOAD+5
			lda network_current_frame_byte1
			sta esp_tx_buffer+ESP_MSG_PAYLOAD+6
			lda network_current_frame_byte2
			sta esp_tx_buffer+ESP_MSG_PAYLOAD+7
			lda network_current_frame_byte3
			sta esp_tx_buffer+ESP_MSG_PAYLOAD+8

			lda controller_a_btns ; controller state
			sta esp_tx_buffer+ESP_MSG_PAYLOAD+9
			sta network_last_sent_btns

			; Send
			sta RAINBOW_WIFI_TX

		controller_sent:

		; Receive new state
		bit RAINBOW_WIFI_RX
		bpl state_updated

			; Ignore length byte (consistency check is not trivial as message has variable length)
			; lda esp_rx_buffer+ESP_MSG_SIZE

			; Check message type
			lda esp_rx_buffer+ESP_MSG_TYPE
			cmp #FROMESP_MSG_MESSAGE_FROM_SERVER
			bne skip_message

			lda esp_rx_buffer+ESP_MSG_PAYLOAD+0 ; Message type from payload
			cmp #STNP_SRV_MSG_TYPE_NEWSTATE
			beq handle_new_state
			cmp #STNP_SRV_MSG_TYPE_GAMEOVER
			bne skip_message

				handle_gameover:
					; Set winner according to the message
					lda esp_rx_buffer+ESP_MSG_PAYLOAD+STNP_GAMEOVER_FIELD_WINNER_PLAYER_NUMBER
					sta game_winner

					; Jump to gameover screen, skipping any further processing
					jmp game_mode_online_gameover

				handle_new_state:
					; Ignore prediction ID
					; TODO use it to avoid useless state reset
					;lda esp_rx_buffer+ESP_MSG_PAYLOAD+1

					; Override gamestate with the one in message's payload
					jsr update_state

					; Acknowledge message reception
					sta RAINBOW_WIFI_RX

					; Update last_frame_btns
					;  "update_state" leaves buttons as after the "game_tick", before "fetch_controllers"
					;  So, it needs a full refresh, update only "last_frame_btns" here since "controller_*_btns" will be ubdated below
					lda controller_a_btns
					sta controller_a_last_frame_btns
					lda controller_b_btns
					sta controller_b_last_frame_btns

					jmp state_updated

			skip_message:
				; Acknowledge message reception
				sta RAINBOW_WIFI_RX

				; Clear buffered messages (cleaning in case the corrupted message was a problem with the esp)
				lda #<esp_cmd_clear_buffers
				ldx #>esp_cmd_clear_buffers
				jsr esp_send_cmd_short

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

		; Return with carry unset to avoid skipping the frame (see pre-update game hooks documentation.)
		clc
		rts
	.)

	update_state:
	.(
		packet_time_flag = tmpfield1
		PACKET_TIME_PAST = 0
		PACKET_TIME_FUTURE = 1
		FRAME_COUNTER_OFFSET = ESP_MSG_PAYLOAD+2
		DELAYED_INPUTS_OFFSET = FRAME_COUNTER_OFFSET+4
		GAMESTATE_OFFSET = DELAYED_INPUTS_OFFSET+(NETWORK_INPUT_LAG*2)

		.(
			; Extract frame counter, and compare it to local timestamp
			lda esp_rx_buffer+FRAME_COUNTER_OFFSET+0
			sta server_current_frame_byte0
			cmp network_current_frame_byte0
			lda esp_rx_buffer+FRAME_COUNTER_OFFSET+1
			sta server_current_frame_byte1
			sbc network_current_frame_byte1
			lda esp_rx_buffer+FRAME_COUNTER_OFFSET+2
			sta server_current_frame_byte2
			sbc network_current_frame_byte2
			lda esp_rx_buffer+FRAME_COUNTER_OFFSET+3
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
				ldx #0
				lda packet_time_flag
				cmp #PACKET_TIME_FUTURE
				beq local_keep
					local_trash:
					.(
						copy_one_byte:
							; Local input buffer
							;lda esp_rx_buffer+DELAYED_INPUTS_OFFSET+0, x

							; Remote input buffer
							lda esp_rx_buffer+DELAYED_INPUTS_OFFSET+1, x
							sta network_player_remote_btns_history, y

							; Loop
							inx
							inx
							cpx #NETWORK_INPUT_LAG*2
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
							lda esp_rx_buffer+DELAYED_INPUTS_OFFSET+0, x
							sta network_player_local_btns_history, y

							; Remote input buffer
							lda esp_rx_buffer+DELAYED_INPUTS_OFFSET+1, x
							sta network_player_remote_btns_history, y

							; Loop
							inx
							inx
							cpx #NETWORK_INPUT_LAG*2
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
			GAMESTATE_SIZE = $6a
			.(

				lda esp_rx_buffer+GAMESTATE_OFFSET  ; 4 cycles
				sta $00                             ; 3 cycles

				lda esp_rx_buffer+GAMESTATE_OFFSET+1  ; 4 cycles
				sta $00+1                             ; 3 cycles

				ldx #2

				copy_one_byte:

					lda esp_rx_buffer+GAMESTATE_OFFSET, x  ; 4 cycles
					sta $00, x                             ; 4 cycles
					inx ; 2 cycles

					lda esp_rx_buffer+GAMESTATE_OFFSET, x  ; 4 cycles
					sta $00, x                             ; 4 cycles
					inx ; 2 cycles

					lda esp_rx_buffer+GAMESTATE_OFFSET, x  ; 4 cycles
					sta $00, x                             ; 4 cycles
					inx ; 2 cycles

					lda esp_rx_buffer+GAMESTATE_OFFSET, x  ; 4 cycles
					sta $00, x                             ; 4 cycles
					inx ; 2 cycles

				cpx #GAMESTATE_SIZE ; 3 cycles
				bne copy_one_byte ; 3 cycles
			.)

			; Note
			;  Rolled - (4+4+2+3+3) * 106 = 16 * 106 = 1696
			;  Unroll - (4+3) * 106 = 7 * 106 = 742
			;  4x rolled - (4+3)*2 + ((4+4+2)*4 + 3 + 3) * (104/4) = 14 + 46 * 26 = 1210

			; Copy special state
			.(
				; Screen shaking
				lda esp_rx_buffer+GAMESTATE_OFFSET+GAMESTATE_SIZE
				sta screen_shake_counter
				bne screen_shake_updated
					; Received a "no screen shake", ensure that scrolling is reset
					;lda #$00 ; useless - ensured by bne
					sta scroll_y
					sta scroll_x
					lda #%10010000
					sta ppuctrl_val
				screen_shake_updated:
				lda esp_rx_buffer+GAMESTATE_OFFSET+GAMESTATE_SIZE+1
				sta screen_shake_current_x
				lda esp_rx_buffer+GAMESTATE_OFFSET+GAMESTATE_SIZE+2
				sta screen_shake_current_y
				lda esp_rx_buffer+GAMESTATE_OFFSET+GAMESTATE_SIZE+3
				sta screen_shake_noise_h
				lda esp_rx_buffer+GAMESTATE_OFFSET+GAMESTATE_SIZE+4
				sta screen_shake_noise_v

				; Deathplosion
				lda esp_rx_buffer+GAMESTATE_OFFSET+GAMESTATE_SIZE+5
				sta deathplosion_step
				lda esp_rx_buffer+GAMESTATE_OFFSET+GAMESTATE_SIZE+6
				sta deathplosion_pos
				lda esp_rx_buffer+GAMESTATE_OFFSET+GAMESTATE_SIZE+7
				sta deathplosion_origin

				; Screen state
				lda esp_rx_buffer+GAMESTATE_OFFSET+GAMESTATE_SIZE+8
				sta stage_fade_level

				lda esp_rx_buffer+GAMESTATE_OFFSET+GAMESTATE_SIZE+9
				sta stage_screen_effect
				beq screen_effect_ok
					; Some screen effects are playing, the screen will need to be restored
					lda #0
					sta stage_restore_screen_step
				screen_effect_ok:
			.)

			; Copy controllers state
			CONTROLLERS_STATE_OFFSET = GAMESTATE_OFFSET+GAMESTATE_SIZE+10
			lda esp_rx_buffer+CONTROLLERS_STATE_OFFSET+0
			sta controller_a_btns
			lda esp_rx_buffer+CONTROLLERS_STATE_OFFSET+1
			sta controller_b_btns

			; Copy actually pressed opponent btns (keep_input_dirty may mess with normal values, but not this one)
			.(
				;TODO Investigate
				;     We may want to write received buttons in local player history instead of burning it
				;       That would avoid desynchronizing if a ControllerState packet is lost (= not seen by server)
				;     Beware of race conditions, if the server receives the ControllerState packet after sending the NewState
				;       That would cause desychronization (until next NewGameState received), because we updated history with predicted info from server
#if 1
				; optimizable now that we can read in random access, we may not have to use the stack to store the useful value
				lda network_local_player_number
				bne player_b

					player_a:
						; Local player is player A, ignore its buttons (already in our history)
						;lda esp_rx_buffer+CONTROLLERS_STATE_OFFSET+2
						lda esp_rx_buffer+CONTROLLERS_STATE_OFFSET+3
						pha
						jmp ok

					player_b:
						; Local player is player B, ignore its buttons (already in our history)
						lda esp_rx_buffer+CONTROLLERS_STATE_OFFSET+2
						pha
						;lda esp_rx_buffer+CONTROLLERS_STATE_OFFSET+3
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
						lda esp_rx_buffer+CONTROLLERS_STATE_OFFSET+2
						sta network_player_local_btns_history, y
						lda esp_rx_buffer+CONTROLLERS_STATE_OFFSET+3
						sta network_player_remote_btns_history, y
						jmp ok

					player_b:
						; Local player is player B
						lda esp_rx_buffer+CONTROLLERS_STATE_OFFSET+2
						sta network_player_remote_btns_history, y
						lda esp_rx_buffer+CONTROLLERS_STATE_OFFSET+3
						sta network_player_local_btns_history, y
				ok:
#endif
			.)

			; Copy animation states
			ANIM_OFFSET = CONTROLLERS_STATE_OFFSET+4
			.(
				lda esp_rx_buffer+ANIM_OFFSET+0
				sta player_a_animation+ANIMATION_STATE_OFFSET_DATA_VECTOR_LSB
				lda esp_rx_buffer+ANIM_OFFSET+1
				sta player_a_animation+ANIMATION_STATE_OFFSET_DATA_VECTOR_MSB
				lda esp_rx_buffer+ANIM_OFFSET+2
				sta player_a_animation+ANIMATION_STATE_OFFSET_DIRECTION
				lda esp_rx_buffer+ANIM_OFFSET+3
				sta player_a_animation+ANIMATION_STATE_OFFSET_CLOCK
				lda esp_rx_buffer+ANIM_OFFSET+4
				sta player_a_animation+ANIMATION_STATE_OFFSET_FRAME_VECTOR_LSB
				lda esp_rx_buffer+ANIM_OFFSET+5
				sta player_a_animation+ANIMATION_STATE_OFFSET_FRAME_VECTOR_MSB
				lda esp_rx_buffer+ANIM_OFFSET+6
				sta player_a_animation+ANIMATION_STATE_OFFSET_NTSC_CNT

				lda esp_rx_buffer+ANIM_OFFSET+7
				sta player_b_animation+ANIMATION_STATE_OFFSET_DATA_VECTOR_LSB
				lda esp_rx_buffer+ANIM_OFFSET+8
				sta player_b_animation+ANIMATION_STATE_OFFSET_DATA_VECTOR_MSB
				lda esp_rx_buffer+ANIM_OFFSET+9
				sta player_b_animation+ANIMATION_STATE_OFFSET_DIRECTION
				lda esp_rx_buffer+ANIM_OFFSET+10
				sta player_b_animation+ANIMATION_STATE_OFFSET_CLOCK
				lda esp_rx_buffer+ANIM_OFFSET+11
				sta player_b_animation+ANIMATION_STATE_OFFSET_FRAME_VECTOR_LSB
				lda esp_rx_buffer+ANIM_OFFSET+12
				sta player_b_animation+ANIMATION_STATE_OFFSET_FRAME_VECTOR_MSB
				lda esp_rx_buffer+ANIM_OFFSET+13
				sta player_b_animation+ANIMATION_STATE_OFFSET_NTSC_CNT
			.)

			; Copy character specific data
			CHARACTERS_OFFSET = ANIM_OFFSET+14
			lda #CHARACTERS_OFFSET
			pha
			.(
				ldx #0
				copy_one_char:
					; Point to character's netload routine
					ldy config_player_a_character, x

					lda characters_netload_routine_lsb, y
					sta tmpfield1
					lda characters_netload_routine_msb, y
					sta tmpfield2

					SWITCH_BANK(characters_bank_number COMMA y)

					; Call netload routine
					pla
					tay
					stx player_number
					jsr call_pointed_subroutine

					ldx player_number
					tya
					pha

					; Loop
					inx
					cpx #2
					bne copy_one_char
			.)
			;NOTE at this point there is still the current offset on the stack

			; Copy stage specific data
			pla
			tax
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

game_mode_online_init = network_init_stage
game_mode_online_pre_update = network_tick_ingame

game_mode_online_gameover:
.(
	; Wait for a message from the server to ensure we are synchronized
	;  Three possible cases
	;   - We receive a GameOver => we are synchronized, proceed to game over screen
	;   - We receive a GameState => it was actually not finished, rollback
	;   - We receive nothing => in doubt, proceed to game over screen
	.(
		;TODO try to avoid looping, but just prolongating the slowdown
		;     It should be a better experience (longer slowndown instead of a freeze at the end)

		; Check if we already received a GameOver message
		lda network_received_gameover
		bne proceed

			; Read incoming messages until timeout
			timeout_clock = network_received_gameover
			lda #NETWORK_GAMEOVER_MESSAGE_TIMEOUT
			sta timeout_clock

			wait_gameover:
				bit RAINBOW_WIFI_RX
				bpl loop_wait

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

							jmp proceed

						handle_new_state:
							; Return from gameover handler, effectively cancelling the gameover
							lda #0 ; Set Z flag, we want to skip this frame (as slowdown) and have the network engine read to GameOver message before next tick
							rts

				skip_message:
					sta RAINBOW_WIFI_RX

				loop_wait:
					dec timeout_clock
					beq proceed

						jsr sleep_frame
						jmp wait_gameover

		proceed:
	.)

	; Deactivate PAL emulation
	.(
		lda pal_emulation_counter
		bmi ok
			lda #$ff
			sta pal_emulation_counter
			lda #1
			sta system_index
		ok:
	.)

	; Continue to gameover screen
	jmp game_mode_goto_gameover

	;rts ; useless, jump to subroutine
.)

network_init_stage:
.(
	; Reinit frame counter
	lda #$00
	sta network_current_frame_byte0
	sta network_current_frame_byte1
	sta network_current_frame_byte2
	sta network_current_frame_byte3

	; Set client id
	lda audio_music_enabled ; Hack to easilly configure the player number - activate music on player A's system
	eor #%00000001
	sta network_client_id_byte0
	lda #0
	sta network_client_id_byte1
	sta network_client_id_byte2
	sta network_client_id_byte3

	rts
.)

network_tick_ingame:
.(
	.(
		network_opponent_number = audio_music_enabled ; Hack to easilly configure the player number - activate music on player A's system

		; Force opponent's buttons to not change
		ldx network_opponent_number
		lda controller_a_last_frame_btns, x
		sta controller_a_btns, x

		; Send controller's state
		jsr switch_selected_player
		lda controller_a_btns, x
		cmp controller_a_last_frame_btns, x
		beq controller_sent

			sta $5009 ; buttons

			lda #$1    ; message_type
			sta $5000

			lda network_client_id_byte0 ; client_id
			sta $5001
			lda network_client_id_byte1
			sta $5002
			lda network_client_id_byte2
			sta $5003
			lda network_client_id_byte3
			sta $5004

			lda network_current_frame_byte0 ; timestamp
			sta $5005
			lda network_current_frame_byte1
			sta $5006
			lda network_current_frame_byte2
			sta $5007
			lda network_current_frame_byte3
			sta $5008

			lda #9    ; Send the packet
			sta $5101

		controller_sent:

		; Receive new state
		lda $5101
		cmp #87
		bne state_updated
		lda $5000
		cmp #2 ; TODO MESSAGE_TYPE_NEWSTATE
		bne state_updated
			jsr update_state
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
		; Copy gamestate
		ldx #0
		copy_one_byte:

			lda $5006, x ; 4 cycles
			sta $00, x   ; 4 cycles

		inx ; 2 cycles
		cpx #$4f ; 3 cycles
		bne copy_one_byte ; 3 cycles

		; Note
		;  Total - (4+4+2+3+3) * 79 = 16 * 79 = 1264
		;  Unroll - (4+4) * 79 = 8 * 79 = 632

		; Copy controllers state, the game state shall have run one frame, last_frame_btns and btns became equal
		lda $5006, x
		sta controller_a_btns
		sta controller_a_last_frame_btns
		lda $5006+1, x
		sta controller_b_btns
		sta controller_b_last_frame_btns

		; Reset frame counter
		;  TODO if in the past, reroll game updates
		lda $5002
		sta network_current_frame_byte0
		lda $5003
		sta network_current_frame_byte1
		lda $5004
		sta network_current_frame_byte2
		lda $5005
		sta network_current_frame_byte3

		rts
	.)

.)

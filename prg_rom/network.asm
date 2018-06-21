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

	rts
.)

network_tick_ingame:
.(
	network_opponent_number = audio_music_enabled ; Hack to easilly configure the player number - activate music on player A's system

	.(
		; Do nothing in rollback mode, it would be recursive
		lda network_rollback_mode
		bne end

		; Force opponent's buttons to not change
		ldx network_opponent_number
		lda controller_a_last_frame_btns, x
		sta controller_a_btns, x

		; Save local controller's history
		jsr switch_selected_player
		lda network_current_frame_byte0
		and #%00011111
		tay
		lda controller_a_btns, x
		sta network_btns_history, y

		; Send controller's state
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

		end:
		rts
	.)

	update_state:
	.(
		//TODO reserve a place for it in mem_labels
		server_current_frame_byte0 = $07d0
		server_current_frame_byte1 = $07d1
		server_current_frame_byte2 = $07d2
		server_current_frame_byte3 = $07d3

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

		; Extract frame counter
		lda $5002
		sta server_current_frame_byte0
		lda $5003
		sta server_current_frame_byte1
		lda $5004
		sta server_current_frame_byte2
		lda $5005
		sta server_current_frame_byte3

		; Update game state until the current frame is at least equal to the one we where before reading the message
		lda #1
		sta network_rollback_mode
		roll_forward_one_step:
		.(
			; If sever's frame is inferior to local frame
			lda server_current_frame_byte3
			cmp network_current_frame_byte3
			bcc do_it
			lda server_current_frame_byte2
			cmp network_current_frame_byte2
			bcc do_it
			lda server_current_frame_byte1
			cmp network_current_frame_byte1
			bcc do_it
			lda server_current_frame_byte0
			cmp network_current_frame_byte0
			bcc do_it
			jmp end_loop
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
		.)
		lda #0
		sta network_rollback_mode

		// Copy (updated) server frame number to the local one
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

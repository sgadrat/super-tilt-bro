; Copy nametable buffers to PPU nametable
; A nametable buffer has the following pattern:
;   continuation (1 byte), address (2 bytes), number of tiles (1 byte), tiles (N bytes)
;   continuation - 1 there is a buffer, 0 work done
;   address - address where to write in PPU address space (big endian)
;   number of tiles - Number of tiles in this buffer
;   tiles - One byte per tile, representing the tile number
;
; Overwrites register X and tmpfield1
process_nt_buffers:
.(
	lda PPUSTATUS ; reset PPUADDR state

	ldx #$00
	handle_nt_buffer:

		; Check continuation byte
		lda nametable_buffers, x
		beq end_buffers
		inx

		; Set PPU destination address
		lda nametable_buffers, x
		sta PPUADDR
		inx
		lda nametable_buffers, x
		sta PPUADDR
		inx

		; Save tiles counter to tmpfield1
		lda nametable_buffers, x
		sta tmpfield1
		inx

		write_one_tile:
			; Write current tile to PPU
			lda nametable_buffers, x
			sta PPUDATA

			; Next tile
			inx
			dec tmpfield1
			bne write_one_tile
			jmp handle_nt_buffer

	end_buffers:
	rts
.)

; Indicate that the input modification on this frame has not been consumed
keep_input_dirty:
.(
	lda controller_a_last_frame_btns, x
	sta controller_a_btns, x
	rts
.)

; Compute the current transition id (previous game state << 4 + new game state)
;
; Output - register A is set to the result
; Overwrites register A
get_transition_id:
.(
	lda previous_global_game_state
	asl
	asl
	asl
	asl
	adc global_game_state
	rts
.)

; Change the game's state
;  register A - new game state
;
; WARNING - This routine never returns. It changes the state then restarts the main loop.
change_global_game_state:
.(
	.(
		; Save previous game state and set the global_game_state variable
		tax
		lda global_game_state
		sta previous_global_game_state
		txa
		sta global_game_state

		; Begin transition between screens
		jsr pre_transition

		; Disable rendering
		;  Keep NMI in audio mode to compensate for not going trhough the main loop each frame
		;  (State initialization routines typically take some frames to play with vram)
		;  (This will be magically restored to normal behavior by the next call to wait_next_frame)
		lda #NMI_AUDIO
		sta nmi_processing
		lda #%10010000
		sta PPUCTRL
		lda #$00
		sta PPUMASK
		sta ppuctrl_val

		; Clear not processed drawings
		jsr reset_nt_buffers

		; Reset scrolling
		lda #$00
		sta scroll_x
		sta scroll_y

		; Reset particle handlers
		jsr particle_handlers_reinit

		; Move all sprites offscreen
		ldx #$00
		clr_sprites:
		lda #$FE
		sta oam_mirror, x    ;move all sprites off screen
		inx
		bne clr_sprites

		; Call the appropriate initialization routine
		lda global_game_state
		asl
		tax
		lda game_states_init, x
		sta tmpfield1
		lda game_states_init+1, x
		sta tmpfield2
		jsr call_pointed_subroutine

		; Do transition between screens (and reactivate rendering)
		jsr post_transition

		; Clear stack
		ldx #$ff
		txs

		; Go straight to the main loop
		jmp forever
	.)

	; Set register X value to the offset of the appropriate transition in the transition table
	find_transition_index:
	.(
		transition_id = tmpfield1

		jsr get_transition_id
		sta transition_id
		ldx #0
		check_one_entry:
			lda state_transition_id, x
			beq not_found
			cmp tmpfield1
			beq found

			inx
			jmp check_one_entry

		not_found:
			ldx #$ff
		found:
		rts
	.)

	pre_transition:
	.(
		jsr find_transition_index
		cpx #$ff
		beq end

			lda state_transition_pretransition_lsb, x
			sta tmpfield1
			lda state_transition_pretransition_msb, x
			sta tmpfield2
			jsr call_pointed_subroutine

		end:
		rts
	.)

	post_transition:
	.(
		jsr find_transition_index
		cpx #$ff
		beq no_transition

			lda state_transition_posttransition_lsb, x
			sta tmpfield1
			lda state_transition_posttransition_msb, x
			sta tmpfield2
			jsr call_pointed_subroutine

			jmp end

		no_transition:
			lda #%10010000  ;
			sta ppuctrl_val ; Reactivate rendering
			sta PPUCTRL     ;
			jsr wait_next_frame ; Avoid re-enabling mid-frame
			lda #%00011110 ; Enable sprites and background rendering
			sta PPUMASK    ;

		end:
		rts
	.)
.)

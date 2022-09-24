; Copy nametable buffers to PPU nametable
; A nametable buffer has the following pattern:
;   continuation (1 byte), payload (depends on buffer's type)
:
;   continuation - buffer's type, or zero at the end of the list (see NT_BUFFER_* constants)
;
;   NT_BUFFER_BASIC
;     continuation (1 byte), address (2 bytes), number of tiles (1 byte), tiles (N bytes)
;       address         - Address where to write in PPU address space (big endian)
;       number of tiles - Number of tiles in this buffer
;       tiles           - One byte per tile, representing the tile number
;
;   NT_BUFFER_ATTRIBUTES
;     continuation (1 byte), attributes (64 bytes)
;       attributes - attribute values to write on top-left nametable
;
; Overwrites all registers
; NOTE as a part of the NMI handler, tmpfields must be preserved.
process_nt_buffers:
.(
	; Save modified tmpfields
	;  12 cycles
	lda tmpfield1 : pha
	lda tmpfield2 : pha

	; Reset PPUADDR state
	;  4 cycles (16)
	lda PPUSTATUS

	; Reset timer
	;  5 cycles (21)
	lda #0
	sta nt_buffer_timer

	; Get nametables buffers begining
	;  3 cycles (24)
	ldx nt_buffers_begin
	handle_nt_buffer:

		; Call handler for that continuation byte's value
		;  4+2+(4+1)+3+(4+0)+3+5 = 26 cycles per buffer
		ldy nametable_buffers, x
		inx

		lda buffer_handlers_lsb, y
		sta tmpfield1
		lda buffer_handlers_msb, y
		sta tmpfield2
		jmp (tmpfield1)

	;
	; Handlers
	;  Can modify A, Y, tmpfield1 and tmpfield2
	;  Must update X to next continuation byte
	;  Must update nt_buffers_begin to next continuation byte
	;  Must update timer (timer += 2.5 for per-buffer common code + 0.08 per cycle in the handler)
	;  If timer becomes more than 128
	;   - the handler shall abort
	;   - without updating nt_buffers_begin
	;   - within ~50 cycles from being called (TODO should figure more precise max cycles for aborting)
	;

	vertical_buffer:
	.(
		; Set PPU increment to vertical
		;  3 + 2 + 4 = 9 cycles
		lda ppuctrl_val
		ora #%00000100
		sta PPUCTRL

		; Add extra cost to nt buffer timer (as basic_buffer will only count its own cost)
		;  5 cycles
		;  total, 9 + 5 + 3 = 19 cycles = 1.52 point (rounded down as basic_buffer rounds up by a large amount)
		inc nt_buffer_timer

		; Handle it as a basic_buffer
		;  3 cycles
		jmp basic_buffer
	.)

	horizontal_buffer:
	.(
		; Set PPU increment to horizontal
		;  3 + 2 + 4 = 9 cycles
		lda ppuctrl_val
		and #%11111011
		sta PPUCTRL

		; Add extra cost to nt buffer timer (as basic_buffer will only count its own cost)
		;  5 cycles
		;  total, 9 + 5 = 16 cycles = 1.28 point (rounded down as basic_buffer rounds up by a large amount)
		inc nt_buffer_timer

		; Fallthourgh to basic_buffer
	.)

	basic_buffer:
	.(
		tmp_val = tmpfield1

		; Set PPU destination address
		;  4+4+2+4+4+2 = 20 cycles
		lda nametable_buffers, x
		sta PPUADDR
		inx
		lda nametable_buffers, x
		sta PPUADDR
		inx

		; Read tiles counter
		;  4+2 cycles (26)
		ldy nametable_buffers, x
		inx

		; Compute cost of this buffer
		;   (cost = 2.5 for per-buffer common code + 0.08 per cycle in the handler)
		;   2.5 + 0.08*(common cycles) + 0.08*(cycles per tile)
		;   2.5 + 0.08*(33 + cycles for this segment) + nb_tiles*0.08*(cycles per tile)
		;   2.5 + 0.08*(33 + 22) + nb_tiles*0.08*16
		;   2.5 + 0.08*55 + nb_tiles*1.28
		;   7 + nb_tiles*1.5 (roughly)
		.(
			; nb_tiles * 1.5
			;  2+3+2+2+3 = 12 cycles
			tya
			sta tmp_val
			lsr
			clc
			adc tmp_val

			; Add time common for all tiles
			;  2+2+3+3 = 10 cycles (22)
			adc #7
			adc nt_buffer_timer
			bmi end_buffers
			sta nt_buffer_timer
		.)

		write_one_tile:
			; Write current tile to PPU
			;  4+4 = 8 cycles per tile
			lda nametable_buffers, x
			sta PPUDATA

			; Next tile
			;  2+2+4 = 8 cycles tile (or less if not misaligned)
			inx
			dey
			bne write_one_tile

		; Point the next buffer as first buffer
		;  4 cycles
		stx nt_buffers_begin

		; Process next buffer
		;  3 cycles
		jmp handle_nt_buffer
	.)

	end_buffers:
	.(
		; Restore modified tmppfields
		;  14 cycles (38)
		pla : sta tmpfield2
		pla : sta tmpfield1

		; Stop processing buffers
		;  6 cycles (44)
		rts
	.)

	attributes_buffer:
	.(
		; Compute cost of this buffer
		;  2+2+3+2+3 = 12 cycles
		;   (cost = 2.5 for per-buffer common code + 0.08 per cycle in the handler)
		;   2.5 + 0.08*(common cycles + NB_STEPS * cycles per step)
		;   2.5 + 0.08*(42 + 16 * 46)
		;   64.74
		lda #65
		clc
		adc nt_buffer_timer
		bmi end_buffers
		sta nt_buffer_timer

		; Set PPU increment to horizontal
		;  3 + 2 + 4 = 9 cycles (21)
		lda ppuctrl_val
		and #%11111011
		sta PPUCTRL

		; Set PPU address
		;  2+4+2+4 = 12 cycles (33)
		lda #$23
		sta PPUADDR
		lda #$c0
		sta PPUADDR

		; Copy 64 bytes from the buffer
		;  2 cycles (35)
		STEP_SIZE = 4
		NB_STEPS = 64 / STEP_SIZE

		ldy #NB_STEPS
		one_step:
			; Copy data
			; 	4*(4+4+2) = 40 cycles
			lda nametable_buffers, x
			sta PPUDATA
			inx

			lda nametable_buffers, x
			sta PPUDATA
			inx

			lda nametable_buffers, x
			sta PPUDATA
			inx

			lda nametable_buffers, x
			sta PPUDATA
			inx

			; Loop
			;  2 + 4 = 6 cycles (46)
			dey
			bne one_step

		; Point the next buffer as first buffer
		;  4 cycles (39)
		stx nt_buffers_begin

		; Process next buffer
		;  3 cycles (42)
		jmp handle_nt_buffer
	.)

	buffer_handlers_lsb:
		.byt <end_buffers, <basic_buffer, <attributes_buffer, <horizontal_buffer, <vertical_buffer
	buffer_handlers_msb:
		.byt >end_buffers, >basic_buffer, >attributes_buffer, >horizontal_buffer, >vertical_buffer
.)

; Consume input only if it is "all buttons released"
;  Essentially the same as keep_input_dirty, but releasing and pressing again
;  the button that started the move will work as expected
smart_keep_input_dirty:
.(
	lda controller_a_btns, x
	beq keep_input_dirty_rts ; exploit CONTROLLER_INPUT_NONE being zero
	; Fallthrough to  keep_input_dirty
.)

; Indicate that the input modification on this frame has not been consumed
keep_input_dirty:
.(
	lda controller_a_last_frame_btns, x
	sta controller_a_btns, x
	&keep_input_dirty_rts:
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
		sta ppuctrl_val ;TODO investigate, ppuctr_val != PPUCTRL, it may be a bug, certainly non-impacting since we are in audio mode

		; Clear not processed drawings
		jsr clear_nt_buffers

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

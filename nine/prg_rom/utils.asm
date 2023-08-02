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

	; Buffer with customizable steps between PPU writes
	;  Layout
	;   | size | address (big endian) | step | payload |
	;   size    - number of bytes in payload
	;   address - Adress of the first PPU write (big endian)
	;   step    - VRAM address increment between writes
	;   payload - VRAM bytes to write
	step_buffer:
	.(
		addr_lsb = tmpfield1
		addr_msb = tmpfield2
		step = tmpfield3

		; Read tiles counter
		;  4+2 = 6 cycles
		ldy nametable_buffers, x
		inx

		; Compute cost of this buffer
		;   (cost = 2.5 for per-buffer common code + 0.08 per cycle in the handler)
		;   2.5 + 0.08*(common cycles) + 0.08*(cycles per tile)
		;   2.5 + 0.08*(61 + cycles for this segment) + nb_tiles*0.08*(cycles per tile)
		;   2.5 + 0.08*(61 + 28) + nb_tiles*0.08*46
		;   2.5 + 0.08*89 + nb_tiles*3.68
		;   10 + nb_tiles*4 (roughly)
		.(
			; nb_tiles * 1.5
			;  2+2+2 = 6 cycles
			tya
			asl
			asl

			; Add time common for all tiles
			;  2+2+3+3 = 10 cycles (22)
			adc #10
			adc nt_buffer_timer
			bmi end_buffers
			sta nt_buffer_timer
		.)

		; Save overwritten memory
		;  3+3 = 6 cycles (12)
		lda step
		pha

		; Set PPU destination address
		;  4+3+4+2+4+3+4+2 = 26 cycles (38)
		lda nametable_buffers, x
		sta addr_msb
		sta PPUADDR
		inx
		lda nametable_buffers, x
		sta addr_lsb
		sta PPUADDR
		inx

		; Read step size
		;  4+3+2 = 9 cycles (47)
		lda nametable_buffers, x
		sta step
		inx

		write_one_tile:
			; Write current tile to PPU
			;  4+4 = 8 cycles per tile
			lda nametable_buffers, x
			sta PPUDATA

			; Skip 7 bytes of VRAM
			; 3+2+3+3+3+2+3+4+3+4 = 30 cycles
			lda addr_lsb
			clc
			adc step
			sta addr_lsb
			lda addr_msb
			adc #0
			sta addr_msb
			sta PPUADDR
			lda addr_lsb
			sta PPUADDR

			; Next tile
			;  2+2+4 = 8 cycles tile (or less if not misaligned)
			inx
			dey
			bne write_one_tile

		; Point the next buffer as first buffer
		;  4 cycles (51)
		stx nt_buffers_begin

		; Restore overwritten memory
		;  4+3 = 7 cycles (58)
		pla
		sta step

		; Process next buffer
		;  3 cycles (61)
		jmp handle_nt_buffer
	.)

	buffer_handlers_lsb:
		.byt <end_buffers, <basic_buffer, <attributes_buffer, <horizontal_buffer, <vertical_buffer, <step_buffer
	buffer_handlers_msb:
		.byt >end_buffers, >basic_buffer, >attributes_buffer, >horizontal_buffer, >vertical_buffer, >step_buffer
.)

; Consume input only if it is "all buttons released"
;  Essentially the same as dumb_keep_input_dirty, but releasing and pressing again
;  the button that started the move will work as expected
smart_keep_input_dirty:
.(
	lda controller_a_btns, x
	beq keep_input_dirty_rts ; exploit CONTROLLER_INPUT_NONE being zero
	; Fallthrough to dumb_keep_input_dirty
.)

; Indicate that the input modification on this frame has not been consumed
dumb_keep_input_dirty:
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

fetch_controllers:
.(
	; Fetch controllers state
	lda #$01
	sta CONTROLLER_A
	lda #$00
	sta CONTROLLER_A

	; x will contain the controller number to fetch (0 or 1)
	ldx #$00

	fetch_one_controller:

	; Save previous state of the controller
	lda controller_a_btns, x
	sta controller_a_last_frame_btns, x

	; Reset the controller's byte
	lda #$00
	sta controller_a_btns, x

	; Fetch the controller's byte button by button
	ldy #$08
	next_btn:
		lda CONTROLLER_A, x
		and #%00000011
		cmp #1
		rol controller_a_btns, x
		dey
		bne next_btn

	; Next controller
	inx
	cpx #$02
	bne fetch_one_controller

	rts
.)

; Wait the next frame, returns once NMI is complete
wait_next_frame:
.(
#if NMI_DRAW <> 0
#error code below expects NMI_DRAW to be zero
#endif

	lda #NMI_DRAW
	sta nmi_processing
	waiting:
		lda nmi_processing
		beq waiting
	rts
.)

#if 0
; Perform multibyte signed comparison
;  tmpfield6 - a (low)
;  tmpfield7 - a (high)
;  tmpfield8 - b (low)
;  tmpfield9 - b (high)
;
; Output - N flag set if "a < b", unset otherwise
;          C flag set if "(unsigned)a < (unsigned)b", unset otherwise
; Overwrites register A
;
; Obsolete, see the macro with the same name (capitalized)
signed_cmp:
.(
	; Trick from http://www.6502.org/tutorials/compare_beyond.html
	a_low = tmpfield6
	a_high = tmpfield7
	b_low = tmpfield8
	b_high = tmpfield9

	lda a_low
	cmp b_low
	lda a_high
	sbc b_high
	bvc end
		eor #%10000000
	end:
	rts
.)
#endif

; Change A to its absolute unsigned value
absolute_a:
.(
	cmp #$00
	bpl end
	eor #%11111111
	clc
	adc #$01

	end:
	rts
.)

; Multiply tmpfield1 by tmpfield2 in tmpfield3
;  tmpfield1 - multiplicand (low byte)
;  tmpfield2 - multiplicand (high byte)
;  tmpfield3 - multiplier
;  Result stored in tmpfield4 (low byte) and tmpfield5 (high byte)
;
;  Overwrites register A, tmpfield4 and tmpfield5
multiply:
.(
	;TODO optimizable - use shift and add instead of addition loop
	;TODO check if it may be merged with multiply8 code
	multiplicand_low = tmpfield1
	multiplicand_high = tmpfield2
	multiplier = tmpfield3
	result_low = tmpfield4
	result_high = tmpfield5

	; Save X, we do not want it to be altered by this subroutine
	txa
	pha

	; Set multiplier to X to be used as a loop count
	lda multiplier
	tax

	; Initialize result's value
	lda #$00
	sta result_low
	sta result_high

	additions_loop:
		; Check if we finished
		cpx #$00
		beq end

		; Add multiplicand to the result
		lda result_low
		clc
		adc multiplicand_low
		sta result_low
		lda result_high
		adc multiplicand_high
		sta result_high

		; Iterate until we looped "multiplier" times
		dex
		jmp additions_loop

	end:
	; Restore X
	pla
	tax

	rts
.)

; Empty the list of nametable buffers
;  Overwrites A
clear_nt_buffers: ; New name to make it clear, calling it cancel any unprocessed buffer
.(
	lda #0
	sta nt_buffers_begin
	sta nt_buffers_end
	sta nametable_buffers
	rts
.)

; A routine doing nothing, it can be used as dummy entry in jump tables
dummy_routine:
.(
	rts
.)

; Change global game state, without trigerring any transition code
;  tmpfield1,tmpfield2 - new state initialization routine
;  tmpfield3 - new game state
;
; NOTE - the initialization routine is called while rendering is active (unlike change_global_game_state)
; WARNING - This routine never returns. It changes the state then restarts the main loop.
change_global_game_state_lite:
.(
	init_routine = tmpfield1      ; Not movable, parameter of call_pointed_subroutine
	init_routinei_msb = tmpfield2 ;
	new_state = tmpfield3

	; Save previous game state and set the global_game_state variable
	lda global_game_state
	sta previous_global_game_state
	lda new_state
	sta global_game_state

	; Move all sprites offscreen
	ldx #$00
	lda #$fe
	clr_sprites:
		sta oam_mirror, x    ;move all sprites off screen
		inx
		inx
		inx
		inx
		bne clr_sprites

	; Call the appropriate initialization routine
	jsr call_pointed_subroutine

	; Clear stack
	ldx #$ff
	txs

	; Go straight to the main loop
	jmp forever
.)

; Copy a compressed nametable to PPU
;  tmpfield1 - compressed nametable address (low)
;  tmpfield2 - compressed nametable address (high)
;
; Overwrites all registers, tmpfield1 and tmpfield2
draw_zipped_nametable:
.(
	compressed_nametable = tmpfield1

	lda PPUSTATUS
	lda #$20
	sta PPUADDR
	lda #$00
	sta PPUADDR

&draw_zipped_vram:
	ldy #$00
	load_background:
		lda (compressed_nametable), y
		beq opcode

		; Standard byte, just write it to PPUDATA
		normal_byte:
			sta PPUDATA
			jsr next_byte
			jmp load_background

		; Got the opcode
		opcode:
			jsr next_byte                 ;
			lda (compressed_nametable), y ; Load parameter in a, if it is zero it means that
			beq end                       ; the nametable is over

			tax                    ;
			lda #$00               ;
			write_one_byte:        ; Write 0 the number of times specified by parameter
				sta PPUDATA        ;
				dex                ;
				bne write_one_byte ;

			jsr next_byte       ; Continue reading the table
			jmp load_background ;

	end:
	rts

	next_byte:
	.(
		inc compressed_nametable
		bne end_inc_vector
		inc compressed_nametable+1
		end_inc_vector:
		rts
	.)
.)

; Allows to inderectly call a pointed subroutine normally with jsr
;  tmpfield1,tmpfield2 - subroutine to call
call_pointed_subroutine:
.(
	jmp (tmpfield1)
.)

; Copy a palette from a palettes table to the ppu
;  register X - PPU address LSB (MSB is fixed to $3f)
;  tmpfield1 - palette number in the table
;  tmpfield2, tmpfield3 - table's address
;
;  Overwrites registers
copy_palette_to_ppu:
.(
	palette_index = tmpfield1
	palette_table = tmpfield2

	lda PPUSTATUS
	lda #$3f
	sta PPUADDR
	txa
	sta PPUADDR

	lda palette_index
	asl
	;clc ; useless, asl shall not overflow
	adc palette_index
	tay
	ldx #3
	copy_one_color:
		lda (palette_table), y
		sta PPUDATA
		iny
		dex
		bne copy_one_color
	rts
.)

shake_screen:
.(
	multiplier = tmpfield1
	multiplicand = tmpfield2
	rand_offset = tmpfield3

	; Move scroll position closer to target (target is hardcoded as 0,0)
	.(
		ldy screen_shake_counter
		ldx #1
		move_one_component:
			; Move current position one step closer to origin
			lda screen_shake_current_x, x
			beq ok
			bpl dec_component
				inc_component:
					lda screen_shake_current_x, x
					clc
					adc screen_shake_speed_h, x
					sta screen_shake_current_x, x
					jmp ok
				dec_component:
					lda screen_shake_current_x, x
					sec
					sbc screen_shake_speed_h, x
					sta screen_shake_current_x, x
			ok:

			; Update scroll value, adding noise
			lda screen_shake_noise_h, x ; Compute screen_shake_noise/2
			lsr
			sta rand_offset

			lda random_table, y ; Get a random number
			tay ; Change Y to avoid using the same random number for both componenet

#if 1
			sta multiplicand ; Cap random value in range [0 ; screen_shake_noise]
			lda screen_shake_noise_h, x
			sta multiplier
			jsr multiply8
#else
			;TODO optimize
			;  - This version simply divide by 2 until finding a number below screen_shake_noise
			;    - Simple and pretty fast, will induce significant bias toward high numbers
			;  - Another idea would be to compute the bitmask, and if result still higher than screen_shake_noise LSR
			;    - Should be speedier than multiplying and only slighlty bias toward middle values
			cap_rand: ; Cap random value in range [0 ; screen_shake_noise]
			cmp screen_shake_noise_h, x
			bcc cap_rand_ok
			beq cap_rand_ok
				lsr
				bne cap_rand
			cap_rand_ok:
#endif

			sec ; Move random value to range [-(screen_shake_noise/2) ; screen_shake_noise/2]
			sbc rand_offset

			clc ; scroll = current position + random number
			adc screen_shake_current_x, x
			sta scroll_x, x

			; Next component
			dex
			bpl move_one_component
	.)

	; Adapt screen number to Y scrolling
	;  Negative values are set at the end of screen 2, on position 240 - abs(scroll_y) = 240 + scroll_y
	lda scroll_y
	bmi set_screen_two
		lda #%10010000
		jmp set_screen
	set_screen_two:
		clc
		adc #240
		sta scroll_y
		lda #%10010010
	set_screen:
	sta ppuctrl_val

	; Decrement screen shake counter
	dec screen_shake_counter
	bne end

	; Shaking is over, reset the scrolling
	lda #$00
	sta scroll_y
	sta scroll_x
	lda #%10010000
	sta ppuctrl_val

	end:
	rts
.)

#define NEXT_BYTE .(:\
	iny:\
	bne end_inc_vector:\
	inc compressed_nametable+1:\
	end_inc_vector:\
.)

#define GOT_BYTE .(:\
	sty local_tmp:\
	ldy current:\
	sta (dest), y:\
	inc current:\
	ldy local_tmp:\
.)

; Unzip a chunk of a compressed nametable
;  tmpfield1 - zipped data address (low)
;  tmpfield2 - zipped data address (high)
;  tmpfield3 - unzipped data offset (low)
;  tmpfield4 - unzipped data offset (high)
;  tmpfield5 - unzipped data count
;  tmpfield6 - unzipped data destination (low)
;  tmpfield7 - unzipped data destination (high)
;
; Overwrites all registers, tmpfield1-10
get_unzipped_bytes:
.(
	compressed_nametable = tmpfield1
	offset = tmpfield3
	count = tmpfield5
	dest = tmpfield6
	current = tmpfield8
	zero_counter = tmpfield9 ; WARNING - used temporarily, read the code before using it
	local_tmp = tmpfield10

	lda #0
	sta current

	ldx #0
	ldy #0
	skip_bytes:
	.(
		; Decrement offset, stop on zero
		.(
			lda offset
			bne no_carry
				carry:
					lda offset+1
					beq end_skip_bytes
					dec offset+1
				no_carry:
					dec offset
		.)
		loop_without_dec:

		; Take action,
		;  - output a zero if in compressed series
		;  - output the byte on normal bytes
		;  - init compressed series on opcode
		cpx #0
		bne compressed_zero
		lda (compressed_nametable), y
		beq opcode

			normal_byte:
				NEXT_BYTE
				jmp skip_bytes

			opcode:
				; X = number of uncompressed zeros to output
				NEXT_BYTE
				lda (compressed_nametable), y
				tax
				NEXT_BYTE

				; Skip iterating on useless zeros
				;  note - This code checks only offset's msb to know if offset > X.
				;         It could be finer grained to gain some cycles (to be tested on need)
				.(
					lda offset+1
					beq done

						skip_all:
							stx zero_counter
							ldx #0

							sec
							lda offset
							sbc zero_counter
							sta offset
							lda offset+1
							sbc #0
							sta offset+1

					done:
				.)

				jmp loop_without_dec ; force the loop, we did not get uncompressed byte

			compressed_zero:
				dex
				jmp skip_bytes

		end_skip_bytes:
	.)

	get_bytes:
	.(
		; Take action,
		;  - output a zero if in compressed series
		;  - output the byte on normal bytes
		;  - init compressed series on opcode
		cpx #0
		bne compressed_zero
		lda (compressed_nametable), y
		beq opcode

			normal_byte:
				GOT_BYTE
				NEXT_BYTE
				ldx #0
				jmp loop_get_bytes

			opcode:
				NEXT_BYTE
				lda (compressed_nametable), y
				tax
				NEXT_BYTE
				jmp get_bytes  ; force the loop, we did not get uncompressed byte

			compressed_zero:
				stx zero_counter
				lda #0
				GOT_BYTE
				ldx zero_counter
				dex
				;jmp loop_get_bytes ; useless fallthrough

		; Check loop count
		loop_get_bytes:
		dec count
		force_loop_get_bytes:
		bne get_bytes
	.)

	end:
	rts
.)

#undef NEXT_BYTE
#undef GOT_BYTE

; Multiply two 8 bit unsigned numbers
;  tmpfield1 - Multiplier
;  tmpfield2 - Multiplicand
;
; Output:
;  tmpfield1 - Result LSB
;  A - Result MSB
;
; Overwrites A, tmpfield1
;
; Note - For best performances, put the number with less bits set to 1 as multiplier.
;
; Original code - https://www.lysator.liu.se/~nisse/misc/6502-mul.html
multiply8:
.(
	factor1 = tmpfield1
	factor2 = tmpfield2

#define ADD_ROR .( :\
		bcc no_add :\
			clc :\
			adc factor2 :\
		no_add:\
		ror :\
		ror factor1 :\
	.)

	lda #0
	lsr factor1
	ADD_ROR
	ADD_ROR
	ADD_ROR
	ADD_ROR
	ADD_ROR
	ADD_ROR
	ADD_ROR
	ADD_ROR

	rts

#undef ADD_ROR
.)

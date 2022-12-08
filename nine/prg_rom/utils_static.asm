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

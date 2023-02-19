;TODO move non-critical performance routines to an utility bank

; Load a tileset to from ROM to VRAM
;  Parameters after routine call
;   ppu_addr_msb, ppu_addr_lsb
;   modifier_lsb, modifier_msb
;   tileset_bank
;   return_bank
;   tileset_addr_lsb, tileset_addr_msb
;
;  Overwrites all registers, tmpfield1 to tmpfield7 (plus possible modifier's side effects)
+load_tileset:
.(
	parameter_addr = tmpfield1
	;parameter_addr_msb = tmpfield2

	prg_vector = tmpfield1
	prg_vector_msb = tmpfield2
	modifier = tmpfield4
	modifier_msb = tmpfield5

	; Stack shenaningans to handle parameters being hardcoded after the jsr
	lda #8
	jsr inline_parameters

	; Set PPU address
	lda PPUSTATUS
	ldy #0
	lda (parameter_addr), y
	sta PPUADDR
	iny
	lda (parameter_addr), y
	sta PPUADDR

	; Set modifier address
	iny
	lda (parameter_addr), y
	sta modifier
	iny
	lda (parameter_addr), y
	sta modifier_msb

	; Set trampoline parameters
	;NOTE Not using the macro because we read bank number from parameters while we will invalid parameters pointer
	lda #<cpu_to_ppu_copy_tileset_modified
	sta extra_tmpfield1
	lda #>cpu_to_ppu_copy_tileset_modified
	sta extra_tmpfield2

	iny
	lda (parameter_addr), y
	sta extra_tmpfield3

	iny
	lda (parameter_addr), y
	sta extra_tmpfield4

	; Store tileset address
	;NOTE Beware, we invalid paramer_addr pointer while reading parameters
	iny
	lda (parameter_addr), y
	tax
	iny
	lda (parameter_addr), y
	sta prg_vector_msb
	txa
	sta prg_vector

	; Call to tileset copying routine
	jsr trampoline

	rts
.)

; Copy a tileset from CPU memory to PPU memory, applying a modifier on the fly
;  tmpfield1, tmpfield2 - Address of the tileset in CPU memory
;  tmpfield3 - not a parameter
;  tmpfield4, tmpfield5 - Address of the modifier routine
;
; PPUADDR must be set to the destination address
; PPUCTRL's I bit should not be set (if set, writes every 32 bytes)
;
; Overwrites registers, tmpfield1 to tmpfield7 (plus possible modifier's side effects)
cpu_to_ppu_copy_tileset_modified:
.(
	addr_lsb = tmpfield1
	addr_msb = tmpfield2

	; Fetch tileset size
	ldy #0
	lda (addr_lsb), y
	sta tmpfield3

	; Compute tileset data address
	inc addr_lsb
	bne inc_ok
		inc addr_msb
	inc_ok:

	; Fallthrough to cpu_to_ppu_copy_tiles_modified
.)

; Copy tiles data from CPU memory to PPU memory
;  tmpfield1, tmpfield2 - Address of CPU data to be copied
;  tmpfield3 - Number of tiles to copy (zero means 255)
;  tmpfield4, tmpfield5 - Address of the modifier routine
;
; PPUADDR must be set to the destination address
; PPUCTRL's I bit should not be set (if set, writes every 32 bytes)
;
; Overwrites registers, tmpfield1 to tmpfield7 (plus possible modifier's side effects)
cpu_to_ppu_copy_tiles_modified:
.(
	prg_vector = tmpfield1
	; prg_vector_msb = tmpfield2
	tiles_counter = tmpfield3
	modifier = tmpfield4
	;modifier_msb = tmpfield5
	low_bits = tmpfield6
	high_bits = tmpfield7
	stack_buffer_begin = tmpfield6 ; NOTE should not conflict with low_bits (never used ate the same time)

	copy_one_tile:
		; Fetch/modify/write tile data
		;  low bits are written to PPU
		;  high bits are stored on stack
		ldy #0
		fetch_one_line:
			; Fetch low bits and high bits bytes
			lda (prg_vector), y
			sta low_bits

			tya
			clc
			adc #8
			tay

			lda (prg_vector), y
			sta high_bits

			; Call modifier
			;  - takes low/high bits input
			;  - outputs low bits in A, high bits in X
			;  - cannot modify Y, and tmpfield1 to tmpfield5
			jsr call_modifier

			; Write low bits to PPU, store high bits on stack
			sta PPUDATA
			txa:pha

			; Y points to the next low bits byte
			tya
			sec
			sbc #7
			tay

			; Loop
			cpy #8
			bne fetch_one_line

		; Write high bits to PPU
		tsx
		txa
		clc
		adc #8
		sta stack_buffer_begin
		tax

		ldy #8
		write_one_byte:
			lda stack, x
			sta PPUDATA

			dex
			dey
			bne write_one_byte

		ldx stack_buffer_begin
		txs

		; Point to next tile
		lda prg_vector
		clc
		adc #16
		sta prg_vector
		lda prg_vector+1
		adc #0
		sta prg_vector+1

		; Loop
		dec tiles_counter
		bne copy_one_tile

	rts

	call_modifier:
	.(
		jmp (tmpfield4)
	.)
.)

; cpu_to_ppu_copy_tiles_modified's modifier doing nothing
;
; Extra side effects
;  None
modifier_identity:
.(
	lda tmpfield6
	ldx tmpfield7
	rts
.)

; cpu_to_ppu_copy_tiles_modified's modifier remapping pixel values
;
; Extra side effects
;  Overwrites tmpfield12 and tmpfield13
modifier_remap:
.(
	low_bits = tmpfield6
	high_bits = tmpfield7
	remap_table = tmpfield8
	;remap_table = tmpfield9
	;remap_table = tmpfield10
	;remap_table = tmpfield11
	low_bits_res = tmpfield12
	high_bits_res = tmpfield13

	; Save Y
	tya:pha

	; Reset result
	lda #0
	sta low_bits_res
	sta high_bits_res

	; Convert pixel per pixel
	ldx #8
	remap_one_pixel:
		; Get original pixel's value
		lda #%00000000
		asl high_bits
		rol
		asl low_bits
		rol

		; Lookup new pixel's value
		tay
		lda remap_table, y

		; Store new pixel's value in result line
		lsr
		rol low_bits_res
		lsr
		rol high_bits_res

		; Loop
		dex
		bne remap_one_pixel

	; Restore Y
	pla:tay

	; Store result in registers
	lda low_bits_res
	ldx high_bits_res

	rts
.)

; cpu_to_ppu_copy_tiles_modified's modifier flipping pixels horizontally
;
; Extra side effects
;  Overwrites tmpfield8
modifier_horizontal_flip:
.(
	low_bits = tmpfield6
	high_bits = tmpfield7
	reversed_high_bits = tmpfield8

	ldx #8
	reverse_high_bits:
		asl high_bits
		ror reversed_high_bits
		dex
		bne reverse_high_bits

	ldx #8
	reverse_low_bits:
		asl low_bits
		ror
		dex
		bne reverse_low_bits

	ldx reversed_high_bits

	rts
.)

; Place sprite tiles for a character in PPU memory
;  register X - Player number
;  config_player_a_character, x - Character number
;
; Overwrites register A, register Y, tmpfield1, tmpfield2 and tmpfield3
; May change active bank
place_character_ppu_tiles:
.(
	ldy config_player_a_character, x

; Place sprite tiles for a character in PPU memory
;  register X - Player number
;  register Y - Character number
;  config_player_a_character, x - Character number
;
; Overwrites register A, register Y, tmpfield1, tmpfield2 and tmpfield3
; May change active bank
;
; This variant does not read selected character selected in configuration
&place_character_ppu_tiles_direct:
	SWITCH_BANK(characters_bank_number COMMA y)

	lda PPUSTATUS
	cpx #0
	bne player_b
		lda #>CHARACTERS_CHARACTER_A_TILES_OFFSET
		sta PPUADDR
		lda #<CHARACTERS_CHARACTER_A_TILES_OFFSET
		jmp end_set_ppu_addr
	player_b:
		lda #>CHARACTERS_CHARACTER_B_TILES_OFFSET
		sta PPUADDR
		lda #<CHARACTERS_CHARACTER_B_TILES_OFFSET
	end_set_ppu_addr:
	sta PPUADDR

	lda characters_tiles_data_lsb, y
	sta tmpfield1
	lda characters_tiles_data_msb, y
	sta tmpfield2
	lda characters_tiles_number, y
	sta tmpfield3
	jmp cpu_to_ppu_copy_tiles

	;rts ; useless, jump to subroutine
.)

; wait_next_frame while still ticking music
;
; Overwrites all registers, and some tmpfields and extra_tmpfields (see audio_music_tick)
sleep_frame:
.(
	jsr audio_music_extra_tick
	jsr wait_next_frame
	; Handle PAL emulation while on NTSC by waiting one more frame when needed
	.(
		; Skip if no PAL emulation is requested
		ldx pal_emulation_counter
		bmi ok
			; Count ticks, reset clock and skip frame every 5 ticks
			dex
			bne normal_tick
				skipped_tick:
					ldx #6
					stx pal_emulation_counter
					jsr wait_next_frame
					jmp ok
				normal_tick:
					stx pal_emulation_counter
		ok:
	.)
	jmp audio_music_tick
	; rts ; useless, jump to a subroutine
.)

; Stop rendering, displaying only the backdrop color and allowing to write PPU's register regardless of vblank
;
; Overwrites register A
stop_rendering:
.(
	lda #NMI_AUDIO
	sta nmi_processing
	lda #%10010000
	sta ppuctrl_val
	sta PPUCTRL
	lda #$00
	sta PPUMASK

	rts
.)

; Restart rendring stopped by stop_rendering
; 	A - scroll's nametable
;
; Overwrites register A
start_rendering:
.(
	; Reactivate rendering
	ora #%10010000
	sta ppuctrl_val
	sta PPUCTRL

	; Avoid re-enabling mid-frame (and quit NMI_AUDIO mode)
	jsr wait_next_frame

	; Enable sprites and background rendering
	lda #%00011110
	sta PPUMASK

	rts
.)

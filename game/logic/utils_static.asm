;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Utilities stable enough to be put in static bank
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Construct a nametable buffer to replace palettes
;  tmpfield1,tmpfield2 - new palette data adress (points to 32 bytes to be copied in PPU palettes)
;
;  Overwrites register X, register Y and register A
construct_palettes_nt_buffer:
.(
	palettes_data = tmpfield1

	jsr last_nt_buffer

	lda #1                   ; Continuation byte
	sta nametable_buffers, x ;

	lda #$3f                   ;
	sta nametable_buffers+1, x ; PPU address
	lda #$00                   ;
	sta nametable_buffers+2, x ;

	lda #32                    ; Tiles count
	sta nametable_buffers+3, x ;

	ldy #0                         ;
	copy_one_byte:                 ;
		lda (palettes_data), y     ;
		sta nametable_buffers+4, x ;
								   ; Palettes data
		inx                        ;
		iny                        ;
		cpy #32                    ;
		bne copy_one_byte          ;

	lda #0                     ; Next continuation byte
	sta nametable_buffers+4, x ;

	rts
.)

; Copy a nametable buffer in the process list
;  A - buffer's address LSB
;  Y - buffer's address MSB
;
; Overwrites registers, tmpfield1, tmpfield2, tmpfield3, tmpfield4
push_nt_buffer:
.(
	sta tmpfield1
	clc
	adc #3
	sta tmpfield3
	tya
	sta tmpfield2
	adc #0
	sta tmpfield4
	; Falltrhough to construct_nt_buffer
.)

; Construct a nametable buffer from its header and payload
;  tmpfield1, tmpfield2 - header address
;  tmpfield3, tmpfield4 - payload address
;
;  Overwrites registers, tmpfield1
construct_nt_buffer:
.(
	header = tmpfield1
	payload = tmpfield3
	payload_size = tmpfield1

	jsr last_nt_buffer

	; Continuation byte
	lda #$01
	sta nametable_buffers, x
	inx

	; Header
	ldy #0
	copy_header_byte:
		lda (header), y
		sta nametable_buffers, x
		inx
		iny
		cpy #3
		bne copy_header_byte
	sta payload_size

	; Payload
	ldy #0
	copy_payload_byte:
		lda (payload), y
		sta nametable_buffers, x
		inx
		iny
		cpy payload_size
		bne copy_payload_byte

	; Stop Byte
	lda #$00
	sta nametable_buffers, x

	rts
.)

; Clear background of bottom left nametable
;  Expect the PPU rendering to be disabled
;  Overwrites tmpfield1 and tmpfiled2
clear_bg_bot_left:
.(
	cnt_lsb = tmpfield1
	cnt_msb = tmpfield2

	lda #$00
	sta cnt_lsb
	sta cnt_msb

	lda PPUSTATUS
	lda #$28
	sta PPUADDR
	lda #$00
	sta PPUADDR

	load_background:
		lda #$00
		sta PPUDATA

		inc cnt_lsb
		bne end_inc_vector
			inc cnt_msb
		end_inc_vector:

		lda #$04
		cmp cnt_msb
		bne load_background
		lda #$00
		cmp cnt_lsb ;FIXME useless compare, we exit the loop the first time MSB is equal to $04
		bne load_background

	rts
.)

; Change active PRG-BANK
;  register A - number of the PRG-BANK to activate
; TODO - handle CHR-BANK switching
; See macro with the same name
switch_bank:
.(
#ifdef MAPPER_RAINBOW
	sta current_bank
	sta RAINBOW_PRG_BANKING_1
#else
#ifdef MAPPER_UNROM
	pha
	txa
	pha

	tsx
	lda stack+2, x
	tax
	sta current_bank
	sta bank_table, x

	pla
	tax
	pla
#else
	sta current_bank
	sta $c000
#endif
#endif
	rts
.)

; Execute a routine while another PRG bank is selected
;  extra_tmpfield1, extra_tmpfield2 - routine to execute
;  extra_tmpfield3 - number of the PRG-BANK to activate
;  extra_tmpfield4 - number of the PRG-BANK to return to
;
; Overwrites register A
trampoline:
.(
	lda extra_tmpfield4
	pha
	lda extra_tmpfield3
	jsr switch_bank
	jsr exec
	pla
	jmp switch_bank
	;rts ; useless, jump to subroutine

	exec:
		jmp (extra_tmpfield1)
		;rts ; useless, jump to subroutine
.)

; Copy a tileset from CPU memory to PPU memory
;  tmpfield1, tmpfield2 - Address of the tileset in CPU memory
;
; PPUCTRL's I bit should not be set (if set, writes every 32 bytes)
;
; Overwrites register A, register Y, tmpfield1, tmpfield2 and tmpfield3
cpu_to_ppu_copy_tileset_background:
.(
	lda PPUSTATUS
	lda #$10
	sta PPUADDR
	lda #$00
	sta PPUADDR

	; Fallthrough to cpu_to_ppu_copy_tileset
.)

; Copy a tileset from CPU memory to PPU memory
;  tmpfield1, tmpfield2 - Address of the tileset in CPU memory
;
; PPUADDR must be set to the destination address
; PPUCTRL's I bit should not be set (if set, writes every 32 bytes)
;
; Overwrites register A, register Y, tmpfield1, tmpfield2 and tmpfield3
cpu_to_ppu_copy_tileset:
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

	; Fallthrough to cpu_to_ppu_copy_tiles
.)

; Copy tiles data from CPU memory to PPU memory
;  tmpfield1, tmpfield2 - Address of CPU data to be copied
;  tmpfield3 - number of tiles to copy (zero means 255)
;
; PPUADDR must be set to the destination address
; PPUCTRL's I bit should not be set (if set, writes every 32 bytes)
;
; Overwrites register A, register Y, tmpfield1, tmpfield2 and tmpfield3
cpu_to_ppu_copy_tiles:
.(
	prg_vector = tmpfield1
	; prg_vector_msb = tmpfield2
	tiles_counter = tmpfield3

	copy_one_tile:
		ldy #0
		copy_one_byte:
			lda (prg_vector), y
			sta PPUDATA

			iny
			cpy #16
			bne copy_one_byte

		lda prg_vector
		clc
		adc #16
		sta prg_vector
		lda prg_vector+1
		adc #0
		sta prg_vector+1

		dec tiles_counter
		bne copy_one_tile

	rts
.)

; Copy a charset from CPU memory to PPU memory
;  tmpfield3, tmpfield4 - Address of the charset in CPU memory
;  register X - Charset colors
;
; Charset colors is binary: zzzz ffbb
;  zzzz - Must be zeros
;  ff   - Foreground color
;  bb   - Background color
;
; PPUADDR must be set to the destination address
; PPUCTRL's I bit should not be set (if set, writes every 32 bytes)
;
; Overwrites register A, register X, register Y, and tmpfield1 to tmpfield7
cpu_to_ppu_copy_charset:
.(
	jump_addr = tmpfield1     ; Not movable, parameters of call_pointed_subroutine
	jump_addr_msb = tmpfield2 ;
	prg_vector = tmpfield3
	prg_vector_msb = tmpfield4
	chars_counter = tmpfield5
	first_line_modifier = tmpfield6
	second_line_modifier = tmpfield7

	; Compute byte modifiers index
	;  First line modifier index is low bit of each color
	;  Second line modifier index is high bit of each color
	;
	;  Modifier index are two bits value, indicating if the resulting bit shall be set for foreground or background
	;  example - fg=1 bg=0 -> %10 -> resulting bit is set if pixel is foreground, but not if background
	txa
	and #%00000001
	sta first_line_modifier
	txa
	and #%00000100
	lsr
	ora first_line_modifier
	sta first_line_modifier

	txa
	and #%00000010
	lsr
	sta second_line_modifier
	txa
	and #%00001000
	lsr
	lsr
	ora second_line_modifier
	sta second_line_modifier

	; Fetch charset size
	ldy #0
	lda (prg_vector), y
	sta chars_counter

	; Compute first character's address
	inc prg_vector
	bne inc_ok
		inc prg_vector_msb
	inc_ok:

	copy_one_char:
		; First bits line
		ldx first_line_modifier
		jsr copy_one_line

		; Second bits line
		ldx second_line_modifier
		jsr copy_one_line


		; Place data pointer on next character
		lda prg_vector
		clc
		adc #8
		sta prg_vector
		bcc ok
			inc prg_vector_msb
		ok:

		; Loop
		dec chars_counter
		bne copy_one_char

	rts

	copy_one_line:
	.(
		; Copy pixels from character data, modifying it to match specified palette indexes
		ldy #0
		copy_one_byte:
			lda bits_modifiers_lsb, x
			sta jump_addr
			lda bits_modifiers_msb, x
			sta jump_addr_msb
			lda (prg_vector), y
			jsr call_pointed_subroutine
			sta PPUDATA

			iny
			cpy #8
			bne copy_one_byte

		rts
	.)

	modifier_force_0:
	.(
		lda #%00000000
		rts
	.)

	modifier_force_1:
	.(
		lda #%11111111
		rts
	.)

	modifier_swap:
	.(
		eor #%11111111
		rts
	.)

	modifier_passthrough = dummy_routine

	bits_modifiers_lsb:
		.byt <modifier_force_0, <modifier_swap, <modifier_passthrough, <modifier_force_1
	bits_modifiers_msb:
		.byt >modifier_force_0, >modifier_swap, >modifier_passthrough, >modifier_force_1
.)

; Fill PPU memory with a single value
;  A - Value to fill with
;  X - Number of bytes to fill
;
; PPUADDR must be set to the destination address
; PPUCTRL's I bit should not be set (if set, writes every 32 bytes)
ppu_fill:
.(
	fill_loop:
		sta PPUDATA
		dex
		bne fill_loop
	rts
.)

; Copy bytes in memory, ensured to be in fixed bank
;  tmpfield1,tmpfield2 - Destination
;  tmpfield3,tmpfield4 - Source
;  tmpfield5 - Number of bytes to copy
;
; Overwrites register A, register Y
fixed_memcpy:
.(
	dest = tmpfield1
	src = tmpfield3
	count = tmpfield5

	ldy count
	copy_one_byte:
		cpy #0
		beq end
		dey

		lda (src), y
		sta (dest), y

		jmp copy_one_byte

	end:
	rts
.)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Super Tilt Bro. specific
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Switch current player
;  register X - Current player number
;  Result is stored in register X
;
; See macro with the same name (capitalized)
switch_selected_player:
.(
	dex
	bpl end
		ldx #1
	end:
	rts
.)

; Change the player's velocity to be closer to a vector
;  X - player number
;  tmpfield1 - Y component of the vector to merge (low byte)
;  tmpfield2 - X component of the vector to merge (low byte)
;  tmpfield3 - Y component of the vector to merge (high byte)
;  tmpfield4 - X component of the vector to merge (high byte)
;  tmpfield5 - Step size
;
; Overwrites register Y, tmpfield8 and tmpfield9
merge_to_player_velocity:
.(
	merged_components_lows = tmpfield1
	merged_components_highs = tmpfield3
	step_size = tmpfield5

	; Count iterations, one per vector's component
	ldy #$00

	add_component:
		; Avoid to pass through merged velocity
		lda player_a_velocity_v_low, x ;
		sec                            ;
		sbc merged_components_lows, y  ; Get difference between player's velocity
		sta tmpfield8                  ; component and merged component
		lda player_a_velocity_v, x     ;
		sbc merged_components_highs, y ;

		bpl check_diff                 ;
		eor #%11111111                 ;
		sta tmpfield9                  ;
		lda tmpfield8                  ;
		eor #%11111111                 ; Make the difference absolute
		clc                            ;
		adc #$01                       ;
		sta tmpfield8                  ;
		lda #$00                       ;
		adc tmpfield9                  ;

		check_diff:                    ;
		cmp #$00                       ; Go add step_size if the difference is superior
		bne add_step_size              ; (or equal) than step_size
		lda tmpfield8                  ;
		cmp step_size                  ; Note - diference is in register A (high byte)
		bcs add_step_size              ; and tmpfield8 (low byte). tmpfield9 is garbage.

		lda merged_components_lows, y  ;
		sta player_a_velocity_v_low, x ; Rewrite player velocity's component with merged
		lda merged_components_highs, y ; and got to next component
		sta player_a_velocity_v, x     ;
		jmp next_component             ;

	; Add or substract step size from velocity component to be closer to
	; the merged component
	add_step_size:
		; Compare the merged vector to the current velocity
		SIGNED_CMP(player_a_velocity_v_low COMMA x, player_a_velocity_v COMMA x, merged_components_lows COMMA y, merged_components_highs COMMA y)
		bpl decrement

			; Add step_size to velocity
			lda step_size
			clc
			adc player_a_velocity_v_low, x
			sta player_a_velocity_v_low, x
			lda #$00
			adc player_a_velocity_v, x
			sta player_a_velocity_v, x
			jmp next_component

		decrement:
			; Substract step_size from velocity
			lda player_a_velocity_v_low, x
			sec
			sbc step_size
			sta player_a_velocity_v_low, x
			lda player_a_velocity_v, x
			sbc #$00
			sta player_a_velocity_v, x

	; Handle next component
	next_component:
		inx
		inx
		iny
		cpy #$02
		bne add_component
		dex
		dex
		dex
		dex

	rts
.)

; Apply the standard gravity effect to a player
;  register X - player number
;
; Overwrites register Y, tmpfield6, tmpfield7, tmpfield8 and tmpfield9
apply_player_gravity:
.(
	lda player_a_velocity_h_low, x
	sta tmpfield2
	lda player_a_velocity_h, x
	sta tmpfield4
	lda player_a_gravity_lsb, x
	sta tmpfield1
	lda player_a_gravity_msb, x
	sta tmpfield3
	ldy system_index
	lda gravity_step, y
	sta tmpfield5
	jsr merge_to_player_velocity

	rts

	acceleration_table($60, gravity_step)
.)

; Reset one player's gravity to the default
;  register X - player number
;
; Overwrites register Y
reset_default_gravity:
.(
	ldy system_index
	lda default_gravity_per_system_lsb, y
	sta player_a_gravity_lsb, x
	lda default_gravity_per_system_msb, y
	sta player_a_gravity_msb, x
	rts
.)

; Check if a point is in a specific platform
;  register Y - platform offset from stage_data
;  tmpfield3 - point x lsb
;  tmpfield4 - point y lsb
;  tmpfield5 - point x msb
;  tmpfield6 - point y msb
;
; Sets Y register to $ff if point is in platform, else keep it unmodified
;
; Compatible with stage_iterate_all_elements routine
;
; Note, it consideres the collision line to be outside of the platform (as characters can move on it)
;
; Ovewrites Register A and register Y
check_in_platform:
.(
	;tmpfield1 - reserved, stage_iterate_all_elements forbids to modify it
	;tmpfield2 - reserved, stage_iterate_all_elements forbids to modify it
	point_x_lsb = tmpfield3
	point_y_lsb = tmpfield4
	point_x_msb = tmpfield5
	point_y_msb = tmpfield6

	.(
		lda stage_data, y
		cmp #STAGE_ELEMENT_PLATFORM
		beq simple_platform_handler
		cmp #STAGE_ELEMENT_OOS_PLATFORM
		beq oos_platform_handler
		rts
	.)

	simple_platform_handler:
	.(
		; Check that point is not out of screen
		lda point_x_msb
		bne not_in_platform
		lda point_y_msb
		bne not_in_platform

			; Not in platform if on the left of left edge
			lda stage_data+STAGE_PLATFORM_OFFSET_LEFT, y
			cmp point_x_lsb
			bcs not_in_platform
			end_left_edge:

			; Not in platform if on the right of right edge
			lda point_x_lsb
			cmp stage_data+STAGE_PLATFORM_OFFSET_RIGHT, y
			bcs not_in_platform
			end_right_edge:

			; Not in platform if above top edge
			lda stage_data+STAGE_PLATFORM_OFFSET_TOP, y
			cmp point_y_lsb
			bcs not_in_platform
			end_top_edge:

			; Not in platform if under bottom edge
			lda point_y_lsb
			cmp stage_data+STAGE_PLATFORM_OFFSET_BOTTOM, y
			bcs not_in_platform
			end_bottom_edge:

				; All checks failed, the point is in the platform
				;jmp in_platform ; useless, fallthrough

		in_platform:
			ldy #$ff
			;rts ; useless, fallthrough

		not_in_platform:
			rts
	.)

#define WORD_EQ(eq_lbl, a_lsb, a_msb, b_lsb, b_msb) .(:\
	lda a_lsb:\
	cmp b_lsb:\
	bne not_eq:\
		lda a_msb:\
		cmp b_msb:\
		beq eq_lbl:\
	not_eq:\
.)

	oos_platform_handler:
	.(
		; Not in platform if on the left of left edge
		SIGNED_CMP(point_x_lsb, point_x_msb, stage_data+STAGE_OOS_PLATFORM_OFFSET_LEFT_LSB COMMA y, stage_data+STAGE_OOS_PLATFORM_OFFSET_LEFT_MSB COMMA y)
		bmi not_in_platform
		WORD_EQ(not_in_platform, point_x_lsb, point_x_msb, stage_data+STAGE_OOS_PLATFORM_OFFSET_LEFT_LSB COMMA y, stage_data+STAGE_OOS_PLATFORM_OFFSET_LEFT_MSB COMMA y)

		; Not in platform if on the right of right edge
		SIGNED_CMP(stage_data+STAGE_OOS_PLATFORM_OFFSET_RIGHT_LSB COMMA y, stage_data+STAGE_OOS_PLATFORM_OFFSET_RIGHT_MSB COMMA y, point_x_lsb, point_x_msb)
		bmi not_in_platform
		WORD_EQ(not_in_platform, stage_data+STAGE_OOS_PLATFORM_OFFSET_RIGHT_LSB COMMA y, stage_data+STAGE_OOS_PLATFORM_OFFSET_RIGHT_MSB COMMA y, point_x_lsb, point_x_msb)

		; Not in platform if above top edge
		SIGNED_CMP(point_y_lsb, point_y_msb, stage_data+STAGE_OOS_PLATFORM_OFFSET_TOP_LSB COMMA y, stage_data+STAGE_OOS_PLATFORM_OFFSET_TOP_MSB COMMA y)
		bmi not_in_platform
		WORD_EQ(not_in_platform, point_y_lsb, point_y_msb, stage_data+STAGE_OOS_PLATFORM_OFFSET_TOP_LSB COMMA y, stage_data+STAGE_OOS_PLATFORM_OFFSET_TOP_MSB COMMA y)

		; Not in platform if under bottom edge
		SIGNED_CMP(stage_data+STAGE_OOS_PLATFORM_OFFSET_BOTTOM_LSB COMMA y, stage_data+STAGE_OOS_PLATFORM_OFFSET_BOTTOM_MSB COMMA y, point_y_lsb, point_y_msb)
		bmi not_in_platform
		WORD_EQ(not_in_platform, stage_data+STAGE_OOS_PLATFORM_OFFSET_BOTTOM_LSB COMMA y, stage_data+STAGE_OOS_PLATFORM_OFFSET_BOTTOM_MSB COMMA y, point_y_lsb, point_y_msb)

			; All checks failed, the point is in the platform
			;jmp in_platform ; useless, fallthrough

		in_platform:
			ldy #$ff
			;rts ; useless, fallthrough

		not_in_platform:
			rts
	.)
.)

; Jump to a callback according to player's controller state
;  X - Player number
;  tmpfield1 - Callbacks table (high byte)
;  tmpfield2 - Callbacks table (low byte)
;  tmpfield3 - number of states in the callbacks table
;
;  Overwrites register Y, tmpfield4, tmpfield5 and tmpfield6
;
;  Note - The callback is called with jmp, controller_callbacks never
;         returns using rts.
controller_callbacks:
.(
	lda controller_a_btns, x
	; Fallthrough to switch_linear
.)

; Jump to a callback according to value in register A (linear complexity)
;  A - Value to check
;  tmpfield1 - Callbacks table (high byte)
;  tmpfield2 - Callbacks table (low byte)
;  tmpfield3 - number of states in the callbacks table
;
;  Overwrites register Y, tmpfield4, tmpfield5 and tmpfield6
;
;  Note - The callback is called with jmp, controller_callbacks never
;         returns using rts.
switch_linear:
.(
	callbacks_table = tmpfield1
	num_states = tmpfield3
	callback_addr = tmpfield4
	matching_index = tmpfield6

	; Initialize loop, Y on first element and A on controller's state
	ldy #$00

	check_controller_state:
		; Compare controller state to the current table element
		cmp (callbacks_table), y
		bne next_controller_state

			; Store the low byte of the callback address
			tya                ;
			sta matching_index ; Save Y, it contains the index of the matching entry
			clc                       ;
			adc num_states            ;
			tay                       ; low_byte = callbacks_table[y + num_states]
			lda (callbacks_table), y  ;
			sta callback_addr         ;

			; Store the high byte of the callback address
			tya                       ;
			clc                       ;
			adc num_states            ; high_byte = callbacks_table[matching_index + num_states * 2]
			tay                       ;
			lda (callbacks_table), y  ;
			sta callback_addr+1       ;

			; Controller state is current element, jump to the callback
			jmp (callback_addr)

		next_controller_state:
			; Check next element on the state table
			iny
			cpy num_states
			bne check_controller_state

	; The state was not listed on the table, call the default callback at table's end
	tya            ;
	asl            ;
	clc            ; Y = num_states * 3
	adc num_states ;
	tay            ;
	lda (callbacks_table), y ;
	sta callback_addr        ;
	iny                      ; Store default callback address
	lda (callbacks_table), y ;
	sta callback_addr+1      ;
	jmp (callback_addr) ; Jump to stored address
.)

; Clear the virtual stack used by C code
;
; Overwrite register A
reinit_c_stack:
.(
	lda #<c_stack_end
	sta _sp0
	lda #>c_stack_end
	sta _sp1
	rts
.)

; Wait for the begining of VBI (skipping the one in progress if any)
wait_vbi:
.(
	bit PPUSTATUS
	vblankwait:
		bit PPUSTATUS
		bpl vblankwait
	rts
.)

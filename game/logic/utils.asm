;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Candidates for inclusion in nine-gine
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

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
	cmp cnt_lsb
	bne load_background

	rts
.)

; Change active PRG-BANK
;  register A - number of the PRG-BANK to activate
; TODO - handle CHR-BANK switching
; TODO - handle bus conflict (which can be turned of at compile time to avoid to store the big table)
; See macro with the same name
switch_bank:
.(
	sta $c000
	rts
.)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Super Tilt Bro. specific
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Switch current player
;  register X - Current player number
;  Result is stored in register X
switch_selected_player:
.(
	cpx #$00
	beq select_player_b
	dex
	jmp end
	select_player_b:
	inx
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
; Overwrites register Y, tmpfield6, tmpfield7, tmpfield8 and tmpfield9
merge_to_player_velocity:
.(
	merged_components_lows = tmpfield1
	merged_components_highs = tmpfield3
	step_size = tmpfield5
	player_velocity_low = tmpfield6
	player_velocity_high = tmpfield7
	current_component_low = tmpfield8
	current_component_high = tmpfield9

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
		lda player_a_velocity_v_low, x ;
		sta player_velocity_low        ;
		lda player_a_velocity_v, x     ;
		sta player_velocity_high       ;
		lda merged_components_lows, y  ; Compare the merged vector to the current velocity
		sta current_component_low      ;
		lda merged_components_highs, y ;
		sta current_component_high     ;
		jsr signed_cmp                 ;
		bpl decrement                  ;

			lda step_size                  ;
			clc                            ;
			adc player_a_velocity_v_low, x ;
			sta player_a_velocity_v_low, x ; Add step_size to velocity
			lda #$00                       ;
			adc player_a_velocity_v, x     ;
			sta player_a_velocity_v, x     ;
			jmp next_component

		decrement:
			lda player_a_velocity_v_low, x ;
			sec                            ;
			sbc step_size                  ;
			sta player_a_velocity_v_low, x ; Substract step_size from velocity
			lda player_a_velocity_v, x     ;
			sbc #$00                       ;
			sta player_a_velocity_v, x     ;

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
apply_player_gravity:
.(
	lda player_a_velocity_h_low, x
	sta tmpfield2
	lda player_a_velocity_h, x
	sta tmpfield4
	lda #$00
	sta tmpfield1
	lda player_a_gravity, x
	sta tmpfield3
	lda #$60
	sta tmpfield5
	jsr merge_to_player_velocity

	rts
.)

; Check if the player is on ground
;  register X - Player number
;
; Sets Z flag if on ground, else unset it
;
; Overwrites register A, register Y and tmpfields 1 to 6
check_on_ground:
.(
	platform_left = tmpfield1 ; Not movable - parameter of check_on_platform
	platform_right = tmpfield2 ; Not movable - parameter of check_on_platform
	platform_top = tmpfield3 ; Not movable - parameter of check_on_platform

	platform_left_lsb = tmpfield1 ; Not movable - parameter of check_on_platform_multi_screen
	platform_right_lsb = tmpfield2 ; Not movable - parameter of check_on_platform_multi_screen
	platform_top_lsb = tmpfield3 ; Not movable - parameter of check_on_platform_multi_screen
	platform_left_msb = tmpfield4 ; Not movable - parameter of check_on_platform_multi_screen
	platform_right_msb = tmpfield5 ; Not movable - parameter of check_on_platform_multi_screen
	platform_top_msb = tmpfield6 ; Not movable - parameter of check_on_platform_multi_screen

	platform_handler_lsb = tmpfield1 ; Not movable - parameter of stage_iterate_all_elements
	platform_handler_msb = tmpfield2 ; Not movable - parameter of stage_iterate_all_elements

	; Iterate on platforms until we find on onn which the player is
	lda #<check_current_platform
	sta platform_handler_lsb
	lda #>check_current_platform
	sta platform_handler_msb
	jsr stage_iterate_all_elements

	; Set Z flag if a grounded platform was found
	cpy #$ff

	rts

	check_current_platform:
	.(
		; Save action vector as it stage_iterate_all_elements forbids to modify it and it collides with check_on_platform parameters
		lda tmpfield1
		pha
		lda tmpfield2
		pha

		; Save Y value as stage_iterate_all_elements forbids to modify it if not to stop iterating
		tya
		pha

		; Call appropriate platform handler
		lda stage_data, y
		cmp #STAGE_ELEMENT_OOS_PLATFORM
		bcs oos_platform
			jsr check_simple_platform
			jmp end_platform_handler
		oos_platform:
			jsr check_oos_platform
		end_platform_handler:

		; Act according to handler's result
		bne not_grounded

		grounded:
			; Stop iterating, we found the platform on which we are grounded
			pla
			ldy #$ff
			jmp end_current_platform

		not_grounded:
			; Continue iterating, restore original Y value and fallthrough to end_current_platform
			pla
			tay

		end_current_platform:
			; Restore action vector
			pla
			sta tmpfield2
			pla
			sta tmpfield1

		rts
	.)

	check_simple_platform:
	.(
		; Check if player is is grounded on this platform
		lda stage_data+STAGE_PLATFORM_OFFSET_LEFT, y
		sta platform_left
		lda stage_data+STAGE_PLATFORM_OFFSET_RIGHT, y
		sta platform_right
		lda stage_data+STAGE_PLATFORM_OFFSET_TOP, y
		sta platform_top
		jmp check_on_platform
		;rts ; useless, check_on_platform is a routine
	.)

	check_oos_platform:
	.(
		; Check if player is is grounded on this platform
		lda stage_data+STAGE_OOS_PLATFORM_OFFSET_LEFT_LSB, y
		sta platform_left_lsb
		lda stage_data+STAGE_OOS_PLATFORM_OFFSET_RIGHT_LSB, y
		sta platform_right_lsb
		lda stage_data+STAGE_OOS_PLATFORM_OFFSET_TOP_LSB, y
		sta platform_top_lsb
		lda stage_data+STAGE_OOS_PLATFORM_OFFSET_LEFT_MSB, y
		sta platform_left_msb
		lda stage_data+STAGE_OOS_PLATFORM_OFFSET_RIGHT_MSB, y
		sta platform_right_msb
		lda stage_data+STAGE_OOS_PLATFORM_OFFSET_TOP_MSB, y
		sta platform_top_msb
		jmp check_on_platform_multi_screen
		;rts ; useless, check_on_platform is a routine
	.)
.)

; Check if the player is grounded on a specific platform
;  register X - Player number
;  tmpfield1 - platform left
;  tmpfield2 - platform right
;  tmpfield3 - platform top
;
; Sets Z flag if on ground, else unset it
;
; Ovewrites register A, tmpfield1, tmpfield2 and tmpfield3
check_on_platform:
; Player cannot be on ground if not in the main screen (platforms use one byte unsigned positions)
.(
	; Check that player is not out of screen
	lda player_a_x_screen, x
	bne offscreen
	lda player_a_y_screen, x
	bne offscreen
	jmp check_on_platform_screen_unsafe ; Fallthrough to the screen-unsafe version of this routine

	offscreen:
		; Comming here by "bne" ensure that Z flag is not set, simply return
		rts
.)

; Check if the player is grounded on a specific platform, but do not check for out-of-screen players
;  register X - Player number
;  tmpfield1 - platform left
;  tmpfield2 - platform right
;  tmpfield3 - platform top
;
; Sets Z flag if on ground, else unset it
;
; Ovewrites register A, tmpfield1, tmpfield2 and tmpfield3
check_on_platform_screen_unsafe:
.(
	platform_left = tmpfield1
	platform_right = tmpfield2
	platform_top = tmpfield3

	lda player_a_x, x ;
	dec platform_left ; if (X < platform_left - 1) then offground
	cmp platform_left ;
	bcc offground     ;
	inc platform_right ;
	lda platform_right ; if (platform_right + 1 < X) then offground
	cmp player_a_x, x  ;
	bcc offground      ;
	lda player_a_y, x ;
	dec platform_top  ; if (Y != platform_top - 1) then offground
	cmp platform_top  ;
	bne offground     ;
	lda player_a_y_low, x ; To be onground, the character has to be on the bottom
	cmp #$ff              ; subpixel of the (Y ground pixel - 1)
	;bne offground ; useless as we do nothing anyway

	; Z flag is already set if on ground (ensured by passing the last "bne")
	; Z flag is already unset if off gound (ensured by "bcc" and "bne")
	;  So there is nothing more to do
	offground:

	end:
	rts
.)

; Check if the player is grounded on a specific multi-screen platform
;  register X - Player number
;  tmpfield1 - platform left lsb
;  tmpfield2 - platform right lsb
;  tmpfield3 - platform top lsb
;  tmpfield4 - platform left msb
;  tmpfield5 - platform right msb
;  tmpfield6 - platform top msb
;
; Sets Z flag if on ground, else unset it
;
; Ovewrites register A, tmpfield1, tmpfield2 and tmpfield3
check_on_platform_multi_screen:
.(
	platform_left_lsb = tmpfield1
	platform_right_lsb = tmpfield2
	platform_top_lsb = tmpfield3
	platform_left_msb = tmpfield4
	platform_right_msb = tmpfield5
	platform_top_msb = tmpfield6

#define DEC_16(lsb,msb) .(:\
	dec lsb:\
	bne dec_16_ok:\
	dec msb:\
	dec_16_ok:\
.)

#define INC_16(lsb,msb) .(:\
	inc lsb:\
	bne inc_16_ok:\
	inc msb:\
	inc_16_ok:\
.)

	; if (X < platform_left - 1) then offground
	DEC_16(platform_left_lsb, platform_left_msb)
	SIGNED_CMP(player_a_x COMMA x, player_a_x_screen COMMA x, platform_left_lsb, platform_left_msb)
	bmi offground

	; if (platform_right + 1 < X) then offground
	INC_16(platform_right_lsb, platform_right_msb)
	SIGNED_CMP(platform_right_lsb, platform_right_msb, player_a_x COMMA x, player_a_x_screen COMMA x)
	bmi offground

	; if (Y != platform_top - 1) then offground
	DEC_16(platform_top_lsb, platform_top_msb)
	SIGNED_CMP(player_a_y COMMA x, player_a_y_screen COMMA x, platform_top_lsb, platform_top_msb)
	bmi offground

	; To be onground, the character has to be on the bottom subpixel of the (Y ground pixel - 1)
	lda player_a_y_low, x
	cmp #$ff
	bne offground

		; On ground, unset Z flag
		lda #1
		rts

	offground:

		; Offground, set Z flag
		lda #0
		rts
.)

; Copy tiles data from CPU memory to PPU memory
;  tmpfield1, tmpfield2 - Address of CPU data to be copied
;  tmpfield3 - number of tiles to copy
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

; Place sprite tiles for a character in PPU memory
;  register X - Player number
;  config_player_a_character, x - Character number
;
; Overwrites register A, register X, register Y, tmpfield1, tmpfield2 and tmpfield3
; May change active bank
place_character_ppu_tiles:
.(
	ldy config_player_a_character, x

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
	jsr cpu_to_ppu_copy_tiles

	rts
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
	callbacks_table = tmpfield1
	num_states = tmpfield3
	callback_addr = tmpfield4
	matching_index = tmpfield6

	; Initialize loop, Y on first element and A on controller's state
	ldy #$00
	lda controller_a_btns, x

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

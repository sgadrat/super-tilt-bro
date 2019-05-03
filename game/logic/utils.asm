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

; Check if the player is on ground
;  register X - Player number
;
; Sets Z flag if on ground, else unset it
;
; Overwrites register A, register Y, tmpfield1, tmpfield2 and tmpfield3
check_on_ground:
.(
	platfrom_left = tmpfield1 ; Not movable - parameter of check_on_platform
	platform_right = tmpfield2 ; Not movable - parameter of check_on_platform
	platform_top = tmpfield3 ; Not movable - parameter of check_on_platform

	; Player cannot be on ground if not in the main screen (platforms use one byte unsigned positions)
	lda player_a_x_screen, x
	bne offground
	lda player_a_y_screen, x
	bne offground

	; Iterate on platforms until we find on onn which the player is
	ldy #0
	check_current_platform:
		lda stage_data+STAGE_OFFSET_PLATFORMS, y
		beq offground

		lda stage_data+STAGE_OFFSET_PLATFORMS+STAGE_PLATFORM_OFFSET_LEFT, y
		sta tmpfield1
		lda stage_data+STAGE_OFFSET_PLATFORMS+STAGE_PLATFORM_OFFSET_RIGHT, y
		sta tmpfield2
		lda stage_data+STAGE_OFFSET_PLATFORMS+STAGE_PLATFORM_OFFSET_TOP, y
		sta tmpfield3
		jsr check_on_platform_screen_unsafe
		beq end

		lda stage_data+STAGE_OFFSET_PLATFORMS, y
		cmp #$01
		beq skip_solid_platform

			tya
			clc
			adc #STAGE_SMOOTH_PLATFORM_LENGTH
			tay
			jmp check_current_platform

		skip_solid_platform:
			tya
			clc
			adc #STAGE_PLATFORM_LENGTH
			tay
			jmp check_current_platform

	offground:
		lda #1 ; unset Z flag

	end:
		rts
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

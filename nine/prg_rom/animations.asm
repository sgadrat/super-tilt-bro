;
; State format
;   Byte 0 - X lsb
;   Byte 1 - X msb
;   Byte 2 - Y lsb
;   Byte 3 - Y msb
;   Byte 4-5 - vector to animation data
;   Byte 6 - direction of the animation (0 - natural, 1 - horizontally flipped)
;   Byte 7 - tick number
;   Byte 8 - index of the first OAM sprite to use
;   Byte 9 - index of the last OAM sprite to use
;   Byte 10-11 - index of the current frame
;   Byte 12 - virtual frame counter for NTSC systems
;
; Typical workflow
;   Initialization
;     ; ... code initializing other parts of the memory ...
;     lda #<my_animation_state
;     sta tmpfield11
;     lda #>my_animation_state
;     sta tmpfield12
;     lda #<my_animation_data
;     sta tmpfield13
;     lda #>my_animation_data
;     sta tmpfield14
;     jsr animation_init_state
;
;   Game loop
;     ; ... code that updates X, Y position of the animation ...
;     lda #<my_animation_state
;     sta tmpfield11
;     lda #>my_animation_state
;     sta tmpfield12
;     jsr animation_draw
;     jsr animation_tick
;

ANIMATION_NTSC_CNT_RESET_VALUE = 5 ; double every fifth frame

; Initialize a memory location to be a valid animation state
;  tmpfield11, tmpfield12 - vector to the animation state
;  tmpfield13, tmpfield14 - vector to the animation data
; Overwrites registers A and Y
animation_init_state:
.(
	anim_state = tmpfield11
	anim_data = tmpfield13

	; Zero initialize most fields
	lda #0
	ldy #ANIMATION_STATE_OFFSET_X_LSB
	sta (anim_state), y
	ldy #ANIMATION_STATE_OFFSET_X_MSB
	sta (anim_state), y
	ldy #ANIMATION_STATE_OFFSET_Y_LSB
	sta (anim_state), y
	ldy #ANIMATION_STATE_OFFSET_Y_MSB
	sta (anim_state), y
	ldy #ANIMATION_STATE_OFFSET_DIRECTION
	sta (anim_state), y
	ldy #ANIMATION_STATE_OFFSET_CLOCK
	sta (anim_state), y
	ldy #ANIMATION_STATE_OFFSET_FIRST_SPRITE_NUM
	sta (anim_state), y
	ldy #ANIMATION_STATE_OFFSET_LAST_SPRITE_NUM
	sta (anim_state), y

	; Initialize frame vector and data vector to the first frame
	lda anim_data
	ldy #ANIMATION_STATE_OFFSET_DATA_VECTOR_LSB
	sta (anim_state), y
	ldy #ANIMATION_STATE_OFFSET_FRAME_VECTOR_LSB
	sta (anim_state), y

	lda anim_data+1
	ldy #ANIMATION_STATE_OFFSET_DATA_VECTOR_MSB
	sta (anim_state), y
	ldy #ANIMATION_STATE_OFFSET_FRAME_VECTOR_MSB
	sta (anim_state), y

	; Initialize virtual frame counter
	lda #ANIMATION_NTSC_CNT_RESET_VALUE
	ldy #ANIMATION_STATE_OFFSET_NTSC_CNT
	sta (anim_state), y

	rts
.)

; Modify the animation playing in an animation state
;  tmpfield11, tmpfield12 - vector to the animation state
;  tmpfield13, tmpfield14 - vector to the animation data
; Overwrites registers A and Y
animation_state_change_animation:
.(
	anim_state = tmpfield11
	anim_data = tmpfield13

	; Reset clock
	lda #0
	ldy #ANIMATION_STATE_OFFSET_CLOCK
	sta (anim_state), y

	; Set frame vector and data vector to new animation's first frame
	lda anim_data
	ldy #ANIMATION_STATE_OFFSET_DATA_VECTOR_LSB
	sta (anim_state), y
	ldy #ANIMATION_STATE_OFFSET_FRAME_VECTOR_LSB
	sta (anim_state), y

	lda anim_data+1
	ldy #ANIMATION_STATE_OFFSET_DATA_VECTOR_MSB
	sta (anim_state), y
	ldy #ANIMATION_STATE_OFFSET_FRAME_VECTOR_MSB
	sta (anim_state), y

	; Reinitialize virtual frame counter
	lda #ANIMATION_NTSC_CNT_RESET_VALUE
	ldy #ANIMATION_STATE_OFFSET_NTSC_CNT
	sta (anim_state), y

	rts
.)

; Draw the current frame of an animation
;  tmpfield11, tmpfield12 - vector to the animation_state
; Overwrites tmpfields 1 to 10, tmpfields 13 to 16 and all registers
animation_draw:
.(
	animation_position_x = tmpfield1
	animation_position_x_msb = tmpfield2
	animation_position_y = tmpfield3
	animation_position_y_msb = tmpfield4
	frame_vector = tmpfield5
	frame_vector_msb = tmpfield6
	first_sprite_index = tmpfield7
	last_sprite_index = tmpfield8
	animation_direction = tmpfield9
	sprite_count = tmpfield10
	anim_state = tmpfield11
	anim_state_lsb = tmpfield12
	sign_extension_byte = tmpfield13
	attributes_modifier = tmpfield14
	sprite_direction = tmpfield15 ; 0 - first OAM sprite to last, 1 - last OAM sprite to first


	; Copy animation state info in fixed location
	.(
		ldy #ANIMATION_STATE_OFFSET_X_LSB
		lda (anim_state), y
		sta animation_position_x
		iny
		lda (anim_state), y
		sta animation_position_x+1

		ldy #ANIMATION_STATE_OFFSET_Y_LSB
		lda (anim_state), y
		sta animation_position_y
		iny
		lda (anim_state), y
		sta animation_position_y+1

		ldy #ANIMATION_STATE_OFFSET_FRAME_VECTOR_LSB
		lda (anim_state), y
		sta frame_vector
		iny
		lda (anim_state), y
		sta frame_vector+1

		ldy #ANIMATION_STATE_OFFSET_DIRECTION
		lda (anim_state), y
		sta animation_direction

+animation_draw_pre_initialized:

		ldy #ANIMATION_STATE_OFFSET_FIRST_SPRITE_NUM
		lda (anim_state), y
		sta first_sprite_index
		ldy #ANIMATION_STATE_OFFSET_LAST_SPRITE_NUM
		lda (anim_state), y
		sta last_sprite_index
	.)

	; Place sprites
	.(
		; Compute direction dependent information
		;  attributes modifier - to flip the animation if needed
		.(
			lda animation_direction
			beq default_direction
				; Flip horizontally attributes
				lda #$40
				sta attributes_modifier
				jmp ok
			default_direction:
				; Do not flip attributes
				lda #$00
				sta attributes_modifier
			ok:
		.)

		; Read foreground sprites count
		ldy #ANIMATION_FRAME_SPRITES_BEGIN
		lda (frame_vector), y
		iny
		cmp #0
		beq end_foreground_sprites
			sta sprite_count

			; First sprite to modify
			lda first_sprite_index
			asl
			asl
			tax

			; Update first_sprite_index to reflect sprites usage
			lda first_sprite_index
			clc
			adc sprite_count
			sta first_sprite_index

			; OAM address change between sprites
			lda #4
			sta sprite_direction

			; Update OAM from frame sprites
			jsr animation_handle_sprites
		end_foreground_sprites:

		; Read normal sprites count
		lda (frame_vector), y
		beq end_place_sprites
			sta sprite_count
			iny

			; Direction dependent information
			.(
				lda animation_direction
				beq default_direction
					; First sprite to modify
					lda last_sprite_index
					asl
					asl
					tax

					; Update last_sprite_index to reflect sprites usage
					lda last_sprite_index
					sec
					sbc sprite_count
					sta last_sprite_index

					; OAM address change between sprites
					lda #$fc
					jmp ok
				default_direction:
					; Sprite to modify
					lda first_sprite_index
					asl
					asl
					tax

					; Update first_sprite_index to reflect sprites usage
					lda first_sprite_index
					clc
					adc sprite_count
					sta first_sprite_index

					; OAM address change between sprites
					lda #4
				ok:
				sta sprite_direction
			.)

			jsr animation_handle_sprites
		end_place_sprites:
	.)

	; Place unused sprites off screen
	.(
		clear_unused_sprites:
			; Y = number of sprites to hide
			inc last_sprite_index
			lda last_sprite_index
			sec
			sbc first_sprite_index
			beq end ; Skip if there is no sprite to hide
			tay

			; X = OAM index of the first sprite to hide
			lda first_sprite_index
			asl
			asl
			tax

			; Hide sprites
			lda #$fe
			clear_one_unused_sprite:
				sta oam_mirror, x
				inx
				inx
				inx
				inx
				dey
				bne clear_one_unused_sprite

		end:
	.)

	rts

	; Place sprites from a list to OAM mirror
	;  register X - offset of first sprite to update in OAM mirror
	;  register Y - offset of first sprite to place, from (frame_vector)
	;  frame_vector - vector to sprites list
	;  animation_position_y
	;  animation_position_y_msb
	;  animation_position_x
	;  animation_position_x_msb
	;  animation_direction
	;  attributes_modifier
	;  sprite_direction - offset between sprites in OAM mirror (typically, 4 - forward, -4 - backward)
	;  sprite_count - number of sprites to place
	;
	; Note - Must not be called for zero sprites (sprite_count == 0 -> undefined behavior)
	;
	; Overwrites all registers, sign_extension_byte, sprite_count
	+animation_handle_sprites:
	.(
		; Y value, must be relative to animation Y position (avoid to place this sprite if offscreen)
		lda (frame_vector), y

		.(
			pha ;TODO zeropage location instead of stack to save cycles
			bmi set_relative_msb_neg
				lda #0
				jmp set_relative_msb
			set_relative_msb_neg:
				lda #$ff
			set_relative_msb:
				sta sign_extension_byte
			pla
		.)

		clc
		adc animation_position_y
		sta oam_mirror, x
		lda sign_extension_byte
		adc animation_position_y_msb
		bne skip
		iny

		; Tile number
#ifdef ANIM_HOOK_TILE_NUMBER
		ANIM_HOOK_TILE_NUMBER
#else
		lda (frame_vector), y
#endif
		sta oam_mirror+1, x
		iny

		; Attributes
		;  Flip horizontally (eor $40) if oriented to the right
#ifdef ANIM_HOOK_SPRITE_ATTRIBUTES
		ANIM_HOOK_SPRITE_ATTRIBUTES
#else
		lda (frame_vector), y
#endif
		eor attributes_modifier
		sta oam_mirror+2, x
		iny

		; X value, must be relative to animation X position
		;  Flip symetrically to the vertical axe if needed
		lda animation_direction
		bne flip_x
			lda (frame_vector), y
			jmp got_relative_pos
		flip_x:
			lda (frame_vector), y
			eor #%11111111
			clc
			adc #1
		got_relative_pos:

		.(
			pha ;TODO zeropage location instead of stack to save cycles
			bmi set_relative_msb_neg
				lda #0
				jmp set_relative_msb
			set_relative_msb_neg:
				lda #$ff
			set_relative_msb:
				sta sign_extension_byte
			pla
		.)

		clc
		adc animation_position_x
		sta oam_mirror+3, x

		lda sign_extension_byte
		adc animation_position_x_msb
		beq continue
			; Sprite is offscreen, erase it
			jmp skip2
		continue:
		iny

		; Loop
		loop:
			; Point to next oam sprite
			txa
			clc
			adc sprite_direction
			tax

			; Loop
			dec sprite_count
			bne animation_handle_sprites

			rts

		; Skip sprite
		skip:
			; Advance to the next frame's sprite
			iny
			iny
			iny
		skip2:
			iny

			; Reset OAM sprite's Y position
			lda #$fe
			sta oam_mirror, x

			; Loop
			jmp loop
	.)
.)

; Advance animation's clock
;  tmpfield11, tmpfield12 - vector to the animation_state
; Overwrites all registers, tmpfield3, tmpfield4, and tmpfield8
animation_tick:
.(
	anim_state = tmpfield11
	;tmpfield12 is anim_state MSB
	frame_vector = tmpfield3
	;tmpfield4 is frame_vector MSB
	frame_length = tmpfield8

	; On NTSC, do nothing every six frames to simulate PAL's pace
	;  Note This must stay deterministic, so NTSC frame data is still stable
	;  Note Beware of the logic for doubling fifth frame, not the sixth. It allows to double the last frame of an animation without looping for one frame.
	.(
		ldy system_index
		beq skip
			ldy #ANIMATION_STATE_OFFSET_NTSC_CNT
			lda (anim_state), y
			sec
			sbc #1
			bmi reset_cnt
			bne ok
			skip_tick:
				sta (anim_state), y
				rts
			reset_cnt:
				lda #ANIMATION_NTSC_CNT_RESET_VALUE
			ok:
			sta (anim_state), y
		skip:
	.)

	; Store current frame vector at a fixed location
	ldy #ANIMATION_STATE_OFFSET_FRAME_VECTOR_LSB
	lda (anim_state), y
	sta frame_vector
	iny
	lda (anim_state), y
	sta frame_vector+1

	; Increment counter
	ldy #ANIMATION_STATE_OFFSET_CLOCK
	lda (anim_state), y
	clc
	adc #1
	sta (anim_state), y

	; If counter is above (or equal) frame duration, update current frame vector
	ldy #0
	cmp (frame_vector), y
	bcc end

		; Point to next frame (frame size = sprites_begin + 1 + 4*nb_foreground_sprites + 1 + 4*nb_normal_sprites)
		ldy #ANIMATION_FRAME_SPRITES_BEGIN
		sty frame_length

		lda (frame_vector), y ; Foreground sprites count
		asl
		asl
		;clc
		adc frame_length
		;clc
		adc #1
		sta frame_length

		tay
		lda (frame_vector), y ; Normal sprites count
		asl
		asl
		;clc
		adc frame_length
		;clc
		adc #1

		;clc
		adc frame_vector
		sta frame_vector
		lda #$00
		adc frame_vector+1
		sta frame_vector+1

		; If the next frame begins with zero, it is then ANIM_ANIMATION_END, return to the begining
		;TODO actually place the address of the loop frame after the "zero" contiuation byte
		;      That would allow to
		;      - remove DATA_VECTOR from animation state
		;      - loop on another frame than the first one
		;      - (madness) actually jump to another animation to share frames
		ldy #0
		lda (frame_vector), y
		bne store_frame_vector
			ldy #ANIMATION_STATE_OFFSET_DATA_VECTOR_LSB
			lda (anim_state), y
			sta frame_vector
			iny
			lda (anim_state),y
			sta frame_vector+1

		; Store computed frame vector in animation state
		store_frame_vector:
			ldy #ANIMATION_STATE_OFFSET_FRAME_VECTOR_LSB
			lda frame_vector
			sta (anim_state), y
			iny
			lda frame_vector+1
			sta (anim_state), y

		; Reset tick counter
		ldy #ANIMATION_STATE_OFFSET_CLOCK
		lda #0
		sta (anim_state), y

	end:
		rts
.)

; Wrapper around animation_draw adding support for hitboxes and hurtboxes
;  X - player number
;  player_number - player number
;  tmpfield11,tmpfield12 - animation state address
;
;  Note, player_number and X must have the same value. X is used by this routine, player_number by fetch hooks.
;
; Overwrites tmpfields 1 to 10, tmpfields 13 to 16 and all registers
stb_animation_draw:
.(
	;TODO optimizable, come CLC are not necessary

	; Unmovables, must mirror animation_draw declarations
	animation_position_x = tmpfield1
	animation_position_x_msb = tmpfield2
	animation_position_y = tmpfield3
	animation_position_y_msb = tmpfield4
	frame_vector = tmpfield5
	frame_vector_msb = tmpfield6
	;first_sprite_index = tmpfield7
	;last_sprite_index = tmpfield8
	animation_direction = tmpfield9
	;sprite_count = tmpfield10
	anim_state = tmpfield11
	anim_state_lsb = tmpfield12

	; Locals
	sign_extension_byte = tmpfield13
	first_tick_on_this_frame = tmpfield14 ; 0 - first tick

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

		ldy #ANIMATION_STATE_OFFSET_CLOCK
		lda (anim_state), y
		sta first_tick_on_this_frame
	.)

	; Hurtbox
	.(
		ldy #ANIMATION_FRAME_HURTBOX_BEGIN

		; Load relative values
		;TODO optimizable, these are intermediate values, could be stored in zeropage
		.(
			; Left/right
			.(
				lda animation_direction
				bne flipped

					; Natural animation direction
					; 	Direct copy of animation data
					not_flipped:
						; Left
						lda (frame_vector), y
						sta player_a_hurtbox_left, x
						SIGN_EXTEND()
						sta player_a_hurtbox_left_msb, x
						iny

						; Right
						lda (frame_vector), y
						sta player_a_hurtbox_right, x
						SIGN_EXTEND()
						sta player_a_hurtbox_right_msb, x
						iny

						jmp ok

					; Flipped animation direction
					;  Hurtbox is flipped with 7 pixels offset to compensate
					;  origin point not being in the middle of the metasprite
					;  (not 8 pixels, because boxes boundaries are inclusive)
					flipped:
						; Right = -left + 7
						lda #7
						sec
						sbc (frame_vector), y ; Fetch "left"
						sta player_a_hurtbox_right, x
						SIGN_EXTEND()
						sta player_a_hurtbox_right_msb, x
						iny

						; Left = -right + 7
						lda #7
						sec
						sbc (frame_vector), y ; Fetch "right"
						sta player_a_hurtbox_left, x
						SIGN_EXTEND()
						sta player_a_hurtbox_left_msb, x
						iny

				ok:
			.)

			; Top
			lda (frame_vector), y
			sta player_a_hurtbox_top, x
			SIGN_EXTEND()
			sta player_a_hurtbox_top_msb, x
			iny

			; Bottom
			lda (frame_vector), y
			sta player_a_hurtbox_bottom, x
			SIGN_EXTEND()
			sta player_a_hurtbox_bottom_msb, x
			iny
		.)

		; Apply position offset
		.(
			; Left
			lda player_a_hurtbox_left, x
			clc
			adc animation_position_x
			sta player_a_hurtbox_left, x
			lda player_a_hurtbox_left_msb, x
			adc animation_position_x_msb
			sta player_a_hurtbox_left_msb, x

			; Right
			lda player_a_hurtbox_right, x
			clc
			adc animation_position_x
			sta player_a_hurtbox_right, x
			lda player_a_hurtbox_right_msb, x
			adc animation_position_x_msb
			sta player_a_hurtbox_right_msb, x

			; Top
			lda player_a_hurtbox_top, x
			clc
			adc animation_position_y
			sta player_a_hurtbox_top, x
			lda player_a_hurtbox_top_msb, x
			adc animation_position_y_msb
			sta player_a_hurtbox_top_msb, x

			; Bottom
			lda player_a_hurtbox_bottom, x
			clc
			adc animation_position_y
			sta player_a_hurtbox_bottom, x
			lda player_a_hurtbox_bottom_msb, x
			adc animation_position_y_msb
			sta player_a_hurtbox_bottom_msb, x
		.)
	.)

	; Hitbox
	.(
		; Disable hitbox if there is no hitbox in the frame
		lda (frame_vector), y
		bne fetch_hitbox
			sta player_a_hitbox_enabled, x
			jmp end_hitbox
		fetch_hitbox:
		iny

			; Flippables - left, right, base_h, force_h
			.(
				lda animation_direction
				bne flipped

					; Natural animation direction
					; 	Direct copy of animation data
					not_flipped:
						; Left
						lda (frame_vector), y
						sta player_a_hitbox_left, x
						SIGN_EXTEND()
						sta player_a_hitbox_left_msb, x
						iny

						; Right
						lda (frame_vector), y
						sta player_a_hitbox_right, x
						SIGN_EXTEND()
						sta player_a_hitbox_right_msb, x
						iny

						; Base_h
						lda (frame_vector), y
						sta player_a_hitbox_base_knock_up_h_low, x
						iny
						lda (frame_vector), y
						sta player_a_hitbox_base_knock_up_h_high, x
						iny

						; Force_h
						lda (frame_vector), y
						sta player_a_hitbox_force_h_low, x
						iny

						jmp ok

					; Flipped animation direction
					;  - Hitbox is flipped with 7 pixels offset to compensate
					;  origin point not being in the middle of the metasprite
					;  (not 8 pixels, because boxes boundaries are inclusive)
					;  - Horizontal forces are negated
					flipped:
						; Right = -left + 7
						lda #7
						sec
						sbc (frame_vector), y ; Fetch "left"
						sta player_a_hitbox_right, x
						SIGN_EXTEND()
						sta player_a_hitbox_right_msb, x
						iny

						; Left = -right + 7
						lda #7
						sec
						sbc (frame_vector), y ; Fetch "right"
						sta player_a_hitbox_left, x
						SIGN_EXTEND()
						sta player_a_hitbox_left_msb, x
						iny

						; Base_h = -base_h
						lda (frame_vector), y
						eor #%11111111
						clc
						adc #1
						sta player_a_hitbox_base_knock_up_h_low, x
						iny
						lda (frame_vector), y
						eor #%11111111
						adc #0
						sta player_a_hitbox_base_knock_up_h_high, x
						iny

						; Force_h = -force_h
						lda (frame_vector), y
						eor #%11111111
						clc
						adc #1
						sta player_a_hitbox_force_h_low, x
						iny

				ok:
			.)

			; Hitstun modifier
			lda (frame_vector), y
			sta player_a_hitbox_hitstun, x
			iny

			; Top
			lda (frame_vector), y
			sta player_a_hitbox_top, x
			SIGN_EXTEND()
			sta player_a_hitbox_top_msb, x
			iny

			; Bottom
			lda (frame_vector), y
			sta player_a_hitbox_bottom, x
			SIGN_EXTEND()
			sta player_a_hitbox_bottom_msb, x
			iny

			; Base_v
			lda (frame_vector), y
			sta player_a_hitbox_base_knock_up_v_low, x
			iny
			lda (frame_vector), y
			sta player_a_hitbox_base_knock_up_v_high, x
			iny

			; Force_v
			lda (frame_vector), y
			sta player_a_hitbox_force_v_low, x
			iny

			; Unused
			iny

			; Damage
			lda (frame_vector), y
			sta player_a_hitbox_damages, x
			iny

			; Enabled
			lda first_tick_on_this_frame
			bne ignore_enabled
				lda (frame_vector), y
				beq ignore_enabled
					sta player_a_hitbox_enabled, x
			ignore_enabled:
			iny

			; Apply position offset
			.(
				; Left
				lda player_a_hitbox_left, x
				clc
				adc animation_position_x
				sta player_a_hitbox_left, x
				lda player_a_hitbox_left_msb, x
				adc animation_position_x_msb
				sta player_a_hitbox_left_msb, x

				; Right
				lda player_a_hitbox_right, x
				clc
				adc animation_position_x
				sta player_a_hitbox_right, x
				lda player_a_hitbox_right_msb, x
				adc animation_position_x_msb
				sta player_a_hitbox_right_msb, x

				; Top
				lda player_a_hitbox_top, x
				clc
				adc animation_position_y
				sta player_a_hitbox_top, x
				lda player_a_hitbox_top_msb, x
				adc animation_position_y_msb
				sta player_a_hitbox_top_msb, x

				; Bottom
				lda player_a_hitbox_bottom, x
				clc
				adc animation_position_y
				sta player_a_hitbox_bottom, x
				lda player_a_hitbox_bottom_msb, x
				adc animation_position_y_msb
				sta player_a_hitbox_bottom_msb, x
			.)

		end_hitbox:
	.)

	; Sprites
	lda network_rollback_mode
	bne end
		jmp animation_draw_pre_initialized

	end:
	rts
.)

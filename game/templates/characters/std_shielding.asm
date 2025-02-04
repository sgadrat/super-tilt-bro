.(
	+{char_name}_start_shielding_left:
	.(
		lda #DIRECTION_LEFT2
		jmp {char_name}_start_shielding_directional
	.)
	+{char_name}_start_shielding_right:
	.(
		lda #DIRECTION_RIGHT2
		; Fallthrough to {char_name}_start_shielding_directional
	.)
	{char_name}_start_shielding_directional:
	.(
		sta player_a_direction, x
		; Fallthrough to {char_name}_start_shielding
	.)
	&{char_name}_start_shielding:
	.(
		; Set state
		lda #{char_name_upper}_STATE_SHIELDING
		sta player_a_state, x

		; Reset clock, used for down-tap detection
		ldy system_index
		lda player_down_tap_max_duration, y
		sta player_a_state_clock, x

		; Set the appropriate animation
		lda #<{char_name}_anim_shield_full
		sta tmpfield13
		lda #>{char_name}_anim_shield_full
		sta tmpfield14
		jsr set_player_animation

		; Cancel momentum
		lda #$00
		sta player_a_velocity_h_low, x
		sta player_a_velocity_h, x

		; Set shield as full life
		lda #2
		sta player_a_state_field1, x

		rts
	.)

	&{char_name}_tick_shielding:
	.(
#ifldef {char_name}_global_tick
		jsr {char_name}_global_tick
#endif

		; Tick clock, stop at zero
		lda player_a_state_clock, x
		beq end_tick
			dec player_a_state_clock, x
		end_tick:

		; Apply friction
		jmp {char_name}_apply_ground_friction

		;rts ; useless, jump to subroutine
	.)

	&{char_name}_input_shielding:
	.(
		; Maintain down to stay on shield
		;   Ignore left/right as they are too susceptible to be pressed unvoluntarily on a lot of gamepads
		; During coyote time (same duration as the down tap used to fall from smooth platforms)
		;   Process inputs as in "idle" state (notably eases reverse down-tilt and down-spe)
		; After coyote time
		;   Down-a and down-b are allowed as out of shield moves (ignoring left/right)
		;   Any other combination ends the shield (with shield lag or falling from smooth platform)
		lda controller_a_btns, x
		and #CONTROLLER_BTN_A+CONTROLLER_BTN_B+CONTROLLER_BTN_UP+CONTROLLER_BTN_DOWN
		beq end_shield
		cmp #CONTROLLER_INPUT_TECH
		beq end
		ldy player_a_state_clock, x
		bne handle_input_coyote
		cmp #CONTROLLER_INPUT_DOWN_TILT
		beq handle_input_dtilt
		cmp #CONTROLLER_INPUT_SPECIAL_DOWN
		beq handle_input_dspe

		end_shield:

			lda player_a_state_clock, x
			beq shieldlag
				ldy player_a_grounded, x
				beq shieldlag
					lda stage_data, y
					cmp #STAGE_ELEMENT_PLATFORM
					beq shieldlag
					cmp #STAGE_ELEMENT_OOS_PLATFORM
					beq shieldlag

			fall_from_smooth:
				; HACK - "position = position + 2" to compensate collision system not handling subpixels and "position + 1" being the collision line
				;        actually, "position = position + 3" to compensate for moving platforms that move down
				;        Better solution would be to have an intermediary player state with a specific animation
				clc
				lda player_a_y, x
				adc #3
				sta player_a_y, x
				lda player_a_y_screen, x
				adc #0
				sta player_a_y_screen, x

				jmp {char_name}_start_falling
				; No return, jump to subroutine

			shieldlag:
				jmp {char_name}_start_shieldlag
				; No return, jump to subroutine

		handle_input_dtilt:
			jmp {char_name}_start_down_tilt
			; No return, jump to subroutine

		handle_input_dspe:
			jmp {char_name}_start_spe_down
			; No return, jump to subroutine

		handle_input_coyote:

			jmp {char_name}_input_idle
			; No return, jump to subroutine

		end:
		rts
	.)

	&{char_name}_hurt_shielding:
	.(
		striker_player = tmpfield10
		stroke_player = tmpfield11
		default_behavior_lsb = tmpfield12
		default_behavior_msb = tmpfield13
		default_behavior_bank = tmpfield14

		; Reduce shield's life
		dec player_a_state_field1, x

		; Select what to do according to shield's life
		lda player_a_state_field1, x
		beq limit_shield
		cmp #1
		beq partial_shield

			; Break the shield, derived from normal hurt with:
			;  Knockback * 2
			;  Screen shaking * 4
			;  Special sound
			TRAMPOLINE(default_hurt_player, default_behavior_bank, #CURRENT_BANK_NUMBER)
			ldx stroke_player
			asl player_a_velocity_h_low, x
			rol player_a_velocity_h, x
			asl player_a_velocity_v_low, x
			rol player_a_velocity_v, x
			asl player_a_hitstun, x
			asl screen_shake_counter
			asl screen_shake_counter
			jsr audio_play_shield_break
			jmp end

		partial_shield:
			; Get the animation corresponding to the shield's life
			lda #<{char_name}_anim_shield_partial
			sta tmpfield13
			lda #>{char_name}_anim_shield_partial
			jmp still_shield

		limit_shield:
			; Get the animation corresponding to the shield's life
			lda #<{char_name}_anim_shield_limit
			sta tmpfield13
			lda #>{char_name}_anim_shield_limit

		still_shield:
			; Set the new shield animation
			ldx stroke_player
			sta tmpfield14
			jsr set_player_animation ; Note - overwrites tmpfield10 (stroke_player)

			; Apply pushback, "base_horizontal_knock_up / 2"
			ldy striker_player

			lda player_a_hitbox_base_knock_up_h_high, y
			asl

			lda player_a_hitbox_base_knock_up_h_high, y
			ror
			sta player_a_velocity_h, x
			lda player_a_hitbox_base_knock_up_h_low, y
			ror
			sta player_a_velocity_h_low, x

			; Play sound
			jsr audio_play_shield_hit

			; Hit pause
			lda #SHIELD_HIT_PAUSE_NB_FRAMES
			sta screen_shake_counter
			lda #0
			sta screen_shake_current_x
			sta screen_shake_current_y
			sta screen_shake_noise_h
			sta screen_shake_noise_v

		end:
		; Disable the hitbox to avoid multi-hits
		ldx striker_player
		lda #HITBOX_DISABLED
		sta player_a_hitbox_enabled, x

		rts
	.)
.)

.(
	shieldlag_duration:
		.byt {char_name}_anim_shield_remove_dur_pal, {char_name}_anim_shield_remove_dur_ntsc
	shieldlag_cancellable_time:
		.byt {char_name}_anim_shield_remove_dur_pal / 2, {char_name}_anim_shield_remove_dur_ntsc / 2

	&{char_name}_start_shieldlag:
	.(
		; Set state
		lda #{char_name_upper}_STATE_SHIELDLAG
		sta player_a_state, x

		; Reset clock
		ldy system_index
		lda shieldlag_duration, y
		sta player_a_state_clock, x

		; Set the appropriate animation
		lda #<{char_name}_anim_shield_remove
		sta tmpfield13
		lda #>{char_name}_anim_shield_remove
		sta tmpfield14
		jmp set_player_animation

		;rts ; useless, jump to subroutine
	.)

	&{char_name}_tick_shieldlag:
	.(
#ifldef {char_name}_global_tick
		jsr {char_name}_global_tick
#endif

		dec player_a_state_clock, x
		bne tick
			jmp {char_name}_start_inactive_state
			; No return, jump to subroutine
		tick:
		jmp {char_name}_apply_ground_friction
		;rts ; useless, jump to subroutine
	.)

	&{char_name}_input_shieldlag:
	.(
#ifldef {char_name}_global_tick
		jsr {char_name}_global_tick
#endif

		; Allow to cancel shield lag by a jump
		lda controller_a_btns, x
		cmp #CONTROLLER_INPUT_JUMP
		bne no_jump

		ldy system_index
		lda player_a_state_clock, x
		cmp shieldlag_cancellable_time, y
		bcs no_jump

			jmp {char_name}_start_jumping
			; No return, jump to subroutine

		no_jump:

		jmp smart_keep_input_dirty
		;rts ; useless, jump to subroutine
	.)
.)

pepper_ai_attack_selector:
.(
	; Do not try to attack in incapacited states, it would ruin ai reactivity after such states
	lda player_b_state
	cmp #PEPPER_STATE_CRASHING
	beq end
	cmp #PEPPER_STATE_HYPERSPEED_CRASHING
	beq end
		jmp ai_attack_selector
		; No return, jump to subroutine
	end:
	rts
.)

pepper_ai_recover_selector:
.(
	platform_handler_lsb = tmpfield1
	platform_handler_msb = tmpfield2
	endangered = tmpfield3
	best_platform = tmpfield4
	;tmpfield5 used by platform handler

	.(
		; Skip everything if the player is grounded
		lda player_b_grounded
		bne dont_try_to_recover

		; Check that the player is offstage - no platform behind him
		lda #1
		sta endangered
		lda #0
		sta best_platform

		lda #<platform_handler
		sta platform_handler_lsb
		lda #>platform_handler
		sta platform_handler_msb
		jsr stage_iterate_all_elements

		lda endangered
		bne try_to_recover

		dont_try_to_recover:
			jmp end

		try_to_recover:
			; Set action modifier to the platform's direction
			lda #CONTROLLER_BTN_RIGHT
			sta ai_current_action_modifier
			ldy best_platform
			SIGNED_CMP(player_b_x, player_b_x_screen, stage_data+STAGE_PLATFORM_OFFSET_RIGHT COMMA y, #0)
			bmi direction_set
			lda #CONTROLLER_BTN_LEFT
			sta ai_current_action_modifier
			direction_set:

			; Set the idle action if
			;  - the player is on hitstun
			;  - or the platform is lower than player
			;  - or the player is not on falling, thrown nor helpless state
			lda player_b_hitstun
			bne set_idle_action

			SIGNED_CMP(player_b_y, player_b_y_screen, stage_data+STAGE_PLATFORM_OFFSET_TOP COMMA y, #0)
			bmi set_idle_action

			lda player_b_state
			cmp #PEPPER_STATE_FALLING
			beq dont_set_idle_action
			cmp #PEPPER_STATE_THROWN
			beq dont_set_idle_action
			cmp #PEPPER_STATE_HELPLESS
			bne set_idle_action
			dont_set_idle_action:

			; Wall jump if it is possible
			lda player_b_walled
			beq skip_walljump
			lda player_b_walljump
			bne set_jump_action
			skip_walljump:

			; In helpless mode, do not try anything else
			lda player_b_state
			cmp #PEPPER_STATE_HELPLESS
			beq set_idle_action

			; Air jump if it is possible
			lda player_b_num_aerial_jumps
			cmp #PEPPER_MAX_NUM_AERIAL_JUMPS
			bne set_jump_action

			; Special-up since no other action was found
			jmp set_special_up_action

			; Set an action
			set_idle_action:
				lda #<ai_action_idle
				sta ai_current_action_lsb
				lda #>ai_action_idle
				sta ai_current_action_msb
				jmp begin_action

			set_jump_action:
				lda #<ai_action_jump
				sta ai_current_action_lsb
				lda #>ai_action_jump
				sta ai_current_action_msb
				jmp begin_action

			set_special_up_action:
				lda #<ai_action_special_up
				sta ai_current_action_lsb
				lda #>ai_action_special_up
				sta ai_current_action_msb
				;jmp begin_action ; useless, fallthrough

		; Reset current action to its begining
		begin_action:
		lda #0
		sta ai_current_action_step
		sta ai_current_action_counter
		jsr ai_delay_action

		end:
		rts
	.)

	platform_handler:
	.(
		patched_value = tmpfield5

		; Ignore unknown platforms
		lda stage_data, y
		cmp #STAGE_ELEMENT_PLATFORM
		beq process
		cmp #STAGE_ELEMENT_SMOOTH_PLATFORM
		beq process
		jmp end
		process:

			; Select any platform as the best
			tya
			sta best_platform

			; A platform above the player cannot save him
			SIGNED_CMP(stage_data+STAGE_PLATFORM_OFFSET_TOP COMMA y, #0, player_b_y, player_b_y_screen)
			bmi end

			; A platform on the left of the player cannot save him
			lda stage_data+STAGE_PLATFORM_OFFSET_RIGHT, y
			clc
			adc #1
			sta patched_value
			SIGNED_CMP(patched_value, #0, player_b_x, player_b_x_screen)
			bmi end

			; A platform on the right of the player cannot save him
			lda player_b_x
			clc
			adc #1
			sta patched_value
			SIGNED_CMP(patched_value, player_b_x_screen, stage_data+STAGE_PLATFORM_OFFSET_LEFT COMMA y, #0)
			bmi end

			; The current platform can save the player, no need to recover
			lda #0
			sta endangered
			ldy #$ff

		end:
		rts
	.)
.)

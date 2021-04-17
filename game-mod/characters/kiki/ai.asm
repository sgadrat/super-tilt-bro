kiki_ai_action_special_neutral:
AI_ACTION_STEP(CONTROLLER_INPUT_SPECIAL, 0)
AI_ACTION_END_STEPS

kiki_ai_attack_selector:
.(
	; Do not try to attack in incapacited states, it would ruin ai reactivity after such states
	lda player_b_state
	cmp #KIKI_STATE_CRASHING
	beq end
		jmp ai_attack_selector
		; No return, jump to subroutine
	end:
	rts
.)

kiki_ai_recover_selector:
.(
	platform_handler_lsb = tmpfield1
	platform_handler_msb = tmpfield2
	endangered = tmpfield9
	lowest_platform_top = tmpfield10
	lowest_platform = tmpfield11

	.(
		; Check that the player is offstage, and lower than lowest platform
		lda player_b_grounded
		bne dont_try_to_recover

		lda #0
		sta lowest_platform_top

		lda #<platform_handler
		sta platform_handler_lsb
		lda #>platform_handler
		sta platform_handler_msb
		jsr stage_iterate_all_elements

		SIGNED_CMP(lowest_platform_top, #0, player_b_y, player_b_y_screen)
		bmi try_to_recover

		dont_try_to_recover:
			jmp end

		try_to_recover:
			; Set action modifier to the platform's direction
			lda #CONTROLLER_BTN_RIGHT
			sta ai_current_action_modifier
			ldy lowest_platform
			SIGNED_CMP(player_b_x, player_b_x_screen, stage_data+STAGE_PLATFORM_OFFSET_RIGHT COMMA y, #0)
			bmi direction_set
			lda #CONTROLLER_BTN_LEFT
			sta ai_current_action_modifier
			direction_set:

			; Set the idle action if
			;  - the player is on hitstun
			;  - or the player is not on falling nor thrown state
			lda player_b_hitstun
			bne set_idle_action

			lda player_b_state
			cmp #KIKI_STATE_FALLING
			beq dont_set_idle_action
			cmp #KIKI_STATE_THROWN
			bne set_idle_action
			dont_set_idle_action:

			; Air jump if it is possible
			lda player_b_num_aerial_jumps
			cmp #KIKI_MAX_NUM_AERIAL_JUMPS
			bne set_jump_action

			; Create some floor since no other action was found
			jmp set_draw_low_platform_action

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

			set_draw_low_platform_action:
				lda #$00
				sta ai_current_action_modifier
				lda #<kiki_ai_action_special_neutral
				sta ai_current_action_lsb
				lda #>kiki_ai_action_special_neutral
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
		; Ignore unknown platforms
		lda stage_data, y
		cmp #STAGE_ELEMENT_PLATFORM
		beq process_simple_platform
		cmp #STAGE_ELEMENT_SMOOTH_PLATFORM
		beq process_simple_platform
		jmp end

		process_simple_platform:
			; Save the top of lowest platform
			lda stage_data+STAGE_PLATFORM_OFFSET_TOP, y
			cmp lowest_platform_top
			bcc end
				sta lowest_platform_top
				sty lowest_platform

		end:

		rts
	.)
.)

kiki_ai_recover_selector:
.(
	;tmpfield 1 to 6 can be modified by platform_handler
	platform_handler_lsb = tmpfield1
	platform_handler_msb = tmpfield2
	endangered = tmpfield9
	lowest_platform_top = tmpfield10
	lowest_platform = tmpfield11
	grounded = tmpfield12

	.(
		; Check that the player is offstage - lower than lowest platform
		lda #0
		sta lowest_platform_top
		sta grounded

		lda #<platform_handler
		sta platform_handler_lsb
		lda #>platform_handler
		sta platform_handler_msb
		jsr stage_iterate_all_elements

		cpy #$ff
		beq dont_try_to_recover
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
			cmp PLAYER_STATE_FALLING
			beq dont_set_idle_action
			cmp PLAYER_STATE_THROWN
			bne set_idle_action
			dont_set_idle_action:

			; Air jump if it is possible
			lda player_b_num_aerial_jumps
			cmp #MAX_NUM_AERIAL_JUMPS
			bne set_jump_action

			; Create some floor since no other action was found
			jmp set_special_down_action

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

			set_special_down_action:
				lda #$00
				sta ai_current_action_modifier
				lda #<ai_action_special_down
				sta ai_current_action_lsb
				lda #>ai_action_special_down
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
		cmp #STAGE_ELEMENT_OOS_PLATFORM
		beq process_oos_platform
		cmp #STAGE_ELEMENT_OOS_SMOOTH_PLATFORM
		beq process_oos_platform
		jmp end

		process_simple_platform:
			; If grounded on platform, stop iterating
			jsr check_simple_platform
			bne not_grounded
				ldy #$ff
				jmp end
			not_grounded:

			; Save the top of lowest platform
			lda stage_data+STAGE_PLATFORM_OFFSET_TOP, y
			cmp lowest_platform_top
			bcc end
				sta lowest_platform_top
				sty lowest_platform

			jmp end

		process_oos_platform:
			; If grounded on platform, stop iterating
			jsr check_oos_platform
			bne end
				ldy #$ff

		end:
		rts
	.)

	; TODO check_*_platform are copy/pasted from game utils - make it generically available, or best, make check_on_platform* routines to take Y register as only pparam
	check_simple_platform:
	.(
		platform_left = tmpfield1 ; Not movable - parameter of check_on_platform
		platform_right = tmpfield2 ; Not movable - parameter of check_on_platform
		platform_top = tmpfield3 ; Not movable - parameter of check_on_platform

		; Don't mess with handler vector
		lda platform_handler_lsb
		pha
		lda platform_handler_msb
		pha

		; Check if player is is grounded on this platform
		lda stage_data+STAGE_PLATFORM_OFFSET_LEFT, y
		sta platform_left
		lda stage_data+STAGE_PLATFORM_OFFSET_RIGHT, y
		sta platform_right
		lda stage_data+STAGE_PLATFORM_OFFSET_TOP, y
		sta platform_top
		jsr check_on_platform

		; Don't mess with handler vector
		pla
		sta platform_handler_msb
		pla
		sta platform_handler_lsb

		rts
	.)

	check_oos_platform:
	.(
		platform_left_lsb = tmpfield1 ; Not movable - parameter of check_on_platform_multi_screen
		platform_right_lsb = tmpfield2 ; Not movable - parameter of check_on_platform_multi_screen
		platform_top_lsb = tmpfield3 ; Not movable - parameter of check_on_platform_multi_screen
		platform_left_msb = tmpfield4 ; Not movable - parameter of check_on_platform_multi_screen
		platform_right_msb = tmpfield5 ; Not movable - parameter of check_on_platform_multi_screen
		platform_top_msb = tmpfield6 ; Not movable - parameter of check_on_platform_multi_screen

		; Don't mess with handler vector
		lda platform_handler_lsb
		pha
		lda platform_handler_msb
		pha

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
		jsr check_on_platform_multi_screen

		; Don't mess with handler vector
		pla
		sta platform_handler_msb
		pla
		sta platform_handler_lsb

		rts
	.)
.)

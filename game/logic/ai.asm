AI_ATTACK_CONDITION_DIRECTION_LEFT = %00000001
AI_ATTACK_CONDITION_DIRECTION_RIGHT = %00000010

; Readable shorthand to get the negation of a constant 8bit value
#define NOT(x) <(-x-1)

ai_action_double_jump:
AI_ACTION_STEP(0, 0)
AI_ACTION_STEP(CONTROLLER_INPUT_JUMP, 9)
AI_ACTION_STEP(0, 0)
AI_ACTION_STEP(CONTROLLER_INPUT_JUMP, 9)
AI_ACTION_END_STEPS

ai_action_jump:
AI_ACTION_STEP(0, 0)
AI_ACTION_STEP(CONTROLLER_INPUT_JUMP, 19)
AI_ACTION_END_STEPS

ai_action_left_tilt:
AI_ACTION_STEP(CONTROLLER_INPUT_ATTACK_LEFT, 0)
AI_ACTION_STEP(0, 19)
AI_ACTION_END_STEPS

ai_action_right_tilt:
AI_ACTION_STEP(CONTROLLER_INPUT_ATTACK_RIGHT, 0)
AI_ACTION_STEP(0, 19)
AI_ACTION_END_STEPS

; Can be used for aerial down and down tilt - same duration
ai_action_down_tilt:
AI_ACTION_STEP(CONTROLLER_INPUT_DOWN_TILT, 0)
AI_ACTION_STEP(0, 19)
AI_ACTION_END_STEPS

ai_action_special_up:
AI_ACTION_STEP(CONTROLLER_INPUT_SPECIAL_UP, 0)
AI_ACTION_END_STEPS

ai_action_tap_down:
AI_ACTION_STEP(CONTROLLER_INPUT_TECH, 0)
AI_ACTION_STEP(0, 0)
AI_ACTION_END_STEPS

ai_action_idle:
AI_ACTION_STEP(0, 0)
AI_ACTION_END_STEPS

ai_level_to_delay:
.byt 30, 10, 1

ai_init:
.(
	; Reset current action
	lda #AI_STEP_FINAL
	sta ai_current_action_step

	; Set delay configuration depending on difficulty level
	ldy config_ai_level
	dey
	lda ai_level_to_delay, y
	sta ai_max_delay
	sta ai_delay
	rts
.)

; Set controller B state
;
; Can watch game state to inteligently set controller B state
ai_tick:
.(
	.(
		; Reset controller's state - extra security, bellow code should
		;      ensure that something is written to controller's state
		lda #$00
		sta controller_b_btns

		; Switch to player B's character bank
		ldx config_player_b_character
		SWITCH_BANK(characters_bank_number COMMA x)

		; Continue the current action if there is one
		lda ai_current_action_step
		cmp #AI_STEP_FINAL
		bne do_action

		; Run selectors until an action is found
		;  Note - the last selector must always return an action,
		;         not finding any action triggers undefined behaviour
		find_action:

		; Push first selectors table's address (lsb first, msb second)
		ldx config_player_b_character ;TODO useless, we already loaded it to switch bank
		lda characters_properties_lsb, x
		sta tmpfield1
		lda characters_properties_msb, x
		sta tmpfield2
		ldy #CHARACTERS_PROPERTIES_AI_ACTION_SELECTORS_OFFSET
		lda (tmpfield1), y
		pha
		iny
		lda (tmpfield1), y
		pha

		run_current_selector:
			; Retrieve selector table pointer
			pla
			sta tmpfield4
			pla
			sta tmpfield3

			; Push pointer + 1
			clc
			adc #2
			pha
			lda tmpfield4
			adc #0
			pha

			; Retrive selector address
			ldy #0
			lda (tmpfield3), y
			sta tmpfield1
			iny
			lda (tmpfield3), y
			sta tmpfield2

			; Call selector
			txa
			pha
			jsr call_pointed_subroutine
			pla
			tax

			; Loop if selector did not start a new action
			lda ai_current_action_step
			cmp #AI_STEP_FINAL
			beq run_current_selector

		; Remove selector table pointer from stack
		pla
		pla

		; Actually continue the current action, there must be one
		do_action:
			jsr ai_continue_action
			lda ai_current_action_step
			cmp #AI_STEP_FINAL
			beq find_action
		rts
	.)
.)

ai_continue_action:
.(
	ldy ai_current_action_step
	iny
	lda (ai_current_action_lsb), y
	cmp ai_current_action_counter
	bcc next_step

	dey
	jmp set_controller

	next_step:
		iny
		sty ai_current_action_step
		lda #0
		sta ai_current_action_counter
		lda (ai_current_action_lsb), y
		cmp #AI_STEP_FINAL
		bne set_controller

		;lda #AI_STEP_FINAL
		sta ai_current_action_step
		jmp end

	set_controller:
		lda (ai_current_action_lsb), y
		ora ai_current_action_modifier
		sta controller_b_btns
		inc ai_current_action_counter

	end:
	rts
.)

; Selector that search for an attack that can hit player A
ai_attack_selector:
.(
	hitbox_left = tmpfield1
	hitbox_right = tmpfield2
	hitbox_top = tmpfield3
	hitbox_bottom = tmpfield4
	hitbox_left_msb = tmpfield9
	hitbox_right_msb = tmpfield10
	hitbox_top_msb = tmpfield11
	hitbox_bottom_msb = tmpfield12
	hurtbox_left = tmpfield5
	hurtbox_right = tmpfield6
	hurtbox_top = tmpfield7
	hurtbox_bottom = tmpfield8
	hurtbox_left_msb = tmpfield13
	hurtbox_right_msb = tmpfield14
	hurtbox_top_msb = tmpfield15
	hurtbox_bottom_msb = tmpfield16

	condition_mask = extra_tmpfield1
	nb_attacks = extra_tmpfield2
	attacks_table = extra_tmpfield3
	; extra_tmpfield4 reserved for attacks table msb
	attacks_msb_table = extra_tmpfield5
	; extra_tmpfield6 reserved for attacks msb table msb

	; Store attacks table address and its size in fixed location
	ldx config_player_b_character
	lda characters_properties_lsb, x
	sta tmpfield1
	lda characters_properties_msb, x
	sta tmpfield2

	ldy #CHARACTERS_PROPERTIES_AI_ATTACKS_OFFSET
	lda (tmpfield1), y
	sta attacks_table
	iny
	lda (tmpfield1), y
	sta attacks_table+1

	ldy #CHARACTERS_PROPERTIES_AI_NB_ATTACKS_OFFSET
	lda (tmpfield1), y
	sta nb_attacks

	; Store attacks MSBs table in fixed location
	;TODO investigate - change table format to one big table
	;      pro - it would make this step unecessary
	;      pro - free extra_tmpfields 5 and 6 (unsed only there)
	;      con - it would slightly change the code below (that's why it is not done in the first implementation, avoid changing logic)
	;      con - size limit would be 256 bytes (21 attacks) instead of current 256*2 (42 attacks)
	asl
	asl
	clc
	adc nb_attacks
	;clc ; useless, that would mean that attacks table is larger than supported (256 bytes for each part)
	adc nb_attacks

	;clc ; useless, that would mean that attacks table is larger than supported (256 bytes for each part)
	adc attacks_table
	sta attacks_msb_table
	lda #0
	adc attacks_table+1
	sta attacks_msb_table+1

	; Compute condition mask
	;  Each matched condition is set to zero in the mask, non matched condition are set to one
	;  Each necessary condition in constraints are set to one
	;  mask & constraints = zero if all necessary conditions are met
	lda #$ff

	ldx player_b_direction
	bne right_facing
		and #NOT(AI_ATTACK_CONDITION_DIRECTION_LEFT)
		jmp end_direction_flag
	right_facing:
		and #NOT(AI_ATTACK_CONDITION_DIRECTION_RIGHT)
	end_direction_flag:

	sta condition_mask

	; Find an attack to trigger
	ldx nb_attacks
	ldy #$00

	check_one_attack:
		; Test if attack's condition match condition mask
		lda (attacks_table), y
		iny
		bit condition_mask
		beq condition_ok

			; Condition failed, skip to next attack
			iny
			iny
			iny
			iny
			jmp next_attack

		condition_ok:

		; Test if attack's hitbox overlaps player A's hurtbox
		lda (attacks_table), y
		clc
		adc player_b_x
		sta hitbox_left
		lda (attacks_msb_table), y
		adc player_b_x_screen
		sta hitbox_left_msb
		iny

		lda (attacks_table), y
		clc
		adc player_b_x
		sta hitbox_right
		lda (attacks_msb_table), y
		adc player_b_x_screen
		sta hitbox_right_msb
		iny

		lda (attacks_table), y
		clc
		adc player_b_y
		sta hitbox_top
		lda (attacks_msb_table), y
		adc player_b_y_screen
		sta hitbox_top_msb
		iny

		lda (attacks_table), y
		clc
		adc player_b_y
		sta hitbox_bottom
		lda (attacks_msb_table), y
		adc player_b_y_screen
		sta hitbox_bottom_msb
		iny

		lda player_a_hurtbox_left
		sta hurtbox_left
		lda player_a_hurtbox_left_msb
		sta hurtbox_left_msb
		lda player_a_hurtbox_right
		sta hurtbox_right
		lda player_a_hurtbox_right_msb
		sta hurtbox_right_msb
		lda player_a_hurtbox_top
		sta hurtbox_top
		lda player_a_hurtbox_top_msb
		sta hurtbox_top_msb
		lda player_a_hurtbox_bottom
		sta hurtbox_bottom
		lda player_a_hurtbox_bottom_msb
		sta hurtbox_bottom_msb

		txa ; TODO investigate pushing X seems unecessary
		pha
		jsr boxes_overlap
		sta tmpfield9
		pla
		tax
		lda tmpfield9
		bne next_attack

			; Boxes overlap, trigger this attack
			lda (attacks_table), y
			sta ai_current_action_lsb
			lda (attacks_msb_table), y
			sta ai_current_action_msb
			lda #0
			sta ai_current_action_modifier
			sta ai_current_action_step
			sta ai_current_action_counter
			jsr ai_delay_action
			jmp end

		; Check the next attack
		next_attack:
		iny
		dex
		beq end
		jmp check_one_attack

	end:
	rts
.)

ai_recover_selector:
.(
	platform_handler_lsb = tmpfield1
	platform_handler_msb = tmpfield2
	endangered = tmpfield3
	best_platform = tmpfield4
	;tmpfield5 used by platform handler

	;TODO find a way to make it generic, or simply move it to sinbad's file

	.(
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
			;  - or the player is not on falling nor thrown state
			lda player_b_hitstun
			bne set_idle_action

			SIGNED_CMP(player_b_y, player_b_y_screen, stage_data+STAGE_PLATFORM_OFFSET_TOP COMMA y, #0)
			bmi set_idle_action

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

			; Special-side if the platform is far away
			lda player_b_x_screen
			bne set_special_side_action

				lda ai_current_action_modifier
				cmp #CONTROLLER_BTN_RIGHT
				beq load_left_edge
				lda stage_data+STAGE_PLATFORM_OFFSET_RIGHT, y
				jmp edge_loaded
				load_left_edge:
				lda stage_data+STAGE_PLATFORM_OFFSET_LEFT, y
				edge_loaded:

					sec
					sbc player_b_x
					jsr absolute_a
					cmp #16
					bcs set_special_side_action

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

			set_special_side_action:
				lda #<ai_action_special_side
				sta ai_current_action_lsb
				lda #>ai_action_special_side
				sta ai_current_action_msb
				jmp begin_action

			set_special_up_action:
				lda #$00
				sta ai_current_action_modifier
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

; Selector that makes the character move toward its opponent
;
; This selector always selects an action.
ai_chase_selector:
.(
	; Note - chasing do not care about screen, only use 8bit unsigned positions
	;
	;  The effect is that, when the player is out of screen, the bot tends to flee him
	;  since the bot actually sees him on the other side of the screen.
	;
	;  Handling two bytes signed position would have the effect of making the bot go
	;  to the edge of the platform. Problem, the bot is really bad on platforms edges,
	;  oscilating between chasing and recovering until the indecision kills him.

	stage_element_handler_lsb = tmpfield1
	stage_element_handler_msb = tmpfield2
	collision_point_x_lsb = tmpfield3
	collision_point_y_lsb = tmpfield4
	collision_point_x_msb = tmpfield5
	collision_point_y_msb = tmpfield6

	grounded_platform = tmpfield3

	; If grounded on smooth platform and opponent bellow, tap down
	SIGNED_CMP(player_b_y, player_b_y_screen, player_a_y, player_a_y_screen)
	bpl no_tap_down
		ldx #1
		jsr check_on_ground
		bne no_tap_down
			ldx grounded_platform
			lda stage_data, x
			cmp #STAGE_ELEMENT_SMOOTH_PLATFORM
			beq tap_down
			cmp #STAGE_ELEMENT_OOS_SMOOTH_PLATFORM
			beq tap_down
	no_tap_down:

	; Set the modifier to opponent's direction
	lda #CONTROLLER_BTN_LEFT
	sta ai_current_action_modifier
	lda player_a_x
	cmp player_b_x
	bcc direction_set
	lda #CONTROLLER_BTN_RIGHT
	sta ai_current_action_modifier
	direction_set:

	; Choose between jumping or not
	lda player_b_state
	cmp PLAYER_STATE_STANDING
	beq jump_if_higher
	cmp PLAYER_STATE_RUNNING
	bne dont_jump

	jump_if_higher:
		lda player_a_y
		cmp player_b_y
		bcs end_jump_if_higher
		sec
		sbc player_b_y
		cmp #16
		bcs jump
	end_jump_if_higher:

	; Jump if there is a wall in front of the bot (just sensor a hard platform at "bot.x +- 7")
	lda #<check_in_platform
	sta stage_element_handler_lsb
	lda #>check_in_platform
	sta stage_element_handler_msb

	lda ai_current_action_modifier
	cmp #CONTROLLER_BTN_LEFT
	beq negative_offset

		lda #7
		sta collision_point_x_lsb
		lda #0
		sta collision_point_x_msb
		jmp end_set_offset

	negative_offset:
		lda #$f9
		sta collision_point_x_lsb
		lda #$ff
		sta collision_point_x_msb

	end_set_offset:

	lda player_b_x
	clc
	adc collision_point_x_lsb
	sta collision_point_x_lsb
	lda player_b_x_screen
	adc collision_point_x_msb
	sta collision_point_x_msb

	lda player_b_y
	sta collision_point_y_lsb
	lda player_b_y_screen
	sta collision_point_y_msb

	jsr stage_iterate_all_elements
	cpy #$ff ; technically useless as stage_iterate_all_elements already does it, but it is not ensured in its description
	beq jump

	dont_jump:
		lda #<ai_action_idle
		sta ai_current_action_lsb
		lda #>ai_action_idle
		sta ai_current_action_msb
		jmp action_set

	jump:
		lda #<ai_action_double_jump
		sta ai_current_action_lsb
		lda #>ai_action_double_jump
		sta ai_current_action_msb
		jmp action_set

	tap_down:
		lda #0
		sta ai_current_action_modifier
		lda #<ai_action_tap_down
		sta ai_current_action_lsb
		lda #>ai_action_tap_down
		sta ai_current_action_msb
		;jmp action_set ; useless, fallthrough

	; Begin the selected action
	action_set:
	lda #0
	sta ai_current_action_step
	sta ai_current_action_counter

	rts
.)

; Replace the selected action by an iddle one if needed because of difficulty level
ai_delay_action:
.(
	dec ai_delay
	beq no_delay

		; Delay the action by replacing it by an idle action
		lda #<ai_action_idle
		sta ai_current_action_lsb
		lda #>ai_action_idle
		sta ai_current_action_msb
		lda #0
		sta ai_current_action_modifier
		sta ai_current_action_step
		sta ai_current_action_counter
		jmp end

	; Let the action execute normally and reset delay counter
	no_delay:
		lda ai_max_delay
		sta ai_delay

	end:
	rts
.)

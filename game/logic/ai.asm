#define AI_ATTACK_HITBOX(left,right,top,bottom) .byt left, right, top, bottom
#define AI_NB_ATTACKS 4
attacks:
AI_ATTACK_HITBOX($f0, $fd, $f4, $0c)
.word ai_action_left_tilt
AI_ATTACK_HITBOX($0a, $17, $f4, $0c)
.word ai_action_right_tilt
AI_ATTACK_HITBOX($f1, $17, $08, $0f)
.word ai_action_down_tilt
AI_ATTACK_HITBOX($f1, $17, $d0, $f8)
.word ai_action_special_up

#define AI_STEP_FINAL $ff
#define AI_ACTION_STEP(buttons,time) .byt buttons, time
#define AI_ACTION_END_STEPS .byt AI_STEP_FINAL

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

ai_action_special_side:
AI_ACTION_STEP(CONTROLLER_INPUT_SPECIAL, 60)
AI_ACTION_STEP(0, 9)
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

		; Continue the current action if there is one
		lda ai_current_action_step
		cmp #AI_STEP_FINAL
		bne do_action

		; Run selectors until an action is found
		;  Note - the last selector must always return an action,
		;         not finding any action triggers undefined behaviour
		find_action:
		ldx #0
		run_current_selector:
			lda action_selectors_lsb, x
			sta tmpfield1
			lda action_selectors_msb, x
			sta tmpfield2
			txa
			pha
			jsr call_pointed_subroutine
			pla
			tax

			inx
			lda ai_current_action_step
			cmp #AI_STEP_FINAL
			beq run_current_selector

		; Actually continue the current action, there must be one
		do_action:
			jsr ai_continue_action
			lda ai_current_action_step
			cmp #AI_STEP_FINAL
			beq find_action
		rts
	.)

	; Search for an attack that can hit player A
	attack_selector:
	.(
		ldy #AI_NB_ATTACKS
		ldx #$00

		check_one_attack:

			; Test if attack's hitbox overlaps player A's hurtbox
			lda attacks, x
			clc
			adc player_b_x
			sta tmpfield1
			inx
			lda attacks, x
			clc
			adc player_b_x
			sta tmpfield2
			inx
			lda attacks, x
			clc
			adc player_b_y
			sta tmpfield3
			inx
			lda attacks, x
			clc
			adc player_b_y
			sta tmpfield4
			inx
			txa
			pha

			lda player_a_hurtbox_left
			sta tmpfield5
			lda player_a_hurtbox_right
			sta tmpfield6
			lda player_a_hurtbox_top
			sta tmpfield7
			lda player_a_hurtbox_bottom
			sta tmpfield8

			jsr boxes_overlap
			sta tmpfield9
			pla
			tax
			lda tmpfield9
			bne next_attack

				; Boxes overlap, trigger this attack
				lda attacks, x
				sta ai_current_action_lsb
				inx
				lda attacks, x
				sta ai_current_action_msb
				lda #0
				sta ai_current_action_modifier
				sta ai_current_action_step
				sta ai_current_action_counter
				jsr delay_action
				jmp end

			; Check the next attack
			next_attack:
			inx
			inx
			dey
			bne check_one_attack

		end:
		rts
	.)

	recover_selector:
	.(
		platform_handler_lsb = tmpfield1
		platform_handler_msb = tmpfield2
		endangered = tmpfield3
		best_platform = tmpfield4

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
			jsr stage_iterate_platforms

			lda endangered
			beq end

				; Set action modifier to the platform's direction
				lda #CONTROLLER_BTN_RIGHT
				sta ai_current_action_modifier
				ldy best_platform
				lda stage_data+STAGE_OFFSET_PLATFORMS+STAGE_PLATFORM_OFFSET_RIGHT, y
				cmp player_b_x
				bcs direction_set
				lda #CONTROLLER_BTN_LEFT
				sta ai_current_action_modifier
				direction_set:

				; Set the idle action if
				;  - the player is on hitstun
				;  - or the platform is lower than player
				;  - or the player is not on falling nor thrown state
				lda player_b_hitstun
				bne set_idle_action

				lda player_b_y
				cmp stage_data+STAGE_OFFSET_PLATFORMS+STAGE_PLATFORM_OFFSET_TOP, y
				bcc set_idle_action

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
				lda ai_current_action_modifier
				cmp #CONTROLLER_BTN_RIGHT
				beq load_left_edge
				lda stage_data+STAGE_OFFSET_PLATFORMS+STAGE_PLATFORM_OFFSET_RIGHT, y
				jmp edge_loaded
				load_left_edge:
				lda stage_data+STAGE_OFFSET_PLATFORMS+STAGE_PLATFORM_OFFSET_LEFT, y
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
			jsr delay_action

			end:
			rts
		.)

		platform_handler:
		.(
			; Select any platform as the best
			tya
			sta best_platform

			; A platform above the player cannot save him
			lda stage_data+STAGE_OFFSET_PLATFORMS+STAGE_PLATFORM_OFFSET_TOP, y
			cmp player_b_y
			bcc end

			; A platform on the left of the player cannot save him
			lda stage_data+STAGE_OFFSET_PLATFORMS+STAGE_PLATFORM_OFFSET_RIGHT, y
			clc
			adc #1
			cmp player_b_x
			bcc end

			; A platform on the right of the player cannot save him
			lda player_b_x
			clc
			adc #1
			cmp stage_data+STAGE_OFFSET_PLATFORMS+STAGE_PLATFORM_OFFSET_LEFT, y
			bcc end

			; The current platform can save the player, no need to recover
			lda #0
			sta endangered
			ldy #$ff

			end:
			rts
		.)
	.)

	chase_selector:
	.(
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
			bcs dont_jump
			sec
			sbc player_b_y
			cmp #16
			bcs jump

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

		; Begin the selected action
		action_set:
		lda #0
		sta ai_current_action_step
		sta ai_current_action_counter

		rts
	.)

	; Replace the selected action by an iddle one if needed because of difficulty level
	delay_action:
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

	action_selectors_lsb:
	.byt <attack_selector
	.byt <recover_selector
	.byt <chase_selector

	action_selectors_msb:
	.byt >attack_selector
	.byt >recover_selector
	.byt >chase_selector
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

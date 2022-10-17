game_mode_local_init:
.(
	lda #0
	sta local_mode_paused

	jmp ai_init

	;rts ; useless - jump to subroutine
.)

game_mode_local_pre_update:
.(
	; Toggle pause status if requested
	.(
		;NOTE we cannot trust "controller_a_last_frame_btns, x" as keep_input_dirty messes with it
		;     instead we store if the "pause" input was the last in bits 7 and 6 of local_mode_paused
		;
		;     local_mode_paused - AB.. ...P
		;      A - Set if "pause" was the last-frame's input for controller A
		;      B - Set if "pause" was the last-frame's input for controller B
		;      P - Set if the game is paused
		ldx #1
		check_one_controller:
			; Check controller's state
			;  We allow other buttons to be pressed with the pause-input, it is more friendly when pausing/unpausing in the middle of a move
			lda controller_a_btns, x
			and #CONTROLLER_INPUT_PAUSE
			cmp #CONTROLLER_INPUT_PAUSE
			beq set_pause_input

				unset_pause_input:
					; Not pressing "pause" input, unflag pause input
					lda pause_bit_unset, x
					and local_mode_paused
					sta local_mode_paused
					jmp next

				set_pause_input:
					; Pressing "pause" input, swap pause state if it is new on this frame and flag input
					lda local_mode_paused
					and pause_bit_set, x
					bne already_swapped_pause
						lda local_mode_paused
						eor #%00000001
						sta local_mode_paused
					already_swapped_pause:

					lda pause_bit_set, x
					ora local_mode_paused
					sta local_mode_paused

				next:
				dex
				bpl check_one_controller
	.)

	; In pause, skip the frame
	.(
		lda local_mode_paused
		beq ok
			sec
			rts
		ok:
	.)

	; Tick AI only if AI is active and frame is playable
	lda config_ai_level
	beq end_ai
	lda network_rollback_mode
    bne end_ai
	lda screen_shake_counter
	bne end_ai
	lda slow_down_counter
	bne end_ai
        jsr ai_tick
    end_ai:

	; Return without skipping the frame
	clc
	rts

	pause_bit_set:
	.byt %10000000, %01000000
	pause_bit_unset:
	.byt %01111111, %10111111
.)

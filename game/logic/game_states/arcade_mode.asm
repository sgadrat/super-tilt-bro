;
; Screen between fights implementation
;

init_arcade_mode:
.(
	; Initialize C stack
	jsr reinit_c_stack

	; Call C init routine
	SWITCH_BANK(#ARCADE_MODE_EXTRA_BANK_NUMBER)
	jmp init_arcade_mode_extra

	;rts ; useless, jump to subroutine
.)

arcade_mode_tick:
.(
	; Call C tick routine
	SWITCH_BANK(#ARCADE_MODE_EXTRA_BANK_NUMBER)
	jmp arcade_mode_tick_extra

	;rts ; useless, jump to subroutine
.)

;
; Game mode implementation
;

.(
ENCOUNTER_FIGHT = 0
ENCOUNTER_RUN = 1
ENCOUNTER_TARGETS = 2
ENCOUNTER_CUTSCENE = 3

N_TARGETS = 10
FIRST_TARGET_SPRITE = 32

&game_mode_arcade_pre_update:
.(
	lda arcade_mode_stage_type
	beq fight
	cmp #ENCOUNTER_RUN
	beq reach_the_exit

		break_the_targets:
			jsr break_the_targets_tick
			jmp common

		reach_the_exit:
			jsr is_player_on_exit
			;jmp common ; useless, "fight" is empty

		fight:
			; Nothing special

	common:

	; Increment counter
	.(
		inc arcade_mode_counter_frames
		lda arcade_mode_counter_frames
		cmp #60
		bne ok

			lda #0
			sta arcade_mode_counter_frames

			inc arcade_mode_counter_seconds
			lda arcade_mode_counter_seconds
			cmp #60
			bne ok

				lda #0
				sta arcade_mode_counter_seconds

				inc arcade_mode_counter_minutes

		ok:
	.)

	;HACK local mode only handle AI, and we want AI too
	jmp game_mode_local_pre_update
	;rts ; useless, jump to subroutine

	is_player_on_exit:
	.(
		exit_left_pixel = tmpfield1 ; Rectangle 1 left (pixel)
		exit_right_pixel = tmpfield2 ; Rectangle 1 right (pixel)
		exit_top_pixel = tmpfield3 ; Rectangle 1 top (pixel)
		exit_bot_pixel = tmpfield4 ; Rectangle 1 bottom (pixel)
		player_left_pixel = tmpfield5 ; Rectangle 2 left (pixel)
		player_right_pixel = tmpfield6 ; Rectangle 2 right (pixel)
		player_top_pixel = tmpfield7 ; Rectangle 2 top (pixel)
		player_bot_pixel = tmpfield8 ; Rectangle 2 bottom (pixel)
		exit_left_screen = tmpfield9 ; Rectangle 1 left (screen)
		exit_right_screen = tmpfield10 ; Rectangle 1 right (screen)
		exit_top_screen = tmpfield11 ; Rectangle 1 top (screen)
		exit_bot_screen = tmpfield12 ; Rectangle 1 bottom (screen)
		player_left_screen = tmpfield13 ; Rectangle 2 left (screen)
		player_right_screen = tmpfield14 ; Rectangle 2 right (screen)
		player_top_screen = tmpfield15 ; Rectangle 2 top (screen)
		player_bot_screen = tmpfield16 ; Rectangle 2 bottom (screen)

		stage_header_addr = player_left_pixel ; need a 2-bytes zeropage location not used by the exit rectangle

		; Select stage bank
		ldx config_selected_stage
		SWITCH_BANK(stages_bank COMMA x)

		; Compute arcade header's address
		txa
		asl
		tax

		lda stages_data+0, x
		sec
		sbc #8
		sta stage_header_addr
		lda stages_data+1, x
		sbc #0
		sta stage_header_addr+1

		; Copy exit rectangle in colision rectangle
		.(
			ldy #0
			ldx #0
			copy_one_component:
				lda (stage_header_addr), y
				sta exit_left_pixel, x
				iny
				lda (stage_header_addr), y
				sta exit_left_screen, x
				iny

				inx
				cpx #4
				bne copy_one_component
		.)

		; Copy player hurtbox in colision rectangle
		.(
			ldx #4-1
			ldy #(4-1)*2
			copy_one_component:
				lda player_a_hurtbox_left, y
				sta player_left_pixel, x
				lda player_a_hurtbox_left_msb, y
				sta player_left_screen, x

				dey
				dey
				dex
				bpl copy_one_component
		.)

		; Test colision
		jsr boxes_overlap
		bne end

			; Directly call gameover to come back to arcade state
			lda #0
			sta gameover_winner
			jmp game_mode_arcade_gameover
			; No return

		end:
		rts
	.)

	break_the_targets_tick:
	.(
		target_left_pixel = tmpfield1 ; Rectangle 1 left (pixel)
		target_right_pixel = tmpfield2 ; Rectangle 1 right (pixel)
		target_top_pixel = tmpfield3 ; Rectangle 1 top (pixel)
		target_bot_pixel = tmpfield4 ; Rectangle 1 bottom (pixel)
		target_left_screen = tmpfield9 ; Rectangle 1 left (screen)
		target_right_screen = tmpfield10 ; Rectangle 1 right (screen)
		target_top_screen = tmpfield11 ; Rectangle 1 top (screen)
		target_bot_screen = tmpfield12 ; Rectangle 1 bottom (screen)
		hitbox_left_pixel = tmpfield5 ; Rectangle 2 left (pixel)
		hitbox_right_pixel = tmpfield6 ; Rectangle 2 right (pixel)
		hitbox_top_pixel = tmpfield7 ; Rectangle 2 top (pixel)
		hitbox_bot_pixel = tmpfield8 ; Rectangle 2 bottom (pixel)
		hitbox_left_screen = tmpfield13 ; Rectangle 2 left (screen)
		hitbox_right_screen = tmpfield14 ; Rectangle 2 right (screen)
		hitbox_top_screen = tmpfield15 ; Rectangle 2 top (screen)
		hitbox_bot_screen = tmpfield16 ; Rectangle 2 bottom (screen)

		current_target = extra_tmpfield1

		; Skip collision checks if player's hitbox is disabled
		.(
			lda player_a_hitbox_enabled
			bne ok
				jmp end_destroy_targets
			ok:
		.)

		; Check if we destroyed some targets
		.(
			ldx #N_TARGETS-1
			stx current_target
			check_one_target:
				; Do nothing if target is deactivated (target position >= 240)
				.(
					lda arcade_mode_targets_y, x
					cmp #240
					bcc ok
						jmp loop_target
					ok:
				.)

				; Store target's hurtbox
				;lda arcade_mode_targets_y, x ; useless, value already in A
				sta target_top_pixel
				clc
				adc #8
				sta target_bot_pixel

				lda arcade_mode_targets_x, x
				sta target_left_pixel
				;clc ; useless, previous adx should not overflow
				adc #8
				sta target_right_pixel

				lda #0
				sta target_left_screen
				sta target_right_screen
				sta target_top_screen
				sta target_bot_screen

				; Store player's hitbox
				lda player_a_hitbox_left
				sta hitbox_left_pixel
				lda player_a_hitbox_left_msb
				sta hitbox_left_screen

				lda player_a_hitbox_right
				sta hitbox_right_pixel
				lda player_a_hitbox_right_msb
				sta hitbox_right_screen

				lda player_a_hitbox_top
				sta hitbox_top_pixel
				lda player_a_hitbox_top_msb
				sta hitbox_top_screen

				lda player_a_hitbox_bottom
				sta hitbox_bot_pixel
				lda player_a_hitbox_bottom_msb
				sta hitbox_bot_screen

				; Check collision
				jsr boxes_overlap
				bne end_collision
					; Collision between player's hitbox and target's hurtbox, break the target
					ldx current_target
					lda #$fe
					sta arcade_mode_targets_y, x
					;TODO animation and sound
				end_collision:

				; Loop
				loop_target:
				dec current_target
				bmi end_destroy_targets
					ldx current_target
					jmp check_one_target

		.)
		end_destroy_targets:

		; Place targets sprites
		.(
			ldx #N_TARGETS-1
			ldy #FIRST_TARGET_SPRITE*4
			place_one_sprite:
				lda arcade_mode_targets_y, x
				sta oam_mirror+0, y
				lda arcade_mode_targets_x, x
				sta oam_mirror+3, y

				iny
				iny
				iny
				iny

				dex
				bpl place_one_sprite
		.)

		; If there is no more target, end the game
		.(
			ldx #N_TARGETS-1
			check_one_target:
				lda arcade_mode_targets_y, x
				cmp #240
				bcc found_a_target

				dex
				bpl check_one_target

			no_target_found:
				; Come back to arcade mode
				lda #0
				sta gameover_winner
				jmp game_mode_arcade_gameover
				; No return

			found_a_target:
				; Nothing to do, just continue as usual
		.)

		rts
	.)
.)

&game_mode_arcade_init:
.(
	lda arcade_mode_stage_type
	beq fight
	cmp #ENCOUNTER_RUN
	beq reach_the_exit

		break_the_targets:
			jsr break_the_targets_init
			;jmp common ; fallthrough to hide the second character

		reach_the_exit:
			; Hide second character
			ldx #1
			ldy config_player_b_character
			SWITCH_BANK(characters_bank_number COMMA y)

			lda #PLAYER_STATE_INNEXISTANT
			sta player_b_state
			ldy config_player_b_character
			lda characters_start_routines_table_lsb, y
			sta tmpfield1
			lda characters_start_routines_table_msb, y
			sta tmpfield2
			jsr player_state_action
			;jmp common ; useless, "fight" is empty

		fight:
			; Nothing special

	common:

	lda arcade_mode_player_damages
	sta player_a_damages

	jmp game_mode_local_init ;HACK local mode only handle AI, and we want AI too

	break_the_targets_init:
	.(
		current_target = tmpfield1
		stage_header_addr = tmpfield2
		;stage_header_addr_msb = tmpfield3

		; Find the begining of targets in stage data
		ldx config_selected_stage
		SWITCH_BANK(stages_bank COMMA x)

		txa
		asl
		tax

		lda stages_data+0, x
		sec
		sbc #N_TARGETS*2
		sta stage_header_addr
		lda stages_data+1, x
		sbc #0
		sta stage_header_addr+1

		; Copy targets information in RAM
		ldy #0
		ldx #N_TARGETS-1
		copy_one_target:
			lda (stage_header_addr), y
			sta arcade_mode_targets_x, x
			iny
			lda (stage_header_addr), y
			sta arcade_mode_targets_y, x
			iny

			dex
			bpl copy_one_target

		rts
	.)
.)

&game_mode_arcade_gameover:
.(
	lda gameover_winner
	sta arcade_mode_last_game_winner

	lda player_a_damages
	sta arcade_mode_player_damages

	inc arcade_mode_current_encounter

	lda #GAME_STATE_ARCADE_MODE
	jmp change_global_game_state
.)
.)

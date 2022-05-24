.(
ENCOUNTER_FIGHT = 0
ENCOUNTER_RUN = 1
ENCOUNTER_TARGETS = 2
ENCOUNTER_CUTSCENE = 3

N_TARGETS = 10
FIRST_TARGET_SPRITE = 32

ARCADE_TARGET_BREAK_FIRST_SPRITE = FIRST_TARGET_SPRITE+N_TARGETS
ARCADE_TARGET_BREAK_LAST_SPRITE = ARCADE_TARGET_BREAK_FIRST_SPRITE+8

ARCADE_RUN_TELEPORT_FIRST_SPRITE = ARCADE_TARGET_BREAK_FIRST_SPRITE
ARCADE_RUN_TELEPORT_LAST_SPRITE = ARCADE_TARGET_BREAK_LAST_SPRITE
ARCADE_RUN_TELEPORT_TIMER_INACTIVE = $ff

hide_player_b:
.(
	ldx #1
	ldy config_player_b_character

	lda #PLAYER_STATE_INNEXISTANT
	sta player_b_state
	lda characters_start_routines_table_lsb, y
	sta tmpfield1
	lda characters_start_routines_table_msb, y
	sta tmpfield2

	lda #<player_state_action
	sta extra_tmpfield1
	lda #>player_state_action
	sta extra_tmpfield2
	lda characters_bank_number, y
	sta extra_tmpfield3
	lda #CURRENT_BANK_NUMBER
	sta extra_tmpfield4
	jmp trampoline
	;rts ; useless, jump to subroutine
.)

&game_mode_arcade_init_hook:
.(
	lda arcade_mode_stage_type
	beq fight
	cmp #ENCOUNTER_RUN
	beq reach_the_exit

		break_the_targets:
			jsr hide_player_b
			jsr break_the_targets_init
			jmp common

		reach_the_exit:
			; Hide second character
			jsr hide_player_b

			; Disable teleport timer
			lda #ARCADE_RUN_TELEPORT_TIMER_INACTIVE
			sta arcade_mode_run_teleport_timer

			;jmp common ; useless, "fight" is empty

		fight:
			; Nothing special

	common:

	; Restore player's damage
	lda arcade_mode_player_damages
	sta player_a_damages

	; Load Break The Targets spritesheet
	lda #<arcade_btt_sprites_tileset
	sta tmpfield1
	lda #>arcade_btt_sprites_tileset
	sta tmpfield2

	lda PPUSTATUS
	lda #$0c
	sta PPUADDR
	lda #$00
	sta PPUADDR

	lda #<cpu_to_ppu_copy_tileset
	sta extra_tmpfield1
	lda #>cpu_to_ppu_copy_tileset
	sta extra_tmpfield2
	lda #ARCADE_BTT_SPRITES_TILESET_BANK_NUMBER
	sta extra_tmpfield3
	lda #CURRENT_BANK_NUMBER
	sta extra_tmpfield4

	jsr trampoline

	;HACK Call local mode init because it only handles AI, and we want AI too
	jmp game_mode_local_init

	;rts ; Useless, jump to subroutine

	break_the_targets_init:
	.(
		stage_header_addr = tmpfield1
		;stage_header_addr_msb = tmpfield2

		; Find the begining of targets in stage data
		ldx config_selected_stage
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
		lda #<arcade_copy_targets
		sta extra_tmpfield1
		lda #>arcade_copy_targets
		sta extra_tmpfield2

		ldx config_selected_stage
		lda stages_bank, x
		sta extra_tmpfield3

		lda #CURRENT_BANK_NUMBER
		sta extra_tmpfield4

		ldy #0
		ldx #N_TARGETS-1
		jsr trampoline

		; Set tile and attribute bytes of target sprites
		ldx #N_TARGETS-1
		ldy #FIRST_TARGET_SPRITE*4
		init_one_target:
			lda #ARCADE_FIRST_TILE+TILE_ARCADE_BTT_SPRITES_TILESET_TARGET
			sta oam_mirror+1, y
			lda #2
			sta oam_mirror+2, y

			iny
			iny
			iny
			iny

			dex
			bpl init_one_target

		; Load targets palette
		lda PPUSTATUS
		lda #$3f
		sta PPUADDR
		lda #$19
		sta PPUADDR

		lda #$0f
		sta PPUDATA
		lda #$16
		sta PPUDATA
		lda #$20
		sta PPUDATA

		; Deactivate target break animation
		lda #0
		sta arcade_mode_target_break_animation_timer

		rts
	.)
.)

&game_mode_arcade_pre_update_hook:
.(
	lda arcade_mode_stage_type
	beq fight
	cmp #ENCOUNTER_RUN
	beq reach_the_exit

		break_the_targets:
			jsr break_the_targets_tick
			jmp common

		reach_the_exit:
			jsr reach_the_exit_tick
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

	reach_the_exit_tick:
	.(
		; Select routine
		;   is_player_on_exit - is normal game behaviour
		;   reach_the_exit_end - display teleport animation before exiting
		lda arcade_mode_run_teleport_timer
		cmp #ARCADE_RUN_TELEPORT_TIMER_INACTIVE
		beq is_player_on_exit
		;Fallthrough to reach_the_exit_end
	.)

	reach_the_exit_end:
	.(
		; Tick teleport animation
		lda #<arcade_mode_run_teleport_animation
		sta tmpfield11
		lda #>arcade_mode_run_teleport_animation
		sta tmpfield12
		lda #0
		sta player_number
		TRAMPOLINE(animation_draw, #ARCADE_MODE_ANIMATIONS_BANK, #CURRENT_BANK_NUMBER)
		TRAMPOLINE(animation_tick, #ARCADE_MODE_ANIMATIONS_BANK, #CURRENT_BANK_NUMBER)

		; Move teleport beam
		PORTAL_DURATION = 8 ;TODO ntsc/pal compat
		lda arcade_mode_run_teleport_timer
		cmp #PORTAL_DURATION
		bcc move_ok
			lda arcade_mode_run_teleport_animation+ANIMATION_STATE_OFFSET_Y_LSB
			sec
			sbc #5
			sta arcade_mode_run_teleport_animation+ANIMATION_STATE_OFFSET_Y_LSB
			lda arcade_mode_run_teleport_animation+ANIMATION_STATE_OFFSET_Y_MSB
			sbc #0
			sta arcade_mode_run_teleport_animation+ANIMATION_STATE_OFFSET_Y_MSB
		move_ok:

		; Inc teleport counter
		inc arcade_mode_run_teleport_timer

		; Return to arcade mode if teleport beam is over the screen
		lda arcade_mode_run_teleport_animation+ANIMATION_STATE_OFFSET_Y_MSB
		bpl still_on_screen
			lda arcade_mode_run_teleport_animation+ANIMATION_STATE_OFFSET_Y_LSB
			cmp #230
			bcs still_on_screen

				; Directly call gameover to come back to arcade state
				lda #0
				sta gameover_winner
				jmp game_mode_arcade_gameover_hook
				; No return

		still_on_screen:

		rts
	.)

	is_player_on_exit:
	.(
		exit_left_pixel = tmpfield1 ; Rectangle 1 left (pixel)
		exit_right_pixel = tmpfield2 ; Rectangle 1 right (pixel)
		exit_top_pixel = tmpfield3 ; Rectangle 1 top (pixel)
		exit_bot_pixel = tmpfield4 ; Rectangle 1 bottom (pixel)
		exit_left_screen = tmpfield9 ; Rectangle 1 left (screen)
		exit_right_screen = tmpfield10 ; Rectangle 1 right (screen)
		exit_top_screen = tmpfield11 ; Rectangle 1 top (screen)
		exit_bot_screen = tmpfield12 ; Rectangle 1 bottom (screen)
		player_left_pixel = tmpfield5 ; Rectangle 2 left (pixel)
		player_right_pixel = tmpfield6 ; Rectangle 2 right (pixel)
		player_top_pixel = tmpfield7 ; Rectangle 2 top (pixel)
		player_bot_pixel = tmpfield8 ; Rectangle 2 bottom (pixel)
		player_left_screen = tmpfield13 ; Rectangle 2 left (screen)
		player_right_screen = tmpfield14 ; Rectangle 2 right (screen)
		player_top_screen = tmpfield15 ; Rectangle 2 top (screen)
		player_bot_screen = tmpfield16 ; Rectangle 2 bottom (screen)

		stage_header_addr = player_left_pixel ; need a 2-bytes zeropage location not used by the exit rectangle

		; Compute arcade header's address
		ldx config_selected_stage
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
		lda #<arcade_copy_exit_rectangle
        sta extra_tmpfield1
        lda #>arcade_copy_exit_rectangle
        sta extra_tmpfield2

        ldx config_selected_stage
        lda stages_bank, x
        sta extra_tmpfield3

        lda #CURRENT_BANK_NUMBER
        sta extra_tmpfield4

        jsr trampoline

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

			; Hide player, and replace it by teleport animation
			.(
				; Save player's position
				lda player_a_x
				pha
				lda player_a_x_screen
				pha
				lda player_a_y
				pha
				lda player_a_y_screen
				pha

				; Change player to inactive state
				ldx #0
				ldy config_player_a_character

				lda #PLAYER_STATE_INNEXISTANT
				sta player_a_state
				lda characters_start_routines_table_lsb, y
				sta tmpfield1
				lda characters_start_routines_table_msb, y
				sta tmpfield2
				TRAMPOLINE(player_state_action, characters_bank_number COMMA y, #CURRENT_BANK_NUMBER)

				; Place teleport animation
				lda #<arcade_mode_run_teleport_animation
				sta tmpfield11
				lda #>arcade_mode_run_teleport_animation
				sta tmpfield12
				lda #<arcade_mode_teleport_anim
				sta tmpfield13
				lda #>arcade_mode_teleport_anim
				sta tmpfield14
				jsr animation_init_state

				lda #ARCADE_RUN_TELEPORT_FIRST_SPRITE
				sta arcade_mode_run_teleport_animation+ANIMATION_STATE_OFFSET_FIRST_SPRITE_NUM
				lda #ARCADE_RUN_TELEPORT_LAST_SPRITE
				sta arcade_mode_run_teleport_animation+ANIMATION_STATE_OFFSET_LAST_SPRITE_NUM
				pla
				sta arcade_mode_run_teleport_animation+ANIMATION_STATE_OFFSET_Y_MSB
				pla
				sta arcade_mode_run_teleport_animation+ANIMATION_STATE_OFFSET_Y_LSB
				pla
				sta arcade_mode_run_teleport_animation+ANIMATION_STATE_OFFSET_X_MSB
				pla
				sta arcade_mode_run_teleport_animation+ANIMATION_STATE_OFFSET_X_LSB

				; Set teleport counter to zero
				lda #0
				sta arcade_mode_run_teleport_timer

				; Sound effect
				jsr audio_play_teleport
			.)

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

					; Hide target's sprite
					ldx current_target
					lda #$fe
					sta arcade_mode_targets_y, x

					; Initialize target breaking animation
					lda #<arcade_mode_target_break_animation
					sta tmpfield11
					lda #>arcade_mode_target_break_animation
					sta tmpfield12
					lda #<arcade_mode_target_break_anim
					sta tmpfield13
					lda #>arcade_mode_target_break_anim
					sta tmpfield14
					jsr animation_init_state

					lda #ARCADE_TARGET_BREAK_FIRST_SPRITE
					sta arcade_mode_target_break_animation+ANIMATION_STATE_OFFSET_FIRST_SPRITE_NUM
					lda #ARCADE_TARGET_BREAK_LAST_SPRITE
					sta arcade_mode_target_break_animation+ANIMATION_STATE_OFFSET_LAST_SPRITE_NUM
					lda target_left_pixel
					sta arcade_mode_target_break_animation+ANIMATION_STATE_OFFSET_X_LSB
					lda target_top_pixel
					sta arcade_mode_target_break_animation+ANIMATION_STATE_OFFSET_Y_LSB

					lda #arcade_mode_target_break_anim_dur_pal
					ldy system_index
					beq duration_loaded:
						lda #arcade_mode_target_break_anim_dur_ntsc
					duration_loaded:
					sta arcade_mode_target_break_animation_timer

					; Sound effect
					jsr audio_play_target_break

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
				; Start slowdown that will come back to arcade mode after that
				lda slow_down_counter
				bne slowdown_already_set
					lda #0
					sta gameover_winner
					lda #SLOWDOWN_TIME
					sta slow_down_counter
				slowdown_already_set:
				;jmp ok ; useless, "found_a_target" does nothing

			found_a_target:
				; Nothing to do, just continue as usual
		.)

		; Tick target break animation
		.(
			lda arcade_mode_target_break_animation_timer
			beq hide_sprites

				tick_anim:
					; Update animation's timer
					dec arcade_mode_target_break_animation_timer

					; Update animation
					lda #<arcade_mode_target_break_animation
					sta tmpfield11
					lda #>arcade_mode_target_break_animation
					sta tmpfield12
					lda #0
					sta player_number
					TRAMPOLINE(animation_draw, #ARCADE_MODE_ANIMATIONS_BANK, #CURRENT_BANK_NUMBER)
					TRAMPOLINE(animation_tick, #ARCADE_MODE_ANIMATIONS_BANK, #CURRENT_BANK_NUMBER)

					jmp ok

				hide_sprites:
					; Change Y position of sprites reserved for the animation to be off-screen
					ldx #ARCADE_TARGET_BREAK_FIRST_SPRITE
					txa
					asl
					asl
					tay

					hide_one_sprite:
						lda #$fe
						sta oam_mirror+0, y

						cpx #ARCADE_TARGET_BREAK_LAST_SPRITE
						beq ok

						iny
						iny
						iny
						iny

						inx

						jmp hide_one_sprite

			ok:
		.)

		rts
	.)
.)

&game_mode_arcade_gameover_hook:
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

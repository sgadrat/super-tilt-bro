#define STAGE_THEHUNT_STAGE_SPRITES INGAME_STAGE_FIRST_SPRITE
#define STAGE_THEHUNT_NB_STAGE_SPRITES 8
#define STAGE_THEHUNT_FIRST_SPRITE_OAM_OFFSET STAGE_THEHUNT_STAGE_SPRITES*4
#define STAGE_THEHUNT_LAST_SPRITE_OAM_OFFSET (STAGE_THEHUNT_STAGE_SPRITES+STAGE_THEHUNT_NB_STAGE_SPRITES-1)*4
#define STAGE_THEHUNT_GEM_SPRITE STAGE_THEHUNT_STAGE_SPRITES

#define STAGE_THEHUNT_GEM_SPRITE_OAM oam_mirror+STAGE_THEHUNT_GEM_SPRITE*4

#define STAGE_THEHUNT_GEM_SPAWN_X $80
#define STAGE_THEHUNT_GEM_SPAWN_Y $30
#define STAGE_THEHUNT_GEM_MAX_VELOCITY 2
#define STAGE_THEHUNT_GEM_MIN_VELOCITY $fe

#define STAGE_THEHUNT_GEM_HURTBOX_WIDTH 7
#define STAGE_THEHUNT_GEM_HURTBOX_HEIGHT 7

#define STAGE_THEHUNT_GEM_COOLDOWN_LSB 0
#define STAGE_THEHUNT_GEM_COOLDOWN_MSB 2
#define STAGE_THEHUNT_BREAK_DURATION 40
#define STAGE_THEHUNT_BUFF_DURATION_LSB 0
#define STAGE_THEHUNT_BUFF_DURATION_MSB 2
#define STAGE_THEHUNT_BUFF_SCREEN_SHAKE_DURATION 20

#define STAGE_THEHUNT_BUFF_DAMAGES 20

#define STAGE_THEHUNT_GEM_STATE_COOLDOWN 0
#define STAGE_THEHUNT_GEM_STATE_ACTIVE 1
#define STAGE_THEHUNT_GEM_STATE_BREAKING 2
#define STAGE_THEHUNT_GEM_STATE_BUFF 3

#define STAGE_THEHUNT_HIDE_SPRITES .( :\
	lda #$fe :\
	ldx #STAGE_THEHUNT_FIRST_SPRITE_OAM_OFFSET :\
	hide_one_sprite:\
		sta oam_mirror, x :\
		inx :\
		inx :\
		inx :\
		inx :\
		cpx #(STAGE_THEHUNT_LAST_SPRITE_OAM_OFFSET)+4 :\
		bne hide_one_sprite :\
.)

; Pause music, avoid audio_mute_music which changes the configuration ;TODO This is hacky as fuck (and may break with new audio engine)
#define STAGE_THEHUNT_PAUSE_MUSIC lda #%00001000 : sta APU_STATUS
; Play music, avoid audio_unmute_music which changes the configuration
#define STAGE_THEHUNT_RESUME_MUSIC lda #%00001111 : sta APU_STATUS

stage_thehunt_init:
.(
	; Magma stage initialization
	TRAMPOLINE(stages_magma_init, #BANKED_UTILS_BANK_NUMBER, #CURRENT_BANK_NUMBER)

	; Copy stage's tiles in VRAM
	.(
		tileset_addr = tmpfield1 ; Not movable, used by cpu_to_ppu_copy_tileset
		;tileset_addr_msb = tmpfield2 ; Not movable, used by cpu_to_ppu_copy_tileset
		tiles_count = tmpfield3 ; Not movable, used by cpu_to_ppu_copy_tileset

		lda #<tileset_stage_thehunt_sprites
		sta tileset_addr
		lda #>tileset_stage_thehunt_sprites
		sta tileset_addr+1

		lda PPUSTATUS
		lda #>STAGE_FIRST_SPRITE_TILE_OFFSET
		sta PPUADDR
		lda #<STAGE_FIRST_SPRITE_TILE_OFFSET
		sta PPUADDR

		jsr cpu_to_ppu_copy_tileset
	.)

	; Put the gem in its initial state
	jsr stage_thehunt_set_state_cooldown

	; Disable screen restoration
	lda #$ff
	sta stage_restore_screen_step
	lda #FADE_LEVEL_NORMAL
	sta stage_fade_level
	sta stage_current_fade_level

	rts
.)

stage_thehunt_netload:
.(
	rx_buffer_gem_state_value = esp_rx_buffer+0
	rx_buffer_gem_state_details = esp_rx_buffer+1

	; Load gem's state
	ldy rx_buffer_gem_state_value, x
	sty stage_thehunt_gem_state

	; Load fields for the new state
	lda gem_state_netload_routines_lsb, y
	sta tmpfield1
	lda gem_state_netload_routines_msb, y
	sta tmpfield2
	jmp (tmpfield1)

	gem_netload_cooldown:
	.(
		; Load state's variables
		lda rx_buffer_gem_state_details+0, x
		sta stage_thehunt_gem_cooldown_low
		lda rx_buffer_gem_state_details+1, x
		sta stage_thehunt_gem_cooldown_high

		; Ensure sprites consistency
		STAGE_THEHUNT_HIDE_SPRITES

		rts
	.)

	gem_netload_active:
	.(
		; Load state's variables
		lda rx_buffer_gem_state_details+0, x
		sta stage_thehunt_gem_position_x_low
		lda rx_buffer_gem_state_details+1, x
		sta stage_thehunt_gem_position_x_high
		lda rx_buffer_gem_state_details+2, x
		sta stage_thehunt_gem_position_y_low
		lda rx_buffer_gem_state_details+3, x
		sta stage_thehunt_gem_position_y_high
		lda rx_buffer_gem_state_details+4, x
		sta stage_thehunt_gem_velocity_h_low
		lda rx_buffer_gem_state_details+5, x
		sta stage_thehunt_gem_velocity_h_high
		lda rx_buffer_gem_state_details+6, x
		sta stage_thehunt_gem_velocity_v_low
		lda rx_buffer_gem_state_details+7, x
		sta stage_thehunt_gem_velocity_v_high

		; Ensure sprites consistency
		STAGE_THEHUNT_HIDE_SPRITES ; Note, just in case we were in "buff" state previously (should be really rare)

		lda #TILE_GEM
		sta STAGE_THEHUNT_GEM_SPRITE_OAM+1 ; Tile number
		lda #3
		sta STAGE_THEHUNT_GEM_SPRITE_OAM+2 ; Attributes
		jmp stage_thehunt_place_gem

		;rts ; useless, jump to subroutine
	.)

	gem_netload_breaking:
	.(
		; Load state's variables
		lda rx_buffer_gem_state_details+0, x
		sta stage_thehunt_buffed_player

		; Ensure sprites consistency
		;  Nothing to do, animation code is called each frame

		; Ensure music is paused
		STAGE_THEHUNT_PAUSE_MUSIC

		rts
	.)

	gem_netload_buff:
	.(
		; Load state's variables
		lda rx_buffer_gem_state_details+0, x
		sta stage_thehunt_gem_cooldown_low
		lda rx_buffer_gem_state_details+1, x
		sta stage_thehunt_gem_cooldown_high
		lda rx_buffer_gem_state_details+2, x
		sta stage_thehunt_last_opponent_state
		lda rx_buffer_gem_state_details+3, x
		sta stage_thehunt_buffed_player

		; Ensure sprites consistency
		;  Nothing to do, animation code is called each frame

		; Ensure music is running
		;  Note - This is fragile, if a game in "breaking" state loads to something else than "buff" state, the music will stay paused
		STAGE_THEHUNT_RESUME_MUSIC

		rts
	.)

	gem_state_netload_routines_lsb:
	.byt <gem_netload_cooldown, <gem_netload_active, <gem_netload_breaking, <gem_netload_buff
	gem_state_netload_routines_msb:
	.byt >gem_netload_cooldown, >gem_netload_active, >gem_netload_breaking, >gem_netload_buff
.)

; Sets fadeout level
;  register X - fadeout level
;
; Overwrites registers, tmpfield1 to tmpfield4
+stage_thehunt_fadeout:
.(
	; Set ideal fade level
	stx stage_fade_level

	; If not in rollback, apply it immediately
	lda network_rollback_mode
	beq apply_fadeout
		rts

	apply_fadeout:
	;Fallthrough to stage_thehunt_fadeout_update
.)

; Rewrite palettes to match fadeout level
;  register X - fadeout level
;
; Overwrites registers, tmpfield1 to tmpfield4
stage_thehunt_fadeout_update:
.(
	header = tmpfield1 ; construct_nt_buffer parameter
	payload = tmpfield3 ; construct_nt_buffer parameter

	; Do nothing if there is not enough space in the buffer
	.(
		IF_NT_BUFFERS_FREE_SPACE_LT(#1+3+16+1, ok)
			rts
		ok:
	.)

	; Set actual fade level
	stx stage_current_fade_level

	; Change palette
	lda #<palette_header
	sta header
	lda #>palette_header
	sta header+1

	lda stage_thehunt_fadeout_lsb, x
	sta payload
	lda stage_thehunt_fadeout_msb, x
	sta payload+1

	jmp construct_nt_buffer
	;No return, jump to subroutine

	palette_header:
	.byt $3f, $00, $10
.)

stage_thehunt_freezed_tick:
.(
	; Restore screen if requested
	lda network_rollback_mode
	bne bg_update_ok
		lda #<stage_thehunt_top_attributes : sta tmpfield1
		lda #<stage_thehunt_bot_attributes : sta tmpfield2
		lda #>stage_thehunt_top_attributes : sta tmpfield3
		lda #>stage_thehunt_bot_attributes : sta tmpfield4
		TRAMPOLINE(stages_magma_repair_screen, #BANKED_UTILS_BANK_NUMBER, #CURRENT_BANK_NUMBER)
	bg_update_ok:

	; Update gem breaking state if it is the cause of the freeze
	lda stage_thehunt_gem_state
	cmp #STAGE_THEHUNT_GEM_STATE_BREAKING
	bne end

		jmp stage_thehunt_tick_state_breaking
		; No return, jump to subroutine

	end:
	rts
.)

stage_thehunt_tick:
.(
	.(
		; Call the correct tick routine according to gem's state
		ldx stage_thehunt_gem_state
		lda stage_thehunt_tick_state_routines_lsb, x
		sta tmpfield1
		lda stage_thehunt_tick_state_routines_msb, x
		sta tmpfield2
		jsr call_pointed_subroutine

		; Update background (apply an asynchrone change if requested, else animate lava)
		lda network_rollback_mode
		bne bg_update_ok
			lda #<stage_thehunt_top_attributes : sta tmpfield1
			lda #<stage_thehunt_bot_attributes : sta tmpfield2
			lda #>stage_thehunt_top_attributes : sta tmpfield3
			lda #>stage_thehunt_bot_attributes : sta tmpfield4
			TRAMPOLINE(stages_magma_update_background, #BANKED_UTILS_BANK_NUMBER, #CURRENT_BANK_NUMBER)
		bg_update_ok:
		rts
	.)

	; gem state tick routines
	stage_thehunt_tick_state_routines_lsb:
		.byt <stage_thehunt_tick_state_cooldown, <stage_thehunt_tick_state_active, <stage_thehunt_tick_state_breaking, <stage_thehunt_tick_state_buff
	stage_thehunt_tick_state_routines_msb:
		.byt >stage_thehunt_tick_state_cooldown, >stage_thehunt_tick_state_active, >stage_thehunt_tick_state_breaking, >stage_thehunt_tick_state_buff

	stage_thehunt_tick_state_cooldown:
	.(
		; If cooldown reaches zero, activate the gem
		jsr dec_cooldown
		bne end

			jsr stage_thehunt_set_state_active

		end:
		rts
	.)

	stage_thehunt_tick_state_active:
	.(
		jsr move_gem

		lda network_rollback_mode
		bne end_place_gem
			jsr stage_thehunt_place_gem
		end_place_gem:

		jmp check_gem_hit

		;rts ; useless, jump to subroutine
	.)

	&stage_thehunt_tick_state_breaking:
	.(
		lda screen_shake_counter
		bne update_anim

			stop_anim:
			.(
				lda audio_music_enabled
				beq music_ok
					STAGE_THEHUNT_RESUME_MUSIC
				music_ok:
				jmp stage_thehunt_set_state_buff
				;rts ; useless, jump to subroutine
			.)

			update_anim:
			.(
				; Draw the gem explosion animation
				;  Overwrites all registers and almost all tmpfields
				.(
					; Do not draw in rollback mode
					lda network_rollback_mode
					bne end_draw_anim

						; Search the current frame number
						lda #STAGE_THEHUNT_BREAK_DURATION
						sec
						sbc screen_shake_counter
						lsr
						lsr

						cmp gem_explosion_last_frame_index
						bcc frame_number_ok
						lda gem_explosion_last_frame_index

						frame_number_ok:
						tax

						; Place sprites
						.(
							; animation_handle_sprites parameters
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
							;anim_state = tmpfield11
							;anim_state_lsb = tmpfield12
							;sign_extension_byte = tmpfield13
							;attributes_modifier = tmpfield14
							;sprite_direction = tmpfield15

							lda gem_explosion_frames_addr_lsb, x
							sta frame_vector
							lda gem_explosion_frames_addr_msb, x
							sta frame_vector_msb

							lda stage_thehunt_gem_position_x_high
							sta animation_position_x
							lda stage_thehunt_gem_position_y_high
							sta animation_position_y

							lda #0
							sta animation_direction
							sta animation_position_y_msb
							sta animation_position_x_msb

							ldx #1

							jsr stage_thehunt_draw_anim_frame
						.)

					end_draw_anim:
				.)

				; Audio effect
				lda #STAGE_THEHUNT_BREAK_DURATION
				sec
				sbc screen_shake_counter
				tax
				jmp play_gem_hit

				;rts ; useless, jump to subroutine
			.)
	.)

	stage_thehunt_tick_state_buff:
	.(
		; Cancel buff if player lost a stock
		.(
			ldx stage_thehunt_buffed_player
			lda player_a_state, x
			cmp #PLAYER_STATE_RESPAWN
			bne ok
				jmp stage_thehunt_set_state_cooldown
				;No return, we don't want to run buff code knowing we are actually in colldown
			ok:
		.)

		; Update buff animation
		lda network_rollback_mode
		bne end_update_anim

			lda stage_thehunt_gem_cooldown_low ; Compute current frame number (the animation must have exactly 8 frames)
			lsr
			lsr
			and #%00000111
			tax

			; animation_handle_sprites parameters
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
			;anim_state = tmpfield11
			;anim_state_lsb = tmpfield12
			;sign_extension_byte = tmpfield13
			;attributes_modifier = tmpfield14
			;sprite_direction = tmpfield15

			lda gem_buff_frames_addr_lsb, x
			sta frame_vector
			lda gem_buff_frames_addr_msb, x
			sta frame_vector_msb

			ldx stage_thehunt_buffed_player
			lda player_a_x, x
			sta animation_position_x
			lda player_a_y, x
			sta animation_position_y
			lda player_a_x_screen, x
			sta animation_position_x_msb
			lda player_a_y_screen, x
			sta animation_position_y_msb
			;lda player_a_direction, x ; actually unsuported flipped animation (the animation is symetrical anyway)
			lda #0
			sta animation_direction

			jsr stage_thehunt_draw_anim_frame

		end_update_anim:

		; Detect if the opponent just got thrown
		ldx stage_thehunt_buffed_player
		SWITCH_SELECTED_PLAYER
		lda player_a_state, x
		cmp stage_thehunt_last_opponent_state
		beq end_throw_handling
		cmp #PLAYER_STATE_THROWN
		bne end_throw_handling

			; Deal bonus damages
			lda #STAGE_THEHUNT_BUFF_DAMAGES ; TODO Factorize with hurt_player subroutine code
			clc
			adc player_a_damages, x
			cmp #200
			bcs cap_damages
				jmp apply_damages
			cap_damages:
				lda #199
			apply_damages:
				sta player_a_damages, x

			; Deal bonus knockback
			asl player_a_velocity_h_low, x
			rol player_a_velocity_h, x
			asl player_a_velocity_v_low, x
			rol player_a_velocity_v, x
			asl player_a_hitstun, x

			; Augment screen shaking
			lda #STAGE_THEHUNT_BUFF_SCREEN_SHAKE_DURATION
			sta screen_shake_counter

			; Remove the gem's buff
			lda #0 ; Tricky - set the cooldown to 1 so that the buff will disapear gracefully at the end of this subroutine
			sta stage_thehunt_gem_cooldown_high
			lda #1
			sta stage_thehunt_gem_cooldown_low

		end_throw_handling:

			; Save new opponent state
			lda player_a_state, x
			sta stage_thehunt_last_opponent_state

		; If cooldown reaches zero, return to gem cooldown
		jsr dec_cooldown
		bne end_cd_check

			jmp stage_thehunt_set_state_cooldown
			; No return, jump to subroutine

		end_cd_check:

		rts
	.)

	; Decrement the gem's cooldown value
	;  Sets Z flag if the new value is zero
	dec_cooldown:
	.(
		; Decrement cooldown
		lda stage_thehunt_gem_cooldown_low
		bne no_carry
			carry:
				dec stage_thehunt_gem_cooldown_high
			no_carry:
				dec stage_thehunt_gem_cooldown_low

		; Z flag = (stage_thehunt_gem_cooldown_low == 0 && stage_thehunt_gem_cooldown_high == 0)
		bne end
		lda stage_thehunt_gem_cooldown_high

		end:
		rts
	.)

	; Check if the gem got hit by a player
	check_gem_hit:
	.(
		box_1_addr = stage_data + stage_thehunt_data_size
		box_1_left = box_1_addr + 0
		box_1_right = box_1_addr + 2
		box_1_top = box_1_addr + 4
		box_1_bottom = box_1_addr + 6
		box_1_left_msb = box_1_addr + 8
		box_1_right_msb = box_1_addr + 10
		box_1_top_msb = box_1_addr + 12
		box_1_bottom_msb = box_1_addr + 14
#if box_1_bottom_msb >= $0480
#error the hunt requires more memory than available
#endif

		; box_1 = gem's bounding box
		lda stage_thehunt_gem_position_x_high
		sta box_1_left
		clc
		adc #STAGE_THEHUNT_GEM_HURTBOX_WIDTH
		sta box_1_right
		lda stage_thehunt_gem_position_y_high
		sta box_1_top
		clc
		adc #STAGE_THEHUNT_GEM_HURTBOX_HEIGHT
		sta box_1_bottom
		lda #0
		sta box_1_left_msb
		sta box_1_right_msb
		sta box_1_top_msb
		sta box_1_bottom_msb

		lda #<box_1_addr
		sta tmpfield1
		lda #>box_1_addr
		sta tmpfield2

		; For each player, check if he hits the gem
		ldx #0
		check_one_player:

			; Skip check if hitbox is disabled
			lda player_a_hitbox_enabled, x
			beq check_projectiles

				; box_2 = player's hitbox
				lda player_hitbox_addr_lsb, x
				sta tmpfield3
				lda player_hitbox_addr_msb, x
				sta tmpfield4

				; Check collision
				jsr interleaved_boxes_overlap
				beq gem_hit

			check_projectiles:
#if NB_PROJECTILES_PER_PLAYER <> 1
#error unrolled loop expects NB_PROJECTILES_PER_PLAYER to be 1
#endif
			lda player_a_projectile_1_flags, x
			beq next_player

				; box_2 = projectile's hitbox
				lda player_projectile_hitbox_addr_lsb, x
				sta tmpfield3
				lda player_projectile_hitbox_addr_msb, x
				sta tmpfield4

				; Check collision
				jsr interleaved_boxes_overlap
				beq gem_hit_by_projectile

			next_player:
			inx
			cpx #2
			bne check_one_player
			jmp end

		; The gem got hit by a projectile, call projectile's logic
		gem_hit_by_projectile:
			ldy config_player_a_character, x
			lda characters_projectile_hit_routine_lsb, y
			sta tmpfield1
			lda characters_projectile_hit_routine_msb, y
			sta tmpfield2
			lda characters_bank_number, y
			sta tmpfield3

			ldy #OTHERBOX
			TRAMPOLINE(call_pointed_subroutine, tmpfield3, #CURRENT_BANK_NUMBER)

			;Fallthrough to gem_hit

		; The gem got hit, emphasis the breaking animation
		gem_hit:
			; Save buffed player number
			stx stage_thehunt_buffed_player

			; Set gem in breaking state
			jsr stage_thehunt_set_state_breaking

		end:
			rts

		player_hitbox_addr_lsb:
			.byt <player_a_hitbox_left, <player_b_hitbox_left
		player_hitbox_addr_msb:
			.byt >player_a_hitbox_left, >player_b_hitbox_left

		player_projectile_hitbox_addr_lsb:
			.byt <player_a_projectile_1_hitbox_left, <player_b_projectile_1_hitbox_left
		player_projectile_hitbox_addr_msb:
			.byt >player_a_projectile_1_hitbox_left, >player_b_projectile_1_hitbox_left
	.)

	; Play sound effet when the gem is exploded
	;  register X - Frame counter
	play_gem_hit:
	.(
		; Search the current frame
		ldy #4
		check_one_frame:
		txa
		cmp sound_frame_time, y
		bne next_frame

			; Y = current frame's index
			lda sound_frame_index, y
			tay

			; Play frame
			lda sound_frames_lsb, y
			sta tmpfield1
			lda sound_frames_msb, y
			sta tmpfield2
			jsr call_pointed_subroutine

			; Stop looping
			jmp end

		next_frame:
		dey
		cpy #255
		bne check_one_frame

		end:
		rts

		sound_frame_time:
			.byt 0, 5, 9, 20, 30
		sound_frame_index:
			.byt 0, 0, 0,  1,  0
		sound_frames_lsb:
			.byt <audio_play_hit, <audio_play_death
		sound_frames_msb:
			.byt >audio_play_hit, >audio_play_death
	.)

	; Update gem's position
	move_gem:
	.(
		; Compute new velocity
		jsr steering_go_between_players

		; Cap to max velocity
		; If velocity_h >= MAX_VELOCITY
		;    velocity_h = MAX_VELOCITY
		SIGNED_CMP(stage_thehunt_gem_velocity_h_low, stage_thehunt_gem_velocity_h_high, #0, #STAGE_THEHUNT_GEM_MAX_VELOCITY)
		bmi vel_h_max_ok
		lda #STAGE_THEHUNT_GEM_MAX_VELOCITY
		sta stage_thehunt_gem_velocity_h_high
		lda #0
		sta stage_thehunt_gem_velocity_h_low
		vel_h_max_ok:

		; If MIN_VELOCITY >= velocity_h
		;    velocity_h = -MIN_VELOCITY
		SIGNED_CMP(#0, #STAGE_THEHUNT_GEM_MIN_VELOCITY, stage_thehunt_gem_velocity_h_low, stage_thehunt_gem_velocity_h_high)
		bmi vel_h_min_ok:
		lda #STAGE_THEHUNT_GEM_MIN_VELOCITY
		sta stage_thehunt_gem_velocity_h_high
		lda #0
		sta stage_thehunt_gem_velocity_h_low
		vel_h_min_ok:

		; If velocity_v >= MAX_VELOCITY
		;    velocity_v = MAX_VELOCITY
		SIGNED_CMP(stage_thehunt_gem_velocity_v_low, stage_thehunt_gem_velocity_v_high, #0, #STAGE_THEHUNT_GEM_MAX_VELOCITY)
		bmi vel_v_max_ok
		lda #STAGE_THEHUNT_GEM_MAX_VELOCITY
		sta stage_thehunt_gem_velocity_v_high
		lda #0
		sta stage_thehunt_gem_velocity_v_low
		vel_v_max_ok:

		; If MIN_VELOCITY >= velocity_v
		;    velocity_v = -MIN_VELOCITY
		SIGNED_CMP(#0, #STAGE_THEHUNT_GEM_MIN_VELOCITY, stage_thehunt_gem_velocity_v_low, stage_thehunt_gem_velocity_v_high)
		bmi vel_v_min_ok:
		lda #STAGE_THEHUNT_GEM_MIN_VELOCITY
		sta stage_thehunt_gem_velocity_v_high
		lda #0
		sta stage_thehunt_gem_velocity_v_low
		vel_v_min_ok:

		; Apply velocity to position
		lda stage_thehunt_gem_velocity_h_low
		clc
		adc stage_thehunt_gem_position_x_low
		sta stage_thehunt_gem_position_x_low
		lda stage_thehunt_gem_velocity_h_high
		adc stage_thehunt_gem_position_x_high
		sta stage_thehunt_gem_position_x_high

		lda stage_thehunt_gem_velocity_v_low
		clc
		adc stage_thehunt_gem_position_y_low
		sta stage_thehunt_gem_position_y_low
		lda stage_thehunt_gem_velocity_v_high
		adc stage_thehunt_gem_position_y_high
		sta stage_thehunt_gem_position_y_high

		rts
	.)

	; Steering behavior trying to go between players
	steering_go_between_players:
	.(
		target_position_x = tmpfield4
		target_position_y = tmpfield5
		tmp_comp_lsb = tmpfield6
		tmp_comp_msb = tmpfield7

		; Compute target position
		;  Target = P1 + (P2 - P1) / 2
		;  With
		;   Target - Target position
		;   P1     - Player A position
		;   P2     - Player B position
		;  Positions are 2D vectors, 16bits signed components, with lsb being pixel position and msb being zero filled
		;  (Zero filling to 16 bits allows us to do signed computations)

		; Target's horizontal component

		lda player_b_x ; tmpcomp = P2 - P1
		sec
		sbc player_a_x
		sta tmp_comp_lsb
		lda #0
		sbc #0
		sta tmp_comp_msb

		;asl ; tmp_comp = tmp_comp / 2 (signed) ; not doing the first asl, invalidate result's msb but we do not use it
		lda tmp_comp_msb
		ror
		;sta tmp_comp_msb ; unused
		lda tmp_comp_lsb
		ror
		sta tmp_comp_lsb

		clc ; target = P1 + tmp_comp (note, we do not care about tmp_comp msb, the result must be between 0 and 255 since P1 and P2 are both between 0 and 255)
		adc player_a_x
		sta target_position_x

		; Target's vertical component

		lda player_b_y ; tmpcomp = P2 - P1
		sec
		sbc player_a_y
		sta tmp_comp_lsb
		lda #0
		sbc #0
		sta tmp_comp_msb

		;asl ; tmp_comp = tmp_comp / 2 (signed) ; not doing the first asl, invalidate result's msb but we do not use it
		lda tmp_comp_msb
		ror
		;sta tmp_comp_msb ; unused
		lda tmp_comp_lsb
		ror
		sta tmp_comp_lsb

		clc ; target = P1 + tmp_comp (note, we do not care about tmp_comp msb, the result must be between 0 and 255 since P1 and P2 are both between 0 and 255)
		adc player_a_y
		sta target_position_y

		sec
		sbc #32
		sta target_position_y

		; Compute vector to target
		;  Vector = Target - G
		;  With
		;   Target - Target position
		;   G      - Current gem's position

		lda target_position_x ; XY = Target - G
		sec
		sbc stage_thehunt_gem_position_x_high
		tax
		lda #0
		sbc #0
		tay

		txa ; Add to gem's velocity
		clc
		adc stage_thehunt_gem_velocity_h_low
		sta stage_thehunt_gem_velocity_h_low
		tya
		adc stage_thehunt_gem_velocity_h_high
		sta stage_thehunt_gem_velocity_h_high

		lda target_position_y ; XY = Target - G
		sec
		sbc stage_thehunt_gem_position_y_high
		tax
		lda #0
		sbc #0
		tay

		txa ; Add to gem's velocity
		clc
		adc stage_thehunt_gem_velocity_v_low
		sta stage_thehunt_gem_velocity_v_low
		tya
		adc stage_thehunt_gem_velocity_v_high
		sta stage_thehunt_gem_velocity_v_high

		rts
	.)
.)

; Puts the gem in cooldown
stage_thehunt_set_state_cooldown:
.(
	; Set the state
	lda #STAGE_THEHUNT_GEM_STATE_COOLDOWN
	sta stage_thehunt_gem_state

	; Hide all stage's sprites
	STAGE_THEHUNT_HIDE_SPRITES

	; Reset cooldown
	lda #STAGE_THEHUNT_GEM_COOLDOWN_LSB
	sta stage_thehunt_gem_cooldown_low
	lda #STAGE_THEHUNT_GEM_COOLDOWN_MSB
	sta stage_thehunt_gem_cooldown_high

	rts
.)

; Activate the gem
stage_thehunt_set_state_active:
.(
	; Set the state
	lda #STAGE_THEHUNT_GEM_STATE_ACTIVE
	sta stage_thehunt_gem_state

	; Set gem's initial position and velocity
	lda #STAGE_THEHUNT_GEM_SPAWN_X
	sta stage_thehunt_gem_position_x_high
	lda #STAGE_THEHUNT_GEM_SPAWN_Y
	sta stage_thehunt_gem_position_y_high
	lda #0
	sta stage_thehunt_gem_position_x_low
	sta stage_thehunt_gem_position_y_low
	sta stage_thehunt_gem_velocity_h_low
	sta stage_thehunt_gem_velocity_h_high
	sta stage_thehunt_gem_velocity_v_low
	sta stage_thehunt_gem_velocity_v_high

	; Prepare gem sprite
	lda #TILE_GEM
	sta STAGE_THEHUNT_GEM_SPRITE_OAM+1 ; Tile number
	lda #3
	sta STAGE_THEHUNT_GEM_SPRITE_OAM+2 ; Attributes

	; Show gem
	.(
		lda network_rollback_mode
		beq show_gem
			rts
		show_gem:
			jmp stage_thehunt_place_gem
			; No return, jump to subroutine
	.)

	;rts ; useless, above code does it or jump to subroutine
.)

; Puts the gem in breaking state
stage_thehunt_set_state_breaking:
.(
	; Set the state
	lda #STAGE_THEHUNT_GEM_STATE_BREAKING
	sta stage_thehunt_gem_state

	; Freeze the screen for the duration of the breaking animation
	lda #0
	sta screen_shake_current_x
	sta screen_shake_current_y
	sta screen_shake_noise_h
	sta screen_shake_noise_v
	lda #STAGE_THEHUNT_BREAK_DURATION
	sta screen_shake_counter

	; Pause music
	STAGE_THEHUNT_PAUSE_MUSIC

	rts
.)

; Buff the player
;  stage_thehunt_buffed_player shall already be set correctly
stage_thehunt_set_state_buff:
.(
	; Set the state
	lda #STAGE_THEHUNT_GEM_STATE_BUFF
	sta stage_thehunt_gem_state

	; Reset cooldown
	lda #STAGE_THEHUNT_BUFF_DURATION_LSB
	sta stage_thehunt_gem_cooldown_low
	lda #STAGE_THEHUNT_BUFF_DURATION_MSB
	sta stage_thehunt_gem_cooldown_high

	; Store initial opponent state
	ldx stage_thehunt_buffed_player
	SWITCH_SELECTED_PLAYER
	lda player_a_state, x
	sta stage_thehunt_last_opponent_state

	rts
.)

; Place the OAM gem's sprite according to gem's position
stage_thehunt_place_gem:
.(
	lda stage_thehunt_gem_position_y_high
	sta STAGE_THEHUNT_GEM_SPRITE_OAM
	lda stage_thehunt_gem_position_x_high
	sta STAGE_THEHUNT_GEM_SPRITE_OAM+3
	rts
.)

; Draw a frame from stage-specific animation format
;  frame_vector - address of the frame to draw
;  animation_position_x
;  animation_position_x_msb
;  animation_position_y
;  animation_position_y_msb
;  animation_direction
;  X - player number, and attributes modifier
;
; Overwrites all registers, sign_extension_byte, sprite_count, attributes_modifier, player_number, sprite_direction
stage_thehunt_draw_anim_frame:
.(
	; animation_handle_sprites parameters
	animation_position_x = tmpfield1
	animation_position_x_msb = tmpfield2
	animation_position_y = tmpfield3
	animation_position_y_msb = tmpfield4
	frame_vector = tmpfield5
	frame_vector_msb = tmpfield6
	;first_sprite_index = tmpfield7
	;last_sprite_index = tmpfield8
	animation_direction = tmpfield9
	sprite_count = tmpfield10
	;anim_state = tmpfield11
	;anim_state_lsb = tmpfield12
	;sign_extension_byte = tmpfield13
	attributes_modifier = tmpfield14
	sprite_direction = tmpfield15

	stx attributes_modifier
	stx player_number

	ldy #0
	lda (frame_vector), y
	sta sprite_count
	pha
	beq end_sprite_placing
		iny

		lda #4
		sta sprite_direction

		ldx #STAGE_THEHUNT_STAGE_SPRITES*4

		; Call sprite placing routine
		jsr animation_handle_sprites
	end_sprite_placing:

	; Clear unused sprites
	.(
		; X = offset of the first unused sprite
		pla
		clc
		adc #STAGE_THEHUNT_STAGE_SPRITES
		asl
		asl
		tax

		; Clear sprites until the last reserved
		lda #$fe
		loop:
			cpx #4*(STAGE_THEHUNT_STAGE_SPRITES+STAGE_THEHUNT_NB_STAGE_SPRITES)
			beq end_loop

				sta oam_mirror, x
				inx
				inx
				inx
				inx

			jmp loop
		end_loop:
	.)

	rts
.)

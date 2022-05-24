#define STAGE_GEM_STAGE_SPRITES $20
#define STAGE_GEM_NB_STAGE_SPRITES 8
#define STAGE_GEM_FIRST_SPRITE_OAM_OFFSET STAGE_GEM_STAGE_SPRITES*4
#define STAGE_GEM_LAST_SPRITE_OAM_OFFSET (STAGE_GEM_STAGE_SPRITES+STAGE_GEM_NB_STAGE_SPRITES-1)*4
#define STAGE_GEM_GEM_SPRITE STAGE_GEM_STAGE_SPRITES

#define STAGE_GEM_GEM_SPRITE_OAM oam_mirror+STAGE_GEM_GEM_SPRITE*4

#define STAGE_GEM_GEM_SPAWN_X $80
#define STAGE_GEM_GEM_SPAWN_Y $30
#define STAGE_GEM_GEM_MAX_VELOCITY 2
#define STAGE_GEM_GEM_MIN_VELOCITY $fe

#define STAGE_GEM_GEM_HURTBOX_WIDTH 7
#define STAGE_GEM_GEM_HURTBOX_HEIGHT 7

#define STAGE_GEM_GEM_COOLDOWN_LSB 0
#define STAGE_GEM_GEM_COOLDOWN_MSB 2
#define STAGE_GEM_BREAK_DURATION 40
#define STAGE_GEM_BUFF_DURATION_LSB 0
#define STAGE_GEM_BUFF_DURATION_MSB 2
#define STAGE_GEM_BUFF_SCREEN_SHAKE_DURATION 20

#define STAGE_GEM_BUFF_DAMAGES 20

#define STAGE_GEM_GEM_STATE_COOLDOWN 0
#define STAGE_GEM_GEM_STATE_ACTIVE 1
#define STAGE_GEM_GEM_STATE_BREAKING 2
#define STAGE_GEM_GEM_STATE_BUFF 3

#define STAGE_GEM_HIDE_SPRITES .( :\
	lda #$fe :\
	ldx #STAGE_GEM_FIRST_SPRITE_OAM_OFFSET :\
	hide_one_sprite:\
		sta oam_mirror, x :\
		inx :\
		inx :\
		inx :\
		inx :\
		cpx #(STAGE_GEM_LAST_SPRITE_OAM_OFFSET)+4 :\
		bne hide_one_sprite :\
.)

; Pause music, avoid audio_mute_music which changes the configuration ;TODO This is hacky as fuck (and may break with new audio engine)
#define STAGE_GEM_PAUSE_MUSIC lda #%00001000 : sta APU_STATUS
; Play music, avoid audio_unmute_music which changes the configuration
#define STAGE_GEM_RESUME_MUSIC lda #%00001111 : sta APU_STATUS

stage_gem_init:
.(
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
		lda #>CHARACTERS_END_TILES_OFFSET
		sta PPUADDR
		lda #<CHARACTERS_END_TILES_OFFSET
		sta PPUADDR

		jsr cpu_to_ppu_copy_tileset
	.)

	; Put the gem in its initial state
	jsr stage_gem_set_state_cooldown

	; Init background animation
	lda #0
	sta stage_gem_frame_cnt

	rts
.)

stage_gem_netload:
.(
	; Load gem's state
	ldy esp_rx_buffer+0, x
	sty stage_gem_gem_state

	; Load fields for the new state
	lda gem_state_netload_routines_lsb, y
	sta tmpfield1
	lda gem_state_netload_routines_msb, y
	sta tmpfield2
	jmp (tmpfield1)

	gem_netload_cooldown:
	.(
		; Load state's variables
		lda esp_rx_buffer+1, x
		sta stage_gem_gem_cooldown_low
		lda esp_rx_buffer+2, x
		sta stage_gem_gem_cooldown_high

		; Ensure sprites consistency
		STAGE_GEM_HIDE_SPRITES

		rts
	.)

	gem_netload_active:
	.(
		; Load state's variables
		lda esp_rx_buffer+1, x
		sta stage_gem_gem_position_x_low
		lda esp_rx_buffer+2, x
		sta stage_gem_gem_position_x_high
		lda esp_rx_buffer+3, x
		sta stage_gem_gem_position_y_low
		lda esp_rx_buffer+4, x
		sta stage_gem_gem_position_y_high
		lda esp_rx_buffer+5, x
		sta stage_gem_gem_velocity_h_low
		lda esp_rx_buffer+6, x
		sta stage_gem_gem_velocity_h_high
		lda esp_rx_buffer+7, x
		sta stage_gem_gem_velocity_v_low
		lda esp_rx_buffer+8, x
		sta stage_gem_gem_velocity_v_high

		; Ensure sprites consistency
		STAGE_GEM_HIDE_SPRITES ; Note, just in case we were in "buff" state previously (should be really rare)

		;FIXME set X/Y position, else it won't show if in screen shake
		lda #TILE_GEM
		sta STAGE_GEM_GEM_SPRITE_OAM+1 ; Tile number
		lda #3
		sta STAGE_GEM_GEM_SPRITE_OAM+2 ; Attributes

		rts
	.)

	gem_netload_breaking:
	.(
		; Load state's variables
		lda esp_rx_buffer+1, x
		sta stage_gem_buffed_player

		; Ensure sprites consistency
		;  Nothing to do, animation code is called each frame

		; Ensure music is paused
		STAGE_GEM_PAUSE_MUSIC

		rts
	.)

	gem_netload_buff:
	.(
		; Load state's variables
		lda esp_rx_buffer+1, x
		sta stage_gem_gem_cooldown_low
		lda esp_rx_buffer+2, x
		sta stage_gem_gem_cooldown_high
		lda esp_rx_buffer+3, x
		sta stage_gem_last_opponent_state
		lda esp_rx_buffer+4, x
		sta stage_gem_buffed_player

		; Ensure sprites consistency
		;  Nothing to do, animation code is called each frame

		; Ensure music is running
		;  Note - This is fragile, if a game in "breaking" state loads to something else than "buff" state, the music will stay paused
		STAGE_GEM_RESUME_MUSIC

		rts
	.)

	gem_state_netload_routines_lsb:
	.byt <gem_netload_cooldown, <gem_netload_active, <gem_netload_breaking, <gem_netload_buff
	gem_state_netload_routines_msb:
	.byt >gem_netload_cooldown, >gem_netload_active, >gem_netload_breaking, >gem_netload_buff
.)

stage_gem_freezed_tick:
.(
	; Update gem breaking state if it is the cause of the freeze
	lda stage_gem_gem_state
	cmp #STAGE_GEM_GEM_STATE_BREAKING
	bne end

		jmp stage_gem_tick_state_breaking
		; No return, jump to subroutine

	end:
	rts
.)

stage_gem_tick:
.(
	.(
		; Update lava tiles
		;  NOTE - despite its name, stage_gem_frame_cnt is only used for one purpose, animating lava.
		;         If this change, the "inc" should certainly be done even in rollback mode.
		lda network_rollback_mode
		bne lava_tiles_ok

			inc stage_gem_frame_cnt
			lda #%0010000
			bit stage_gem_frame_cnt
			beq even_frame
				ldx #1
				jmp x_ok
			even_frame:
				ldx #0
			x_ok:

			lda lava_bg_frames_lsb, x
			sta tmpfield1
			lda lava_bg_frames_msb, x
			sta tmpfield2

			jsr last_nt_buffer
			ldy #0
			copy_one_byte:
				lda (tmpfield1), y
				sta nametable_buffers, x
				inx
				iny
				cpy #LAVA_TILE_ANIM_BUFF_LEN
				bne copy_one_byte

		lava_tiles_ok:

		; Call the correct tick routine according to gem's state
		ldx stage_gem_gem_state
		lda stage_gem_tick_state_routines_lsb, x
		sta tmpfield1
		lda stage_gem_tick_state_routines_msb, x
		sta tmpfield2
		jsr call_pointed_subroutine
		rts

		; gem state tick routines
		stage_gem_tick_state_routines_lsb:
			.byt <stage_gem_tick_state_cooldown, <stage_gem_tick_state_active, <stage_gem_tick_state_breaking, <stage_gem_tick_state_buff
		stage_gem_tick_state_routines_msb:
			.byt >stage_gem_tick_state_cooldown, >stage_gem_tick_state_active, >stage_gem_tick_state_breaking, >stage_gem_tick_state_buff
	.)

	stage_gem_tick_state_cooldown:
	.(
		; If cooldown reaches zero, activate the gem
		jsr dec_cooldown
		bne end

			jsr stage_gem_set_state_active

		end:
		rts
	.)

	stage_gem_tick_state_active:
	.(
		jsr move_gem

		lda network_rollback_mode
		bne end_place_gem
			jsr stage_gem_place_gem
		end_place_gem:

		jmp check_gem_hit

		;rts ; useless, jump to subroutine
	.)

	&stage_gem_tick_state_breaking:
	.(
		lda screen_shake_counter
		bne update_anim

			stop_anim:
			.(
				lda audio_music_enabled
				beq music_ok
					STAGE_GEM_RESUME_MUSIC
				music_ok:
				jmp stage_gem_set_state_buff
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
						lda #STAGE_GEM_BREAK_DURATION
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

							lda stage_gem_gem_position_x_high
							sta animation_position_x
							lda stage_gem_gem_position_y_high
							sta animation_position_y

							lda #0
							sta animation_direction
							sta animation_position_y_msb
							sta animation_position_x_msb

							ldx #1

							jsr stage_gem_draw_anim_frame
						.)

					end_draw_anim:
				.)

				; Audio effect
				lda #STAGE_GEM_BREAK_DURATION
				sec
				sbc screen_shake_counter
				tax
				jmp play_gem_hit

				;rts ; useless, jump to subroutine
			.)
	.)

	stage_gem_tick_state_buff:
	.(
		; Update buff animation
		lda network_rollback_mode
		bne end_update_anim

			lda stage_gem_gem_cooldown_low ; Compute current frame number (the animation must have exactly 8 frames)
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

			ldx stage_gem_buffed_player
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

			jsr stage_gem_draw_anim_frame

		end_update_anim:

		; Detect if the opponent just got thrown
		ldx stage_gem_buffed_player
		SWITCH_SELECTED_PLAYER
		lda player_a_state, x
		cmp stage_gem_last_opponent_state
		beq end_throw_handling
		cmp #PLAYER_STATE_THROWN
		bne end_throw_handling

			; Deal bonus damages
			lda #STAGE_GEM_BUFF_DAMAGES ; TODO Factorize with hurt_player subroutine code
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
			lda #STAGE_GEM_BUFF_SCREEN_SHAKE_DURATION
			sta screen_shake_counter

			; Remove the gem's buff
			lda #0 ; Tricky - set the cooldown to 1 so that the buff will disapear gracefully at the end of this subroutine
			sta stage_gem_gem_cooldown_high
			lda #1
			sta stage_gem_gem_cooldown_low

		end_throw_handling:

			; Save new opponent state
			lda player_a_state, x
			sta stage_gem_last_opponent_state

		; If cooldown reaches zero, return to gem cooldown
		jsr dec_cooldown
		bne end_cd_check

			jmp stage_gem_set_state_cooldown
			; No return, jump to subroutine

		end_cd_check:

		rts
	.)

	; Decrement the gem's cooldown value
	;  Sets Z flag if the new value is zero
	dec_cooldown:
	.(
		; Decrement cooldown
		lda stage_gem_gem_cooldown_low
		bne no_carry
			carry:
				dec stage_gem_gem_cooldown_high
			no_carry:
				dec stage_gem_gem_cooldown_low

		; Z flag = (stage_gem_gem_cooldown_low == 0 && stage_gem_gem_cooldown_high == 0)
		bne end
		lda stage_gem_gem_cooldown_high

		end:
		rts
	.)

	; Check if the gem got hit by a player
	check_gem_hit:
	.(
		; box_1 = gem's bounding box
		lda stage_gem_gem_position_x_high
		sta tmpfield1
		clc
		adc #STAGE_GEM_GEM_HURTBOX_WIDTH
		sta tmpfield2
		lda stage_gem_gem_position_y_high
		sta tmpfield3
		clc
		adc #STAGE_GEM_GEM_HURTBOX_HEIGHT
		sta tmpfield4
		lda #0
		sta tmpfield9
		sta tmpfield10
		sta tmpfield11
		sta tmpfield12

		; For each player, check if he hits the gem
		ldx #0
		check_one_player:

			; Skip check if hitbox is disabled
			lda player_a_hitbox_enabled, x
			beq next_player

			; box_2 = player's hitbox
			lda player_a_hitbox_left, x
			sta tmpfield5
			lda player_a_hitbox_left_msb, x
			sta tmpfield13

			lda player_a_hitbox_right, x
			sta tmpfield6
			lda player_a_hitbox_right_msb, x
			sta tmpfield14

			lda player_a_hitbox_top, x
			sta tmpfield7
			lda player_a_hitbox_top_msb, x
			sta tmpfield15

			lda player_a_hitbox_bottom, x
			sta tmpfield8
			lda player_a_hitbox_bottom_msb, x
			sta tmpfield16

			; Check collision
			jsr boxes_overlap
			beq gem_hit

			next_player:
			inx
			cpx #2
			bne check_one_player
			jmp end

		; The gem got hit, emphasis the breaking animation
		gem_hit:
			; Save buffed player number
			stx stage_gem_buffed_player

			; Set gem in breaking state
			jsr stage_gem_set_state_breaking

		end:
			rts
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
		SIGNED_CMP(stage_gem_gem_velocity_h_low, stage_gem_gem_velocity_h_high, #0, #STAGE_GEM_GEM_MAX_VELOCITY)
		bmi vel_h_max_ok
		lda #STAGE_GEM_GEM_MAX_VELOCITY
		sta stage_gem_gem_velocity_h_high
		lda #0
		sta stage_gem_gem_velocity_h_low
		vel_h_max_ok:

		; If MIN_VELOCITY >= velocity_h
		;    velocity_h = -MIN_VELOCITY
		SIGNED_CMP(#0, #STAGE_GEM_GEM_MIN_VELOCITY, stage_gem_gem_velocity_h_low, stage_gem_gem_velocity_h_high)
		bmi vel_h_min_ok:
		lda #STAGE_GEM_GEM_MIN_VELOCITY
		sta stage_gem_gem_velocity_h_high
		lda #0
		sta stage_gem_gem_velocity_h_low
		vel_h_min_ok:

		; If velocity_v >= MAX_VELOCITY
		;    velocity_v = MAX_VELOCITY
		SIGNED_CMP(stage_gem_gem_velocity_v_low, stage_gem_gem_velocity_v_high, #0, #STAGE_GEM_GEM_MAX_VELOCITY)
		bmi vel_v_max_ok
		lda #STAGE_GEM_GEM_MAX_VELOCITY
		sta stage_gem_gem_velocity_v_high
		lda #0
		sta stage_gem_gem_velocity_v_low
		vel_v_max_ok:

		; If MIN_VELOCITY >= velocity_v
		;    velocity_v = -MIN_VELOCITY
		SIGNED_CMP(#0, #STAGE_GEM_GEM_MIN_VELOCITY, stage_gem_gem_velocity_v_low, stage_gem_gem_velocity_v_high)
		bmi vel_v_min_ok:
		lda #STAGE_GEM_GEM_MIN_VELOCITY
		sta stage_gem_gem_velocity_v_high
		lda #0
		sta stage_gem_gem_velocity_v_low
		vel_v_min_ok:

		; Apply velocity to position
		lda stage_gem_gem_velocity_h_low
		clc
		adc stage_gem_gem_position_x_low
		sta stage_gem_gem_position_x_low
		lda stage_gem_gem_velocity_h_high
		adc stage_gem_gem_position_x_high
		sta stage_gem_gem_position_x_high

		lda stage_gem_gem_velocity_v_low
		clc
		adc stage_gem_gem_position_y_low
		sta stage_gem_gem_position_y_low
		lda stage_gem_gem_velocity_v_high
		adc stage_gem_gem_position_y_high
		sta stage_gem_gem_position_y_high

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
		sbc stage_gem_gem_position_x_high
		tax
		lda #0
		sbc #0
		tay

		txa ; Add to gem's velocity
		clc
		adc stage_gem_gem_velocity_h_low
		sta stage_gem_gem_velocity_h_low
		tya
		adc stage_gem_gem_velocity_h_high
		sta stage_gem_gem_velocity_h_high

		lda target_position_y ; XY = Target - G
		sec
		sbc stage_gem_gem_position_y_high
		tax
		lda #0
		sbc #0
		tay

		txa ; Add to gem's velocity
		clc
		adc stage_gem_gem_velocity_v_low
		sta stage_gem_gem_velocity_v_low
		tya
		adc stage_gem_gem_velocity_v_high
		sta stage_gem_gem_velocity_v_high

		rts
	.)
.)

; Puts the gem in cooldown
stage_gem_set_state_cooldown:
.(
	; Set the state
	lda #STAGE_GEM_GEM_STATE_COOLDOWN
	sta stage_gem_gem_state

	; Hide all stage's sprites
	STAGE_GEM_HIDE_SPRITES

	; Reset cooldown
	lda #STAGE_GEM_GEM_COOLDOWN_LSB
	sta stage_gem_gem_cooldown_low
	lda #STAGE_GEM_GEM_COOLDOWN_MSB
	sta stage_gem_gem_cooldown_high

	rts
.)

; Activate the gem
stage_gem_set_state_active:
.(
	; Set the state
	lda #STAGE_GEM_GEM_STATE_ACTIVE
	sta stage_gem_gem_state

	; Set gem's initial position and velocity
	lda #STAGE_GEM_GEM_SPAWN_X
	sta stage_gem_gem_position_x_high
	lda #STAGE_GEM_GEM_SPAWN_Y
	sta stage_gem_gem_position_y_high
	lda #0
	sta stage_gem_gem_position_x_low
	sta stage_gem_gem_position_y_low
	sta stage_gem_gem_velocity_h_low
	sta stage_gem_gem_velocity_h_high
	sta stage_gem_gem_velocity_v_low
	sta stage_gem_gem_velocity_v_high

	; Prepare gem sprite
	lda #TILE_GEM
	sta STAGE_GEM_GEM_SPRITE_OAM+1 ; Tile number
	lda #3
	sta STAGE_GEM_GEM_SPRITE_OAM+2 ; Attributes

	; Show gem
	.(
		lda network_rollback_mode
		beq show_gem
			rts
		show_gem:
			jmp stage_gem_place_gem
			; No return, jump to subroutine
	.)

	;rts ; useless, above code does it or jump to subroutine
.)

; Puts the gem in breaking state
stage_gem_set_state_breaking:
.(
	; Set the state
	lda #STAGE_GEM_GEM_STATE_BREAKING
	sta stage_gem_gem_state

	; Freeze the screen for the duration of the breaking animation
	lda #0
	sta screen_shake_nextval_x
	sta screen_shake_nextval_y
	lda #STAGE_GEM_BREAK_DURATION
	sta screen_shake_counter

	; Pause music
	STAGE_GEM_PAUSE_MUSIC

	rts
.)

; Buff the player
;  stage_gem_buffed_player shall already be set correctly
stage_gem_set_state_buff:
.(
	; Set the state
	lda #STAGE_GEM_GEM_STATE_BUFF
	sta stage_gem_gem_state

	; Reset cooldown
	lda #STAGE_GEM_BUFF_DURATION_LSB
	sta stage_gem_gem_cooldown_low
	lda #STAGE_GEM_BUFF_DURATION_MSB
	sta stage_gem_gem_cooldown_high

	; Store initial opponent state
	ldx stage_gem_buffed_player
	SWITCH_SELECTED_PLAYER
	lda player_a_state, x
	sta stage_gem_last_opponent_state

	rts
.)

; Place the OAM gem's sprite according to gem's position
stage_gem_place_gem:
.(
	lda stage_gem_gem_position_y_high
	sta STAGE_GEM_GEM_SPRITE_OAM
	lda stage_gem_gem_position_x_high
	sta STAGE_GEM_GEM_SPRITE_OAM+3
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
stage_gem_draw_anim_frame:
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

		ldx #STAGE_GEM_STAGE_SPRITES*4

		; Call sprite placing routine
		jsr animation_handle_sprites
	end_sprite_placing:

	; Clear unused sprites
	.(
		; X = offset of the first unused sprite
		pla
		clc
		adc #STAGE_GEM_STAGE_SPRITES
		asl
		asl
		tax

		; Clear sprites until the last reserved
		lda #$fe
		loop:
			cpx #4*(STAGE_GEM_STAGE_SPRITES+STAGE_GEM_NB_STAGE_SPRITES)
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

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
#define STAGE_GEM_GEM_STATE_BUFF 2

stage_gem_init:
.(
	; Generic initialization stuff
	jsr stage_generic_init

	; Copy stage's tiles in VRAM
	.(
		tileset_addr = tmpfield1 ; Not movable, used by cpu_to_ppu_copy_tiles
		;tileset_addr_msb = tmpfield2 ; Not movable, used by cpu_to_ppu_copy_tiles
		tiles_count = tmpfield3 ; Not movable, used by cpu_to_ppu_copy_tiles

		lda #<(tileset_stage_thehunt_sprites+1)
		sta tileset_addr
		lda #>(tileset_stage_thehunt_sprites+1)
		sta tileset_addr+1

		lda tileset_stage_thehunt_sprites
		sta tiles_count

		lda PPUSTATUS
		lda #>CHARACTERS_END_TILES_OFFSET
		sta PPUADDR
		lda #<CHARACTERS_END_TILES_OFFSET
		sta PPUADDR

		jsr cpu_to_ppu_copy_tiles
	.)

	; Put the gem in its initial state
	jsr stage_gem_set_state_cooldown

	; Init background animation
	lda #0
	sta stage_gem_frame_cnt

	rts
.)

stage_gem_tick:
.(
	.(
		; Update lava tiles
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
			.byt <stage_gem_tick_state_cooldown, <stage_gem_tick_state_active, <stage_gem_tick_state_buff
		stage_gem_tick_state_routines_msb:
			.byt >stage_gem_tick_state_cooldown, >stage_gem_tick_state_active, >stage_gem_tick_state_buff
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
		jsr stage_gem_place_gem
		jsr check_gem_hit
		rts
	.)

	stage_gem_tick_state_buff:
	.(
		; Update buff animation
		lda stage_gem_gem_cooldown_low ; Compute current frame number (the animation must have exactly 8 frames)
		lsr
		lsr
		and #%00000111
		tax

		lda gem_buff_frames_addr_lsb, x
		sta tmpfield3
		lda gem_buff_frames_addr_msb, x
		sta tmpfield4
		lda #STAGE_GEM_STAGE_SPRITES
		sta tmpfield5
		lda #STAGE_GEM_STAGE_SPRITES+STAGE_GEM_NB_STAGE_SPRITES-1
		sta tmpfield6

		ldx stage_gem_buffed_player
		stx player_number
		lda player_a_x, x
		sta tmpfield1
		lda player_a_y, x
		sta tmpfield2
		lda player_a_x_screen, x
		sta tmpfield8
		lda player_a_y_screen, x
		sta tmpfield9
		lda player_a_direction, x
		sta tmpfield7

		lda player_a_hitbox_enabled, x
		pha
		jsr draw_anim_frame
		pla
		ldx stage_gem_buffed_player
		sta player_a_hitbox_enabled, x

		; Detect if the opponent just got thrown
		ldx stage_gem_buffed_player
		jsr switch_selected_player
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

			jsr stage_gem_set_state_cooldown

		end_cd_check:

		rts
	.)

	; Decrement the gem's cooldown value
	;  Sets Z flag if the new value is zero
	dec_cooldown:
	.(
		; Decrement cooldown
		lda stage_gem_gem_cooldown_low
		sec
		sbc #1
		sta stage_gem_gem_cooldown_low
		lda stage_gem_gem_cooldown_high
		sbc #0
		sta stage_gem_gem_cooldown_high

		; Z flag = (stage_gem_gem_cooldown_high OR stage_gem_gem_cooldown_low) == 0
		ora stage_gem_gem_cooldown_low

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

			; Pause music and all animations but the breaking gem
			lda #%00001000 ; Pause music, avoid audio_mute_music which changes the configuration ;TODO This is hacky as fuck (and may break with new audio engine)
			sta APU_STATUS

			ldx #0
			break_tick:
				; Avoid the game loop
				jsr wait_next_frame

				; Update gem explosion animation
				txa
				pha
				jsr update_gem_explosion
				pla
				tax
				inx

				; Play explosion audio effect
				jsr play_gem_hit

				cpx #STAGE_GEM_BREAK_DURATION
				bne break_tick

			; Play music again, if the enabled
			lda audio_music_enabled
			beq music_ok
				lda #%00001111 ; Play music, avoid audio_unmute_music which changes the configuration
				sta APU_STATUS
			music_ok:

			; Activate the buff
			jsr stage_gem_set_state_buff

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

	; Draw the gem explosion animation
	;  Overwrites all registers and almost all tmpfields
	update_gem_explosion:
	.(
		; Search the current frame number
		txa
		lsr
		lsr
		tax
		cmp gem_explosion_last_frame_index
		bcc frame_number_ok
		lda gem_explosion_last_frame_index
		tax
		frame_number_ok:

		; Call draw_anim_frame
		lda stage_gem_gem_position_x_high
		sta tmpfield1
		lda stage_gem_gem_position_y_high
		sta tmpfield2
		lda gem_explosion_frames_addr_lsb, x
		sta tmpfield3
		lda gem_explosion_frames_addr_msb, x
		sta tmpfield4
		lda #STAGE_GEM_STAGE_SPRITES
		sta tmpfield5
		lda #STAGE_GEM_STAGE_SPRITES+STAGE_GEM_NB_STAGE_SPRITES-1
		sta tmpfield6
		lda #0
		sta tmpfield7
		sta tmpfield8
		sta tmpfield9
		lda #1
		stx player_number

		jsr draw_anim_frame

		rts
	.)

	; Update gem's position
	move_gem:
	.(
		; Compute new velocity
		jsr steering_go_between_players

		; Cap to max velocity
		lda #STAGE_GEM_GEM_MAX_VELOCITY   ; If velocity_h >= MAX_VELOCITY
		sta tmpfield9                     ;    velocity_h = MAX_VELOCITY
		lda #0
		sta tmpfield8
		lda stage_gem_gem_velocity_h_high
		sta tmpfield7
		lda stage_gem_gem_velocity_h_low
		sta tmpfield6
		jsr signed_cmp
		bmi vel_h_max_ok
		lda #STAGE_GEM_GEM_MAX_VELOCITY
		sta stage_gem_gem_velocity_h_high
		lda #0
		sta stage_gem_gem_velocity_h_low
		vel_h_max_ok:

		lda #STAGE_GEM_GEM_MIN_VELOCITY   ; If MIN_VELOCITY >= velocity_h
		sta tmpfield7                     ;    velocity_h = -MIN_VELOCITY
		lda #0
		sta tmpfield6
		lda stage_gem_gem_velocity_h_high
		sta tmpfield9
		lda stage_gem_gem_velocity_h_low
		sta tmpfield8
		jsr signed_cmp
		bmi vel_h_min_ok:
		lda #STAGE_GEM_GEM_MIN_VELOCITY
		sta stage_gem_gem_velocity_h_high
		lda #0
		sta stage_gem_gem_velocity_h_low
		vel_h_min_ok:

		lda #STAGE_GEM_GEM_MAX_VELOCITY   ; If velocity_v >= MAX_VELOCITY
		sta tmpfield9                     ;    velocity_v = MAX_VELOCITY
		lda #0
		sta tmpfield8
		lda stage_gem_gem_velocity_v_high
		sta tmpfield7
		lda stage_gem_gem_velocity_v_low
		sta tmpfield6
		jsr signed_cmp
		bmi vel_v_max_ok
		lda #STAGE_GEM_GEM_MAX_VELOCITY
		sta stage_gem_gem_velocity_v_high
		lda #0
		sta stage_gem_gem_velocity_v_low
		vel_v_max_ok:

		lda #STAGE_GEM_GEM_MIN_VELOCITY   ; If MIN_VELOCITY >= velocity_v
		sta tmpfield7                     ;    velocity_v = -MIN_VELOCITY
		lda #0
		sta tmpfield6
		lda stage_gem_gem_velocity_v_high
		sta tmpfield9
		lda stage_gem_gem_velocity_v_low
		sta tmpfield8
		jsr signed_cmp
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
	lda #$fe
	ldx #STAGE_GEM_FIRST_SPRITE_OAM_OFFSET
	hide_one_sprite:
		sta oam_mirror, x
		inx
		inx
		inx
		inx
		cpx #(STAGE_GEM_LAST_SPRITE_OAM_OFFSET)+4
		bne hide_one_sprite

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
	jsr stage_gem_place_gem

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
	jsr switch_selected_player
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

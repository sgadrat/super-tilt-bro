init_game_state:
.(
	.(
		; Clear background of nametable 2
		jsr clear_bg_bot_left

		; Ensure game state is zero
		ldx #$00
		lda #$00
		zero_game_state:
		sta $00, x
		inx
		cpx #ZERO_PAGE_GLOBAL_FIELDS_BEGIN
		bne zero_game_state

		; Call stage initialization routine
		lda config_selected_stage
		asl
		tax
		lda stages_init_routine, x
		sta tmpfield1
		lda stages_init_routine+1, x
		sta tmpfield2
		jsr call_pointed_subroutine

		; Reset screen shaking
		lda #0
		sta screen_shake_counter

		; Setup logical game state to the game startup configuration
		lda DIRECTION_LEFT
		sta player_b_direction

		lda DIRECTION_RIGHT
		sta player_a_direction

		lda HITBOX_DISABLED
		sta player_a_hitbox_enabled
		sta player_b_hitbox_enabled

		ldx #0
		position_player_loop:
			lda stage_data+STAGE_HEADER_OFFSET_PAY_HIGH, x
			sta player_a_y, x
			lda stage_data+STAGE_HEADER_OFFSET_PAY_LOW, x
			sta player_a_y_low, x
			lda stage_data+STAGE_HEADER_OFFSET_PAX_HIGH, x
			sta player_a_x, x
			lda stage_data+STAGE_HEADER_OFFSET_PAX_LOW, x
			sta player_a_x_low, x
			inx
			cpx #2
			bne position_player_loop

		lda #DEFAULT_GRAVITY
		sta player_a_gravity
		sta player_b_gravity
		lda config_initial_stocks
		sta player_a_stocks
		sta player_b_stocks

		lda #<player_a_animation                                       ;
		sta tmpfield11                                                 ;
		lda #>player_a_animation                                       ;
		sta tmpfield12                                                 ;
		jsr animation_init_state                                       ;
		lda #$00                                                       ;
		sta player_a_animation+ANIMATION_STATE_OFFSET_FIRST_SPRITE_NUM ;
		lda #$0f                                                       ;
		sta player_a_animation+ANIMATION_STATE_OFFSET_LAST_SPRITE_NUM  ; Initialize players animation state
		lda #<player_b_animation                                       ; (voluntarily let garbage in data vector, it will be overriden by initializing player's state)
		sta tmpfield11                                                 ;
		lda #>player_b_animation                                       ;
		sta tmpfield12                                                 ;
		jsr animation_init_state                                       ;
		lda #$10                                                       ;
		sta player_b_animation+ANIMATION_STATE_OFFSET_FIRST_SPRITE_NUM ;
		lda #$1f                                                       ;
		sta player_b_animation+ANIMATION_STATE_OFFSET_LAST_SPRITE_NUM  ;

		ldx #$00
		jsr start_spawn_player
		ldx #$01
		jsr start_spawn_player

		; Construct players palette swap buffers
		ldy #0 ; Y points on players_palettes's next byte

		jsr place_player_a_header
		ldx #0
		jsr place_character_palette
		jsr place_player_a_header
		ldx #0
		jsr place_alternate_palette

		jsr place_player_b_header
		ldx #1
		jsr place_character_palette
		jsr place_player_b_header
		ldx #1
		jsr place_alternate_palette

		; Initialize weapons palettes
		bit PPUSTATUS     ;
		lda #$80          ; Wait the begining of a VBI before
		wait_vbi:         ; writing data to PPU's palettes
			bit PPUSTATUS ;
			beq wait_vbi  ;

		lda #<weapon_palettes
		sta tmpfield2
		lda #>weapon_palettes
		sta tmpfield3

		ldx #$15
		lda config_player_a_weapon_palette
		sta tmpfield1
		jsr copy_palette_to_ppu

		ldx #$1d
		lda config_player_b_weapon_palette
		sta tmpfield1
		jsr copy_palette_to_ppu

		; Move sprites according to the initial state
		jsr update_sprites

		; Change for ingame music
		jsr audio_music_power

		; Initialize AI
		jsr ai_init

		rts
	.)

	place_player_a_header:
	.(
		ldx #0
		copy_one_byte:
		lda header_player_a, x
		sta players_palettes, y
		iny
		inx
		cpx #4
		bne copy_one_byte
		rts
	.)

	place_player_b_header:
	.(
		ldx #0
		copy_one_byte:
		lda header_player_b, x
		sta players_palettes, y
		iny
		inx
		cpx #4
		bne copy_one_byte
		rts
	.)

	place_character_palette:
	.(
		lda config_player_a_character_palette, x
		asl
		;clc ; useless, asl shall not overflow
		adc config_player_a_character_palette, x
		tax
		lda character_palettes, x
		sta players_palettes, y
		iny
		inx
		lda character_palettes, x
		sta players_palettes, y
		iny
		inx
		lda character_palettes, x
		sta players_palettes, y
		iny
		inx

		lda #0
		sta players_palettes, y
		iny

		rts
	.)

	place_alternate_palette:
	.(
		lda config_player_a_character_palette, x
		asl
		;clc ; useless, asl shall not overflow
		adc config_player_a_character_palette, x
		tax
		lda character_palettes_alternate, x
		sta players_palettes, y
		iny
		inx
		lda character_palettes_alternate, x
		sta players_palettes, y
		iny
		inx
		lda character_palettes_alternate, x
		sta players_palettes, y
		iny
		inx

		lda #0
		sta players_palettes, y
		iny

		rts
	.)

	header_player_a:
	.byt $01, $3f, $11, $03
	header_player_b:
	.byt $01, $3f, $19, $03
.)

game_tick:
.(
	; Remove processed nametable buffers
	jsr reset_nt_buffers

	; Shake screen and do nothing until shaking is over
	lda screen_shake_counter
	beq no_screen_shake
	jsr shake_screen
	ldx #0
	jsr player_effects
	ldx #1
	jsr player_effects
	jsr particle_draw
	rts
	no_screen_shake:

	; Do nothing during a slowdown skipped frame
	lda slow_down_counter
	beq no_slowdown
	jsr slowdown
	lda tmpfield1
	bne end
	no_slowdown:

	; Call stage's logic
	lda config_selected_stage
	asl
	tax
	lda stages_tick_routine, x
	sta tmpfield1
	lda stages_tick_routine+1, x
	sta tmpfield2
	jsr call_pointed_subroutine

	; Process AI - this override controller B state
	lda config_ai_level
	beq end_ai
	jsr ai_tick
	end_ai:

	; Update game state
	jsr update_players

	; Update screen
	jsr update_sprites

	end:
	rts
.)

; Set tmpfield1 to 1 if ne current frame need to be skipped, follow to gameover
; screen when the counter goes to zero
slowdown:
.(
	dec slow_down_counter
	beq next_screen
	lda slow_down_counter
	and #%00000011
	beq keep_frame
		lda #1
		sta tmpfield1
		jmp end
	keep_frame:
		lda #0
		sta tmpfield1
		jmp end

	next_screen:
	lda #GAME_STATE_GAMEOVER
	jsr change_global_game_state

	end:
	rts
.)

update_players:
.(
	; Decrement hitstun counters
	ldx #$00
	hitstun_one_player:
		lda player_a_hitstun, x
		beq hitstun_next_player
		dec player_a_hitstun, x
	hitstun_next_player:
		inx
		cpx #$02
		bne hitstun_one_player

	; Check hitbox collisions
	ldx #$00
	hitbox_one_player:
		jsr check_player_hit
		inx
		cpx #$02
		bne hitbox_one_player

	; Update both players
	ldx #$00 ; player number
	update_one_player:

		; Call the state update routine
		lda #<sinbad_state_update_routines
		sta tmpfield1
		lda #>sinbad_state_update_routines
		sta tmpfield2
		jsr player_state_action

		; Call the state input routine if input changed
		lda controller_a_btns, x
		cmp controller_a_last_frame_btns, x
		beq end_input_event
			lda #<sinbad_state_input_routines
			sta tmpfield1
			lda #>sinbad_state_input_routines
			sta tmpfield2
			jsr player_state_action
		end_input_event:

		; Call generic update routines
		jsr move_player
		jsr check_player_position
		jsr write_player_damages
		jsr player_effects

	inx
	cpx #$02
	bne update_one_player

	rts
.)

; Calls a subroutine depending on player's state
;  register X - Player number
;  tmpfield1 - Jump table address (low byte)
;  tmpfield2 - Jump table address (high bute)
player_state_action:
.(
	jump_table = tmpfield1

	; Convert player state number to vector address (relative to table begining)
	lda player_a_state, x       ; Y = state * 2
	asl                         ; (as each element is 2 bytes long)
	tay                         ;

	; Push the state's routine address to the stack
	lda (jump_table), y
	pha
	iny
	lda (jump_table), y
	pha

	; Return to the state's routine, it will itself return to player_state_action's caller
	rts
.)

check_player_hit:
.(
	current_player = tmpfield10
	opponent_player = tmpfield11

	; Store current player number
	stx current_player

	; Check that player's hitbox is enabled
	lda player_a_hitbox_enabled, x
	bne process_checks
	jmp end
	process_checks:

		; Store current player's hitbox
		lda player_a_hitbox_left, x
		sta tmpfield1
		lda player_a_hitbox_right, x
		sta tmpfield2
		lda player_a_hitbox_top, x
		sta tmpfield3
		lda player_a_hitbox_bottom, x
		sta tmpfield4

		; Switch current player to select the opponent
		jsr switch_selected_player

		; Store opponent player number
		stx opponent_player

		; If opponent's hitbox is enabled, check hitbox on hitbox collisions
		lda player_a_hitbox_enabled, x
		beq check_hitbox_hurtbox

			; Store opponent's hitbox
			lda player_a_hitbox_left, x
			sta tmpfield5
			lda player_a_hitbox_right, x
			sta tmpfield6
			lda player_a_hitbox_top, x
			sta tmpfield7
			lda player_a_hitbox_bottom, x
			sta tmpfield8

			; Check collisions between hitbox and hitbox
			jsr boxes_overlap
			lda tmpfield9
			bne check_hitbox_hurtbox

			; Play parry sound
			jsr audio_play_parry

			; Hitboxes collide, set opponent in thrown mode without momentum
			lda #HITSTUN_PARRY_NB_FRAMES
			sta player_a_hitstun, x
			lda #$00
			sta player_a_velocity_h, x
			sta player_a_velocity_h_low, x
			sta player_a_velocity_v, x
			sta player_a_velocity_v_low, x
			jsr start_thrown_player
			lda #SCREENSHAKE_PARRY_INTENSITY
			sta screen_shake_nextval_x
			sta screen_shake_nextval_y
			lda #SCREENSHAKE_PARRY_NB_FRAMES
			sta screen_shake_counter
			jmp end

		check_hitbox_hurtbox:

			; Store opponent's hurtbox
			lda player_a_hurtbox_left, x
			sta tmpfield5
			lda player_a_hurtbox_right, x
			sta tmpfield6
			lda player_a_hurtbox_top, x
			sta tmpfield7
			lda player_a_hurtbox_bottom, x
			sta tmpfield8

			; Check collisions between hitbox and hurtbox
			jsr boxes_overlap
			lda tmpfield9
			bne end

			lda #<sinbad_state_onhurt_routines ;
			sta tmpfield1                      ;
			lda #>sinbad_state_onhurt_routines ; Fire on-hurt event
			sta tmpfield2                      ;
			jsr player_state_action            ;

	end:
	; Reset register X to the current player
	ldx current_player
	rts
.)

; Throw the hurted player depending on the hitbox hurting him
;  tmpfield10 - Player number of the striker
;  tmpfield11 - Player number of the stroke
;  register X - Player number of the stroke (equals to tmpfield11)
;
;  Can overwrite any register and any tmpfield except tmpfield10 and tmpfield11.
hurt_player:
.(
	current_player = tmpfield10
	opponent_player = tmpfield11

	; Play hit sound
	jsr audio_play_hit

	; Apply force vector to the opponent
	jsr apply_force_vector

	; Apply damages to the opponent
	ldx current_player
	lda player_a_hitbox_damages, x ; Put hitbox damages in A
	ldx opponent_player
	clc                     ;
	adc player_a_damages, x ;
	cmp #200                ;
	bcs cap_damages         ; Apply damages, capped to 199
	jmp apply_damages:      ;
	cap_damages:            ;
	lda #199                ;
	apply_damages:          ;
	sta player_a_damages, x ;

	; Set opponent to thrown state
	jsr start_thrown_player

	; Disable the hitbox to avoid multi-hits
	ldx current_player
	lda HITBOX_DISABLED
	sta player_a_hitbox_enabled, x

	rts
.)

; Apply force in current player's hitbox to it's opponent
;
; Overwrites every tmpfields except "current_player" and "opponent_player".
; Overwrites registers A and  X (set to the opponent player's number).
apply_force_vector:
.(
	base_h_low = tmpfield6
	base_h_high = tmpfield7
	base_v_low = tmpfield8
	base_v_high = tmpfield9
	current_player = tmpfield10
	opponent_player = tmpfield11
	force_h = tmpfield12
	force_v = tmpfield13
	force_h_low = tmpfield14
	force_v_low = tmpfield15
	knockback_h_high = force_h    ; knockback_h reuses force_h memory location
	knockback_h_low = force_h_low ; it is only writen after the last read of force_h
	knockback_v_high = force_v     ; knockback_v reuses force_v memory location
	knockback_v_low = force_v_low  ; it is only writen after the last read of force_v

	; Apply force vector to the opponent
	ldx current_player
	lda player_a_hitbox_force_h, x     ;
	sta force_h                        ;
	lda player_a_hitbox_force_h_low, x ;
	sta force_h_low                    ; Save force vector to a player independent
	lda player_a_hitbox_force_v, x     ; location
	sta force_v                        ;
	lda player_a_hitbox_force_v_low, x ;
	sta force_v_low                    ;
	lda player_a_hitbox_base_knock_up_h_high, x ;
	sta base_h_high                             ;
	lda player_a_hitbox_base_knock_up_h_low, x  ;
	sta base_h_low                              ; Save base knock up to a player independent
	lda player_a_hitbox_base_knock_up_v_high, x ; location
	sta base_v_high                             ;
	lda player_a_hitbox_base_knock_up_v_low, x  ;
	sta base_v_low                              ;
	ldx opponent_player
	lda player_a_damages, x ;
	lsr                     ; Get force multiplier
	lsr                     ; "damages / 4"
	sta tmpfield3           ;
	lda force_h     ;
	sta tmpfield2   ;
	lda force_h_low ;
	sta tmpfield1   ;
	jsr multiply    ; Compute horizontal knockback
	lda base_h_low  ; "force_h * multiplier + base_h"
	clc             ;
	adc tmpfield4   ;
	sta tmpfield4   ;
	lda base_h_high ;
	adc tmpfield5   ;
	sta player_a_velocity_h, x     ;
	lda tmpfield4                  ; Apply horizontal knockback
	sta player_a_velocity_h_low, x ;
	lda force_v      ;
	sta tmpfield2    ;
	lda force_v_low  ;
	sta tmpfield1    ;
	jsr multiply     ; Compute vertical knockback
	lda base_v_low   ; "force_v * multiplier + base_v"
	clc              ;
	adc tmpfield4    ;
	lda base_v_high  ;
	adc tmpfield5    ;
	sta player_a_velocity_v, x     ;
	lda tmpfield4                  ; Apply vertical knockback
	sta player_a_velocity_v_low, x ;

	; Apply hitstun to the opponent
	; hitstun duration = high byte of 2 * (abs(velotcity_v) + abs(velocity_h))
	lda player_a_velocity_h, x     ;
	bpl end_abs_kb_h               ;
	lda player_a_velocity_h_low, x ;
	eor #%11111111                 ;
	clc                            ;
	adc #$01                       ; knockback_h = abs(velocity_h)
	sta knockback_h_low            ;
	lda player_a_velocity_h, x     ;
	eor #%11111111                 ;
	adc #$00                       ;
	end_abs_kb_h:                  ;
	sta knockback_h_high           ;

	lda player_a_velocity_v, x      ;
	bpl end_abs_kb_v                ;
	lda player_a_velocity_v_low, x  ;
	eor #%11111111                  ;
	clc                             ;
	adc #$01                        ; knockback_v = abs(velocity_v)
	sta knockback_v_low             ;
	lda player_a_velocity_v, x      ;
	eor #%11111111                  ;
	adc #$00                        ;
	end_abs_kb_v:                   ;
	sta knockback_v_high            ;

	lda knockback_h_low  ;
	clc                  ;
	adc knockback_v_low  ;
	sta knockback_h_low  ; knockback_h = knockback_v + knockback_h
	lda knockback_h_high ;
	adc knockback_v_high ;
	sta knockback_h_high ;

	asl knockback_h_low     ;
	lda knockback_h_high    ; Oponent player hitstun = high byte of 2 * knockback_h
	rol                     ;
	sta player_a_hitstun, x ;

	; Start screenshake of duration = hitstun / 2
	lsr
	sta screen_shake_counter
	lda player_a_velocity_h, x
	sta screen_shake_nextval_x
	lda player_a_velocity_v, x
	sta screen_shake_nextval_y

	; Start directional indicator particles
	jsr particle_directional_indicator_start

	rts
.)

; Move the player according to it's velocity and collisions with obstacles
;  register X - player number
;
;  When returning player's position is updated, tmpfield1 contains it's old X
;  and tmpfield2 contains it's old Y
move_player:
.(
	old_x = tmpfield1 ; Not movable, return value and parameter of check_collision
	old_y = tmpfield2 ; Not movable, return value and parameter of check_collision
	final_x_low = tmpfield9 ; Not movable, parameter of check_collision
	final_x_high = tmpfield3 ; Not movable, parameter of check_collision
	final_y_low = tmpfield10 ; Not movable, parameter of check_collision
	final_y_high = tmpfield4 ; Not movable, parameter of check_collision
	obstacle_left = tmpfield5 ; Not movable, parameter of check_collision
	obstacle_top = tmpfield6 ; Not movable, parameter of check_collision
	obstacle_right = tmpfield7 ; Not movable, parameter of check_collision
	obstacle_bottom = tmpfield8 ; Not movable, parameter of check_collision
	action_vector = tmpfield14

	; Save old position
	lda player_a_x, x
	sta old_x
	lda player_a_y, x
	sta old_y

	; Apply velocity to position
	lda player_a_velocity_h_low, x
	clc
	adc player_a_x_low, x
	sta final_x_low
	lda player_a_velocity_h, x
	adc player_a_x, x
	sta final_x_high

	lda player_a_velocity_v_low, x
	clc
	adc player_a_y_low, x
	sta final_y_low
	lda player_a_velocity_v, x
	adc player_a_y, x
	sta final_y_high

	; Check collisions with stage plaforms
	ldy #0

	check_platform_colision:
	txa
	pha
	ldx stage_data+STAGE_OFFSET_PLATFORMS, y
	lda platform_actions_low, x
	sta action_vector
	lda platform_actions_high, x
	sta action_vector+1
	pla
	tax
	jmp (action_vector)

	end:
	rts

	end_platforms:
	.(
		jmp end
	.)

	solid_platform_collision:
	.(
		lda stage_data+STAGE_OFFSET_PLATFORMS+STAGE_PLATFORM_OFFSET_LEFT, y
		sta obstacle_left
		lda stage_data+STAGE_OFFSET_PLATFORMS+STAGE_PLATFORM_OFFSET_TOP, y
		sta obstacle_top
		lda stage_data+STAGE_OFFSET_PLATFORMS+STAGE_PLATFORM_OFFSET_RIGHT, y
		sta obstacle_right
		lda stage_data+STAGE_OFFSET_PLATFORMS+STAGE_PLATFORM_OFFSET_BOTTOM, y
		sta obstacle_bottom

		jsr check_collision
		lda final_x_high
		sta player_a_x, x
		lda final_y_high
		sta player_a_y, x
		lda final_x_low
		sta player_a_x_low, x
		lda final_y_low
		sta player_a_y_low, x

		tya
		clc
		adc #STAGE_PLATFORM_LENGTH
		tay
		jmp check_platform_colision
	.)

	smooth_platform_collision:
	.(
		lda stage_data+STAGE_OFFSET_PLATFORMS+STAGE_PLATFORM_OFFSET_LEFT, y
		sta obstacle_left
		lda stage_data+STAGE_OFFSET_PLATFORMS+STAGE_PLATFORM_OFFSET_TOP, y
		sta obstacle_top
		lda stage_data+STAGE_OFFSET_PLATFORMS+STAGE_PLATFORM_OFFSET_RIGHT, y
		sta obstacle_right

		jsr check_top_collision
		lda final_x_high
		sta player_a_x, x
		lda final_y_high
		sta player_a_y, x
		lda final_x_low
		sta player_a_x_low, x
		lda final_y_low
		sta player_a_y_low, x

		tya
		clc
		adc #STAGE_SMOOTH_PLATFORM_LENGTH
		tay
		jmp check_platform_colision
	.)

	platform_actions_low:
		.byt <end_platforms
		.byt <solid_platform_collision
		.byt <smooth_platform_collision
	platform_actions_high:
		.byt >end_platforms
		.byt >solid_platform_collision
		.byt >smooth_platform_collision
.)

; Check the player's position and modify the current state accordingly
;  register X - player number
;  tmpfield1 - player's old X
;  tmpfield2 - player's old Y
;
;  Overwrites tmpfield1 and tmpfield2
check_player_position:
.(
	old_x = tmpfield1 ; Not movable, used by particle_death_start
	old_y = tmpfield2 ; Not movable, used by particle_death_start

	; Check death
	lda player_a_velocity_h, x
	bpl check_right_blast
	lda old_x           ; Horizontal velocity is negative
	cmp player_a_x, x   ; die if "old X < new X"
	bcc set_death_state ;
	jmp check_vertical_blasts
	check_right_blast:
	lda player_a_x, x   ; Horizontal velocity is positive
	cmp old_x           ; die if "new X < old X"
	bcc set_death_state ;
	check_vertical_blasts:
	lda player_a_velocity_v, x
	bpl check_bottom_blast
	lda old_y           ; Vertical velocity is negative
	cmp player_a_y, x   ; die if "old Y < new Y"
	bcc set_death_state ;
	jmp end_death_checks
	check_bottom_blast:
	lda player_a_y, x   ; Vertical velocity is positive
	cmp old_y           ; die if "new Y < old Y"
	bcc set_death_state ;
	end_death_checks:

	; Check if on ground
	jsr check_on_ground
	bne offground

		; On ground
		lda #$00                         ; Reset aerial jumps counter
		sta player_a_num_aerial_jumps, x ;
		lda #DEFAULT_GRAVITY    ; Reset gravity modifications
		sta player_a_gravity, x ;
		lda #<sinbad_state_onground_routines ;
		sta tmpfield1                        ;
		lda #>sinbad_state_onground_routines ; Fire on-ground event
		sta tmpfield2                        ;
		jsr player_state_action              ;
		jmp end

	offground:
		lda #<sinbad_state_offground_routines
		sta tmpfield1
		lda #>sinbad_state_offground_routines
		sta tmpfield2
		jsr player_state_action
		jmp end

	set_death_state:
		jsr audio_play_death ; Play death sound
		lda #$00                         ; Reset aerial jumps counter
		sta player_a_num_aerial_jumps, x ;
		sta player_a_hitstun, x ; Reset hitstun counter
		lda #DEFAULT_GRAVITY     ; Reset gravity
		sta player_a_gravity, x  ;
		jsr particle_death_start ; Death particles animation
		dec player_a_stocks, x ; Decrement stocks counter and check for gameover
		bmi gameover           ;
		jsr start_respawn_player ; Respawn
		jmp end

	gameover:
		lda slow_down_counter      ;
		bne no_set_winner          ;
		jsr switch_selected_player ;
		txa                        ; Set the winner for gameover screen
		sta gameover_winner        ;
		jsr switch_selected_player ;
		no_set_winner:             ;
		lda #0                 ; Do not keep an invalid number of stocks
		sta player_a_stocks, x ;
		jsr start_innexistant_player ; Hide dead player
		lda #SLOWDOWN_TIME    ; Start slow down (restart it if the second player die to
		sta slow_down_counter ; show that heroic death's animation)

	end:
	rts
.)

; Show on screen player's damages
;  register X must contain the player number
write_player_damages:
.(
	damages_ppu_position = tmpfield4
	stocks_ppu_position = tmpfield7
	player_stocks = tmpfield8

	; Save X
	txa
	pha

	; Set on-screen text position depending on the player
	cpx #$00
	beq prepare_player_a
	lda #$54
	sta damages_ppu_position
	lda #$14
	sta stocks_ppu_position
	jmp end_player_variables
	prepare_player_a:
	lda #$48
	sta damages_ppu_position
	lda #$08
	sta stocks_ppu_position
	end_player_variables:

	; Put damages value parameter for number_to_tile_indexes
	lda player_a_damages, x
	sta tmpfield1
	lda player_a_stocks, x
	sta player_stocks

	; Write the begining of the damage buffer
	jsr last_nt_buffer
	lda #$01                 ; Continuation byte
	sta nametable_buffers, x ;
	inx
	lda #$23                 ; PPU address MSB
	sta nametable_buffers, x ;
	inx
	lda damages_ppu_position ; PPU address LSB
	sta nametable_buffers, x ;
	inx
	lda #$03                 ; Tiles count
	sta nametable_buffers, x ;
	inx

	; Store the tiles address as destination parameter for number_to_tile_indexes
	txa
	sta tmpfield2
	lda #>nametable_buffers
	sta tmpfield3

	; Set the next continuation byte to 0
	inx
	inx
	inx
	lda #$00
	sta nametable_buffers, x

	; Populate tiles data for damage buffer
	jsr number_to_tile_indexes

	; Construct stocks buffers
	ldy #$00
	jsr last_nt_buffer
	stocks_buffer:
	lda #$01                 ; Continuation byte
	sta nametable_buffers, x ;
	inx
	lda #$23                 ; PPU address MSB
	sta nametable_buffers, x ;
	inx
	lda stocks_ppu_position  ; PPU address LSB
	clc                      ;
	adc stocks_positions, y  ;
	sta nametable_buffers, x ;
	inx
	lda #$01                 ; Tiles count
	sta nametable_buffers, x ;
	inx
	cpy player_stocks        ;
	bcs empty_stock          ;
	lda #$cf                 ;
	jmp set_stock_tile       ; Set stock tile depending of the
	empty_stock:             ; stock's availability
	lda #$00                 ;
	set_stock_tile:          ;
	sta nametable_buffers, x ;
	inx
	iny               ;
	cpy #$04          ; Loop for each stock to print
	bne stocks_buffer ;
	lda #$00                 ; Next continuation byte to 0
	sta nametable_buffers, x ;

	; Restore X
	pla
	tax

	rts

	stocks_positions:
	.byt 0, 3, 32, 35
.)

; Update comestic effects on the player
;  register X must contain the player number
player_effects:
.(
	.(
		jsr blinking
		jsr particle_directional_indicator_tick
		jsr particle_death_tick
		rts
	.)

	; Change palette according to player's state
	;  register X must contain the player number
	blinking:
	.(
		palette_buffer = tmpfield1
		;                tmpfield2
#define PLAYER_EFFECTS_PALLETTE_SIZE 8

		lda #<players_palettes ;
		sta palette_buffer     ; palette_buffer points on the first players' palette
		lda #>players_palettes ;
		sta palette_buffer+1   ;

		; Add palette offset related to hitstun state
		lda player_a_hitstun, x
		and #%00000010
		beq no_hitstun
		lda palette_buffer
		clc
		adc #PLAYER_EFFECTS_PALLETTE_SIZE
		sta palette_buffer
		lda palette_buffer+1
		adc #0
		sta palette_buffer+1
		no_hitstun:

		; Add palette offset related to player number
		cpx #1
		bne player_one
		lda palette_buffer
		clc
		adc #PLAYER_EFFECTS_PALLETTE_SIZE*2
		sta palette_buffer
		lda palette_buffer+1
		adc #0
		sta palette_buffer+1
		player_one:

		; Copy pointed palette to a nametable buffer
		txa                ;
		pha                ; Initialize working values
		jsr last_nt_buffer ; X = destination's offset (from nametable_buffers)
		ldy #0             ; Y = source's offset (from (palette_buffer) origin)

		copy_one_byte:
		lda (palette_buffer), y  ; Copy a byte
		sta nametable_buffers, x ;

		inx                               ;
		iny                               ; Prepare next byte
		cpy #PLAYER_EFFECTS_PALLETTE_SIZE ;
		bne copy_one_byte                 ;

		pla ; Restore X
		tax ;

		rts
	.)
.)

update_sprites:
.(
	; Pretty names
	animation_vector = tmpfield11 ; Not movable - Used as parameter for stb_animation_draw subroutine
	camera_x = tmpfield13         ; Not movable - Used as parameter for stb_animation_draw subroutine
	camera_y = tmpfield15         ; Not movable - Used as parameter for stb_animation_draw subroutine

	; Player A
	lda player_a_x
	sta player_a_animation+ANIMATION_STATE_OFFSET_X_LSB
	lda player_a_y
	sta player_a_animation+ANIMATION_STATE_OFFSET_Y_LSB
	lda #0
	sta player_a_animation+ANIMATION_STATE_OFFSET_X_MSB
	sta player_a_animation+ANIMATION_STATE_OFFSET_Y_MSB

	lda #<player_a_animation
	sta animation_vector
	lda #>player_a_animation
	sta animation_vector+1
	lda #0
	sta camera_x
	sta camera_x+1
	sta camera_y
	sta camera_y+1
	sta player_number
	jsr stb_animation_draw
	jsr animation_tick

	; Player B
	lda player_b_x
	sta player_b_animation+ANIMATION_STATE_OFFSET_X_LSB
	lda player_b_y
	sta player_b_animation+ANIMATION_STATE_OFFSET_Y_LSB
	lda #0
	sta player_b_animation+ANIMATION_STATE_OFFSET_X_MSB
	sta player_b_animation+ANIMATION_STATE_OFFSET_Y_MSB

	lda #<player_b_animation
	sta animation_vector
	lda #>player_b_animation
	sta animation_vector+1
	lda #0
	sta camera_x
	sta camera_x+1
	sta camera_y
	sta camera_y+1
	lda #1
	sta player_number
	jsr stb_animation_draw
	jsr animation_tick

	; Enhancement sprites
	jsr particle_draw
	;jsr show_hitboxes

	rts
.)

; Debug subroutine to show hitboxes and hurtboxes
;show_hitboxes:
;.(
;	pha
;	txa
;	pha
;	tya
;	pha
;
;	; Player A hurtbox
;	ldx #$fc
;	lda player_a_hurtbox_top
;	sta oam_mirror, x
;	inx
;	lda #$0d
;	sta oam_mirror, x
;	inx
;	lda #$03
;	sta oam_mirror, x
;	inx
;	lda player_a_hurtbox_left
;	sta oam_mirror, x
;	inx
;	ldx #$f8
;	lda player_a_hurtbox_bottom
;	sec
;	sbc #$07
;	sta oam_mirror, x
;	inx
;	lda #$0d
;	sta oam_mirror, x
;	inx
;	lda #$03
;	sta oam_mirror, x
;	inx
;	lda player_a_hurtbox_right
;	sec
;	sbc #$07
;	sta oam_mirror, x
;	inx
;
;	; Player B hurtbox
;	ldx #$f4
;	lda player_b_hurtbox_top
;	sta oam_mirror, x
;	inx
;	lda #$0d
;	sta oam_mirror, x
;	inx
;	lda #$03
;	sta oam_mirror, x
;	inx
;	lda player_b_hurtbox_left
;	sta oam_mirror, x
;	inx
;	ldx #$f0
;	lda player_b_hurtbox_bottom
;	sec
;	sbc #$07
;	sta oam_mirror, x
;	inx
;	lda #$0d
;	sta oam_mirror, x
;	inx
;	lda #$03
;	sta oam_mirror, x
;	inx
;	lda player_b_hurtbox_right
;	sec
;	sbc #$07
;	sta oam_mirror, x
;	inx
;
;	; Player A hitbox
;	lda player_a_hitbox_enabled
;	bne show_player_a_hitbox
;	lda #$fe  ;
;	sta $02e8 ;
;	sta $02e9 ;
;	sta $02ea ;
;	sta $02eb ; Hide disabled hitbox
;	sta $02ec ;
;	sta $02ed ;
;	sta $02ee ;
;	sta $02ef ;
;	jmp end_player_a_hitbox
;	show_player_a_hitbox:
;	ldx #$ec
;	lda player_a_hitbox_top
;	sta oam_mirror, x
;	inx
;	lda #$0e
;	sta oam_mirror, x
;	inx
;	lda #$03
;	sta oam_mirror, x
;	inx
;	lda player_a_hitbox_left
;	sta oam_mirror, x
;	inx
;	ldx #$e8
;	lda player_a_hitbox_bottom
;	sec
;	sbc #$07
;	sta oam_mirror, x
;	inx
;	lda #$0e
;	sta oam_mirror, x
;	inx
;	lda #$03
;	sta oam_mirror, x
;	inx
;	lda player_a_hitbox_right
;	sec
;	sbc #$07
;	sta oam_mirror, x
;	inx
;	end_player_a_hitbox
;
;	; Player B hitbox
;	lda player_b_hitbox_enabled
;	bne show_player_b_hitbox
;	lda #$fe  ;
;	sta $02e0 ;
;	sta $02e1 ;
;	sta $02e2 ;
;	sta $02e3 ; Hide disabled hitbox
;	sta $02e4 ;
;	sta $02e5 ;
;	sta $02e6 ;
;	sta $02e7 ;
;	jmp end_player_b_hitbox
;	show_player_b_hitbox:
;	ldx #$e4
;	lda player_b_hitbox_top
;	sta oam_mirror, x
;	inx
;	lda #$0e
;	sta oam_mirror, x
;	inx
;	lda #$03
;	sta oam_mirror, x
;	inx
;	lda player_b_hitbox_left
;	sta oam_mirror, x
;	inx
;	ldx #$e0
;	lda player_b_hitbox_bottom
;	sec
;	sbc #$07
;	sta oam_mirror, x
;	inx
;	lda #$0e
;	sta oam_mirror, x
;	inx
;	lda #$03
;	sta oam_mirror, x
;	inx
;	lda player_b_hitbox_right
;	sec
;	sbc #$07
;	sta oam_mirror, x
;	inx
;	end_player_b_hitbox
;
;	; Player A hitstun indicator
;	lda player_a_hitstun
;	bne show_player_a_hitstun
;	lda #$fe  ;
;	sta $02dc ;
;	sta $02dd ; Hide disabled hitstun
;	sta $02de ;
;	sta $02df ;
;	jmp end_player_a_hitstun
;	show_player_a_hitstun:
;	ldx #$dc
;	lda #$10
;	sta oam_mirror, x
;	sta oam_mirror+3, x
;	lda #$0e
;	sta oam_mirror+1, x
;	lda #$03
;	sta oam_mirror+2, x
;	end_player_a_hitstun:
;
;	; Player B hitstun indicator
;	lda player_b_hitstun
;	bne show_player_b_hitstun
;	lda #$fe  ;
;	sta $02d8 ;
;	sta $02d9 ; Hide disabled hitstun
;	sta $02da ;
;	sta $02db ;
;	jmp end_player_b_hitstun
;	show_player_b_hitstun:
;	ldx #$d8
;	lda #$10
;	sta oam_mirror, x
;	lda #$20
;	sta oam_mirror+3, x
;	lda #$0e
;	sta oam_mirror+1, x
;	lda #$03
;	sta oam_mirror+2, x
;	end_player_b_hitstun:
;
;	pla
;	tay
;	pla
;	tax
;	pla
;	rts
;.)

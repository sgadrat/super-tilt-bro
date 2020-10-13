init_game_state:
.(
	.(
		; Clear background of nametable 2
		jsr clear_bg_bot_left

		; Store characters' tiles in CHR
		ldx #0
		jsr place_character_ppu_tiles
		ldx #1
		jsr place_character_ppu_tiles

		ldx #0
		jsr place_character_ppu_illustrations
		ldx #1
		jsr place_character_ppu_illustrations

		; Ensure game state is zero
		ldx #$00
		lda #$00
		zero_game_state:
		sta $00, x
		inx
		cpx #ZERO_PAGE_GLOBAL_FIELDS_BEGIN
		bne zero_game_state

		; Copy stage's tileset
		.(
			tileset_addr = tmpfield1 ; Not movable, used by cpu_to_ppu_copy_tiles
			;tileset_addr_msb = tmpfield2 ; Not movable, used by cpu_to_ppu_copy_tiles
			tiles_count = tmpfield3 ; Not movable, used by cpu_to_ppu_copy_tiles

			; Save tileset's vector
			ldx config_selected_stage
			lda stages_tileset_lsb, x
			sta tileset_addr
			lda stages_tileset_msb, x
			sta tileset_addr+1

			; Switch to tileset's bank
			SWITCH_BANK(stages_tileset_bank COMMA x)

			; Copy tileset
			ldy #0
			lda (tileset_addr), y
			sta tiles_count

			inc tileset_addr
			bne update_addr_end
				inc tileset_addr+1
			update_addr_end:

			lda PPUSTATUS
			lda #$10
			sta PPUADDR
			lda #$00
			sta PPUADDR

			jsr cpu_to_ppu_copy_tiles
		.)

		; Call stage initialization routine
		ldx config_selected_stage
		SWITCH_BANK(stages_bank COMMA x)
		txa
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
			lda #0
			sta player_a_x_screen, x
			sta player_a_y_screen, x
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
		lda #INGAME_PLAYER_A_FIRST_SPRITE                              ;
		sta player_a_animation+ANIMATION_STATE_OFFSET_FIRST_SPRITE_NUM ;
		lda #INGAME_PLAYER_A_LAST_SPRITE                               ;
		sta player_a_animation+ANIMATION_STATE_OFFSET_LAST_SPRITE_NUM  ; Initialize players animation state
		lda #<player_b_animation                                       ; (voluntarily let garbage in data vector, it will be overriden by initializing player's state)
		sta tmpfield11                                                 ;
		lda #>player_b_animation                                       ;
		sta tmpfield12                                                 ;
		jsr animation_init_state                                       ;
		lda #INGAME_PLAYER_B_FIRST_SPRITE                              ;
		sta player_b_animation+ANIMATION_STATE_OFFSET_FIRST_SPRITE_NUM ;
		lda #INGAME_PLAYER_B_LAST_SPRITE                               ;
		sta player_b_animation+ANIMATION_STATE_OFFSET_LAST_SPRITE_NUM  ;

		; Initialize out of screen indicators animation state
		lda #<player_a_out_of_screen_indicator
		sta tmpfield11
		lda #>player_a_out_of_screen_indicator
		sta tmpfield12
		lda #<anim_out_of_screen_bubble
		sta tmpfield13
		lda #>anim_out_of_screen_bubble
		sta tmpfield14
		jsr animation_init_state
		lda #INGAME_PLAYER_A_FIRST_SPRITE
		sta player_a_out_of_screen_indicator+ANIMATION_STATE_OFFSET_FIRST_SPRITE_NUM
		lda #INGAME_PLAYER_A_LAST_SPRITE
		sta player_a_out_of_screen_indicator+ANIMATION_STATE_OFFSET_LAST_SPRITE_NUM

		lda #<player_b_out_of_screen_indicator
		sta tmpfield11
		lda #>player_b_out_of_screen_indicator
		jsr animation_init_state
		lda #INGAME_PLAYER_B_FIRST_SPRITE
		sta player_b_out_of_screen_indicator+ANIMATION_STATE_OFFSET_FIRST_SPRITE_NUM
		lda #INGAME_PLAYER_B_LAST_SPRITE
		sta player_b_out_of_screen_indicator+ANIMATION_STATE_OFFSET_LAST_SPRITE_NUM

		; Clear players' elements
		lda #STAGE_ELEMENT_END
		sta player_a_objects
		sta player_b_objects

		; Initialize players' state
		ldx #$00
		initialize_one_player:
			; Select character's bank
			ldy config_player_a_character, x
			SWITCH_BANK(characters_bank_number COMMA y)

			; Call character's start routine
			lda PLAYER_STATE_SPAWN
			sta player_a_state, x
			lda characters_start_routines_table_lsb, y
			sta tmpfield1
			lda characters_start_routines_table_msb, y
			sta tmpfield2
			jsr player_state_action

			; Next player
			inx
			cpx #2
			bne initialize_one_player

		; Construct players palette swap buffers
		ldx #0 ; X points on players_palettes's next byte

		ldy config_player_a_character
		SWITCH_BANK(characters_bank_number COMMA y)

		jsr place_player_a_header
		ldy #0
		jsr place_character_normal_palette
		jsr place_player_a_header
		ldy #0
		jsr place_character_alternate_palette

		ldy config_player_b_character
		SWITCH_BANK(characters_bank_number COMMA y)

		jsr place_player_b_header
		ldy #1
		jsr place_character_normal_palette
		jsr place_player_b_header
		ldy #1
		jsr place_character_alternate_palette

		; Initialize weapons palettes
		bit PPUSTATUS     ;
		lda #$80          ; Wait the begining of a VBI before
		wait_vbi:         ; writing data to PPU's palettes
			bit PPUSTATUS ;
			beq wait_vbi  ;

		ldx config_player_a_character
		SWITCH_BANK(characters_bank_number COMMA x)

		lda characters_weapon_palettes_lsb, x
		sta tmpfield2
		lda characters_weapon_palettes_msb, x
		sta tmpfield3

		ldx #$15
		lda config_player_a_weapon_palette
		sta tmpfield1
		jsr copy_palette_to_ppu

		ldx config_player_b_character
		SWITCH_BANK(characters_bank_number COMMA x)

		lda characters_weapon_palettes_lsb, x
		sta tmpfield2
		lda characters_weapon_palettes_msb, x
		sta tmpfield3

		ldx #$1d
		lda config_player_b_weapon_palette
		sta tmpfield1
		jsr copy_palette_to_ppu

		; Move sprites according to the initial state
		jsr update_sprites

		; Change for ingame music
		jsr audio_music_power

		; Initialize game mode
		ldx config_game_mode
		lda game_modes_init_lsb, x
		sta tmpfield1
		lda game_modes_init_msb, x
		sta tmpfield2
		jsr call_pointed_subroutine

		rts
	.)

	place_player_a_header:
	.(
		ldy #0
		copy_one_byte:
		lda header_player_a, y
		sta players_palettes, x
		iny
		inx
		cpy #4
		bne copy_one_byte
		rts
	.)

	place_player_b_header:
	.(
		ldy #0
		copy_one_byte:
		lda header_player_b, y
		sta players_palettes, x
		iny
		inx
		cpy #4
		bne copy_one_byte
		rts
	.)

	; Copy character's normal palette in players_palettes
	;  X - current offset in players_palettes
	;  Y - player number
	;
	; Output
	;  X -  Updated offset in players_palettes
	;
	; Overwrites all registers, tmpfield1 and tmpfield2
	place_character_normal_palette:
	.(
		txa
		pha

		ldx config_player_a_character, y
		lda characters_palettes_lsb, x
		sta tmpfield1
		lda characters_palettes_msb, x
		sta tmpfield2

		pla
		tax

		jmp place_character_palette
		;rts ; useless, use place_character_palette's rts
	.)

	place_character_alternate_palette:
	.(
		txa
		pha

		ldx config_player_a_character, y
		lda characters_alternate_palettes_lsb, x
		sta tmpfield1
		lda characters_alternate_palettes_msb, x
		sta tmpfield2

		pla
		tax

		jmp place_character_palette
		;rts ; useless, use place_character_palette's rts
	.)

	; Copy pointed palette in players_palettes
	;  X - current offset in players_palettes
	;  Y - player number
	;  tmpfield1, tmpfield2 - palettes table of player's character
	;
	; Output
	;  X -  Updated offset in players_palettes
	;
	; Overwrites all registers, tmpfield1 and tmpfield2
	place_character_palette:
	.(
		lda config_player_a_character_palette, y
		asl
		;clc ; useless, asl shall not overflow
		adc config_player_a_character_palette, y
		tay

		lda (tmpfield1), y
		sta players_palettes, x
		iny
		inx
		lda (tmpfield1), y
		sta players_palettes, x
		iny
		inx
		lda (tmpfield1), y
		sta players_palettes, x
		iny
		inx

		lda #0
		sta players_palettes, x
		inx

		rts
	.)

	place_character_ppu_illustrations:
	.(
		ldy config_player_a_character, x
		SWITCH_BANK(characters_bank_number COMMA y)

		lda PPUSTATUS
		lda illustrations_addr_msb, x
		sta PPUADDR
		lda illustrations_addr_lsb, x
		sta PPUADDR

		lda characters_properties_lsb, y
		sta tmpfield4
		lda characters_properties_msb, y
		sta tmpfield5

		ldy #CHARACTERS_PROPERTIES_ILLUSTRATIONS_ADDR_OFFSET
		lda (tmpfield4), y
		sta tmpfield1
		iny
		lda (tmpfield4), y
		sta tmpfield2
		lda #5
		sta tmpfield3
		jsr cpu_to_ppu_copy_tiles

		rts

		illustrations_addr_msb:
		.byt $1d, $1d
		illustrations_addr_lsb:
		.byt $00, $50
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

	; Tick game mode
	ldx config_game_mode
	lda game_modes_pre_update_lsb, x
	sta tmpfield1
	lda game_modes_pre_update_msb, x
	sta tmpfield2
	jsr call_pointed_subroutine

	; Shake screen and do nothing until shaking is over
	lda screen_shake_counter
	beq no_screen_shake
	jsr shake_screen
	lda network_rollback_mode
	bne end_effects
		ldx #0
		jsr player_effects
		ldx #1
		jsr player_effects
		jsr particle_draw
	end_effects:
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
	ldx config_selected_stage
	SWITCH_BANK(stages_bank COMMA x)
	txa
	asl
	tax
	lda stages_tick_routine, x
	sta tmpfield1
	lda stages_tick_routine+1, x
	sta tmpfield2
	jsr call_pointed_subroutine

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
	lda #0
	sta network_rollback_mode
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
		; Select character's bank
		ldy config_player_a_character, x
		SWITCH_BANK(characters_bank_number COMMA y)

		; Call the state update routine
		lda characters_update_routines_table_lsb, y
		sta tmpfield1
		lda characters_update_routines_table_msb, y
		sta tmpfield2
		jsr player_state_action

		; Call the state input routine if input changed
		lda controller_a_btns, x
		cmp controller_a_last_frame_btns, x
		beq end_input_event
			ldy config_player_a_character, x
			lda characters_input_routines_table_lsb, y
			sta tmpfield1
			lda characters_input_routines_table_msb, y
			sta tmpfield2
			jsr player_state_action
		end_input_event:

		; Call generic update routines
		jsr move_player
		jsr check_player_position
		lda network_rollback_mode
		bne end_visuals
			jsr write_player_damages
			jsr player_effects
		end_visuals:

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

; Update a player's state according to hitbox collisions
;  register X - player number
;
; Overwrite all registers and all tmpfields
check_player_hit:
.(
	; Parameters of boxes_overlap
	striking_box_left = tmpfield1
	striking_box_right = tmpfield2
	striking_box_top = tmpfield3
	striking_box_bottom = tmpfield4
	striking_box_left_msb = tmpfield9
	striking_box_right_msb = tmpfield10
	striking_box_top_msb = tmpfield11
	striking_box_bottom_msb = tmpfield12
	smashed_box_left = tmpfield5
	smashed_box_right = tmpfield6
	smashed_box_top = tmpfield7
	smashed_box_bottom = tmpfield8
	smashed_box_left_msb = tmpfield13
	smashed_box_right_msb = tmpfield14
	smashed_box_top_msb = tmpfield15
	smashed_box_bottom_msb = tmpfield16

	; Parameters of onhurt callbacks
	current_player = tmpfield10
	opponent_player = tmpfield11

	; Store current player number (at stack+1)
	txa
	pha

	; Check that player's hitbox is enabled
	lda player_a_hitbox_enabled, x
	bne process_checks
	jmp end
	process_checks:

		; Store current player's hitbox
		lda player_a_hitbox_left, x
		sta striking_box_left
		lda player_a_hitbox_left_msb, x
		sta striking_box_left_msb

		lda player_a_hitbox_right, x
		sta striking_box_right
		lda player_a_hitbox_right_msb, x
		sta striking_box_right_msb

		lda player_a_hitbox_top, x
		sta striking_box_top
		lda player_a_hitbox_top_msb, x
		sta striking_box_top_msb

		lda player_a_hitbox_bottom, x
		sta striking_box_bottom
		lda player_a_hitbox_bottom_msb, x
		sta striking_box_bottom_msb

		; Switch current player to select the opponent
		jsr switch_selected_player

		; If opponent's hitbox is enabled, check hitbox on hitbox collisions
		lda player_a_hitbox_enabled, x
		beq check_hitbox_hurtbox

			; Store opponent's hitbox
			lda player_a_hitbox_left, x
			sta smashed_box_left
			lda player_a_hitbox_left_msb, x
			sta smashed_box_left_msb

			lda player_a_hitbox_right, x
			sta smashed_box_right
			lda player_a_hitbox_right_msb, x
			sta smashed_box_right_msb

			lda player_a_hitbox_top, x
			sta smashed_box_top
			lda player_a_hitbox_top_msb, x
			sta smashed_box_top_msb

			lda player_a_hitbox_bottom, x
			sta smashed_box_bottom
			lda player_a_hitbox_bottom_msb, x
			sta smashed_box_bottom_msb

			; Check collisions between hitbox and hitbox
			jsr boxes_overlap
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

				lda PLAYER_STATE_THROWN
				sta player_a_state, x
				ldy config_player_a_character, x
				SWITCH_BANK(characters_bank_number COMMA y)
				lda characters_start_routines_table_lsb, y
				sta tmpfield1
				lda characters_start_routines_table_msb, y
				sta tmpfield2
				jsr player_state_action

				lda #SCREENSHAKE_PARRY_INTENSITY
				sta screen_shake_nextval_x
				sta screen_shake_nextval_y
				lda #SCREENSHAKE_PARRY_NB_FRAMES
				sta screen_shake_counter

			jmp end

		check_hitbox_hurtbox:

			; Store opponent's hurtbox
			lda player_a_hurtbox_left, x
			sta smashed_box_left
			lda player_a_hurtbox_left_msb, x
			sta smashed_box_left_msb

			lda player_a_hurtbox_right, x
			sta smashed_box_right
			lda player_a_hurtbox_right_msb, x
			sta smashed_box_right_msb

			lda player_a_hurtbox_top, x
			sta smashed_box_top
			lda player_a_hurtbox_top_msb, x
			sta smashed_box_top_msb

			lda player_a_hurtbox_bottom, x
			sta smashed_box_bottom
			lda player_a_hurtbox_bottom_msb, x
			sta smashed_box_bottom_msb

			; Check collisions between hitbox and hurtbox
			jsr boxes_overlap
			bne end

				; Fire on-hurt event
				stx opponent_player
				jsr switch_selected_player
				stx current_player
				jsr switch_selected_player
				ldy config_player_a_character, x
				SWITCH_BANK(characters_bank_number COMMA y)
				lda characters_onhurt_routines_table_lsb, y
				sta tmpfield1
				lda characters_onhurt_routines_table_msb, y
				sta tmpfield2
				jsr player_state_action

	end:
	; Reset register X to the current player
	pla
	tax
	rts
.)

; Throw the hurted player depending on the hitbox hurting him
;  tmpfield10 - Player number of the striker
;  tmpfield11 - Player number of the stroke
;  register X - Player number of the stroke (equals to tmpfield11)
;
;  Can overwrite any register and any tmpfield except tmpfield10 and tmpfield11.
;  The currently selected bank must be the current character's bank
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
	lda PLAYER_STATE_THROWN
	sta player_a_state, x
	ldy config_player_a_character, x
	lda characters_start_routines_table_lsb, y
	sta tmpfield1
	lda characters_start_routines_table_msb, y
	sta tmpfield2

	lda current_player
	pha
	lda opponent_player
	pha
	jsr player_state_action
	pla
	sta opponent_player
	pla
	sta current_player

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
	lda player_a_velocity_h, x         ;
	bpl passthrough_kb_h               ;
		lda player_a_velocity_h_low, x ;
		eor #%11111111                 ;
		clc                            ;
		adc #$01                       ;
		sta knockback_h_low            ;
		lda player_a_velocity_h, x     ;
		eor #%11111111                 ; knockback_h = abs(velocity_h)
		adc #$00                       ;
		sta knockback_h_high           ;
		jmp end_abs_kb_h               ;
	passthrough_kb_h:                  ;
		sta knockback_h_high           ;
		lda player_a_velocity_h_low, x ;
		sta knockback_h_low            ;
	end_abs_kb_h:                      ;

	lda player_a_velocity_v, x         ;
	bpl passthrough_kb_v               ;
		lda player_a_velocity_v_low, x ;
		eor #%11111111                 ;
		clc                            ;
		adc #$01                       ;
		sta knockback_v_low            ;
		lda player_a_velocity_v, x     ;
		eor #%11111111                 ; knockback_v = abs(velocity_v)
		adc #$00                       ;
		sta knockback_v_high           ;
		jmp end_abs_kb_v               ;
	passthrough_kb_v:                  ;
		sta knockback_v_high           ;
		lda player_a_velocity_v_low, x ;
		sta knockback_v_low            ;
	end_abs_kb_v:                      ;

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
;  When returning
;   - player's position is updated
;   - tmpfield1 contains its old X ;TODO check, seems bugged
;   - tmpfield2 contains its old Y ;TODO check, seems bugged
;   - tmpfield13 contains its old screen_x
;   - tmpfield14 contains its old screen_y
;
;  Note - As a side effect, new position is stored in some tmpfields
;         some code may use it as an easy optimization (to fetch it
;         from zero page instead of "zero-page, x").
;         If this behaviour is changed, take care of dependent code.
move_player:
.(
	;TODO harmonize component names "subpixel", "pixel" and "screen"
	old_x_collision = tmpfield1 ; Not movable, return value and parameter of check_collision
	old_y_collision = tmpfield2 ; Not movable, return value and parameter of check_collision
	final_x_low = tmpfield9 ; Not movable, parameter of check_collision
	final_x_high = tmpfield3 ; Not movable, parameter of check_collision
	final_y_low = tmpfield10 ; Not movable, parameter of check_collision
	final_y_high = tmpfield4 ; Not movable, parameter of check_collision
	obstacle_left = tmpfield5 ; Not movable, parameter of check_collision
	obstacle_top = tmpfield6 ; Not movable, parameter of check_collision
	obstacle_right = tmpfield7 ; Not movable, parameter of check_collision
	obstacle_bottom = tmpfield8 ; Not movable, parameter of check_collision
	final_x_screen = tmpfield11 ; Not movable, parameter of check_collision
	final_y_screen = tmpfield12 ; Not movable, parameter of check_collision
	old_x_screen = tmpfield13 ; Not movable, parameter of check_collision
	old_y_screen = tmpfield14 ; Not movable, parameter of check_collision
	action_vector = tmpfield15

	old_x = extra_tmpfield1
	old_y = extra_tmpfield2
	elements_action_vector = tmpfield1 ; Not movable, parameter of stage_iterate_all_elements

	; Save X to ensure it is not modified by this routine
	txa
	pha

	; Save old position
	lda player_a_x, x
	sta old_x
	lda player_a_y, x
	sta old_y
	lda player_a_x_screen, x
	sta old_x_screen
	lda player_a_y_screen, x
	sta old_y_screen

	; Apply velocity to position
	lda player_a_velocity_h_low, x
	clc
	adc player_a_x_low, x
	sta final_x_low
	lda player_a_velocity_h, x
	adc old_x
	sta final_x_high
	lda player_a_velocity_h, x
	SIGN_EXTEND()
	adc old_x_screen
	sta final_x_screen

	lda player_a_velocity_v_low, x
	clc
	adc player_a_y_low, x
	sta final_y_low
	lda player_a_velocity_v, x
	adc old_y
	sta final_y_high
	lda player_a_velocity_v, x
	SIGN_EXTEND()
	adc old_y_screen
	sta final_y_screen

	; Check collisions with stage plaforms
	ldy #0 ; TODO seems useless, not used bu stage_iterate_all_elements

	check_platform_collision:
		lda #<handle_one_platform
		sta elements_action_vector
		lda #>handle_one_platform
		sta elements_action_vector+1
		jsr stage_iterate_all_elements

		; HACK perform the check twice to mitigate the following issue
		;  With two pateforms (A and B), if the final position is outside A
		;  and inside B. A does not impacts movement, but collision with B
		;  may replace the player inside A.
		;
		;  To mitigate it more elegantly we may
		;   - recheck only platforms before the last colliding platform (and do it until no platform collide)
		;   - use a better formula for collision detection that does not let player cut the corners
		;   - better formula idea (kudos darry.revok), move vertically, check vertical collisions, move horizontally, check H collisions
		;      - Can still cut corners (one way)
		;      - Should not be able to be trapped by multi-platform bug described above
		;      - Still iterate two times over objects, but each time checking less collisions (only one line per platform needed)
		;        - Maybe improvable by computing full movement, and interating once, but considering (old_x, new_y) and (old_y, new_x) on each platform
		;          - Save one iteration (same number of collision check) at the cost of complexity
		;          - Possibly incompatible with slopes (to be determined, not yet needed)
		;          - thinking about it, it is dumb
		;            - some vertical positions will be checked without the final horz position
		;              - (multiple platform) bugs may appear
		;                - player[0;0] momentum[2;2] platform(upleft=[1;1],botright=[3;3]
		;                  - player could go to [0;2] and [2;0], dumb application of this formula would state that it is ok to go to [2;2]
		;                  - could be fixed for single platform by updating one pos before computing the other
		;                  - multi platform fix is the same - fully compute one component before considering the other
		;                    - that means "do not use this trick, it is dumb"
		;      - Better optimization, do not store boxes, but just lines, make lines iterable byt type (up, down, left or right)
		;        - This is a big change, impacting engine and tools
		;
		; TODO implement a cleaner solution
		lda #<handle_one_platform
		sta elements_action_vector
		lda #>handle_one_platform
		sta elements_action_vector+1
		jsr stage_iterate_all_elements

	end:
		; Restore X
		pla
		tax

		; Store final velocity in player's position
		lda final_x_screen
		sta player_a_x_screen, x
		lda final_y_screen
		sta player_a_y_screen, x
		lda final_x_high
		sta player_a_x, x
		lda final_y_high
		sta player_a_y, x
		lda final_x_low
		sta player_a_x_low, x
		lda final_y_low
		sta player_a_y_low, x
	rts

	handle_one_platform:
	.(
		; Use element type as jump-table index
		ldx stage_data, y
		dex

		; Jump to correct action
		lda platform_actions_low, x
		sta action_vector
		lda platform_actions_high, x
		sta action_vector+1
		jmp (action_vector)

		;rts ; useless, we jump to a routine
	.)

	solid_platform_collision:
	.(
		; Prepare parameters for check_collision
		lda old_x
		sta old_x_collision
		lda old_y
		sta old_y_collision
		lda stage_data+STAGE_PLATFORM_OFFSET_LEFT, y
		sta obstacle_left
		lda stage_data+STAGE_PLATFORM_OFFSET_TOP, y
		sta obstacle_top
		lda stage_data+STAGE_PLATFORM_OFFSET_RIGHT, y
		sta obstacle_right
		lda stage_data+STAGE_PLATFORM_OFFSET_BOTTOM, y
		sta obstacle_bottom
		lda #0
		pha
		pha
		pha
		pha

		; Call check collision and clean stack parameters
		jsr check_collision
		pla
		pla
		pla
		pla

		; Move computed position to its non-conflicting place
		lda old_x_collision
		sta old_x
		lda old_y_collision
		sta old_y

		; Restore iteration action vector, erased by "old position" parameter
		lda #<handle_one_platform
		sta elements_action_vector
		lda #>handle_one_platform
		sta elements_action_vector+1

		rts
	.)

	smooth_platform_collision:
	.(
		; Prepare parameters for check_top_collision
		lda old_x
		sta old_x_collision
		lda old_y
		sta old_y_collision
		lda stage_data+STAGE_PLATFORM_OFFSET_LEFT, y
		sta obstacle_left
		lda stage_data+STAGE_PLATFORM_OFFSET_TOP, y
		sta obstacle_top
		lda stage_data+STAGE_PLATFORM_OFFSET_RIGHT, y
		sta obstacle_right
		lda #0
		pha
		pha
		pha

		; Call check collision and clean stack parameters
		jsr check_top_collision
		pla
		pla
		pla

		; Move computed position to its non-conflicting place
		lda old_x_collision
		sta old_x
		lda old_y_collision
		sta old_y

		; Restore iteration action vector, erased by "old position" parameter
		lda #<handle_one_platform
		sta elements_action_vector
		lda #>handle_one_platform
		sta elements_action_vector+1

		rts
	.)

	oos_solid_platform_collision:
	.(
		; Prepare parameters for check_collision
		lda old_x
		sta old_x_collision
		lda old_y
		sta old_y_collision
		lda stage_data+STAGE_OOS_PLATFORM_OFFSET_LEFT_LSB, y
		sta obstacle_left
		lda stage_data+STAGE_OOS_PLATFORM_OFFSET_TOP_LSB, y
		sta obstacle_top
		lda stage_data+STAGE_OOS_PLATFORM_OFFSET_RIGHT_LSB, y
		sta obstacle_right
		lda stage_data+STAGE_OOS_PLATFORM_OFFSET_BOTTOM_LSB, y
		sta obstacle_bottom
		lda stage_data+STAGE_OOS_PLATFORM_OFFSET_LEFT_MSB, y
		pha
		lda stage_data+STAGE_OOS_PLATFORM_OFFSET_TOP_MSB, y
		pha
		lda stage_data+STAGE_OOS_PLATFORM_OFFSET_RIGHT_MSB, y
		pha
		lda stage_data+STAGE_OOS_PLATFORM_OFFSET_BOTTOM_MSB, y
		pha

		; Call check collision and clean stack parameters
		jsr check_collision
		pla
		pla
		pla
		pla

		; Move computed position to its non-conflicting place
		lda old_x_collision
		sta old_x
		lda old_y_collision
		sta old_y

		; Restore iteration action vector, erased by "old position" parameter
		lda #<handle_one_platform
		sta elements_action_vector
		lda #>handle_one_platform
		sta elements_action_vector+1

		rts
	.)

	oos_smooth_platform_collision:
	.(
		; Prepare parameters for check_top_collision
		lda old_x
		sta old_x_collision
		lda old_y
		sta old_y_collision
		lda stage_data+STAGE_OOS_PLATFORM_OFFSET_LEFT_LSB, y
		sta obstacle_left
		lda stage_data+STAGE_OOS_PLATFORM_OFFSET_TOP_LSB, y
		sta obstacle_top
		lda stage_data+STAGE_OOS_PLATFORM_OFFSET_RIGHT_LSB, y
		sta obstacle_right
		lda stage_data+STAGE_OOS_PLATFORM_OFFSET_LEFT_MSB, y
		pha
		lda stage_data+STAGE_OOS_PLATFORM_OFFSET_TOP_MSB, y
		pha
		lda stage_data+STAGE_OOS_PLATFORM_OFFSET_RIGHT_MSB, y
		pha

		; Call check collision and clean stack parameters
		jsr check_top_collision
		pla
		pla
		pla

		; Move computed position to its non-conflicting place
		lda old_x_collision
		sta old_x
		lda old_y_collision
		sta old_y

		; Restore iteration action vector, erased by "old position" parameter
		lda #<handle_one_platform
		sta elements_action_vector
		lda #>handle_one_platform
		sta elements_action_vector+1

		rts
	.)

	platform_actions_low:
		.byt <solid_platform_collision
		.byt <smooth_platform_collision
		.byt <oos_solid_platform_collision
		.byt <oos_smooth_platform_collision
	platform_actions_high:
		.byt >solid_platform_collision
		.byt >smooth_platform_collision
		.byt >oos_solid_platform_collision
		.byt >oos_smooth_platform_collision
.)

; Check the player's position and modify the current state accordingly
;  register X - player number
;  tmpfield3 - player's current X pixel
;  tmpfield4 - player's current Y pixel
;  tmpfield11 - player's current X screen
;  tmpfield12 - player's current Y screen
;
;  The selected bank must be the correct character's bank.
;
;  Overwrites tmpfield1 and tmpfield2
check_player_position:
.(
	capped_x = tmpfield1 ; Not movable, used by particle_death_start
	capped_y = tmpfield2 ; Not movable, used by particle_death_start
	current_x_pixel = tmpfield3 ; Dispensable, shall be equal to "player_a_x, x"
	current_y_pixel = tmpfield4 ; Dispensable, shall be equal to "player_a_y, x"
	current_x_screen = tmpfield11
	current_y_screen = tmpfield12

	; Check death
	SIGNED_CMP(current_x_pixel, current_x_screen, #<STAGE_BLAST_LEFT, #>STAGE_BLAST_LEFT)
	bmi set_death_state
	SIGNED_CMP(#<STAGE_BLAST_RIGHT, #>STAGE_BLAST_RIGHT, current_x_pixel, current_x_screen)
	bmi set_death_state
	SIGNED_CMP(current_y_pixel, current_y_screen, #<STAGE_BLAST_TOP, #>STAGE_BLAST_TOP)
	bmi set_death_state
	SIGNED_CMP(#<STAGE_BLAST_BOTTOM, #>STAGE_BLAST_BOTTOM, current_y_pixel, current_y_screen)
	bmi set_death_state

	; Check if on ground
	jsr check_on_ground
	bne offground

		; On ground

		; Reset aerial jumps counter
		lda #$00
		sta player_a_num_aerial_jumps, x

		; Reset gravity modifications
		lda #DEFAULT_GRAVITY
		sta player_a_gravity, x

		; Fire on-ground event
		ldy config_player_a_character, x
		lda characters_onground_routines_table_lsb, y
		sta tmpfield1
		lda characters_onground_routines_table_msb, y
		sta tmpfield2
		jsr player_state_action
		jmp end

	offground:
		; Fire off-ground event
		ldy config_player_a_character, x
		lda characters_offground_routines_table_lsb, y
		sta tmpfield1
		lda characters_offground_routines_table_msb, y
		sta tmpfield2
		jsr player_state_action
		jmp end

	set_death_state:
		; Play death sound
		jsr audio_play_death

		; Reset aerial jumps counter
		lda #$00
		sta player_a_num_aerial_jumps, x

		; Reset hitstun counter
		sta player_a_hitstun, x

		; Reset gravity
		lda #DEFAULT_GRAVITY
		sta player_a_gravity, x

		; Death particles animation
		;  It takes on-screen unsigned coordinates,
		;  so we cap actual coordinates to a minimum
		;  of zero and a maxium of 255
		.(
			lda current_x_screen
			bmi left_edge
			beq pass_cap_vertical_blast
				lda #$ff
				jmp cap_vertical_blast
			pass_cap_vertical_blast:
				lda current_x_pixel
				jmp cap_vertical_blast
			left_edge:
				lda #$0
			cap_vertical_blast:
				sta capped_x
			end_cap_vertical_blast:
		.)
		.(
			lda current_y_screen
			bmi top_edge
			beq pass_cap_horizontal_blast
				lda #$ff
				jmp cap_horizontal_blast
			pass_cap_horizontal_blast:
				lda current_y_pixel
				jmp cap_horizontal_blast
			top_edge:
				lda #$0
			cap_horizontal_blast:
				sta capped_y
			end_cap_horizontal_blast:
		.)
		jsr particle_death_start

		; Decrement stocks counter and check for gameover
		dec player_a_stocks, x
		bmi gameover

		; Set respawn state
		lda PLAYER_STATE_RESPAWN
		sta player_a_state, x
		ldy config_player_a_character, x
		lda characters_start_routines_table_lsb, y
		sta tmpfield1
		lda characters_start_routines_table_msb, y
		sta tmpfield2
		jsr player_state_action

		jmp end

	gameover:
		; Set the winner for gameover screen
		lda slow_down_counter
		bne no_set_winner
		jsr switch_selected_player
		txa
		sta gameover_winner
		jsr switch_selected_player
		no_set_winner:

		; Do not keep an invalid number of stocks
		lda #0
		sta player_a_stocks, x

		; Hide dead player
		lda PLAYER_STATE_INNEXISTANT
		sta player_a_state, x
		ldy config_player_a_character, x
		lda characters_start_routines_table_lsb, y
		sta tmpfield1
		lda characters_start_routines_table_msb, y
		sta tmpfield2
		jsr player_state_action

		; Start slow down (restart it if the second player die to
		; show that heroic death's animation)
		lda #SLOWDOWN_TIME
		sta slow_down_counter

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
	character_icon = tmpfield9

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

	; Get player's character icon while we have player index at hand
	lda character_icons, x
	sta character_icon

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
#if (nametable_buffers & $ff) <> 0
#error Code bellow expects nametable_buffer to be page-aligned
#endif
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
	lda character_icon       ;
	jmp set_stock_tile       ; Set stock tile depending of the
	empty_stock:             ; stock's availability
	lda #TILE_SOLID_0        ;
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

	character_icons:
	.byt $d0, $d5
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

	ldx #0 ; X is the player number
	ldy #0 ; Y is the offset of player's animation state
	update_one_player_sprites:
		; Select character's bank
		tya
		pha
		ldy config_player_a_character, x
		SWITCH_BANK(characters_bank_number COMMA y)
		pla
		tay

		; Player
		lda player_a_x, x
		sta player_a_animation+ANIMATION_STATE_OFFSET_X_LSB, y
		lda player_a_y, x
		sta player_a_animation+ANIMATION_STATE_OFFSET_Y_LSB, y
		lda player_a_x_screen, x
		sta player_a_animation+ANIMATION_STATE_OFFSET_X_MSB, y
		lda player_a_y_screen, x
		sta player_a_animation+ANIMATION_STATE_OFFSET_Y_MSB, y

		lda #<player_a_animation
		sta animation_vector
		tya
		clc
		adc animation_vector
		sta animation_vector
		lda #>player_a_animation
		adc #0
		sta animation_vector+1
		lda #0
		sta camera_x
		sta camera_x+1
		sta camera_y
		sta camera_y+1
		txa
		sta player_number
		pha
		tya
		pha
		jsr stb_animation_draw
		jsr animation_tick
		pla
		tay
		pla
		tax

		; Player's out of screen indicator
		.(
			lda player_a_x_screen, x
			bmi oos_left
			bne oos_right
			lda player_a_y_screen, x
			bmi oss_top
			bne oos_bot
			jmp oos_indicator_drawn

			oos_left:
				lda player_a_y, x ; TODO cap to min 0 - max 240-8
				sta player_a_out_of_screen_indicator+ANIMATION_STATE_OFFSET_Y_LSB, y
				lda DIRECTION_LEFT
				sta player_a_out_of_screen_indicator+ANIMATION_STATE_OFFSET_DIRECTION, y
				lda #0
				sta player_a_out_of_screen_indicator+ANIMATION_STATE_OFFSET_X_LSB, y
				jmp oos_indicator_placed

			oos_right:
				lda player_a_y, x ; TODO cap to min 0 - max 240-8
				sta player_a_out_of_screen_indicator+ANIMATION_STATE_OFFSET_Y_LSB, y
				lda DIRECTION_RIGHT
				sta player_a_out_of_screen_indicator+ANIMATION_STATE_OFFSET_DIRECTION, y
				lda #255-8
				sta player_a_out_of_screen_indicator+ANIMATION_STATE_OFFSET_X_LSB, y
				jmp oos_indicator_placed

			oss_top:
				lda player_a_x, x ; TODO cap to min 0 - max 255-8
				sta player_a_out_of_screen_indicator+ANIMATION_STATE_OFFSET_X_LSB, y
				lda DIRECTION_LEFT
				sta player_a_out_of_screen_indicator+ANIMATION_STATE_OFFSET_DIRECTION, y
				lda #0
				sta player_a_out_of_screen_indicator+ANIMATION_STATE_OFFSET_Y_LSB, y
				jmp oos_indicator_placed

			oos_bot:
				lda player_a_x, x ; TODO cap to min 0 - max 255-8
				sta player_a_out_of_screen_indicator+ANIMATION_STATE_OFFSET_X_LSB, y
				lda DIRECTION_RIGHT
				sta player_a_out_of_screen_indicator+ANIMATION_STATE_OFFSET_DIRECTION, y
				lda #240-8
				sta player_a_out_of_screen_indicator+ANIMATION_STATE_OFFSET_Y_LSB, y
				;jmp oos_indicator_placed

			oos_indicator_placed:
				lda #<player_a_out_of_screen_indicator
				sta animation_vector
				tya
				clc
				adc animation_vector
				sta animation_vector
				lda #>player_a_out_of_screen_indicator
				adc #0
				sta animation_vector+1
				lda #0
				sta camera_x
				sta camera_x+1
				sta camera_y
				sta camera_y+1
				txa
				sta player_number
				pha
				tya
				pha
				jsr animation_draw
				jsr animation_tick
				pla
				tay
				pla
				tax

			oos_indicator_drawn:
		.)

		; Loop for both players
		inx
		tya
		clc
		adc #ANIMATION_STATE_LENGTH
		tay
		cpx #2
		beq all_player_sprites_updated
		jmp update_one_player_sprites
	all_player_sprites_updated:

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

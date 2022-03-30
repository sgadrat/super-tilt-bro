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
		txa
		zero_game_state:
			sta $00, x
			inx
			cpx #ZERO_PAGE_GLOBAL_FIELDS_BEGIN
			bne zero_game_state

		; Copy common tileset
		;TODO Only copy a numeric font and the "%" symbol
		jsr copy_common_tileset

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
			jsr cpu_to_ppu_copy_tileset_background
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

		ldx #0
		jsr reset_default_gravity
		ldx #1
		jsr reset_default_gravity

		lda config_initial_stocks
		sta player_a_stocks
		sta player_b_stocks

		lda #$ff ; impossible value in screen damage meter cache, forcing it to redraw
		sta player_a_last_shown_damage
		sta player_b_last_shown_damage
		sta player_a_last_shown_stocks
		sta player_b_last_shown_stocks

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
		ldx #1
		initialize_one_player:
			; Select character's bank
			ldy config_player_a_character, x
			SWITCH_BANK(characters_bank_number COMMA y)

			; Call character's start routine
			lda #PLAYER_STATE_SPAWN
			sta player_a_state, x
			lda characters_start_routines_table_lsb, y
			sta tmpfield1
			lda characters_start_routines_table_msb, y
			sta tmpfield2
			jsr player_state_action

			; Next player
			dex
			bpl initialize_one_player

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

		; If both players have the same character with same colors, lighten player B's colors
		.(
			lda config_player_a_character
			cmp config_player_b_character
			bne ok
			lda config_player_a_character_palette
			cmp config_player_b_character_palette
			bne ok
				ldx #16+4 ; Player B's normal palette, first color
				ldy #3
				lighten_one_color:
					; Get color
					lda players_palettes, x

					; Skip if cannot be lightened, special handling for black
					cmp #$0f
					beq lighten_black
					cmp #$30
					bcs end_color

						ligthen_normal:
							; Up color to the lighter value
							clc
							adc #$10
							sta players_palettes, x
							jmp end_color

						lighten_black:
							; Change to dark-grey
							lda #$00
							sta players_palettes, x

					; Loop on three colors
					end_color:
					inx
					dey
					bne lighten_one_color
			ok:
		.)

		; Initialize weapons palettes
		jsr wait_vbi ; Wait the begining of a VBI before writing data to PPU's palettes

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
		jsr audio_music_ingame

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
		;rts ; useless, jump to subroutine
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

		; Fallthrough to place_character_palette
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

		; Shake the screen
		jsr shake_screen

		; Call stage's logic
		ldx config_selected_stage
		SWITCH_BANK(stages_bank COMMA x)
		lda stages_freezed_tick_routine_lsb, x
		sta tmpfield1
		lda stages_freezed_tick_routine_msb, x
		sta tmpfield2
		jsr call_pointed_subroutine

		; Keep inputs dirty (inlined double call to keep_input_dirty)
		lda controller_a_last_frame_btns
		sta controller_a_btns
		lda controller_b_last_frame_btns
		sta controller_b_btns

		; Update visual effects
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
		beq no_slowdown
			; Keep inputs dirty (inlined double call to keep_input_dirty)
			lda controller_a_last_frame_btns
			sta controller_a_btns
			lda controller_b_last_frame_btns
			sta controller_b_btns

			; Skip this frame
			rts
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
	jmp update_sprites

	;rts ; useless, jump to subroutine
.)

; Set tmpfield1 to 1 if the current frame need to be skipped, follow to gameover
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
	ldx config_game_mode
	lda game_modes_gameover_lsb, x
	sta tmpfield1
	lda game_modes_gameover_msb, x
	sta tmpfield2
	jsr call_pointed_subroutine

	end:
	rts
.)

; Your typical handler for game mod's gameover routine
; Go to gameover screen, ensuring rollback mode is deactivated (would prevent further animations)
game_mode_goto_gameover:
.(
	lda #0
	sta network_rollback_mode
	lda #GAME_STATE_GAMEOVER
	jmp change_global_game_state
	;rts ; useless, jump to subroutine
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
		txa
		sta player_number
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
	routine_addr_lsb = tmpfield3
	routine_addr_msb = tmpfield4

	; Convert player state number to vector address (relative to table begining)
	lda player_a_state, x       ; Y = state * 2
	asl                         ; (as each element is 2 bytes long)
	tay                         ;

	; Retrieve state's routine address
	lda (jump_table), y
	sta routine_addr_lsb
	iny
	lda (jump_table), y
	sta routine_addr_msb

	; Jump to state's routine, it will return to player_state_action's caller
	jmp (routine_addr_lsb)
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
		SWITCH_SELECTED_PLAYER

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

				lda #PLAYER_STATE_THROWN
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
				SWITCH_SELECTED_PLAYER
				stx current_player
				SWITCH_SELECTED_PLAYER
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

	; Reset fall speed
	jsr reset_default_gravity

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
	lda #PLAYER_STATE_THROWN
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
	multiplicand_low = tmpfield1
	multiplicand_high = tmpfield2
	multiplier = tmpfield3
	multiply_result_low = tmpfield4
	multiply_result_high = tmpfield5
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
	sta multiplier          ;

	lda force_h              ;
	sta multiplicand_high    ;
	lda force_h_low          ;
	sta multiplicand_low     ;
	jsr multiply             ; Compute horizontal knockback
	lda base_h_low           ; "force_h * multiplier + base_h"
	clc                      ;
	adc multiply_result_low  ;
	sta multiply_result_low  ;
	lda base_h_high          ;
	adc multiply_result_high ;
	sta player_a_velocity_h, x     ;
	lda multiply_result_low        ; Apply horizontal knockback
	sta player_a_velocity_h_low, x ;

	lda force_v              ;
	sta multiplicand_high    ;
	lda force_v_low          ;
	sta multiplicand_low     ;
	jsr multiply             ; Compute vertical knockback
	lda base_v_low           ; "force_v * multiplier + base_v"
	clc                      ;
	adc multiply_result_low  ;
	sta multiply_result_low  ;
	lda base_v_high          ;
	adc multiply_result_high ;
	sta player_a_velocity_v, x     ;
	lda multiply_result_low        ; Apply vertical knockback
	sta player_a_velocity_v_low, x ;

	; Apply hitstun to the opponent
	; hitstun duration = high byte of 3 * (abs(velotcity_v) + abs(velocity_h)) [approximated]
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
	lda knockback_h_high    ;
	rol                     ; Oponent player hitstun = high byte of 3 * knockback_h
	;clc ; useless          ;   approximated, it is actually "msb(2 * knockback_h) + msb(knockback_h)"
	adc knockback_h_high    ;   CLC ignored, should not happen, precision loss is one frame, and if knockback is this high we don't care of hitstun anyway
	sta player_a_hitstun, x ;

	; Start screenshake of duration = hitstun / 2
	lsr
	sta screen_shake_counter
	lda player_a_velocity_h, x
	sta screen_shake_nextval_x
	lda player_a_velocity_v, x
	sta screen_shake_nextval_y

	; Adapt resulting velocity, screenshake and hitstun duration in ntsc
	lda system_index
	beq ntsc_ok
		; Vertical velocity
		.(
			lda player_a_velocity_v, x
			bmi negative
				positive:
					PAL_TO_NTSC_VELOCITY_POSITIVE(player_a_velocity_v_low COMMA x, player_a_velocity_v COMMA x, player_a_velocity_v_low COMMA x, player_a_velocity_v COMMA x)
					jmp ok
				negative:
					PAL_TO_NTSC_VELOCITY_NEGATIVE(player_a_velocity_v_low COMMA x, player_a_velocity_v COMMA x, player_a_velocity_v_low COMMA x, player_a_velocity_v COMMA x)
			ok:
		.)

		; Horizontal velocity
		.(
			lda player_a_velocity_h, x
			bmi negative
				positive:
					PAL_TO_NTSC_VELOCITY_POSITIVE(player_a_velocity_h_low COMMA x, player_a_velocity_h COMMA x, player_a_velocity_h_low COMMA x, player_a_velocity_h COMMA x)
					jmp ok
				negative:
					PAL_TO_NTSC_VELOCITY_NEGATIVE(player_a_velocity_h_low COMMA x, player_a_velocity_h COMMA x, player_a_velocity_h_low COMMA x, player_a_velocity_h COMMA x)
			ok:
		.)

		; Screen shake
		lda screen_shake_counter
		lsr
		lsr
		tay
		lda plus_20_percent, y
		sta screen_shake_counter

		; Hitstun
		lda player_a_hitstun, x
		lsr
		lsr
		tay
		lda plus_20_percent, y
		sta player_a_hitstun, x
	ntsc_ok:

	; Start directional indicator particles
	jsr particle_directional_indicator_start

	rts

;TODO comment usage and put in static bank
#define TWT(x) (x*4*12)/10
	plus_20_percent:
		.byt TWT(0), TWT(1), TWT(2), TWT(3), TWT(4), TWT(5), TWT(6), TWT(7)
		.byt TWT(8), TWT(9), TWT(10), TWT(11), TWT(12), TWT(13), TWT(14), TWT(15)
		.byt TWT(16), TWT(17), TWT(18), TWT(19), TWT(20), TWT(21), TWT(22), TWT(23)
		.byt TWT(24), TWT(25), TWT(26), TWT(27), TWT(28), TWT(29), TWT(30), TWT(31)
		.byt TWT(32), TWT(33), TWT(34), TWT(35), TWT(36), TWT(37), TWT(38), TWT(39)
		.byt TWT(40), TWT(41), TWT(42), TWT(43), TWT(44), TWT(45), TWT(46), TWT(47)
		.byt TWT(48), TWT(49), TWT(50), TWT(51), TWT(52), TWT(53), 255, 255
		.byt 255, 255, 255, 255, 255, 255, 255, 255
#undef TWT
.)

; Move the player according to it's velocity and collisions with obstacles
;  register X - player number
;  player_number - player number
;
;  Ouput
;   - player's position is updated
;   - tmpfield4 equals to "player_a_x, x"
;   - tmpfield5 equals to "player_a_x_screen, x"
;   - tmpfield7 equals to "player_a_y, x"
;   - tmpfield8 equals to "player_a_y_screen, x"
;   - "player_a_grounded, x", "player_a_walled, x", and "player_a_walled_direction, x" are set according to collisions
;
;  Overwrites register A, regiter Y, and tmpfield1 to tmpfield12
;
;FIXME bug - A walled player with null velocity becomes unwalled
move_player:
.(
	elements_action_vector = tmpfield1 ; Not movable, parameter of stage_iterate_all_elements
	;elements_action_vector_msb = tmpfield2
	final_x_subpixel = tmpfield3
	final_x_pixel = tmpfield4
	final_x_screen = tmpfield5
	final_y_subpixel = tmpfield6
	final_y_pixel = tmpfield7
	final_y_screen = tmpfield8
	orig_x_pixel = tmpfield9
	orig_x_screen = tmpfield10
	orig_y_pixel = tmpfield11
	orig_y_screen = tmpfield12

	; Save original position
	lda player_a_x, x
	sta orig_x_pixel
	lda player_a_x_screen, x
	sta orig_x_screen

	lda player_a_y, x
	sta orig_y_pixel
	lda player_a_y_screen, x
	sta orig_y_screen

	; Apply vertical velocity, coliding with obstacles on the way
	vertical:
	.(
		; Beware
		;   Do not use final_y, not even in platform handlers,
		;   we care only of moving the character from (orig_x;orig_y) to (orig_x;orig_y+velocity_v)

		; Apply velocity to position
		lda player_a_velocity_v_low, x
		clc
		adc player_a_y_low, x
		sta final_y_subpixel
		lda player_a_velocity_v, x
		adc orig_y_pixel
		sta final_y_pixel
		lda player_a_velocity_v, x
		SIGN_EXTEND()
		pha ; save velocity direction
		adc orig_y_screen
		sta final_y_screen

		; Clear grounded flag (to be set by collision handlers)
		lda #0
		sta player_a_grounded, x

		; Iterate on stage elements
		.(
			pla
			bne up
				down:
					lda #<move_player_handle_one_platform_down
					sta elements_action_vector
					lda #>move_player_handle_one_platform_down
					jmp end_set_callback
				up:
					lda #<move_player_handle_one_platform_up
					sta elements_action_vector
					lda #>move_player_handle_one_platform_up
			end_set_callback:
			sta elements_action_vector+1
			jsr stage_iterate_all_elements
		.)

		; Restore X register which can be freely used by platform handlers
		ldx player_number
	.)

	; Apply horizontal velocity, coliding with obstacles on the way
	horizontal:
	.(
		; Beware
		;   Do not use orig_y, not even in platform handlers,
		;   we care only of moving the character from (orig_x;final_y) to (orig_x+velocity_h;final_y)

		; Apply velocity to position
		lda player_a_velocity_h_low, x
		clc
		adc player_a_x_low, x
		sta final_x_subpixel
		lda player_a_velocity_h, x
		adc orig_x_pixel
		sta final_x_pixel
		lda player_a_velocity_h, x
		SIGN_EXTEND()
		pha ; save velocity direction
		adc orig_x_screen
		sta final_x_screen

		; Clear walled flag (to be set by collision handlers)
		lda #0
		sta player_a_walled, x

		; Iterate on stage elements
		.(
			pla
			bne left
				right:
					lda #<move_player_handle_one_platform_right
					sta elements_action_vector
					lda #>move_player_handle_one_platform_right
					jmp end_set_callback
				left:
					lda #<move_player_handle_one_platform_left
					sta elements_action_vector
					lda #>move_player_handle_one_platform_left
			end_set_callback:
			sta elements_action_vector+1
			jsr stage_iterate_all_elements
		.)

		; Restore X register which can be freely used by platform handlers
		ldx player_number
	.)

	; Update actual player positon, x has been messed with but player_number is there
	lda final_x_subpixel
	sta player_a_x_low, x
	lda final_x_pixel
	sta player_a_x, x
	lda final_x_screen
	sta player_a_x_screen, x

	lda final_y_subpixel
	sta player_a_y_low, x
	lda final_y_pixel
	sta player_a_y, x
	lda final_y_screen
	sta player_a_y_screen, x

	rts
.)

;TODO move these routines inside move_player's scope (and do not redefine shared labels)
move_player_handle_one_platform_left:
.(
	elements_action_vector = tmpfield1 ; Not movable, parameter of stage_iterate_all_elements
	;elements_action_vector_msb = tmpfield2
	final_x_subpixel = tmpfield3
	final_x_pixel = tmpfield4
	final_x_screen = tmpfield5
	final_y_subpixel = tmpfield6
	final_y_pixel = tmpfield7
	final_y_screen = tmpfield8
	orig_x_pixel = tmpfield9
	orig_x_screen = tmpfield10
	orig_y_pixel = tmpfield11
	orig_y_screen = tmpfield12

	platform_specific_handler_lsb = tmpfield13
	platform_specific_handler_msb = tmpfield14

	; Call appropriate handler for this kind of elements
	tax
	lda platform_specific_handlers_lsb, x
	sta platform_specific_handler_lsb
	lda platform_specific_handlers_msb, x
	sta platform_specific_handler_msb
	jmp (platform_specific_handler_lsb)
	; No return, the handler will rts

	;    unused,         PLATFORM,             SMOOTH,         OOS_PLATFORM,  OOS_SMOOTH
	platform_specific_handlers_lsb:
	.byt <dummy_routine, <one_screen_platform, <dummy_routine, <oos_platform, <dummy_routine
	platform_specific_handlers_msb:
	.byt >dummy_routine, >one_screen_platform, >dummy_routine, >oos_platform, >dummy_routine

	one_screen_platform:
	.(
		; No collision if player is above the platform (the very last pixel is not counted)
		SIGNED_CMP(stage_data+STAGE_PLATFORM_OFFSET_TOP COMMA y, #0, final_y_pixel, final_y_screen)
		bpl no_collision

		; No collision if player is under the platform (the very last pixel is not counted)
		SIGNED_CMP(final_y_pixel, final_y_screen, stage_data+STAGE_PLATFORM_OFFSET_BOTTOM COMMA y, #0)
		bpl no_collision

		; No collision if original position is on the left of the edge
		SIGNED_CMP(orig_x_pixel, orig_x_screen, stage_data+STAGE_PLATFORM_OFFSET_RIGHT COMMA y, #0)
		bmi no_collision

		; No collision if final position is on the right of the edge
		SIGNED_CMP(stage_data+STAGE_PLATFORM_OFFSET_RIGHT COMMA y, #0, final_x_pixel, final_x_screen)
		bmi no_collision

			; Collision, set final_x to platform right edge, plus one pixel (consider the obstacle filling its last pixel)
			lda #$00
			sta final_x_subpixel
			lda stage_data+STAGE_PLATFORM_OFFSET_RIGHT, y
			sta final_x_pixel
			lda #0
			sta final_x_screen

			; Set walled flag
			ldx player_number
			sty player_a_walled, x
			lda DIRECTION_RIGHT
			sta player_a_walled_direction, x

		no_collision:
		rts
	.)

	oos_platform:
	.(
		; No collision if player is above the platform (the very last pixel is not counted)
		SIGNED_CMP(stage_data+STAGE_OOS_PLATFORM_OFFSET_TOP_LSB COMMA y, stage_data+STAGE_OOS_PLATFORM_OFFSET_TOP_MSB COMMA y, final_y_pixel, final_y_screen)
		bpl no_collision

		; No collision if player is under the platform (the very last pixel is not counted)
		SIGNED_CMP(final_y_pixel, final_y_screen, stage_data+STAGE_OOS_PLATFORM_OFFSET_BOTTOM_LSB COMMA y, stage_data+STAGE_OOS_PLATFORM_OFFSET_BOTTOM_MSB COMMA y)
		bpl no_collision

		; No collision if original position is on the left of the edge
		SIGNED_CMP(orig_x_pixel, orig_x_screen, stage_data+STAGE_OOS_PLATFORM_OFFSET_RIGHT_LSB COMMA y, stage_data+STAGE_OOS_PLATFORM_OFFSET_RIGHT_MSB COMMA y)
		bmi no_collision

		; No collision if final position is on the right of the edge
		SIGNED_CMP(stage_data+STAGE_OOS_PLATFORM_OFFSET_RIGHT_LSB COMMA y, stage_data+STAGE_OOS_PLATFORM_OFFSET_RIGHT_MSB COMMA y, final_x_pixel, final_x_screen)
		bmi no_collision

			; Collision, set final_x to platform right edge, plus one pixel (consider the obstacle filling its last pixel)
			lda #$00
			sta final_x_subpixel
			lda stage_data+STAGE_OOS_PLATFORM_OFFSET_RIGHT_LSB, y
			sta final_x_pixel
			lda stage_data+STAGE_OOS_PLATFORM_OFFSET_RIGHT_MSB, y
			sta final_x_screen

			; Set walled flag
			ldx player_number
			sty player_a_walled, x
			lda DIRECTION_RIGHT
			sta player_a_walled_direction, x

		no_collision:
		rts
	.)
.)

move_player_handle_one_platform_right:
.(
	elements_action_vector = tmpfield1 ; Not movable, parameter of stage_iterate_all_elements
	;elements_action_vector_msb = tmpfield2
	final_x_subpixel = tmpfield3
	final_x_pixel = tmpfield4
	final_x_screen = tmpfield5
	final_y_subpixel = tmpfield6
	final_y_pixel = tmpfield7
	final_y_screen = tmpfield8
	orig_x_pixel = tmpfield9
	orig_x_screen = tmpfield10
	orig_y_pixel = tmpfield11
	orig_y_screen = tmpfield12

	platform_specific_handler_lsb = tmpfield13
	platform_specific_handler_msb = tmpfield14

	; Call appropriate handler for this kind of elements
	tax
	lda platform_specific_handlers_lsb, x
	sta platform_specific_handler_lsb
	lda platform_specific_handlers_msb, x
	sta platform_specific_handler_msb
	jmp (platform_specific_handler_lsb)
	; No return, the handler will rts

	;    unused,         PLATFORM,             SMOOTH,         OOS_PLATFORM,  OOS_SMOOTH
	platform_specific_handlers_lsb:
	.byt <dummy_routine, <one_screen_platform, <dummy_routine, <oos_platform, <dummy_routine
	platform_specific_handlers_msb:
	.byt >dummy_routine, >one_screen_platform, >dummy_routine, >oos_platform, >dummy_routine

	one_screen_platform:
	.(
		; No collision if player is above the platform (the very last pixel is not counted)
		SIGNED_CMP(stage_data+STAGE_PLATFORM_OFFSET_TOP COMMA y, #0, final_y_pixel, final_y_screen)
		bpl no_collision

		; No collision if player is under the platform (the very last pixel is not counted)
		SIGNED_CMP(final_y_pixel, final_y_screen, stage_data+STAGE_PLATFORM_OFFSET_BOTTOM COMMA y, #0)
		bpl no_collision

		; No collision if original position is on the right of the edge
		SIGNED_CMP(stage_data+STAGE_PLATFORM_OFFSET_LEFT COMMA y, #0, orig_x_pixel, orig_x_screen)
		bmi no_collision

		; No collision if final position is on the left of the edge
		SIGNED_CMP(final_x_pixel, final_x_screen, stage_data+STAGE_PLATFORM_OFFSET_LEFT COMMA y, #0)
		bmi no_collision

			; Collision, set final_x to platform left edge, minus one sub pixel
			lda #$ff
			sta final_x_subpixel
			lda stage_data+STAGE_PLATFORM_OFFSET_LEFT, y
			sta final_x_pixel
			lda #0
			sta final_x_screen

			; Set walled flag
			ldx player_number
			sty player_a_walled, x
			lda DIRECTION_LEFT
			sta player_a_walled_direction, x

		no_collision:
		rts
	.)

	oos_platform:
	.(
		; No collision if player is above the platform (the very last pixel is not counted)
		SIGNED_CMP(stage_data+STAGE_OOS_PLATFORM_OFFSET_TOP_LSB COMMA y, stage_data+STAGE_OOS_PLATFORM_OFFSET_TOP_MSB COMMA y, final_y_pixel, final_y_screen)
		bpl no_collision

		; No collision if player is under the platform (the very last pixel is not counted)
		SIGNED_CMP(final_y_pixel, final_y_screen, stage_data+STAGE_OOS_PLATFORM_OFFSET_BOTTOM_LSB COMMA y, stage_data+STAGE_OOS_PLATFORM_OFFSET_BOTTOM_MSB COMMA y)
		bpl no_collision

		; No collision if original position is on the right of the edge
		SIGNED_CMP(stage_data+STAGE_OOS_PLATFORM_OFFSET_LEFT_LSB COMMA y, stage_data+STAGE_OOS_PLATFORM_OFFSET_LEFT_MSB COMMA y, orig_x_pixel, orig_x_screen)
		bmi no_collision

		; No collision if final position is on the left of the edge
		SIGNED_CMP(final_x_pixel, final_x_screen, stage_data+STAGE_OOS_PLATFORM_OFFSET_LEFT_LSB COMMA y, stage_data+STAGE_OOS_PLATFORM_OFFSET_LEFT_MSB COMMA y)
		bmi no_collision

			; Collision, set final_x to platform left edge, minus one sub pixel
			lda #$ff
			sta final_x_subpixel
			lda stage_data+STAGE_OOS_PLATFORM_OFFSET_LEFT_LSB, y
			sta final_x_pixel
			lda stage_data+STAGE_OOS_PLATFORM_OFFSET_LEFT_MSB, y
			sta final_x_screen

			; Set walled flag
			ldx player_number
			sty player_a_walled, x
			lda DIRECTION_LEFT
			sta player_a_walled_direction, x

		no_collision:
		rts
	.)
.)

move_player_handle_one_platform_up:
.(
	elements_action_vector = tmpfield1 ; Not movable, parameter of stage_iterate_all_elements
	;elements_action_vector_msb = tmpfield2
	final_x_subpixel = tmpfield3
	final_x_pixel = tmpfield4
	final_x_screen = tmpfield5
	final_y_subpixel = tmpfield6
	final_y_pixel = tmpfield7
	final_y_screen = tmpfield8
	orig_x_pixel = tmpfield9
	orig_x_screen = tmpfield10
	orig_y_pixel = tmpfield11
	orig_y_screen = tmpfield12

	platform_specific_handler_lsb = tmpfield13
	platform_specific_handler_msb = tmpfield14

	; Call appropriate handler for this kind of elements
	tax
	lda platform_specific_handlers_lsb, x
	sta platform_specific_handler_lsb
	lda platform_specific_handlers_msb, x
	sta platform_specific_handler_msb
	jmp (platform_specific_handler_lsb)
	; No return, the handler will rts

	;    unused,         PLATFORM,             SMOOTH,         OOS_PLATFORM,  OOS_SMOOTH
	platform_specific_handlers_lsb:
	.byt <dummy_routine, <one_screen_platform, <dummy_routine, <oos_platform, <dummy_routine
	platform_specific_handlers_msb:
	.byt >dummy_routine, >one_screen_platform, >dummy_routine, >oos_platform, >dummy_routine

	one_screen_platform:
	.(
		; No collision if player is on the left of the platform (the very last pixel is not counted)
		SIGNED_CMP(stage_data+STAGE_PLATFORM_OFFSET_LEFT COMMA y, #0, orig_x_pixel, orig_x_screen)
		bpl no_collision

		; No collision if player is on the right of the platform (the very last pixel is not counted)
		SIGNED_CMP(orig_x_pixel, orig_x_screen, stage_data+STAGE_PLATFORM_OFFSET_RIGHT COMMA y, #0)
		bpl no_collision

		; No collision if original position is above the edge
		SIGNED_CMP(orig_y_pixel, orig_y_screen, stage_data+STAGE_PLATFORM_OFFSET_BOTTOM COMMA y, #0)
		bmi no_collision

		; No collision if final position is under the edge
		SIGNED_CMP(stage_data+STAGE_PLATFORM_OFFSET_BOTTOM COMMA y, #0, final_y_pixel, final_y_screen)
		bmi no_collision

			; Collision, set final_y to platform bottom edge, plus one pixel (consider the obstacle filling its last pixel)
			lda #$00
			sta final_y_subpixel
			lda stage_data+STAGE_PLATFORM_OFFSET_BOTTOM, y
			sta final_y_pixel
			lda #0
			sta final_y_screen

		no_collision:
		rts
	.)

	oos_platform:
	.(
		; No collision if player is on the left of the platform (the very last pixel is not counted)
		SIGNED_CMP(stage_data+STAGE_OOS_PLATFORM_OFFSET_LEFT_LSB COMMA y, stage_data+STAGE_OOS_PLATFORM_OFFSET_LEFT_MSB COMMA y, orig_x_pixel, orig_x_screen)
		bpl no_collision

		; No collision if player is on the right of the platform (the very last pixel is not counted)
		SIGNED_CMP(orig_x_pixel, orig_x_screen, stage_data+STAGE_OOS_PLATFORM_OFFSET_RIGHT_LSB COMMA y, stage_data+STAGE_OOS_PLATFORM_OFFSET_RIGHT_MSB COMMA y)
		bpl no_collision

		; No collision if original position is above the edge
		SIGNED_CMP(orig_y_pixel, orig_y_screen, stage_data+STAGE_OOS_PLATFORM_OFFSET_BOTTOM_LSB COMMA y, stage_data+STAGE_OOS_PLATFORM_OFFSET_BOTTOM_MSB COMMA y)
		bmi no_collision

		; No collision if final position is under the edge
		SIGNED_CMP(stage_data+STAGE_OOS_PLATFORM_OFFSET_BOTTOM_LSB COMMA y, stage_data+STAGE_OOS_PLATFORM_OFFSET_BOTTOM_MSB COMMA y, final_y_pixel, final_y_screen)
		bmi no_collision

			; Collision, set final_y to platform bottom edge, plus one pixel (consider the obstacle filling its last pixel)
			lda #$00
			sta final_y_subpixel
			lda stage_data+STAGE_OOS_PLATFORM_OFFSET_BOTTOM_LSB, y
			sta final_y_pixel
			lda stage_data+STAGE_OOS_PLATFORM_OFFSET_BOTTOM_MSB, y
			sta final_y_screen

		no_collision:
		rts
	.)
.)

move_player_handle_one_platform_down:
.(
	elements_action_vector = tmpfield1 ; Not movable, parameter of stage_iterate_all_elements
	;elements_action_vector_msb = tmpfield2
	final_x_subpixel = tmpfield3
	final_x_pixel = tmpfield4
	final_x_screen = tmpfield5
	final_y_subpixel = tmpfield6
	final_y_pixel = tmpfield7
	final_y_screen = tmpfield8
	orig_x_pixel = tmpfield9
	orig_x_screen = tmpfield10
	orig_y_pixel = tmpfield11
	orig_y_screen = tmpfield12

	platform_specific_handler_lsb = tmpfield13
	platform_specific_handler_msb = tmpfield14

	; Call appropriate handler for this kind of elements
	tax
	lda platform_specific_handlers_lsb, x
	sta platform_specific_handler_lsb
	lda platform_specific_handlers_msb, x
	sta platform_specific_handler_msb
	jmp (platform_specific_handler_lsb)
	; No return, the handler will rts

	;    unused,         PLATFORM,             SMOOTH,               OOS_PLATFORM,  OOS_SMOOTH
	platform_specific_handlers_lsb:
	.byt <dummy_routine, <one_screen_platform, <one_screen_platform, <oos_platform, <oos_platform
	platform_specific_handlers_msb:
	.byt >dummy_routine, >one_screen_platform, >one_screen_platform, >oos_platform, >oos_platform

	one_screen_platform:
	.(
		; No collision if player is on the left of the platform (the very last pixel is not counted)
		SIGNED_CMP(stage_data+STAGE_PLATFORM_OFFSET_LEFT COMMA y, #0, orig_x_pixel, orig_x_screen)
		bpl no_collision

		; No collision if player is on the right of the platform (the very last pixel is not counted)
		SIGNED_CMP(orig_x_pixel, orig_x_screen, stage_data+STAGE_PLATFORM_OFFSET_RIGHT COMMA y, #0)
		bpl no_collision

		; No collision if original position is under the edge
		SIGNED_CMP(stage_data+STAGE_PLATFORM_OFFSET_TOP COMMA y, #0, orig_y_pixel, orig_y_screen)
		bmi no_collision

		; No collision if final position is above the edge
		SIGNED_CMP(final_y_pixel, final_y_screen, stage_data+STAGE_PLATFORM_OFFSET_TOP COMMA y, #0)
		bmi no_collision

			; Collision, set final_y to platform top edge, minus one subpixel
			lda #$ff
			sta final_y_subpixel
			lda stage_data+STAGE_PLATFORM_OFFSET_TOP, y
			sta final_y_pixel
			lda #0
			sta final_y_screen

			; Set grounded flag
			ldx player_number
			sty player_a_grounded, x

		no_collision:
		rts
	.)

	oos_platform:
	.(
		; No collision if player is on the left of the platform (the very last pixel is not counted)
		SIGNED_CMP(stage_data+STAGE_OOS_PLATFORM_OFFSET_LEFT_LSB COMMA y, stage_data+STAGE_OOS_PLATFORM_OFFSET_LEFT_MSB COMMA y, orig_x_pixel, orig_x_screen)
		bpl no_collision

		; No collision if player is on the right of the platform (the very last pixel is not counted)
		SIGNED_CMP(orig_x_pixel, orig_x_screen, stage_data+STAGE_OOS_PLATFORM_OFFSET_RIGHT_LSB COMMA y, stage_data+STAGE_OOS_PLATFORM_OFFSET_RIGHT_MSB COMMA y)
		bpl no_collision

		; No collision if original position is under the edge
		SIGNED_CMP(stage_data+STAGE_OOS_PLATFORM_OFFSET_TOP_LSB COMMA y, stage_data+STAGE_OOS_PLATFORM_OFFSET_TOP_MSB COMMA y, orig_y_pixel, orig_y_screen)
		bmi no_collision

		; No collision if final position is above the edge
		SIGNED_CMP(final_y_pixel, final_y_screen, stage_data+STAGE_OOS_PLATFORM_OFFSET_TOP_LSB COMMA y, stage_data+STAGE_OOS_PLATFORM_OFFSET_TOP_MSB COMMA y)
		bmi no_collision

			; Collision, set final_y to platform top edge, minus one subpixel
			lda #$ff
			sta final_y_subpixel
			lda stage_data+STAGE_OOS_PLATFORM_OFFSET_TOP_LSB, y
			sta final_y_pixel
			lda stage_data+STAGE_OOS_PLATFORM_OFFSET_TOP_MSB, y
			sta final_y_screen

			; Set grounded flag
			ldx player_number
			sty player_a_grounded, x

		no_collision:
		rts
	.)
.)

; Check the player's position and modify the current state accordingly
;  register X - player number
;  tmpfield4 - player's current X pixel
;  tmpfield7 - player's current Y pixel
;  tmpfield5 - player's current X screen
;  tmpfield8 - player's current Y screen
;
;  The selected bank must be the correct character's bank.
;
;  Call character code, which may overwrite other things - TODO clear guidelines of allowed side effects for character callbacks
;  Overwrites tmpfield1 and tmpfield2
check_player_position:
.(
	capped_x = tmpfield1 ; Not movable, used by particle_death_start
	capped_y = tmpfield2 ; Not movable, used by particle_death_start

	; Shortcut, set by move_player, equal to "player_a_x, x" and friends
	current_x_pixel = tmpfield4
	current_x_screen = tmpfield5
	current_y_pixel = tmpfield7
	current_y_screen = tmpfield8

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
	lda player_a_grounded, x
	beq offground

		; On ground

		; Reset aerial jumps counter
		lda #$00
		sta player_a_num_aerial_jumps, x

		; Reset gravity modifications
		jsr reset_default_gravity

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
		jsr reset_default_gravity

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
		lda #PLAYER_STATE_RESPAWN
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
		SWITCH_SELECTED_PLAYER
		txa
		sta gameover_winner
		SWITCH_SELECTED_PLAYER
		no_set_winner:

		; Do not keep an invalid number of stocks
		lda #0
		sta player_a_stocks, x

		; Hide dead player
		lda #PLAYER_STATE_INNEXISTANT
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
;
; Overwrites A, Y, player_number, tmpfield1 to tmpfield5
write_player_damages:
.(
	;TODO optimizable - could remove call to jsr last_nt_buffer and absolute,x indexing
	;     rationale - stage/char code modifying background could be called after write_player_damages (ensuring X is zero in current implem)
	;TODO optimizable - inverse X and Y for referencing player and ntbuffer index, allowing to use "zp,x" addressing mode

	damage_tmp = tmpfield1
	tile_construct = tmpfield2

	player_stocks = tmpfield3
	buffer_count = tmpfield4
	character_icon = tmpfield5

	; Do not compute buffers if it would match values on screen
	lda player_a_damages, x
	cmp player_a_last_shown_damage, x
	bne do_it
	lda player_a_stocks, x
	cmp player_a_last_shown_stocks, x
	bne do_it
		rts
	do_it:
	lda player_a_stocks, x
	sta player_a_last_shown_stocks, x
	lda player_a_damages, x
	sta player_a_last_shown_damage, x

	; Do not compute buffers if damage metter is hidden
	.(
		lda config_player_a_present, x
		bne ok
			rts
		ok:
	.)

	; Save X
	stx player_number

	; Write the damage buffer
	.(
		; Player number in Y
		ldy player_number

		; Buffer header
		jsr last_nt_buffer
		lda #$01                    ; Continuation byte
		sta nametable_buffers, x
		lda #$23                    ; PPU address MSB
		sta nametable_buffers+1, x
		lda damages_ppu_position, y ; PPU address LSB
		sta nametable_buffers+2, x
		lda #$03                    ; Tiles count
		sta nametable_buffers+3, x

		; Tiles, decimal representation of the value (value is capped at 199)
		.(
			lda player_a_damages, y
			cmp #100
			bcs one_hundred
				less_than_one_hundred:
					sta damage_tmp
					lda #TILE_CHAR_0
					sta nametable_buffers+4, x
					jmp ok
				one_hundred:
					;sec ; Ensured by bcs
					sbc #100
					sta damage_tmp
					lda #TILE_CHAR_1
					sta nametable_buffers+4, x
			ok:
		.)
		.(
			;TODO optimizable - divide by two then use lookup table
			lda #TILE_CHAR_0
			sta tile_construct

			lda damage_tmp
			cmp #50
			bcc less_than_fifty
				;sec ; ensured by bcc not branching
				sbc #50
				sta damage_tmp
				lda #TILE_CHAR_5
				sta tile_construct
			less_than_fifty:

			lda damage_tmp
			.( : cmp #10 : bcc ok : sbc #10 : inc tile_construct : ok : .)
			.( : cmp #10 : bcc ok : sbc #10 : inc tile_construct : ok : .)
			.( : cmp #10 : bcc ok : sbc #10 : inc tile_construct : ok : .)
			.( : cmp #10 : bcc ok : sbc #10 : inc tile_construct : ok : .)

			sta damage_tmp
			lda tile_construct
			sta nametable_buffers+5, x
		.)
		.(
			lda damage_tmp
			clc
			adc #TILE_CHAR_0
			sta nametable_buffers+6, x
		.)
	.)

	; Construct stocks buffers
	.(
		; Store character's icon in player-independant location
		lda character_icons, y
		sta character_icon

		; Store player's stocks count in player-independant location
		lda player_a_stocks, y
		sta player_stocks

		; Y = offset in stocks_ppu_position
		tya
		asl
		asl
		tay

		; Write buffers
		lda #3
		sta buffer_count
		stocks_buffer:
			; Buffer header
			lda #$01                   ; Continuation byte
			sta nametable_buffers+7, x ;
			lda #$23                   ; PPU address MSB
			sta nametable_buffers+8, x ;
			lda stocks_ppu_position, y ; PPU address LSB
			sta nametable_buffers+9, x ;
			lda #$01                    ; Tiles count
			sta nametable_buffers+10, x ;

			; Set stock tile depending of the stock's availability
			lda buffer_count
			cmp player_stocks
			bcs empty_stock
				filled_stock:
					lda character_icon
					jmp set_stock_tile
				empty_stock:
					lda #TILE_SOLID_0
			set_stock_tile:
			sta nametable_buffers+11, x

			; Loop for each stock to print
			iny

			dec buffer_count
			bmi end_loop
				txa
				clc
				adc #5
				tax

				jmp stocks_buffer
			end_loop:
	.)

	; Next continuation byte to 0
	lda #$00
	sta nametable_buffers+12, x

	; Restore X
	ldx player_number

	rts

	damages_ppu_position:
		.byt $48, $54

	stocks_ppu_position:
		.byt $08+35, $08+32, $08+3, $08
		.byt $14+35, $14+32, $14+3, $14

	character_icons:
		.byt $d0, $d5
.)

; Update comestic effects on the player
;  register X must contain the player number
player_effects:
.(
	.(
		lda config_player_a_present, x
		beq end
			jsr blinking
			jsr particle_directional_indicator_tick
			jsr particle_death_tick
		end:
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

		; Add alternate palette offset if appropriate
		lda player_a_hitstun, x ; Blink under hitstun
		and #%00000010
		bne alternate_palette

		ldy system_index        ; Shine under fastfall
		lda default_gravity_per_system_msb, y
		cmp player_a_gravity_msb, x
		bcc alternate_palette ; default gravity < current gravity
		bne palette_selected ; default gravity > current gravity
			lda default_gravity_per_system_lsb, y
			cmp player_a_gravity_lsb, x
			bcs palette_selected ; default gravity >= current gravity

			alternate_palette:
			lda palette_buffer
			clc
			adc #PLAYER_EFFECTS_PALLETTE_SIZE
			sta palette_buffer
			lda palette_buffer+1
			adc #0
			sta palette_buffer+1

		palette_selected:

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

	ldx #1 ; X is the player number
	update_one_player_sprites:
		; Select character's bank
		ldy config_player_a_character, x
		SWITCH_BANK(characters_bank_number COMMA y)

		; Player
		.(
			; Get a vector to the player's animation state
			lda anim_state_per_player_lsb, x
			sta animation_vector
			lda anim_state_per_player_msb, x
			sta animation_vector+1

			lda player_a_x, x
			ldy #ANIMATION_STATE_OFFSET_X_LSB
			sta (animation_vector), y
			lda player_a_y, x
			ldy #ANIMATION_STATE_OFFSET_Y_LSB
			sta (animation_vector), y
			lda player_a_x_screen, x
			ldy #ANIMATION_STATE_OFFSET_X_MSB
			sta (animation_vector), y
			lda player_a_y_screen, x
			ldy #ANIMATION_STATE_OFFSET_Y_MSB
			sta (animation_vector), y

			stx player_number
			jsr stb_animation_draw
			jsr animation_tick
			ldx player_number
		.)

		; Stop there in rollback mode, only player animations are game impacting (for hitboxes)
		lda network_rollback_mode
		bne loop

		; Player's out of screen indicator
		.(
			; Get a vector to the player's oos animation state
			lda oos_anim_state_per_player_lsb, x
			sta animation_vector
			lda oos_anim_state_per_player_msb, x
			sta animation_vector+1

			; Choose on which edge to place the oos animation
			lda player_a_x_screen, x
			bmi oos_left
			bne oos_right
			lda player_a_y_screen, x
			bmi oss_top
			bne oos_bot
			jmp oos_indicator_drawn

			oos_left:
				lda player_a_y, x ; TODO cap to min 0 - max 240-8
				ldy #ANIMATION_STATE_OFFSET_Y_LSB
				sta (animation_vector), y
				lda DIRECTION_LEFT
				ldy #ANIMATION_STATE_OFFSET_DIRECTION
				sta (animation_vector), y
				lda #0
				ldy #ANIMATION_STATE_OFFSET_X_LSB
				sta (animation_vector), y
				jmp oos_indicator_placed

			oos_right:
				lda player_a_y, x ; TODO cap to min 0 - max 240-8
				ldy #ANIMATION_STATE_OFFSET_Y_LSB
				sta (animation_vector), y
				lda DIRECTION_RIGHT
				ldy #ANIMATION_STATE_OFFSET_DIRECTION
				sta (animation_vector), y
				lda #255-8
				ldy #ANIMATION_STATE_OFFSET_X_LSB
				sta (animation_vector), y
				jmp oos_indicator_placed

			oss_top:
				lda player_a_x, x ; TODO cap to min 0 - max 255-8
				ldy #ANIMATION_STATE_OFFSET_X_LSB
				sta (animation_vector), y
				lda DIRECTION_LEFT
				ldy #ANIMATION_STATE_OFFSET_DIRECTION
				sta (animation_vector), y
				lda #0
				ldy #ANIMATION_STATE_OFFSET_Y_LSB
				sta (animation_vector), y
				jmp oos_indicator_placed

			oos_bot:
				lda player_a_x, x ; TODO cap to min 0 - max 255-8
				ldy #ANIMATION_STATE_OFFSET_X_LSB
				sta (animation_vector), y
				lda DIRECTION_RIGHT
				ldy #ANIMATION_STATE_OFFSET_DIRECTION
				sta (animation_vector), y
				lda #240-8
				ldy #ANIMATION_STATE_OFFSET_Y_LSB
				sta (animation_vector), y
				;jmp oos_indicator_placed

			oos_indicator_placed:
				stx player_number
				jsr animation_draw
				jsr animation_tick
				ldx player_number

			oos_indicator_drawn:
		.)

		; Loop for both players
		loop:
		dex
		bmi all_player_sprites_updated
		jmp update_one_player_sprites
	all_player_sprites_updated:

	; Enhancement sprites
	jsr particle_draw
	;jsr show_hitboxes

	rts

	anim_state_per_player_lsb:
	.byt <player_a_animation, <player_a_animation+ANIMATION_STATE_LENGTH
	anim_state_per_player_msb:
	.byt >player_a_animation, >player_a_animation+ANIMATION_STATE_LENGTH

	oos_anim_state_per_player_lsb:
	.byt <player_a_out_of_screen_indicator, <player_a_out_of_screen_indicator+ANIMATION_STATE_LENGTH
	oos_anim_state_per_player_msb:
	.byt >player_a_out_of_screen_indicator, >player_a_out_of_screen_indicator+ANIMATION_STATE_LENGTH
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

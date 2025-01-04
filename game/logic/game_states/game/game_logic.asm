init_game_state:
.(
	SWITCH_BANK(#GAMESTATE_GAME_EXTRA_BANK)
	jmp extra_init_game_state
	;rts ; useless, jump to subroutine
.)

game_tick:
.(
	; Reset temporary velocity
	lda #0
	sta player_a_temporary_velocity_h
	sta player_a_temporary_velocity_h_low
	sta player_a_temporary_velocity_v
	sta player_a_temporary_velocity_v_low

	sta player_b_temporary_velocity_h
	sta player_b_temporary_velocity_h_low
	sta player_b_temporary_velocity_v
	sta player_b_temporary_velocity_v_low

	; Tick game mode
	.(
		ldx config_game_mode
		lda game_modes_pre_update_lsb, x
		sta tmpfield1
		lda game_modes_pre_update_msb, x
		sta tmpfield2
		jsr call_pointed_subroutine ; omptimizable - we could directly jump to (tmpfield1) and require the hook to jump back to "continue" or "abort" labels
		bcc ok
			rts
		ok:
	.)

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

		; Keep inputs dirty (inlined double call to dumb_keep_input_dirty)
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
		SWITCH_BANK(#GAMESTATE_GAME_EXTRA_BANK)
		jsr slowdown
		beq no_slowdown
			; Keep inputs dirty (inlined double call to dumb_keep_input_dirty)
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
	.(
		; Caracter dependent screen updating routines
		lda network_rollback_mode
		bne end_visuals
			ldx #0
			jsr write_player_damages
			jsr player_effects
			ldx #1
			jsr write_player_damages
			jsr player_effects
		end_visuals:

		; Deathplosion
		SWITCH_BANK(#GAMESTATE_GAME_EXTRA_BANK)
		jsr vfx_deathplosion

		; Characters animations (and extras like oos bubble)
		;TODO optimizable could not loop, and be included in "Caracter dependent screen updating routines"
		;     but shall be done even in rollback because it ticks animations (which are part of the state) and draw animations (which updates hitboxes)
		;     Ok, seems hard to do, and just avoid a loop. Future me (or dear maintainer), it may require some serious refactor, problem being than animations
		;     are essential for display AND game state.
		jmp update_sprites
	.)

	;rts ; useless, jump to subroutine
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
	;TODO optimizable, unroll loop
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
	jsr check_players_hit

	; Update both players
	ldx #$00 ; player number
	update_one_player:
		; Select character's bank
		ldy config_player_a_character, x
		SWITCH_BANK(characters_bank_number COMMA y)

		; Call global update routine
		lda characters_global_tick_routine_lsb, y
		sta tmpfield1
		lda characters_global_tick_routine_msb, y
		sta tmpfield2
		jsr call_pointed_subroutine

		; Call the state update routine
		ldy config_player_a_character, x
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

	inx
	cpx #$02
	bne update_one_player

	; Updates that impacts both players
	.(
		; Jostling
		;  Compute manathan distance between players, if too close move them appart
		;
		;  Better use simple distance instead of checking if hurtboxes overlap
		;   - Causes less weird behaviors caused by unstable hurtbox shape (you feel to be pushed farther from a crashing opponent than an idle one.)
		;   - Less CPU intensive
		;  Better move players than change their velocity
		;   - We don't want to keep momentum after being pushed appart
		.(
			JOSTLING_STRENGTH = $0050
			JOSTLING_DISTANCE_V = 16
			JOSTLING_DISTANCE_H = 8

			; Jostling is active only if both player are in the stage
			;NOTE the "respawn" state is actually the invisibility time before respawn platform appears
			.(
				lda player_a_state
				cmp #PLAYER_STATE_RESPAWN
				beq skip_jostling
				cmp #PLAYER_STATE_INNEXISTANT
				beq skip_jostling
				lda player_b_state
				cmp #PLAYER_STATE_RESPAWN
				beq skip_jostling
				cmp #PLAYER_STATE_INNEXISTANT
				bne ok
					skip_jostling:
					jmp end_jostling
				ok:
			.)

			; Jostling is active only if both players are on main screen
			lda player_a_x_screen
			bne end_jostling
			lda player_a_y_screen
			bne end_jostling
			lda player_b_x_screen
			bne end_jostling
			lda player_b_y_screen
			bne end_jostling

			; Check if characters are at jostling vertical distance
			.(
				lda player_a_y
				sec
				sbc player_b_y
				bcc negative
					positive:
						cmp #JOSTLING_DISTANCE_V
						bcs end_jostling
						jmp vertical_in_range
					negative:
						cmp #<-JOSTLING_DISTANCE_V
						bcc end_jostling
						;jmp vertical_in_range ; useless, falltrhough
				vertical_in_range:
			.)

			; Check if characters are at jostling horizontal distance
			.(
				lda player_a_x
				sec
				sbc player_b_x
				bcc negative
					positive:
						cmp #JOSTLING_DISTANCE_H
						bcs end_jostling
						jmp player_a_is_on_right ; optimizable, inline
					negative:
						cmp #<-JOSTLING_DISTANCE_H
						bcc end_jostling
						jmp player_a_is_on_left ; optimizable, inline
			.)

			player_a_is_on_right:
			.(
				lda #<JOSTLING_STRENGTH
				clc
				adc player_a_temporary_velocity_h_low
				sta player_a_temporary_velocity_h_low
				lda #>JOSTLING_STRENGTH
				adc player_a_temporary_velocity_h
				sta player_a_temporary_velocity_h

				lda #<-JOSTLING_STRENGTH
				clc
				adc player_b_temporary_velocity_h_low
				sta player_b_temporary_velocity_h_low
				lda #>-JOSTLING_STRENGTH
				adc player_b_temporary_velocity_h
				sta player_b_temporary_velocity_h

				jmp end_jostling
			.)

			player_a_is_on_left:
			.(
				lda #<JOSTLING_STRENGTH
				clc
				adc player_b_temporary_velocity_h_low
				sta player_b_temporary_velocity_h_low
				lda #>JOSTLING_STRENGTH
				adc player_b_temporary_velocity_h
				sta player_b_temporary_velocity_h

				lda #<-JOSTLING_STRENGTH
				clc
				adc player_a_temporary_velocity_h_low
				sta player_a_temporary_velocity_h_low
				lda #>-JOSTLING_STRENGTH
				adc player_a_temporary_velocity_h
				sta player_a_temporary_velocity_h
			.)

			end_jostling:
		.)
	.)

	; Move characters, and check position-dependent events (like being behind blastlines)
	.(
		;TODO optimizable, unroll
		ldx #0
		generic_update_one_player:
			; Select character's bank
			ldy config_player_a_character, x
			SWITCH_BANK(characters_bank_number COMMA y)

			; Generic update routines
			stx player_number
			jsr move_player
			jsr check_player_position

			; Loop
			inx
			cpx #$02
			bne generic_update_one_player
	.)

	rts
.)

; Calls a subroutine depending on player's state
;  register X - Player number
;  tmpfield1 - Jump table address (low byte)
;  tmpfield2 - Jump table address (high bute)
;
; Overwrites A, Y, tmpfield1-tmpfield4
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

; Apply effects of players hitboxes and hurtboxes.
;
; Overwrites all registers, tmpfield1 to tmpfield6, tmpfield10, and tmpfield11
; Switches current bank
check_players_hit:
.(
	; - Check hitbox-hitbox collisions
	; - For each player:
	;   - Check projectile-hitbox
	;   - Check projectile-hurtbox
	;   - Check hitbox-hurtbox

	; Parameters of boxes_overlap
	striking_box = tmpfield1
	striking_box_msb = tmpfield2
	smashed_box = tmpfield3
	smashed_box_msb = tmpfield4

	; Parameters of onhurt callbacks
	current_player = tmpfield10
	opponent_player = tmpfield11
	default_onhurt_lsb = tmpfield12
	default_onhurt_msb = tmpfield13
	default_onhurt_bank = tmpfield14

	; Parameters of projectile hit callback
	projectile_index = tmpfield12

	; Check hitbox-hitbox collisions
	.(
		lda player_a_hitbox_enabled
		beq ok
		lda player_b_hitbox_enabled
		beq ok

			lda #<player_a_hitbox_left
			sta striking_box
			lda #>player_a_hitbox_left
			sta striking_box_msb
			lda #<player_b_hitbox_left
			sta smashed_box
			lda #>player_b_hitbox_left
			sta smashed_box_msb
			jsr interleaved_boxes_overlap
			bne ok

				; Parry if both hitboxes are direct, else call custom hitbox handler
				; Player A takes priority if both hitboxes are custom. May have to be changed to call
				; both callbacks.
				lda #HITBOX_CUSTOM
				cmp player_a_hitbox_enabled
				beq custom_hitbox_player_a
				cmp player_b_hitbox_enabled
				beq custom_hitbox_player_b

					direct_hitbox:
						; Apply parry to both players if their hitboxes are direct (custom hitboxes must take care of themselve)
						jsr parry_players
						jmp end

					custom_hitbox_player_b:
						ldx #1
						jmp custom_hitbox
					custom_hitbox_player_a:
						ldx #0
					custom_hitbox:
						; Call hitbox's callback
						ldy config_player_a_character, x
						SWITCH_BANK(characters_bank_number COMMA y)
						ldy #HITBOX
						lda player_a_custom_hitbox_routine_lsb, x
						sta tmpfield1
						lda player_a_custom_hitbox_routine_msb, x
						sta tmpfield2
						jsr call_pointed_subroutine
						jmp end

		ok:
	.)

	; Check projectile collisions
	.(
		; Check player A projectiles vs player B hit/hurt boxes
		.(
#if NB_PROJECTILES_PER_PLAYER <> 1
#error unrolled loop expects NB_PROJECTILES_PER_PLAYER to be 1
#endif
			lda player_a_projectile_1_flags
			beq ok

				; Store projectile's hitbox
				lda #<player_a_projectile_1_hitbox_left
				sta striking_box
				lda #>player_a_projectile_1_hitbox_left
				sta striking_box_msb

				; Check projectile vs hitbox
				lda player_b_hitbox_enabled
				beq check_hurtbox

					lda #<player_b_hitbox_left
					sta smashed_box
					lda #>player_b_hitbox_left
					sta smashed_box_msb
					jsr interleaved_boxes_overlap
					bne check_hurtbox

						lda #0
						sta projectile_index
						ldx #0
						jsr impact_projectile_hitbox

				; Check projectile vs hurtbox
				check_hurtbox:
				lda #<player_b_hurtbox_left
				sta smashed_box
				lda #>player_b_hurtbox_left
				sta smashed_box_msb
				jsr interleaved_boxes_overlap
				bne ok

					lda #0
					sta projectile_index
					ldx #0
					jsr impact_projectile_hurtbox

			ok:
		.)

		; Check player B projectiles vs player A hit/hurt boxes
		.(
#if NB_PROJECTILES_PER_PLAYER <> 1
#error unrolled loop expects NB_PROJECTILES_PER_PLAYER to be 1
#endif
			lda player_b_projectile_1_flags
			beq ok

				; Store projectile's hitbox
				lda #<player_b_projectile_1_hitbox_left
				sta striking_box
				lda #>player_b_projectile_1_hitbox_left
				sta striking_box_msb

				; Check projectile vs hitbox
				lda player_a_hitbox_enabled
				beq check_hurtbox

					lda #<player_a_hitbox_left
					sta smashed_box
					lda #>player_a_hitbox_left
					sta smashed_box_msb
					jsr interleaved_boxes_overlap
					bne check_hurtbox

						lda #0
						sta projectile_index
						ldx #1
						jsr impact_projectile_hitbox

				; Check projectile vs hurtbox
				check_hurtbox:
				lda #<player_a_hurtbox_left
				sta smashed_box
				lda #>player_a_hurtbox_left
				sta smashed_box_msb
				jsr interleaved_boxes_overlap
				bne ok

					lda #0
					sta projectile_index
					ldx #1
					jsr impact_projectile_hurtbox

			ok:
		.)
	.)

	; Check hitbox-hurtbox collisions
	.(
		; Check player A hitbox vs player B hurtbox
		.(
			lda player_a_hitbox_enabled
			beq ok

				lda #<player_a_hitbox_left
				sta striking_box
				lda #>player_a_hitbox_left
				sta striking_box_msb
				lda #<player_b_hurtbox_left
				sta smashed_box
				lda #>player_b_hurtbox_left
				sta smashed_box_msb
				jsr interleaved_boxes_overlap
				bne ok

					ldx #0
					jsr impact_hitbox_hurtbox
					jmp ok

			ok:
		.)

		; Check player B hitbox vs player A hurtbox
		.(
			lda player_b_hitbox_enabled
			beq ok

				lda #<player_b_hitbox_left
				sta striking_box
				lda #>player_b_hitbox_left
				sta striking_box_msb
				lda #<player_a_hurtbox_left
				sta smashed_box
				lda #>player_a_hurtbox_left
				sta smashed_box_msb
				jsr interleaved_boxes_overlap
				bne ok

					ldx #1
					jsr impact_hitbox_hurtbox
					jmp ok

			ok:
		.)
	.)

	end:
	rts

	; register X - striker player number
	impact_hitbox_hurtbox:
	.(
		; Select behaviour from hitbox type
		lda player_a_hitbox_enabled, x
		cmp #HITBOX_DIRECT
		beq direct_hitbox

			custom_hitbox:
				; Call hitbox on hurtbox callback
				ldy config_player_a_character, x
				SWITCH_BANK(characters_bank_number COMMA y)
				ldy #HURTBOX
				lda player_a_custom_hitbox_routine_lsb, x
				sta tmpfield1
				lda player_a_custom_hitbox_routine_msb, x
				sta tmpfield2
				jmp call_pointed_subroutine
				; no return ; jump to subroutine

			direct_hitbox:
				; Fire on-hurt event
				stx current_player
				SWITCH_SELECTED_PLAYER
				stx opponent_player

				ldy config_player_a_character, x
				SWITCH_BANK(characters_bank_number COMMA y)

				lda #<hurt_player
				sta default_onhurt_lsb
				lda #>hurt_player
				sta default_onhurt_msb
				lda characters_bank_number, y
				sta default_onhurt_bank

				lda characters_onhurt_routines_table_lsb, y
				sta tmpfield1
				lda characters_onhurt_routines_table_msb, y
				sta tmpfield2
				jmp player_state_action
				; no return ; jump to subroutine

		;rts ; useless, no branch return
	.)

	; Preserve striking_box and striking_box_msb
	impact_projectile_hitbox:
	.(
		lda striking_box : pha
		lda striking_box_msb : pha

		ldy config_player_a_character, x
		SWITCH_BANK(characters_bank_number COMMA y)
		lda characters_projectile_hit_routine_lsb, y
		sta tmpfield1
		lda characters_projectile_hit_routine_msb, y
		sta tmpfield2
		ldy #HITBOX
		jsr call_pointed_subroutine

		pla : sta striking_box_msb
		pla : sta striking_box
		rts
	.)

	impact_projectile_hurtbox:
	.(
		ldy config_player_a_character, x
		SWITCH_BANK(characters_bank_number COMMA y)
		lda characters_projectile_hit_routine_lsb, y
		sta tmpfield1
		lda characters_projectile_hit_routine_msb, y
		sta tmpfield2
		ldy #HURTBOX
		jmp (tmpfield1)
		;rts ; useless, jump to subroutine
	.)
.)

; Call the default behavior from an onhurt routine
;  tmpfield12, tmpfield13 - default behavior routine address
;
;  Current bank must be the default behavior routine's bank
default_hurt_player:
.(
	jmp (tmpfield12)
.)

; Throw the hurted player depending on the hitbox hurting him
;  tmpfield10 - Player number of the striker
;  tmpfield11 - Player number of the stroke
;  register X - Player number of the stroke (equals to tmpfield11)
;
;  Notably ignores tmpfield12-tmpfield14, making it a suitable default onhurt behavior.
;
;  Can overwrite any register and any tmpfield except tmpfield10 and tmpfield11.
;  The currently selected bank must be the stroke character's bank
hurt_player:
.(
	current_player = tmpfield10
	opponent_player = tmpfield11

	; Apply force vector to the opponent
	jsr apply_force_vector

	; Disable the hitbox to avoid multi-hits
	ldx current_player
	lda #HITBOX_DISABLED
	sta player_a_hitbox_enabled, x

	; Apply damages to the opponent
	ldx current_player
	lda player_a_hitbox_damages, x ; Put hitbox damages in A
	ldx opponent_player
	clc                     ;
	adc player_a_damages, x ;
	cmp #200                ;
	bcs cap_damages         ; Apply damages, capped to 199
	jmp apply_damages:      ; TODO optimizable use "bcc" instead of "bcs+jmp"
	cap_damages:            ;
	lda #199                ;
	apply_damages:          ;
	sta player_a_damages, x ;

	; Fallthrough to hurt_player_direct
.)

; Throw the hurted player expecting other hitbox' effects (damage, velocity,...) to have already been applied
;  register X - Player number of the stroke (equals to tmpfield11)
;
;  Can overwrite any register and any tmpfield except tmpfield10 and tmpfield11.
;  The currently selected bank must be the stroke character's bank
hurt_player_direct:
.(
	current_player = tmpfield10
	opponent_player = tmpfield11

	; Reset fall speed
	jsr reset_default_gravity

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

	; Play hit sound
	jmp audio_play_hit

	;rts ; useless, jump to subroutine
.)

; Make players who hit their respective hitbox fall
;
; Overwrite any register and any tmpfield
; Switches current bank
parry_players:
.(
	; Shake the screen
	lda #SCREENSHAKE_PARRY_INTENSITY
	sta screen_shake_noise_h
	sta screen_shake_noise_v
	lda #SCREENSHAKE_PARRY_NB_FRAMES
	sta screen_shake_counter
	lda #0
	sta screen_shake_current_x
	sta screen_shake_current_y

	; Disable hitboxes
	lda #HITBOX_DISABLED
	sta player_a_hitbox_enabled
	sta player_b_hitbox_enabled

	; Set player in thrown mode without momentum
	lda #HITSTUN_PARRY_NB_FRAMES
	sta player_a_hitstun
	sta player_b_hitstun

	lda #$00
	sta player_a_velocity_h
	sta player_a_velocity_h_low
	sta player_a_velocity_v
	sta player_a_velocity_v_low
	sta player_b_velocity_h
	sta player_b_velocity_h_low
	sta player_b_velocity_v
	sta player_b_velocity_v_low

	ldx #0
	jsr reset_default_gravity
	ldx #1
	jsr reset_default_gravity

	lda #PLAYER_STATE_THROWN
	sta player_a_state
	sta player_b_state

	ldx #1
	call_routine:
		ldy config_player_a_character, x
		SWITCH_BANK(characters_bank_number COMMA y)
		lda characters_start_routines_table_lsb, y
		sta tmpfield1
		lda characters_start_routines_table_msb, y
		sta tmpfield2
		jsr player_state_action

		dex
		bpl call_routine

	; Play parry sound
	jmp audio_play_parry

	;rts ; useless, jump to subroutine
.)

; Throw the player upward off a bumper stage element
;  register X - Player number
;
;  The selected bank must be the correct character's bank.
;
;  Overwrites all registers and all tmpfields.
bump_player_up:
.(
	ldy player_a_grounded, x
	jsr bump_player_common

	; Force vertical velocity to be upward
	.(
		lda player_a_velocity_v_low, x
		eor #%11111111
		clc
		adc #1
		sta player_a_velocity_v_low, x
		lda player_a_velocity_v, x
		eor #%11111111
		adc #0
		sta player_a_velocity_v, x
	.)

	; Adapt horizontal velocity to requested direction
	.(
		ldy player_a_grounded, x
		lda stage_data+STAGE_BUMPER_OFFSET_DAMMAGES, y
		tay
		and #%00100000
		bne nullify
		tya
		bpl ok

			invert:
				lda player_a_velocity_h_low, x
				eor #%11111111
				clc
				adc #1
				sta player_a_velocity_h_low, x
				lda player_a_velocity_h, x
				eor #%11111111
				adc #0
				sta player_a_velocity_h, x

				jmp ok

			nullify:
				lda #0
				sta player_a_velocity_h_low, x
				sta player_a_velocity_h, x

		ok:
	.)

	; Set player in thrown state
	jmp set_thrown_state

	;rts ; useless, jump to subroutine
.)

; Throw the player downward off a bumper stage element
;  register X - Player number
;
;  The selected bank must be the correct character's bank.
;
;  Overwrites all registers and all tmpfields.
bump_player_down:
.(
	ldy player_a_ceiled, x
	jsr bump_player_common

	; Let vertical velocity downard
	.(
		; Nothing to do
	.)

	; Adapt horizontal velocity to requested direction
	.(
		ldy player_a_ceiled, x
		lda stage_data+STAGE_BUMPER_OFFSET_DAMMAGES, y
		tay
		and #%00100000
		bne nullify
		tya
		bpl ok

			invert:
				lda player_a_velocity_h_low, x
				eor #%11111111
				clc
				adc #1
				sta player_a_velocity_h_low, x
				lda player_a_velocity_h, x
				eor #%11111111
				adc #0
				sta player_a_velocity_h, x

				jmp ok

			nullify:
				lda #0
				sta player_a_velocity_h_low, x
				sta player_a_velocity_h, x

		ok:
	.)

	; Set player in thrown state
	jmp set_thrown_state

	;rts ; useless, jump to subroutine
.)

; Throw the player leftward off a bumper stage element
;  register X - Player number
;
;  The selected bank must be the correct character's bank.
;
;  Overwrites all registers and all tmpfields.
bump_player_left:
.(
	ldy player_a_walled, x
	jsr bump_player_common

	; Adapt vertical velocity to requested direction
	.(
		ldy player_a_walled, x
		lda stage_data+STAGE_BUMPER_OFFSET_DAMMAGES, y
		tay
		and #%00010000
		bne nullify
		tya
		and #%01000000
		beq ok

			invert:
				lda player_a_velocity_v_low, x
				eor #%11111111
				clc
				adc #1
				sta player_a_velocity_v_low, x
				lda player_a_velocity_v, x
				eor #%11111111
				adc #0
				sta player_a_velocity_v, x

				jmp ok

			nullify:
				lda #0
				sta player_a_velocity_v_low, x
				sta player_a_velocity_v, x

		ok:
	.)

	; Force horizontal velocity to be leftward
	.(
		lda player_a_velocity_h_low, x
		eor #%11111111
		clc
		adc #1
		sta player_a_velocity_h_low, x
		lda player_a_velocity_h, x
		eor #%11111111
		adc #0
		sta player_a_velocity_h, x
	.)

	; Set player in thrown state
	jmp set_thrown_state

	;rts ; useless, jump to subroutine
.)

; Throw the player rightward off a bumper stage element
;  register X - Player number
;
;  The selected bank must be the correct character's bank.
;
;  Overwrites all registers and all tmpfields.
bump_player_right:
.(
	ldy player_a_walled, x
	jsr bump_player_common

	; Adapt vertical velocity to requested direction
	.(
		ldy player_a_walled, x
		lda stage_data+STAGE_BUMPER_OFFSET_DAMMAGES, y
		tay
		and #%00010000
		bne nullify
		tya
		and #%01000000
		beq ok

			invert:
				lda player_a_velocity_v_low, x
				eor #%11111111
				clc
				adc #1
				sta player_a_velocity_v_low, x
				lda player_a_velocity_v, x
				eor #%11111111
				adc #0
				sta player_a_velocity_v, x

				jmp ok

			nullify:
				lda #0
				sta player_a_velocity_v_low, x
				sta player_a_velocity_v, x

		ok:
	.)

	; Force horizontal velocity to be rightward
	.(
		; Nothing to do
	.)

	; Set player in thrown state
	;jmp set_thrown_state ; useless, fallthrough

	;rts ; useless, jump to subroutine

	; Fallthrough to set_thrown_state
.)

; Set player inb thrown state
;  X - player number
;
;  The selected bank must be the correct character's bank.
;
;  Overwrites all registers, tmpfield1, and tmpfield2
;  Note - the start routine itself may modify other tmpfields
set_thrown_state:
.(
	lda #PLAYER_STATE_THROWN
	sta player_a_state, x
	ldy config_player_a_character, x
	lda characters_start_routines_table_lsb, y
	sta tmpfield1
	lda characters_start_routines_table_msb, y
	sta tmpfield2

	jmp player_state_action

	;rts ; useless, jump to subroutine
.)

; Common code for bumping a player out of a bumper platform
;  register X - player number
;  register Y - platform offset from stage-data
bump_player_common:
.(
	; Apply damages
	.(
		lda stage_data+STAGE_BUMPER_OFFSET_DAMMAGES, y
		and #%00001111
		clc
		adc player_a_damages, x
		cmp #200
		bcc apply_damages
			lda #199
		apply_damages:
		sta player_a_damages, x
	.)

	; Apply force vector to the opponent
	.(
		base_h_low = tmpfield6
		base_h_high = tmpfield7
		base_v_low = tmpfield8
		base_v_high = tmpfield9
		force_h_high = tmpfield12
		force_v_high = tmpfield13
		force_h_low = tmpfield14
		force_v_low = tmpfield15

		; Vertical knockback
		.(
			; Load base knockback
			lda stage_data+STAGE_BUMPER_OFFSET_BASE_LSB, y
			sta base_v_low
			lda stage_data+STAGE_BUMPER_OFFSET_BASE_MSB, y
			sta base_v_high

			; Load sign-extended force knockback
			lda stage_data+STAGE_BUMPER_OFFSET_FORCE, y
			sta force_v_low
			lda #0
			sta force_v_high
		.)

		; Horizontal knockback
		.(
			; Load base knockback
			lda stage_data+STAGE_BUMPER_OFFSET_BASE_LSB, y
			sta base_h_low
			lda stage_data+STAGE_BUMPER_OFFSET_BASE_MSB, y
			sta base_h_high

			; Load sign-extended force knockback
			lda stage_data+STAGE_BUMPER_OFFSET_FORCE, y
			sta force_h_low
			lda #0
			sta force_h_high
		.)

		; Apply knockback
		jsr apply_force_vector_direct
	.)

	; Play hit sound
	jsr audio_play_hit

	; Lessen hitstun
	lsr player_a_hitstun, x
	lsr player_a_hitstun, x

	lda #2
	cmp screen_shake_counter
	bcc screen_shake_ok
		lsr screen_shake_counter
	screen_shake_ok:

	; Reset fall speed
	jmp reset_default_gravity

	;rts ; Useless, jump to subroutine
.)

; Apply force in current player's hitbox to it's opponent
;   tmpfield10 - striker player number
;   tmpfield11 - stroke player number
;
; Output
;   register X - stroke player number
;
; Overwrites all registers, tmpfield1-tmpfield9, tmpfield12-tmpfield15
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

	;Fallthrough to apply_force_vector_direct
.)

; Apply a composite force (base knockup + scaling knockup) to a player
;   register X - Player number
;   tmpfield6 - Horizontal base knockup (LSB)
;   tmpfield7 - Horizontal base knockup (MSB)
;   tmpfield8 - Vertical base knockup (LSB)
;   tmpfield9 - Vertical base knockup (MSB)
;   tmpfield12 - Horizontal scaling knockup (MSB)
;   tmpfield13 - Vertical scaling knockup (MSB)
;   tmpfield14 - Horizontal scaling knockup (LSB)
;   tmpfield15 - Vertical scaling knockup (LSB)
;
; Overwrites tmpfield1-tmpfield9, tmpfield12-tmpfield15
; Overwrites register A, register Y
apply_force_vector_direct:
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

	; Screenshake strength
	.(
		; Horizontal noise = knockback_h * 4
		lda knockback_h_high
		asl:asl
		sta screen_shake_noise_h

		; Vertical noise = knockback_v * 4
		lda knockback_v_high
		asl:asl
		sta screen_shake_noise_v

		; Start position
		.(
			; Compute start position from thrown player velocity
			;  vertical velocity has less impact to compensate higher typical values to fight gravity
			lda player_a_velocity_h, x
			asl
			asl
			sta screen_shake_current_x

			lda player_a_velocity_v, x
			asl
			sta screen_shake_current_y
		.)
	.)

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

	; Screenshake of duration = hitstun / 2
	.(
		SCREEN_SAKE_MAX_DURATION = $10

		lsr
		cmp #SCREEN_SAKE_MAX_DURATION
		bcc ok
			lda #SCREEN_SAKE_MAX_DURATION
		ok:
		sta screen_shake_counter
	.)

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

	rts ; TODO optimizable by jmp instead of jsr on the routine above. Kept for now as it may help profiling tools.

;TODO comment usage
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
;   - "player_a_grounded, x", "player_a_ceiled, x", "player_a_walled, x", and "player_a_walled_direction, x" are set according to collisions
;
;  Overwrites register A, regiter Y, and tmpfield1 to tmpfield14
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
	effective_velocity_lsb = tmpfield13
	effective_velocity_msb = tmpfield14

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
		;   Do not use final_x, not even in platform handlers,
		;   we care only of moving the character from (orig_x;orig_y) to (orig_x;orig_y+velocity_v)

		; Compute effective vertical velocity (normal + temporary velocity)
		lda player_a_velocity_v_low, x
		clc
		adc player_a_temporary_velocity_v_low, x
		sta effective_velocity_lsb

		lda player_a_velocity_v, x
		adc player_a_temporary_velocity_v, x
		sta effective_velocity_msb

		; Apply velocity to position
		lda effective_velocity_lsb
		clc
		adc player_a_y_low, x
		sta final_y_subpixel
		lda effective_velocity_msb
		adc orig_y_pixel
		sta final_y_pixel
		lda effective_velocity_msb
		SIGN_EXTEND()
		pha ; save velocity direction ;TODO optimizable use a tmpfield instead of the stack
		adc orig_y_screen
		sta final_y_screen

		; Clear grounded/ceiled flags (to be set by collision handlers)
		lda #0
		sta player_a_grounded, x
		sta player_a_ceiled, x

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

		; Compute effective vertical velocity (normal + temporary velocity)
		lda player_a_velocity_h_low, x
		clc
		adc player_a_temporary_velocity_h_low, x
		sta effective_velocity_lsb

		lda player_a_velocity_h, x
		adc player_a_temporary_velocity_h, x
		sta effective_velocity_msb

		; Apply velocity to position
		lda effective_velocity_lsb
		clc
		adc player_a_x_low, x
		sta final_x_subpixel
		lda effective_velocity_msb
		adc orig_x_pixel
		sta final_x_pixel
		lda effective_velocity_msb
		SIGN_EXTEND()
		pha ; save velocity direction ;TODO optimizable, use a tmpfield instead of the stack
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

	;    unused,         PLATFORM,             SMOOTH,         OOS_PLATFORM,  OOS_SMOOTH,     BUMPER
	platform_specific_handlers_lsb:
	.byt <dummy_routine, <one_screen_platform, <dummy_routine, <oos_platform, <dummy_routine, <one_screen_platform
	platform_specific_handlers_msb:
	.byt >dummy_routine, >one_screen_platform, >dummy_routine, >oos_platform, >dummy_routine, >one_screen_platform

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

	;    unused,         PLATFORM,             SMOOTH,         OOS_PLATFORM,  OOS_SMOOTH,     BUMPER
	platform_specific_handlers_lsb:
	.byt <dummy_routine, <one_screen_platform, <dummy_routine, <oos_platform, <dummy_routine, <one_screen_platform
	platform_specific_handlers_msb:
	.byt >dummy_routine, >one_screen_platform, >dummy_routine, >oos_platform, >dummy_routine, >one_screen_platform

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

	;    unused,         PLATFORM,             SMOOTH,         OOS_PLATFORM,  OOS_SMOOTH,     BUMPER
	platform_specific_handlers_lsb:
	.byt <dummy_routine, <one_screen_platform, <dummy_routine, <oos_platform, <dummy_routine, <one_screen_platform
	platform_specific_handlers_msb:
	.byt >dummy_routine, >one_screen_platform, >dummy_routine, >oos_platform, >dummy_routine, >one_screen_platform

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

			; Set ceiled flag
			ldx player_number
			sty player_a_ceiled, x

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

			; Set ceiled flag
			ldx player_number
			sty player_a_ceiled, x

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

	;    unused,         PLATFORM,             SMOOTH,               OOS_PLATFORM,  OOS_SMOOTH,    BUMPER
	platform_specific_handlers_lsb:
	.byt <dummy_routine, <one_screen_platform, <one_screen_platform, <oos_platform, <oos_platform, <one_screen_platform
	platform_specific_handlers_msb:
	.byt >dummy_routine, >one_screen_platform, >one_screen_platform, >oos_platform, >oos_platform, >one_screen_platform

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
	jmp check_collisions

		set_death_state:
		.(
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
					pha ; NOTE store for future use by deathplosion
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
					pha ; NOTE store for future use by deathplosion
			.)

			jsr particle_death_start

			; Deathplosion attributes table animation
			pla:sta capped_y
			pla:sta capped_x
			jsr deathplosion_start

			; Decrement stocks counter and check for gameover
			dec player_a_stocks, x
			bmi gameover

				respawn:
				.(
					; Set respawn state
					lda #PLAYER_STATE_RESPAWN
					sta player_a_state, x
					ldy config_player_a_character, x
					lda characters_start_routines_table_lsb, y
					sta tmpfield1
					lda characters_start_routines_table_msb, y
					sta tmpfield2
					jmp player_state_action

					;rts ; useless, jump to subroutine
				.)

				gameover:
				.(
					; Set the winner for gameover screen
					lda slow_down_counter
					bne no_set_winner
					SWITCH_SELECTED_PLAYER
					txa
					sta game_winner
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

					rts
				.)
		.)
		; No return, all branches had RTS

	check_collisions:

	; Check if on ground
	.(
		ldy player_a_grounded, x
		beq offground

			; On ground

			; Reset aerial jumps counter
			lda #$00
			sta player_a_num_aerial_jumps, x

			; Reset gravity modifications
			; TODO optimizable
			;      storing system-dependent default gravity in RAM would not require modifying Y to fetch it,
			;      allowing to avoid loading player_a_grounded, x two times
			jsr reset_default_gravity

			; Act according to platform type
			.(
				ldy player_a_grounded, x
				lda stage_data, y
				cmp #STAGE_ELEMENT_BUMPER
				beq bumper_collision

					normal:
						; Normal platform - fire on-ground event
						ldy config_player_a_character, x
						lda characters_onground_routines_table_lsb, y
						sta tmpfield1
						lda characters_onground_routines_table_msb, y
						sta tmpfield2
						jsr player_state_action
						jmp ok

					bumper_collision:
						; Bumper - throw player
						jsr bump_player_up
			.)

			jmp ok

		offground:
			; Fire off-ground event
			ldy config_player_a_character, x
			lda characters_offground_routines_table_lsb, y
			sta tmpfield1
			lda characters_offground_routines_table_msb, y
			sta tmpfield2
			jsr player_state_action

		ok:
	.)

	; Check if ceiled
	.(
		ldy player_a_ceiled, x
		beq ok

			; Act according to platform type
			.(
				lda stage_data, y
				cmp #STAGE_ELEMENT_BUMPER
				bne ok

					bumper_collision:
						; Bumper - throw player
						jsr bump_player_down
			.)

		ok:
	.)

	; Check if walled
	.(
		ldy player_a_walled, x
		beq ok

			; Act according to platform type
			.(
				lda stage_data, y
				cmp #STAGE_ELEMENT_BUMPER
				bne ok

					bumper_collision:
						; Bumper - throw player
						lda player_a_walled_direction, x
						beq left
							jsr bump_player_right
							jmp ok
						left:
							jsr bump_player_left
			.)

		ok:
	.)

	rts
.)

; Start the deathplosion animation on attributes table
;  X - player number of the KO'ed player
;  tmpfield1 - player's current X pixel (capped between 0 and 255)
;  tmpfield2 - player's current Y pixel (capped between 0 and 255)
;
; Overwrite A, tmpfield3
deathplosion_start:
.(
	; Shortcut, set by move_player, equal to "player_a_x, x" and friends
	capped_x = tmpfield1
	capped_y = tmpfield2

	; Notify we are going to dirty the screen
	.(
		; If deathplosion was already running, don't increment screen_effect we'll just replace it
		lda deathplosion_step
		bpl ok
			inc stage_screen_effect
			lda #0
			sta stage_restore_screen_step
		ok:
	.)

	; Place the animation
	.(
		lda player_a_x_screen, x
		bne horizontal
			vertical:
			.(
				; Position = (capped_x / 32) - 1
				;  /32 -> change from 256 values to 8
				;  -1 -> we want to place the center of the explosion on the character
				lda capped_x
				lsr
				lsr
				lsr
				lsr
				lsr

				sec
				sbc #1

				; Ensure position is between 0 and 5 (to avoid writing out of attributes table bounds)
				bpl check_upper
					lda #0
				check_upper:
				cmp #6
				bcc pos_ok
					lda #5
				pos_ok:

				; Set position
				sta deathplosion_pos

				lda player_a_y_screen, x
				bmi top
					bottom:
						lda #DEATHPLOSION_ORIGIN_BOTTOM
						jmp set_origin
					top:
						lda #DEATHPLOSION_ORIGIN_TOP
				set_origin:
				sta deathplosion_origin

				jmp anim_placed
			.)

			horizontal:
			.(
				; Position = (capped_y / 32) - 1
				;  /32 -> change from 256 values to 8
				;  -1 -> we want to place the center of the explosion on the character
				lda capped_y
				lsr
				lsr
				lsr
				lsr
				lsr

				sec
				sbc #1

				; Ensure position is between 0 and 5 (to avoid writing out of attributes table bounds)
				bpl check_upper
					lda #0
				check_upper:
				cmp #6
				bcc pos_ok
					lda #5
				pos_ok:

				; Set position (multiplied by 8 as required by deathplosion API)
				asl
				asl
				asl
				sta deathplosion_pos

				lda player_a_x_screen, x
				bmi left
					right:
						lda #DEATHPLOSION_ORIGIN_RIGHT
						jmp set_origin
					left:
						lda #DEATHPLOSION_ORIGIN_LEFT
				set_origin:
				sta deathplosion_origin
			.)

		anim_placed:
	.)

	; Reset animation counter
	lda #DEATHPLOSION_FRAME_COUNT-1
	sta deathplosion_step

	rts
.)

; Show on screen player's damages
;  register X must contain the player number
;
; Overwrites A, Y, player_number, tmpfield1 to tmpfield5
write_player_damages:
.(
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
		LAST_NT_BUFFER
		lda #$01                    ; Continuation byte
		sta nametable_buffers, x
		inx
		lda #$23                    ; PPU address MSB
		sta nametable_buffers, x
		inx
		lda damages_ppu_position, y ; PPU address LSB
		sta nametable_buffers, x
		inx
		lda #$03                    ; Tiles count
		sta nametable_buffers, x
		inx

		; Tiles, decimal representation of the value (value is capped at 199)
		.(
			lda player_a_damages, y
			cmp #100
			bcs one_hundred
				less_than_one_hundred:
					sta damage_tmp
					lda #TILE_CHAR_0
					sta nametable_buffers, x
					inx
					jmp ok
				one_hundred:
					;sec ; Ensured by bcs
					sbc #100
					sta damage_tmp
					lda #TILE_CHAR_1
					sta nametable_buffers, x
					inx
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
			.( : cmp #10 : bcc ok : sbc #10 : inc tile_construct : ok : .) ;TODO optimizable, put "ok" label after all four subtracts
			.( : cmp #10 : bcc ok : sbc #10 : inc tile_construct : ok : .)
			.( : cmp #10 : bcc ok : sbc #10 : inc tile_construct : ok : .)
			.( : cmp #10 : bcc ok : sbc #10 : inc tile_construct : ok : .)

			sta damage_tmp
			lda tile_construct
			sta nametable_buffers, x
			inx
		.)
		.(
			lda damage_tmp
			clc
			adc #TILE_CHAR_0
			sta nametable_buffers, x
			inx
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
			sta nametable_buffers, x ;
			inx
			lda #$23                   ; PPU address MSB
			sta nametable_buffers, x ;
			inx
			lda stocks_ppu_position, y ; PPU address LSB
			sta nametable_buffers, x ;
			inx
			lda #$01                    ; Tiles count
			sta nametable_buffers, x ;
			inx

			; Set stock tile depending of the stock's availability
			lda buffer_count
			cmp player_stocks
			bcs empty_stock
				filled_stock:
					lda character_icon
					jmp set_stock_tile
				empty_stock:
					lda #INGAME_CHARACTER_EMPTY_STOCK_TILE
			set_stock_tile:
			sta nametable_buffers, x
			inx

			; Loop for each stock to print
			iny

			dec buffer_count
			bpl stocks_buffer
			end_loop:
	.)

	; Next continuation byte to 0
	lda #$00
	sta nametable_buffers, x
	stx nt_buffers_end

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
;
;  Overwrites all registers, tmpfield1 to tmpfield2 (and certainly other tmpfields, to be checked)
player_effects:
.(
	.(
		lda config_player_a_present, x
		beq end
			jsr particle_directional_indicator_tick
			jsr particle_death_tick
			jsr blinking
		end:
		rts
	.)

	; Change palette according to player's state
	;  register X must contain the player number
	blinking:
	.(
		;TODO optimizable chose the palette before setting palette_buffer instead of adding palette size if alternate if finally chosen
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
		LAST_NT_BUFFER ; X = destination's offset (from nametable_buffers)
		ldy #0         ; Y = source's offset (from (palette_buffer) origin)

		copy_one_byte:
			lda (palette_buffer), y  ; Copy a byte
			sta nametable_buffers, x ;

			inx                               ;
			iny                               ; Prepare next byte
			cpy #PLAYER_EFFECTS_PALLETTE_SIZE ;
			bne copy_one_byte                 ;

		dex                ; Update last buffer pointer
		stx nt_buffers_end ;

		rts
	.)
.)

; Update animation and out of screen bubble for a player
;  X - Player number
;
; Overwrites all registers, player_number, and all tmpfields
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
	;TODO optimizable not needed in rollback mode
	jsr particle_draw

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

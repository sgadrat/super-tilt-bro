.(

;
; Waypoint-based moving object implementation
;

;TODO this is made to be generic, it could be placed in common libs (even in nine-gine actually)

MOVING_OBJECT_X = 0
MOVING_OBJECT_Y = 1
MOVING_OBJECT_WP = 2

; Places a moving object on its first waypoint
;  tmpfield1, tmpfield2 - Moving object state
;  A, Y - Waypoints data
;
; Overwrites A, Y, tmpfield3, tmpfield4 tmpfield5, tmpfield6
moving_object_init:
.(
	object_state = tmpfield1
	;object_state_msb = tmpfield2
	waypoints = tmpfield3
	;waypoints_msb = tmpfield4
	num_waypoints = tmpfield5
	waypoint_data_cursor = tmpfield6

	; Store waypoints data pointer
	sta waypoints
	sty waypoints+1

; Variant taking "Waypoints data" in tmpfield3,tmpfield4
;  tmpfield1, tmpfield2 - Moving object state
;  tmpfield3, tmpfield4 - Waypoints data
;
; Overwrites A, Y, tmpfield5, tmpfield6
&moving_object_init_tmpfields_params:

	; Load the number of waypoints in fixed location
	ldy #0 ; number of waypoints
	lda (waypoints), y
	sta num_waypoints

	; Get position of the last waypoint's end, it is actually the begining of the first waypoint
	clc
	adc num_waypoints
	adc num_waypoints
	tay ; Y = num_waypoint * 3 = last waypoint's end X

	adc num_waypoints
	sta waypoint_data_cursor ; waypoint_data_cursor = num_waypoint * 4 = last waypoint's end Y

	lda (waypoints), y ; last waypoint's end X
	ldy #MOVING_OBJECT_X
	sta (object_state), y ; object's X

	ldy waypoint_data_cursor
	lda (waypoints), y ; last waypoint's end Y
	ldy #MOVING_OBJECT_Y
	sta (object_state), y ; object's Y

	; Set current waypoint to the first one
	lda #0
	iny
	sta (object_state), y ; object's waypoint index

	rts
.)

; Update a moving object
;  tmpfield1, tmpfield2 - Moving object state
;  A, Y - Waypoints data
;
; Overwrites A, Y, tmpfield3, tmpfield4, tmpfield5, tmpfield6, tmpfield7, tmpfield8
;
;TODO investigate - could have a variant that only work on state "fixed_state_*", with the generic one calling it
moving_object_tick:
.(
	object_state = tmpfield1
	;object_state_msb = tmpfield2
	waypoints = tmpfield3
	;waypoints_msb = tmpfield4
	num_waypoints = tmpfield5
	fixed_state_x = tmpfield6
	fixed_state_y = tmpfield7
	fixed_state_wp = tmpfield8

	; Store waypoints data pointer
	sta waypoints
	sty waypoints+1

; Variant taking "Waypoints data" in tmpfield3,tmpfield4
;  tmpfield1, tmpfield2 - Moving object state
;  tmpfield3, tmpfield4 - Waypoints data
;
; Overwrites A, Y, tmpfield5, tmpfield6, tmpfield7, tmpfield8
&moving_object_tick_tmpfields_params:

	; Load state in fixed location
	ldy #MOVING_OBJECT_X
	lda (object_state), y
	sta fixed_state_x
	iny
	lda (object_state), y
	sta fixed_state_y
	iny
	lda (object_state), y
	sta fixed_state_wp

	; Load the number of waypoints in fixed location
	ldy #0 ; number of waypoints
	lda (waypoints), y
	sta num_waypoints

	; Add velocity to current position
	.(
		; Horizontal velocity
		.(
			; Y = offset of current waypoint's velocity_h = 1 + waypoint_index
			ldy fixed_state_wp
			iny

			; Add waypoint's velocity to current position
			lda (waypoints), y
			clc
			adc fixed_state_x
			sta fixed_state_x
		.)

		; Vertical velocity
		.(
			; Y = offset of current waypoint's velocity_v = velocity_h + num_waypoints
			tya
			clc
			adc num_waypoints
			tay

			; Add waypoint's velocity to current position
			lda (waypoints), y
			;clc ; useless, previous operation should not overflow
			adc fixed_state_y
			sta fixed_state_y
		.)
	.)

	; Check if we need to change waypoint
	.(
		; Check X position against waypoint's end
		;   Y = offset of current waypoint's end-position X = velocity_v + num_waypoints
		tya
		clc
		adc num_waypoints
		tay
		
		lda (waypoints), y
		cmp fixed_state_x
		bne ok

		; Check Y position against waypoint's end
		;   Y = offset of current waypoint's end-position Y = end_x + num_waypoints
		tya
		clc
		adc num_waypoints
		tay
		
		lda (waypoints), y
		cmp fixed_state_y
		bne ok

			; Both tests passed, we are on the waypoint, activate next waypoint
			inc fixed_state_wp

			lda fixed_state_wp
			cmp num_waypoints
			bne ok

				lda #0
				sta fixed_state_wp

		ok:
	.)

	; Copy back fixed-location state to the pointed state
	ldy #MOVING_OBJECT_X
	lda fixed_state_x
	sta (object_state), y
	iny
	lda fixed_state_y
	sta (object_state), y
	iny
	lda fixed_state_wp
	sta (object_state), y

	rts
.)

;
; Actors implementations
;

;TODO this is generic code that should be made available to all stages, or all arcade stages

#if 0
; This is WIP, notably terrible at handling collisions
;  - No collision if the platform moves over the player
;  - Allows the player to move through other walls
;  - Hardcodes sprites usage
;  - "init", cannot be called in "init" section of the stage (cf related TODO)
;    - Hacky answer is to create a "step 2" init routine for the stage, called on first tick
;      - This is needed because "stage_generic_init" must be called before
;        palette hacking in "init_game_state" so it cannot be moved to after game mode
;        initialization.
;      - Better change this process to
;        - Generic initialization done by init_game_state (instead of all stage calling "stage_generic_init" explicitely)
;        - Call game mode init routine
;        - Call stage init routine
;        That way every step can modify what have been done by its predecessors,
;        and it is cool since steps come from the most generic to the most specific.

;Example of metasprite, we should actually use an animation frame, or a fully featured animation
METASPRITE_LENGTH = 0
moving_bumper_metasprite:
.byt 4 ; Number of sprites
moving_bumper_metasprite_x:
.byt 0, 8, 16, 24
moving_bumper_metasprite_y:
.byt 0, 0, 0, 0

stage_actor_platform_mover_init:
.(
	object_state = tmpfield1
	;object_state_msb = tmpfield2
	metasprite = tmpfield1
	;metasprite_msb = tmpfield2
	waypoints = tmpfield3
	;waypoints_msb = tmpfield4
	params_ptr = tmpfield13
	;params_ptr = tmpfield14

	PARAM_MOVING_OBJECT = 0
	PARAM_METASPRITE = 4

	; Read parameters
	lda #7
	jsr inline_parameters
	lda tmpfield1
	sta params_ptr
	lda tmpfield2
	sta params_ptr+1

	; Initialize moving bumper
	ldy #PARAM_MOVING_OBJECT
	lda (params_ptr), y
	sta object_state
	iny
	lda (params_ptr), y
	sta object_state+1

	iny
	lda (params_ptr), y
	sta waypoints
	iny
	lda (params_ptr), y
	sta waypoints+1

	jsr moving_object_init_tmpfields_params

	; Prepare OAM for moving bumper sprites
	; (recycling unused target sprites)
	.(
		; Read metasprite address
		ldy #PARAM_METASPRITE
		lda (params_ptr), y
		sta metasprite
		iny
		lda (params_ptr), y
		sta metasprite+1

		; Read OAM offset
		iny
		lda (params_ptr), y
		tax

		; Initialize all tiles used by the metasprite
		ldy #METASPRITE_LENGTH
		lda (metasprite), y ; number of sprites in the metasprite
		tay
		dey
		init_one_sprite:
			lda #TILE_ARCADE_BTT_SPRITES_TILESET_TARGET_DARK
			sta oam_mirror+1, x
			lda #0
			sta oam_mirror+2, x

			inx
			inx
			inx
			inx
			dey
			bpl init_one_sprite
	.)

	rts
.)

stage_actor_platform_mover:
.(
	object_state = tmpfield1
	;object_state_msb = tmpfield2
	waypoints = tmpfield3
	;waypoints_msb = tmpfield4
	metasprite = tmpfield5
	;metasprite_msb = tmpfield6
	metasprite_x = tmpfield7
	;metasprite_x_msb = tmpfield8
	metasprite_y = tmpfield9
	;metasprite_y_msb = tmpfield10
	new_x = tmpfield11
	new_y = tmpfield12
	params_ptr = tmpfield13
	;params_ptr_msb = tmpfield14

	PARAM_MOVING_OBJECT = 0
	PARAM_METASPRITE = 4
	PARAM_PLATFORM_OFFSET = 6
	PARAM_FIRST_SPRITE_OFFSET = 7

	; Read parameters
	lda #8
	jsr inline_parameters
	lda tmpfield1
	sta params_ptr
	lda tmpfield2
	sta params_ptr+1

	; Compute new position
	ldy #PARAM_MOVING_OBJECT
	lda (params_ptr), y
	sta object_state
	iny
	lda (params_ptr), y
	sta object_state+1

	iny
	lda (params_ptr), y
	sta waypoints
	iny
	lda (params_ptr), y
	sta waypoints+1

	jsr moving_object_tick_tmpfields_params

	; Move the stage element to its new position
	ldy #PARAM_PLATFORM_OFFSET
	lda (params_ptr), y
	tax

	ldy #MOVING_OBJECT_X
	lda (object_state), y
	sec
	sbc #8 ; Adapt left value to engine quirks
	sta stage_data+STAGE_BUMPER_OFFSET_LEFT, x
	clc
	adc #16+8 ; right edge = left edge + object's width + 8 = A + 16 + 8
	sta stage_data+STAGE_BUMPER_OFFSET_RIGHT, x

	iny
	lda (object_state), y
	sec
	sbc #16+1 ; Adapt top value to engine's quirks
	sta stage_data+STAGE_BUMPER_OFFSET_TOP, x
	clc
	adc #16+16 ; bottom edge = top edge + object's height + 16 = A + 16 + 16
	sta stage_data+STAGE_BUMPER_OFFSET_BOTTOM, x

	; Place sprites
	ldy #MOVING_OBJECT_X ; Place object's position at a fixed memory address
	lda (object_state), y
	sta new_x
	iny
	lda (object_state), y
	sta new_y

	ldy #PARAM_METASPRITE ; metasprite = address of the metasprite
	lda (params_ptr), y
	sta metasprite
	iny
	lda (params_ptr), y
	sta metasprite+1

	lda metasprite ; metasprite_x = address of the X position table
	clc
	adc #1
	sta metasprite_x
	lda metasprite+1
	adc #0
	sta metasprite_x+1

	ldy #METASPRITE_LENGTH ; metasprite_y = address of the Y potision table = X position table + metasprite length
	lda (metasprite), y
	;clc ; useless, previous operation should not overflow
	adc metasprite_x
	sta metasprite_y
	lda #0
	adc metasprite_x+1
	sta metasprite_y+1

	ldy #PARAM_FIRST_SPRITE_OFFSET ; X = offset of the first sprite in OAM
	lda (params_ptr), y
	tax

	ldy #METASPRITE_LENGTH ; Y = index of metasprite's last sprite  = metasprite length - 1
	lda (metasprite), y
	tay
	dey

	place_one_sprite:
		lda new_x
		clc
		adc (metasprite_x), y
		sta oam_mirror+3, x

		lda new_y
		clc
		adc (metasprite_y), y
		sta oam_mirror+0, x

		inx
		inx
		inx
		inx
		dey
		bpl place_one_sprite

	rts
.)
#endif

stage_actor_target_mover_init:
.(
	object_state = tmpfield1
	;object_state_msb = tmpfield2
	waypoints = tmpfield3
	;waypoints_msb = tmpfield4
	params_ptr = tmpfield5
	;params_ptr = tmpfield6

	; Handle inline parameters
	lda #4
	jsr inline_parameters
	lda tmpfield1
	sta params_ptr
	lda tmpfield2
	sta params_ptr+1

	; Call moving_object_init with inlined parameters
	ldy #0
	lda (params_ptr), y
	sta object_state
	iny
	lda (params_ptr), y
	sta object_state+1

	iny
	lda (params_ptr), y
	sta waypoints
	iny
	lda (params_ptr), y
	sta waypoints+1

	jmp moving_object_init_tmpfields_params
	;rts ; useless, jump to subroutine
.)

stage_actor_target_mover:
.(
	object_state = tmpfield1
	;object_state_msb = tmpfield2
	waypoints = tmpfield3
	;waypoints_msb = tmpfield4
	params_ptr = tmpfield9
	;params_ptr = tmpfield10
	x_offset = tmpfield11
	y_offset = tmpfield12
	x_scale = tmpfield13
	y_scale = tmpfield14

	PARAM_TARGET_INDEX = 0
	PARAM_OBJECT_STATE = 1
	PARAM_WAYPOINTS = 3
	PARAM_X_OFFSET = 5
	PARAM_Y_OFFSET = 6
	PARAM_SCALE = 7

	; Handle inline parameters
	lda #8
	jsr inline_parameters
	lda tmpfield1
	sta params_ptr
	lda tmpfield2
	sta params_ptr+1

	; Check if target is still active
	ldy #PARAM_TARGET_INDEX
	lda (params_ptr), y
	tax

	lda arcade_mode_targets_y, x
	cmp #240
	bcs ok

		; Move target
		.(
			; Read inline parameters
			iny
			lda (params_ptr), y
			sta object_state
			iny
			lda (params_ptr), y
			sta object_state+1

			iny
			lda (params_ptr), y
			sta waypoints
			iny
			lda (params_ptr), y
			sta waypoints+1

			iny
			lda (params_ptr), y
			sta x_offset
			iny
			lda (params_ptr), y
			sta y_offset
			iny
			lda (params_ptr), y
			sta x_scale
			sta y_scale

			; Update moving object
			jsr moving_object_tick_tmpfields_params

			; Apply position scale and offset
			;ldx #MOVING_TARGET_INDEX ; useless, moving_object_tick does not modify X

			.(
				ldy #MOVING_OBJECT_X
				lda (object_state), y

				.(
					scale_loop:
						dec x_scale
						bmi scale_end
							lsr
						jmp scale_loop
					scale_end:
				.)

				clc
				adc x_offset

				sta arcade_mode_targets_x, x
			.)

			.(
				iny
				lda (object_state), y

				.(
					scale_loop:
						dec y_scale
						bmi scale_end
							lsr
						jmp scale_loop
					scale_end:
				.)

				clc
				adc y_offset

				sta arcade_mode_targets_y, x
			.)
		.)
	ok:

	rts
.)

;
; Stage-specific code
;

.(
cursor = stage_state_begin
&circle_target_x = cursor : -cursor += 1
&circle_target_y = cursor : -cursor += 1
&circle_target_current_waypoint = cursor : -cursor += 1

&top_target_x = cursor : -cursor += 1
&top_target_y = cursor : -cursor += 1
&top_target_current_waypoint = cursor : -cursor += 1

&bot_target_x = cursor : -cursor += 1
&bot_target_y = cursor : -cursor += 1
&bot_target_current_waypoint = cursor : -cursor += 1

#if cursor - stage_state_begin >= $10
#error arcade stage BTT02 uses to much memory
#endif
.)

+stage_arcade_btt02_init:
.(
	; Common stuff
	jsr stage_generic_init

	; Initialize moving targets
	jsr stage_actor_target_mover_init
	.word top_target_x, top_target_path

	jsr stage_actor_target_mover_init
	.word circle_target_x, circle_target_path

	jsr stage_actor_target_mover_init
	.word bot_target_x, bot_target_path

	rts
.)

+stage_arcade_btt02_tick:
.(
	; Tick moving targets
	TOP_TARGET_INDEX = 6
	jsr stage_actor_target_mover
	.byt TOP_TARGET_INDEX
	.word top_target_x, top_target_path
	.byt 48-4, 40-4
	.byt 1

	CIRCLE_TARGET_INDEX = 9
	jsr stage_actor_target_mover
	.byt CIRCLE_TARGET_INDEX
	.word circle_target_x, circle_target_path
	.byt 84-4, 52-4
	.byt 2

	BOT_TARGET_INDEX = 7
	jsr stage_actor_target_mover
	.byt BOT_TARGET_INDEX
	.word bot_target_x, bot_target_path
	.byt 149-4, 139-4
	.byt 2

	rts
.)

.)

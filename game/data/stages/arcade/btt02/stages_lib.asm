;
;TODO this is made to be generic, it could be placed in common libs (even in nine-gine actually)
;

;
; Waypoint-based moving object implementation
;

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


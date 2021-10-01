;
; States index
;

SINBAD_STATE_THROWN = PLAYER_STATE_THROWN
SINBAD_STATE_RESPAWN = PLAYER_STATE_RESPAWN
SINBAD_STATE_INNEXISTANT = PLAYER_STATE_INNEXISTANT
SINBAD_STATE_SPAWN = PLAYER_STATE_SPAWN
SINBAD_STATE_STANDING = PLAYER_STATE_STANDING
SINBAD_STATE_RUNNING = PLAYER_STATE_RUNNING
SINBAD_STATE_FALLING = CUSTOM_PLAYER_STATES_BEGIN + 0
SINBAD_STATE_JUMPING = CUSTOM_PLAYER_STATES_BEGIN + 1
SINBAD_STATE_JABBING = CUSTOM_PLAYER_STATES_BEGIN + 2
SINBAD_STATE_SIDE_TILT = CUSTOM_PLAYER_STATES_BEGIN + 3
SINBAD_STATE_SPECIAL_CHARGE = CUSTOM_PLAYER_STATES_BEGIN + 4
SINBAD_STATE_SPECIAL_STRIKE = CUSTOM_PLAYER_STATES_BEGIN + 5
SINBAD_STATE_SIDE_SPECIAL = CUSTOM_PLAYER_STATES_BEGIN + 6
SINBAD_STATE_HELPLESS = CUSTOM_PLAYER_STATES_BEGIN + 7
SINBAD_STATE_LANDING = CUSTOM_PLAYER_STATES_BEGIN + 8
SINBAD_STATE_CRASHING = CUSTOM_PLAYER_STATES_BEGIN + 9
SINBAD_STATE_DOWN_TILT = CUSTOM_PLAYER_STATES_BEGIN + 10
SINBAD_STATE_AERIAL_SIDE = CUSTOM_PLAYER_STATES_BEGIN + 11
SINBAD_STATE_AERIAL_DOWN = CUSTOM_PLAYER_STATES_BEGIN + 12
SINBAD_STATE_AERIAL_UP = CUSTOM_PLAYER_STATES_BEGIN + 13
SINBAD_STATE_AERIAL_NEUTRAL = CUSTOM_PLAYER_STATES_BEGIN + 14
SINBAD_STATE_AERIAL_SPE_NEUTRAL = CUSTOM_PLAYER_STATES_BEGIN + 15
SINBAD_STATE_SPE_UP = CUSTOM_PLAYER_STATES_BEGIN + 16
SINBAD_STATE_SPE_DOWN = CUSTOM_PLAYER_STATES_BEGIN + 17
SINBAD_STATE_UP_TILT = CUSTOM_PLAYER_STATES_BEGIN + 18
SINBAD_STATE_SHIELDING = CUSTOM_PLAYER_STATES_BEGIN + 19
SINBAD_STATE_SHIELDLAG = CUSTOM_PLAYER_STATES_BEGIN + 20
SINBAD_STATE_WALLJUMPING = CUSTOM_PLAYER_STATES_BEGIN + 21

;
; Gameplay constants
;

SINBAD_AERIAL_SPEED = $0100
SINBAD_AERIAL_DIRECTIONAL_INFLUENCE_STRENGTH = $80
SINBAD_AIR_FRICTION_STRENGTH = 7
SINBAD_FASTFALL_GRAVITY = $0500
SINBAD_GROUND_FRICTION_STRENGTH = $40
SINBAD_JUMP_POWER = $0480
SINBAD_JUMP_SHORT_HOP_POWER = $0102
SINBAD_JUMP_SHORT_HOP_EXTRA_TIME_PAL = 4 ; Number of frames after jumpsquat at which shorthop is handled
SINBAD_JUMP_SHORT_HOP_EXTRA_TIME_NTSC = 5
SINBAD_JUMP_SQUAT_DURATION_PAL = 4
SINBAD_JUMP_SQUAT_DURATION_NTSC = 5
SINBAD_LANDING_MAX_VELOCITY = $0200
SINBAD_MAX_AERIAL_JUMPS = 1
SINBAD_MAX_WALLJUMPS = 1
SINBAD_RUNNING_SPEED_MAX = $0200
SINBAD_RUNNING_SPEED_INIT = $0100
SINBAD_RUNNING_SPEED_ACCELERATION = $40
SINBAD_TECH_SPEED = $0400

;
; Constants data
;

velocity_table(SINBAD_AERIAL_SPEED, sinbad_aerial_speed_msb, sinbad_aerial_speed_lsb)
velocity_table(-SINBAD_AERIAL_SPEED, sinbad_aerial_neg_speed_msb, sinbad_aerial_neg_speed_lsb)
acceleration_table(SINBAD_AERIAL_DIRECTIONAL_INFLUENCE_STRENGTH, sinbad_aerial_directional_influence_strength)
acceleration_table(SINBAD_AIR_FRICTION_STRENGTH, sinbad_air_friction_strength)
velocity_table(SINBAD_FASTFALL_GRAVITY, sinbad_fastfall_gravity_msb, sinbad_fastfall_gravity_lsb)
acceleration_table(SINBAD_GROUND_FRICTION_STRENGTH, sinbad_ground_friction_strength)
acceleration_table(SINBAD_GROUND_FRICTION_STRENGTH/3, sinbad_ground_friction_strength_weak)
acceleration_table(SINBAD_GROUND_FRICTION_STRENGTH*3, sinbad_ground_friction_strength_strong)
velocity_table(SINBAD_TECH_SPEED, sinbad_tech_speed_msb, sinbad_tech_speed_lsb)
velocity_table(-SINBAD_TECH_SPEED, sinbad_tech_speed_neg_msb, sinbad_tech_speed_neg_lsb)
velocity_table(-SINBAD_JUMP_POWER, sinbad_jump_velocity_msb, sinbad_jump_velocity_lsb)
velocity_table(-SINBAD_JUMP_SHORT_HOP_POWER, sinbad_jump_short_hop_velocity_msb, sinbad_jump_short_hop_velocity_lsb)

sinbad_jumpsquat_duration:
	.byt SINBAD_JUMP_SQUAT_DURATION_PAL, SINBAD_JUMP_SQUAT_DURATION_NTSC

sinbad_short_hop_time:
	.byt SINBAD_JUMP_SQUAT_DURATION_PAL + SINBAD_JUMP_SHORT_HOP_EXTRA_TIME_PAL, SINBAD_JUMP_SQUAT_DURATION_NTSC + SINBAD_JUMP_SHORT_HOP_EXTRA_TIME_NTSC

;
; Implementation
;

sinbad_init:
sinbad_global_onground:
.(
	; Initialize walljump counter
	lda #SINBAD_MAX_WALLJUMPS
	sta player_a_walljump, x
	rts
.)

sinbad_apply_air_friction:
.(
	; merge_to_player_velocity parameter names
	merged_v_low = tmpfield1
	merged_v_high = tmpfield3
	merged_h_low = tmpfield2
	merged_h_high = tmpfield4
	merge_step = tmpfield5

	; Apply air friction
	lda player_a_velocity_v_low, x
	sta merged_v_low
	lda player_a_velocity_v, x
	sta merged_v_high
	lda #$00
	sta merged_h_low
	sta merged_h_high
	ldy system_index
	lda sinbad_air_friction_strength, y
	sta merge_step
	jmp merge_to_player_velocity
	;rts ; useless, jump to a subroutine
.)

sinbad_apply_ground_friction:
.(
	; merge_to_player_velocity parameter names
	merged_v_low = tmpfield1
	merged_v_high = tmpfield3
	merged_h_low = tmpfield2
	merged_h_high = tmpfield4
	merge_step = tmpfield5

	; Apply ground friction
	lda #$00
	sta merged_h_high
	sta merged_v_high
	sta merged_h_low
	sta merged_v_low
	ldy system_index
	lda sinbad_ground_friction_strength, y
	sta tmpfield5
	jmp merge_to_player_velocity
	;rts ; useless, jump to subroutine
.)

; Change the player's state if an aerial move is input on the controller
;  register X - Player number
;
;  Overwrites tmpfield15 and tmpfield2 plus the ones overriten by the state starting subroutine
sinbad_check_aerial_inputs:
.(
	input_marker = tmpfield15
	player_btn = tmpfield2

	.(
		; Refuse to do anything if under hitstun
		lda player_a_hitstun, x
		bne end

		; Assuming we are called from an input event
		; Do nothing if the only changes concern the left-right buttons
		lda controller_a_btns, x
		eor controller_a_last_frame_btns, x
		and #CONTROLLER_BTN_A | CONTROLLER_BTN_B | CONTROLLER_BTN_UP | CONTROLLER_BTN_DOWN
		beq end

			; Save current direction
			lda player_a_direction, x
			pha

			; Change player's direction according to input direction
			lda controller_a_btns, x
			sta player_btn
			lda #CONTROLLER_BTN_LEFT
			bit player_btn
			beq check_direction_right
				lda DIRECTION_LEFT
				jmp set_direction
			check_direction_right:
				lda #CONTROLLER_BTN_RIGHT
				bit player_btn
				beq no_direction
				lda DIRECTION_RIGHT
			set_direction:
				sta player_a_direction, x
			no_direction:

			; Start the good state according to input
			jsr take_input

			; Restore player's direction if there was no input, else discard saved direction
			lda input_marker
			beq restore_direction
				pla
				jmp end
			restore_direction:
				pla
				sta player_a_direction, x

		end:
		rts
	.)

	take_input:
	.(
		; Mark input
		lda #01
		sta input_marker

		; Call aerial subroutines, in case of input it will return with input marked
		lda #<controller_inputs
		sta tmpfield1
		lda #>controller_inputs
		sta tmpfield2
		lda #NUM_AERIAL_INPUTS
		sta tmpfield3
		jmp controller_callbacks
		;rts ; useless, jump to subroutine

		; Fast fall on release of CONTROLLER_INPUT_TECH, gravity * 1.5
		fast_fall:
		.(
			lda controller_a_last_frame_btns, x
			cmp #CONTROLLER_INPUT_TECH
			bne no_fast_fall
				; Set fast fall gravity and velocity
				ldy system_index
				lda sinbad_fastfall_gravity_msb, y
				sta player_a_gravity_msb, x
				sta player_a_velocity_v, x
				lda sinbad_fastfall_gravity_lsb, y
				sta player_a_gravity_lsb, x
				sta player_a_velocity_v_low, x

				; Play SFX
				txa
				pha
				jsr audio_play_fast_fall
				pla
				tax
			no_fast_fall:
			rts
		.)

		; Jump, choose between aerial jump or wall jump
		jump:
		.(
			lda player_a_walled, x
			beq aerial_jump
			lda player_a_walljump, x
			beq aerial_jump
				wall_jump:
					lda player_a_walled_direction, x
					sta player_a_direction, x
					jmp sinbad_start_walljumping
				aerial_jump:
					jmp sinbad_start_aerial_jumping
			;rts ; useless, both branches jump to subroutine
		.)

		; If no input, unmark the input flag and return
		no_input:
		.(
			lda #$00
			sta input_marker
			rts
		.)

		; Impactful controller states and associated callbacks
		controller_inputs:
		.byt CONTROLLER_INPUT_NONE,               CONTROLLER_INPUT_SPECIAL_RIGHT
		.byt CONTROLLER_INPUT_SPECIAL_LEFT,       CONTROLLER_INPUT_JUMP
		.byt CONTROLLER_INPUT_JUMP_RIGHT,         CONTROLLER_INPUT_JUMP_LEFT
		.byt CONTROLLER_INPUT_ATTACK_LEFT,        CONTROLLER_INPUT_ATTACK_RIGHT
		.byt CONTROLLER_INPUT_DOWN_TILT,          CONTROLLER_INPUT_ATTACK_UP
		.byt CONTROLLER_INPUT_JAB,                CONTROLLER_INPUT_SPECIAL
		.byt CONTROLLER_INPUT_SPECIAL_UP,         CONTROLLER_INPUT_SPECIAL_DOWN
		.byt CONTROLLER_INPUT_ATTACK_UP_RIGHT,    CONTROLLER_INPUT_ATTACK_UP_LEFT
		.byt CONTROLLER_INPUT_SPECIAL_UP_RIGHT,   CONTROLLER_INPUT_SPECIAL_UP_LEFT
		.byt CONTROLLER_INPUT_ATTACK_DOWN_RIGHT,  CONTROLLER_INPUT_ATTACK_DOWN_LEFT
		.byt CONTROLLER_INPUT_SPECIAL_DOWN_RIGHT, CONTROLLER_INPUT_SPECIAL_DOWN_LEFT
		controller_callbacks_lo:
		.byt <fast_fall,                   <sinbad_start_side_special
		.byt <sinbad_start_side_special,   <jump
		.byt <jump,                        <jump
		.byt <sinbad_start_aerial_side,    <sinbad_start_aerial_side
		.byt <sinbad_start_aerial_down,    <sinbad_start_aerial_up
		.byt <sinbad_start_aerial_neutral, <sinbad_start_aerial_spe
		.byt <sinbad_start_spe_up,         <sinbad_start_spe_down
		.byt <sinbad_start_aerial_up,      <sinbad_start_aerial_up
		.byt <sinbad_start_spe_up,         <sinbad_start_spe_up
		.byt <sinbad_start_aerial_down,    <sinbad_start_aerial_down
		.byt <sinbad_start_spe_down,       <sinbad_start_spe_down
		controller_callbacks_hi:
		.byt >fast_fall,                   >sinbad_start_side_special
		.byt >sinbad_start_side_special,   >jump
		.byt >jump,                        >jump
		.byt >sinbad_start_aerial_side,    >sinbad_start_aerial_side
		.byt >sinbad_start_aerial_down,    >sinbad_start_aerial_up
		.byt >sinbad_start_aerial_neutral, >sinbad_start_aerial_spe
		.byt >sinbad_start_spe_up,         >sinbad_start_spe_down
		.byt >sinbad_start_aerial_up,      >sinbad_start_aerial_up
		.byt >sinbad_start_spe_up,         >sinbad_start_spe_up
		.byt >sinbad_start_aerial_down,    >sinbad_start_aerial_down
		.byt >sinbad_start_spe_down,       >sinbad_start_spe_down
		controller_default_callback:
		.word no_input
		NUM_AERIAL_INPUTS = controller_callbacks_lo - controller_inputs
	.)
.)

sinbad_aerial_directional_influence:
.(
	; merge_to_player_velocity parameter names
	merged_v_low = tmpfield1
	merged_v_high = tmpfield3
	merged_h_low = tmpfield2
	merged_h_high = tmpfield4
	merge_step = tmpfield5

	; Choose what to do depending on controller state
	lda controller_a_btns, x
	and #CONTROLLER_INPUT_LEFT
	bne go_left

	lda controller_a_btns, x
	and #CONTROLLER_INPUT_RIGHT
	bne go_right

	air_friction:
		jmp sinbad_apply_air_friction
		; No return, jump to a subroutine

	go_left:
		; Go to the left
		ldy system_index

		lda sinbad_aerial_neg_speed_lsb, y
		sta tmpfield6
		lda sinbad_aerial_neg_speed_msb, y
		sta tmpfield7
		lda player_a_velocity_h_low, x
		sta tmpfield8
		lda player_a_velocity_h, x
		sta tmpfield9
		jsr signed_cmp
		bpl end

			lda player_a_velocity_v_low, x
			sta merged_v_low
			lda player_a_velocity_v, x
			sta merged_v_high
			lda sinbad_aerial_neg_speed_lsb, y
			sta merged_h_low
			lda sinbad_aerial_neg_speed_msb, y
			sta merged_h_high
			lda sinbad_aerial_directional_influence_strength, y
			sta merge_step
			jmp merge_to_player_velocity
			; No return, jump to a subroutine

	go_right:
		; Go to the right
		ldy system_index

		lda player_a_velocity_h_low, x
		sta tmpfield6
		lda player_a_velocity_h, x
		sta tmpfield7
		lda sinbad_aerial_speed_lsb, y
		sta tmpfield8
		lda sinbad_aerial_speed_msb, y
		sta tmpfield9
		jsr signed_cmp
		bpl end

			lda player_a_velocity_v_low, x
			sta merged_v_low
			lda player_a_velocity_v, x
			sta merged_v_high
			lda sinbad_aerial_speed_lsb, y
			sta merged_h_low
			lda sinbad_aerial_speed_msb, y
			sta merged_h_high
			lda sinbad_aerial_directional_influence_strength, y
			sta merge_step
			jmp merge_to_player_velocity
			; No return, jump to a subroutine

	end:
	rts
.)

; Choose between falling or idle depending if grounded
sinbad_start_inactive_state:
.(
    lda player_a_grounded, x
    bne stand

    fall:
        jmp sinbad_start_falling
        ; No return, jump to subroutine

    stand:
    ; Fallthrough to sinbad_start_standing
.)

;
; Standing
;

.(
	&sinbad_start_standing:
	.(
		; Set the appropriate animation
		lda #<sinbad_anim_idle
		sta tmpfield13
		lda #>sinbad_anim_idle
		sta tmpfield14
		jsr set_player_animation

		; Set the player's state
		lda #SINBAD_STATE_STANDING
		sta player_a_state, x
		rts
	.)

	; Update a player that is standing on ground
	;  register X must contain the player number
	&sinbad_tick_standing:
	.(
		; Do not move, velocity tends toward vector (0,0)
		lda #$00
		sta tmpfield4
		sta tmpfield3
		sta tmpfield2
		sta tmpfield1
		lda #$ff
		sta tmpfield5
		jsr merge_to_player_velocity

		; Force the handling of directional controls
		lda controller_a_btns, x
		cmp #CONTROLLER_INPUT_LEFT
		bne no_left
			jsr sinbad_input_standing_left
			jmp end
		no_left:
			cmp #CONTROLLER_INPUT_RIGHT
			bne end
			jsr sinbad_input_standing_right

		end:
		rts
	.)

	; Player is now running left
	sinbad_input_standing_left:
	.(
		lda DIRECTION_LEFT
		sta player_a_direction, x
		jsr sinbad_start_running
		rts
	.)

	; Player is now running right
	sinbad_input_standing_right:
	.(
		lda DIRECTION_RIGHT
		sta player_a_direction, x
		jsr sinbad_start_running
		rts
	.)

	&sinbad_input_standing:
	.(
		; Do not handle any input if under hitstun
		lda player_a_hitstun, x
		bne end

		; Check state changes
		lda #<input_table
		sta tmpfield1
		lda #>input_table
		sta tmpfield2
		lda #INPUT_TABLE_LENGTH
		sta tmpfield3
		jmp controller_callbacks

		; Player is now jumping
		jump_input_left:
			lda DIRECTION_LEFT
			sta player_a_direction, x
			jmp jump_input
			jump_input_right:
			lda DIRECTION_RIGHT
			sta player_a_direction, x
			jump_input:
			jsr sinbad_start_jumping
			jmp end

		; Player is now tilting
		tilt_input_left:
			lda DIRECTION_LEFT
			sta player_a_direction, x
			jmp tilt_input
			tilt_input_right:
			lda DIRECTION_RIGHT
			sta player_a_direction, x
			tilt_input:
			jsr sinbad_start_side_tilt
			jmp end

		; Player is now side specialing
		side_special_input_left:
			lda DIRECTION_LEFT
			sta player_a_direction, x
			jmp side_special_input
			side_special_input_right:
			lda DIRECTION_RIGHT
			sta player_a_direction, x
			side_special_input:
			jsr sinbad_start_side_special
			jmp end

		end:
		rts

		input_table:
		.(
			controller_inputs:
			.byt CONTROLLER_INPUT_LEFT,              CONTROLLER_INPUT_RIGHT
			.byt CONTROLLER_INPUT_JUMP,              CONTROLLER_INPUT_JUMP_RIGHT
			.byt CONTROLLER_INPUT_JUMP_LEFT,         CONTROLLER_INPUT_JAB
			.byt CONTROLLER_INPUT_ATTACK_LEFT,       CONTROLLER_INPUT_ATTACK_RIGHT
			.byt CONTROLLER_INPUT_SPECIAL,           CONTROLLER_INPUT_SPECIAL_RIGHT
			.byt CONTROLLER_INPUT_SPECIAL_LEFT,      CONTROLLER_INPUT_DOWN_TILT
			.byt CONTROLLER_INPUT_SPECIAL_UP,        CONTROLLER_INPUT_SPECIAL_DOWN
			.byt CONTROLLER_INPUT_ATTACK_UP,         CONTROLLER_INPUT_TECH
			.byt CONTROLLER_INPUT_TECH_LEFT,         CONTROLLER_INPUT_TECH_RIGHT
			.byt CONTROLLER_INPUT_SPECIAL_UP_LEFT,   CONTROLLER_INPUT_SPECIAL_UP_RIGHT
			.byt CONTROLLER_INPUT_ATTACK_UP_LEFT,    CONTROLLER_INPUT_ATTACK_UP_RIGHT
			.byt CONTROLLER_INPUT_SPECIAL_DOWN_LEFT, CONTROLLER_INPUT_SPECIAL_DOWN_RIGHT
			.byt CONTROLLER_INPUT_ATTACK_DOWN_LEFT,  CONTROLLER_INPUT_ATTACK_DOWN_RIGHT
			controller_callbacks_lo:
			.byt <sinbad_input_standing_left, <sinbad_input_standing_right
			.byt <jump_input,                 <jump_input_right
			.byt <jump_input_left,            <sinbad_start_jabbing
			.byt <tilt_input_left,            <tilt_input_right
			.byt <sinbad_start_special,       <side_special_input_right
			.byt <side_special_input_left,    <sinbad_start_down_tilt
			.byt <sinbad_start_spe_up,        <sinbad_start_spe_down
			.byt <sinbad_start_up_tilt,       <sinbad_start_shielding
			.byt <sinbad_start_shielding,     <sinbad_start_shielding
			.byt <sinbad_start_spe_up,        <sinbad_start_spe_up
			.byt <sinbad_start_up_tilt,       <sinbad_start_up_tilt
			.byt <sinbad_start_spe_down,      <sinbad_start_spe_down
			.byt <sinbad_start_down_tilt,     <sinbad_start_down_tilt
			controller_callbacks_hi:
			.byt >sinbad_input_standing_left, >sinbad_input_standing_right
			.byt >jump_input,                 >jump_input_right
			.byt >jump_input_left,            >sinbad_start_jabbing
			.byt >tilt_input_left,            >tilt_input_right
			.byt >sinbad_start_special,       >side_special_input_right
			.byt >side_special_input_left,    >sinbad_start_down_tilt
			.byt >sinbad_start_spe_up,        >sinbad_start_spe_down
			.byt >sinbad_start_up_tilt,       >sinbad_start_shielding
			.byt >sinbad_start_shielding,     >sinbad_start_shielding
			.byt >sinbad_start_spe_up,        >sinbad_start_spe_up
			.byt >sinbad_start_up_tilt,       >sinbad_start_up_tilt
			.byt >sinbad_start_spe_down,      >sinbad_start_spe_down
			.byt >sinbad_start_down_tilt,     >sinbad_start_down_tilt
			controller_default_callback:
			.word end
			&INPUT_TABLE_LENGTH = controller_callbacks_lo - controller_inputs
		.)
	.)
.)

;
; Running
;

.(
	velocity_table(SINBAD_RUNNING_SPEED_INIT, run_init_velocity_msb, run_init_velocity_lsb)
	velocity_table(-SINBAD_RUNNING_SPEED_INIT, run_init_neg_velocity_msb, run_init_neg_velocity_lsb)

	velocity_table(SINBAD_RUNNING_SPEED_MAX, run_max_velocity_msb, run_max_velocity_lsb)
	velocity_table(-SINBAD_RUNNING_SPEED_MAX, run_max_neg_velocity_msb, run_max_neg_velocity_lsb)

	acceleration_table(SINBAD_RUNNING_SPEED_ACCELERATION, run_acceleration)

	&sinbad_start_running:
	.(
		lda #SINBAD_STATE_RUNNING
		sta player_a_state, x
		; Fallthrough
	.)
	set_running_animation:
	.(
		; Set the appropriate animation
		lda #<sinbad_anim_run
		sta tmpfield13
		lda #>sinbad_anim_run
		sta tmpfield14
		jsr set_player_animation

		; Set initial velocity
		ldy system_index
		lda player_a_direction, x
		cmp DIRECTION_LEFT
		bne direction_right
			direction_left:
				lda run_init_neg_velocity_lsb, y
				sta player_a_velocity_h_low, x
				lda run_init_neg_velocity_msb, y
				jmp set_high_byte
			direction_right:
				lda run_init_velocity_lsb, y
				sta player_a_velocity_h_low, x
				lda run_init_velocity_msb, y
		set_high_byte:
		sta player_a_velocity_h, x

		rts
	.)

	; Update a player that is running
	;  register X must contain the player number
	&sinbad_tick_running:
	.(
		merge_velocity_y_lsb = tmpfield1
		merge_velocity_x_lsb = tmpfield2
		merge_velocity_y_msb = tmpfield3
		merge_velocity_x_msb = tmpfield4
		merge_velocity_step = tmpfield5

		; Move the player to the direction he is watching
		ldy system_index
		lda player_a_direction, x
		beq run_left

			; Running right, velocity tends toward vector (2,0)
			lda run_max_velocity_msb, y
			sta merge_velocity_x_msb
			lda run_max_velocity_lsb, y
			sta merge_velocity_x_lsb
			lda #0
			sta merge_velocity_y_msb
			sta merge_velocity_y_lsb
			lda run_acceleration, y
			sta merge_velocity_step
			jmp merge_to_player_velocity
			; No return, jump to subroutine

		; Running left, velocity tends toward vector (-2,0)
		run_left:
			lda run_max_neg_velocity_msb, y
			sta merge_velocity_x_msb
			lda run_max_neg_velocity_lsb, y
			sta merge_velocity_x_lsb
			lda #0
			sta merge_velocity_y_msb
			sta merge_velocity_y_lsb
			lda run_acceleration, y
			sta merge_velocity_step
			jmp merge_to_player_velocity
			; No return, jump to subroutine

		;rts ; Useless, no branch return
	.)

	&sinbad_input_running:
	.(
		; If in hitstun, stop running
		lda player_a_hitstun, x
		beq take_input
			jmp sinbad_start_standing
			; No return, jump to subroutine

		take_input:

			lda #<controller_inputs
			sta tmpfield1
			lda #>controller_inputs
			sta tmpfield2
			lda #INPUT_TABLE_LENGTH
			sta tmpfield3
			jmp controller_callbacks

			; Player is now watching left
			input_left:
				lda DIRECTION_LEFT
				cmp player_a_direction, x
				beq end
					sta player_a_direction, x
					jsr set_running_animation
					jmp end

			; Player is now watching right
			input_right:
				lda DIRECTION_RIGHT
				cmp player_a_direction, x
				beq end
					sta player_a_direction, x
					jsr set_running_animation
					jmp end

			; Player is now tilting
			tilt_input_left:
				lda DIRECTION_LEFT
				sta player_a_direction, x
				jmp tilt_input
			tilt_input_right:
				lda DIRECTION_RIGHT
				sta player_a_direction, x
			tilt_input:
				jsr sinbad_start_side_tilt
				jmp end

		end:
		rts

		; Impactful controller states and associated callbacks
		; Note - We can put subroutines as callbacks because we have nothing to do after calling it
		;        (sourboutines return to our caller since "called" with jmp)
		controller_inputs:
		.byt CONTROLLER_INPUT_LEFT,              CONTROLLER_INPUT_RIGHT
		.byt CONTROLLER_INPUT_JUMP,              CONTROLLER_INPUT_JUMP_RIGHT
		.byt CONTROLLER_INPUT_JUMP_LEFT,         CONTROLLER_INPUT_ATTACK_LEFT
		.byt CONTROLLER_INPUT_ATTACK_RIGHT,      CONTROLLER_INPUT_SPECIAL
		.byt CONTROLLER_INPUT_SPECIAL_RIGHT,     CONTROLLER_INPUT_SPECIAL_LEFT
		.byt CONTROLLER_INPUT_SPECIAL_UP,        CONTROLLER_INPUT_SPECIAL_DOWN
		.byt CONTROLLER_INPUT_TECH_LEFT,         CONTROLLER_INPUT_TECH_RIGHT
		.byt CONTROLLER_INPUT_SPECIAL_UP_LEFT,   CONTROLLER_INPUT_SPECIAL_UP_RIGHT
		.byt CONTROLLER_INPUT_ATTACK_UP_LEFT,    CONTROLLER_INPUT_ATTACK_UP_RIGHT
		.byt CONTROLLER_INPUT_SPECIAL_DOWN_LEFT, CONTROLLER_INPUT_SPECIAL_DOWN_RIGHT
		.byt CONTROLLER_INPUT_ATTACK_DOWN_LEFT,  CONTROLLER_INPUT_ATTACK_DOWN_RIGHT
		.byt CONTROLLER_INPUT_DOWN_TILT
		controller_callbacks_lo:
		.byt <input_left,                <input_right
		.byt <sinbad_start_jumping,      <sinbad_start_jumping
		.byt <sinbad_start_jumping,      <tilt_input_left
		.byt <tilt_input_right,          <sinbad_start_special
		.byt <sinbad_start_side_special, <sinbad_start_side_special
		.byt <sinbad_start_spe_up,       <sinbad_start_spe_down
		.byt <sinbad_start_shielding,    <sinbad_start_shielding
		.byt <sinbad_start_spe_up,       <sinbad_start_spe_up
		.byt <sinbad_start_up_tilt,      <sinbad_start_up_tilt
		.byt <sinbad_start_spe_down,     <sinbad_start_spe_down
		.byt <sinbad_start_down_tilt,    <sinbad_start_down_tilt
		.byt <sinbad_start_down_tilt
		controller_callbacks_hi:
		.byt >input_left,                >input_right
		.byt >sinbad_start_jumping,      >sinbad_start_jumping
		.byt >sinbad_start_jumping,      >tilt_input_left
		.byt >tilt_input_right,          >sinbad_start_special
		.byt >sinbad_start_side_special, >sinbad_start_side_special
		.byt >sinbad_start_spe_up,       >sinbad_start_spe_down
		.byt >sinbad_start_shielding,    >sinbad_start_shielding
		.byt >sinbad_start_spe_up,       >sinbad_start_spe_up
		.byt >sinbad_start_up_tilt,      >sinbad_start_up_tilt
		.byt >sinbad_start_spe_down,     >sinbad_start_spe_down
		.byt >sinbad_start_down_tilt,    >sinbad_start_down_tilt
		.byt >sinbad_start_down_tilt
		controller_default_callback:
		.word sinbad_start_standing
		INPUT_TABLE_LENGTH = controller_callbacks_lo - controller_inputs
	.)
.)

;
; Falling
;

.(
	&sinbad_start_falling:
	.(
		lda #SINBAD_STATE_FALLING
		sta player_a_state, x

		; Fallthrough to set the animation
	.)
	set_falling_animation:
	.(
		; Set the appropriate animation
		lda #<sinbad_anim_falling
		sta tmpfield13
		lda #>sinbad_anim_falling
		sta tmpfield14
		jmp set_player_animation

		;rts ; useless, jump to subroutine
	.)

	; Update a player that is falling
	;  register X must contain the player number
	&sinbad_tick_falling:
	.(
		jsr sinbad_aerial_directional_influence
		jmp apply_player_gravity
		;rts ; useless, jump to subroutine
	.)
.)

;
; Jumping
;

.(
	&sinbad_start_jumping:
	.(
		lda #SINBAD_STATE_JUMPING
		sta player_a_state, x

		lda #0
		sta player_a_state_clock, x

		jsr audio_play_jump

		; Fallthrough to set the animation
		; Set the appropriate animation
		lda #<sinbad_anim_jumping
		sta tmpfield13
		lda #>sinbad_anim_jumping
		sta tmpfield14
		jmp set_player_animation

		;rts ; useless, jump to subroutine
	.)

	&sinbad_tick_jumping:
	.(
		; Tick clock
		inc player_a_state_clock, x

		; Wait for the preparation to end to begin to jump
		ldy system_index
		lda player_a_state_clock, x
		cmp sinbad_jumpsquat_duration, y
		bcc end
		beq begin_to_jump

		; Check if the top of the jump is reached
		lda player_a_velocity_v, x
		beq top_reached
		bpl top_reached

			; The top is not reached, stay in jumping state but apply gravity and directional influence
			jsr sinbad_tick_falling ; Hack - We just use sinbad_tick_falling which does exactly what we want

			; Check if it is time to stop a short-hop
			ldy system_index
			lda sinbad_short_hop_time, y
			cmp player_a_state_clock, x
			beq stop_short_hop
			rts

		; The top is reached, return to falling
		top_reached:
			jmp sinbad_start_falling
			; No return, jump to subroutine

		; If the jump button is no more pressed mid jump, convert the jump to a short-hop
		stop_short_hop:
			; If the jump button is still pressed, this is not a short-hop
			lda controller_a_btns, x
			and #CONTROLLER_INPUT_JUMP
			bne end

				; Reduce upward momentum to end the jump earlier
				ldy system_index
				lda sinbad_jump_short_hop_velocity_msb, y
				sta player_a_velocity_v, x
				lda sinbad_jump_short_hop_velocity_lsb, y
				sta player_a_velocity_v_low, x

				rts

		; Put initial jumping velocity
		begin_to_jump:
			ldy system_index
			lda sinbad_jump_velocity_msb, y
			sta player_a_velocity_v, x
			lda sinbad_jump_velocity_lsb, y
			sta player_a_velocity_v_low, x
			;jmp end ; Fallthrough

		end:
		rts
	.)

	&sinbad_input_jumping:
	.(
		; The jump is cancellable by grounded movements during preparation
		; and by aerial movements after that
		lda player_a_num_aerial_jumps, x ; performing aerial jump, not
		bne not_grounded                 ; grounded

		ldy system_index                ;
		lda player_a_state_clock, x      ; Still preparing the jump
		cmp sinbad_jumpsquat_duration, y ;
		bcc grounded                     ;

		not_grounded:
			jsr sinbad_check_aerial_inputs
			jmp end

		grounded:
			lda #<controller_inputs
			sta tmpfield1
			lda #>controller_inputs
			sta tmpfield2
			lda #INPUT_TABLE_LENGTH
			sta tmpfield3
			jmp controller_callbacks

		end:
		rts

		; Impactful controller states and associated callbacks (when still grounded)
		; Note - We can put subroutines as callbacks because we have nothing to do after calling it
		;        (sourboutines return to our caller since "called" with jmp)
		controller_inputs:
		.byt CONTROLLER_INPUT_ATTACK_UP,       CONTROLLER_INPUT_SPECIAL_UP
		.byt CONTROLLER_INPUT_ATTACK_UP_LEFT,  CONTROLLER_INPUT_SPECIAL_UP_LEFT
		.byt CONTROLLER_INPUT_ATTACK_UP_RIGHT, CONTROLLER_INPUT_SPECIAL_UP_RIGHT
		controller_callbacks_lo:
		.byt <sinbad_start_up_tilt, <sinbad_start_spe_up
		.byt <sinbad_start_up_tilt, <sinbad_start_spe_up
		.byt <sinbad_start_up_tilt, <sinbad_start_spe_up
		controller_callbacks_hi:
		.byt >sinbad_start_up_tilt, >sinbad_start_spe_up
		.byt >sinbad_start_up_tilt, >sinbad_start_spe_up
		.byt >sinbad_start_up_tilt, >sinbad_start_spe_up
		controller_default_callback:
		.word end
		INPUT_TABLE_LENGTH = controller_callbacks_lo - controller_inputs
	.)
.)

;
; Aerial jumping
;

.(
	&sinbad_start_aerial_jumping:
	.(
		; Deny to start jump state if the player used all it's jumps
		lda #SINBAD_MAX_AERIAL_JUMPS
		cmp player_a_num_aerial_jumps, x
		bne jump_ok
			rts
		jump_ok:
		inc player_a_num_aerial_jumps, x

		; Reset fall speed
		jsr reset_default_gravity

		; Trick - aerial_jumping set the state to jumping. It is the same state with
		; the starting conditions as the only differences
		lda #SINBAD_STATE_JUMPING
		sta player_a_state, x

		; Reset clock
		lda #0
		sta player_a_state_clock, x

		lda #$00
		sta player_a_velocity_v, x
		sta player_a_velocity_v_low, x

		; Play SFX
		jsr audio_play_aerial_jump

		; Set the appropriate animation
		lda #<sinbad_anim_aerial_jumping
		sta tmpfield13
		lda #>sinbad_anim_aerial_jumping
		sta tmpfield14
		jmp set_player_animation

		;rts ; useless, jump to subroutine
	.)
.)

;
; Jab
;

.(
	jab_duration:
		.byt sinbad_anim_jab_dur_pal, sinbad_anim_jab_dur_ntsc

	&sinbad_start_jabbing:
	.(
		lda #SINBAD_STATE_JABBING
		sta player_a_state, x
		lda #0
		sta player_a_state_clock, x
		; Fallthrough
	.)
	set_jabbing_animation:
	.(
		; Set the appropriate animation
		lda #<sinbad_anim_jab
		sta tmpfield13
		lda #>sinbad_anim_jab
		sta tmpfield14
		jmp set_player_animation

		;rts ; useless, jump to subroutine
	.)

	&sinbad_tick_jabbing:
	.(
		; Tick clock
		inc player_a_state_clock, x

		; Do not move, velocity tends toward vector (0,0)
		lda #$00
		sta tmpfield4
		sta tmpfield3
		sta tmpfield2
		sta tmpfield1
		lda #$ff
		sta tmpfield5
		jsr merge_to_player_velocity

		; At the end of the move, return to standing state
		ldy system_index
		lda player_a_state_clock, x
		cmp jab_duration, y
		bne end
			jmp sinbad_start_inactive_state
			; No return, jump to subroutine

		end:
		rts
	.)

	&sinbad_input_jabbing:
	.(
		; Allow to cut the animation for another jab
		lda controller_a_btns, x
		cmp #CONTROLLER_INPUT_JAB
		bne end
			jmp sinbad_start_jabbing
			; No return, jump to subroutine
		end:
		rts
	.)
.)

;
; Thrown
;

!include "std_thrown.asm"

;
; Respawn
;

.(
	&sinbad_start_respawn:
	.(
		; Set the player's state
		lda #SINBAD_STATE_RESPAWN
		sta player_a_state, x

		; Place player to the respawn spot
		lda stage_data+STAGE_HEADER_OFFSET_RESPAWNX_HIGH
		sta player_a_x, x
		lda stage_data+STAGE_HEADER_OFFSET_RESPAWNX_LOW
		sta player_a_x_low, x
		lda stage_data+STAGE_HEADER_OFFSET_RESPAWNY_HIGH
		sta player_a_y, x
		lda stage_data+STAGE_HEADER_OFFSET_RESPAWNY_LOW
		sta player_a_y_low, x
		lda #$00
		sta player_a_x_screen, x
		sta player_a_y_screen, x
		sta player_a_velocity_h, x
		sta player_a_velocity_h_low, x
		sta player_a_velocity_v, x
		sta player_a_velocity_v_low, x
		sta player_a_damages, x

		; Initialize state's timer
		ldy system_index
		lda player_respawn_max_duration, y
		sta player_a_state_field1, x

		; Reinitialize walljump counter
		lda #SINBAD_MAX_WALLJUMPS
		sta player_a_walljump, x

		; Set the appropriate animation
		lda #<sinbad_anim_respawn
		sta tmpfield13
		lda #>sinbad_anim_respawn
		sta tmpfield14
		jmp set_player_animation

		;rts ; useless, jump to subroutine
	.)

	&sinbad_tick_respawn:
	.(
		; Check for timeout
		dec player_a_state_field1, x
		bne end
			jmp sinbad_start_falling
			; No return, jump to subroutine

		end:
		rts
	.)

	&sinbad_input_respawn:
	.(
		; Avoid doing anything until controller has returned to neutral since after
		; death the player can release buttons without expecting to take action
		lda controller_a_last_frame_btns, x
		bne end

		; Call sinbad_check_aerial_inputs
		;  If it does not change the player state, go to falling state
		;  so that any button press makes the player falls from revival
		;  platform
		jsr sinbad_check_aerial_inputs
		lda player_a_state, x
		cmp #SINBAD_STATE_RESPAWN
		bne end
			jmp sinbad_start_falling
			; No return, jump to subroutine

		end:
		rts
	.)
.)

;
; Side tilt
;

.(
	side_tilt_duration:
		.byt sinbad_anim_side_tilt_dur_pal, sinbad_anim_side_tilt_dur_ntsc

	; Not per-system constant
	;  The static decay ensures the same distance is traveled
	;  The difference in travel speed is barely noticeable (when focusing on it)
	;  Seriously, this animation is ugly and should be rework anyway
	VELOCITY_H = $0480
	VELOCITY_V = $fd80
	VELOCITY_DECAY = $80

	&sinbad_start_side_tilt:
	.(
		; Set the appropriate animation
		lda #<sinbad_anim_side_tilt
		sta tmpfield13
		lda #>sinbad_anim_side_tilt
		sta tmpfield14
		jsr set_player_animation

		; Set the player's state
		lda #SINBAD_STATE_SIDE_TILT
		sta player_a_state, x

		; Initialize the clock
		ldy system_index
		lda side_tilt_duration, y
		sta player_a_state_clock,x

		; Set initial velocity
		lda #>VELOCITY_V
		sta player_a_velocity_v, x
		lda #<VELOCITY_V
		sta player_a_velocity_v_low, x

		lda player_a_direction, x
		beq set_velocity_left
			set_velocity_right:
				lda #>VELOCITY_H
				sta player_a_velocity_h, x
				jmp end_set_velocity
			set_velocity_left:
				lda #>-VELOCITY_H
				sta player_a_velocity_h, x
		end_set_velocity:
		lda #<VELOCITY_H ;NOTE this is the same as "<-VELOCITY_H" ($80)
		sta player_a_velocity_h_low, x

		rts
	.)

	; Update a player that is performing a side tilt
	;  register X must contain the player number
	&sinbad_tick_side_tilt:
	.(
		dec player_a_state_clock, x
		bne update_velocity
			jmp sinbad_start_inactive_state
			; No return, jump to a subroutine

		update_velocity:
			lda #$01
			sta tmpfield3
			lda #$00
			sta tmpfield4
			sta tmpfield1
			sta tmpfield2
			lda #VELOCITY_DECAY
			sta tmpfield5
			jmp merge_to_player_velocity
			; No return, jump to subroutine
	.)
.)

;
; Grounded neutral special
;

.(
	SINBAD_GROUNDED_SPECIAL_CHARGE_DURATION = 20
	duration_table(SINBAD_GROUNDED_SPECIAL_CHARGE_DURATION, duration_per_system)

	&sinbad_start_special:
	.(
		; Set the appropriate animation
		lda #<sinbad_anim_special_charge
		sta tmpfield13
		lda #>sinbad_anim_special_charge
		sta tmpfield14
		jsr set_player_animation

		; Set the player's state
		lda #SINBAD_STATE_SPECIAL_CHARGE
		sta player_a_state, x

		; Stop any momentum
		lda #$00
		sta player_a_velocity_h_low, x
		sta player_a_velocity_h, x
		sta player_a_velocity_v_low, x
		sta player_a_velocity_v, x

		; Initialize the clock
		ldy system_index
		lda duration_per_system, y
		sta player_a_state_clock, x

		rts
	.)

	&sinbad_tick_special_charge:
	.(
		dec player_a_state_clock, x
		bne end
			jmp sinbad_start_special_strike
			; No return, jump to a subroutine
		end:
		rts
	.)
.)

.(
	duration_per_system:
		.byt 2*sinbad_anim_special_dur_pal, 2*sinbad_anim_special_dur_ntsc

	STRIKE_HEIGHT = $10

	&sinbad_start_special_strike:
	.(

		; Set the appropriate animation
		lda #<sinbad_anim_special
		sta tmpfield13
		lda #>sinbad_anim_special
		sta tmpfield14
		jsr set_player_animation

		; Set the player's state
		lda #SINBAD_STATE_SPECIAL_STRIKE
		sta player_a_state, x

		; Place the player above ground
		lda player_a_y, x
		sec
		sbc #STRIKE_HEIGHT
		sta player_a_y, x

		; Initialize the clock
		ldy system_index
		lda duration_per_system, y
		sta player_a_state_clock, x

		rts
	.)

	&sinbad_tick_special_strike:
	.(
		dec player_a_state_clock, x
		bne end
			jmp sinbad_start_helpless
			; No return, jump to a subroutine
		end:
		rts
	.)
.)

;
; Side special
;

.(
	CHARGE_DURATION = 120
	MOVING_VELOCITY_V = $0080
	MOVING_VELOCITY_H = $0400

	duration_table(CHARGE_DURATION, charge_duration)
	velocity_table(-MOVING_VELOCITY_V, moving_velocity_v_msb, moving_velocity_v_lsb)
	velocity_table(MOVING_VELOCITY_H, moving_velocity_h_msb, moving_velocity_h_lsb)
	velocity_table(-MOVING_VELOCITY_H, moving_velocity_h_neg_msb, moving_velocity_h_neg_lsb)

	&sinbad_start_side_special:
	.(
		; Set state
		lda #SINBAD_STATE_SIDE_SPECIAL
		sta player_a_state, x

		; Set initial velocity
		lda #$00
		sta player_a_velocity_h_low, x
		sta player_a_velocity_h, x
		sta player_a_velocity_v_low, x
		sta player_a_velocity_v, x

		; Reset clock
		sta player_a_state_clock, x

		; Set substate to "charging"
		sta player_a_state_field1, x

		; Fallthrough to set the animation
	.)
	set_side_special_animation:
	.(
		; Set the appropriate animation
		lda #<sinbad_anim_side_special_charge
		sta tmpfield13
		lda #>sinbad_anim_side_special_charge
		sta tmpfield14
		jmp set_player_animation

		;rts ; useless, jump to subroutine
	.)

	&sinbad_tick_side_special:
	.(
		; Tick clock
		inc player_a_state_clock, x

		; Move if the substate is set to moving
		lda player_a_state_field1, x
		bne moving

		; Check if there is reason to begin to move
		ldy system_index
		lda player_a_state_clock, x
		cmp charge_duration, y
		bcs start_moving
		lda controller_a_btns, x
		cmp #CONTROLLER_INPUT_SPECIAL_RIGHT
		beq not_moving
		cmp #CONTROLLER_INPUT_SPECIAL_LEFT
		bne start_moving

		not_moving:
			jmp end

		start_moving:
			; Set substate to "moving"
			lda #$01
			sta player_a_state_field1, x

			; Store fly duration (fly_duration = 5 + charge_duration / 8)
			;NOTE The division of duration is pal/ntsc independent, the "5" constant could be made system-specific (but it would be minor)
			lda player_a_state_clock, x
			lsr
			lsr
			lsr
			clc
			adc #5
			sta player_a_state_field2, x

			; Set the movement animation
			lda #<sinbad_anim_side_special_jump
			sta tmpfield13
			lda #>sinbad_anim_side_special_jump
			sta tmpfield14
			jsr set_player_animation

			; Reset clock
			lda #0
			sta player_a_state_clock, x

		moving:
			; Set vertical velocity (fixed)
			ldy system_index
			lda moving_velocity_v_msb, y
			sta player_a_velocity_v, x
			lda moving_velocity_v_lsb, y
			sta player_a_velocity_v_low, x

			; Set horizontal velocity (depending on direction)
			lda player_a_direction, x
			cmp DIRECTION_LEFT
			bne right_velocity
				left_velocity:
					lda moving_velocity_h_neg_msb, y
					sta player_a_velocity_h, x
					lda moving_velocity_h_neg_lsb, y
					jmp h_velocity_ok
				right_velocity:
					lda moving_velocity_h_msb, y
					sta player_a_velocity_h, x
					lda moving_velocity_h_lsb, y
			h_velocity_ok:
			sta player_a_velocity_h_low, x

		; After move's time is out, go to helpless state
		lda player_a_state_clock, x
		cmp player_a_state_field2, x
		bne end
			jmp sinbad_start_helpless
			; No return, jump to subroutine

		end:
		rts
	.)
.)

;
; Helpless
;

.(
	&sinbad_start_helpless:
	.(
		; Set state
		lda #SINBAD_STATE_HELPLESS
		sta player_a_state, x

		; Fallthrough to set the animation
	.)
	set_helpless_animation:
	.(
		; Set the appropriate animation
		lda #<sinbad_anim_helpless
		sta tmpfield13
		lda #>sinbad_anim_helpless
		sta tmpfield14
		jmp set_player_animation

		;rts ; useless, jump to subroutine
	.)

	&sinbad_tick_helpless = sinbad_tick_falling

	&sinbad_input_helpless:
	.(
		; Allow to escape helpless mode with a walljump, else keep input dirty
		lda player_a_walled, x
		beq no_jump
		lda player_a_walljump, x
		beq no_jump
			jump:
				lda player_a_walled_direction, x
				sta player_a_direction, x
				jmp sinbad_start_walljumping
			no_jump:
				jmp keep_input_dirty
		;rts ; useless, both branches jump to a subroutine
	.)
.)

;
; Landing
;

.(
	landing_duration:
		.byt sinbad_anim_landing_dur_pal, sinbad_anim_landing_dur_ntsc

	velocity_table(SINBAD_LANDING_MAX_VELOCITY, land_max_velocity_msb, land_max_velocity_lsb)
	velocity_table(-SINBAD_LANDING_MAX_VELOCITY, land_max_neg_velocity_msb, land_max_neg_velocity_lsb)

	&sinbad_start_teching:
	.(
		jsr audio_play_tech
		jmp sinbad_start_landing_common
	.)
	&sinbad_start_landing:
	.(
		jsr audio_play_land
		; Fallthrough
	.)
	sinbad_start_landing_common:
	.(
		jsr sinbad_global_onground

		; Set state
		lda #SINBAD_STATE_LANDING
		sta player_a_state, x

		; Reset clock
		lda #0
		sta player_a_state_clock, x

		; Cap initial velocity
		ldy system_index
		lda player_a_velocity_h, x
		bmi negative_cap
			positive_cap:
			.(
				; Check wether to cap or not
				lda land_max_velocity_msb, y
				cmp player_a_velocity_h, x
				bcc do_cap ; msb(max) < msb(velocity)
				bne ok ; msb(max) > msb(velocity)
					lda player_a_velocity_h_low, x
					cmp land_max_velocity_lsb, y
					bcc ok ; lsb(velocity) < lsb(max)

				do_cap:
					lda land_max_velocity_msb, y
					sta player_a_velocity_h, x
					lda land_max_velocity_lsb, y
					sta player_a_velocity_h_low, x
				ok:
				jmp set_landing_animation
			.)
			negative_cap:
			.(
				; Check wether to cap or not - negative, we have to cap if unsigned CMP is lower than "max"
				lda player_a_velocity_h, x
				cmp land_max_velocity_msb, y
				bcc do_cap ; msb(velocity) < msb(max)
				bne ok ; msb(velocity) > msb(max)
					lda land_max_velocity_lsb, y
					cmp player_a_velocity_h_low, x
					bcc ok ; lsb(max) < lsb(velocity)

				do_cap:
					lda land_max_neg_velocity_msb, y
					sta player_a_velocity_h, x
					lda land_max_neg_velocity_lsb, y
					sta player_a_velocity_h_low, x
				ok:
			.)

		; Fallthrough to set the animation
	.)
	set_landing_animation:
	.(
		; Set the appropriate animation
		lda #<sinbad_anim_landing
		sta tmpfield13
		lda #>sinbad_anim_landing
		sta tmpfield14
		jsr set_player_animation

		rts
	.)

	&sinbad_tick_landing:
	.(
		; Tick clock
		inc player_a_state_clock, x

		; Do not move, velocity tends toward vector (0,0)
		jsr sinbad_apply_ground_friction

		; After move's time is out, go to standing state
		ldy system_index
		lda player_a_state_clock, x
		cmp landing_duration, y
		bne end
			jmp sinbad_start_inactive_state

		end:
		rts
	.)
.)

;
; Crashing
;

.(
	crashing_duration:
		.byt sinbad_anim_crashing_dur_pal, sinbad_anim_crashing_dur_ntsc

	&sinbad_start_crashing:
	.(
		jsr sinbad_global_onground

		; Set state
		lda #SINBAD_STATE_CRASHING
		sta player_a_state, x

		; Reset clock
		lda #0
		sta player_a_state_clock, x

		; Fallthrough to set the animation
	.)
	set_crashing_animation:
	.(
		; Set the appropriate animation
		lda #<sinbad_anim_crashing
		sta tmpfield13
		lda #>sinbad_anim_crashing
		sta tmpfield14
		jsr set_player_animation

		; Play crash sound
		jsr audio_play_crash

		rts
	.)

	&sinbad_tick_crashing:
	.(
		; Tick clock
		inc player_a_state_clock, x

		; Do not move, velocity tends toward vector (0,0)
		lda #$00
		sta tmpfield4
		sta tmpfield3
		sta tmpfield2
		sta tmpfield1
		ldy system_index
		lda sinbad_ground_friction_strength_strong, y
		sta tmpfield5
		jsr merge_to_player_velocity

		; After move's time is out, go to standing state
		lda player_a_state_clock, x
		ldy system_index
		cmp crashing_duration, y
		bne end
			jmp sinbad_start_inactive_state

		end:
		rts
	.)
.)

;
; Down tilt
;

.(
	down_tilt_duration:
		.byt sinbad_anim_down_tilt_dur_pal, sinbad_anim_down_tilt_dur_ntsc

	&sinbad_start_down_tilt:
	.(
		; Set state
		lda #SINBAD_STATE_DOWN_TILT
		sta player_a_state, x

		; Reset clock
		ldy system_index
		lda down_tilt_duration, y
		sta player_a_state_clock, x

		; Fallthrough to set the animation
	.)
	set_down_tilt_animation:
	.(
		; Set the appropriate animation
		lda #<sinbad_anim_down_tilt
		sta tmpfield13
		lda #>sinbad_anim_down_tilt
		sta tmpfield14
		jmp set_player_animation

		;rts ; useless, jump to subroutine
	.)

	&sinbad_tick_down_tilt:
	.(
		; After move's time is out, go to standing state
		dec player_a_state_clock, x
		bne tick
			jmp sinbad_start_inactive_state
			; No return, jump to subroutine
		tick:

		; Do not move, velocity tends toward vector (0,0)
		jmp sinbad_apply_ground_friction

		;rts ; useless, jump to subroutine
	.)
.)

;
; Aerial side
;

.(
	aerial_side_duration:
		.byt sinbad_anim_aerial_side_dur_pal, sinbad_anim_aerial_side_dur_ntsc

	&sinbad_start_aerial_side:
	.(
		; Set state
		lda #SINBAD_STATE_AERIAL_SIDE
		sta player_a_state, x

		; Reset clock
		ldy system_index
		lda aerial_side_duration, y
		sta player_a_state_clock, x

		; Fallthrough to set the animation
	.)
	set_aerial_side_animation:
	.(
		; Set the appropriate animation
		lda #<sinbad_anim_aerial_side
		sta tmpfield13
		lda #>sinbad_anim_aerial_side
		sta tmpfield14
		jmp set_player_animation

		;rts ; useless, jump to subroutine
	.)

	&sinbad_tick_aerial_side:
	.(
		dec player_a_state_clock, x
		bne tick
			jmp sinbad_start_falling
			; No return, jump to subroutine
		tick:
		jmp apply_player_gravity
		;rts ; useless, jump to subroutine
	.)
.)

;
; Aerial down
;

.(
	aerial_down_duration:
		.byt sinbad_anim_aerial_down_dur_pal, sinbad_anim_aerial_down_dur_ntsc

	&sinbad_start_aerial_down:
	.(
		; Set state
		lda #SINBAD_STATE_AERIAL_DOWN
		sta player_a_state, x

		; Reset clock
		ldy system_index
		lda aerial_down_duration, y
		sta player_a_state_clock, x

		; Fallthrough to set the animation
	.)
	set_aerial_down_animation:
	.(
		; Set the appropriate animation
		lda #<sinbad_anim_aerial_down
		sta tmpfield13
		lda #>sinbad_anim_aerial_down
		sta tmpfield14
		jmp set_player_animation

		;rts ; useless, jump to subroutine
	.)

	&sinbad_tick_aerial_down:
	.(
		dec player_a_state_clock, x
		bne tick
			jmp sinbad_start_falling
			; No return, jump to subroutine
		tick:
		jmp apply_player_gravity
		;rts ; useless, jump to subroutine
	.)
.)

;
; Aerial up
;

.(
	aerial_up_duration:
		.byt sinbad_anim_aerial_up_dur_pal, sinbad_anim_aerial_up_dur_ntsc

	&sinbad_start_aerial_up:
	.(
		; Set state
		lda #SINBAD_STATE_AERIAL_UP
		sta player_a_state, x

		; Reset clock
		ldy system_index
		lda aerial_up_duration, y
		sta player_a_state_clock, x

		; Fallthrough to set the animation
	.)
	set_aerial_up_animation:
	.(
		; Set the appropriate animation
		lda #<sinbad_anim_aerial_up
		sta tmpfield13
		lda #>sinbad_anim_aerial_up
		sta tmpfield14
		jmp set_player_animation

		;rts ; useless, jump to subroutine
	.)

	&sinbad_tick_aerial_up:
	.(
		dec player_a_state_clock, x
		bne tick
			jmp sinbad_start_falling
			; No return, jump to subroutine
		tick:
		jmp apply_player_gravity
		;rts ; useless, jump to subroutine
	.)
.)

;
; Aerial neutral
;

.(
	aerial_neutral_duration:
		.byt sinbad_anim_aerial_neutral_dur_pal, sinbad_anim_aerial_neutral_dur_ntsc

	&sinbad_start_aerial_neutral:
	.(
		; Set state
		lda #SINBAD_STATE_AERIAL_NEUTRAL
		sta player_a_state, x

		; Reset clock
		ldy system_index
		lda aerial_neutral_duration, y
		sta player_a_state_clock, x

		; Fallthrough to set the animation
	.)
	set_aerial_neutral_animation:
	.(
		; Set the appropriate animation
		lda #<sinbad_anim_aerial_neutral
		sta tmpfield13
		lda #>sinbad_anim_aerial_neutral
		sta tmpfield14
		jmp set_player_animation

		;rts ; useless, jump to subroutine
	.)

	&sinbad_tick_aerial_neutral:
	.(
		dec player_a_state_clock, x
		bne tick
			jmp sinbad_start_falling
			; No return, jump to subroutine
		tick:
		jmp apply_player_gravity
		;rts ; useless, jump to subroutine
	.)
.)

.(
	FALL_SPEED = $0100
	FALL_ACCELERATION = $10

	velocity_table(FALL_SPEED, fall_speed_msb, fall_speed_lsb)
	velocity_table_u8(FALL_ACCELERATION, fall_acceleration)

	&sinbad_start_aerial_spe:
	.(
		; Set state
		lda #SINBAD_STATE_AERIAL_SPE_NEUTRAL
		sta player_a_state, x

		; Set substate to "not cancelable"
		lda #0
		sta player_a_state_field1, x

		; Fallthrough to set the animation
	.)
	set_aerial_spe_animation:
	.(
		; Set the appropriate animation
		lda #<sinbad_anim_aerial_spe
		sta tmpfield13
		lda #>sinbad_anim_aerial_spe
		sta tmpfield14
		jsr set_player_animation

		rts
	.)

	&sinbad_tick_aerial_spe:
	.(
		jsr sinbad_aerial_directional_influence

		; Never move upward in this state
		lda player_a_velocity_v, x
		bpl end_max_velocity
			lda #$00
			sta player_a_velocity_v, x
			sta player_a_velocity_v_low, x
		end_max_velocity:

		; Special fall speed - particularily slow
		lda player_a_velocity_h, x
		sta tmpfield4
		lda player_a_velocity_h_low, x
		sta tmpfield2
		ldy system_index
		lda fall_speed_msb, y
		sta tmpfield3
		lda fall_speed_lsb, y
		sta tmpfield1
		lda fall_acceleration, y
		sta tmpfield5
		jsr merge_to_player_velocity

		rts
	.)

	&sinbad_input_aerial_spe:
	.(
		lda player_a_state_field1, x
		beq check_release

			check_cancel:
				; Press B again to cancel into helpless
				lda controller_a_btns, x
				and #CONTROLLER_BTN_B
				beq end

					jmp sinbad_start_helpless
					; No return, jump to a subroutine

			check_release:
				; Release B to pass in "cancelable" substate
				lda controller_a_btns, x
				and #CONTROLLER_BTN_B
				bne end

					inc player_a_state_field1, x
					; Fallthrough

		end:
		rts
	.)
.)

.(
	SPE_UP_PREPARATION_DURATION = 3
	SPE_UP_POWER = $0600

	velocity_table(-SPE_UP_POWER, spe_up_power_msb, spe_up_power_lsb)

	&sinbad_start_spe_up:
	.(
		; Set state
		lda #SINBAD_STATE_SPE_UP
		sta player_a_state, x

		; Reset fall speed
		jsr reset_default_gravity

		; Set initial velocity
		lda #$00
		sta player_a_velocity_h_low, x
		sta player_a_velocity_h, x
		sta player_a_velocity_v_low, x
		sta player_a_velocity_v, x

		; Reset clock
		sta player_a_state_clock, x

		; Set substate to "charging"
		sta player_a_state_field1, x

		; Fallthrough to set the animation
	.)
	set_spe_up_animation:
	.(
		; Set the appropriate animation
		lda #<sinbad_anim_spe_up_prepare
		sta tmpfield13
		lda #>sinbad_anim_spe_up_prepare
		sta tmpfield14
		jsr set_player_animation

		rts
	.)

	&sinbad_tick_spe_up:
	.(
		; Tick clock
		inc player_a_state_clock, x

		; Move if the substate is set to moving
		lda player_a_state_field1, x
		bne moving

		; Check if there is reason to begin to move
		lda player_a_state_clock, x
		cmp #SPE_UP_PREPARATION_DURATION
		bcs start_moving

		not_moving:
			jmp end

		start_moving:
			; Set substate to "moving"
			lda #$01
			sta player_a_state_field1, x

			; Set jumping velocity
			ldy system_index
			lda spe_up_power_msb, y
			sta player_a_velocity_v, x
			lda spe_up_power_lsb, y
			sta player_a_velocity_v_low, x

			; Set the movement animation
			lda #<sinbad_anim_spe_up_jump
			sta tmpfield13
			lda #>sinbad_anim_spe_up_jump
			sta tmpfield14
			jsr set_player_animation

		moving:
			; Return to falling when the top is reached
			lda player_a_velocity_v, x
			beq top_reached
			bpl top_reached

				; The top is not reached, stay in special upward state but apply gravity and directional influence
				jsr sinbad_aerial_directional_influence
				jsr apply_player_gravity
				jmp end

			top_reached:
				jsr sinbad_start_helpless
				jmp end

		end:
		rts
	.)
.)

.(
	spe_down_duration:
		.byt sinbad_anim_spe_down_dur_pal, sinbad_anim_spe_down_dur_ntsc

	&sinbad_start_spe_down:
	.(
		; Set state
		lda #SINBAD_STATE_SPE_DOWN
		sta player_a_state, x

		; Reset clock
		lda #0
		sta player_a_state_clock, x

		; Fallthrough to set the animation
	.)
	set_spe_down_animation:
	.(
		; Set the appropriate animation
		lda #<sinbad_anim_spe_down
		sta tmpfield13
		lda #>sinbad_anim_spe_down
		sta tmpfield14
		jsr set_player_animation

		rts
	.)

	&sinbad_tick_spe_down:
	.(
		lda player_a_grounded, x
		beq air_friction
			ground_friction:
				lda #$00
				sta tmpfield4
				sta tmpfield3
				sta tmpfield2
				sta tmpfield1
				ldy system_index
				lda sinbad_ground_friction_strength_weak, y
				sta tmpfield5
				jsr merge_to_player_velocity
				jmp end_friction
			air_friction:
				jsr sinbad_apply_air_friction
				jsr apply_player_gravity
				; Fallthrough
		end_friction:

		; Wait for move's timeout
		ldy system_index
		inc player_a_state_clock, x
		lda player_a_state_clock, x
		cmp spe_down_duration, y
		bne end

		; Return to falling or standing
		jmp sinbad_start_inactive_state
		; No return, jump to subroutine

		end:
		rts
	.)
.)

.(
	uptilt_duration:
		.byt sinbad_anim_up_tilt_dur_pal, sinbad_anim_up_tilt_dur_ntsc

	&sinbad_start_up_tilt:
	.(
		; Set state
		lda #SINBAD_STATE_UP_TILT
		sta player_a_state, x

		; Reset clock
		ldy system_index
		lda uptilt_duration, y
		sta player_a_state_clock, x

		; Fallthrough to set the animation
	.)
	set_up_tilt_animation:
	.(
		; Set the appropriate animation
		lda #<sinbad_anim_up_tilt
		sta tmpfield13
		lda #>sinbad_anim_up_tilt
		sta tmpfield14
		jsr set_player_animation

		rts
	.)

	&sinbad_tick_up_tilt:
	.(
		dec player_a_state_clock, x
		bne tick
			jmp sinbad_start_inactive_state
			; No return, jump to subroutine
		tick:

		; Do not move, velocity tends toward vector (0,0)
		jmp sinbad_apply_ground_friction
		;rts ; useless, jump to subroutine
	.)
.)

;
; Shielding
;

.(
	&sinbad_start_shielding:
	.(
		; Set state
		lda #SINBAD_STATE_SHIELDING
		sta player_a_state, x

		; Reset clock, used for down-tap detection
		ldy system_index
		lda player_down_tap_max_duration, y
		sta player_a_state_clock, x

		; Fallthrough to set the animation
	.)
	set_shielding_animation:
	.(
		; Set the appropriate animation
		lda #<sinbad_anim_shielding_full
		sta tmpfield13
		lda #>sinbad_anim_shielding_full
		sta tmpfield14
		jsr set_player_animation

		; Cancel momentum
		lda #$00
		sta player_a_velocity_h_low, x
		sta player_a_velocity_h, x

		; Set shield as full life
		lda #2
		sta player_a_state_field1, x

		rts
	.)

	&sinbad_tick_shielding:
	.(
		; Tick clock, stop at zero
		lda player_a_state_clock, x
		beq end_tick
			dec player_a_state_clock, x
		end_tick:

		rts
	.)

	&sinbad_input_shielding:
	.(
		; Maintain down to stay on shield
		; Ignore left/right as they are too susceptible to be pressed unvoluntarily on a lot of gamepads
		; Down-a and down-b are allowed as out of shield moves
		; Any other combination ends the shield (with shield lag or falling from smooth platform)
		lda controller_a_btns, x
		and #CONTROLLER_BTN_A+CONTROLLER_BTN_B+CONTROLLER_BTN_UP+CONTROLLER_BTN_DOWN
		cmp #CONTROLLER_INPUT_TECH
		beq end
		cmp #CONTROLLER_INPUT_DOWN_TILT
		beq handle_input
		cmp #CONTROLLER_INPUT_SPECIAL_DOWN
		beq handle_input

		end_shield:

			lda player_a_state_clock, x
			beq shieldlag
				ldy player_a_grounded, x
				beq shieldlag
					lda stage_data, y
					cmp #STAGE_ELEMENT_PLATFORM
					beq shieldlag
					cmp #STAGE_ELEMENT_OOS_PLATFORM
					beq shieldlag

			fall_from_smooth:
				; HACK - "position = position + 2" to compensate collision system not handling subpixels and "position + 1" being the collision line
				;        actually, "position = position + 3" to compensate for moving platforms that move down
				;        Better solution would be to have an intermediary player state with a specific animation
				clc
				lda player_a_y, x
				adc #3
				sta player_a_y, x
				lda player_a_y_screen, x
				adc #0
				sta player_a_y_screen, x

				jmp sinbad_start_falling
				; No return, jump to subroutine

			shieldlag:
				jmp sinbad_start_shieldlag
				; No return, jump to subroutine

		handle_input:

			jmp sinbad_input_standing
			; No return, jump to subroutine

		end:
		rts
	.)

	&sinbad_hurt_shielding:
	.(
		stroke_player = tmpfield11

		; Reduce shield's life
		dec player_a_state_field1, x

		; Select what to do according to shield's life
		lda player_a_state_field1, x
		beq limit_shield
		cmp #1
		beq partial_shield

			; Break the shield, derived from normal hurt with:
			;  Knockback * 2
			;  Screen shaking * 4
			;  Special sound
			jsr hurt_player
			ldx stroke_player
			asl player_a_velocity_h_low, x
			rol player_a_velocity_h, x
			asl player_a_velocity_v_low, x
			rol player_a_velocity_v, x
			asl player_a_hitstun, x
			asl screen_shake_counter
			asl screen_shake_counter
			jsr audio_play_shield_break
			jmp end

		; Get the animation corresponding to the shield's life
		partial_shield:
			lda #<sinbad_anim_shielding_partial
			sta tmpfield13
			lda #>sinbad_anim_shielding_partial
			jmp still_shield

		limit_shield:
			lda #<sinbad_anim_shielding_limit
			sta tmpfield13
			lda #>sinbad_anim_shielding_limit

		still_shield:
			; Set the new shield animation
			sta tmpfield14
			jsr set_player_animation

			; Play sound
			jsr audio_play_shield_hit

		end:
		; Disable the hitbox to avoid multi-hits
		jsr switch_selected_player
		lda HITBOX_DISABLED
		sta player_a_hitbox_enabled, x

		rts
	.)
.)

.(
	shieldlag_duration:
		.byt sinbad_anim_shielding_remove_dur_pal, sinbad_anim_shielding_remove_dur_ntsc

	&sinbad_start_shieldlag:
	.(
		; Set state
		lda #SINBAD_STATE_SHIELDLAG
		sta player_a_state, x

		; Reset clock
		ldy system_index
		lda shieldlag_duration, y
		sta player_a_state_clock, x

		; Fallthrough to set the animation
	.)
	&set_shieldlag_animation:
	.(
		; Set the appropriate animation
		lda #<sinbad_anim_shielding_remove
		sta tmpfield13
		lda #>sinbad_anim_shielding_remove
		sta tmpfield14
		jmp set_player_animation

		;rts ; useless, jump to subroutine
	.)

	&sinbad_tick_shieldlag:
	.(
		dec player_a_state_clock, x
		bne tick
			jmp sinbad_start_inactive_state
			; No return, jump to subroutine
		tick:
		jmp sinbad_apply_ground_friction
		;rts ; useless, jump to subroutine
	.)
.)

;
; Innexistant
;

.(
	&sinbad_start_innexistant:
	.(
		; Set state
		lda #SINBAD_STATE_INNEXISTANT
		sta player_a_state, x

		; Set to a fixed place
		lda #0
		sta player_a_x_screen, x
		sta player_a_x, x
		sta player_a_x_low, x
		sta player_a_y_screen, x
		sta player_a_y, x
		sta player_a_y_low, x
		sta player_a_velocity_h, x
		sta player_a_velocity_h_low, x
		sta player_a_velocity_v, x
		sta player_a_velocity_v_low, x

		; Fallthrough to set the animation
	.)
	set_innexistant_animation:
	.(
		; Set the appropriate animation
		lda #<anim_invisible
		sta tmpfield13
		lda #>anim_invisible
		sta tmpfield14
		jmp set_player_animation

		;rts ; useless, jump to subroutine
	.)
.)

;
; Spawn
;

.(
	spawn_duration:
		.byt sinbad_anim_spawn_dur_pal, sinbad_anim_spawn_dur_ntsc
#if sinbad_anim_spawn_dur_pal <> 50
#error incorrect spawn duration
#endif
#if sinbad_anim_spawn_dur_ntsc <> 60
#error incorrect spawn duration (ntsc only)
#endif

	&sinbad_start_spawn:
	.(
		; Hack - there is no ensured call to a character init function
		;        expect start_spawn to be called once at the begining of a game
		jsr sinbad_init

		; Set the player's state
		lda #SINBAD_STATE_SPAWN
		sta player_a_state, x

		; Reset clock
		ldy system_index
		lda spawn_duration, y
		sta player_a_state_clock, x

		; Fallthrough to set the animation
	.)
	set_spawn_animation:
	.(
		; Set the appropriate animation
		lda #<sinbad_anim_spawn
		sta tmpfield13
		lda #>sinbad_anim_spawn
		sta tmpfield14
		jmp set_player_animation

		;rts ; useless, jump to subroutine
	.)

	&sinbad_tick_spawn:
	.(
		dec player_a_state_clock, x
		bne tick
			jmp sinbad_start_standing
			; No return, jump to subroutine
		tick:
		rts
	.)
.)

.(
	SINBAD_WALL_JUMP_SQUAT_END = 4
	SINBAD_WALL_JUMP_VELOCITY_V = $0480
	SINBAD_WALL_JUMP_VELOCITY_H = $0100

	velocity_table(-SINBAD_WALL_JUMP_VELOCITY_V, sinbad_wall_jump_velocity_v_msb, sinbad_wall_jump_velocity_v_lsb)
	velocity_table(SINBAD_WALL_JUMP_VELOCITY_H, sinbad_wall_jump_velocity_h_msb, sinbad_wall_jump_velocity_h_lsb)
	velocity_table(-SINBAD_WALL_JUMP_VELOCITY_H, sinbad_wall_jump_velocity_h_neg_msb, sinbad_wall_jump_velocity_h_neg_lsb)

	&sinbad_start_walljumping:
	.(
		; Deny to start jump state if the player used all it's jumps
		;lda player_a_walljump, x ; useless, all calls to sinbad_start_walljumping actually do this check
		;beq end

		; Update wall jump counter
		dec player_a_walljump, x

		; Set player's state
		lda #SINBAD_STATE_WALLJUMPING
		sta player_a_state, x

		; Reset clock
		lda #0
		sta player_a_state_clock, x

		; Stop any momentum, sinbad does not fall during jumpsquat
		sta player_a_velocity_h, x
		sta player_a_velocity_h_low, x
		sta player_a_velocity_v, x
		sta player_a_velocity_v_low, x

		; Reset fall speed
		jsr reset_default_gravity

		; Play SFX
		jsr audio_play_jump

		; Set the appropriate animation
		;TODO specific animation
		lda #<sinbad_anim_jumping
		sta tmpfield13
		lda #>sinbad_anim_jumping
		sta tmpfield14
		jsr set_player_animation

		end:
		rts
	.)

	&sinbad_tick_walljumping:
	.(
		; Tick clock
		inc player_a_state_clock, x

		; Wait for the preparation to end to begin to jump
		lda player_a_state_clock, x
		cmp #SINBAD_WALL_JUMP_SQUAT_END
		bcc end
		beq begin_to_jump

		; Check if the top of the jump is reached
		lda player_a_velocity_v, x
		beq top_reached
		bpl top_reached

			; The top is not reached, stay in walljumping state but apply gravity, without directional influence
			jmp apply_player_gravity
			;jmp end ; useless, jump to a subroutine

		; The top is reached, return to falling
		top_reached:
			jmp sinbad_start_falling
			;jmp end ; useless, jump to a subroutine

		; Put initial jumping velocity
		begin_to_jump:
			;TODO set animation

			; Vertical velocity
			ldy system_index
			lda sinbad_wall_jump_velocity_v_msb, y
			sta player_a_velocity_v, x
			lda sinbad_wall_jump_velocity_v_lsb, y
			sta player_a_velocity_v_low, x

			; Horizontal velocity
			lda player_a_direction, x
			;cmp DIRECTION_LEFT ; useless while DIRECTION_LEFT is $00
			bne jump_right
				jump_left:
					lda sinbad_wall_jump_velocity_h_neg_msb, y
					sta player_a_velocity_h, x
					lda sinbad_wall_jump_velocity_h_neg_lsb, y
					jmp end_jump_direction
				jump_right:
					lda sinbad_wall_jump_velocity_h_msb, y
					sta player_a_velocity_h, x
					lda sinbad_wall_jump_velocity_h_lsb, y
			end_jump_direction:
			sta player_a_velocity_h_low, x

			;jmp end ; useless, fallthrough

		end:
		rts
	.)

	&sinbad_input_walljumping:
	.(
		; The jump is cancellable by aerial movements, but only after preparation
		lda #SINBAD_WALL_JUMP_SQUAT_END
		cmp player_a_state_clock, x
		bcs grounded
			not_grounded:
				jmp sinbad_check_aerial_inputs
				; no return, jump to a subroutine
		grounded:
		rts
	.)
.)

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

SINBAD_AIR_FRICTION_STRENGTH = 7
SINBAD_FASTFALL_GRAVITY = $05
SINBAD_GROUND_FRICTION_STRENGTH = $40
SINBAD_MAX_WALLJUMPS = 1
SINBAD_RUNNING_SPEED_MAX = $0200
SINBAD_RUNNING_SPEED_INIT = $0100
SINBAD_RUNNING_SPEED_ACCELERATION = $40

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
	lda #SINBAD_AIR_FRICTION_STRENGTH
	sta merge_step
	jmp merge_to_player_velocity
	;rts ; useless, jump to a subroutine
.)

; Change the player's state if an aerial move is input on the controller
;  register X - Player number
;
;  Overwrites tmpfield15 and tmpfield2 plus the ones overriten by the state starting subroutine
check_aerial_inputs:
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
				lda #SINBAD_FASTFALL_GRAVITY
				sta player_a_gravity, x
				sta player_a_velocity_v, x
				lda #$00
				sta player_a_velocity_v_low, x
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
		; Note - We have to put subroutines as callbacks since we do not expect a return unless we used the default callback
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

aerial_directional_influence:
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
		lda #$00
		sta tmpfield6
		lda #$ff
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
			lda #$00
			sta merged_h_low
			lda #$ff
			sta merged_h_high
			lda #$80
			sta merge_step
			jmp merge_to_player_velocity
			; No return, jump to a subroutine

	go_right:
		; Go to the right
		lda player_a_velocity_h_low, x
		sta tmpfield6
		lda player_a_velocity_h, x
		sta tmpfield7
		lda #$00
		sta tmpfield8
		lda #$01
		sta tmpfield9
		jsr signed_cmp
		bpl end

			lda player_a_velocity_v_low, x
			sta merged_v_low
			lda player_a_velocity_v, x
			sta merged_v_high
			lda #$00
			sta merged_h_low
			lda #$01
			sta merged_h_high
			lda #$80
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

sinbad_start_standing:
.(
	; Set the appropriate animation
	lda #<anim_sinbad_idle
	sta tmpfield13
	lda #>anim_sinbad_idle
	sta tmpfield14
	jsr set_player_animation

	; Set the player's state
	lda #SINBAD_STATE_STANDING
	sta player_a_state, x
	rts
.)

; Update a player that is standing on ground
;  register X must contain the player number
sinbad_tick_standing:
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

sinbad_input_standing:
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

.(
	velocity_table(SINBAD_RUNNING_SPEED_INIT, run_init_velocity_msb, run_init_velocity_lsb)
	velocity_table(-SINBAD_RUNNING_SPEED_INIT, run_init_neg_velocity_msb, run_init_neg_velocity_lsb)

	velocity_table(SINBAD_RUNNING_SPEED_MAX, run_max_velocity_msb, run_max_velocity_lsb)
	velocity_table(-SINBAD_RUNNING_SPEED_MAX, run_max_neg_velocity_msb, run_max_neg_velocity_lsb)

	velocity_table_u8(SINBAD_RUNNING_SPEED_ACCELERATION, run_acceleration)

	&sinbad_start_running:
	.(
		lda #SINBAD_STATE_RUNNING
		sta player_a_state, x
		; Fallthrough
	.)
	set_running_animation:
	.(
		; Set the appropriate animation
		lda #<anim_sinbad_run
		sta tmpfield13
		lda #>anim_sinbad_run
		sta tmpfield14
		jsr set_player_animation

		; Set initial velocity
		ldy #SYSTEM_INDEX
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
		ldy #SYSTEM_INDEX
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

sinbad_start_falling:
.(
	lda #SINBAD_STATE_FALLING
	sta player_a_state, x

	; Fallthrough to set the animation
.)
set_falling_animation:
.(
	; Set the appropriate animation
	lda #<anim_sinbad_falling
	sta tmpfield13
	lda #>anim_sinbad_falling
	sta tmpfield14
	jsr set_player_animation

	rts
.)

; Update a player that is falling
;  register X must contain the player number
sinbad_tick_falling:
.(
	jsr aerial_directional_influence
	jsr apply_player_gravity
	rts
.)

sinbad_start_jumping:
.(
	lda #SINBAD_STATE_JUMPING
	sta player_a_state, x

	lda #0
	sta player_a_state_field1, x
	sta player_a_state_clock, x

	; Fallthrough to set the animation
.)
set_jumping_animation:
.(
	; Set the appropriate animation
	lda #<anim_sinbad_jumping
	sta tmpfield13
	lda #>anim_sinbad_jumping
	sta tmpfield14
	jsr set_player_animation

	rts
.)

#define STATE_SINBAD_JUMP_PREPARATION_END #4
sinbad_tick_jumping:
.(
	; Tick clock
	inc player_a_state_clock, x

	; Wait for the preparation to end to begin to jump
	lda player_a_state_clock, x
	cmp STATE_SINBAD_JUMP_PREPARATION_END
	bcc end
	beq begin_to_jump

	; Check if the top of the jump is reached
	lda player_a_velocity_v, x
	beq top_reached
	bpl top_reached

		; The top is not reached, stay in jumping state but apply gravity and directional influence
		jsr sinbad_tick_falling ; Hack - We just use sinbad_tick_falling which do exactly what we want

		; Check if it is time to stop a short-hop
		lda player_a_velocity_v, x
		cmp #$fd
		bcs stop_short_hop
		jmp end

	; The top is reached, return to falling
	top_reached:
		jsr sinbad_start_falling
		jmp end

	; If the jump button is no more pressed mid jump, convert the jump to a short-hop
	stop_short_hop:
		lda player_a_state_field1, x ;
		bne end                      ; Check for short hop only once
		inc player_a_state_field1, x ;

		lda controller_a_btns, x   ;
		and #CONTROLLER_INPUT_JUMP ; If the jump button is still pressed, this is not a short-hop
		bne end                    ;

		lda #$fe                       ;
		sta player_a_velocity_v, x     ;
		sta player_a_velocity_v_low, x ; Reduce upward momentum to end the jump earlier
		jmp end                        ;

	; Put initial jumping velocity
	begin_to_jump:
		lda #$fb
		sta player_a_velocity_v, x
		lda #$80
		sta player_a_velocity_v_low, x
		jmp end

	end:
	rts
.)

sinbad_input_jumping:
.(
	; The jump is cancellable by grounded movements during preparation
	; and by aerial movements after that
	lda player_a_num_aerial_jumps, x ; performing aerial jump, not
	bne not_grounded                 ; grounded
	lda player_a_state_clock, x           ;
	cmp STATE_SINBAD_JUMP_PREPARATION_END ; Still preparing the jump
	bcc grounded                          ;

	not_grounded:
		jsr check_aerial_inputs
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

#define MAX_NUM_AERIAL_JUMPS 1
sinbad_start_aerial_jumping:
.(
	; Deny to start jump state if the player used all it's jumps
	lda #MAX_NUM_AERIAL_JUMPS
	cmp player_a_num_aerial_jumps, x
	bne jump_ok
	rts
	jump_ok:
	inc player_a_num_aerial_jumps, x

	; Reset fall speed
	lda #DEFAULT_GRAVITY
	sta player_a_gravity, x

	; Trick - aerial_jumping set the state to jumping. It is the same state with
	; the starting conditions as the only differences
	lda #SINBAD_STATE_JUMPING
	sta player_a_state, x

	; Reset clock
	lda #0
	sta player_a_state_clock, x

	lda #$00
	sta player_a_velocity_v, x
	lda #$00
	sta player_a_velocity_v_low, x

	; Fallthrough to set the animation
.)
set_aerial_jumping_animation:
.(
	; Set the appropriate animation
	lda #<anim_sinbad_aerial_jumping
	sta tmpfield13
	lda #>anim_sinbad_aerial_jumping
	sta tmpfield14
	jsr set_player_animation

	rts
.)

sinbad_start_jabbing:
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
	lda #<anim_sinbad_jab
	sta tmpfield13
	lda #>anim_sinbad_jab
	sta tmpfield14
	jsr set_player_animation

	rts
.)

#define STATE_SINBAD_JAB_DURATION #14
sinbad_tick_jabbing:
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
	lda player_a_state_clock, x
	cmp STATE_SINBAD_JAB_DURATION
	bne end
	jmp sinbad_start_inactive_state
	; No return, jump to subroutine

	end:
	rts
.)

sinbad_input_jabbing:
.(
	; Allow to cut the animation for another jab
	lda controller_a_btns, x
	cmp #CONTROLLER_INPUT_JAB
	bne end

	jsr sinbad_start_jabbing

	end:
	rts
.)

sinbad_start_thrown:
.(
	; Set player's state
	lda #SINBAD_STATE_THROWN
	sta player_a_state, x

	; Initialize tech counter
	lda #0
	sta player_a_state_field1, x

	; Fallthrough to set the animation
.)
set_thrown_animation:
.(
	lda #<anim_sinbad_thrown
	sta tmpfield13
	lda #>anim_sinbad_thrown
	sta tmpfield14
	jsr set_player_animation

	; Set the appropriate animation direction (depending on player's velocity)
	lda player_a_velocity_h, x
	bmi set_anim_left
	lda DIRECTION_RIGHT
	jmp set_anim_dir
	set_anim_left:
	lda DIRECTION_LEFT
	set_anim_dir:
	ldy #ANIMATION_STATE_OFFSET_DIRECTION
	sta (tmpfield11), y

	rts
.)

; To tech successfully the tech must be input at maximum TECH_MAX_FRAMES_BEFORE_COLLISION frames before hitting the ground.
; After expiration of a tech input, it is not possible to input another tech for TECH_NB_FORBIDDEN_FRAMES frames.
sinbad_tick_thrown:
.(
	; Update velocity
	lda player_a_hitstun, x
	bne gravity
	jsr aerial_directional_influence
	gravity:
	jsr apply_player_gravity

	; Decrement tech counter (to zero minimum)
	lda player_a_state_field1, x
	beq end_dec_tech_cnt
	dec player_a_state_field1, x
	end_dec_tech_cnt:

	rts
.)

sinbad_input_thrown:
.(
	; Handle controller inputs
	lda #<controller_inputs
	sta tmpfield1
	lda #>controller_inputs
	sta tmpfield2
	lda #$03
	sta tmpfield3
	jmp controller_callbacks

	; If a tech is entered, store it's direction in state_field2
	; and if the counter is at 0, reset it to it's max value.
	tech_neutral:
		lda #$00
		jmp tech_common
	tech_right:
		lda #$01
		jmp tech_common
	tech_left:
		lda #$02
	tech_common:
		sta player_a_state_field2, x
		lda player_a_state_field1, x
		bne end
		lda #TECH_MAX_FRAMES_BEFORE_COLLISION+TECH_NB_FORBIDDEN_FRAMES
		sta player_a_state_field1, x

	no_tech:
		jsr check_aerial_inputs

	end:
	rts

	; Impactful controller states and associated callbacks
	controller_inputs:
	.byt CONTROLLER_INPUT_TECH,        CONTROLLER_INPUT_TECH_RIGHT,   CONTROLLER_INPUT_TECH_LEFT
	controller_callbacks_lo:
	.byt <tech_neutral,                <tech_right,                   <tech_left
	controller_callbacks_hi:
	.byt >tech_neutral,                >tech_right,                   >tech_left
	controller_default_callback:
	.word no_tech
.)

; Routine to be called when hitting the ground from thrown state
sinbad_thrown_on_ground:
.(
	;jsr sinbad_global_onground ; useless, will be done by start_landing or start_crashing

	; If the tech counter is bellow the threshold, just crash
	lda #TECH_NB_FORBIDDEN_FRAMES
	cmp player_a_state_field1, x
	bcs crash

		; A valid tech was entered, land with momentum depending on tech's direction
		jsr sinbad_start_landing
		lda player_a_state_field2, x
		beq no_momentum
		cmp #$01
		beq momentum_right
			lda #$fc
			sta player_a_velocity_h, x
			lda #$00
			sta player_a_velocity_h_low, x
			jmp end
		no_momentum:
			lda #$00
			sta player_a_velocity_h, x
			sta player_a_velocity_h_low, x
			jmp end
		momentum_right:
			lda #$04
			sta player_a_velocity_h, x
			lda #$00
			sta player_a_velocity_h_low, x
			jmp end

	crash:
		jsr sinbad_start_crashing

	end:
	rts
.)

sinbad_start_respawn:
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
	lda #PLAYER_RESPAWN_MAX_DURATION
	sta player_a_state_field1, x

	; Reinitialize walljump counter
	lda #SINBAD_MAX_WALLJUMPS
	sta player_a_walljump, x

	; Set the appropriate animation
	lda #<anim_sinbad_respawn
	sta tmpfield13
	lda #>anim_sinbad_respawn
	sta tmpfield14
	jsr set_player_animation

	rts
.)

sinbad_tick_respawn:
.(
	; Check for timeout
	dec player_a_state_field1, x
	bne end
	jsr sinbad_start_falling

	end:
	rts
.)

sinbad_input_respawn:
.(
	; Avoid doing anything until controller has returned to neutral since after
	; death the player can release buttons without expecting to take action
	lda controller_a_last_frame_btns, x
	bne end

	; Call check_aerial_inputs
	;  If it does not change the player state, go to falling state
	;  so that any button press makes the player falls from revival
	;  platform
	jsr check_aerial_inputs
	lda player_a_state, x
	cmp #SINBAD_STATE_RESPAWN
	bne end

	jsr sinbad_start_falling

	end:
	rts
.)

sinbad_start_side_tilt:
.(
	; Set the appropriate animation
	lda #<anim_sinbad_side_tilt
	sta tmpfield13
	lda #>anim_sinbad_side_tilt
	sta tmpfield14
	jsr set_player_animation

	; Set the player's state
	lda #SINBAD_STATE_SIDE_TILT
	sta player_a_state, x

	; Initialize the clock
	lda #0
	sta player_a_state_clock,x

	; Set initial velocity
	lda #$fd
	sta player_a_velocity_v, x
	lda #$80
	sta player_a_velocity_v_low, x
	lda player_a_direction, x
	beq set_velocity_left
	lda #$04
	sta player_a_velocity_h, x
	jmp end_set_velocity
	set_velocity_left:
	lda #$fb
	sta player_a_velocity_h, x
	end_set_velocity:
	lda #$80
	sta player_a_velocity_h_low, x

	rts
.)

; Update a player that is performing a side tilt
;  register X must contain the player number
#define STATE_SINBAD_SIDE_TILT_DURATION #21
sinbad_tick_side_tilt:
.(
	inc player_a_state_clock, x

	lda player_a_state_clock, x
	cmp STATE_SINBAD_SIDE_TILT_DURATION
	bne update_velocity
		jmp sinbad_start_inactive_state
		; No return, jump to subroutine

	update_velocity:
		lda #$01
		sta tmpfield3
		lda #$00
		sta tmpfield4
		sta tmpfield1
		sta tmpfield2
		lda #$80
		sta tmpfield5
		jsr merge_to_player_velocity

	end:
	rts
.)

.(
	SINBAD_GROUNDED_SPECIAL_CHARGE_DURATION = 20
	duration_table(SINBAD_GROUNDED_SPECIAL_CHARGE_DURATION)

	&sinbad_start_special:
	.(
		; Set the appropriate animation
		lda #<anim_sinbad_special_charge
		sta tmpfield13
		lda #>anim_sinbad_special_charge
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
		ldy #SYSTEM_INDEX
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
		.byt 2*anim_sinbad_special_dur_pal, 2*anim_sinbad_special_dur_ntsc

	&sinbad_start_special_strike:
	.(

		; Set the appropriate animation
		lda #<anim_sinbad_special
		sta tmpfield13
		lda #>anim_sinbad_special
		sta tmpfield14
		jsr set_player_animation

		; Set the player's state
		lda #SINBAD_STATE_SPECIAL_STRIKE
		sta player_a_state, x

		; Place the player above ground
		lda player_a_y, x
		sec
		sbc #$10
		sta player_a_y, x

		; Initialize the clock
		ldy #SYSTEM_INDEX
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

sinbad_start_side_special:
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
	lda #<anim_sinbad_side_special_charge
	sta tmpfield13
	lda #>anim_sinbad_side_special_charge
	sta tmpfield14
	jsr set_player_animation

	rts
.)

#define STATE_SINBAD_SIDE_SPECIAL_PREPARATION_DURATION #120
sinbad_tick_side_special:
.(
	; Tick clock
	inc player_a_state_clock, x

	; Move if the substate is set to moving
	lda player_a_state_field1, x
	bne moving

	; Check if there is reason to begin to move
	lda player_a_state_clock, x
	cmp STATE_SINBAD_SIDE_SPECIAL_PREPARATION_DURATION
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
		lda player_a_state_clock, x
		lsr
		lsr
		lsr
		clc
		adc #5
		sta player_a_state_field2, x

		; Set the movement animation
		lda #<anim_sinbad_side_special_jump
		sta tmpfield13
		lda #>anim_sinbad_side_special_jump
		sta tmpfield14
		jsr set_player_animation

		; Reset clock
		lda #0
		sta player_a_state_clock, x

	moving:
		; Set vertical velocity (fixed)
		lda #$ff
		sta player_a_velocity_v, x
		lda #$80
		sta player_a_velocity_v_low, x

		; Set horizontal velocity (depending on direction)
		lda player_a_direction, x
		cmp DIRECTION_LEFT
		bne right_velocity
		lda #$fc
		jmp set_h_velocity
		right_velocity:
		lda #$04
		set_h_velocity:
		sta player_a_velocity_h, x
		lda #$00
		sta player_a_velocity_h_low, x

	; After move's time is out, go to helpless state
	lda player_a_state_clock, x
	cmp player_a_state_field2, x
	bne end
	jsr sinbad_start_helpless

	end:
	rts
.)

sinbad_start_helpless:
.(
	; Set state
	lda #SINBAD_STATE_HELPLESS
	sta player_a_state, x

	; Fallthrough to set the animation
.)
set_helpless_animation:
.(
	; Set the appropriate animation
	lda #<anim_sinbad_helpless
	sta tmpfield13
	lda #>anim_sinbad_helpless
	sta tmpfield14
	jsr set_player_animation

	rts
.)

sinbad_tick_helpless:
.(
	jsr sinbad_tick_falling
	rts
.)

sinbad_input_helpless:
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

sinbad_start_landing:
.(
	jsr sinbad_global_onground

	; Set state
	lda #SINBAD_STATE_LANDING
	sta player_a_state, x

	; Reset clock
	lda #0
	sta player_a_state_clock, x

	; Cap initial velocity
	lda player_a_velocity_h, x
	jsr absolute_a
	cmp #$03
	bcs set_cap
	jmp set_landing_animation
	set_cap:
	lda player_a_velocity_h, x
	bmi negative_cap
	lda #$02
	sta player_a_velocity_h, x
	lda #$00
	sta player_a_velocity_h_low, x
	jmp set_landing_animation
	negative_cap:
	lda #$fe
	sta player_a_velocity_h, x
	lda #$00
	sta player_a_velocity_h_low, x

	; Fallthrough to set the animation
.)
set_landing_animation:
.(
	; Set the appropriate animation
	lda #<anim_sinbad_landing
	sta tmpfield13
	lda #>anim_sinbad_landing
	sta tmpfield14
	jsr set_player_animation

	rts
.)

#define STATE_SINBAD_LANDING_DURATION #6
sinbad_tick_landing:
.(
	; Tick clock
	inc player_a_state_clock, x

	; Do not move, velocity tends toward vector (0,0)
	lda #$00
	sta tmpfield4
	sta tmpfield3
	sta tmpfield2
	sta tmpfield1
	lda #SINBAD_GROUND_FRICTION_STRENGTH
	sta tmpfield5
	jsr merge_to_player_velocity

	; After move's time is out, go to standing state
	lda player_a_state_clock, x
	cmp STATE_SINBAD_LANDING_DURATION
	bne end
		jmp sinbad_start_inactive_state

	end:
	rts
.)

sinbad_start_crashing:
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
	lda #<anim_sinbad_crashing
	sta tmpfield13
	lda #>anim_sinbad_crashing
	sta tmpfield14
	jsr set_player_animation

	; Play crash sound
	jsr audio_play_crash

	rts
.)

#define STATE_SINBAD_CRASHING_DURATION #30
sinbad_tick_crashing:
.(
	; Tick clock
	inc player_a_state_clock, x

	; Do not move, velocity tends toward vector (0,0)
	lda #$00
	sta tmpfield4
	sta tmpfield3
	sta tmpfield2
	sta tmpfield1
	lda #SINBAD_GROUND_FRICTION_STRENGTH*2
	sta tmpfield5
	jsr merge_to_player_velocity

	; After move's time is out, go to standing state
	lda player_a_state_clock, x
	cmp STATE_SINBAD_CRASHING_DURATION
	bne end
		jmp sinbad_start_inactive_state

	end:
	rts
.)

sinbad_start_down_tilt:
.(
	; Set state
	lda #SINBAD_STATE_DOWN_TILT
	sta player_a_state, x

	; Reset clock
	lda #0
	sta player_a_state_clock, x

	; Fallthrough to set the animation
.)
set_down_tilt_animation:
.(
	; Set the appropriate animation
	lda #<anim_sinbad_down_tilt
	sta tmpfield13
	lda #>anim_sinbad_down_tilt
	sta tmpfield14
	jsr set_player_animation

	rts
.)

#define STATE_SINBAD_DOWNTILT_DURATION #21
sinbad_tick_down_tilt:
.(
	; Tick clock
	inc player_a_state_clock, x

	; Do not move, velocity tends toward vector (0,0)
	lda #$00
	sta tmpfield4
	sta tmpfield3
	sta tmpfield2
	sta tmpfield1
	lda #$80
	sta tmpfield5
	jsr merge_to_player_velocity

	; After move's time is out, go to standing state
	lda player_a_state_clock, x
	cmp STATE_SINBAD_DOWNTILT_DURATION
	bne end
		jmp sinbad_start_inactive_state

	end:
	rts
.)

sinbad_start_aerial_side:
.(
	; Set state
	lda #SINBAD_STATE_AERIAL_SIDE
	sta player_a_state, x

	; Reset clock
	lda #0
	sta player_a_state_clock, x

	; Fallthrough to set the animation
.)
set_aerial_side_animation:
.(
	; Set the appropriate animation
	lda #<anim_sinbad_aerial_side
	sta tmpfield13
	lda #>anim_sinbad_aerial_side
	sta tmpfield14
	jsr set_player_animation

	rts
.)

#define STATE_SINBAD_AERIAL_SIDE_DURATION #25
sinbad_tick_aerial_side:
.(
	jsr apply_player_gravity

	; Wait for move's timeout
	inc player_a_state_clock, x
	lda player_a_state_clock, x
	cmp STATE_SINBAD_AERIAL_SIDE_DURATION
	bne end
		jsr sinbad_start_falling

	end:
	rts
.)

sinbad_start_aerial_down:
.(
	; Set state
	lda #SINBAD_STATE_AERIAL_DOWN
	sta player_a_state, x

	; Reset clock
	lda #0
	sta player_a_state_clock, x

	; Cancel fastfall
	lda #DEFAULT_GRAVITY     ; Do nothing if not in fast fall
	cmp player_a_gravity, x  ;
	beq end_cancel_fast_fall ;

	sta player_a_gravity, x ; Reset gravity

	lda #DEFAULT_GRAVITY           ;
	sta player_a_velocity_v, x     ; Reset fall speed
	lda #0                         ;
	sta player_a_velocity_v_low, x ;

	end_cancel_fast_fall:

	; Fallthrough to set the animation
.)
set_aerial_down_animation:
.(
	; Set the appropriate animation
	lda #<anim_sinbad_aerial_down
	sta tmpfield13
	lda #>anim_sinbad_aerial_down
	sta tmpfield14
	jsr set_player_animation

	rts
.)

#define STATE_SINBAD_AERIAL_DOWN_DURATION #14
sinbad_tick_aerial_down:
.(
	jsr apply_player_gravity

	; Wait for move's timeout
	inc player_a_state_clock, x
	lda player_a_state_clock, x
	cmp STATE_SINBAD_AERIAL_DOWN_DURATION
	bne end
	jsr sinbad_start_falling

	end:
	rts
.)

sinbad_start_aerial_up:
.(
	; Set state
	lda #SINBAD_STATE_AERIAL_UP
	sta player_a_state, x

	; Reset clock
	lda #0
	sta player_a_state_clock, x

	; Fallthrough to set the animation
.)
set_aerial_up_animation:
.(
	; Set the appropriate animation
	lda #<anim_sinbad_aerial_up
	sta tmpfield13
	lda #>anim_sinbad_aerial_up
	sta tmpfield14
	jsr set_player_animation

	rts
.)

#define STATE_SINBAD_AERIAL_UP_DURATION #32
sinbad_tick_aerial_up:
.(
	jsr apply_player_gravity

	; Wait for move's timeout
	inc player_a_state_clock, x
	lda player_a_state_clock, x
	cmp STATE_SINBAD_AERIAL_UP_DURATION
	bne end
	jsr sinbad_start_falling

	end:
	rts
.)

sinbad_start_aerial_neutral:
.(
	; Set state
	lda #SINBAD_STATE_AERIAL_NEUTRAL
	sta player_a_state, x

	; Reset clock
	lda #0
	sta player_a_state_clock, x

	; Fallthrough to set the animation
.)
set_aerial_neutral_animation:
.(
	; Set the appropriate animation
	lda #<anim_sinbad_aerial_neutral
	sta tmpfield13
	lda #>anim_sinbad_aerial_neutral
	sta tmpfield14
	jsr set_player_animation

	rts
.)

#define STATE_SINBAD_AERIAL_NEUTRAL_DURATION #12
sinbad_tick_aerial_neutral:
.(
	jsr apply_player_gravity

	; Wait for move's timeout
	inc player_a_state_clock, x
	lda player_a_state_clock, x
	cmp STATE_SINBAD_AERIAL_NEUTRAL_DURATION
	bne end
		jsr sinbad_start_falling

	end:
	rts
.)

sinbad_start_aerial_spe:
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
	lda #<anim_sinbad_aerial_spe
	sta tmpfield13
	lda #>anim_sinbad_aerial_spe
	sta tmpfield14
	jsr set_player_animation

	rts
.)

sinbad_tick_aerial_spe:
.(
	jsr aerial_directional_influence

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
	lda #$01
	sta tmpfield3
	lda #$00
	sta tmpfield1
	lda #$10
	sta tmpfield5
	jsr merge_to_player_velocity

	rts
.)

sinbad_input_aerial_spe:
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

sinbad_start_spe_up:
.(
	; Set state
	lda #SINBAD_STATE_SPE_UP
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
set_spe_up_animation:
.(
	; Set the appropriate animation
	lda #<anim_sinbad_spe_up_prepare
	sta tmpfield13
	lda #>anim_sinbad_spe_up_prepare
	sta tmpfield14
	jsr set_player_animation

	rts
.)

#define STATE_SINBAD_SPE_UP_PREPARATION_DURATION #3
sinbad_tick_spe_up:
.(
	; Tick clock
	inc player_a_state_clock, x

	; Move if the substate is set to moving
	lda player_a_state_field1, x
	bne moving

	; Check if there is reason to begin to move
	lda player_a_state_clock, x
	cmp STATE_SINBAD_SPE_UP_PREPARATION_DURATION
	bcs start_moving

	not_moving:
		jmp end

	start_moving:
		; Set substate to "moving"
		lda #$01
		sta player_a_state_field1, x

		; Set jumping velocity
		lda #$fa
		sta player_a_velocity_v, x
		lda #$00
		sta player_a_velocity_v_low, x

		; Set the movement animation
		lda #<anim_sinbad_spe_up_jump
		sta tmpfield13
		lda #>anim_sinbad_spe_up_jump
		sta tmpfield14
		jsr set_player_animation

	moving:
		; Return to falling when the top is reached
		lda player_a_velocity_v, x
		beq top_reached
		bpl top_reached

			; The top is not reached, stay in special upward state but apply gravity and directional influence
			jsr aerial_directional_influence
			jsr apply_player_gravity
			jmp end

		top_reached:
			jsr sinbad_start_helpless
			jmp end

	end:
	rts
.)

sinbad_start_spe_down:
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
	lda #<anim_sinbad_spe_down
	sta tmpfield13
	lda #>anim_sinbad_spe_down
	sta tmpfield14
	jsr set_player_animation

	rts
.)

#define STATE_SINBAD_SPE_DOWN_DURATION #21
sinbad_tick_spe_down:
.(
	lda player_a_grounded, x
	beq air_friction
		ground_friction:
			lda #$00
			sta tmpfield4
			sta tmpfield3
			sta tmpfield2
			sta tmpfield1
			lda #SINBAD_GROUND_FRICTION_STRENGTH/3
			sta tmpfield5
			jsr merge_to_player_velocity
			jmp end_friction
		air_friction:
			jsr sinbad_apply_air_friction
			jsr apply_player_gravity
			; Fallthrough
	end_friction:

	; Wait for move's timeout
	inc player_a_state_clock, x
	lda player_a_state_clock, x
	cmp STATE_SINBAD_SPE_DOWN_DURATION
	bne end

	; Return to falling or standing
	jmp sinbad_start_inactive_state
	; No return, jump to subroutine

	end:
	rts
.)

sinbad_start_up_tilt:
.(
	; Set state
	lda #SINBAD_STATE_UP_TILT
	sta player_a_state, x

	; Reset clock
	lda #0
	sta player_a_state_clock, x

	; Fallthrough to set the animation
.)
set_up_tilt_animation:
.(
	; Set the appropriate animation
	lda #<anim_sinbad_up_tilt
	sta tmpfield13
	lda #>anim_sinbad_up_tilt
	sta tmpfield14
	jsr set_player_animation

	rts
.)

#define STATE_SINBAD_UPTILT_DURATION #20
sinbad_tick_up_tilt:
.(
	; Do not move, velocity tends toward vector (0,0)
	lda #$00
	sta tmpfield4
	sta tmpfield3
	sta tmpfield2
	sta tmpfield1
	lda #$80
	sta tmpfield5
	jsr merge_to_player_velocity

	; After move's time is out, go to standing state
	inc player_a_state_clock, x
	lda player_a_state_clock, x
	cmp STATE_SINBAD_UPTILT_DURATION
	bne end
		jmp sinbad_start_inactive_state

	end:
	rts
.)

sinbad_start_shielding:
.(
	; Set state
	lda #SINBAD_STATE_SHIELDING
	sta player_a_state, x

	; Reset clock
	lda #0
	sta player_a_state_clock, x

	; Fallthrough to set the animation
.)
set_shielding_animation:
.(
	; Set the appropriate animation
	lda #<anim_sinbad_shielding_full
	sta tmpfield13
	lda #>anim_sinbad_shielding_full
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

sinbad_tick_shielding:
.(
	; Tick clock
	lda player_a_state_clock, x
	cmp #PLAYER_DOWN_TAP_MAX_DURATION
	bcs end_tick
		inc player_a_state_clock, x
	end_tick:

	rts
.)

sinbad_input_shielding:
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

		lda #PLAYER_DOWN_TAP_MAX_DURATION
		cmp player_a_state_clock, x
		beq shieldlag
		bcc shieldlag
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

sinbad_hurt_shielding:
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
		lda #<anim_sinbad_shielding_partial
		sta tmpfield13
		lda #>anim_sinbad_shielding_partial
		jmp still_shield

	limit_shield:
		lda #<anim_sinbad_shielding_limit
		sta tmpfield13
		lda #>anim_sinbad_shielding_limit

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

sinbad_start_shieldlag:
.(
	; Set state
	lda #SINBAD_STATE_SHIELDLAG
	sta player_a_state, x

	; Reset clock
	lda #0
	sta player_a_state_clock, x

	; Fallthrough to set the animation
.)
set_shieldlag_animation:
.(
	; Set the appropriate animation
	lda #<anim_sinbad_shielding_remove
	sta tmpfield13
	lda #>anim_sinbad_shielding_remove
	sta tmpfield14
	jsr set_player_animation

	rts
.)

#define STATE_SINBAD_SHIELDLAG_DURATION #8
sinbad_tick_shieldlag:
.(
	; Do not move, velocity tends toward vector (0,0)
	lda #$00
	sta tmpfield4
	sta tmpfield3
	sta tmpfield2
	sta tmpfield1
	lda #$80
	sta tmpfield5
	jsr merge_to_player_velocity

	; After move's time is out, go to standing state
	inc player_a_state_clock, x
	lda player_a_state_clock, x
	cmp STATE_SINBAD_SHIELDLAG_DURATION
	bne end
		jmp sinbad_start_inactive_state

	end:
	rts
.)

sinbad_start_innexistant:
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
	jsr set_player_animation

	rts
.)

sinbad_tick_innexistant:
.(
	rts
.)

sinbad_start_spawn:
.(
	; Hack - there is no ensured call to a character init function
	;        expect start_spawn to be called once at the begining of a game
	jsr sinbad_init

	; Set the player's state
	lda #SINBAD_STATE_SPAWN
	sta player_a_state, x

	; Reset clock
	lda #0
	sta player_a_state_clock, x

	; Fallthrough to set the animation
.)
set_spawn_animation:
.(
	; Set the appropriate animation
	lda #<anim_sinbad_spawn
	sta tmpfield13
	lda #>anim_sinbad_spawn
	sta tmpfield14
	jsr set_player_animation

	rts
.)

#define STATE_SINBAD_SPAWN_DURATION #50
sinbad_tick_spawn:
.(
	inc player_a_state_clock, x
	lda player_a_state_clock, x
	cmp STATE_SINBAD_SPAWN_DURATION
	bne end
		jmp sinbad_start_standing
		; No return, jump to subroutine

	end:
	rts
.)

sinbad_start_walljumping:
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

	; Set the appropriate animation
	;TODO specific animation
	lda #<anim_sinbad_jumping
	sta tmpfield13
	lda #>anim_sinbad_jumping
	sta tmpfield14
	jsr set_player_animation

	end:
	rts
.)

SINBAD_WALL_JUMP_SQUAT_END = 4
sinbad_tick_walljumping:
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
		lda #$fb
		sta player_a_velocity_v, x
		lda #$80
		sta player_a_velocity_v_low, x

		; Horizontal velocity
		lda player_a_direction, x
		;cmp DIRECTION_LEFT ; useless while DIRECTION_LEFT is $00
		bne jump_right
			jump_left:
				lda #$ff
				jmp end_jump_direction
			jump_right:
				lda #1
		end_jump_direction:
		sta player_a_velocity_h, x

		;jmp end ; useless, fallthrough

	end:
	rts
.)

sinbad_input_walljumping:
.(
	; The jump is cancellable by aerial movements, but only after preparation
	lda #SINBAD_WALL_JUMP_SQUAT_END
	cmp player_a_state_clock, x
	bcs grounded
		not_grounded:
			jmp check_aerial_inputs
			; no return, jump to a subroutine
	grounded:
	rts
.)

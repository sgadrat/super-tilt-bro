KIKI_STATE_THROWN = 0
KIKI_STATE_RESPAWN = 1
KIKI_STATE_INNEXISTANT = 2
KIKI_STATE_SPAWN = 3
KIKI_STATE_IDLE = 4
KIKI_STATE_RUNNING = 5
KIKI_STATE_FALLING = 6
KIKI_STATE_LANDING = 7

KIKI_AIR_FRICTION_STRENGTH = 7
KIKI_AERIAL_DIRECTIONAL_INFLUENCE_STRENGTH = $80
KIKI_AERIAL_SPEED = $0100

KIKI_GROUND_FRICTION_STRENGTH = $40

kiki_aerial_directional_influence:
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

	jmp air_friction

	go_left:
		; Go to the left
		lda #<-KIKI_AERIAL_SPEED
		sta tmpfield6
		lda #>-KIKI_AERIAL_SPEED
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
		lda #<-KIKI_AERIAL_SPEED
		sta merged_h_low
		lda #>-KIKI_AERIAL_SPEED
		sta merged_h_high
		lda #KIKI_AERIAL_DIRECTIONAL_INFLUENCE_STRENGTH
		sta merge_step
		jsr merge_to_player_velocity
		jmp end

	go_right:
		; Go to the right
		lda player_a_velocity_h_low, x
		sta tmpfield6
		lda player_a_velocity_h, x
		sta tmpfield7
		lda #<KIKI_AERIAL_SPEED
		sta tmpfield8
		lda #>KIKI_AERIAL_SPEED
		sta tmpfield9
		jsr signed_cmp
		bpl end

		lda player_a_velocity_v_low, x
		sta merged_v_low
		lda player_a_velocity_v, x
		sta merged_v_high
		lda #<KIKI_AERIAL_SPEED
		sta merged_h_low
		lda #>KIKI_AERIAL_SPEED
		sta merged_h_high
		lda #KIKI_AERIAL_DIRECTIONAL_INFLUENCE_STRENGTH
		sta merge_step
		jsr merge_to_player_velocity
		jmp end

	air_friction:
		; Apply air friction
		lda player_a_velocity_v_low, x
		sta merged_v_low
		lda player_a_velocity_v, x
		sta merged_v_high
		lda #$00
		sta merged_h_low
		sta merged_h_high
		lda #KIKI_AIR_FRICTION_STRENGTH
		sta merge_step
		jsr merge_to_player_velocity

	end:
	rts
.)

; Change the player's state if an aerial move is input on the controller
;  register X - Player number
;
;  Overwrites tmpfield15 and tmpfield2 plus the ones overriten by the state starting subroutine
kiki_check_aerial_inputs:
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
		lda #14
		sta tmpfield3
		jmp controller_callbacks

		;rts ; useless, controller_callbacks returns to caller

		; Fast fall, gravity * 1.5
		fast_fall:
		.(
			lda #DEFAULT_GRAVITY*2-DEFAULT_GRAVITY/2
			sta player_a_gravity, x
			sta player_a_velocity_v, x
			lda #$00
			sta player_a_velocity_v_low, x
			rts
		.)

		; If no input, unmark the input flag and return
		no_input:
		.(
			lda #$00
			sta input_marker
			;rts ; Fallthrough to return
		.)

		end:
		rts

		; Impactful controller states and associated callbacks
		; Note - We have to put subroutines as callbacks since we do not expect a return unless we used the default callback
		; TODO callbacks set to no_input are to be implemented (except the default callback)
		controller_inputs:
		.byt CONTROLLER_INPUT_SPECIAL_RIGHT, CONTROLLER_INPUT_SPECIAL_LEFT, CONTROLLER_INPUT_JUMP,         CONTROLLER_INPUT_JUMP_RIGHT,  CONTROLLER_INPUT_JUMP_LEFT
		.byt CONTROLLER_INPUT_ATTACK_LEFT,   CONTROLLER_INPUT_ATTACK_RIGHT, CONTROLLER_INPUT_DOWN_TILT,    CONTROLLER_INPUT_ATTACK_UP,   CONTROLLER_INPUT_JAB
		.byt CONTROLLER_INPUT_SPECIAL,       CONTROLLER_INPUT_SPECIAL_UP,   CONTROLLER_INPUT_SPECIAL_DOWN, CONTROLLER_INPUT_TECH
		controller_callbacks_lo:
		.byt <no_input,                      <no_input,                     <no_input,                     <no_input,                    <no_input
		.byt <no_input,                      <no_input,                     <no_input,                     <no_input,                    <no_input
		.byt <no_input,                      <no_input,                     <no_input,                     <fast_fall
		controller_callbacks_hi:
		.byt >no_input,                      >no_input,                     >no_input,                     >no_input,                    >no_input
		.byt >no_input,                      >no_input,                     >no_input,                     >no_input,                    >no_input
		.byt >no_input,                      >no_input,                     >no_input,                     >fast_fall
		controller_default_callback:
		.word no_input
	.)
.)

kiki_start_thrown:
.(
	; Set the player's state
	lda #KIKI_STATE_THROWN
	sta player_a_state, x

	; Initialize tech counter
	lda #0
	sta player_a_state_field1, x

	; Set the appropriate animation
	lda #<kiki_anim_thrown
	sta tmpfield13
	lda #>kiki_anim_thrown
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

; To tech successfully the tech must be input at maximum KIKI_TECH_MAX_FRAMES_BEFORE_COLLISION frames before hitting the ground.
; After expiration of a tech input, it is not possible to input another tech for KIKI_TECH_NB_FORBIDDEN_FRAMES frames.
KIKI_TECH_MAX_FRAMES_BEFORE_COLLISION = 10
KIKI_TECH_NB_FORBIDDEN_FRAMES = 60
kiki_tick_thrown:
.(
	; Update velocity
	lda player_a_hitstun, x
	bne gravity
	jsr kiki_aerial_directional_influence
	gravity:
	jsr apply_player_gravity

	; Decrement tech counter (to zero minimum)
	lda player_a_state_field1, x
	beq end_dec_tech_cnt
	dec player_a_state_field1, x
	end_dec_tech_cnt:

	rts
.)

kiki_input_thrown:
.(
	;TODO tech and aerial input handling
	rts
.)

kiki_onground_thrown:
.(
	;TODO choose between states landing and crashing
	jsr kiki_start_idle
	rts
.)

kiki_start_respawn:
.(
	; Set the player's state
	lda #KIKI_STATE_RESPAWN
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

	; Initialise state's timer
	lda #PLAYER_RESPAWN_MAX_DURATION
	sta player_a_state_field1, x

	; Set the appropriate animation
	lda #<kiki_anim_respawn
	sta tmpfield13
	lda #>kiki_anim_respawn
	sta tmpfield14
	jsr set_player_animation

	rts
.)


kiki_tick_respawn:
.(
	; Check for timeout
	dec player_a_state_field1, x
	bne end
	jsr kiki_start_falling

	end:
	rts
.)

kiki_input_respawn:
.(
	; Avoid doing anything until controller has returned to neutral since after
	; death the player can release buttons without expecting to take action
	lda controller_a_last_frame_btns, x
	bne end

		; Call kiki_check_aerial_inputs
		;  If it does not change the player state, go to falling state
		;  so that any button press makes the player falls from revival
		;  platform
		jsr kiki_check_aerial_inputs
		lda player_a_state, x
		cmp #KIKI_STATE_RESPAWN
		bne end

			jsr kiki_start_falling

	end:
	rts
.)


kiki_start_innexistant:
.(
	; Set the player's state
	lda #KIKI_STATE_INNEXISTANT
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

	; Set the appropriate animation
	lda #<anim_invisible
	sta tmpfield13
	lda #>anim_invisible
	sta tmpfield14
	jsr set_player_animation

	rts
.)

kiki_tick_innexistant:
.(
	rts
.)


kiki_start_spawn:
.(
	; Set the player's state
	lda #KIKI_STATE_SPAWN
	sta player_a_state, x

	; Reset clock
	lda #0
	sta player_a_state_clock, x

	; Set the appropriate animation
	lda #<kiki_anim_spawn
	sta tmpfield13
	lda #>kiki_anim_spawn
	sta tmpfield14
	jsr set_player_animation

	rts
.)

kiki_tick_spawn:
.(
	KIKI_STATE_SPAWN_DURATION = 50

	inc player_a_state_clock, x
	lda player_a_state_clock, x
	cmp #KIKI_STATE_SPAWN_DURATION
	bne end
		jsr kiki_start_idle

	end:
	rts
.)


kiki_start_idle:
.(
	; Set the player's state
	lda #KIKI_STATE_IDLE
	sta player_a_state, x

	; Set the appropriate animation
	lda #<kiki_anim_idle
	sta tmpfield13
	lda #>kiki_anim_idle
	sta tmpfield14
	jsr set_player_animation

	rts
.)

kiki_tick_idle:
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

	; Force handling directional controls
	;   we want to start running even if button presses where maintained from previous state)
	lda controller_a_btns, x
	cmp #CONTROLLER_INPUT_LEFT
	bne no_left
	jsr kiki_input_idle_left
	jmp end
	no_left:
	cmp #CONTROLLER_INPUT_RIGHT
	bne end
	jsr kiki_input_idle_right

	end:
	rts
.)

kiki_input_idle:
.(
	; Do not handle any input if under hitstun
	lda player_a_hitstun, x
	bne end

		; Check state changes
		lda #<(input_table+1)
		sta tmpfield1
		lda #>(input_table+1)
		sta tmpfield2
		lda input_table
		sta tmpfield3
		jmp controller_callbacks

	end:
	rts

	input_table:
	.(
		table_length:
		.byt 2
		controller_inputs:
		.byt CONTROLLER_INPUT_LEFT, CONTROLLER_INPUT_RIGHT
		controller_callbacks_lsb:
		.byt <kiki_input_idle_left, <kiki_input_idle_right
		controller_callbacks_msb:
		.byt >kiki_input_idle_left, >kiki_input_idle_right
		controller_default_callback:
		.word end
	.)
.)

kiki_input_idle_left:
.(
	lda DIRECTION_LEFT
	sta player_a_direction, x
	jsr kiki_start_running
	rts
.)

kiki_input_idle_right:
.(
	lda DIRECTION_RIGHT
	sta player_a_direction, x
	jsr kiki_start_running
	rts
.)


KIKI_RUNNING_INITIAL_VELOCITY = $0100
KIKI_RUNNING_MAX_VELOCITY = $0180
KIKI_RUNNING_ACCELERATION = $40
kiki_start_running:
.(
	; Set the player's state
	lda #KIKI_STATE_RUNNING
	sta player_a_state, x

	; Set initial velocity
	lda player_a_direction, x
	cmp DIRECTION_LEFT
	bne direction_right
		lda #<-KIKI_RUNNING_INITIAL_VELOCITY
		sta player_a_velocity_h_low, x
		lda #>-KIKI_RUNNING_INITIAL_VELOCITY
		jmp set_high_byte
	direction_right:
		lda #<KIKI_RUNNING_INITIAL_VELOCITY
		sta player_a_velocity_h_low, x
		lda #>KIKI_RUNNING_INITIAL_VELOCITY
	set_high_byte:
	sta player_a_velocity_h, x

	; Fallthrough to set animation
.)
kiki_set_running_animation:
.(
	; Set the appropriate animation
	lda #<kiki_anim_run
	sta tmpfield13
	lda #>kiki_anim_run
	sta tmpfield14
	jsr set_player_animation

	rts
.)

kiki_tick_running:
.(
	; Update player's velocity dependeing on his direction
	lda player_a_direction, x
	beq run_left

		; Running right, velocity tends toward vector max velocity
		lda #>KIKI_RUNNING_MAX_VELOCITY
		sta tmpfield4
		lda #<KIKI_RUNNING_MAX_VELOCITY
		jmp update_volicty

	run_left:
		; Running left, velocity tends toward vector "-1 * max volcity"
		lda #>-KIKI_RUNNING_MAX_VELOCITY
		sta tmpfield4
		lda #<-KIKI_RUNNING_MAX_VELOCITY

	update_volicty:
		sta tmpfield2
		lda #0
		sta tmpfield3
		sta tmpfield1
		lda #KIKI_RUNNING_ACCELERATION
		sta tmpfield5
		jsr merge_to_player_velocity

	end:
	rts
.)

kiki_input_running:
.(
	; If in hitstun, stop running
	lda player_a_hitstun, x
	beq take_input
		jsr kiki_start_idle
		jmp end
	take_input:

		; Check state changes
		lda #<(input_table+1)
		sta tmpfield1
		lda #>(input_table+1)
		sta tmpfield2
		lda input_table
		sta tmpfield3
		jmp controller_callbacks

	end:
	rts

	kiki_input_running_left:
	.(
		rts
	.)

	kiki_input_running_right:
	.(
		rts
	.)

	input_table:
	.(
		table_length:
		.byt 2
		controller_inputs:
		.byt CONTROLLER_INPUT_LEFT,    CONTROLLER_INPUT_RIGHT
		controller_callbacks_lsb:
		.byt <kiki_input_running_left, <kiki_input_running_right
		controller_callbacks_msb:
		.byt >kiki_input_running_left, >kiki_input_running_right
		controller_default_callback:
		.word kiki_start_idle
	.)
.)


kiki_start_falling:
.(
	lda #KIKI_STATE_FALLING
	sta player_a_state, x

	; Set the appropriate animation
	lda #<kiki_anim_falling
	sta tmpfield13
	lda #>kiki_anim_falling
	sta tmpfield14
	jsr set_player_animation

	rts
.)

kiki_tick_falling:
.(
	jsr kiki_aerial_directional_influence
	jsr apply_player_gravity
	rts
.)


kiki_start_landing:
.(
	KIKI_LANDING_SPEED_CAP = $0200

	; Set state
	lda #KIKI_STATE_LANDING
	sta player_a_state, x

	; Reset clock
	lda #0
	sta player_a_state_clock, x

	; Cap initial velocity
#if (KIKI_LANDING_SPEED_CAP & $00ff) <> 0
#error following condition expects round number for kiki landing speed cap
#endif
	lda player_a_velocity_h, x
	jsr absolute_a
	cmp #>(KIKI_LANDING_SPEED_CAP+$0100)
	bcs set_cap

		jmp kiki_set_landing_animation

	set_cap:
		lda player_a_velocity_h, x
		bmi negative_cap
			lda #>KIKI_LANDING_SPEED_CAP
			sta player_a_velocity_h, x
			lda #<KIKI_LANDING_SPEED_CAP
			sta player_a_velocity_h_low, x
			jmp kiki_set_landing_animation
		negative_cap:
			lda #>(-KIKI_LANDING_SPEED_CAP)
			sta player_a_velocity_h, x
			lda #<(-KIKI_LANDING_SPEED_CAP)
			sta player_a_velocity_h_low, x

	; Fallthrough to set the animation
.)
kiki_set_landing_animation:
.(
	; Set the appropriate animation
	lda #<kiki_anim_landing
	sta tmpfield13
	lda #>kiki_anim_landing
	sta tmpfield14
	jsr set_player_animation

	rts
.)

kiki_tick_landing:
.(
	KIKI_STATE_LANDING_DURATION = 6

	; Tick clock
	inc player_a_state_clock, x

	; Do not move, velocity tends toward vector (0,0)
	lda #$00
	sta tmpfield4
	sta tmpfield3
	sta tmpfield2
	sta tmpfield1
	lda #KIKI_GROUND_FRICTION_STRENGTH
	sta tmpfield5
	jsr merge_to_player_velocity

	; After move's time is out, go to standing state
	lda player_a_state_clock, x
	cmp #KIKI_STATE_LANDING_DURATION
	bne end
	jsr kiki_start_idle

	end:
	rts
.)


kiki_start_helpless:
.(
	;TODO implement helpless falling
	jmp kiki_start_falling
.)

KIKI_STATE_THROWN = 0
KIKI_STATE_RESPAWN = 1
KIKI_STATE_INNEXISTANT = 2
KIKI_STATE_SPAWN = 3
KIKI_STATE_IDLE = 4
KIKI_STATE_RUNNING = 5

kiki_start_thrown:
.(
	; Set the player's state
	lda #KIKI_STATE_THROWN
	sta player_a_state, x

	; Set the appropriate animation
	lda #<kiki_anim_idle
	sta tmpfield13
	lda #>kiki_anim_idle
	sta tmpfield14
	jsr set_player_animation

	rts
.)

kiki_tick_thrown:
.(
	rts
.)


kiki_start_respawn:
.(
	; Set the player's state
	lda #KIKI_STATE_RESPAWN
	sta player_a_state, x

	; Set the appropriate animation
	lda #<kiki_anim_idle
	sta tmpfield13
	lda #>kiki_anim_idle
	sta tmpfield14
	jsr set_player_animation

	rts
.)

kiki_tick_respawn:
.(
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
	lda #<kiki_anim_idle
	sta tmpfield13
	lda #>kiki_anim_idle
	sta tmpfield14
	jsr set_player_animation

	rts
.)

kiki_tick_spawn:
.(
	KIKI_STATE_SPAWN_DURATION = 50

	inc player_a_state_clock, x
	lda player_a_state_clock, x
	cmp KIKI_STATE_SPAWN_DURATION
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
		jsr sinbad_start_standing
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

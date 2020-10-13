KIKI_STATE_THROWN = 0
KIKI_STATE_RESPAWN = 1
KIKI_STATE_INNEXISTANT = 2
KIKI_STATE_SPAWN = 3
KIKI_STATE_IDLE = 4
KIKI_STATE_RUNNING = 5
KIKI_STATE_FALLING = 6
KIKI_STATE_LANDING = 7
KIKI_STATE_CRASHING = 8
KIKI_STATE_HELPLESS = 9
KIKI_STATE_JUMPING = 10
KIKI_STATE_SHIELDING = 11
KIKI_STATE_SHIELDLAG = 12
KIKI_STATE_SIDE_TILT = 13
KIKI_STATE_SIDE_SPE = 14
KIKI_STATE_DOWN_SPE = 15
KIKI_STATE_UP_SPE = 16
KIKI_STATE_UP_TILT = 17
KIKI_STATE_UP_AERIAL = 18
KIKI_STATE_DOWN_TILT = 19
KIKI_STATE_DOWN_AERIAL = 20
KIKI_STATE_SIDE_AERIAL = 21
KIKI_STATE_JABBING = 22
KIKI_STATE_NEUTRAL_AERIAL = 23
KIKI_STATE_COUNTER_GUARD = 24
KIKI_STATE_COUNTER_STRIKE = 25

KIKI_AIR_FRICTION_STRENGTH = 7
KIKI_AERIAL_DIRECTIONAL_INFLUENCE_STRENGTH = $80
KIKI_AERIAL_SPEED = $0100
KIKI_FASTFALL_SPEED = $04
KIKI_PLATFORM_DURATION = 120

KIKI_GROUND_FRICTION_STRENGTH = $40

kiki_first_wall_sprite_per_player:
.byt INGAME_PLAYER_A_LAST_SPRITE-1, INGAME_PLAYER_B_LAST_SPRITE-1

kiki_last_anim_sprite_per_player:
.byt INGAME_PLAYER_A_LAST_SPRITE-2, INGAME_PLAYER_B_LAST_SPRITE-2

kiki_first_tile_index_per_player:
.byt CHARACTERS_CHARACTER_A_FIRST_TILE, CHARACTERS_CHARACTER_B_FIRST_TILE

kiki_a_platform_state = player_a_state_field3 ; aTTT TTTT - a, allowed to create a new platform - T, platform timer

kiki_init:
.(
	; Reserve two sprites for walls
	.(
		animation_state_vector = tmpfield2

		; Animation's last sprite num = animation's last sprite num - 2
		lda anim_last_sprite_num_per_player_lsb, x
		sta animation_state_vector
		lda anim_last_sprite_num_per_player_msb, x
		sta animation_state_vector+1

		ldy #0
		lda kiki_last_anim_sprite_per_player, x
		sta (animation_state_vector), y

		; Same for out of screen indicator
		lda oos_last_sprite_num_per_player_lsb, x
		sta animation_state_vector
		lda oos_last_sprite_num_per_player_msb, x
		sta animation_state_vector+1

		;ldy #0 ; useless, already set above
		lda kiki_last_anim_sprite_per_player, x
		sta (animation_state_vector), y
	.)

	; Init platform state
	.(
		lda #%10000000
		sta kiki_a_platform_state, x
	.)

	rts

	;TODO may be optmizable
	;     storing the index of the byte from player_a_animation, means one byte per player
	;     and only have to load it in y and access the byte in "absolute,Y" instead of "(indirect),Y"
	anim_last_sprite_num_per_player_msb:
		.byt >player_a_animation+ANIMATION_STATE_OFFSET_LAST_SPRITE_NUM
		.byt >player_b_animation+ANIMATION_STATE_OFFSET_LAST_SPRITE_NUM
	anim_last_sprite_num_per_player_lsb:
		.byt <player_a_animation+ANIMATION_STATE_OFFSET_LAST_SPRITE_NUM
		.byt <player_b_animation+ANIMATION_STATE_OFFSET_LAST_SPRITE_NUM

	oos_last_sprite_num_per_player_msb:
		.byt >player_a_out_of_screen_indicator+ANIMATION_STATE_OFFSET_LAST_SPRITE_NUM
		.byt >player_b_out_of_screen_indicator+ANIMATION_STATE_OFFSET_LAST_SPRITE_NUM
	oos_last_sprite_num_per_player_lsb:
		.byt <player_a_out_of_screen_indicator+ANIMATION_STATE_OFFSET_LAST_SPRITE_NUM
		.byt <player_b_out_of_screen_indicator+ANIMATION_STATE_OFFSET_LAST_SPRITE_NUM
.)

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
		lda #18
		sta tmpfield3
		jmp controller_callbacks

		;rts ; useless, controller_callbacks returns to caller

		; Fast fall, gravity * 1.5
		fast_fall:
		.(
			lda #KIKI_FASTFALL_SPEED
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
		controller_inputs:
		.byt CONTROLLER_INPUT_SPECIAL_RIGHT,  CONTROLLER_INPUT_SPECIAL_LEFT,     CONTROLLER_INPUT_JUMP,            CONTROLLER_INPUT_JUMP_RIGHT,  CONTROLLER_INPUT_JUMP_LEFT
		.byt CONTROLLER_INPUT_ATTACK_LEFT,    CONTROLLER_INPUT_ATTACK_RIGHT,     CONTROLLER_INPUT_DOWN_TILT,       CONTROLLER_INPUT_ATTACK_UP,   CONTROLLER_INPUT_JAB
		.byt CONTROLLER_INPUT_SPECIAL,        CONTROLLER_INPUT_SPECIAL_UP,       CONTROLLER_INPUT_SPECIAL_DOWN,    CONTROLLER_INPUT_TECH,        CONTROLLER_INPUT_ATTACK_UP_RIGHT
		.byt CONTROLLER_INPUT_ATTACK_UP_LEFT, CONTROLLER_INPUT_SPECIAL_UP_RIGHT, CONTROLLER_INPUT_SPECIAL_UP_LEFT
		controller_callbacks_lo:
		.byt <kiki_start_side_spe_right,      <kiki_start_side_spe_left,         <kiki_start_aerial_jumping,       <kiki_start_aerial_jumping,   <kiki_start_aerial_jumping
		.byt <kiki_start_side_aerial_left,    <kiki_start_side_aerial_right,     <kiki_start_down_aerial,          <kiki_start_up_aerial,        <kiki_start_neutral_aerial
		.byt <kiki_start_counter_guard,       <kiki_start_up_spe,                <kiki_start_down_spe,             <fast_fall,                   <kiki_start_up_aerial
		.byt <kiki_start_up_aerial,           <kiki_start_up_spe,                <kiki_start_up_spe
		controller_callbacks_hi:
		.byt >kiki_start_side_spe_right,      >kiki_start_side_spe_left,         >kiki_start_aerial_jumping,       >kiki_start_aerial_jumping,   >kiki_start_aerial_jumping
		.byt >kiki_start_side_aerial_left,    >kiki_start_side_aerial_right,     >kiki_start_down_aerial,          >kiki_start_up_aerial,        >kiki_start_neutral_aerial
		.byt >kiki_start_counter_guard,       >kiki_start_up_spe,                >kiki_start_down_spe,             >fast_fall,                   >kiki_start_up_aerial
		.byt >kiki_start_up_aerial,           >kiki_start_up_spe,                >kiki_start_up_spe
		controller_default_callback:
		.word no_input
	.)
.)

kiki_global_tick:
.(
	; Handle platform's lifetime
	.(
		lda kiki_a_platform_state, x
		and #%01111111
		beq destroy_platform

			dec_timer:
				; Decrement platform timer
				sec
				sbc #1
				sta tmpfield1
				lda kiki_a_platform_state, x
				and #%10000000
				ora tmpfield1
				sta kiki_a_platform_state, x
				jmp end_lifetime

			destroy_platform:
				; Destroy platform object
				ldy #0
				cpx #0
				beq offset_ok
					ldy #player_b_objects-player_a_objects
				offset_ok:
#if STAGE_ELEMENT_END <> 0
#error this code expects STAGE_ELEMENT_END to be zero
#endif
				;lda #STAGE_ELEMENT_END ; useless, ensured by beq
				sta player_a_objects, y ; type

				; Hide platform sprites
				lda kiki_first_wall_sprite_per_player, x
				asl
				asl
				tay

				lda #$fe
				sta oam_mirror, y
				sta oam_mirror+4,y

		end_lifetime:
	.)

	;TODO make platform blink on end of life (will need to find a place in memory to store real sprites' Y position)

	; Reset allowed flag on ground
	.(
		; Do not reset if not on a legit stage platform
		jsr check_on_ground
		bne end_ground_reset ; Not on ground
		lda tmpfield3
		cmp #player_a_objects-stage_data
		bcs end_ground_reset ; Grounded on any player platform

			; Set allowed flag
			lda #%10000000
			ora kiki_a_platform_state, x
			sta kiki_a_platform_state, x

		end_ground_reset:
	.)

	rts
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

kiki_tick_thrown:
.(
	jsr kiki_global_tick

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
	; Handle controller inputs
	lda #<(input_table+1)
	sta tmpfield1
	lda #>(input_table+1)
	sta tmpfield2
	lda input_table
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
		jsr kiki_check_aerial_inputs

	end:
	rts

	; Impactful controller states and associated callbacks
	input_table:
	.(
		table_length:
		.byt 3
		controller_inputs:
		.byt CONTROLLER_INPUT_TECH,        CONTROLLER_INPUT_TECH_RIGHT,   CONTROLLER_INPUT_TECH_LEFT
		controller_callbacks_lo:
		.byt <tech_neutral,                <tech_right,                   <tech_left
		controller_callbacks_hi:
		.byt >tech_neutral,                >tech_right,                   >tech_left
		controller_default_callback:
		.word no_tech
	.)
.)

kiki_onground_thrown:
.(
	KIKI_TECH_SPEED = $0400

	; If the tech counter is bellow the threshold, just crash
	lda #TECH_NB_FORBIDDEN_FRAMES
	cmp player_a_state_field1, x
	bcs crash

	; A valid tech was entered, land with momentum depending on tech's direction
	jsr kiki_start_landing
	lda player_a_state_field2, x
	beq no_momentum
	cmp #$01
	beq momentum_right
		lda #>(-KIKI_TECH_SPEED)
		sta player_a_velocity_h, x
		lda #>(-KIKI_TECH_SPEED)
		sta player_a_velocity_h_low, x
		jmp end
	no_momentum:
		lda #$00
		sta player_a_velocity_h, x
		sta player_a_velocity_h_low, x
		jmp end
	momentum_right:
		lda #>KIKI_TECH_SPEED
		sta player_a_velocity_h, x
		lda #<KIKI_TECH_SPEED
		sta player_a_velocity_h_low, x
		jmp end

	crash:
	jsr kiki_start_crashing

	end:
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
	jsr kiki_global_tick

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
	jsr kiki_global_tick

	rts
.)


kiki_start_spawn:
.(
	; Hack - there is no ensured call to a character init function
	;        expect start_spawn to be called once at the begining of a game
	jsr kiki_init

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
	jsr kiki_global_tick

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
	jsr kiki_global_tick

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
		.byt 22
		controller_inputs:
		.byt CONTROLLER_INPUT_LEFT,           CONTROLLER_INPUT_RIGHT,           CONTROLLER_INPUT_JUMP,          CONTROLLER_INPUT_JUMP_RIGHT,      CONTROLLER_INPUT_JUMP_LEFT
		.byt CONTROLLER_INPUT_ATTACK_RIGHT,   CONTROLLER_INPUT_ATTACK_LEFT,     CONTROLLER_INPUT_SPECIAL_RIGHT, CONTROLLER_INPUT_SPECIAL_LEFT,    CONTROLLER_INPUT_TECH
		.byt CONTROLLER_INPUT_SPECIAL_DOWN,   CONTROLLER_INPUT_SPECIAL_UP,      CONTROLLER_INPUT_ATTACK_UP,     CONTROLLER_INPUT_DOWN_TILT,       CONTROLLER_INPUT_JAB
		.byt CONTROLLER_INPUT_SPECIAL,        CONTROLLER_INPUT_TECH_LEFT,       CONTROLLER_INPUT_TECH_RIGHT,    CONTROLLER_INPUT_SPECIAL_UP_LEFT, CONTROLLER_INPUT_SPECIAL_UP_RIGHT
		.byt CONTROLLER_INPUT_ATTACK_UP_LEFT, CONTROLLER_INPUT_ATTACK_UP_RIGHT
		controller_callbacks_lsb:
		.byt <kiki_input_idle_left,           <kiki_input_idle_right,           <kiki_start_jumping,            <kiki_input_idle_jump_right,      <kiki_input_idle_jump_left
		.byt <kiki_start_side_tilt_right,     <kiki_start_side_tilt_left,       <kiki_start_side_spe_right,     <kiki_start_side_spe_left,        <kiki_start_shielding
		.byt <kiki_start_down_spe,            <kiki_start_up_spe,               <kiki_start_up_tilt,            <kiki_start_down_tilt,            <kiki_start_jabbing
		.byt <kiki_start_counter_guard,       <kiki_start_shielding,            <kiki_start_shielding,          <kiki_start_up_spe,               <kiki_start_up_spe
		.byt <kiki_start_up_tilt,             <kiki_start_up_tilt
		controller_callbacks_msb:
		.byt >kiki_input_idle_left,           >kiki_input_idle_right,           >kiki_start_jumping,            >kiki_input_idle_jump_right,      >kiki_input_idle_jump_left
		.byt >kiki_start_side_tilt_right,     >kiki_start_side_tilt_left,       >kiki_start_side_spe_right,     >kiki_start_side_spe_left,        >kiki_start_shielding
		.byt >kiki_start_down_spe,            >kiki_start_up_spe,               >kiki_start_up_tilt,            >kiki_start_down_tilt,            >kiki_start_jabbing
		.byt >kiki_start_counter_guard,       >kiki_start_shielding,            >kiki_start_shielding,          >kiki_start_up_spe,               >kiki_start_up_spe
		.byt >kiki_start_up_tilt,             >kiki_start_up_tilt

		controller_default_callback:
		.word end
	.)

	kiki_input_idle_jump_right:
	.(
		lda DIRECTION_RIGHT
		sta player_a_direction, x
		jmp kiki_start_jumping
		;rts ; useless - kiki_start_jumping is a routine
	.)

	kiki_input_idle_jump_left:
	.(
		lda DIRECTION_LEFT
		sta player_a_direction, x
		jmp kiki_start_jumping
		;rts ; useless - kiki_start_jumping is a routine
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
	jsr kiki_global_tick

	; Update player's velocity dependeing on his direction
	lda player_a_direction, x
	beq run_left

		; Running right, velocity tends toward vector max velocity
		lda #>KIKI_RUNNING_MAX_VELOCITY
		sta tmpfield4
		lda #<KIKI_RUNNING_MAX_VELOCITY
		jmp update_velocity

	run_left:
		; Running left, velocity tends toward vector "-1 * max volcity"
		lda #>-KIKI_RUNNING_MAX_VELOCITY
		sta tmpfield4
		lda #<-KIKI_RUNNING_MAX_VELOCITY

	update_velocity:
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
		lda DIRECTION_LEFT
		cmp player_a_direction, x
		beq end_changing_direction
			sta player_a_direction, x
			jsr kiki_set_running_animation
		end_changing_direction:
		rts
	.)

	kiki_input_running_right:
	.(
		lda DIRECTION_RIGHT
		cmp player_a_direction, x
		beq end_changing_direction
			sta player_a_direction, x
			jsr kiki_set_running_animation
		end_changing_direction:
		rts
	.)

	input_table:
	.(
		table_length:
		.byt 22
		controller_inputs:
		.byt CONTROLLER_INPUT_LEFT,           CONTROLLER_INPUT_RIGHT,           CONTROLLER_INPUT_JUMP,          CONTROLLER_INPUT_JUMP_RIGHT,      CONTROLLER_INPUT_JUMP_LEFT
		.byt CONTROLLER_INPUT_ATTACK_LEFT,    CONTROLLER_INPUT_ATTACK_RIGHT,    CONTROLLER_INPUT_SPECIAL_LEFT,  CONTROLLER_INPUT_SPECIAL_RIGHT,   CONTROLLER_INPUT_TECH
		.byt CONTROLLER_INPUT_SPECIAL_DOWN,   CONTROLLER_INPUT_SPECIAL_UP,      CONTROLLER_INPUT_ATTACK_UP,     CONTROLLER_INPUT_DOWN_TILT,       CONTROLLER_INPUT_JAB
		.byt CONTROLLER_INPUT_SPECIAL,        CONTROLLER_INPUT_TECH_LEFT,       CONTROLLER_INPUT_TECH_RIGHT,    CONTROLLER_INPUT_SPECIAL_UP_LEFT, CONTROLLER_INPUT_SPECIAL_UP_RIGHT
		.byt CONTROLLER_INPUT_ATTACK_UP_LEFT, CONTROLLER_INPUT_ATTACK_UP_RIGHT
		controller_callbacks_lsb:
		.byt <kiki_input_running_left,        <kiki_input_running_right,        <kiki_start_jumping,            <kiki_start_jumping,              <kiki_start_jumping
		.byt <kiki_start_side_tilt_left,      <kiki_start_side_tilt_right,      <kiki_start_side_spe_left,      <kiki_start_side_spe_right,       <kiki_start_shielding
		.byt <kiki_start_down_spe,            <kiki_start_up_spe,               <kiki_start_up_tilt,            <kiki_start_down_tilt,            <kiki_start_jabbing
		.byt <kiki_start_counter_guard,       <kiki_start_shielding,            <kiki_start_shielding,          <kiki_start_up_spe,               <kiki_start_up_spe
		.byt <kiki_start_up_tilt,             <kiki_start_up_tilt
		controller_callbacks_msb:
		.byt >kiki_input_running_left,        >kiki_input_running_right,        >kiki_start_jumping,            >kiki_start_jumping,              >kiki_start_jumping
		.byt >kiki_start_side_tilt_left,      >kiki_start_side_tilt_right,      >kiki_start_side_spe_left,      >kiki_start_side_spe_right,       >kiki_start_shielding
		.byt >kiki_start_down_spe,            >kiki_start_up_spe,               >kiki_start_up_tilt,            >kiki_start_down_tilt,            >kiki_start_jabbing
		.byt >kiki_start_counter_guard,       >kiki_start_shielding,            >kiki_start_shielding,          >kiki_start_up_spe,               >kiki_start_up_spe
		.byt >kiki_start_up_tilt,             >kiki_start_up_tilt
		controller_default_callback:
		.word kiki_start_idle
	.)
.)


kiki_start_jumping:
.(
	lda #KIKI_STATE_JUMPING
	sta player_a_state, x

	lda #0
	sta player_a_state_field1, x
	sta player_a_state_clock, x

	; Set the appropriate animation
	lda #<kiki_anim_jump
	sta tmpfield13
	lda #>kiki_anim_jump
	sta tmpfield14
	jsr set_player_animation

	rts
.)

KIKI_STATE_JUMP_PREPARATION_END = 4
kiki_tick_jumping:
.(
	jsr kiki_global_tick

	KIKI_STATE_JUMP_SHORT_HOP_TIME = 9
	KIKI_STATE_JUMP_INITIAL_VELOCITY = $fb80
	KIKI_STATE_JUMP_SHORT_HOP_VELOCITY = $fefe

	; Tick clock
	inc player_a_state_clock, x

	; Wait for the preparation to end to begin to jump
	lda player_a_state_clock, x
	cmp #KIKI_STATE_JUMP_PREPARATION_END
	bcc end
	beq begin_to_jump

	; Handle short-hop input
	cmp #KIKI_STATE_JUMP_SHORT_HOP_TIME
	beq stop_short_hop

	; Check if the top of the jump is reached
	lda player_a_velocity_v, x
	beq top_reached
	bpl top_reached

	; The top is not reached, stay in jumping state but apply gravity and directional influence
	moving_upward:
		jsr kiki_tick_falling ; Hack - We just use kiki_tick_falling which do exactly what we want
		jmp end

	; The top is reached, return to falling
	top_reached:
		jsr kiki_start_falling
		jmp end

	; If the jump button is no more pressed mid jump, convert the jump to a short-hop
	stop_short_hop:
		; Handle this tick as any other
		jsr kiki_tick_falling

		; If the jump button is still pressed, this is not a short-hop
		lda controller_a_btns, x
		and #CONTROLLER_INPUT_JUMP
		bne end

		; Reduce upward momentum to end the jump earlier
		lda #>KIKI_STATE_JUMP_SHORT_HOP_VELOCITY
		sta player_a_velocity_v, x
		lda #<KIKI_STATE_JUMP_SHORT_HOP_VELOCITY
		sta player_a_velocity_v_low, x
		jmp end

	; Put initial jumping velocity
	begin_to_jump:
		lda #>KIKI_STATE_JUMP_INITIAL_VELOCITY
		sta player_a_velocity_v, x
		lda #<KIKI_STATE_JUMP_INITIAL_VELOCITY
		sta player_a_velocity_v_low, x
		;jmp end ; Useless, fallthrough

	end:
	rts
.)

kiki_input_jumping:
.(
	; The jump is cancellable by grounded movements during preparation
	; and by aerial movements after that
	lda player_a_num_aerial_jumps, x ; performing aerial jump, not
	bne not_grounded                 ; grounded
	lda player_a_state_clock, x          ;
	cmp #KIKI_STATE_JUMP_PREPARATION_END ; Still preparing the jump
	bcc grounded                         ;

	not_grounded:
	jsr kiki_check_aerial_inputs
	jmp end

	grounded:
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
		; Impactful controller states and associated callbacks (when still grounded)
		; Note - We can put subroutines as callbacks because we have nothing to do after calling it
		;        (sourboutines return to our caller since "called" with jmp)
		table_length:
		.byt 2
		controller_inputs:
		.byt CONTROLLER_INPUT_ATTACK_UP, CONTROLLER_INPUT_SPECIAL_UP
		controller_callbacks_lo:
		.byt <kiki_start_up_tilt, <kiki_start_up_spe
		controller_callbacks_hi:
		.byt >kiki_start_up_tilt, >kiki_start_up_spe
		controller_default_callback:
		.word end
	.)
.)


kiki_start_aerial_jumping:
.(
	KIKI_MAX_NUM_AERIAL_JUMPS = 1

	; Deny to start jump state if the player used all it's jumps
	lda #KIKI_MAX_NUM_AERIAL_JUMPS
	cmp player_a_num_aerial_jumps, x
	bne jump_ok
	rts
	jump_ok:
	inc player_a_num_aerial_jumps, x

	; Trick - aerial_jumping set the state to jumping. It is the same state with
	; the starting conditions as the only differences
	lda #KIKI_STATE_JUMPING
	sta player_a_state, x

	; Reset clock
	lda #0
	sta player_a_state_clock, x

	lda #$00
	sta player_a_velocity_v, x
	lda #$00
	sta player_a_velocity_v_low, x

	; Set the appropriate animation
	;TODO use aerial_jump animation
	lda #<kiki_anim_jump
	sta tmpfield13
	lda #>kiki_anim_jump
	sta tmpfield14
	jsr set_player_animation

	rts
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
	jsr kiki_global_tick

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
	jsr kiki_global_tick

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


kiki_start_crashing:
.(
	; Set state
	lda #KIKI_STATE_CRASHING
	sta player_a_state, x

	; Reset clock
	lda #0
	sta player_a_state_clock, x

	; Set the appropriate animation
	lda #<kiki_anim_crash
	sta tmpfield13
	lda #>kiki_anim_crash
	sta tmpfield14
	jsr set_player_animation

	; Play crash sound
	jsr audio_play_crash

	rts
.)

kiki_tick_crashing:
.(
	jsr kiki_global_tick

	KIKI_STATE_CRASHING_DURATION = 30

	; Tick clock
	inc player_a_state_clock, x

	; Do not move, velocity tends toward vector (0,0)
	lda #$00
	sta tmpfield4
	sta tmpfield3
	sta tmpfield2
	sta tmpfield1
	lda #KIKI_GROUND_FRICTION_STRENGTH*2
	sta tmpfield5
	jsr merge_to_player_velocity

	; After move's time is out, go to standing state
	lda player_a_state_clock, x
	cmp #KIKI_STATE_CRASHING_DURATION
	bne end
	jsr kiki_start_idle

	end:
	rts
.)


kiki_start_helpless:
.(
	; Set state
	lda #KIKI_STATE_HELPLESS
	sta player_a_state, x

	; Set the appropriate animation
	lda #<kiki_anim_helpless
	sta tmpfield13
	lda #>kiki_anim_helpless
	sta tmpfield14
	jsr set_player_animation

	rts
.)

kiki_tick_helpless:
.(
	jsr kiki_global_tick

	jmp kiki_tick_falling
.)


kiki_start_shielding:
.(
	; Set state
	lda #KIKI_STATE_SHIELDING
	sta player_a_state, x

	; Reset clock
	lda #0
	sta player_a_state_clock, x

	; Set the appropriate animation
	lda #<kiki_anim_shield_full
	sta tmpfield13
	lda #>kiki_anim_shield_full
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

kiki_tick_shielding:
.(
	jsr kiki_global_tick

	; Tick clock
	lda player_a_state_clock, x
	cmp #PLAYER_DOWN_TAP_MAX_DURATION
	bcs end_tick
		inc player_a_state_clock, x
	end_tick:

	rts
.)

kiki_input_shielding:
.(
	; Do the same as standing player except when
	;  all buttons are released - start shieldlag (or falling if on smooth platform and it was a short-tap)
	;  down is pressed - avoid to reset the shield state (and hit counter)
	lda controller_a_btns, x
	beq end_shield
	cmp #CONTROLLER_INPUT_TECH
	beq end

		jsr kiki_input_idle
		jmp end

	end_shield:

		lda #PLAYER_DOWN_TAP_MAX_DURATION
		cmp player_a_state_clock, x
		beq shieldlag
		bcc shieldlag
			jsr check_on_ground
			bne shieldlag
				ldy tmpfield3
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

			jsr kiki_start_falling
			jmp end

		shieldlag:
			jsr kiki_start_shieldlag

	end:
	rts
.)

kiki_hurt_shielding:
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

	partial_shield:
		; Get the animation corresponding to the shield's life
		lda #<kiki_anim_shield_partial
		sta tmpfield13
		lda #>kiki_anim_shield_partial
		jmp still_shield

	limit_shield:
		; Get the animation corresponding to the shield's life
		lda #<kiki_anim_shield_limit
		sta tmpfield13
		lda #>kiki_anim_shield_limit

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

kiki_start_shieldlag:
.(
	; Set state
	lda #KIKI_STATE_SHIELDLAG
	sta player_a_state, x

	; Reset clock
	lda #0
	sta player_a_state_clock, x

	; Set the appropriate animation
	lda #<kiki_anim_shield_remove
	sta tmpfield13
	lda #>kiki_anim_shield_remove
	sta tmpfield14
	jsr set_player_animation

	rts
.)

kiki_tick_shieldlag:
.(
	jsr kiki_global_tick

	KIKI_STATE_SHIELDLAG_DURATION = 8

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
	cmp #KIKI_STATE_SHIELDLAG_DURATION
	bne end
		jsr kiki_start_idle

	end:
	rts
.)


kiki_start_side_tilt_right:
.(
	lda DIRECTION_RIGHT
	sta player_a_direction, x
	jmp kiki_start_side_tilt
	; rts ; useless - kiki_start_side_tilt is a routine
.)

kiki_start_side_tilt_left:
.(
	lda DIRECTION_LEFT
	sta player_a_direction, x
	; jmp kiki_start_side_tilt ; useless - fallthrough
	; rts ; useless - kiki_start_side_tilt is a routine
.)

kiki_start_side_tilt:
.(
	; Set the appropriate animation
	lda #<kiki_anim_strike
	sta tmpfield13
	lda #>kiki_anim_strike
	sta tmpfield14
	jsr set_player_animation

	; Set the player's state
	lda #KIKI_STATE_SIDE_TILT
	sta player_a_state, x

	; Initialize the clock
	lda #0
	sta player_a_state_clock,x

	rts
.)

kiki_tick_side_tilt:
.(
	jsr kiki_global_tick

	KIKI_STATE_SIDE_TILT_DURATION = 16
	KIKI_STATE_SIDE_TILT_FRICTION = $20

	inc player_a_state_clock, x

	lda player_a_state_clock, x
	cmp #KIKI_STATE_SIDE_TILT_DURATION
	bne update_velocity

		jsr kiki_start_idle
		jmp end

	update_velocity:
		; Do not move, velocity tends toward vector (0,0)
		lda #$00
		sta tmpfield4
		sta tmpfield3
		sta tmpfield2
		sta tmpfield1
		lda #KIKI_STATE_SIDE_TILT_FRICTION
		sta tmpfield5
		jsr merge_to_player_velocity

	end:
	rts
.)


kiki_start_side_spe_right:
.(
	lda DIRECTION_RIGHT
	sta player_a_direction, x
	jmp kiki_start_side_spe
	; rts ; useless - kiki_start_side_spe is a routine
.)

kiki_start_side_spe_left:
.(
	lda DIRECTION_LEFT
	sta player_a_direction, x
	; jmp kiki_start_side_spe ; useless - fallthrough
	; rts ; useless - kiki_start_side_spe is a routine
.)

kiki_start_side_spe:
.(
	sprite_x_lsb = tmpfield1
	sprite_x_msb = tmpfield2
	sprite_y_lsb = tmpfield3
	sprite_y_msb = tmpfield4

	; Set the appropriate animation
	lda #<kiki_anim_paint_side
	sta tmpfield13
	lda #>kiki_anim_paint_side
	sta tmpfield14
	jsr set_player_animation

	; Set the player's state
	lda #KIKI_STATE_SIDE_SPE
	sta player_a_state, x

	; Initialize the clock
	lda #0
	sta player_a_state_clock,x

	; TODO study intersting velocity setups
	;  Current - rapidly slow down to (0, 0) (was done to copy-paste code from side tilt)
	;  Idea 1 - directly stop any velocity (should feel like now, without computations per tick)
	;  Idea 2 - stop horizontal velocity, keep vertical velocity, apply gravity on tick (should help to side spe as part of aerial gameplay)

	; Avoid spawning wall when forbiden
	lda kiki_a_platform_state, x
	and #%10000000
	bne spawn_wall
		jmp spawn_wall_end

	; Spawn wall
	spawn_wall:
	.(
		; Reset wall state
		lda #KIKI_PLATFORM_DURATION
		sta kiki_a_platform_state, x

		; Place wall
		ldy #0
		cpx #0
		beq place_wall
			ldy #player_b_objects-player_a_objects
		place_wall:

		lda #STAGE_ELEMENT_OOS_PLATFORM
		sta player_a_objects, y ; type

		lda player_a_direction, x
		cmp DIRECTION_LEFT
		bne platform_on_right
			lda player_a_x, x
			clc
			adc #$ef
			sta player_a_objects+STAGE_OOS_PLATFORM_OFFSET_LEFT_LSB, y
			lda player_a_x_screen, x
			adc #$ff
			jmp end_platform_left_positioning
		platform_on_right:
			lda player_a_x, x
			sta player_a_objects+STAGE_OOS_PLATFORM_OFFSET_LEFT_LSB, y
			lda player_a_x_screen, x
		end_platform_left_positioning:
		sta player_a_objects+STAGE_OOS_PLATFORM_OFFSET_LEFT_MSB, y

		lda player_a_objects+STAGE_OOS_PLATFORM_OFFSET_LEFT_LSB, y
		clc
		adc #16
		sta player_a_objects+STAGE_OOS_PLATFORM_OFFSET_RIGHT_LSB, y
		lda player_a_objects+STAGE_OOS_PLATFORM_OFFSET_LEFT_MSB, y
		adc #0
		sta player_a_objects+STAGE_OOS_PLATFORM_OFFSET_RIGHT_MSB, y

		lda player_a_y, x
		clc
		adc #16
		sta player_a_objects+STAGE_OOS_PLATFORM_OFFSET_BOTTOM_LSB, y
		lda player_a_y_screen, x
		adc #0
		sta player_a_objects+STAGE_OOS_PLATFORM_OFFSET_BOTTOM_MSB, y

		lda player_a_objects+STAGE_OOS_PLATFORM_OFFSET_BOTTOM_LSB, y
		sec
		sbc #32
		sta player_a_objects+STAGE_OOS_PLATFORM_OFFSET_TOP_LSB, y
		lda player_a_objects+STAGE_OOS_PLATFORM_OFFSET_BOTTOM_MSB, y
		sbc #0
		sta player_a_objects+STAGE_OOS_PLATFORM_OFFSET_TOP_MSB, y

		lda #STAGE_ELEMENT_END
		sta player_a_objects+STAGE_OOS_PLATFORM_LENGTH, y ; next's type

		; Compute wall's sprites position
		lda player_a_objects+STAGE_OOS_PLATFORM_OFFSET_TOP_LSB, y
		clc
		adc #15
		sta sprite_y_lsb
		lda player_a_objects+STAGE_OOS_PLATFORM_OFFSET_TOP_MSB, y
		adc #0
		sta sprite_y_msb

		lda player_a_objects+STAGE_OOS_PLATFORM_OFFSET_LEFT_LSB, y
		clc
		adc #8
		sta sprite_x_lsb
		lda player_a_objects+STAGE_OOS_PLATFORM_OFFSET_LEFT_MSB, y
		adc #0
		sta sprite_x_msb

		; Set sprites properties
		lda kiki_first_wall_sprite_per_player, x
		asl
		asl
		tay

		lda wall_attributes_per_player, x
		sta oam_mirror+2, y ; First sprite attributes
		sta oam_mirror+6, y ; Second sprite attributes

		; Place upper sprite
		lda sprite_x_msb
		cmp #0
		bne hide_upper_sprite
		lda sprite_y_msb
		bne hide_upper_sprite

			lda #KIKI_TILE_WALL_BLOCK_V_UP
			clc
			adc kiki_first_tile_index_per_player, x
			sta oam_mirror+1, y ; First sprite tile
			lda sprite_y_lsb
			sta oam_mirror, y ; First sprite Y
			lda sprite_x_lsb
			sta oam_mirror+3, y ; First sprite X
			jmp end_upper_sprite

		hide_upper_sprite:
			lda #$fe
			sta oam_mirror, y ; First sprite Y

		end_upper_sprite:

		; Place lower sprite
		lda sprite_x_msb
		cmp #0
		bne hide_lower_sprite

		lda sprite_y_lsb
		clc
		adc #8
		sta sprite_y_lsb
		lda sprite_y_msb
		adc #0
		bne hide_lower_sprite


			lda #KIKI_TILE_WALL_BLOCK_V_DOWN
			clc
			adc kiki_first_tile_index_per_player, x
			sta oam_mirror+5, y ; Second sprite tile
			lda sprite_y_lsb
			sta oam_mirror+4, y ; Second sprite Y
			lda sprite_x_lsb
			sta oam_mirror+7, y ; Second sprite X
			jmp end_lower_sprite

		hide_lower_sprite:
			lda #$fe
			sta oam_mirror+4, y ; Second sprite Y

		end_lower_sprite:
	.)
	spawn_wall_end:

	rts

	wall_attributes_per_player:
	.byt 1, 3
.)

kiki_tick_side_spe:
.(
	jsr kiki_global_tick

	; TODO study velocity stuff
	KIKI_STATE_SIDE_SPE_DURATION = 16
	KIKI_STATE_SIDE_SPE_FRICTION = $ff

	inc player_a_state_clock, x

	lda player_a_state_clock, x
	cmp #KIKI_STATE_SIDE_SPE_DURATION
	bne update_velocity

		jsr kiki_start_idle
		jmp end

	update_velocity:
		; Do not move, velocity tends toward vector (0,0)
		lda #$00
		sta tmpfield4
		sta tmpfield3
		sta tmpfield2
		sta tmpfield1
		lda #KIKI_STATE_SIDE_SPE_FRICTION
		sta tmpfield5
		jsr merge_to_player_velocity

	end:
	rts
.)


kiki_start_down_spe:
.(
	sprite_x_lsb = tmpfield1
	sprite_x_msb = tmpfield2
	sprite_y_lsb = tmpfield3
	sprite_y_msb = tmpfield4

	; Set the appropriate animation
	lda #<kiki_anim_paint_down
	sta tmpfield13
	lda #>kiki_anim_paint_down
	sta tmpfield14
	jsr set_player_animation

	; Set the player's state
	lda #KIKI_STATE_DOWN_SPE
	sta player_a_state, x

	; Initialize the clock
	lda #0
	sta player_a_state_clock,x

	; Reset velocity
	;lda #0 ; useless, already set to zero
	sta player_a_velocity_h_low, x
	sta player_a_velocity_h, x
	sta player_a_velocity_v_low, x
	sta player_a_velocity_v, x

	; Avoid spawning wall when forbiden
	lda kiki_a_platform_state, x
	and #%10000000
	bne spawn_wall
		jmp spawn_wall_end

	; Spawn wall
	spawn_wall:
	.(
		; Move player upward (to create wall on ground)
		lda player_a_y, x
		sec
		sbc #8
		sta player_a_y, x
		lda player_a_y_screen, x
		sbc #0
		sta player_a_y_screen, x
		lda #$ff
		sta player_a_y_low, x

		; Reset wall state
		lda #KIKI_PLATFORM_DURATION
		sta kiki_a_platform_state, x

		; Place wall
		;TODO factorize code with other specials
		ldy #0
		cpx #0
		beq place_wall
			ldy #player_b_objects-player_a_objects
		place_wall:

		lda #STAGE_ELEMENT_OOS_PLATFORM
		sta player_a_objects, y ; type

		lda player_a_x, x
		clc
		adc #$f3
		sta player_a_objects+STAGE_OOS_PLATFORM_OFFSET_LEFT_LSB, y
		lda player_a_x_screen, x
		adc #$ff
		sta player_a_objects+STAGE_OOS_PLATFORM_OFFSET_LEFT_MSB, y

		lda player_a_objects+STAGE_OOS_PLATFORM_OFFSET_LEFT_LSB, y
		clc
		adc #24
		sta player_a_objects+STAGE_OOS_PLATFORM_OFFSET_RIGHT_LSB, y
		lda player_a_objects+STAGE_OOS_PLATFORM_OFFSET_LEFT_MSB, y
		adc #0
		sta player_a_objects+STAGE_OOS_PLATFORM_OFFSET_RIGHT_MSB, y

		lda player_a_y, x
		clc
		adc #24
		sta player_a_objects+STAGE_OOS_PLATFORM_OFFSET_BOTTOM_LSB, y
		lda player_a_y_screen, x
		adc #0
		sta player_a_objects+STAGE_OOS_PLATFORM_OFFSET_BOTTOM_MSB, y

		lda player_a_objects+STAGE_OOS_PLATFORM_OFFSET_BOTTOM_LSB, y
		sec
		sbc #24
		sta player_a_objects+STAGE_OOS_PLATFORM_OFFSET_TOP_LSB, y
		lda player_a_objects+STAGE_OOS_PLATFORM_OFFSET_BOTTOM_MSB, y
		sbc #0
		sta player_a_objects+STAGE_OOS_PLATFORM_OFFSET_TOP_MSB, y

		lda #STAGE_ELEMENT_END
		sta player_a_objects+STAGE_OOS_PLATFORM_LENGTH, y ; next's type

		; Compute wall's sprites position
		lda player_a_objects+STAGE_OOS_PLATFORM_OFFSET_TOP_LSB, y
		clc
		adc #15
		sta sprite_y_lsb
		lda player_a_objects+STAGE_OOS_PLATFORM_OFFSET_TOP_MSB, y
		adc #0
		sta sprite_y_msb

		lda player_a_objects+STAGE_OOS_PLATFORM_OFFSET_LEFT_LSB, y
		clc
		adc #8
		sta sprite_x_lsb
		lda player_a_objects+STAGE_OOS_PLATFORM_OFFSET_LEFT_MSB, y
		adc #0
		sta sprite_x_msb

		; Set sprites properties
		lda kiki_first_wall_sprite_per_player, x
		asl
		asl
		tay

		lda wall_attributes_per_player, x
		sta oam_mirror+2, y ; First sprite attributes
		sta oam_mirror+6, y ; Second sprite attributes

		; Place left sprite
		lda sprite_x_msb
		cmp #0
		bne hide_left_sprite
		lda sprite_y_msb
		bne hide_left_sprite

			lda #KIKI_TILE_WALL_BLOCK_H_LEFT
			clc
			adc kiki_first_tile_index_per_player, x
			sta oam_mirror+1, y ; First sprite tile
			lda sprite_y_lsb
			sta oam_mirror, y ; First sprite Y
			lda sprite_x_lsb
			sta oam_mirror+3, y ; First sprite X
			jmp end_left_sprite

		hide_left_sprite:
			lda #$fe
			sta oam_mirror, y ; First sprite Y

		end_left_sprite:

		; Place right sprite
		lda sprite_x_lsb
		clc
		adc #8
		sta sprite_x_lsb
		lda sprite_x_msb
		adc #0
		bne hide_right_sprite

		lda sprite_y_msb
		bne hide_right_sprite

			lda #KIKI_TILE_WALL_BLOCK_H_RIGHT
			clc
			adc kiki_first_tile_index_per_player, x
			sta oam_mirror+5, y ; Second sprite tile
			lda sprite_y_lsb
			sta oam_mirror+4, y ; Second sprite Y
			lda sprite_x_lsb
			sta oam_mirror+7, y ; Second sprite X
			jmp end_right_sprite

		hide_right_sprite:
			lda #$fe
			sta oam_mirror+4, y ; Second sprite Y

		end_right_sprite:
	.)
	spawn_wall_end:

	rts

	wall_attributes_per_player:
	.byt 1, 3
.)

kiki_tick_down_spe:
.(
	jsr kiki_global_tick

	KIKI_STATE_DOWN_SPE_DURATION = 16

	jsr apply_player_gravity

	inc player_a_state_clock, x

	lda player_a_state_clock, x
	cmp #KIKI_STATE_DOWN_SPE_DURATION
	bne end
		jsr kiki_start_idle

	end:
	rts
.)


kiki_start_up_spe:
.(
	sprite_x_lsb = tmpfield1
	sprite_x_msb = tmpfield2
	sprite_y_lsb = tmpfield3
	sprite_y_msb = tmpfield4

	; Set the appropriate animation
	; TODO draw a specific animation
	lda #<kiki_anim_paint_side
	sta tmpfield13
	lda #>kiki_anim_paint_side
	sta tmpfield14
	jsr set_player_animation

	; Set the player's state
	lda #KIKI_STATE_UP_SPE
	sta player_a_state, x

	; Initialize the clock
	lda #0
	sta player_a_state_clock,x

	; Reset velocity
	; TODO study intersting velocity setups
	;lda #0 ; useless, already set to zero
	sta player_a_velocity_h_low, x
	sta player_a_velocity_h, x
	sta player_a_velocity_v_low, x
	sta player_a_velocity_v, x

	; Avoid spawning wall when forbiden
	lda kiki_a_platform_state, x
	and #%10000000
	bne spawn_wall
		jmp spawn_wall_end

	; Spawn wall
	spawn_wall:
	.(
		; Reset wall state
		lda #KIKI_PLATFORM_DURATION
		sta kiki_a_platform_state, x

		; Place wall
		;TODO factorize code with other specials
		ldy #0
		cpx #0
		beq place_wall
			ldy #player_b_objects-player_a_objects
		place_wall:

		lda #STAGE_ELEMENT_OOS_SMOOTH_PLATFORM
		sta player_a_objects, y ; type

		lda player_a_x, x
		clc
		adc #$f3
		sta player_a_objects+STAGE_OOS_PLATFORM_OFFSET_LEFT_LSB, y
		lda player_a_x_screen, x
		adc #$ff
		sta player_a_objects+STAGE_OOS_PLATFORM_OFFSET_LEFT_MSB, y

		lda player_a_objects+STAGE_OOS_PLATFORM_OFFSET_LEFT_LSB, y
		clc
		adc #24
		sta player_a_objects+STAGE_OOS_PLATFORM_OFFSET_RIGHT_LSB, y
		lda player_a_objects+STAGE_OOS_PLATFORM_OFFSET_LEFT_MSB, y
		adc #0
		sta player_a_objects+STAGE_OOS_PLATFORM_OFFSET_RIGHT_MSB, y

		lda player_a_y, x
		sec
		sbc #24
		sta player_a_objects+STAGE_OOS_PLATFORM_OFFSET_TOP_LSB, y
		lda player_a_y_screen, x
		sbc #0
		sta player_a_objects+STAGE_OOS_PLATFORM_OFFSET_TOP_MSB, y

		lda #STAGE_ELEMENT_END
		sta player_a_objects+STAGE_OOS_SMOOTH_PLATFORM_LENGTH, y ; next's type

		; Compute wall's sprites position
		lda player_a_objects+STAGE_OOS_PLATFORM_OFFSET_TOP_LSB, y
		clc
		adc #15
		sta sprite_y_lsb
		lda player_a_objects+STAGE_OOS_PLATFORM_OFFSET_TOP_MSB, y
		adc #0
		sta sprite_y_msb

		lda player_a_objects+STAGE_OOS_PLATFORM_OFFSET_LEFT_LSB, y
		clc
		adc #8
		sta sprite_x_lsb
		lda player_a_objects+STAGE_OOS_PLATFORM_OFFSET_LEFT_MSB, y
		adc #0
		sta sprite_x_msb

		; Set sprites properties
		lda kiki_first_wall_sprite_per_player, x
		asl
		asl
		tay

		lda wall_attributes_per_player, x
		sta oam_mirror+2, y ; First sprite attributes
		sta oam_mirror+6, y ; Second sprite attributes

		; Place left sprite
		lda sprite_x_msb
		cmp #0
		bne hide_left_sprite
		lda sprite_y_msb
		bne hide_left_sprite

			lda #KIKI_TILE_SMOOTH_WALL_BLOCK_LEFT
			clc
			adc kiki_first_tile_index_per_player, x
			sta oam_mirror+1, y ; First sprite tile
			lda sprite_y_lsb
			sta oam_mirror, y ; First sprite Y
			lda sprite_x_lsb
			sta oam_mirror+3, y ; First sprite X
			jmp end_left_sprite

		hide_left_sprite:
			lda #$fe
			sta oam_mirror, y ; First sprite Y

		end_left_sprite:

		; Place right sprite
		lda sprite_x_lsb
		clc
		adc #8
		sta sprite_x_lsb
		lda sprite_x_msb
		adc #0
		bne hide_right_sprite

		lda sprite_y_msb
		bne hide_right_sprite

			lda #KIKI_TILE_SMOOTH_WALL_BLOCK_RIGHT
			clc
			adc kiki_first_tile_index_per_player, x
			sta oam_mirror+5, y ; Second sprite tile
			lda sprite_y_lsb
			sta oam_mirror+4, y ; Second sprite Y
			lda sprite_x_lsb
			sta oam_mirror+7, y ; Second sprite X
			jmp end_right_sprite

		hide_right_sprite:
			lda #$fe
			sta oam_mirror+4, y ; Second sprite Y

		end_right_sprite:
	.)
	spawn_wall_end:

	rts

	wall_attributes_per_player:
	.byt 1, 3
.)

kiki_tick_up_spe:
.(
	jsr kiki_global_tick

	KIKI_STATE_UP_SPE_DURATION = 16

	inc player_a_state_clock, x

	lda player_a_state_clock, x
	cmp #KIKI_STATE_UP_SPE_DURATION
	bne end

		;TODO avoid to compute check_on_ground
		;     It is already done in kiki_global_tick, but should really be done
		;     only once per frame by the engine (storing the result for reuse.)
		jsr check_on_ground
		beq on_ground
			jsr kiki_start_falling
			jmp end
		on_ground:
			jsr kiki_start_idle

	end:
	rts
.)


kiki_start_up_tilt:
.(
	; Set the appropriate animation
	lda #<kiki_anim_strike_up
	sta tmpfield13
	lda #>kiki_anim_strike_up
	sta tmpfield14
	jsr set_player_animation

	; Set the player's state
	lda #KIKI_STATE_UP_TILT
	sta player_a_state, x

	; Initialize the clock
	lda #0
	sta player_a_state_clock,x

	rts
.)

kiki_tick_up_tilt:
.(
	jsr kiki_global_tick

	KIKI_STATE_UP_TILT_DURATION = 16
	KIKI_STATE_UP_TILT_FRICTION = $20

	inc player_a_state_clock, x

	lda player_a_state_clock, x
	cmp #KIKI_STATE_UP_TILT_DURATION
	bne update_velocity

		jsr kiki_start_idle
		jmp end

	update_velocity:
		; Do not move, velocity tends toward vector (0,0)
		lda #$00
		sta tmpfield4
		sta tmpfield3
		sta tmpfield2
		sta tmpfield1
		lda #KIKI_STATE_UP_TILT_FRICTION
		sta tmpfield5
		jsr merge_to_player_velocity

	end:
	rts
.)


kiki_start_up_aerial:
.(
	; Set the appropriate animation
	lda #<kiki_anim_strike_up
	sta tmpfield13
	lda #>kiki_anim_strike_up
	sta tmpfield14
	jsr set_player_animation

	; Set the player's state
	lda #KIKI_STATE_UP_AERIAL
	sta player_a_state, x

	; Initialize the clock
	lda #0
	sta player_a_state_clock,x

	rts
.)

kiki_tick_up_aerial:
.(
	jsr kiki_global_tick

	KIKI_STATE_UP_AERIAL_DURATION = 16

	jsr apply_player_gravity

	inc player_a_state_clock, x
	lda player_a_state_clock, x
	cmp #KIKI_STATE_UP_AERIAL_DURATION
	bne end
		jsr kiki_start_falling

	end:
	rts
.)


kiki_start_down_tilt:
.(
	; Set the appropriate animation
	lda #<kiki_anim_strike_down
	sta tmpfield13
	lda #>kiki_anim_strike_down
	sta tmpfield14
	jsr set_player_animation

	; Set the player's state
	lda #KIKI_STATE_DOWN_TILT
	sta player_a_state, x

	; Initialize the clock
	lda #0
	sta player_a_state_clock,x

	rts
.)

kiki_tick_down_tilt:
.(
	jsr kiki_global_tick

	KIKI_STATE_DOWN_TILT_DURATION = 12
	KIKI_STATE_DOWN_TILT_FRICTION = $20

	inc player_a_state_clock, x

	lda player_a_state_clock, x
	cmp #KIKI_STATE_DOWN_TILT_DURATION
	bne update_velocity

		jsr kiki_start_idle
		jmp end

	update_velocity:
		; Do not move, velocity tends toward vector (0,0)
		lda #$00
		sta tmpfield4
		sta tmpfield3
		sta tmpfield2
		sta tmpfield1
		lda #KIKI_STATE_DOWN_TILT_FRICTION
		sta tmpfield5
		jsr merge_to_player_velocity

	end:
	rts
.)


kiki_start_down_aerial:
.(
	; Set the appropriate animation
	lda #<kiki_anim_strike_down
	sta tmpfield13
	lda #>kiki_anim_strike_down
	sta tmpfield14
	jsr set_player_animation

	; Set the player's state
	lda #KIKI_STATE_DOWN_AERIAL
	sta player_a_state, x

	; Initialize the clock
	lda #0
	sta player_a_state_clock,x

	; Cancel fastfall
	lda #DEFAULT_GRAVITY     ; Do nothing if not in fast fall
	cmp player_a_gravity, x  ;
	beq end_cancel_fast_fall ;

		; Reset gravity
		sta player_a_gravity, x

		; Reset fall speed
		sta player_a_velocity_v, x
		lda #0
		sta player_a_velocity_v_low, x

	end_cancel_fast_fall:

	rts
.)

kiki_tick_down_aerial:
.(
	jsr kiki_global_tick

	KIKI_STATE_DOWN_AERIAL_DURATION = 12

	jsr apply_player_gravity

	inc player_a_state_clock, x
	lda player_a_state_clock, x
	cmp #KIKI_STATE_DOWN_AERIAL_DURATION
	bne end
		jsr kiki_start_falling

	end:
	rts
.)


kiki_start_side_aerial_right:
.(
	lda DIRECTION_RIGHT
	sta player_a_direction, x
	jmp kiki_start_side_aerial
	; rts ; useless - kiki_start_side_aerial is a routine
.)

kiki_start_side_aerial_left:
.(
	lda DIRECTION_LEFT
	sta player_a_direction, x
	; jmp kiki_start_side_aerial ; useless - fallthrough
	; rts ; useless - kiki_start_side_aerial is a routine
.)

kiki_start_side_aerial:
.(
	; Set the appropriate animation
	lda #<kiki_anim_strike
	sta tmpfield13
	lda #>kiki_anim_strike
	sta tmpfield14
	jsr set_player_animation

	; Set the player's state
	lda #KIKI_STATE_SIDE_AERIAL
	sta player_a_state, x

	; Initialize the clock
	lda #0
	sta player_a_state_clock,x

	rts
.)

kiki_tick_side_aerial:
.(
	jsr kiki_global_tick

	KIKI_STATE_SIDE_AERIAL_DURATION = 16

	jsr apply_player_gravity

	inc player_a_state_clock, x
	lda player_a_state_clock, x
	cmp #KIKI_STATE_SIDE_AERIAL_DURATION
	bne end
		jsr kiki_start_falling

	end:
	rts
.)


kiki_start_jabbing:
.(
	; Set the appropriate animation
	lda #<kiki_anim_jab
	sta tmpfield13
	lda #>kiki_anim_jab
	sta tmpfield14
	jsr set_player_animation

	; Set the player's state
	lda #KIKI_STATE_JABBING
	sta player_a_state, x

	; Initialize the clock
	lda #0
	sta player_a_state_clock,x

	rts
.)

kiki_tick_jabbing:
.(
	jsr kiki_global_tick

	KIKI_STATE_JAB_DURATION = 12
	KIKI_STATE_JAB_FRICTION = $20

	inc player_a_state_clock, x

	lda player_a_state_clock, x
	cmp #KIKI_STATE_JAB_DURATION
	bne update_velocity

		jsr kiki_start_idle
		jmp end

	update_velocity:
		; Do not move, velocity tends toward vector (0,0)
		lda #$00
		sta tmpfield4
		sta tmpfield3
		sta tmpfield2
		sta tmpfield1
		lda #KIKI_STATE_JAB_FRICTION
		sta tmpfield5
		jsr merge_to_player_velocity

	end:
	rts
.)

kiki_input_jabbing:
.(
	; Allow to cut the animation for another jab
	lda controller_a_btns, x
	cmp #CONTROLLER_INPUT_JAB
	bne end
		jsr kiki_start_jabbing

	end:
	rts
.)


kiki_start_neutral_aerial:
.(
	; Set the appropriate animation
	lda #<kiki_anim_aerial_neutral
	sta tmpfield13
	lda #>kiki_anim_aerial_neutral
	sta tmpfield14
	jsr set_player_animation

	; Set the player's state
	lda #KIKI_STATE_NEUTRAL_AERIAL
	sta player_a_state, x

	; Initialize the clock
	lda #0
	sta player_a_state_clock,x

	rts
.)

kiki_tick_neutral_aerial:
.(
	jsr kiki_global_tick

	KIKI_STATE_NEUTRAL_AERIAL_DURATION = 12

	jsr apply_player_gravity

	inc player_a_state_clock, x
	lda player_a_state_clock, x
	cmp #KIKI_STATE_NEUTRAL_AERIAL_DURATION
	bne end
		jsr kiki_start_falling

	end:
	rts
.)


kiki_start_counter_guard:
.(
	; Set the appropriate animation
	lda #<kiki_anim_counter_guard
	sta tmpfield13
	lda #>kiki_anim_counter_guard
	sta tmpfield14
	jsr set_player_animation

	; Set the player's state
	lda #KIKI_STATE_COUNTER_GUARD
	sta player_a_state, x

	; Initialize the clock
	lda #0
	sta player_a_state_clock,x

	rts
.)

KIKI_STATE_COUNTER_GUARD_ACTIVE_DURATION = 12
kiki_tick_counter_guard:
.(
	jsr kiki_global_tick

	KIKI_STATE_COUNTER_GUARD_TOTAL_DURATION = 24

	jsr apply_player_gravity

	inc player_a_state_clock, x

	lda player_a_state_clock, x
	cmp #KIKI_STATE_COUNTER_GUARD_ACTIVE_DURATION
	bne check_total_duration

		; Active duration is over, display it by switching to weak animation
		lda #<kiki_anim_counter_weak
		sta tmpfield13
		lda #>kiki_anim_counter_weak
		sta tmpfield14
		jsr set_player_animation

	check_total_duration:
	cmp #KIKI_STATE_COUNTER_GUARD_TOTAL_DURATION
	bne end

		; Total duration is over, return to a neutral state
		jsr kiki_start_falling

	end:
	rts
.)

kiki_hurt_counter_guard:
.(
	striker_player = tmpfield10
	stroke_player = tmpfield11

	lda stroke_player
	pha
	lda striker_player
	pha

	; Strike if still active, else get hurt
	lda player_a_state_clock, x
	cmp #KIKI_STATE_COUNTER_GUARD_ACTIVE_DURATION+1
	bcs hurt

		ldy striker_player
		lda HITBOX_DISABLED
		sta player_a_hitbox_enabled, y

		jsr kiki_start_counter_strike
		jmp end
	hurt:
		jsr hurt_player

	end:
	pla
	sta striker_player
	pla
	sta stroke_player
	rts
.)


kiki_start_counter_strike:
.(
	; Set the appropriate animation
	lda #<kiki_anim_counter_strike
	sta tmpfield13
	lda #>kiki_anim_counter_strike
	sta tmpfield14
	jsr set_player_animation

	; Set the player's state
	lda #KIKI_STATE_COUNTER_STRIKE
	sta player_a_state, x

	; Initialize the clock
	lda #0
	sta player_a_state_clock,x

	rts
.)

kiki_tick_counter_strike:
.(
	jsr kiki_global_tick

	KIKI_STATE_COUNTER_STRIKE_DURATION = 12

	jsr apply_player_gravity

	inc player_a_state_clock, x
	lda player_a_state_clock, x
	cmp #KIKI_STATE_COUNTER_STRIKE_DURATION
	bne end
		jsr kiki_start_falling

	end:
	rts
.)

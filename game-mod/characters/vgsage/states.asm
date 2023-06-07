!define "char_name" {vgsage}
!define "char_name_upper" {VGSAGE}

;
; States index
;

VGSAGE_STATE_THROWN = PLAYER_STATE_THROWN                             ;  0
VGSAGE_STATE_RESPAWN_INVISIBLE = PLAYER_STATE_RESPAWN                 ;  1
VGSAGE_STATE_INNEXISTANT = PLAYER_STATE_INNEXISTANT                   ;  2
VGSAGE_STATE_SPAWN = PLAYER_STATE_SPAWN                               ;  3
VGSAGE_STATE_OWNED = PLAYER_STATE_OWNED                               ;  4
VGSAGE_STATE_IDLE = PLAYER_STATE_STANDING                             ;  5
VGSAGE_STATE_RUNNING = PLAYER_STATE_RUNNING                           ;  6
VGSAGE_STATE_RESPAWN_PLATFORM = CUSTOM_PLAYER_STATES_BEGIN + 0        ;  7
VGSAGE_STATE_JUMPING = CUSTOM_PLAYER_STATES_BEGIN + 1                 ;  8
VGSAGE_STATE_WALLJUMPING = CUSTOM_PLAYER_STATES_BEGIN + 2             ;  9
VGSAGE_STATE_FALLING = CUSTOM_PLAYER_STATES_BEGIN + 3                 ;  a
VGSAGE_STATE_HELPLESS = CUSTOM_PLAYER_STATES_BEGIN + 4                ;  b
VGSAGE_STATE_LANDING = CUSTOM_PLAYER_STATES_BEGIN + 5                 ;  c
VGSAGE_STATE_CRASHING = CUSTOM_PLAYER_STATES_BEGIN + 6                ;  d
VGSAGE_STATE_SHIELDING = CUSTOM_PLAYER_STATES_BEGIN + 7               ;  e
VGSAGE_STATE_SHIELDLAG = CUSTOM_PLAYER_STATES_BEGIN + 8               ;  f
VGSAGE_STATE_JABBING = CUSTOM_PLAYER_STATES_BEGIN + 9                 ; 10
VGSAGE_STATE_UP_TILT = CUSTOM_PLAYER_STATES_BEGIN + 10                ; 11
VGSAGE_STATE_DOWN_TILT = CUSTOM_PLAYER_STATES_BEGIN + 11              ; 12
VGSAGE_STATE_SIDE_TILT = CUSTOM_PLAYER_STATES_BEGIN + 12              ; 13
VGSAGE_STATE_AERIAL_NEUTRAL = CUSTOM_PLAYER_STATES_BEGIN + 13         ; 14
VGSAGE_STATE_AERIAL_UP = CUSTOM_PLAYER_STATES_BEGIN + 14              ; 15
VGSAGE_STATE_AERIAL_DOWN = CUSTOM_PLAYER_STATES_BEGIN + 15            ; 16
VGSAGE_STATE_AERIAL_SIDE = CUSTOM_PLAYER_STATES_BEGIN + 16            ; 17
VGSAGE_STATE_SPECIAL_NEUTRAL_CHARGE = CUSTOM_PLAYER_STATES_BEGIN + 17 ; 18
VGSAGE_STATE_SPECIAL_NEUTRAL_PUNCH = CUSTOM_PLAYER_STATES_BEGIN + 18  ; 19
VGSAGE_STATE_SPECIAL_NEUTRAL_STEP_1 = CUSTOM_PLAYER_STATES_BEGIN + 19 ; 1a
VGSAGE_STATE_SPECIAL_NEUTRAL_STEP_2 = CUSTOM_PLAYER_STATES_BEGIN + 20 ; 1b
VGSAGE_STATE_SPECIAL_NEUTRAL_STEP_3 = CUSTOM_PLAYER_STATES_BEGIN + 21 ; 1c
VGSAGE_STATE_SPECIAL_NEUTRAL_STEP_4 = CUSTOM_PLAYER_STATES_BEGIN + 22 ; 1d
VGSAGE_STATE_SPECIAL_NEUTRAL_STEP_5 = CUSTOM_PLAYER_STATES_BEGIN + 23 ; 1e
VGSAGE_STATE_SPECIAL_UP_CHARGE = CUSTOM_PLAYER_STATES_BEGIN + 24      ; 1f
VGSAGE_STATE_SPECIAL_UP_JUMP = CUSTOM_PLAYER_STATES_BEGIN + 25        ; 20
VGSAGE_STATE_SPECIAL_UP_HELPLESS = CUSTOM_PLAYER_STATES_BEGIN + 26    ; 21
VGSAGE_STATE_SPECIAL_DOWN_ROLL = CUSTOM_PLAYER_STATES_BEGIN + 27      ; 22
VGSAGE_STATE_SPECIAL_DOWN_FALL = CUSTOM_PLAYER_STATES_BEGIN + 28      ; 23
VGSAGE_STATE_SPECIAL_SIDE_CHARGE = CUSTOM_PLAYER_STATES_BEGIN + 29    ; 24
VGSAGE_STATE_SPECIAL_SIDE_MOVE = CUSTOM_PLAYER_STATES_BEGIN + 30      ; 25
VGSAGE_STATE_SPECIAL_SIDE_LAND = CUSTOM_PLAYER_STATES_BEGIN + 31      ; 26

;
; Gameplay constants
;

                            ; sinbad pepper kiki
VGSAGE_AERIAL_SPEED = $00d0 ; 0100 0100 0100
VGSAGE_AERIAL_DIRECTIONAL_INFLUENCE_STRENGTH = $80 ; 80 80 80
VGSAGE_AIR_FRICTION_STRENGTH = 21 ; 7 7 7
VGSAGE_FASTFALL_SPEED = $0600 ; 500 600 400
VGSAGE_GROUND_FRICTION_STRENGTH = $40 ; 40 40 40
VGSAGE_JUMP_POWER = $0400 ; 480 540 480
VGSAGE_JUMP_SHORT_HOP_POWER = $0102 ; 102 102 102
VGSAGE_JUMP_SHORT_HOP_EXTRA_TIME_PAL = 4 ; 4 4 4 ; Number of frames after jumpsquat at which shorthop is handled
VGSAGE_JUMP_SHORT_HOP_EXTRA_TIME_NTSC = 5 ; 5 5 5
VGSAGE_JUMP_SQUAT_DURATION_PAL = 4 ; 4 4 4
VGSAGE_JUMP_SQUAT_DURATION_NTSC = 5 ; 5 5 5
VGSAGE_LANDING_MAX_VELOCITY = $0200 ; 200 200 200
VGSAGE_MAX_NUM_AERIAL_JUMPS = 1 ; 1 1 1
VGSAGE_MAX_WALLJUMPS = 1 ; 1 1 1
VGSAGE_RUNNING_INITIAL_VELOCITY = $0280 ; 100 100 100
VGSAGE_RUNNING_MAX_VELOCITY = $0120 ; 200 180 180
VGSAGE_RUNNING_ACCELERATION = $10 ; 40 40 40
VGSAGE_TECH_SPEED = $0380 ; 400 400 400
VGSAGE_WALL_JUMP_SQUAT_END = 4 ; 4 4 4
VGSAGE_WALL_JUMP_VELOCITY_V = $0480 ; 480 480 3c0
VGSAGE_WALL_JUMP_VELOCITY_H = $0100 ; 100 100 80

;
; Constants data
;

!include "characters/std_constant_tables.asm"

;
; Implementation
;

vgsage_init:
vgsage_global_onground:
.(
	; Initialize walljump counter
	lda #VGSAGE_MAX_WALLJUMPS
	sta player_a_walljump, x
	rts
.)

; Input table for aerial moves, special values are
;  fast_fall - mandatorily on INPUT_NONE to take effect on release of DOWN
;  jump      - automatically choose between aerial jump or wall jump
;  no_input  - expected default
!define "VGSAGE_AERIAL_INPUTS_TABLE" {
	.(
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
		.byt <fast_fall,                   <vgsage_start_spe_side
		.byt <vgsage_start_spe_side,       <jump
		.byt <jump,                        <jump
		.byt <vgsage_start_aerial_side,    <vgsage_start_aerial_side
		.byt <vgsage_start_aerial_down,    <vgsage_start_aerial_up
		.byt <vgsage_start_aerial_neutral, <vgsage_start_aerial_spe
		.byt <vgsage_start_spe_up,         <vgsage_start_spe_down
		.byt <vgsage_start_aerial_up,      <vgsage_start_aerial_up
		.byt <vgsage_start_spe_up,         <vgsage_start_spe_up
		.byt <vgsage_start_aerial_down,    <vgsage_start_aerial_down
		.byt <vgsage_start_spe_down,       <vgsage_start_spe_down
		controller_callbacks_hi:
		.byt >fast_fall,                   >vgsage_start_spe_side
		.byt >vgsage_start_spe_side,       >jump
		.byt >jump,                        >jump
		.byt >vgsage_start_aerial_side,    >vgsage_start_aerial_side
		.byt >vgsage_start_aerial_down,    >vgsage_start_aerial_up
		.byt >vgsage_start_aerial_neutral, >vgsage_start_aerial_spe
		.byt >vgsage_start_spe_up,         >vgsage_start_spe_down
		.byt >vgsage_start_aerial_up,      >vgsage_start_aerial_up
		.byt >vgsage_start_spe_up,         >vgsage_start_spe_up
		.byt >vgsage_start_aerial_down,    >vgsage_start_aerial_down
		.byt >vgsage_start_spe_down,       >vgsage_start_spe_down
		controller_default_callback:
		.word no_input
		&INPUT_TABLE_LENGTH = controller_callbacks_lo - controller_inputs
	.)
}

; Input table for idle state, special values are
;  input_idle_jump_left - Force LEFT direction and jump
;  input_idle_jump_right - Force RIGHT direction and jump
;  input_idle_tilt_left - Left tilt
;  input_idle_tilt_right - Right tilt
;  input_idle_left - Run to the left
;  input_idle_right - Run to the right
;  no_input - Default
!define "VGSAGE_IDLE_INPUTS_TABLE" {
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
		.byt <input_idle_left,            <input_idle_right
		.byt <vgsage_start_jumping,       <input_idle_jump_right
		.byt <input_idle_jump_left,       <vgsage_start_jabbing
		.byt <input_idle_tilt_left,       <input_idle_tilt_right
		.byt <vgsage_start_special,       <vgsage_start_spe_side_right
		.byt <vgsage_start_spe_side_left, <vgsage_start_down_tilt
		.byt <vgsage_start_spe_up,        <vgsage_start_spe_down
		.byt <vgsage_start_up_tilt,       <vgsage_start_shielding
		.byt <vgsage_start_shielding,     <vgsage_start_shielding
		.byt <vgsage_start_spe_up,        <vgsage_start_spe_up
		.byt <vgsage_start_up_tilt,       <vgsage_start_up_tilt
		.byt <vgsage_start_spe_down,      <vgsage_start_spe_down
		.byt <vgsage_start_down_tilt,     <vgsage_start_down_tilt
		controller_callbacks_hi:
		.byt >input_idle_left,            >input_idle_right
		.byt >vgsage_start_jumping,       >input_idle_jump_right
		.byt >input_idle_jump_left,       >vgsage_start_jabbing
		.byt >input_idle_tilt_left,       >input_idle_tilt_right
		.byt >vgsage_start_special,       >vgsage_start_spe_side_right
		.byt >vgsage_start_spe_side_left, >vgsage_start_down_tilt
		.byt >vgsage_start_spe_up,        >vgsage_start_spe_down
		.byt >vgsage_start_up_tilt,       >vgsage_start_shielding
		.byt >vgsage_start_shielding,     >vgsage_start_shielding
		.byt >vgsage_start_spe_up,        >vgsage_start_spe_up
		.byt >vgsage_start_up_tilt,       >vgsage_start_up_tilt
		.byt >vgsage_start_spe_down,      >vgsage_start_spe_down
		.byt >vgsage_start_down_tilt,     >vgsage_start_down_tilt
		controller_default_callback:
		.word no_input
		&INPUT_TABLE_LENGTH = controller_callbacks_lo - controller_inputs
	.)
}

; Input table for running state, special values are
;  input_running_left - Change running direction to the left (if not already running to the left)
;  input_runnning_right - Change running direction to the right (if not already running to the right)
!define "VGSAGE_RUNNING_INPUTS_TABLE" {
	.(
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
		.byt <input_running_left,           <input_running_right
		.byt <vgsage_start_jumping,         <vgsage_start_jumping
		.byt <vgsage_start_jumping,         <vgsage_start_side_tilt_left
		.byt <vgsage_start_side_tilt_right, <vgsage_start_special
		.byt <vgsage_start_spe_side,        <vgsage_start_spe_side
		.byt <vgsage_start_spe_up,          <vgsage_start_spe_down
		.byt <vgsage_start_shielding,       <vgsage_start_shielding
		.byt <vgsage_start_spe_up,          <vgsage_start_spe_up
		.byt <vgsage_start_up_tilt,         <vgsage_start_up_tilt
		.byt <vgsage_start_spe_down,        <vgsage_start_spe_down
		.byt <vgsage_start_down_tilt,       <vgsage_start_down_tilt
		.byt <vgsage_start_down_tilt
		controller_callbacks_hi:
		.byt >input_running_left,           >input_running_right
		.byt >vgsage_start_jumping,         >vgsage_start_jumping
		.byt >vgsage_start_jumping,         >vgsage_start_side_tilt_left
		.byt >vgsage_start_side_tilt_right, >vgsage_start_special
		.byt >vgsage_start_spe_side,        >vgsage_start_spe_side
		.byt >vgsage_start_spe_up,          >vgsage_start_spe_down
		.byt >vgsage_start_shielding,       >vgsage_start_shielding
		.byt >vgsage_start_spe_up,          >vgsage_start_spe_up
		.byt >vgsage_start_up_tilt,         >vgsage_start_up_tilt
		.byt >vgsage_start_spe_down,        >vgsage_start_spe_down
		.byt >vgsage_start_down_tilt,       >vgsage_start_down_tilt
		.byt >vgsage_start_down_tilt
		controller_default_callback:
		.word vgsage_start_idle
		&INPUT_TABLE_LENGTH = controller_callbacks_lo - controller_inputs
	.)
}

; Input table for jumping state state (only used during jumpsquat), special values are
;  no_input - default
!define "VGSAGE_JUMPSQUAT_INPUTS_TABLE" {
	.(
		controller_inputs:
		.byt CONTROLLER_INPUT_ATTACK_UP,       CONTROLLER_INPUT_SPECIAL_UP
		.byt CONTROLLER_INPUT_ATTACK_UP_LEFT,  CONTROLLER_INPUT_SPECIAL_UP_LEFT
		.byt CONTROLLER_INPUT_ATTACK_UP_RIGHT, CONTROLLER_INPUT_SPECIAL_UP_RIGHT
		controller_callbacks_lo:
		.byt <vgsage_start_up_tilt, <vgsage_start_spe_up
		.byt <vgsage_start_up_tilt, <vgsage_start_spe_up
		.byt <vgsage_start_up_tilt, <vgsage_start_spe_up
		controller_callbacks_hi:
		.byt >vgsage_start_up_tilt, >vgsage_start_spe_up
		.byt >vgsage_start_up_tilt, >vgsage_start_spe_up
		.byt >vgsage_start_up_tilt, >vgsage_start_spe_up
		controller_default_callback:
		.word no_input
		&INPUT_TABLE_LENGTH = controller_callbacks_lo - controller_inputs
	.)
}

!include "characters/std_aerial_input.asm"
!include "characters/std_crashing.asm"
!include "characters/std_thrown.asm"
!include "characters/std_respawn.asm"
!include "characters/std_innexistant.asm"
!include "characters/std_spawn.asm"
!include "characters/std_idle.asm"
!include "characters/std_running.asm"
!include "characters/std_jumping.asm"
!include "characters/std_landing.asm"
!include "characters/std_helpless.asm"
!include "characters/std_shielding.asm"
!include "characters/std_walljumping.asm"
!include "characters/std_owned.asm"

;
; Jab
;

.(
	!define "anim" {vgsage_anim_jab}
	!define "state" {VGSAGE_STATE_JABBING}
	!define "routine" {jabbing}
	!include "characters/tpl_grounded_attack.asm"

	; Points of interest in the animation (in PAL frames)
	CUT_POINT = 16 ; Point in time when we can cancel the move

	; NTSC equivalent to PAL timings (computed according to formula in anim duration tables from macros)
	CUT_POINT_NTSC = (CUT_POINT)+((((CUT_POINT)*10)/5)+9)/10

	; System-specific table for points of interest in the animation
	;  Unlike constants, values in this table are coomputed to match clock going in reverse
	cut_point:
		.byt vgsage_anim_jab_dur_pal-CUT_POINT, vgsage_anim_jab_dur_ntsc-CUT_POINT_NTSC

	&vgsage_input_jabbing:
	.(
		; Cut animation if we are above cut point, and pressing jab input
		ldy system_index ; useless, done above
		lda player_a_state_clock, x ; useless, done above
		cmp cut_point, y
		bcs ignore_input
		lda controller_a_btns, x
		cmp #CONTROLLER_INPUT_JAB
		bne ignore_input

			cut_animation:
				jmp vgsage_start_jabbing
				;No return

			ignore_input:
				; Ignore input, except for CONTROLLER_INPUT_NONE
				;  It allows to spam A to spam jabs
				jmp smart_keep_input_dirty

		;rts ; useless, no branch return
	.)
.)

;
; Up tilt
;

!define "anim" {vgsage_anim_up_tilt}
!define "state" {VGSAGE_STATE_UP_TILT}
!define "routine" {up_tilt}
!include "characters/tpl_grounded_attack.asm"

;
; Down tilt
;

!define "anim" {vgsage_anim_down_tilt}
!define "state" {VGSAGE_STATE_DOWN_TILT}
!define "routine" {down_tilt}
!include "characters/tpl_grounded_attack.asm"

;
; Side tilt
;

.(
	anim_dur:
		.byt vgsage_anim_roll_dur_pal, vgsage_anim_roll_dur_ntsc

	+vgsage_start_side_tilt_left:
	.(
		lda DIRECTION_LEFT
		sta player_a_direction, x
		jmp vgsage_start_side_tilt
		;rts ; useless, jump to subroutine
	.)

	+vgsage_start_side_tilt_right:
	.(
		lda DIRECTION_RIGHT
		sta player_a_direction, x
		;jmp vgsage_start_side_tilt ; useless, falltrhough
		;rts ; useless, jump to subroutine
	.)

	+vgsage_start_side_tilt:
	.(
		; Set player's state
		lda #VGSAGE_STATE_SIDE_TILT
		sta player_a_state, x

		; Reset clock
		ldy system_index
		lda anim_dur, y
		sta player_a_state_clock, x

		; Set the appropriate animation
		lda #<vgsage_anim_roll
		sta tmpfield13
		lda #>vgsage_anim_roll
		sta tmpfield14
		jmp set_player_animation

		;rts ; useless, jump to subroutine
	.)

	+vgsage_tick_side_tilt:
	.(
		; Tick clock
		dec player_a_state_clock, x
		bne do_tick
			jmp vgsage_start_inactive_state
			; No return, jump to subroutine
		do_tick:

		; Update velocity
		jmp vgsage_tick_running ;HACK expect tick_running to only update velocity and call global_tick
		;rts ; useless, jump to subroutine
	.)
.)

;
; Aerial neutral
;

!define "anim" {vgsage_anim_aerial_neutral}
!define "state" {VGSAGE_STATE_AERIAL_NEUTRAL}
!define "routine" {aerial_neutral}
!include "characters/tpl_aerial_attack.asm"

;
; Aerial up
;

!define "anim" {vgsage_anim_aerial_up}
!define "state" {VGSAGE_STATE_AERIAL_UP}
!define "routine" {aerial_up}
!include "characters/tpl_aerial_attack.asm"

;
; Aerial down
;

!define "anim" {vgsage_anim_aerial_down}
!define "state" {VGSAGE_STATE_AERIAL_DOWN}
!define "routine" {aerial_down}
!include "characters/tpl_aerial_attack.asm"

;
; Aerial side
;

!define "anim" {vgsage_anim_aerial_side}
!define "state" {VGSAGE_STATE_AERIAL_SIDE}
!define "routine" {aerial_side}
!include "characters/tpl_aerial_attack.asm"

;
; Grounded neutral special
;

.(
	; Step - charge
	!define "anim" {vgsage_anim_special_charge}
	!define "state" {VGSAGE_STATE_SPECIAL_NEUTRAL_CHARGE}
	!define "routine" {special}
	.(
		duration:
			.byt {anim}_dur_pal*2, {anim}_dur_ntsc*2

		+{char_name}_start_{routine}:
		.(
			; Set state
			lda #{state}
			sta player_a_state, x

			; Reset clock
			ldy system_index
			lda duration, y
			sta player_a_state_clock, x

			; Play sfx
			jsr audio_play_land

			; Set the appropriate animation
			lda #<{anim}
			sta tmpfield13
			lda #>{anim}
			sta tmpfield14
			jmp set_player_animation

			;rts ; useless, jump to subroutine
		.)

		+{char_name}_tick_{routine}:
		.(
#ifldef {char_name}_global_tick
			jsr {char_name}_global_tick
#endif

			jsr {char_name}_apply_friction_lite

			lda player_a_grounded, x
			bne no_di
				jsr {char_name}_aerial_directional_influence
			no_di:

			; Play the sfx a second time mid-animation
			ldy system_index
			lda duration, y
			lsr
			cmp player_a_state_clock, x
			;;lda player_a_state_clock, x
			;;and #%00000011

			bne sfx_ok
				jsr audio_play_land
			sfx_ok:

			dec player_a_state_clock, x
			bne end
				jmp {char_name}_start_special_punch

				; No return, jump to subroutine
			end:
			rts
		.)
	.)
	!undef "anim"
	!undef "state"
	!undef "routine"

	; Punch animation
	.(
		duration:
			.byt vgsage_anim_special_punch_dur_pal, vgsage_anim_special_punch_dur_ntsc

		&vgsage_start_special_punch:
		.(
			lda #VGSAGE_STATE_SPECIAL_NEUTRAL_PUNCH
			sta player_a_state, x

			; Stop any momentum
			lda #0
			sta player_a_velocity_v, x
			sta player_a_velocity_h, x
			sta player_a_velocity_v_low, x
			sta player_a_velocity_h_low, x

			; Init clock
			ldy system_index
			lda duration, y
			sta player_a_state_clock, x

			; Set the appropriate animation
			lda #<vgsage_anim_special_punch
			sta tmpfield13
			lda #>vgsage_anim_special_punch
			sta tmpfield14
			jmp set_player_animation
		.)

		;Note - pasted from tpl_aerial_attack_uncancellable
		+vgsage_tick_special_punch:
		.(
#ifldef {char_name}_global_tick
			jsr {char_name}_global_tick
#endif

			jsr {char_name}_apply_friction_lite

			dec player_a_state_clock, x
			bne end
				jmp {char_name}_start_inactive_state
				; No return, jump to subroutine
			end:
			rts
		.)
	.)

	+vgsage_special_hit:
	.(
		is_punch_box = player_a_custom_hitbox_value1

		; Disable hitbox
		lda #HITBOX_DISABLED
		sta player_a_hitbox_enabled, x

		; Choose action
		;  - Do nothing if not in the "punch" state (sage's animation continue during knight animation, but must be inactive)
		;  - Strong hit if connects with the punch-box
		;  - Weak hit if connects with the wind-box
		lda player_a_state, x
		cmp #VGSAGE_STATE_SPECIAL_NEUTRAL_PUNCH
		bne skip
		lda is_punch_box, x
		bne strong_hit

			; Weak hit is a windbox
			weak_hit:
			.(
				player_a_force_h_lsb = player_a_custom_hitbox_directional1_lsb
				player_a_force_h_msb = player_a_custom_hitbox_directional1_msb
				force_h_lsb = tmpfield1
				force_h_msb = tmpfield2

				;NOTE We don't check if we hit an hitbox or hurtbox
				;     Hitbox vs Hitbox collision will prevent Hitbox vs Hurtbox collision check
				;     so we cannot easily know if we collide with opponent hurtbox to push them only if it's the case.

				;NOTE We keep hitbox_enabled to HITBOX_DISABLED when hitting an hitbox
				;     It avoids multi-hits but has the unwated side effect of favoring player A when two Sage's windboxes collide
				;     Should be fixed by a refactor of hitbox vs hitbox collisions in game logic

				; Store wind power at fixed location
				lda player_a_force_h_lsb, x
				sta force_h_lsb
				lda player_a_force_h_msb, x
				sta force_h_msb

				; Add wind force to opponent's velocity
				stx player_number
				SWITCH_SELECTED_PLAYER

				lda player_a_velocity_h_low, x
				clc
				adc force_h_lsb
				sta player_a_velocity_h_low, x
				lda player_a_velocity_h, x
				adc force_h_msb
				sta player_a_velocity_h, x

				ldx player_number

				rts
			.)

			skip:
				rts

			strong_hit:
			.(
				; If we hit opponent's hitbox, we should apply parry
				.(
					cpy #HURTBOX
					beq process

						; Reenable our hitbox (we should not have disabled it in hitbox vs hitbox case)
						;NOTE requirement would be made obsolete if hitbox vs hitbox collisions were not made once per player
						lda #HITBOX_CUSTOM
						sta player_a_hitbox_enabled, x

						; Apply parry to ourself
						ldy config_player_a_character, x
						jsr parry_player

						; Apply parry to our opponent (if it is a direct hitbox)
						SWITCH_SELECTED_PLAYER
						lda player_a_hitbox_enabled, x
						cmp #HITBOX_DIRECT
						bne ok
							ldy config_player_a_character, x
							TRAMPOLINE(parry_player, characters_bank_number COMMA y, #CURRENT_BANK_NUMBER)
						ok:

						; Do not actually process hit
						rts

					process:
				.)

				; Set the appropriate animation
				lda #<vgsage_anim_special_punch_hit
				sta tmpfield13
				lda #>vgsage_anim_special_punch_hit
				sta tmpfield14
				jsr set_player_animation

				; Start Knigth's animation if the sage is on his last stock, else apply the hit directly
				lda player_a_stocks, x
				beq knight_hit
					simple_hit:
						jmp apply_hit
					knight_hit:
						; Put opponent in owned state
						SWITCH_SELECTED_PLAYER
						lda #PLAYER_STATE_OWNED
						sta player_a_state, x
						ldy config_player_a_character, x
						lda characters_start_routines_table_lsb, y
						sta tmpfield1
						lda characters_start_routines_table_msb, y
						sta tmpfield2
						TRAMPOLINE(player_state_action, characters_bank_number COMMA y, #CURRENT_BANK_NUMBER)

						; Cancel any opponent's momentum
						lda #0
						sta player_a_velocity_v_low, x
						sta player_a_velocity_v, x
						sta player_a_velocity_h_low, x
						sta player_a_velocity_h, x

						SWITCH_SELECTED_PLAYER
						;jmp vgsage_start_special_fadeout ; useless, fallthrough
			.)
	.)

	; Step - fadeout
	.(
		+vgsage_start_special_fadeout:
		.(
			lda #VGSAGE_STATE_SPECIAL_NEUTRAL_STEP_1
			sta player_a_state, x

			; Set clock
			lda #3*2
			sta player_a_state_clock, x

			; Entering state's sound effect
			stx player_number
			ldx #SFX_COUNTDOWN_REACH_IDX
			jsr audio_play_sfx_from_list
			ldx player_number

			rts
		.)

		+vgsage_tick_special_fadeout:
		.(
			; Every two ticks, advance one step of the fadeout
			.(
				lda player_a_state_clock, x
				and #%00000001
				bne ok

					; Set pallettes to current fadeout step
					stx player_number

					lda player_a_state_clock, x
					lsr
					tax

					ldy config_selected_stage
					TRAMPOLINE_POINTED(stage_routine_fadeout_lsb COMMA y, stage_routine_fadeout_msb COMMA y, stages_bank COMMA y, #CURRENT_BANK_NUMBER)

					ldx player_number

				ok:
			.)

			; Tick clock
			dec player_a_state_clock, x
			bpl end
				jmp vgsage_start_special_draw_knight
				;No return

			end:
			rts
		.)
	.)

	; Step - draw knight, and fadein to it
	.(
		&vgsage_start_special_draw_knight:
		.(
			; Set step
			lda #VGSAGE_STATE_SPECIAL_NEUTRAL_STEP_2
			sta player_a_state, x

			; Set clock
			lda #LAST_STEP
			sta player_a_state_clock, x

			; Notify we are going dirty with the screen
			inc stage_screen_effect
			lda #0
			sta stage_restore_screen_step

			; Draw knight
			;  Not in rollback - Better redraw it regularily (in vgsage_tick_special_show_knight) if it cause troubles in rollback situations
			;  In the "start" routine - It whould work well with the palette buffer writen in last tick of the fadeout step
			.(
				; Avoid drawing knight on rollback
				.(
					lda network_rollback_mode
					beq do_it
						rts
					do_it:
				.)

				; Avoid drawing knight if there is not enough space in nametable buffers
				.(
					IF_NT_BUFFERS_FREE_SPACE_LT(#illustration_buffer_end-illustration_buffer, do_it)
						rts
					do_it:
				.)

				; Save player_number
				stx player_number

				; Copy illustration buffer
				LAST_NT_BUFFER

#if 1
				ldy #0
				copy_one_byte:
					lda illustration_buffer, y
					iny
					sta nametable_buffers, x
					inx

					cpy #illustration_buffer_end-illustration_buffer
					bne copy_one_byte

				dex
				stx nt_buffers_end
#else
				; Rolled loop is 2+66*(12+5)        = 1124 cycles /  14 bytes
				; This version is 2+2+11*(6*10+6+5) =  785 cycles /  54 bytes
				; Fully unrolled is 66*10           =  660 cycles / 462 bytes
				ldy #0
				clc ;NOTE - beware not setting the carry flag in the loop
				copy_one_byte:
					lda illustration_buffer, y
					sta nametable_buffers, x
					inx

					lda illustration_buffer+1, y
					sta nametable_buffers, x
					inx

					lda illustration_buffer+2, y
					sta nametable_buffers, x
					inx

					lda illustration_buffer+3, y
					sta nametable_buffers, x
					inx

					lda illustration_buffer+4, y
					sta nametable_buffers, x
					inx

					lda illustration_buffer+5, y
					sta nametable_buffers, x
					inx

					tya
					adc #6 ; Will never set carry flag (we stop at 66)
					tay

					cpy #illustration_buffer_end-illustration_buffer ; Does not set carry flag until we leave the loop
					bne copy_one_byte

				dex
				stx nt_buffers_end
#endif

				; Restore X
				ldx player_number
			.)
			;NOTE this block does not always return

			rts

#define ATT(br,bl,tr,tl) ((br << 6) + (bl << 4) + (tr << 2) + tl)
			illustration_buffer:
			.byt NT_BUFFER_ATTRIBUTES
			illustration:
			.byt ATT(0,0,1,1), ATT(1,0,0,0), ATT(2,2,1,1), ATT(2,2,1,1), ATT(0,1,0,0), ATT(0,0,0,0), ATT(0,0,0,0), ATT(0,0,0,0)
			.byt ATT(0,0,0,0), ATT(2,1,2,1), ATT(2,2,2,2), ATT(2,1,3,1), ATT(3,3,1,3), ATT(1,2,0,1), ATT(0,0,0,0), ATT(0,0,0,0)
			.byt ATT(1,0,1,0), ATT(2,2,2,2), ATT(2,2,2,2), ATT(2,2,1,2), ATT(2,1,3,2), ATT(3,3,2,3), ATT(1,3,0,1), ATT(0,0,0,0)
			.byt ATT(2,1,2,1), ATT(2,2,2,2), ATT(2,2,2,2), ATT(2,2,2,2), ATT(2,2,2,1), ATT(3,2,3,2), ATT(3,3,3,3), ATT(1,2,0,1)
			.byt ATT(1,0,2,1), ATT(1,2,0,1), ATT(0,0,0,0), ATT(3,3,2,0), ATT(0,0,2,2), ATT(3,3,0,0), ATT(1,0,0,0), ATT(1,2,1,1)
			.byt ATT(0,0,0,0), ATT(1,0,2,1), ATT(2,2,0,2), ATT(1,2,0,0), ATT(0,0,0,0), ATT(2,1,0,0), ATT(1,2,2,2), ATT(0,0,0,1)
			.byt ATT(1,1,0,0), ATT(0,0,0,0), ATT(0,0,1,1), ATT(1,0,2,1), ATT(1,1,2,2), ATT(0,1,1,2), ATT(0,0,0,1), ATT(0,0,0,0)
			.byt ATT(2,2,2,2), ATT(2,2,1,1), ATT(1,1,0,0), ATT(0,0,0,0), ATT(0,0,0,0), ATT(0,0,0,0), ATT(1,0,0,0), ATT(2,2,1,1)
			stop_byte:
			.byt NT_BUFFER_END
			illustration_buffer_end:
#undef ATT
		.)

		+vgsage_tick_special_draw_knight:
		.(
			; Avoid to write the buffer in rollback
			lda network_rollback_mode
			bne skip_fade_in

			; Avoid to write the buffer if no space left
			IF_NT_BUFFERS_FREE_SPACE_GE(#1+3+16+1, skip_fade_in)

				do_fade_in:
					; Change palette to fade into the knight's illustration
					stx player_number

					ldy player_a_state_clock, x

					lda #<fadein_palette_header
					sta tmpfield1
					lda #>fadein_palette_header
					sta tmpfield2
					lda fadein_lsb, y
					sta tmpfield3
					lda fadein_msb, y
					sta tmpfield4
					jsr construct_nt_buffer

					ldx player_number

			skip_fade_in:

			; Update clock
			dec player_a_state_clock, x
			bpl end
				jmp vgsage_start_special_show_knight
				; No return, jump to subroutine

			end:
			rts
		.)

		&fadein_palette:
		.byt $0f,$0f,$0f,$0f, $0f,$03,$03,$13, $0f,$32,$32,$20, $0f,$20,$20,$20
		; more opaque version
		;.byt $0f,$0f,$0f,$0f, $0f,$03,$03,$03, $0f,$32,$32,$32, $0f,$20,$20,$20
		; lighter version, seeing more of the stage, less of the fadein
		;.byt $0f,$21,$00,$10, $0f,$03,$03,$13, $0f,$32,$32,$20, $0f,$20,$20,$20
		fadein_palette_1:
		.byt $0f,$0f,$0f,$0f, $0f,$03,$03,$13, $0f,$22,$22,$32, $0f,$10,$10,$20
		fadein_palette_2:
		.byt $0f,$0f,$0f,$0f, $0f,$03,$0f,$03, $0f,$12,$12,$22, $0f,$00,$00,$10
		fadein_palette_3:
		.byt $0f,$0f,$0f,$0f, $0f,$0f,$0f,$0f, $0f,$02,$02,$0f, $0f,$0f,$0f,$00
		fadein_lsb:
		.byt <fadein_palette
		.byt <fadein_palette_1, <fadein_palette_2, <fadein_palette_3
		fadein_msb:
		.byt >fadein_palette
		.byt >fadein_palette_1, >fadein_palette_2, >fadein_palette_3

		&fadein_palette_header:
		.byt $3f, $00, $10

		LAST_STEP = fadein_msb - fadein_lsb - 1
	.)

	; Step - wait a bit to show the knight
	.(
		KNIGHT_DISPLAY_DURATION = 25
		duration_table(KNIGHT_DISPLAY_DURATION, knight_display_duration)

		&vgsage_start_special_show_knight:
		.(
			lda #VGSAGE_STATE_SPECIAL_NEUTRAL_STEP_3
			sta player_a_state, x

			ldy system_index
			lda knight_display_duration, y
			sta player_a_state_clock, x

			jmp audio_play_title_screen_subtitle

			;rts
		.)

		+vgsage_tick_special_show_knight:
		.(
			dec player_a_state_clock, x
			bne do_tick
				jmp vgsage_start_special_draw_slash
			do_tick:

			; Rewrite knigth's palette, in case rollback put us here
			lda network_rollback_mode
			bne end

				stx player_number

				lda #<fadein_palette_header
				sta tmpfield1
				lda #>fadein_palette_header
				sta tmpfield2
				lda #<fadein_palette
				sta tmpfield3
				lda #>fadein_palette
				sta tmpfield4
				jsr construct_nt_buffer

				ldx player_number

			end:
			rts
		.)
	.)

	; Step - Slash animation
	.(
		&vgsage_start_special_draw_slash:
		.(
			lda #VGSAGE_STATE_SPECIAL_NEUTRAL_STEP_4
			sta player_a_state, x

			lda #(NUM_ANIM_STEPS-1)*2
			sta player_a_state_clock, x

			jmp audio_play_parry

			;rts ; Useless, jump to subroutine
		.)

		+vgsage_tick_special_draw_slash:
		.(
			; Avoid to create nt buffer in rollback mode
			lda network_rollback_mode
			bne end_animating

			; Avoid to create nt buffer if there is no space for it
			IF_NT_BUFFERS_FREE_SPACE_GE(#1+3+32+1, end_animating)

				; Step the animation
				.(
					lda player_a_state_clock, x
					and #%00000001
					bne ok

						stx player_number

						lda player_a_state_clock, x
						lsr
						tay

						lda anim_headers_lsb, y
						cmp #NOOP
						beq skip

							sta tmpfield1
							lda anim_headers_msb, y
							sta tmpfield2
							lda anim_frames_lsb, y
							sta tmpfield3
							lda anim_frames_msb, y
							sta tmpfield4
							jsr construct_nt_buffer

						skip:
						ldx player_number

					ok:
				.)

			end_animating:

			; Tick clock
			dec player_a_state_clock, x
			bpl end
				jmp vgsage_start_restore_screen
				; No return, jump to subroutine

			end:
			rts

#define ATT(br,bl,tr,tl) ((br << 6) + (bl << 4) + (tr << 2) + tl)
			anim_1: ;bottom
			.byt ATT(1,0,2,1), ATT(1,2,0,1), ATT(0,0,0,0), ATT(3,3,2,0), ATT(0,0,2,2), ATT(3,3,0,0), ATT(1,0,0,0), ATT(1,2,1,1)
			.byt ATT(0,0,0,0), ATT(1,0,2,1), ATT(2,2,0,2), ATT(1,2,0,0), ATT(0,0,0,0), ATT(2,1,0,0), ATT(1,2,2,2), ATT(0,0,0,1)
			.byt ATT(1,1,0,0), ATT(0,0,0,0), ATT(3,3,3,3), ATT(3,3,3,3), ATT(1,1,2,2), ATT(0,1,1,2), ATT(0,0,0,1), ATT(0,0,0,0)
			.byt ATT(2,2,2,2), ATT(3,3,3,3), ATT(3,3,3,3), ATT(3,3,3,3), ATT(0,0,0,0), ATT(0,0,0,0), ATT(1,0,0,0), ATT(2,2,1,1)
			anim_2: ;bottom
			.byt ATT(1,0,2,1), ATT(1,2,0,1), ATT(0,0,0,0), ATT(3,3,2,0), ATT(3,3,3,3), ATT(3,3,3,3), ATT(3,3,3,3), ATT(1,2,1,1)
			.byt ATT(0,0,0,0), ATT(1,0,2,1), ATT(2,2,0,2), ATT(3,3,3,3), ATT(3,3,3,3), ATT(3,3,3,3), ATT(1,2,2,2), ATT(0,0,0,1)
			.byt ATT(1,1,0,0), ATT(0,0,0,0), ATT(3,3,3,3), ATT(3,3,3,3), ATT(3,3,3,3), ATT(0,1,1,2), ATT(0,0,0,1), ATT(0,0,0,0)
			.byt ATT(2,2,2,2), ATT(3,3,3,3), ATT(3,3,3,3), ATT(3,3,3,3), ATT(0,0,0,0), ATT(0,0,0,0), ATT(1,0,0,0), ATT(2,2,1,1)
			anim_3: ;top
			.byt ATT(0,0,1,1), ATT(1,0,0,0), ATT(2,2,1,1), ATT(2,2,1,1), ATT(0,1,0,0), ATT(0,0,0,0), ATT(0,0,0,0), ATT(0,0,0,0)
			.byt ATT(0,0,0,0), ATT(2,1,2,1), ATT(2,2,2,2), ATT(2,1,3,1), ATT(3,3,1,3), ATT(1,2,0,1), ATT(0,0,0,0), ATT(3,3,3,3)
			.byt ATT(1,0,1,0), ATT(2,2,2,2), ATT(2,2,2,2), ATT(2,2,1,2), ATT(2,1,3,2), ATT(3,3,2,3), ATT(3,3,3,3), ATT(3,3,3,3)
			.byt ATT(2,1,2,1), ATT(2,2,2,2), ATT(2,2,2,2), ATT(2,2,2,2), ATT(2,2,2,1), ATT(3,3,3,3), ATT(3,3,3,3), ATT(3,3,3,3)
			anim_4: ;bottom
			.byt ATT(1,0,2,1), ATT(1,2,0,1), ATT(3,3,3,3), ATT(3,3,3,3), ATT(3,3,3,3), ATT(3,3,3,3), ATT(3,3,3,3), ATT(3,3,3,3)
			.byt ATT(0,0,0,0), ATT(3,3,3,3), ATT(3,3,3,3), ATT(3,3,3,3), ATT(3,3,3,3), ATT(3,3,3,3), ATT(3,3,3,3), ATT(3,3,3,3)
			.byt ATT(3,3,3,3), ATT(3,3,3,3), ATT(3,3,3,3), ATT(3,3,3,3), ATT(3,3,3,3), ATT(3,3,3,3), ATT(3,3,3,3), ATT(0,0,0,0)
			.byt ATT(3,3,3,3), ATT(3,3,3,3), ATT(3,3,3,3), ATT(3,3,3,3), ATT(3,3,3,3), ATT(3,3,3,3), ATT(1,0,0,0), ATT(2,2,1,1)
			anim_5: ;top
			.byt ATT(0,0,1,1), ATT(1,0,0,0), ATT(2,2,1,1), ATT(2,2,1,1), ATT(0,1,0,0), ATT(0,0,0,0), ATT(3,3,3,3), ATT(3,3,3,3)
			.byt ATT(0,0,0,0), ATT(2,1,2,1), ATT(2,2,2,2), ATT(2,1,3,1), ATT(3,3,1,3), ATT(3,3,3,3), ATT(3,3,3,3), ATT(3,3,3,3)
			.byt ATT(1,0,1,0), ATT(2,2,2,2), ATT(2,2,2,2), ATT(2,2,1,2), ATT(3,3,3,3), ATT(3,3,3,3), ATT(3,3,3,3), ATT(3,3,3,3)
			.byt ATT(2,1,2,1), ATT(2,2,2,2), ATT(2,2,2,2), ATT(3,3,3,3), ATT(3,3,3,3), ATT(3,3,3,3), ATT(3,3,3,3), ATT(3,3,3,3)
			anim_6: ;bottom
			.byt ATT(1,0,2,1), ATT(1,2,0,1), ATT(0,0,0,0), ATT(3,3,2,0), ATT(0,0,0,0), ATT(0,0,0,0), ATT(0,0,0,0), ATT(1,2,1,1)
			.byt ATT(0,0,0,0), ATT(1,0,2,1), ATT(2,2,0,2), ATT(0,0,0,0), ATT(0,0,0,0), ATT(0,0,0,0), ATT(1,2,2,2), ATT(0,0,0,1)
			.byt ATT(1,1,0,0), ATT(0,0,0,0), ATT(0,0,0,0), ATT(0,0,0,0), ATT(0,0,0,0), ATT(0,1,1,2), ATT(0,0,0,1), ATT(0,0,0,0)
			.byt ATT(2,2,2,2), ATT(0,0,0,0), ATT(0,0,0,0), ATT(0,0,0,0), ATT(0,0,0,0), ATT(0,0,0,0), ATT(1,0,0,0), ATT(2,2,1,1)
			anim_7: ;top
			.byt ATT(0,0,1,1), ATT(1,0,0,0), ATT(2,2,1,1), ATT(2,2,1,1), ATT(0,1,0,0), ATT(0,0,0,0), ATT(0,0,0,0), ATT(0,0,0,0)
			.byt ATT(0,0,0,0), ATT(2,1,2,1), ATT(2,2,2,2), ATT(2,1,3,1), ATT(3,3,1,3), ATT(1,2,0,1), ATT(0,0,0,0), ATT(0,0,0,0)
			.byt ATT(1,0,1,0), ATT(2,2,2,2), ATT(2,2,2,2), ATT(2,2,1,2), ATT(2,1,3,2), ATT(3,3,2,3), ATT(0,0,0,0), ATT(0,0,0,0)
			.byt ATT(2,1,2,1), ATT(2,2,2,2), ATT(2,2,2,2), ATT(2,2,2,2), ATT(2,2,2,1), ATT(0,0,0,0), ATT(0,0,0,0), ATT(0,0,0,0)
#undef ATT
			NOOP = 255
			anim_frames_lsb:
			.byt <anim_7, <anim_6, NOOP, <anim_3, <anim_2, <anim_1, <anim_5, <anim_4
			anim_frames_msb:
			.byt >anim_7, >anim_6, NOOP, >anim_3, >anim_2, >anim_1, >anim_5, >anim_4

			top_header:
			.byt $23, $c0, $20
			bot_header:
			.byt $23, $e0, $20

			anim_headers_lsb:
			.byt <top_header, <bot_header, NOOP, <top_header, <bot_header, <bot_header, <top_header, <bot_header
			anim_headers_msb:
			.byt >top_header, >bot_header, NOOP, >top_header, >bot_header, >bot_header, >top_header, >bot_header

			&NUM_ANIM_STEPS = anim_headers_msb - anim_headers_lsb
		.)
	.)

	; Step - Restore screen
	;  NOTE - character's logic being called after stage logic,
	;         it should be safe to notify end of effect (triggering screen repair) at the end of previous step,
	;         saving one step.
	;         It is so indirect (calling code that may change) and a meager gain (one frame and some bytes),
	;         better go the safest route and keep that step.
	.(
		&vgsage_start_restore_screen:
		.(
			lda #VGSAGE_STATE_SPECIAL_NEUTRAL_STEP_5
			sta player_a_state, x
			rts
		.)

		+vgsage_tick_special_restore_screen:
		.(
			; Restore screen
			lda #FADE_LEVEL_NORMAL
			sta stage_fade_level
			dec stage_screen_effect
			jsr apply_hit

			; Avoid directional movement of screen shake (it is weird with knight's illustration)
			lda #0
			sta screen_shake_current_x
			sta screen_shake_current_y
			sta screen_shake_speed_h
			sta screen_shake_speed_v

			; Come back to a playable state
			jmp vgsage_start_inactive_state

			;rts ; useless, jump to subroutine
		.)
	.)

	apply_hit:
	.(
		DAMAGES = 23
		BASE_H = -900
		FORCE_H = -40
		BASE_V = -1500
		FORCE_V = 0

		; Hurt opponent
		.(
			; Rewrite hitbox knockback info to match sage's punch values
			lda #DAMAGES
			sta player_a_hitbox_damages, x
			lda #<BASE_V
			sta player_a_hitbox_base_knock_up_v_low, x
			lda #>BASE_V
			sta player_a_hitbox_base_knock_up_v_high, x
			lda #<FORCE_V
			sta player_a_hitbox_force_v_low, x
			lda #>FORCE_V
			sta player_a_hitbox_force_v, x

			lda player_a_direction, x
			bne right
				left:
					lda #<BASE_H
					sta player_a_hitbox_base_knock_up_h_low, x
					lda #>BASE_H
					sta player_a_hitbox_base_knock_up_h_high, x
					lda #<FORCE_H
					sta player_a_hitbox_force_h_low, x
					lda #>FORCE_H
					sta player_a_hitbox_force_h, x

					jmp hitbox_ok

				right:
					lda #<-BASE_H
					sta player_a_hitbox_base_knock_up_h_low, x
					lda #>-BASE_H
					sta player_a_hitbox_base_knock_up_h_high, x
					lda #<-FORCE_H
					sta player_a_hitbox_force_h_low, x
					lda #>-FORCE_H
					sta player_a_hitbox_force_h, x

			hitbox_ok:

			; Call opponent's onhurt routine
			.(
				; Save X
				txa:pha

				; Set current_player/opponent_player parameters (and switch X to the hurt player)
				stx tmpfield10
				SWITCH_SELECTED_PLAYER
				stx tmpfield11

				; Hurt the player
				lda player_a_state, x
				cmp #PLAYER_STATE_OWNED
				bne normal_onhurt
					owned_onhurt:
						; Character is owned (by Knight's animation), hurt directly
						ldy config_player_a_character, x
						TRAMPOLINE(hurt_player, characters_bank_number COMMA y, #CURRENT_BANK_NUMBER)
						jmp hurt_ok
					normal_onhurt:
						; Character is in a normal state, call its onhurt callback
						ldy config_player_a_character, x
						lda characters_onhurt_routines_table_lsb, y
						sta tmpfield1
						lda characters_onhurt_routines_table_msb, y
						sta tmpfield2
						TRAMPOLINE(player_state_action, characters_bank_number COMMA y, #CURRENT_BANK_NUMBER)
				hurt_ok:

				; Restore X
				pla:tax
			.)

			; Compute non-capped screenshake
			.(
				SWITCH_SELECTED_PLAYER
				lda player_a_hitstun, x
				lsr
				sta screen_shake_counter
				SWITCH_SELECTED_PLAYER
			.)
		.)

		rts
	.)
.)

;
; Aerial neutral special
;

.(
	+vgsage_start_aerial_spe = vgsage_start_special
.)

;
; Up special
;

.(
	CHARGE_DURATION = 10
	FALL_CANCEL_COYOTE_DURATION = 15
	JUMP_INITIAL_VELOCITY_V = -$500
	JUMP_INITIAL_VELOCITY_H = $200

	anim_duration_table(CHARGE_DURATION, charge_duration)
	duration_table(FALL_CANCEL_COYOTE_DURATION, fall_cancel_coyote_duration)
	velocity_table(JUMP_INITIAL_VELOCITY_V, jump_initial_velocity_v_msb, jump_initial_velocity_v_lsb)
	velocity_table(JUMP_INITIAL_VELOCITY_H, jump_initial_velocity_h_msb, jump_initial_velocity_h_lsb)
	velocity_table(-JUMP_INITIAL_VELOCITY_H, jump_initial_velocity_h_neg_msb, jump_initial_velocity_h_neg_lsb)

	+vgsage_start_spe_up:
	.(
		; Set state
		lda #VGSAGE_STATE_SPECIAL_UP_CHARGE
		sta player_a_state, x

		; Reset clock
		ldy system_index
		lda charge_duration, y
		sta player_a_state_clock, x

		; Cancel momentum
		lda #0
		sta player_a_velocity_v_low, x
		sta player_a_velocity_v, x
		sta player_a_velocity_h_low, x
		sta player_a_velocity_h, x

		; Set animation
		lda #<vgsage_anim_spe_up_charge
		sta tmpfield13
		lda #>vgsage_anim_spe_up_charge
		sta tmpfield14
		jmp set_player_animation

		;rts ; useless, jump to subroutine
	.)

	+vgsage_tick_spe_up_charge:
	.(
#ifldef {char_name}_global_tick
		jsr {char_name}_global_tick
#endif

		jsr {char_name}_apply_friction_lite

		dec player_a_state_clock, x
		bne end
			jmp {char_name}_start_spe_up_jump
			; No return, jump to subroutine
		end:
		rts
	.)

	+vgsage_start_spe_up_jump:
	.(
		; Set state
		lda #VGSAGE_STATE_SPECIAL_UP_JUMP
		sta player_a_state, x

		; Set momentum
		.(
			; Set Y to reference velocity tables
			ldy system_index

			; Chose direction
			lda controller_a_btns, x
			and #CONTROLLER_BTN_LEFT
			bne left_direction
			lda controller_a_btns, x
			and #CONTROLLER_BTN_RIGHT
			bne right_direction

				neutral_direction:
					lda #0
					sta player_a_velocity_h_low, x
					sta player_a_velocity_h, x

					jmp direction_ok

				left_direction:
					lda #DIRECTION_LEFT2
					sta player_a_direction, x

					;ldy system_index ; useless, done above
					lda jump_initial_velocity_h_neg_lsb, y
					sta player_a_velocity_h_low, x
					lda jump_initial_velocity_h_neg_msb, y
					sta player_a_velocity_h, x

					jmp direction_ok

				right_direction:
					lda #DIRECTION_RIGHT2
					sta player_a_direction, x

					;ldy system_index ; useless, done above
					lda jump_initial_velocity_h_lsb, y
					sta player_a_velocity_h_low, x
					lda jump_initial_velocity_h_msb, y
					sta player_a_velocity_h, x

					;jmp direction_ok ; useless, fallthrough

			direction_ok:

			; Set upward velocity
			;ldy system_index ; useless, done above
			lda jump_initial_velocity_v_lsb, y
			sta player_a_velocity_v_low, x
			lda jump_initial_velocity_v_msb, y
			sta player_a_velocity_v, x
		.)

		; Set animation
		lda #<vgsage_anim_spe_up_jump
		sta tmpfield13
		lda #>vgsage_anim_spe_up_jump
		sta tmpfield14
		jmp set_player_animation

		;rts ; useless, jump to subroutine
	.)

	+vgsage_tick_spe_up_jump:
	.(
#ifldef {char_name}_global_tick
		jsr {char_name}_global_tick
#endif

		lda player_a_velocity_v, x
		bmi tick
			jmp vgsage_start_spe_up_helpless
			; No return, jump to subroutine
		tick:

		jsr vgsage_aerial_directional_influence
		jmp vgsage_apply_player_gravity_reduced
		;rts ; useless, jump to subroutine
	.)

	; Like apply_player_gravity, but with reduced impact
	;TODO generalisable, it is same code, just another step value
	;     or better, this value should be in zero-page per character, would be more flexible and save cycles in apply_player_gravity
	vgsage_apply_player_gravity_reduced:
	.(
		lda player_a_velocity_h_low, x
		sta tmpfield2
		lda player_a_velocity_h, x
		sta tmpfield4
		lda player_a_gravity_lsb, x
		sta tmpfield1
		lda player_a_gravity_msb, x
		sta tmpfield3
		ldy system_index
		lda gravity_step, y
		sta tmpfield5
		jsr merge_to_player_velocity

		rts

		acceleration_table($30, gravity_step)
	.)

	+vgsage_input_spe_up_jump:
	.(
		; Spe-up jump can be canceled into spe-down
		lda controller_a_btns, x
		cmp #CONTROLLER_INPUT_SPECIAL_DOWN
		beq vgsage_start_spe_down
		cmp #CONTROLLER_INPUT_SPECIAL_DOWN_LEFT
		beq vgsage_start_spe_down
		cmp #CONTROLLER_INPUT_SPECIAL_DOWN_RIGHT
		beq vgsage_start_spe_down
		rts
	.)

	vgsage_start_spe_up_helpless:
	.(
		; Set state
		lda #VGSAGE_STATE_SPECIAL_UP_HELPLESS
		sta player_a_state, x

		; Reset clock
		ldy system_index
		lda fall_cancel_coyote_duration, y
		sta player_a_state_clock, x

		; Set the appropriate animation
		lda #<{char_name}_anim_helpless
		sta tmpfield13
		lda #>{char_name}_anim_helpless
		sta tmpfield14
		jmp set_player_animation

		; rts ; useless, jump to subroutine
	.)

	+vgsage_tick_spe_up_helpless:
	.(
		dec player_a_state_clock, x
		bne do_tick:
			jmp vgsage_start_helpless
			; No return, jump to subroutine
		do_tick:

		jmp vgsage_tick_helpless
		;rts ; useless, jump to subroutine
	.)

	+vgsage_input_spe_up_helpless = vgsage_input_spe_up_jump
.)

;
; Down special
;

.(
	charge_duration:
		.byt vgsage_anim_spe_down_roll_dur_pal, vgsage_anim_spe_down_roll_dur_ntsc

	velocity_table($400, fall_velocity_v_msb, fall_velocity_v_lsb)
	velocity_table(-$400, roll_velocity_v_msb, roll_velocity_v_lsb)

	&vgsage_start_spe_down:
	.(
		; Set state
		lda #VGSAGE_STATE_SPECIAL_DOWN_ROLL
		sta player_a_state, x

		; Reset clock
		ldy system_index
		lda charge_duration, y
		sta player_a_state_clock, x

		; Cancel momentum
		;ldy system_index ; useless, done above
		lda roll_velocity_v_lsb, y
		sta player_a_velocity_v_low, x
		lda roll_velocity_v_msb, y
		sta player_a_velocity_v, x
		lda #0
		sta player_a_velocity_h_low, x
		sta player_a_velocity_h, x

		; Set animation
		lda #<vgsage_anim_spe_down_roll
		sta tmpfield13
		lda #>vgsage_anim_spe_down_roll
		sta tmpfield14
		jmp set_player_animation

		;rts ; useless, jump to subroutine
	.)

	+vgsage_tick_spe_down_roll:
	.(
		dec player_a_state_clock, x
		bne do_tick
			jmp vgsage_start_spe_down_fall
		do_tick:

		jmp apply_player_gravity
		;rts ; useless, jump to subroutine
	.)

	vgsage_start_spe_down_fall:
	.(
		; Set state
		lda #VGSAGE_STATE_SPECIAL_DOWN_FALL
		sta player_a_state, x

		; Set velocity
		ldy system_index
		lda fall_velocity_v_lsb, y
		sta player_a_velocity_v_low, x
		lda fall_velocity_v_msb, y
		sta player_a_velocity_v, x

		; Set animation
		lda #<vgsage_anim_spe_down_fall
		sta tmpfield13
		lda #>vgsage_anim_spe_down_fall
		sta tmpfield14
		jmp set_player_animation

		;rts ; useless, jump to subroutine
	.)

#ifldef {char_name}_global_tick
	+vgsage_tick_spe_down_fall:
	.(
		jsr {char_name}_global_tick
		jmp vgsage_aerial_directional_influence
		;rts ; useless, jump to subroutine
	.)
#else
	+vgsage_tick_spe_down_fall = vgsage_aerial_directional_influence
#endif

	+vgsage_input_spe_down_fall:
	.(
		lda controller_a_btns, x
		cmp #CONTROLLER_INPUT_JUMP
		beq cancel
		cmp #CONTROLLER_INPUT_JUMP_LEFT
		beq cancel
		cmp #CONTROLLER_INPUT_JUMP_RIGHT
		beq cancel

			ignore:
				jmp smart_keep_input_dirty

			cancel:
				jmp vgsage_start_helpless

		;rts ; useless, no branch return
	.)
.)

;
; Side special
;

.(
	MOVE_DURATION = 5
	MOVE_SPEED = $600
	LAND_SPEED = $200

	charge_duration:
		.byt vgsage_anim_spe_side_charge_dur_pal, vgsage_anim_spe_side_charge_dur_ntsc
	land_duration:
		.byt vgsage_anim_spe_side_land_dur_pal, vgsage_anim_spe_side_land_dur_ntsc
	duration_table(MOVE_DURATION, move_duration)
	velocity_table(-MOVE_SPEED, move_speed_left_msb, move_speed_left_lsb)
	velocity_table(MOVE_SPEED, move_speed_right_msb, move_speed_right_lsb)
	velocity_table(-LAND_SPEED, land_speed_left_msb, land_speed_left_lsb)
	velocity_table(LAND_SPEED, land_speed_right_msb, land_speed_right_lsb)

	&vgsage_start_spe_side_left:
	.(
		lda DIRECTION_LEFT
		sta player_a_direction, x
		jmp vgsage_start_spe_side
		;rts ; useless, jump to subroutine
	.)

	&vgsage_start_spe_side_right:
	.(
		lda DIRECTION_RIGHT
		sta player_a_direction, x
		;jmp vgsage_start_spe_side ; useless, fallthrough
		; Falltrhough to vgsage_start_spe_side
	.)

	&vgsage_start_spe_side:
	.(
		; Set state
		lda #VGSAGE_STATE_SPECIAL_SIDE_CHARGE
		sta player_a_state, x

		; Reset clock
		ldy system_index
		lda charge_duration, y
		sta player_a_state_clock, x

		; Cancel momentum
		lda #0
		sta player_a_velocity_v_low, x
		sta player_a_velocity_v, x
		sta player_a_velocity_h_low, x
		sta player_a_velocity_h, x

		; Set animation
		lda #<vgsage_anim_spe_side_charge
		sta tmpfield13
		lda #>vgsage_anim_spe_side_charge
		sta tmpfield14
		jmp set_player_animation

		;rts ; useless, jump to subroutine
	.)

	+vgsage_tick_spe_side_charge:
	.(
		dec player_a_state_clock, x
		bne do_tick:
			jmp vgsage_start_spe_side_move
		do_tick:
		rts
	.)

	vgsage_start_spe_side_move:
	.(
		lda #VGSAGE_STATE_SPECIAL_SIDE_MOVE
		sta player_a_state, x

		; Reset clock
		ldy system_index
		lda move_duration, y
		sta player_a_state_clock, x

		; Set momentum
		.(
			;ldy system_index ; useless, done above
			lda player_a_direction, x
			bne right

				left:
					lda move_speed_left_lsb, y
					sta player_a_velocity_h_low, x
					lda move_speed_left_msb, y
					sta player_a_velocity_h, x
					jmp ok

				right:
					lda move_speed_right_lsb, y
					sta player_a_velocity_h_low, x
					lda move_speed_right_msb, y
					sta player_a_velocity_h, x

			ok:
		.)

		; Set animation
		lda #<vgsage_anim_spe_side_move
		sta tmpfield13
		lda #>vgsage_anim_spe_side_move
		sta tmpfield14
		jmp set_player_animation

		;rts ; useless, jump to subroutine
	.)

	+vgsage_tick_spe_side_move:
	.(
		dec player_a_state_clock, x
		bne do_tick:
			jmp vgsage_start_spe_side_land
		do_tick:
		rts
	.)

	vgsage_start_spe_side_land:
	.(
		; Set state
		lda #VGSAGE_STATE_SPECIAL_SIDE_LAND
		sta player_a_state, x

		; Reset clock
		ldy system_index
		lda land_duration, y
		sta player_a_state_clock, x

		; Set momentum
		.(
			;ldy system_index ; useless, done above
			lda player_a_direction, x
			bne right

				left:
					lda land_speed_left_lsb, y
					sta player_a_velocity_h_low, x
					lda land_speed_left_msb, y
					sta player_a_velocity_h, x
					jmp ok

				right:
					lda land_speed_right_lsb, y
					sta player_a_velocity_h_low, x
					lda land_speed_right_msb, y
					sta player_a_velocity_h, x

			ok:
		.)

		; Set animation
		lda #<vgsage_anim_spe_side_land
		sta tmpfield13
		lda #>vgsage_anim_spe_side_land
		sta tmpfield14
		jmp set_player_animation

		;rts ; useless, jump to subroutine
	.)

	+vgsage_tick_spe_side_land:
	.(
		dec player_a_state_clock, x
		bne do_tick:
			jmp vgsage_start_helpless
		do_tick:

		jmp vgsage_apply_friction_lite
		;rts ; useless, jump to subroutine
	.)
.)

!include "characters/std_friction_routines.asm"

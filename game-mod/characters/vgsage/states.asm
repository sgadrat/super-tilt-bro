!define "char_name" {vgsage}
!define "char_name_upper" {VGSAGE}

;
; States index
;

VGSAGE_STATE_THROWN = PLAYER_STATE_THROWN                             ;  0
VGSAGE_STATE_RESPAWN_INVISIBLE = PLAYER_STATE_RESPAWN                 ;  1
VGSAGE_STATE_INNEXISTANT = PLAYER_STATE_INNEXISTANT                   ;  2
VGSAGE_STATE_SPAWN = PLAYER_STATE_SPAWN                               ;  3
VGSAGE_STATE_IDLE = PLAYER_STATE_STANDING                             ;  4
VGSAGE_STATE_RUNNING = PLAYER_STATE_RUNNING                           ;  5
VGSAGE_STATE_RESPAWN_PLATFORM = CUSTOM_PLAYER_STATES_BEGIN + 0        ;  6
VGSAGE_STATE_JUMPING = CUSTOM_PLAYER_STATES_BEGIN + 1                 ;  7
VGSAGE_STATE_WALLJUMPING = CUSTOM_PLAYER_STATES_BEGIN + 2             ;  8
VGSAGE_STATE_FALLING = CUSTOM_PLAYER_STATES_BEGIN + 3                 ;  9
VGSAGE_STATE_HELPLESS = CUSTOM_PLAYER_STATES_BEGIN + 4                ;  a
VGSAGE_STATE_LANDING = CUSTOM_PLAYER_STATES_BEGIN + 5                 ;  b
VGSAGE_STATE_CRASHING = CUSTOM_PLAYER_STATES_BEGIN + 6                ;  c
VGSAGE_STATE_SHIELDING = CUSTOM_PLAYER_STATES_BEGIN + 7               ;  d
VGSAGE_STATE_SHIELDLAG = CUSTOM_PLAYER_STATES_BEGIN + 8               ;  e
VGSAGE_STATE_JABBING = CUSTOM_PLAYER_STATES_BEGIN + 9                 ;  f
VGSAGE_STATE_UP_TILT = CUSTOM_PLAYER_STATES_BEGIN + 10                ; 10
VGSAGE_STATE_DOWN_TILT = CUSTOM_PLAYER_STATES_BEGIN + 11              ; 11
VGSAGE_STATE_SIDE_TILT = CUSTOM_PLAYER_STATES_BEGIN + 12              ; 12
VGSAGE_STATE_AERIAL_NEUTRAL = CUSTOM_PLAYER_STATES_BEGIN + 13         ; 13
VGSAGE_STATE_AERIAL_UP = CUSTOM_PLAYER_STATES_BEGIN + 14              ; 14
VGSAGE_STATE_AERIAL_DOWN = CUSTOM_PLAYER_STATES_BEGIN + 15            ; 15
VGSAGE_STATE_AERIAL_SIDE = CUSTOM_PLAYER_STATES_BEGIN + 16            ; 16
VGSAGE_STATE_SPECIAL_NEUTRAL_STEP_0 = CUSTOM_PLAYER_STATES_BEGIN + 17 ; 17
VGSAGE_STATE_SPECIAL_NEUTRAL_STEP_1 = CUSTOM_PLAYER_STATES_BEGIN + 18 ; 18
VGSAGE_STATE_SPECIAL_NEUTRAL_STEP_2 = CUSTOM_PLAYER_STATES_BEGIN + 19 ; 19
VGSAGE_STATE_SPECIAL_NEUTRAL_STEP_3 = CUSTOM_PLAYER_STATES_BEGIN + 20 ; 1a
VGSAGE_STATE_SPECIAL_NEUTRAL_STEP_4 = CUSTOM_PLAYER_STATES_BEGIN + 21 ; 1b

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
		.byt <fast_fall,                   <vgsage_start_side_special
		.byt <vgsage_start_side_special,   <jump
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
		.byt >fast_fall,                   >vgsage_start_side_special
		.byt >vgsage_start_side_special,   >jump
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
		.byt <input_idle_left,                <input_idle_right
		.byt <vgsage_start_jumping,           <input_idle_jump_right
		.byt <input_idle_jump_left,           <vgsage_start_jabbing
		.byt <input_idle_tilt_left,           <input_idle_tilt_right
		.byt <vgsage_start_special,           <vgsage_start_side_special_right
		.byt <vgsage_start_side_special_left, <vgsage_start_down_tilt
		.byt <vgsage_start_spe_up,            <vgsage_start_spe_down
		.byt <vgsage_start_up_tilt,           <vgsage_start_shielding
		.byt <vgsage_start_shielding,         <vgsage_start_shielding
		.byt <vgsage_start_spe_up,            <vgsage_start_spe_up
		.byt <vgsage_start_up_tilt,           <vgsage_start_up_tilt
		.byt <vgsage_start_spe_down,          <vgsage_start_spe_down
		.byt <vgsage_start_down_tilt,         <vgsage_start_down_tilt
		controller_callbacks_hi:
		.byt >input_idle_left,                >input_idle_right
		.byt >vgsage_start_jumping,           >input_idle_jump_right
		.byt >input_idle_jump_left,           >vgsage_start_jabbing
		.byt >input_idle_tilt_left,           >input_idle_tilt_right
		.byt >vgsage_start_special,           >vgsage_start_side_special_right
		.byt >vgsage_start_side_special_left, >vgsage_start_down_tilt
		.byt >vgsage_start_spe_up,            >vgsage_start_spe_down
		.byt >vgsage_start_up_tilt,           >vgsage_start_shielding
		.byt >vgsage_start_shielding,         >vgsage_start_shielding
		.byt >vgsage_start_spe_up,            >vgsage_start_spe_up
		.byt >vgsage_start_up_tilt,           >vgsage_start_up_tilt
		.byt >vgsage_start_spe_down,          >vgsage_start_spe_down
		.byt >vgsage_start_down_tilt,         >vgsage_start_down_tilt
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
		.byt <vgsage_start_side_special,    <vgsage_start_side_special
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
		.byt >vgsage_start_side_special,    >vgsage_start_side_special
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

;
; Jab
;

.(
	+vgsage_start_jabbing:
	.(
		;TODO
		rts
	.)

	+vgsage_tick_jabbing:
	.(
		;TODO
		rts
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
		;TODO
		rts
	.)

	+vgsage_tick_side_tilt:
	.(
		;TODO
		rts
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
	step0_ppu_addr_lsb = player_a_state_field1
	step0_ppu_addr_msb = player_a_state_field2

	; Step 0 - fadeout
	.(
		+vgsage_start_special:
		.(
			lda #VGSAGE_STATE_SPECIAL_NEUTRAL_STEP_0
			sta player_a_state, x

			; Set the appropriate animation
			lda #<vgsage_anim_side_special_jump
			sta tmpfield13
			lda #>vgsage_anim_side_special_jump
			sta tmpfield14
			jsr set_player_animation

			; Stop any momentum
			lda #0
			sta player_a_velocity_v, x
			sta player_a_velocity_h, x
			sta player_a_velocity_v_low, x
			sta player_a_velocity_h_low, x

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

		+vgsage_tick_special:
		.(
			; Every four ticks, advance one step of the fadeout
			.(
				lda player_a_state_clock, x
				and #%00000001
				bne ok

					; Set pallettes to current fadaout step
					stx player_number

					lda player_a_state_clock, x
					lsr
					lsr
					tax

					lda fadeout_lsb, x
					ldy fadeout_msb, x
					jsr push_nt_buffer

					ldx player_number

				ok:
			.)

			; Tick clock
			dec player_a_state_clock, x
			bpl end
				jmp vgsage_start_special_neutral_go_bottom_screen
				;No return

			end:
			rts

			;FIXME hardcoded for flatland, call a stage routine to do the repaint in dedicated logic
			palette1:
			.byt $3f, $00, $10
			.byt $11,$0f,$00,$00, $11,$0f,$00,$21, $11,$09,$09,$21, $11,$07,$07,$17
			palette2:
			.byt $3f, $00, $10
			.byt $01,$0f,$0f,$0f, $01,$0f,$0f,$11, $01,$0f,$0f,$11, $01,$0f,$0f,$07
			palette3:
			.byt $3f, $00, $10
			.byt $0f,$0f,$0f,$0f, $0f,$0f,$0f,$01, $0f,$0f,$0f,$01, $01,$0f,$0f,$0f
			palette_black:
			.byt $3f, $00, $10
			.byt $0f,$0f,$0f,$0f, $0f,$0f,$0f,$0f, $0f,$0f,$0f,$0f, $0f,$0f,$0f,$0f

			fadeout_lsb:
			.byt <palette_black, <palette3, <palette2, <palette1
			fadeout_msb:
			.byt >palette_black, >palette3, >palette2, >palette1
		.)
	.)

	; Step XXX - prepare bottom screen for illustrations
	.(
		+vgsage_start_special_neutral_go_bottom_screen:
		.(
			lda #VGSAGE_STATE_SPECIAL_NEUTRAL_STEP_1
			sta player_a_state, x

			; Scroll to bottom screen
			lda ppuctrl_val
			and #%11111100
			ora #%00000010
			sta ppuctrl_val

			; Init bottom screen fill state
			lda #30 ; Number of lines to fill
			sta player_a_state_clock, x

			lda #$00 ; PPU address
			sta step0_ppu_addr_lsb
			lda #$28
			sta step0_ppu_addr_msb

			rts
		.)

		+vgsage_tick_special_neutral_go_bottom_screen:
		.(
			; Fill a row with solid1 tiles
			stx player_number

			lda step0_ppu_addr_lsb, x
			sta tmpfield1
			lda step0_ppu_addr_msb, x
			sta tmpfield2

			jsr last_nt_buffer
			lda #$01
			sta nametable_buffers+0, x
			lda tmpfield2
			sta nametable_buffers+1, x
			lda tmpfield1
			sta nametable_buffers+2, x
			lda #$20
			sta nametable_buffers+3, x

			ldy #$20
			lda #$62 ;FIXME hardcoded value to a leftover of illustrations, need an actually ensured SOLID_1 tile
			fill_bytes:
				sta nametable_buffers+4, x
				inx

				dey
				bne fill_bytes

			lda #0
			sta nametable_buffers+4, x

			ldx player_number

			; Update row address
			lda #$20
			clc
			adc tmpfield1
			sta step0_ppu_addr_lsb, x
			bcc ok
				inc step0_ppu_addr_msb, x
			ok:

			; End state once all rows have been filled
			dec player_a_state_clock, x
			bne end
				jmp vgsage_start_special_draw_warrior
				; No return, jump to subroutine

			end:
			rts
		.)
	.)

	; Step1 - draw warrior
	.(
		&vgsage_start_special_draw_warrior:
		.(
			lda #VGSAGE_STATE_SPECIAL_NEUTRAL_STEP_2
			sta player_a_state, x

			lda #5
			sta player_a_state_clock, x

			;TODO
			rts
		.)

		+vgsage_tick_special_draw_warrior:
		.(
			stx player_number

			ldy player_a_state_clock, x

			lda illustration_header_lsb, y
			sta tmpfield1
			lda illustration_header_msb, y
			sta tmpfield2
			lda illustration_lsb, y
			sta tmpfield3
			lda illustration_msb, y
			sta tmpfield4
			jsr construct_nt_buffer

			ldx player_number

			dec player_a_state_clock, x
			bpl end
				jmp vgsage_start_special_show_warrior
				; No return, jump to subroutine

			end:
			rts

#define ATT(br,bl,tr,tl) ((br << 6) + (bl << 4) + (tr << 2) + tl)
			illustration_palette:
			.byt $0f,$0f,$0f,$0f, $0f,$03,$0f,$0f, $0f,$32,$0f,$0f, $0f,$20,$0f,$0f
			illustration_palette_fadein_1:
			.byt $0f,$0f,$0f,$0f, $0f,$03,$0f,$0f, $0f,$22,$0f,$0f, $0f,$10,$0f,$0f
			illustration_palette_fadein_2:
			.byt $0f,$0f,$0f,$0f, $0f,$03,$0f,$0f, $0f,$12,$0f,$0f, $0f,$00,$0f,$0f
			illustration_palette_fadein_3:
			.byt $0f,$0f,$0f,$0f, $0f,$0f,$0f,$0f, $0f,$02,$0f,$0f, $0f,$0f,$0f,$0f
			illustration_top:
			.byt ATT(0,0,1,1), ATT(1,0,0,0), ATT(2,2,1,1), ATT(2,2,1,1), ATT(0,1,0,0), ATT(0,0,0,0), ATT(0,0,0,0), ATT(0,0,0,0)
			.byt ATT(0,0,0,0), ATT(2,1,2,1), ATT(2,2,2,2), ATT(2,1,3,1), ATT(3,3,1,3), ATT(1,2,0,1), ATT(0,0,0,0), ATT(0,0,0,0)
			.byt ATT(1,0,1,0), ATT(2,2,2,2), ATT(2,2,2,2), ATT(2,2,1,2), ATT(2,1,3,2), ATT(3,3,2,3), ATT(1,3,0,1), ATT(0,0,0,0)
			.byt ATT(2,1,2,1), ATT(2,2,2,2), ATT(2,2,2,2), ATT(2,2,2,2), ATT(2,2,2,1), ATT(3,2,3,2), ATT(3,3,3,3), ATT(1,2,0,1)
			illustration_bot:
			.byt ATT(1,0,2,1), ATT(1,2,0,1), ATT(0,0,0,0), ATT(3,3,2,0), ATT(0,0,2,2), ATT(3,3,0,0), ATT(1,0,0,0), ATT(1,2,1,1)
			.byt ATT(0,0,0,0), ATT(1,0,2,1), ATT(2,2,0,2), ATT(1,2,0,0), ATT(0,0,0,0), ATT(2,1,0,0), ATT(1,2,2,2), ATT(0,0,0,1)
			.byt ATT(1,1,0,0), ATT(0,0,0,0), ATT(0,0,1,1), ATT(1,0,2,1), ATT(1,1,2,2), ATT(0,1,1,2), ATT(0,0,0,1), ATT(0,0,0,0)
			.byt ATT(2,2,2,2), ATT(2,2,1,1), ATT(1,1,0,0), ATT(0,0,0,0), ATT(0,0,0,0), ATT(0,0,0,0), ATT(1,0,0,0), ATT(2,2,1,1)
#undef ATT
			illustration_lsb:
			.byt <illustration_palette
			.byt <illustration_palette_fadein_1, <illustration_palette_fadein_2, <illustration_palette_fadein_3
			.byt <illustration_top, <illustration_bot
			illustration_msb:
			.byt >illustration_palette
			.byt >illustration_palette_fadein_1, >illustration_palette_fadein_2, >illustration_palette_fadein_3
			.byt >illustration_top, >illustration_bot

			illustration_palette_header:
			.byt $3f, $00, $10
			illustration_top_header:
			.byt $2b, $c0, $20
			illustration_bot_header:
			.byt $2b, $e0, $20

			illustration_header_lsb:
			.byt <illustration_palette_header
			.byt <illustration_palette_header, <illustration_palette_header, <illustration_palette_header
			.byt <illustration_top_header, <illustration_bot_header
			illustration_header_msb:
			.byt >illustration_palette_header
			.byt >illustration_palette_header, >illustration_palette_header, >illustration_palette_header
			.byt >illustration_top_header, >illustration_bot_header
		.)
	.)

	; Step 3 - wait a bit to show the warrior
	.(
		&vgsage_start_special_show_warrior:
		.(
			lda #VGSAGE_STATE_SPECIAL_NEUTRAL_STEP_3
			sta player_a_state, x

			lda #50 ;TODO ntsc
			sta player_a_state_clock, x

			jmp audio_play_title_screen_subtitle

			;rts
		.)

		+vgsage_tick_special_show_warrior:
		.(
			dec player_a_state_clock, x
			bne end
				jmp vgsage_start_special_draw_slash
			end:
			rts
		.)
	.)

	; Step 4 - Slash animation
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

			; Tick clock
			dec player_a_state_clock, x
			bpl end
				jmp resume_game
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
			.byt $2b, $c0, $20
			bot_header:
			.byt $2b, $e0, $20

			anim_headers_lsb:
			.byt <top_header, <bot_header, NOOP, <top_header, <bot_header, <bot_header, <top_header, <bot_header
			anim_headers_msb:
			.byt >top_header, >bot_header, NOOP, >top_header, >bot_header, >bot_header, >top_header, >bot_header

			&NUM_ANIM_STEPS = anim_headers_msb - anim_headers_lsb
		.)
	.)

	resume_game:
	.(
		; Come back to top screen
		lda ppuctrl_val
		and #%11111100
		sta ppuctrl_val

		; Restore stage's palettes
		;FIXME hardcoded for flatland, call a stage routine to do the repaint in dedicated logic
		txa
		sta player_number ;TODO investigate don't really know if we can write player_number safely here (update the doc if known for sure)

		lda #<hack_flatland_palette
		ldy #>hack_flatland_palette
		jsr push_nt_buffer

		ldx player_number

		; Hurt opponent
		;  optimisable - avoid hurt_player routine, call apply_force_vector_direct to not setup the hitbox just to read it in tmpfields
		;  could also be better to use a hitbox in the animation (just ensure it connects someway)
		lda #23
		sta player_a_hitbox_damages, x
		lda #0
		sta player_a_hitbox_force_h, x
		sta player_a_hitbox_force_h_low, x
		sta player_a_hitbox_force_v, x
		sta player_a_hitbox_force_v_low, x
		lda #<-2048
		sta player_a_hitbox_base_knock_up_v_low, x
		lda #>-2048
		sta player_a_hitbox_base_knock_up_v_high, x
		lda #<2048
		sta player_a_hitbox_base_knock_up_h_low, x
		lda #>2048
		sta player_a_hitbox_base_knock_up_h_high, x

		txa:pha
		ldy config_player_a_character
		stx tmpfield10
		SWITCH_SELECTED_PLAYER
		stx tmpfield11
		TRAMPOLINE(hurt_player, characters_bank_number COMMA x, #CURRENT_BANK_NUMBER)
		pla:tax

		; Come back to a playable state
		jmp vgsage_start_inactive_state

		;rts ; useless, jump to subroutine

		hack_flatland_palette:
		.byt $3f, $00, $10
		.byt $21,$0f,$00,$10, $21,$0f,$00,$31, $21,$09,$19,$31, $21,$07,$17,$27
	.)
.)

;
; Aerial neutral special
;

.(
	+vgsage_start_aerial_spe:
	.(
		;TODO
		rts
	.)
.)

;
; Up special
;

.(
	+vgsage_start_spe_up:
	.(
		;TODO
		rts
	.)
.)

;
; Down special
;

.(
	+vgsage_start_spe_down:
	.(
		;TODO
		rts
	.)
.)

;
; Side special
;

.(
	+vgsage_start_side_special_left:
	.(
		lda DIRECTION_LEFT
		sta player_a_direction, x
		jmp vgsage_start_side_special
		;rts ; useless, jump to subroutine
	.)

	+vgsage_start_side_special_right:
	.(
		lda DIRECTION_RIGHT
		sta player_a_direction, x
		;jmp vgsage_start_side_special ; useless, fallthrough
		; Falltrhough to vgsage_start_side_special
	.)

	+vgsage_start_side_special:
	.(
		;TODO
		rts
	.)
.)

!include "characters/std_friction_routines.asm"

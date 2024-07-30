!define "char_name" {kiki}
!define "char_name_upper" {KIKI}

;
; Gameplay constants
;

KIKI_AERIAL_DIRECTIONAL_INFLUENCE_STRENGTH = $80
KIKI_AERIAL_SPEED = $0100
KIKI_AIR_FRICTION_STRENGTH = 7
KIKI_COUNTER_GRAVITY = $0100
KIKI_FASTFALL_SPEED = $0400
KIKI_GROUND_FRICTION_STRENGTH = $40
KIKI_JUMP_SQUAT_DURATION_PAL = 4
KIKI_JUMP_SQUAT_DURATION_NTSC = 5
KIKI_JUMP_SHORT_HOP_EXTRA_TIME_PAL = 4
KIKI_JUMP_SHORT_HOP_EXTRA_TIME_NTSC = 5
KIKI_JUMP_SHORT_HOP_AERIAL_TIME_PAL = 2 ;  Number of frames after jumpsquat at which an attack input stops converting is into a short hop-aerial
KIKI_JUMP_SHORT_HOP_AERIAL_TIME_NTSC = 2
KIKI_JUMP_POWER = $0480
KIKI_JUMP_SHORT_HOP_POWER = $0102
KIKI_LANDING_MAX_VELOCITY = $0200
KIKI_MAX_NUM_AERIAL_JUMPS = 1
KIKI_ALL_SPECIAL_JUMPS = %10000001
KIKI_PLATFORM_DURATION = 100 ; Note, 106 (ntsc->127) is the max, we have only 7 bits to store the value
KIKI_PLATFORM_BLINK_THRESHOLD_MASK = %01100000 ; Platform is blinking if "timer > 0 && (MASK & timer == 0)"
KIKI_PLATFORM_BLINK_MASK = %00000100 ; Blinking platform is shown on frames where "MASK & timer == 1"
KIKI_RUNNING_INITIAL_VELOCITY = $0100
KIKI_RUNNING_MAX_VELOCITY = $0180
KIKI_RUNNING_ACCELERATION = $40
KIKI_TECH_SPEED = $0400
KIKI_WALL_JUMP_SQUAT_END = 4
KIKI_WALL_JUMP_VELOCITY_V = $03c0
KIKI_WALL_JUMP_VELOCITY_H = $0080

;
; Constants data
;

!include "characters/std_constant_tables.asm"

duration_table(KIKI_PLATFORM_DURATION, kiki_platform_duration)

kiki_wall_attributes_per_player:
.byt 1, 3

kiki_first_wall_sprite_per_player:
.byt INGAME_PLAYER_A_LAST_SPRITE-1, INGAME_PLAYER_B_LAST_SPRITE-1

; Offset of 2 bytes reserved in player's object data for storing current platform sprites Y position on screen
kiki_first_wall_sprite_y_per_player:
.byt (player_a_objects-stage_data)+STAGE_ELEMENT_SIZE+1, (player_b_objects-stage_data)+STAGE_ELEMENT_SIZE+1

kiki_last_anim_sprite_per_player:
.byt INGAME_PLAYER_A_LAST_SPRITE-2, INGAME_PLAYER_B_LAST_SPRITE-2

kiki_first_tile_index_per_player:
.byt CHARACTERS_CHARACTER_A_FIRST_TILE, CHARACTERS_CHARACTER_B_FIRST_TILE

kiki_a_platform_state = player_a_state_field3 ; aTTT TTTT - a, allowed to create a new platform - T, platform timer
kiki_b_platform_state = player_b_state_field3

;
; Implementation
;

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

	; Set wall sprites attributes
	.(
		lda kiki_first_wall_sprite_per_player, x
		asl
		asl
		tay

		lda kiki_wall_attributes_per_player, x
		sta oam_mirror+2, y ; First sprite attributes
		sta oam_mirror+6, y ; Second sprite attributes
	.)

	; Init platform state
	.(
		lda #%10000000
		sta kiki_a_platform_state, x
	.)

	; Setup player's elements
	; - First byte is ELEMENT_END (deactivated platform)
	; - Stop player's elements after the platform
	.(
		ldy #0
		cpx #0
		beq load_element
			ldy #player_b_objects-player_a_objects
		load_element:

		lda #STAGE_ELEMENT_END
		sta player_a_objects+0, y
		sta player_a_objects+STAGE_ELEMENT_SIZE, y
	.)

	; Initialize special jump flags
	lda #KIKI_ALL_SPECIAL_JUMPS
	sta player_a_special_jumps, x

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

kiki_netload:
.(
	cpx #0
	beq load_element
		ldx #player_b_objects-player_a_objects
	load_element:

	; Platform stage-element
	lda esp_rx_buffer+0, y
	sta player_a_objects+0, x
	lda esp_rx_buffer+1, y
	sta player_a_objects+1, x
	lda esp_rx_buffer+2, y
	sta player_a_objects+2, x
	lda esp_rx_buffer+3, y
	sta player_a_objects+3, x
	lda esp_rx_buffer+4, y
	sta player_a_objects+4, x
	lda esp_rx_buffer+5, y
	sta player_a_objects+5, x
	lda esp_rx_buffer+6, y
	sta player_a_objects+6, x
	lda esp_rx_buffer+7, y
	sta player_a_objects+7, x
	lda esp_rx_buffer+8, y
	sta player_a_objects+8, x

#if STAGE_ELEMENT_SIZE <> 9
#error above code expects stage elements to be 9 bytes
#endif

	; Y pos of the platform (kiki_first_wall_sprite_y_per_player)
	lda esp_rx_buffer+9, y
	sta player_a_objects+10, x
	lda esp_rx_buffer+10, y
	sta player_a_objects+11, x

	; X pos of the platform tiles
	ldx player_number
	lda kiki_first_wall_sprite_per_player, x
	asl
	asl
	tax

	lda esp_rx_buffer+11, y
	sta oam_mirror+3, x
	lda esp_rx_buffer+12, y
	sta oam_mirror+4+3, x

	; Platform tiles
	lda esp_rx_buffer+13, y
	sta oam_mirror+1, x
	lda esp_rx_buffer+14, y
	sta oam_mirror+4+1, x

	; Save buffer cursor
	tya
	clc
	adc #15
	pha

	; Ensure platform is correctly displayed
	.(
		; Shall be drawn if
		;  timer > blink threshold, or
		;  blink is in a visible tick
		ldx player_number
		lda kiki_a_platform_state, x
		and #KIKI_PLATFORM_BLINK_THRESHOLD_MASK
		bne displayed
		lda kiki_a_platform_state, x
		and #KIKI_PLATFORM_BLINK_MASK
		bne displayed

			hidden:
				jsr kiki_hide_platform
				jmp end_place_platform

			displayed:
				jsr kiki_show_platform

		end_place_platform:
	.)

	; Store updated buffer cursor
	pla
	tay

	rts
.)

kiki_hide_platform:
.(
	; Hide platform (set sprites Y position offscreen)
	lda kiki_first_wall_sprite_per_player, x
	asl
	asl
	tay

	lda #$fe
	sta oam_mirror+4, y
	sta oam_mirror, y

	rts
.)

kiki_show_platform:
.(
	; Show platform (set sprites Y position to the original one)
	ldy kiki_first_wall_sprite_y_per_player, x
	lda stage_data, y
	pha
	iny
	lda stage_data, y
	pha

	lda kiki_first_wall_sprite_per_player, x
	asl
	asl
	tay

	pla
	sta oam_mirror+4, y
	pla
	sta oam_mirror, y

	rts
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

				; useless, ensured by blinking
				;; Hide platform sprites
				;lda kiki_first_wall_sprite_per_player, x
				;asl
				;asl
				;tay

				;lda #$fe
				;sta oam_mirror, y
				;sta oam_mirror+4,y

		end_lifetime:
	.)

	; Make platform blink on end of life
	.(
		;TODO ntsc timing, if it feels wrong with shared timing
		; Do not blink until the platform is about to disapear
		lda kiki_a_platform_state, x
		tay
		and #KIKI_PLATFORM_BLINK_THRESHOLD_MASK
		bne end_blinking

			tya
			and #KIKI_PLATFORM_BLINK_MASK
			beq hide

				show:
					jsr kiki_show_platform
					jmp end_blinking

				hide:
					jsr kiki_hide_platform

		end_blinking:
	.)

	; Call global on-ground
	.(
		; Do not reset if not on a legit stage platform
		lda player_a_grounded, x
		beq end_ground_reset ; Not on ground
			jsr kiki_global_onground
		end_ground_reset:
	.)

	rts
.)

kiki_global_onground:
.(
	; Initialize special jump flags
	lda #KIKI_ALL_SPECIAL_JUMPS
	sta player_a_special_jumps, x

	; Reset allowed flag on stage's ground (not on player-made platforms)
	.(
		lda player_a_grounded, x
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


; Input table for aerial moves, special values are
;  fast_fall - mandatorily on INPUT_NONE to take effect on release of DOWN
;  jump      - automatically choose between aerial jump or wall jump
;  no_input  - expected default
!input-table-define "KIKI_AERIAL_INPUTS_TABLE" {
	CONTROLLER_INPUT_NONE                fast_fall
	CONTROLLER_INPUT_SPECIAL_RIGHT       kiki_start_side_spe_right
	CONTROLLER_INPUT_SPECIAL_LEFT        kiki_start_side_spe_left
	CONTROLLER_INPUT_JUMP                jump
	CONTROLLER_INPUT_JUMP_RIGHT          jump
	CONTROLLER_INPUT_JUMP_LEFT           jump
	CONTROLLER_INPUT_ATTACK_LEFT         kiki_start_side_aerial_left
	CONTROLLER_INPUT_ATTACK_RIGHT        kiki_start_side_aerial_right
	CONTROLLER_INPUT_DOWN_TILT           kiki_start_down_aerial
	CONTROLLER_INPUT_ATTACK_UP           kiki_start_up_aerial
	CONTROLLER_INPUT_JAB                 kiki_start_neutral_aerial
	CONTROLLER_INPUT_SPECIAL             kiki_start_top_wall
	CONTROLLER_INPUT_SPECIAL_UP          kiki_start_down_wall
	CONTROLLER_INPUT_SPECIAL_DOWN        kiki_start_counter_guard
	CONTROLLER_INPUT_ATTACK_UP_RIGHT     kiki_start_up_aerial_right
	CONTROLLER_INPUT_ATTACK_UP_LEFT      kiki_start_up_aerial_left
	CONTROLLER_INPUT_SPECIAL_UP_RIGHT    kiki_start_down_wall_right
	CONTROLLER_INPUT_SPECIAL_UP_LEFT     kiki_start_down_wall_left
	CONTROLLER_INPUT_ATTACK_DOWN_RIGHT   kiki_start_down_aerial_right
	CONTROLLER_INPUT_ATTACK_DOWN_LEFT    kiki_start_down_aerial_left
	CONTROLLER_INPUT_SPECIAL_DOWN_RIGHT  kiki_start_counter_guard_right
	CONTROLLER_INPUT_SPECIAL_DOWN_LEFT   kiki_start_counter_guard_left

	no_input
}

; Input table for idle state, special values are
;  no_input - Default
!input-table-define "KIKI_IDLE_INPUTS_TABLE" {
	CONTROLLER_INPUT_LEFT               kiki_start_running_left
	CONTROLLER_INPUT_RIGHT              kiki_start_running_right
	CONTROLLER_INPUT_JUMP               kiki_start_jumping
	CONTROLLER_INPUT_JUMP_RIGHT         kiki_start_jumping_right
	CONTROLLER_INPUT_JUMP_LEFT          kiki_start_jumping_left
	CONTROLLER_INPUT_ATTACK_RIGHT       kiki_start_side_tilt_right
	CONTROLLER_INPUT_ATTACK_LEFT        kiki_start_side_tilt_left
	CONTROLLER_INPUT_SPECIAL_RIGHT      kiki_start_side_spe_right
	CONTROLLER_INPUT_SPECIAL_LEFT       kiki_start_side_spe_left
	CONTROLLER_INPUT_TECH               kiki_start_shielding
	CONTROLLER_INPUT_SPECIAL_DOWN       kiki_start_counter_guard
	CONTROLLER_INPUT_SPECIAL_UP         kiki_start_down_wall
	CONTROLLER_INPUT_ATTACK_UP          kiki_start_up_tilt
	CONTROLLER_INPUT_DOWN_TILT          kiki_start_down_tilt
	CONTROLLER_INPUT_JAB                kiki_start_jabbing
	CONTROLLER_INPUT_SPECIAL            kiki_start_top_wall
	CONTROLLER_INPUT_TECH_LEFT          kiki_start_shielding_left
	CONTROLLER_INPUT_TECH_RIGHT         kiki_start_shielding_right
	CONTROLLER_INPUT_SPECIAL_UP_LEFT    kiki_start_down_wall_left
	CONTROLLER_INPUT_SPECIAL_UP_RIGHT   kiki_start_down_wall_right
	CONTROLLER_INPUT_ATTACK_UP_LEFT     kiki_start_up_tilt_left
	CONTROLLER_INPUT_ATTACK_UP_RIGHT    kiki_start_up_tilt_right
	CONTROLLER_INPUT_SPECIAL_DOWN_LEFT  kiki_start_counter_guard_left
	CONTROLLER_INPUT_SPECIAL_DOWN_RIGHT kiki_start_counter_guard_right
	CONTROLLER_INPUT_ATTACK_DOWN_LEFT   kiki_start_down_tilt_left
	CONTROLLER_INPUT_ATTACK_DOWN_RIGHT  kiki_start_down_tilt_right

	no_input
}

; Input table for running state, special values are
;  input_running_left - Change running direction to the left (if not already running to the left)
;  input_runnning_right - Change running direction to the right (if not already running to the right)
!input-table-define "KIKI_RUNNING_INPUTS_TABLE" {
	CONTROLLER_INPUT_LEFT               input_running_left
	CONTROLLER_INPUT_RIGHT              input_running_right
	CONTROLLER_INPUT_JUMP               kiki_start_jumping
	CONTROLLER_INPUT_JUMP_RIGHT         kiki_start_jumping_right
	CONTROLLER_INPUT_JUMP_LEFT          kiki_start_jumping_left
	CONTROLLER_INPUT_ATTACK_LEFT        kiki_start_side_tilt_left
	CONTROLLER_INPUT_ATTACK_RIGHT       kiki_start_side_tilt_right
	CONTROLLER_INPUT_SPECIAL_LEFT       kiki_start_side_spe_left
	CONTROLLER_INPUT_SPECIAL_RIGHT      kiki_start_side_spe_right
	CONTROLLER_INPUT_TECH               kiki_start_shielding
	CONTROLLER_INPUT_SPECIAL_DOWN       kiki_start_counter_guard
	CONTROLLER_INPUT_SPECIAL_UP         kiki_start_down_wall
	CONTROLLER_INPUT_ATTACK_UP          kiki_start_up_tilt
	CONTROLLER_INPUT_DOWN_TILT          kiki_start_down_tilt
	CONTROLLER_INPUT_JAB                kiki_start_jabbing
	CONTROLLER_INPUT_SPECIAL            kiki_start_top_wall
	CONTROLLER_INPUT_TECH_LEFT          kiki_start_shielding_left
	CONTROLLER_INPUT_TECH_RIGHT         kiki_start_shielding_right
	CONTROLLER_INPUT_SPECIAL_UP_LEFT    kiki_start_down_wall_left
	CONTROLLER_INPUT_SPECIAL_UP_RIGHT   kiki_start_down_wall_right
	CONTROLLER_INPUT_ATTACK_UP_LEFT     kiki_start_up_tilt_left
	CONTROLLER_INPUT_ATTACK_UP_RIGHT    kiki_start_up_tilt_right
	CONTROLLER_INPUT_SPECIAL_DOWN_LEFT  kiki_start_counter_guard_left
	CONTROLLER_INPUT_SPECIAL_DOWN_RIGHT kiki_start_counter_guard_right
	CONTROLLER_INPUT_ATTACK_DOWN_LEFT   kiki_start_down_tilt_left
	CONTROLLER_INPUT_ATTACK_DOWN_RIGHT  kiki_start_down_tilt_right

	kiki_start_idle
}

; Input table for jumping state state (only used during jumpsquat), special values are
;  no_input - default
!input-table-define "KIKI_JUMPSQUAT_INPUTS_TABLE" {
	CONTROLLER_INPUT_ATTACK_UP        kiki_start_up_tilt
	CONTROLLER_INPUT_SPECIAL_UP       kiki_start_down_wall
	CONTROLLER_INPUT_ATTACK_UP_LEFT   kiki_start_up_tilt_left
	CONTROLLER_INPUT_SPECIAL_UP_LEFT  kiki_start_down_wall_left
	CONTROLLER_INPUT_ATTACK_UP_RIGHT  kiki_start_up_tilt_right
	CONTROLLER_INPUT_SPECIAL_UP_RIGHT kiki_start_down_wall_right

	no_input
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
; Respawn
;

kiki_start_respawn_extra:
.(
	; Set platform allowed flag
	lda #%10000000
	ora kiki_a_platform_state, x
	sta kiki_a_platform_state, x

	; Common respawn code
	jmp {char_name}_start_respawn_invisible

	;rts ; useless, jump to subroutine
.)

;
; Side Tilt
;

.(
	!define "anim" {kiki_anim_strike}
	!define "state" {KIKI_STATE_SIDE_TILT}
	!define "routine" {side_tilt}
	!include "characters/tpl_grounded_attack.asm"
.)

;
; Side special
;

.(
	KIKI_WALL_WHIFF = 0
	KIKI_WALL_DRAWN = 1
	kiki_a_wall_drawn = player_a_state_field1

	kiki_anim_paint_side_dur:
		.byt kiki_anim_paint_side_dur_pal, kiki_anim_paint_side_dur_ntsc

	&kiki_start_side_spe_right:
	.(
		lda DIRECTION_RIGHT
		sta player_a_direction, x
		jmp kiki_start_side_spe
		; rts ; useless - kiki_start_side_spe is a routine
	.)

	&kiki_start_side_spe_left:
	.(
		lda DIRECTION_LEFT
		sta player_a_direction, x
		; jmp kiki_start_side_spe ; useless - fallthrough
		; rts ; useless - kiki_start_side_spe is a routine
	.)

	&kiki_start_side_spe:
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

		; NOTE interesting velocity setups
		;  Original - rapidly slow down to (0, 0) (was done to copy-paste code from side tilt)
		;  Current - directly stop any velocity (should feel like original, without computations per tick)
		;  Idea 2 - stop horizontal velocity, keep vertical velocity, apply gravity on tick (should help to side spe as part of aerial gameplay)

		; Avoid spawning wall when forbiden
		lda kiki_a_platform_state, x
		and #%10000000
		bne process
			lda #KIKI_WALL_WHIFF
			sta kiki_a_wall_drawn, x
			jmp spawn_wall_end
		process:

		lda #KIKI_WALL_DRAWN
		sta kiki_a_wall_drawn, x

		; Reset velocity
		lda #0
		sta player_a_velocity_h_low, x
		sta player_a_velocity_h, x
		sta player_a_velocity_v_low, x
		sta player_a_velocity_v, x

		; Spawn wall
		spawn_wall:
		.(
			; Reset wall state
			ldy system_index
			lda kiki_platform_duration, y
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

			;lda #STAGE_ELEMENT_END
			;sta player_a_objects+STAGE_ELEMENT_SIZE, y ; next's type, useless, set at init time

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

			; Y = first wall sprite offset
			lda kiki_first_wall_sprite_per_player, x
			asl
			asl
			tay

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

			; Mirror sprites screen position in unused object memory
			lda oam_mirror+4, y
			pha
			lda oam_mirror, y
			pha

			ldy kiki_first_wall_sprite_y_per_player, x
			pla
			sta stage_data, y
			iny
			pla
			sta stage_data, y
		.)
		spawn_wall_end:

		rts
	.)

	&kiki_tick_side_spe:
	.(
		jsr kiki_global_tick

		; Apply gravity if failed to paint
		lda kiki_a_wall_drawn, x
		bne skip_gravity
			jsr kiki_apply_friction_lite
		skip_gravity:

		; Return to inactive state after animation's duration
		inc player_a_state_clock, x

		ldy system_index
		lda player_a_state_clock, x
		cmp kiki_anim_paint_side_dur, y
		bne end

			jmp kiki_start_inactive_state
			; No return, jump to subroutine

		end:
		rts
	.)
.)

.(
	kiki_anim_paint_down_dur:
		.byt kiki_anim_paint_down_dur_pal, kiki_anim_paint_down_dur_ntsc

	&{char_name}_start_down_wall_left:
	.(
		lda #DIRECTION_LEFT2
		jmp {char_name}_start_down_wall_directional
	.)
	&{char_name}_start_down_wall_right:
	.(
		lda #DIRECTION_RIGHT2
		; Fallthrough to {char_name}_start_down_wall_directional
	.)
	{char_name}_start_down_wall_directional:
	.(
		sta player_a_direction, x
		; Fallthrough to {char_name}_start_down_wall
	.)
	&kiki_start_down_wall:
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
		lda #KIKI_STATE_DOWN_WALL
		sta player_a_state, x

		; Initialize the clock
		lda #0
		sta player_a_state_clock,x

		; Avoid spawning wall when forbiden
		lda kiki_a_platform_state, x
		and #%10000000
		bne process
			jmp spawn_wall_end
		process:

		; Reset velocity
		lda #0
		sta player_a_velocity_h_low, x
		sta player_a_velocity_h, x
		sta player_a_velocity_v_low, x
		sta player_a_velocity_v, x

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
			ldy system_index
			lda kiki_platform_duration, y
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

			;lda #STAGE_ELEMENT_END
			;sta player_a_objects+STAGE_ELEMENT_SIZE, y ; next's type, useless, set at init time

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

			; Y = first wall sprite offset
			lda kiki_first_wall_sprite_per_player, x
			asl
			asl
			tay

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

			; Mirror sprites screen position in unused object memory
			lda oam_mirror+4, y
			pha
			lda oam_mirror, y
			pha

			ldy kiki_first_wall_sprite_y_per_player, x
			pla
			sta stage_data, y
			iny
			pla
			sta stage_data, y
		.)
		spawn_wall_end:

		rts
	.)

	&kiki_tick_down_wall:
	.(
		jsr kiki_global_tick

		jsr apply_player_gravity

		inc player_a_state_clock, x

		ldy system_index
		lda player_a_state_clock, x
		cmp kiki_anim_paint_down_dur, y
		bne end
			jmp kiki_start_inactive_state

		end:
		rts
	.)
.)

.(
	KIKI_WALL_WHIFF = 0
	KIKI_WALL_DRAWN = 1
	kiki_a_wall_drawn = player_a_state_field1

	kiki_anim_paint_up_dur:
		.byt kiki_anim_paint_side_dur_pal, kiki_anim_paint_side_dur_ntsc

	&kiki_start_top_wall:
	.(
		sprite_x_lsb = tmpfield1
		sprite_x_msb = tmpfield2
		sprite_y_lsb = tmpfield3
		sprite_y_msb = tmpfield4

		; Set the appropriate animation
		lda #<kiki_anim_paint_up
		sta tmpfield13
		lda #>kiki_anim_paint_up
		sta tmpfield14
		jsr set_player_animation

		; Set the player's state
		lda #KIKI_STATE_TOP_WALL
		sta player_a_state, x

		; Initialize the clock
		lda #0
		sta player_a_state_clock,x

		; Avoid spawning wall when forbiden
		lda kiki_a_platform_state, x
		and #%10000000
		bne process
			lda #KIKI_WALL_WHIFF
			sta kiki_a_wall_drawn, x
			jmp spawn_wall_end
		process:

		lda #KIKI_WALL_DRAWN
		sta kiki_a_wall_drawn, x

		; Reset velocity
		lda #0
		sta player_a_velocity_h_low, x
		sta player_a_velocity_h, x
		sta player_a_velocity_v_low, x
		sta player_a_velocity_v, x

		; Spawn wall
		spawn_wall:
		.(
			; Reset wall state
			ldy system_index
			lda kiki_platform_duration, y
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

			;lda #STAGE_ELEMENT_END
			;sta player_a_objects+STAGE_ELEMENT_SIZE, y ; next's type, useless, set at init time

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

			; Y = first wall sprite offset
			lda kiki_first_wall_sprite_per_player, x
			asl
			asl
			tay

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

			; Mirror sprites screen position in unused object memory
			lda oam_mirror+4, y
			pha
			lda oam_mirror, y
			pha

			ldy kiki_first_wall_sprite_y_per_player, x
			pla
			sta stage_data, y
			iny
			pla
			sta stage_data, y
		.)
		spawn_wall_end:

		rts
	.)

	&kiki_tick_top_wall:
	.(
		jsr kiki_global_tick

		; Apply gravity if failed to paint
		lda kiki_a_wall_drawn, x
		bne skip_gravity
			jsr kiki_apply_friction_lite
		skip_gravity:

		; Return to inactive state after animation's duration
		inc player_a_state_clock, x

		ldy system_index
		lda player_a_state_clock, x
		cmp kiki_anim_paint_up_dur, y
		bne end

			jmp kiki_start_inactive_state

		end:
		rts
	.)
.)

!define "anim" {kiki_anim_strike_up}
!define "state" {KIKI_STATE_UP_TILT}
!define "routine" {up_tilt}
!include "characters/tpl_grounded_attack.asm"

!define "anim" {kiki_anim_strike_up}
!define "state" {KIKI_STATE_UP_AERIAL}
!define "routine" {up_aerial}
!include "characters/tpl_aerial_attack.asm"

!define "anim" {kiki_anim_strike_down}
!define "state" {KIKI_STATE_DOWN_TILT}
!define "routine" {down_tilt}
!include "characters/tpl_grounded_attack.asm"

;HACK aerial-down is not cancellable, but don't use the "tpl_aerial_attack_uncancellable.asm"
;  - we don't get any friction on ground, allowing for great landing slide
;  - TODO change it to uncancellable template, may need to rework Kiki's ground friction (or allow special case in the tamplate)
!define "anim" {kiki_anim_strike_down}
!define "state" {KIKI_STATE_DOWN_AERIAL}
!define "routine" {down_aerial}
!include "characters/tpl_aerial_attack.asm"

.(
	!define "anim" {kiki_anim_strike}
	!define "state" {KIKI_STATE_SIDE_AERIAL}
	!define "routine" {side_aerial}
	!include "characters/tpl_aerial_attack.asm"
.)

;
; Jab
;

.(
	!define "anim" {kiki_anim_jab}
	!define "state" {KIKI_STATE_JABBING}
	!define "routine" {jabbing}
	!include "characters/tpl_grounded_attack.asm"

	&kiki_input_jabbing:
	.(
		; Allow to cut the animation for another jab
		lda controller_a_btns, x
		cmp #CONTROLLER_INPUT_JAB
		bne end
			jmp kiki_start_jabbing
			;No return

		end:
		rts
	.)
.)

!define "anim" {kiki_anim_aerial_neutral}
!define "state" {KIKI_STATE_NEUTRAL_AERIAL}
!define "routine" {neutral_aerial}
!include "characters/tpl_aerial_attack.asm"

.(
	COUNTER_GUARD_ACTIVE_DURATION = 18
	COUNTER_GUARD_TOTAL_DURATION = 43

	velocity_table(KIKI_COUNTER_GRAVITY, kiki_counter_gravity_msb, kiki_counter_gravity_lsb)
	duration_table(COUNTER_GUARD_ACTIVE_DURATION, counter_guard_active_duration)
	duration_table(COUNTER_GUARD_TOTAL_DURATION, counter_guard_total_duration)

	&kiki_start_counter_guard_right:
	.(
		lda #DIRECTION_RIGHT2
		sta player_a_direction, x
		jmp kiki_start_counter_guard
	.)
	&kiki_start_counter_guard_left:
	.(
		lda #DIRECTION_LEFT2
		sta player_a_direction, x
		;Fallthrough to kiki_start_counter_guard
	.)
	&kiki_start_counter_guard:
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

		; Cancel vertical momentum
		;lda #0 ; useless, done above
		sta player_a_velocity_v_low, x
		sta player_a_velocity_v, x

		; Lower horizontal momentum
		lda player_a_velocity_h, x ; Set sign bit in carry flag, so the following bitshift is a signed division
		rol

		ror player_a_velocity_h, x
		ror player_a_velocity_h_low, x

		; Lower gravity
		ldy system_index
		lda kiki_counter_gravity_lsb, y
		sta player_a_gravity_lsb, x
		lda kiki_counter_gravity_msb, y
		sta player_a_gravity_msb, x

		rts
	.)

	&kiki_tick_counter_guard:
	.(
		jsr kiki_global_tick

		jsr kiki_apply_friction_lite

		inc player_a_state_clock, x

		ldy system_index
		lda player_a_state_clock, x
		cmp counter_guard_active_duration, y
		bne check_total_duration

			; Active duration is over, display it by switching to weak animation
			lda #<kiki_anim_counter_weak
			sta tmpfield13
			lda #>kiki_anim_counter_weak
			sta tmpfield14
			jsr set_player_animation

			; Reset fall speed
			jsr reset_default_gravity

		check_total_duration:
		cmp counter_guard_total_duration, y
		bne end

			; Total duration is over, return to a neutral state
			jsr reset_default_gravity
			jmp kiki_start_inactive_state
			; No return, jump to subroutine

		end:
		rts
	.)

	&kiki_hurt_counter_guard:
	.(
		striker_player = tmpfield10
		stroke_player = tmpfield11

		lda stroke_player
		pha
		lda striker_player
		pha

		; Strike if still active, else get hurt
		ldy system_index
		lda counter_guard_active_duration, y
		cmp player_a_state_clock, x
		bcc hurt

			ldy striker_player
			lda #HITBOX_DISABLED
			sta player_a_hitbox_enabled, y

			jsr reset_default_gravity

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
.)

.(
	COUNTER_STRIKE_DURATION = 12
	duration_table(COUNTER_STRIKE_DURATION, counter_strike_duration)

	&kiki_start_counter_strike:
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

	&kiki_tick_counter_strike:
	.(
		jsr kiki_global_tick

		jsr apply_player_gravity

		ldy system_index
		inc player_a_state_clock, x
		lda player_a_state_clock, x
		cmp counter_strike_duration, y
		bne end
			jsr kiki_start_falling

		end:
		rts
	.)
.)

!include "characters/std_friction_routines.asm"

; Standard move names
;{char_name}_start_down_tilt = {char_name}_start_down_tilt
{char_name}_start_spe_down = {char_name}_start_counter_guard

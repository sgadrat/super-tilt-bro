!define "char_name" {sunny}
!define "char_name_upper" {SUNNY}

;
; Gameplay constants
;

SUNNY_AERIAL_SPEED = $0180
SUNNY_AERIAL_DIRECTIONAL_INFLUENCE_STRENGTH = $c0
SUNNY_AIR_FRICTION_STRENGTH = 7
SUNNY_FASTFALL_SPEED = $0500
SUNNY_GROUND_FRICTION_STRENGTH = $40
SUNNY_JUMP_POWER = $0480
SUNNY_JUMP_SHORT_HOP_POWER = $0100
SUNNY_JUMP_SHORT_HOP_EXTRA_TIME_PAL = 4 ; Number of frames after jumpsquat at which shorthop is handled
SUNNY_JUMP_SHORT_HOP_EXTRA_TIME_NTSC = 5
SUNNY_JUMP_SHORT_HOP_AERIAL_TIME_PAL = 2 ;  Number of frames after jumpsquat at which an attack input stops converting is into a short hop-aerial
SUNNY_JUMP_SHORT_HOP_AERIAL_TIME_NTSC = 2
SUNNY_JUMP_SQUAT_DURATION_PAL = 4
SUNNY_JUMP_SQUAT_DURATION_NTSC = 5
SUNNY_LANDING_MAX_VELOCITY = $01c0
SUNNY_MAX_NUM_AERIAL_JUMPS = 1
SUNNY_ALL_SPECIAL_JUMPS = %10000001
SUNNY_RUNNING_INITIAL_VELOCITY = $0100
SUNNY_RUNNING_MAX_VELOCITY = $01c0
SUNNY_RUNNING_ACCELERATION = $20
SUNNY_TECH_SPEED = $0300
SUNNY_WALL_JUMP_SQUAT_END = 4
SUNNY_WALL_JUMP_VELOCITY_V = $0500
SUNNY_WALL_JUMP_VELOCITY_H = $0100

;
; Constants data
;

!include "characters/std_constant_tables.asm"

;
; Pearl shot implementation
;

sunny_pearl_sprite_oam_per_player:
	.byt INGAME_PLAYER_A_LAST_SPRITE*4, INGAME_PLAYER_B_LAST_SPRITE*4

.(

	pearl_direction_h = player_a_state_extra1
	pearl_counter = player_a_state_extra2
	pearl_up_counter = player_a_state_extra3
	pearl_x_subpixel = player_a_state_extra4
	pearl_y_subpixel = player_a_state_extra5
	pearl_x_pixel = player_a_state_extra6
	pearl_y_pixel = player_a_state_extra7
	pearl_x_screen = player_a_state_extra8
	pearl_y_screen = player_a_state_extra9

	PEARL_DURATION = 100
	duration_table(PEARL_DURATION, pearl_duration)

	PEARL_HORIZONTAL_VELOCITY = $0140
	velocity_table(PEARL_HORIZONTAL_VELOCITY, pearl_h_velocity_right_msb, pearl_h_velocity_right_lsb)
	velocity_table(-PEARL_HORIZONTAL_VELOCITY, pearl_h_velocity_left_msb, pearl_h_velocity_left_lsb)

#define SUNNY_SIG(x) (((x >> 15) & $01) * $ff)
#define SUNNY_MSB(x) >(x)
#define SUNNY_LSB(x) <(x)

#define SUNNY_NSI(x) ((( (((x)*5)/6) >> 15) & $01) * $ff)
#define SUNNY_NMS(x) >(((x)*5)/6)
#define SUNNY_NLS(x) <(((x)*5)/6)

	;NOTE as long has we never have value below -$0100 (above $ff00), sign table and msb table are the same
	;     (could save 66 bytes if we really need it)
	pearl_v_velocity_pal_sign:
		.byt SUNNY_SIG($0100), SUNNY_SIG($00c0), SUNNY_SIG($0080), SUNNY_SIG($0060), SUNNY_SIG($0050)
		.byt SUNNY_SIG($0040), SUNNY_SIG($0030), SUNNY_SIG($0020), SUNNY_SIG($0010), SUNNY_SIG($0008)
		.byt SUNNY_SIG($0004), SUNNY_SIG($0002), SUNNY_SIG($0001), SUNNY_SIG($0000), SUNNY_SIG($0000)
		.byt SUNNY_SIG($0000), SUNNY_SIG($0000), SUNNY_SIG($ffff), SUNNY_SIG($fffe), SUNNY_SIG($fffc)
		.byt SUNNY_SIG($fff8), SUNNY_SIG($fff0), SUNNY_SIG($ffe0), SUNNY_SIG($ffc0), SUNNY_SIG($ff80)
		.byt SUNNY_SIG($ff40), SUNNY_SIG($ff20), SUNNY_SIG($ff10), SUNNY_SIG($ff00), SUNNY_SIG($ff00)
	pearl_v_velocity_pal_msb:
		.byt SUNNY_MSB($0100), SUNNY_MSB($00c0), SUNNY_MSB($0080), SUNNY_MSB($0060), SUNNY_MSB($0050)
		.byt SUNNY_MSB($0040), SUNNY_MSB($0030), SUNNY_MSB($0020), SUNNY_MSB($0010), SUNNY_MSB($0008)
		.byt SUNNY_MSB($0004), SUNNY_MSB($0002), SUNNY_MSB($0001), SUNNY_MSB($0000), SUNNY_MSB($0000)
		.byt SUNNY_MSB($0000), SUNNY_MSB($0000), SUNNY_MSB($ffff), SUNNY_MSB($fffe), SUNNY_MSB($fffc)
		.byt SUNNY_MSB($fff8), SUNNY_MSB($fff0), SUNNY_MSB($ffe0), SUNNY_MSB($ffc0), SUNNY_MSB($ff80)
		.byt SUNNY_MSB($ff40), SUNNY_MSB($ff20), SUNNY_MSB($ff10), SUNNY_MSB($ff00), SUNNY_MSB($ff00)
	pearl_v_velocity_pal_lsb:
		.byt SUNNY_LSB($0100), SUNNY_LSB($00c0), SUNNY_LSB($0080), SUNNY_LSB($0060), SUNNY_LSB($0050)
		.byt SUNNY_LSB($0040), SUNNY_LSB($0030), SUNNY_LSB($0020), SUNNY_LSB($0010), SUNNY_LSB($0008)
		.byt SUNNY_LSB($0004), SUNNY_LSB($0002), SUNNY_LSB($0001), SUNNY_LSB($0000), SUNNY_LSB($0000)
		.byt SUNNY_LSB($0000), SUNNY_LSB($0000), SUNNY_LSB($ffff), SUNNY_LSB($fffe), SUNNY_LSB($fffc)
		.byt SUNNY_LSB($fff8), SUNNY_LSB($fff0), SUNNY_LSB($ffe0), SUNNY_LSB($ffc0), SUNNY_LSB($ff80)
		.byt SUNNY_LSB($ff40), SUNNY_LSB($ff20), SUNNY_LSB($ff10), SUNNY_LSB($ff00), SUNNY_LSB($ff00)
	PEARL_V_VELOCITY_TABLE_LEN_PAL = * - pearl_v_velocity_pal_lsb

	pearl_v_velocity_ntsc_sign:
		.byt SUNNY_NSI($0100), SUNNY_NSI($00cb), SUNNY_NSI($009a), SUNNY_NSI($0090), SUNNY_NSI($0066), SUNNY_NSI($0050)
		.byt SUNNY_NSI($0040), SUNNY_NSI($0034), SUNNY_NSI($0027), SUNNY_NSI($001a), SUNNY_NSI($000d), SUNNY_NSI($0008)
		.byt SUNNY_NSI($0004), SUNNY_NSI($0002), SUNNY_NSI($0001), SUNNY_NSI($0001), SUNNY_NSI($0000), SUNNY_NSI($0000)
		.byt SUNNY_NSI($0000), SUNNY_NSI($0000), SUNNY_NSI(-$0001), SUNNY_NSI(-$0002), SUNNY_NSI(-$0003), SUNNY_NSI(-$0004)
		.byt SUNNY_NSI(-$0008), SUNNY_NSI(-$0010), SUNNY_NSI(-$0020), SUNNY_NSI(-$0040), SUNNY_NSI(-$0060), SUNNY_NSI(-$0080)
		.byt SUNNY_NSI(-$00c0), SUNNY_NSI(-$00e8), SUNNY_NSI(-$00f6), SUNNY_NSI(-$00fc), SUNNY_NSI(-$0100), SUNNY_NSI(-$0100)
	pearl_v_velocity_ntsc_msb:
		.byt SUNNY_NMS($0100), SUNNY_NMS($00cb), SUNNY_NMS($009a), SUNNY_NMS($0090), SUNNY_NMS($0066), SUNNY_NMS($0050)
		.byt SUNNY_NMS($0040), SUNNY_NMS($0034), SUNNY_NMS($0027), SUNNY_NMS($001a), SUNNY_NMS($000d), SUNNY_NMS($0008)
		.byt SUNNY_NMS($0004), SUNNY_NMS($0002), SUNNY_NMS($0001), SUNNY_NMS($0001), SUNNY_NMS($0000), SUNNY_NMS($0000)
		.byt SUNNY_NMS($0000), SUNNY_NMS($0000), SUNNY_NMS(-$0001), SUNNY_NMS(-$0002), SUNNY_NMS(-$0003), SUNNY_NMS(-$0004)
		.byt SUNNY_NMS(-$0008), SUNNY_NMS(-$0010), SUNNY_NMS(-$0020), SUNNY_NMS(-$0040), SUNNY_NMS(-$0060), SUNNY_NMS(-$0080)
		.byt SUNNY_NMS(-$00c0), SUNNY_NMS(-$00e8), SUNNY_NMS(-$00f6), SUNNY_NMS(-$00fc), SUNNY_NMS(-$0100), SUNNY_NMS(-$0100)
	pearl_v_velocity_ntsc_lsb:
		.byt SUNNY_NLS($0100), SUNNY_NLS($00cb), SUNNY_NLS($009a), SUNNY_NLS($0090), SUNNY_NLS($0066), SUNNY_NLS($0050)
		.byt SUNNY_NLS($0040), SUNNY_NLS($0034), SUNNY_NLS($0027), SUNNY_NLS($001a), SUNNY_NLS($000d), SUNNY_NLS($0008)
		.byt SUNNY_NLS($0004), SUNNY_NLS($0002), SUNNY_NLS($0001), SUNNY_NLS($0001), SUNNY_NLS($0000), SUNNY_NLS($0000)
		.byt SUNNY_NLS($0000), SUNNY_NLS($0000), SUNNY_NLS(-$0001), SUNNY_NLS(-$0002), SUNNY_NLS(-$0003), SUNNY_NLS(-$0004)
		.byt SUNNY_NLS(-$0008), SUNNY_NLS(-$0010), SUNNY_NLS(-$0020), SUNNY_NLS(-$0040), SUNNY_NLS(-$0060), SUNNY_NLS(-$0080)
		.byt SUNNY_NLS(-$00c0), SUNNY_NLS(-$00e8), SUNNY_NLS(-$00f6), SUNNY_NLS(-$00fc), SUNNY_NLS(-$0100), SUNNY_NLS(-$0100)
	PEARL_V_VELOCITY_TABLE_LEN_NTSC = * - pearl_v_velocity_ntsc_lsb

	pearl_v_velocity_table_last:
		.byt PEARL_V_VELOCITY_TABLE_LEN_PAL-1, PEARL_V_VELOCITY_TABLE_LEN_NTSC-1

#if PEARL_V_VELOCITY_TABLE_LEN_NTSC <> (PEARL_V_VELOCITY_TABLE_LEN_PAL)+((((PEARL_V_VELOCITY_TABLE_LEN_PAL)*10)/5)+5)/10
#error pearl velocity tables have differing duration in PAL vs NTSC
#endif

	; Pearl position is used for platform collision, its hitbox should actually be offsetted to have logical positioning
	; Pearl width/height are actually -1 of graphics because "bottom = top + height" so zero is one line of pixels
	PEARL_PROJECTILE_OFFSET_VERTICAL = 11
	PEARL_PROJECTILE_OFFSET_HORIZONTAL = 1
	PEARL_PROJECTILE_HEIGHT = 6
	PEARL_PROJECTILE_WIDTH = 6

	+sunny_netload:
	.(
		lda esp_rx_buffer+0, y
		sta player_a_projectile_1_flags, x
		beq pearl_inactive

			pearl_active:
				; Pearl-specific state
				lda esp_rx_buffer+1, y
				sta player_a_state_extra1, x
				lda esp_rx_buffer+2, y
				sta player_a_state_extra2, x
				lda esp_rx_buffer+3, y
				sta player_a_state_extra3, x
				lda esp_rx_buffer+4, y
				sta player_a_state_extra4, x
				lda esp_rx_buffer+5, y
				sta player_a_state_extra5, x
				lda esp_rx_buffer+6, y
				sta player_a_state_extra6, x
				lda esp_rx_buffer+7, y
				sta player_a_state_extra7, x
				lda esp_rx_buffer+8, y
				sta player_a_state_extra8, x
				lda esp_rx_buffer+9, y
				sta player_a_state_extra9, x

				; Recompute pearl hitbox
				jsr place_pearl_hitbox

				; Return with updated buffer cursor
				tya
				clc
				adc #10
				tay

				rts

			pearl_inactive:
				; Return with updated buffer cursor
				iny
				rts

		;rts ; useless no branch return
	.)

	&sunny_pearl_shot_spawn:
	.(
		; Activate projectile
		lda #PROJECTILE_FLAGS_ACTIVE
		sta player_a_projectile_1_flags, x

		; Position pearl
		.(
			lda #0
			sta pearl_x_subpixel, x

			lda player_a_direction, x
			bne right
				left:
					lda player_a_x, x
					clc
					adc #<-8
					sta pearl_x_pixel, x
					lda player_a_x_screen, x
					adc #>-8
					sta pearl_x_screen, x
					jmp ok
				right:
					lda player_a_x, x
					clc
					adc #<8
					sta pearl_x_pixel, x
					lda player_a_x_screen, x
					adc #>8
					sta pearl_x_screen, x
					jmp ok
			ok:
		.)

		lda #0
		sta pearl_y_subpixel, x
		lda player_a_y, x
		clc
		adc #<-4
		sta pearl_y_pixel, x
		lda player_a_y_screen, x
		adc #>-4
		sta pearl_y_screen, x

		; Set hitbox boundaries
		jsr place_pearl_hitbox

		; Init pearl state
		ldy system_index
		lda pearl_duration, y
		sta pearl_counter, x

		lda player_a_direction, x
		sta pearl_direction_h, x

		lda #0
		sta pearl_up_counter, x

		rts
	.)

	+sunny_pearl_shot_hit:
	.(
		stroke_player_onhurt_table_addr = tmpfield1     ; Not movable, parameter of far_lda_tmpfield1_y
		stroke_player_onhurt_table_addr_msb = tmpfield2 ; Not movable, parameter of far_lda_tmpfield1_y
		stroke_player_onhurt_handler_addr = tmpfield3
		stroke_player_onhurt_handler_addr_msb = tmpfield4
		stroke_player_bank = tmpfield5
		striker_player = tmpfield10      ; Not movable, parameter of onhurt handler
		stroke_player = tmpfield11       ; Not movable, parameter of onhurt handler
		default_onhurt_lsb = tmpfield12  ; Not movable, parameter of onhurt handler
		default_onhurt_msb = tmpfield13  ; Not movable, parameter of onhurt handler
		default_onhurt_bank = tmpfield14 ; Not movable, parameter of onhurt handler

		; Disable pearl
		lda #PROJECTILE_FLAGS_DEACTIVATED
		sta player_a_projectile_1_flags, x

		; Save player number
		stx player_number

		; Select action depending on hitbox type
		cpy #HURTBOX
		beq strike_hurtbox
		cpy #HITBOX
		bne strike_otherbox

			strike_hitbox:
				; Screen freeze
				SHAKE_INTENSITY = 0
				SHAKE_DURATION = 5

				lda #SHAKE_INTENSITY
				sta screen_shake_noise_h
				sta screen_shake_noise_v
				lda #SHAKE_DURATION
				sta screen_shake_counter
				lda #0
				sta screen_shake_current_x
				sta screen_shake_current_y

				; Play SFX
				ldx #SFX_PARRY_IDX
				jsr audio_play_sfx_from_list

				ldx player_number
				rts

			strike_otherbox:
				; Do not do anything aside disabling pearl
				rts

			strike_hurtbox:
				; Select action depending on opponent's hurt handler
				SWITCH_SELECTED_PLAYER

				ldy config_player_a_character, x
				lda characters_onhurt_routines_table_lsb, y
				sta stroke_player_onhurt_table_addr
				lda characters_onhurt_routines_table_msb, y
				sta stroke_player_onhurt_table_addr_msb
				lda characters_bank_number, y
				sta stroke_player_bank

				lda player_a_state, x
				asl
				tay

				lda stroke_player_bank : jsr far_lda_tmpfield1_y
				sta stroke_player_onhurt_handler_addr
				iny
				lda stroke_player_bank : jsr far_lda_tmpfield1_y
				sta stroke_player_onhurt_handler_addr_msb
				;NOTE - here register X is garbage

				BEQ16(hurt, #<hurt_player, #>hurt_player, stroke_player_onhurt_handler_addr, stroke_player_onhurt_handler_addr_msb)
				BEQ16(intangible, #<dummy_routine, #>dummy_routine, stroke_player_onhurt_handler_addr, stroke_player_onhurt_handler_addr_msb)

					custom_onhurt_handler:
						; Call the custom handler
						ldx player_number
						stx striker_player
						SWITCH_SELECTED_PLAYER
						stx stroke_player

						lda #<sunny_hurt_by_pearl_default
						sta default_onhurt_lsb
						lda #>sunny_hurt_by_pearl_default
						sta default_onhurt_msb
						lda #CURRENT_BANK_NUMBER
						sta default_onhurt_bank
						TRAMPOLINE_POINTED(stroke_player_onhurt_handler_addr, stroke_player_onhurt_handler_addr_msb, stroke_player_bank, #CURRENT_BANK_NUMBER)
						lda striker_player
						rts

					intangible:
						; Changed mind, do not disable pearl
						ldx player_number
						lda #PROJECTILE_FLAGS_ACTIVE
						sta player_a_projectile_1_flags, x
						rts

					&sunny_normal_pearl_on_normal_hurtbox:
					hurt:
						; Apply knockback
						.(
							KNOCKUP_BASE_HORIZONTAL = -200
							KNOCKUP_BASE_VERTICAL = -500
							KNOCKUP_SCALING_HORIZONTAL = -1
							KNOCKUP_SCALING_VERTICAL = -2
							HITSTUN_MODIFIER = 0

							base_h_lsb = tmpfield6
							base_h_msb = tmpfield7
							force_h_lsb = tmpfield14
							force_h_msb = tmpfield12
							base_v_lsb = tmpfield8
							base_v_msb = tmpfield9
							force_v_lsb = tmpfield15
							force_v_msb = tmpfield13
							hitstun_modifier = tmpfield16

							ldx player_number

							lda pearl_direction_h, x
							bne right
								left:
									lda #<KNOCKUP_BASE_HORIZONTAL : sta base_h_lsb
									lda #>KNOCKUP_BASE_HORIZONTAL : sta base_h_msb
									lda #<KNOCKUP_SCALING_HORIZONTAL : sta force_h_lsb
									lda #>KNOCKUP_SCALING_HORIZONTAL : sta force_h_msb
									jmp ok
								right:
									lda #<-KNOCKUP_BASE_HORIZONTAL : sta base_h_lsb
									lda #>-KNOCKUP_BASE_HORIZONTAL : sta base_h_msb
									lda #<-KNOCKUP_SCALING_HORIZONTAL : sta force_h_lsb
									lda #>-KNOCKUP_SCALING_HORIZONTAL : sta force_h_msb
							ok:
							lda #<KNOCKUP_BASE_VERTICAL : sta base_v_lsb
							lda #>KNOCKUP_BASE_VERTICAL : sta base_v_msb
							lda #<KNOCKUP_SCALING_VERTICAL : sta force_v_lsb
							lda #>KNOCKUP_SCALING_VERTICAL : sta force_v_msb
							lda #HITSTUN_MODIFIER : sta hitstun_modifier

							SWITCH_SELECTED_PLAYER
							jsr apply_force_vector_direct
						.)

						; Apply dammage
						.(
							ldy player_a_damages, x
							cpy #199
							bcs ok
								iny
								sty player_a_damages, x
							ok:
						.)

						; Throw opponent
						.(
							ldy config_player_a_character, x
							TRAMPOLINE(hurt_player_direct, characters_bank_number COMMA y, #CURRENT_BANK_NUMBER)
						.)

						; Return
						ldx player_number
						rts

		;rts ; useless, branches return directly
	.)

	; Called by opponent custom onhurt handler when it want's to fallback to default behavior of being thrown
	+sunny_hurt_by_pearl_default:
	.(
		striker_player = tmpfield10
		stroke_player = tmpfield11

		lda striker_player
		sta player_number
		jsr sunny_normal_pearl_on_normal_hurtbox
		ldx stroke_player
		stx player_number
		rts
	.)

	+sunny_global_tick:
	.(
		lda player_a_projectile_1_flags, x
		bne sunny_pearl_shot_tick

			; Hide pearl sprite
			lda #$fe
			ldy sunny_pearl_sprite_oam_per_player, x
			sta oam_mirror, y
			rts

		; Fallthrough to sunny_pearl_shot_tick possible by the above BNE
	.)

	sunny_pearl_shot_tick:
	.(
		elements_action_vector = tmpfield1 ; Not movable, parameter of stage_iterate_all_elements
		;tmpfield2 reseved for elements_action_vector msb
		final_x_pixel = tmpfield3
		final_x_screen = tmpfield4
		final_y_pixel = tmpfield5
		final_y_screen = tmpfield6
		collided_platform = tmpfield7
		platform_specific_handler_lsb = tmpfield8
		platform_specific_handler_msb = tmpfield9
		platform_top_pixel = tmpfield10
		platform_top_screen = tmpfield11

		; Destroy if end of life
		.(
			dec pearl_counter, x
			bne ok
				lda #PROJECTILE_FLAGS_DEACTIVATED
				sta player_a_projectile_1_flags, x
				rts
			ok:
		.)

		;NOTE movement+collision code has a lot in common with move_player from game's logic
		;     may be doable to factorize platform collision code
		;NOTE only one collision detection is done at the end, instead of one for vertical
		;     and one for horizontal movement.
		;     That means pearl may path through corners of two adjacent platforms. Should be
		;     less impacting than for players as the pearl is destroyed if ending in a platform
		;     because of that.

		; Vertical movement
		.(
			ldy system_index
			bne ntsc
				pal:
					ldy pearl_up_counter, x
					lda pearl_v_velocity_pal_lsb, y
					clc
					adc pearl_y_subpixel, x
					sta pearl_y_subpixel, x

					lda pearl_v_velocity_pal_msb, y
					adc pearl_y_pixel, x
					sta final_y_pixel

					lda pearl_v_velocity_pal_sign, y
					adc pearl_y_screen, x
					sta final_y_screen

					jmp move_ok

				ntsc:
					ldy pearl_up_counter, x
					lda pearl_v_velocity_ntsc_lsb, y
					clc
					adc pearl_y_subpixel, x
					sta pearl_y_subpixel, x

					lda pearl_v_velocity_ntsc_msb, y
					adc pearl_y_pixel, x
					sta final_y_pixel

					lda pearl_v_velocity_ntsc_sign, y
					adc pearl_y_screen, x
					sta final_y_screen
			move_ok:

			dec pearl_up_counter, x
			bpl ok
				inc pearl_up_counter, x

			ok:
		.)

		; Horizontal movement
		.(
			ldy system_index

			lda pearl_direction_h, x
			bne right
				left:
					clc
					lda pearl_x_subpixel, x
					adc pearl_h_velocity_left_lsb, y
					sta pearl_x_subpixel, x
					lda pearl_x_pixel, x
					adc pearl_h_velocity_left_msb, y
					sta final_x_pixel
					lda pearl_x_screen, x
					adc #$ff
					sta final_x_screen
					jmp ok
				right:
					clc
					lda pearl_x_subpixel, x
					adc pearl_h_velocity_right_lsb, y
					sta pearl_x_subpixel, x
					lda pearl_x_pixel, x
					adc pearl_h_velocity_right_msb, y
					sta final_x_pixel
					lda pearl_x_screen, x
					adc #0
					sta final_x_screen

			ok:
		.)

		; Collision detection - destroy the pearl if horizontal, rebound if vertical
		.(
			stx player_number

			lda #<platform_collision_handler
			sta elements_action_vector
			lda #>platform_collision_handler
			sta elements_action_vector+1
			jsr stage_iterate_all_elements
			;ldx player_number ;useless, X won't be read before being trashed again (and actually platform_collision_handler does not trash it)

			cpy #$ff
			bne ok
				; Detect collision direction, vertical if original position is above the platform
				jsr load_platform_top
				ldx player_number

				lda pearl_y_screen, x
				cmp platform_top_screen
				bcc vertical
				bne horizontal
				lda pearl_y_pixel, x
				cmp platform_top_pixel
				bcc vertical

					horizontal:
						; Destroy projectile
						lda #PROJECTILE_FLAGS_DEACTIVATED
						sta player_a_projectile_1_flags, x

						; Stop there, we don't care about moving the projectile anymore
						rts

					vertical:
						; Place pearl on platform top
						lda #0
						sta pearl_y_subpixel, x

						lda platform_top_screen
						sta final_y_screen

						;NOTE this decrement may be made useless by not considering the edge pixels in platform_collision_handler
						ldy platform_top_pixel
						dey
						sty final_y_pixel
						cpy #$ff
						bne dec_ok
							dec final_y_screen
						dec_ok:

						; Reset vertical velocity to go upward
						ldy system_index
						lda pearl_v_velocity_table_last, y
						sta pearl_up_counter, x

						; Go forward with moving the projectile
						;jmp ok ; useless, fallthrough
			ok:
			ldx player_number
		.)

		; Move pearl to its final position
		.(
			lda final_y_pixel
			sta pearl_y_pixel, x
			lda final_y_screen
			sta pearl_y_screen, x
			lda final_x_pixel
			sta pearl_x_pixel, x
			lda final_x_screen
			sta pearl_x_screen, x
		.)

		; Set hitbox boundaries
		.(
			jsr place_pearl_hitbox
		.)

		; Place sprite
		.(
			ldy sunny_pearl_sprite_oam_per_player, x

			lda player_a_projectile_1_hitbox_top_msb, x
			bne hide
			lda player_a_projectile_1_hitbox_left_msb, x
			bne hide
				display:
					; Sprite's Y pos is hitbox top -1 to compensate sprites being on the scanline after their position
					lda player_a_projectile_1_hitbox_top, x
					beq hide
						sec
						sbc #1
						sta oam_mirror, y

						iny:iny:iny
						lda player_a_projectile_1_hitbox_left, x
						sta oam_mirror, y
						jmp ok
				hide:
					lda #$fe
					sta oam_mirror, y
			ok:
		.)

		rts

		platform_collision_handler:
		.(
			; Call appropriate handler for this kind of elements
			;stx player_number ; useless, expecting caller to already set it
			tax
			lda platform_specific_handlers_lsb, x
			sta platform_specific_handler_lsb
			lda platform_specific_handlers_msb, x
			sta platform_specific_handler_msb
			ldx player_number
			jmp (platform_specific_handler_lsb)
			; No return, the handler will rts

			;    unused,         PLATFORM,             SMOOTH,             OOS_PLATFORM,  OOS_SMOOTH,  BUMPER
			platform_specific_handlers_lsb:
			.byt <dummy_routine, <one_screen_platform, <one_screen_smooth, <oos_platform, <oos_smooth, <one_screen_platform
			platform_specific_handlers_msb:
			.byt >dummy_routine, >one_screen_platform, >one_screen_smooth, >oos_platform, >oos_smooth, >one_screen_platform

			one_screen_platform:
			.(
				; No collision if projectile is above the platform
				SIGNED_CMP(final_y_pixel, final_y_screen, stage_data+STAGE_PLATFORM_OFFSET_TOP COMMA y, #0)
				bmi no_collision

				; No collision if projectile is under the platform
				SIGNED_CMP(stage_data+STAGE_PLATFORM_OFFSET_BOTTOM COMMA y, #0, final_y_pixel, final_y_screen)
				bmi no_collision

				; No collision if original position is on the left of the platform
				SIGNED_CMP(final_x_pixel, final_x_screen, stage_data+STAGE_PLATFORM_OFFSET_LEFT COMMA y, #0)
				bmi no_collision

				; No collision if final position is on the right of the platform
				SIGNED_CMP(stage_data+STAGE_PLATFORM_OFFSET_RIGHT COMMA y, #0, final_x_pixel, final_x_screen)
				bmi no_collision

					; Collision, stop iterating
					sty collided_platform
					ldy #$ff

				no_collision:
				rts
			.)

			oos_platform:
			.(
				; No collision if projectile is above the platform
				SIGNED_CMP(final_y_pixel, final_y_screen, stage_data+STAGE_OOS_PLATFORM_OFFSET_TOP_LSB COMMA y, stage_data+STAGE_OOS_PLATFORM_OFFSET_TOP_MSB COMMA y)
				bmi no_collision

				; No collision if projectile is under the platform
				SIGNED_CMP(stage_data+STAGE_OOS_PLATFORM_OFFSET_BOTTOM_LSB COMMA y, stage_data+STAGE_OOS_PLATFORM_OFFSET_BOTTOM_MSB COMMA y, final_y_pixel, final_y_screen)
				bmi no_collision

				; No collision if original position is on the left of the platform
				SIGNED_CMP(final_x_pixel, final_x_screen, stage_data+STAGE_OOS_PLATFORM_OFFSET_LEFT_LSB COMMA y, stage_data+STAGE_OOS_PLATFORM_OFFSET_LEFT_MSB COMMA y)
				bmi no_collision

				; No collision if final position is on the right of the platform
				SIGNED_CMP(stage_data+STAGE_OOS_PLATFORM_OFFSET_RIGHT_LSB COMMA y, stage_data+STAGE_OOS_PLATFORM_OFFSET_RIGHT_MSB COMMA y, final_x_pixel, final_x_screen)
				bmi no_collision

					; Collision, stop iterating
					sty collided_platform
					ldy #$ff

				no_collision:
				rts
			.)

			one_screen_smooth:
			.(
				; No collision if projectile is above the platform
				SIGNED_CMP(final_y_pixel, final_y_screen, stage_data+STAGE_PLATFORM_OFFSET_TOP COMMA y, #0)
				bmi no_collision

				; No collision if projectile original position is bellow the platform
				SIGNED_CMP(stage_data+STAGE_PLATFORM_OFFSET_TOP COMMA y, #0, pearl_y_pixel COMMA x, pearl_y_screen COMMA x)
				bmi no_collision

				; No collision if final position is on the left of the platform
				SIGNED_CMP(final_x_pixel, final_x_screen, stage_data+STAGE_PLATFORM_OFFSET_LEFT COMMA y, #0)
				bmi no_collision

				; No collision if final position is on the right of the platform
				SIGNED_CMP(stage_data+STAGE_PLATFORM_OFFSET_RIGHT COMMA y, #0, final_x_pixel, final_x_screen)
				bmi no_collision

					; Collision, stop iterating
					sty collided_platform
					ldy #$ff

				no_collision:
				rts
			.)

			oos_smooth:
			.(
				; No collision if projectile is above the platform
				SIGNED_CMP(final_y_pixel, final_y_screen, stage_data+STAGE_OOS_PLATFORM_OFFSET_TOP_LSB COMMA y, stage_data+STAGE_OOS_PLATFORM_OFFSET_TOP_MSB COMMA y)
				bmi no_collision

				; No collision if projectile original position is bellow the platform
				SIGNED_CMP(stage_data+STAGE_OOS_PLATFORM_OFFSET_TOP_LSB COMMA y, stage_data+STAGE_OOS_PLATFORM_OFFSET_TOP_MSB COMMA y, pearl_y_pixel COMMA x, pearl_y_screen COMMA x)
				bmi no_collision

				; No collision if final position is on the left of the platform
				SIGNED_CMP(final_x_pixel, final_x_screen, stage_data+STAGE_OOS_PLATFORM_OFFSET_LEFT_LSB COMMA y, stage_data+STAGE_OOS_PLATFORM_OFFSET_LEFT_MSB COMMA y)
				bmi no_collision

				; No collision if final position is on the right of the platform
				SIGNED_CMP(stage_data+STAGE_OOS_PLATFORM_OFFSET_RIGHT_LSB COMMA y, stage_data+STAGE_OOS_PLATFORM_OFFSET_RIGHT_MSB COMMA y, final_x_pixel, final_x_screen)
				bmi no_collision

					; Collision, stop iterating
					sty collided_platform
					ldy #$ff

				no_collision:
				rts
			.)
		.)

		load_platform_top:
		.(
			; Call appropriate handler for this kind of elements
			ldy collided_platform

			lda stage_data, y
			tax

			lda platform_specific_handlers_lsb, x
			sta platform_specific_handler_lsb
			lda platform_specific_handlers_msb, x
			sta platform_specific_handler_msb
			jmp (platform_specific_handler_lsb)
			; No return, the handler will rts

			;    unused,         PLATFORM,             SMOOTH,               OOS_PLATFORM,  OOS_SMOOTH,    BUMPER
			platform_specific_handlers_lsb:
			.byt <dummy_routine, <one_screen_platform, <one_screen_platform, <oos_platform, <oos_platform, <one_screen_platform
			platform_specific_handlers_msb:
			.byt >dummy_routine, >one_screen_platform, >one_screen_platform, >oos_platform, >oos_platform, >one_screen_platform

			one_screen_platform:
			.(
				lda #0
				sta platform_top_screen
				lda stage_data+STAGE_PLATFORM_OFFSET_TOP, y
				sta platform_top_pixel
				rts
	 		.)

			oos_platform:
			.(
				lda stage_data+STAGE_OOS_PLATFORM_OFFSET_TOP_MSB, y
				sta platform_top_screen
				lda stage_data+STAGE_OOS_PLATFORM_OFFSET_TOP_LSB, y
				sta platform_top_pixel
				rts
	 		.)
		.)
	.)

	place_pearl_hitbox:
	.(
		lda pearl_y_pixel, x
		clc
		adc #PEARL_PROJECTILE_OFFSET_VERTICAL
		sta player_a_projectile_1_hitbox_top, x
		lda pearl_y_screen, x
		adc #0
		sta player_a_projectile_1_hitbox_top_msb, x

		lda player_a_projectile_1_hitbox_top, x
		clc
		adc #PEARL_PROJECTILE_HEIGHT
		sta player_a_projectile_1_hitbox_bottom, x
		lda player_a_projectile_1_hitbox_top_msb, x
		adc #0
		sta player_a_projectile_1_hitbox_bottom_msb, x

		lda pearl_x_pixel, x
		clc
		adc #PEARL_PROJECTILE_OFFSET_HORIZONTAL
		sta player_a_projectile_1_hitbox_left, x
		lda pearl_x_screen, x
		adc #0
		sta player_a_projectile_1_hitbox_left_msb, x

		lda player_a_projectile_1_hitbox_left, x
		clc
		adc #PEARL_PROJECTILE_WIDTH
		sta player_a_projectile_1_hitbox_right, x
		lda player_a_projectile_1_hitbox_left_msb, x
		adc #0
		sta player_a_projectile_1_hitbox_right_msb, x

		rts
	.)

.)

;
; Implementation
;


sunny_init:
.(
	; Reserve a sprite for the pearl shoot
	.(
		animation_state_vector = tmpfield2

		; Animation's last sprite num = animation's last sprite num - 1
		lda anim_last_sprite_num_per_player_lsb, x
		sta animation_state_vector
		lda anim_last_sprite_num_per_player_msb, x
		sta animation_state_vector+1

		ldy #0
		lda sunny_last_anim_sprite_per_player, x
		sta (animation_state_vector), y

		; Same for out of screen indicator
		lda oos_last_sprite_num_per_player_lsb, x
		sta animation_state_vector
		lda oos_last_sprite_num_per_player_msb, x
		sta animation_state_vector+1

		;ldy #0 ; useless, already set above
		lda sunny_last_anim_sprite_per_player, x
		sta (animation_state_vector), y
	.)

	; Init sprite's OAM
	.(
		ldy sunny_pearl_sprite_oam_per_player, x

		lda #$fe
		sta oam_mirror, y
		iny

		lda pearl_sprite_index_per_player, x
		sta oam_mirror, y
		iny

		lda pearl_sprite_palette_per_player, x
		sta oam_mirror, y
		iny

		lda #0
		sta oam_mirror, y
	.)

	; Reset variables that are ground-dependent
	jmp sunny_global_onground

	;rts ; useless, jump to subroutine

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

	sunny_last_anim_sprite_per_player:
		.byt INGAME_PLAYER_A_LAST_SPRITE-1, INGAME_PLAYER_B_LAST_SPRITE-1

	pearl_sprite_index_per_player:
		.byt CHARACTERS_CHARACTER_A_FIRST_TILE+SUNNY_TILE_PEARL, CHARACTERS_CHARACTER_B_FIRST_TILE+SUNNY_TILE_PEARL

	pearl_sprite_palette_per_player:
		.byt 0, 2
.)

sunny_global_onground:
.(
	; Initialize special jump flags
	lda #SUNNY_ALL_SPECIAL_JUMPS
	sta player_a_special_jumps, x
	rts
.)

; Input table for aerial moves, special values are
;  fast_fall - mandatorily on INPUT_NONE to take effect on release of DOWN
;  jump      - automatically choose between aerial jump or wall jump
;  no_input  - expected default
!input-table-define "SUNNY_AERIAL_INPUTS_TABLE" {
	CONTROLLER_INPUT_NONE               fast_fall
	CONTROLLER_INPUT_SPECIAL_RIGHT      sunny_start_side_special
	CONTROLLER_INPUT_SPECIAL_LEFT       sunny_start_side_special
	CONTROLLER_INPUT_JUMP               jump
	CONTROLLER_INPUT_JUMP_RIGHT         jump
	CONTROLLER_INPUT_JUMP_LEFT          jump
	CONTROLLER_INPUT_ATTACK_LEFT        sunny_start_aerial_side
	CONTROLLER_INPUT_ATTACK_RIGHT       sunny_start_aerial_side
	CONTROLLER_INPUT_DOWN_TILT          sunny_start_aerial_down
	CONTROLLER_INPUT_ATTACK_UP          sunny_start_aerial_up
	CONTROLLER_INPUT_JAB                sunny_start_aerial_neutral
	CONTROLLER_INPUT_SPECIAL            sunny_start_special
	CONTROLLER_INPUT_SPECIAL_UP         sunny_start_spe_up
	CONTROLLER_INPUT_SPECIAL_DOWN       sunny_start_spe_down
	CONTROLLER_INPUT_ATTACK_UP_RIGHT    sunny_start_aerial_up_right
	CONTROLLER_INPUT_ATTACK_UP_LEFT     sunny_start_aerial_up_left
	CONTROLLER_INPUT_SPECIAL_UP_RIGHT   sunny_start_spe_up_right
	CONTROLLER_INPUT_SPECIAL_UP_LEFT    sunny_start_spe_up_left
	CONTROLLER_INPUT_ATTACK_DOWN_RIGHT  sunny_start_aerial_down_right
	CONTROLLER_INPUT_ATTACK_DOWN_LEFT   sunny_start_aerial_down_left
	CONTROLLER_INPUT_SPECIAL_DOWN_RIGHT sunny_start_spe_down_right
	CONTROLLER_INPUT_SPECIAL_DOWN_LEFT  sunny_start_spe_down_left

	no_input
}

; Input table for idle state, special values are
;  no_input - Default
!input-table-define "SUNNY_IDLE_INPUTS_TABLE" {
	CONTROLLER_INPUT_LEFT               sunny_start_running_left
	CONTROLLER_INPUT_RIGHT              sunny_start_running_right
	CONTROLLER_INPUT_JUMP               sunny_start_jumping
	CONTROLLER_INPUT_JUMP_RIGHT         sunny_start_jumping_right
	CONTROLLER_INPUT_JUMP_LEFT          sunny_start_jumping_left
	CONTROLLER_INPUT_JAB                sunny_start_jabbing
	CONTROLLER_INPUT_ATTACK_LEFT        sunny_start_side_tilt_left
	CONTROLLER_INPUT_ATTACK_RIGHT       sunny_start_side_tilt_right
	CONTROLLER_INPUT_SPECIAL            sunny_start_special
	CONTROLLER_INPUT_SPECIAL_RIGHT      sunny_start_side_special_right
	CONTROLLER_INPUT_SPECIAL_LEFT       sunny_start_side_special_left
	CONTROLLER_INPUT_DOWN_TILT          sunny_start_down_tilt
	CONTROLLER_INPUT_SPECIAL_UP         sunny_start_spe_up
	CONTROLLER_INPUT_SPECIAL_DOWN       sunny_start_spe_down
	CONTROLLER_INPUT_ATTACK_UP          sunny_start_up_tilt
	CONTROLLER_INPUT_TECH               sunny_start_shielding
	CONTROLLER_INPUT_TECH_LEFT          sunny_start_shielding_left
	CONTROLLER_INPUT_TECH_RIGHT         sunny_start_shielding_right
	CONTROLLER_INPUT_SPECIAL_UP_LEFT    sunny_start_spe_up_left
	CONTROLLER_INPUT_SPECIAL_UP_RIGHT   sunny_start_spe_up_right
	CONTROLLER_INPUT_ATTACK_UP_LEFT     sunny_start_up_tilt_left
	CONTROLLER_INPUT_ATTACK_UP_RIGHT    sunny_start_up_tilt_right
	CONTROLLER_INPUT_SPECIAL_DOWN_LEFT  sunny_start_spe_down_left
	CONTROLLER_INPUT_SPECIAL_DOWN_RIGHT sunny_start_spe_down_right
	CONTROLLER_INPUT_ATTACK_DOWN_LEFT   sunny_start_down_tilt_left
	CONTROLLER_INPUT_ATTACK_DOWN_RIGHT  sunny_start_down_tilt_right

	no_input
}

; Input table for running state, special values are
;  input_running_left - Change running direction to the left (if not already running to the left)
;  input_runnning_right - Change running direction to the right (if not already running to the right)
!input-table-define "SUNNY_RUNNING_INPUTS_TABLE" {
	CONTROLLER_INPUT_LEFT               input_running_left
	CONTROLLER_INPUT_RIGHT              input_running_right
	CONTROLLER_INPUT_JUMP               sunny_start_jumping
	CONTROLLER_INPUT_JUMP_LEFT          sunny_start_jumping_left
	CONTROLLER_INPUT_JUMP_RIGHT         sunny_start_jumping_right
	CONTROLLER_INPUT_ATTACK_LEFT        sunny_start_side_tilt_left
	CONTROLLER_INPUT_ATTACK_RIGHT       sunny_start_side_tilt_right
	CONTROLLER_INPUT_SPECIAL            sunny_start_special
	CONTROLLER_INPUT_SPECIAL_RIGHT      sunny_start_side_special_right
	CONTROLLER_INPUT_SPECIAL_LEFT       sunny_start_side_special_left
	CONTROLLER_INPUT_SPECIAL_UP         sunny_start_spe_up
	CONTROLLER_INPUT_SPECIAL_DOWN       sunny_start_spe_down
	CONTROLLER_INPUT_TECH_LEFT          sunny_start_shielding_left
	CONTROLLER_INPUT_TECH_RIGHT         sunny_start_shielding_right
	CONTROLLER_INPUT_SPECIAL_UP_LEFT    sunny_start_spe_up_left
	CONTROLLER_INPUT_SPECIAL_UP_RIGHT   sunny_start_spe_up_right
	CONTROLLER_INPUT_ATTACK_UP_LEFT     sunny_start_up_tilt_left
	CONTROLLER_INPUT_ATTACK_UP_RIGHT    sunny_start_up_tilt_right
	CONTROLLER_INPUT_SPECIAL_DOWN_LEFT  sunny_start_spe_down_left
	CONTROLLER_INPUT_SPECIAL_DOWN_RIGHT sunny_start_spe_down_right
	CONTROLLER_INPUT_ATTACK_DOWN_LEFT   sunny_start_down_tilt_left
	CONTROLLER_INPUT_ATTACK_DOWN_RIGHT  sunny_start_down_tilt_right
	CONTROLLER_INPUT_DOWN_TILT          sunny_start_down_tilt

	sunny_start_idle
}

; Input table for jumping state state (only used during jumpsquat), special values are
;  no_input - default
!input-table-define "SUNNY_JUMPSQUAT_INPUTS_TABLE" {
	CONTROLLER_INPUT_ATTACK_UP        sunny_start_up_tilt
	CONTROLLER_INPUT_SPECIAL_UP       sunny_start_spe_up
	CONTROLLER_INPUT_ATTACK_UP_LEFT   sunny_start_up_tilt_left
	CONTROLLER_INPUT_SPECIAL_UP_LEFT  sunny_start_spe_up_left
	CONTROLLER_INPUT_ATTACK_UP_RIGHT  sunny_start_up_tilt_right
	CONTROLLER_INPUT_SPECIAL_UP_RIGHT sunny_start_spe_up_right

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
; Jab
;

!define "anim" {sunny_anim_jab1}
!define "state" {SUNNY_STATE_JABBING_1}
!define "routine" {jabbing}
!define "cutable_duration" {8}
!define "cut_input" {
	; Allow to cut the animation for another jab
	lda controller_a_btns, x
	cmp #CONTROLLER_INPUT_JAB
	beq cut
		rts
	cut:
		jmp sunny_start_jabbing2
		; No return, jump to subroutine
}
!include "characters/tpl_grounded_attack_cutable.asm"

!define "anim" {sunny_anim_jab2}
!define "state" {SUNNY_STATE_JABBING_2}
!define "routine" {jabbing2}
!define "cutable_duration" {8}
!define "cut_input" {
	; Allow to cut the animation for another jab
	lda controller_a_btns, x
	cmp #CONTROLLER_INPUT_JAB
	beq cut
		rts
	cut:
		jmp sunny_start_jabbing3
		; No return, jump to subroutine
}
!include "characters/tpl_grounded_attack_cutable.asm"

!define "anim" {sunny_anim_jab3}
!define "state" {SUNNY_STATE_JABBING_3}
!define "routine" {jabbing3}
!include "characters/tpl_grounded_attack.asm"

;
; Side tilt
;

!define "anim" {sunny_anim_side_tilt}
!define "state" {SUNNY_STATE_SIDE_TILT}
!define "routine" {side_tilt}
!include "characters/tpl_grounded_attack.asm"

;
; Neutral special
;

.(
	!define "anim" {sunny_anim_special}
	!define "state" {SUNNY_STATE_SPECIAL}
	!define "routine" {special}
	!define "followup" {sunny_select_special_endlag}
	!define "tick" {
		lda player_a_grounded, x
		bne ok
			; Not grounded, allow the player to move while shooting
			jsr sunny_aerial_directional_influence
			jmp apply_player_gravity
			;No return, jump to subroutine
		ok:
		rts
	}
	!include "characters/tpl_aerial_attack_uncancellable.asm"

	!define "anim" {sunny_anim_special_endlag}
	!define "state" {SUNNY_STATE_SPECIAL_ENDLAG}
	!define "routine" {special_endlag}
	!include "characters/tpl_grounded_attack.asm"

	!define "anim" {sunny_anim_special_endlag}
	!define "state" {SUNNY_STATE_AERIAL_SPE_ENDLAG}
	!define "routine" {aerial_spe_endlag}
	!include "characters/tpl_aerial_attack.asm"

	sunny_select_special_endlag:
	.(
		; Allow to change Sunny's direction on ground
		.(
			lda player_a_grounded, x
			beq ok
				lda controller_a_btns, x
				and #CONTROLLER_INPUT_LEFT | CONTROLLER_INPUT_RIGHT
				beq ok
					and #CONTROLLER_INPUT_LEFT
					beq right
						left:
							lda #DIRECTION_LEFT2
							jmp apply
						right:
							lda #DIRECTION_RIGHT2
							;jmp apply ; useless, fallthrough
					apply:
						sta player_a_direction, x
				ok:
		.)

		; Shot pearl
		.(
			lda player_a_projectile_1_flags, x
			bne ok
				jsr sunny_pearl_shot_spawn
			ok:
		.)

		; Start endlag
		.(
			lda player_a_grounded, x
			bne grounded
				aerial:
					jmp sunny_start_aerial_spe_endlag
					;rts ; useless, jump to subroutine
				grounded:
					jmp sunny_start_special_endlag
					;rts ; useless, jump to subroutine
			;rts ; useless, no branch return
		.)
	.)
.)

;
; Side special
;

.(
	INITIAL_VELOCITY = $0300
	velocity_table(INITIAL_VELOCITY, initial_velocity_right_msb, initial_velocity_right_lsb)
	velocity_table(-INITIAL_VELOCITY, initial_velocity_left_msb, initial_velocity_left_lsb)

	FRICTION = $08
	acceleration_table(FRICTION, friction_table)

	!define "anim" {sunny_anim_side_special_charge}
	!define "state" {SUNNY_STATE_SIDE_SPECIAL_CHARGE}
	!define "routine" {side_special_charge}
	!define "followup" {sunny_start_side_special_hit}
	!define "init" {
		; No velocity
		lda #0
		sta player_a_velocity_v_low, x
		sta player_a_velocity_v, x
		sta player_a_velocity_h, x
		sta player_a_velocity_h, x
		rts
	}
	!define "tick" {
		; No gravity, and specific air-friction for this move
		lda #0
		sta tmpfield1
		sta tmpfield2
		sta tmpfield3
		sta tmpfield4
		ldy system_index
		lda friction_table, y
		sta tmpfield5
		jmp merge_to_player_velocity
	}
	!include "characters/tpl_grounded_attack_followup.asm"

	!define "anim" {sunny_anim_side_special_hit}
	!define "state" {SUNNY_STATE_SIDE_SPECIAL_HIT}
	!define "routine" {side_special_hit}
	!define "followup" {sunny_start_side_special_end}
	!define "init" {
		; Fixed horizontal velocity
		ldy system_index
		lda player_a_direction, x
		bne right
			left:
				lda initial_velocity_left_msb, y
				sta player_a_velocity_h, x
				lda initial_velocity_left_lsb
				sta player_a_velocity_h_low, x
				rts
			right:
				lda initial_velocity_right_msb, y
				sta player_a_velocity_h, x
				lda initial_velocity_right_lsb
				sta player_a_velocity_h_low, x
				rts
		;rts ; useless, no branch return
	}
	!define "tick" {
		; No gravity, and specific air-friction for this move
		lda #0
		sta tmpfield1
		sta tmpfield2
		sta tmpfield3
		sta tmpfield4
		ldy system_index
		lda friction_table, y
		sta tmpfield5
		jmp merge_to_player_velocity
	}
	!include "characters/tpl_grounded_attack_followup.asm"

	!define "anim" {sunny_anim_side_special_end}
	!define "state" {SUNNY_STATE_SIDE_SPECIAL_END}
	!define "routine" {side_special_end}
	!include "characters/tpl_aerial_attack_uncancellable.asm"

	+sunny_start_side_special = sunny_start_side_special_charge
	+sunny_start_side_special_left = sunny_start_side_special_charge_left
	+sunny_start_side_special_right = sunny_start_side_special_charge_right
.)

;
; Down tilt
;

!define "anim" {sunny_anim_down_tilt}
!define "state" {SUNNY_STATE_DOWN_TILT}
!define "routine" {down_tilt}
!include "characters/tpl_grounded_attack.asm"

;
; Aerial side
;

!define "anim" {sunny_anim_aerial_side}
!define "state" {SUNNY_STATE_AERIAL_SIDE}
!define "routine" {aerial_side}
!include "characters/tpl_aerial_attack.asm"

;
; Aerial down
;
; NOTE we are using two "spin" states while one state with
;      extended duration to 2*animation-duration would do the same.
;      A bit wasteful, but would need to allow custom duration in
;      tpl_aerial_attack to fix.
;

!define "anim" {sunny_anim_aerial_down}
!define "state" {SUNNY_STATE_AERIAL_DOWN}
!define "routine" {aerial_down}
!define "followup" {sunny_start_aerial_down_spin}
!define "init" {
	lda #0
	sta player_a_velocity_v_low, x
	sta player_a_velocity_v, x
	rts
}
!include "characters/tpl_aerial_attack.asm"

!define "anim" {sunny_anim_aerial_down_spin}
!define "state" {SUNNY_STATE_AERIAL_DOWN_SPIN}
!define "routine" {aerial_down_spin}
!define "followup" {sunny_start_aerial_down_spin2}
!include "characters/tpl_aerial_attack.asm"

!define "anim" {sunny_anim_aerial_down_spin}
!define "state" {SUNNY_STATE_AERIAL_DOWN_SPIN2}
!define "routine" {aerial_down_spin2}
!define "followup" {sunny_aerial_down_select_end}
!include "characters/tpl_aerial_attack.asm"

!define "anim" {sunny_anim_aerial_down_end}
!define "state" {SUNNY_STATE_AERIAL_DOWN_END}
!define "routine" {aerial_down_end}
!define "followup" {sunny_start_helpless}
!include "characters/tpl_aerial_attack.asm"

!define "anim" {sunny_anim_aerial_down_stomp}
!define "state" {SUNNY_STATE_AERIAL_DOWN_STOMP}
!define "routine" {aerial_down_stomp}
!include "characters/tpl_grounded_attack.asm"

.(
	VELOCITY_BOOST = -$0300
	velocity_table(VELOCITY_BOOST, velocity_boost_msb, velocity_boost_lsb)

	+sunny_input_aerial_down_spin:
	.(
		lda controller_a_btns, x
		and #(CONTROLLER_BTN_DOWN | CONTROLLER_BTN_LEFT | CONTROLLER_BTN_RIGHT)^$ff
		cmp #CONTROLLER_INPUT_JAB
		bne end
			ldy system_index
			lda velocity_boost_lsb, y
			sta player_a_velocity_v_low, x
			lda velocity_boost_msb, y
			sta player_a_velocity_v, x
		end:
		rts
	.)

	&sunny_aerial_down_select_end:
	.(
		lda player_a_grounded, x
		bne grounded_end
			aerial_end:
				jmp sunny_start_aerial_down_end
			grounded_end:
				jmp sunny_start_aerial_down_stomp
		;rts ; useless, jump to subroutine
	.)
.)

;
; Aerial up
;

!define "anim" {sunny_anim_aerial_up}
!define "state" {SUNNY_STATE_AERIAL_UP}
!define "routine" {aerial_up}
!define "cutable_duration" {12}
!include "characters/tpl_aerial_attack_cutable.asm"

;
; Aerial neutral
;

!define "anim" {sunny_anim_aerial_neutral}
!define "state" {SUNNY_STATE_AERIAL_NEUTRAL}
!define "routine" {aerial_neutral}
!include "characters/tpl_aerial_attack.asm"

;
; Special up
;

.(
	;TODO moves here use tpl_aerial_attack, but may be better using tpl_aerial_attack_uncancellable
	;     Need to adapt uncancellable API to match features in tpl_aerial_attack if so.

	SPE_UP_POWER = $0500
	velocity_table(-SPE_UP_POWER, spe_up_power_msb, spe_up_power_lsb)

	!define "anim" {sunny_anim_spe_up_prepare}
	!define "state" {SUNNY_STATE_SPE_UP_PREPARE}
	!define "routine" {spe_up}
	!define "followup" {sunny_start_spe_up_jump}
	!define "init" {
		; Set initial velocity
		lda #$00
		sta player_a_velocity_h_low, x
		sta player_a_velocity_h, x
		sta player_a_velocity_v_low, x
		sta player_a_velocity_v, x

		; Reset fall speed
		jmp reset_default_gravity
		;rts ; useless, jump to subroutine
	}
	!include "characters/tpl_aerial_attack.asm"

	!define "anim" {sunny_anim_spe_up_jump}
	!define "state" {SUNNY_STATE_SPE_UP_JUMP}
	!define "routine" {spe_up_jump}
	!define "followup" {sunny_start_helpless}
	!define "init" {
		; Set jumping velocity
		ldy system_index
		lda spe_up_power_msb, y
		sta player_a_velocity_v, x
		lda spe_up_power_lsb, y
		sta player_a_velocity_v_low, x

		rts
	}
	!include "characters/tpl_aerial_attack.asm"
.)

;
; Special down
;

!define "anim" {sunny_anim_spe_down_charge}
!define "state" {SUNNY_STATE_SPE_DOWN_CHARGE}
!define "routine" {spe_down}
!define "followup" {sunny_start_spe_down_hit}
!include "characters/tpl_aerial_attack_uncancellable.asm"

!define "anim" {sunny_anim_spe_down_hit}
!define "state" {SUNNY_STATE_SPE_DOWN_HIT}
!define "routine" {spe_down_hit}
!include "characters/tpl_aerial_attack_uncancellable.asm"

;
; Up tilt
;

!define "anim" {sunny_anim_up_tilt}
!define "state" {SUNNY_STATE_UP_TILT}
!define "routine" {up_tilt}
!define "cutable_duration" {20}
!define "cut_input" {
	lda controller_a_btns, x
	cmp #CONTROLLER_INPUT_JUMP
	beq cut
	cmp #CONTROLLER_INPUT_JUMP_LEFT
	beq cut
	cmp #CONTROLLER_INPUT_JUMP_RIGHT
	beq cut
		rts
	cut:
		jmp sunny_start_jumping
}
!include "characters/tpl_grounded_attack_cutable.asm"

!include "characters/std_friction_routines.asm"

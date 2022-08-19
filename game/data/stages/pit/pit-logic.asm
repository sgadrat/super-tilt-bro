STAGE_PIT_MOVING_PLATFORM_1_OFFSET = STAGE_ELEMENT_SIZE * 2
STAGE_PIT_MOVING_PLATFORM_2_OFFSET = STAGE_PIT_MOVING_PLATFORM_1_OFFSET + STAGE_ELEMENT_SIZE

#define STAGE_PIT_MOVING_PLATFORM_SPRITES $20
#define STAGE_PIT_NB_MOVING_PLATFORM_SPRITES 8

#define STAGE_PIT_PLATFORM_MAX_HEIGHT 88
#define STAGE_PIT_PLATFORM_MIN_HEIGHT 162
#define STAGE_PIT_PLATFORM_LEFTMOST 73
#define STAGE_PIT_PLATFORM_RIGHTMOST 137

+stage_pit_netload:
.(
	lda esp_rx_buffer+0, x
	sta stage_pit_platform1_direction_v
	lda esp_rx_buffer+1, x
	sta stage_pit_platform2_direction_v
	lda esp_rx_buffer+2, x
	sta stage_pit_platform1_direction_h
	lda esp_rx_buffer+3, x
	sta stage_pit_platform2_direction_h

	lda esp_rx_buffer+4, x
	sta stage_data+STAGE_OFFSET_ELEMENTS+STAGE_PIT_MOVING_PLATFORM_1_OFFSET+STAGE_PLATFORM_OFFSET_TOP
	lda esp_rx_buffer+5, x
	sta stage_data+STAGE_OFFSET_ELEMENTS+STAGE_PIT_MOVING_PLATFORM_1_OFFSET+STAGE_PLATFORM_OFFSET_LEFT
	clc
	adc #38
	sta stage_data+STAGE_OFFSET_ELEMENTS+STAGE_PIT_MOVING_PLATFORM_1_OFFSET+STAGE_PLATFORM_OFFSET_RIGHT

	lda esp_rx_buffer+6, x
	sta stage_data+STAGE_OFFSET_ELEMENTS+STAGE_PIT_MOVING_PLATFORM_2_OFFSET+STAGE_PLATFORM_OFFSET_TOP
	lda esp_rx_buffer+7, x
	sta stage_data+STAGE_OFFSET_ELEMENTS+STAGE_PIT_MOVING_PLATFORM_2_OFFSET+STAGE_PLATFORM_OFFSET_LEFT
	;clc ; useless, last ADC should not overflow (platforms stay on screen)
	adc #38
	sta stage_data+STAGE_OFFSET_ELEMENTS+STAGE_PIT_MOVING_PLATFORM_2_OFFSET+STAGE_PLATFORM_OFFSET_RIGHT

	rts
.)

+stage_pit_fadeout:
.(
	header = tmpfield1 ; construct_nt_buffer parameter
	payload = tmpfield3 ; construct_nt_buffer parameter

	lda #<palette_header
	sta header
	lda #>palette_header
	sta header+1

	lda stage_pit_fadeout_lsb, x
	sta payload
	lda stage_pit_fadeout_msb, x
	sta payload+1

	jmp construct_nt_buffer

	;rts ; useless, jump to subroutine

	palette_header:
	.byt $3f, $00, $10
.)

+stage_pit_init:
.(
	; Disable screen restore
	lda #$ff
	sta stage_restore_screen_step

	; Set stage's state
	lda #$ff
	sta stage_pit_platform1_direction_v
	lda #$01
	sta stage_pit_platform2_direction_v
	lda #0
	sta stage_pit_platform1_direction_h
	sta stage_pit_platform2_direction_h

	; Init moving platform sprites
	lda #TILE_MOVING_PLATFORM                                ;
	sta oam_mirror+STAGE_PIT_MOVING_PLATFORM_SPRITES*4+1     ;
	sta oam_mirror+(STAGE_PIT_MOVING_PLATFORM_SPRITES+1)*4+1 ; Tile number
	sta oam_mirror+(STAGE_PIT_MOVING_PLATFORM_SPRITES+2)*4+1 ;
	sta oam_mirror+(STAGE_PIT_MOVING_PLATFORM_SPRITES+3)*4+1 ;
	sta oam_mirror+(STAGE_PIT_MOVING_PLATFORM_SPRITES+4)*4+1 ;
	sta oam_mirror+(STAGE_PIT_MOVING_PLATFORM_SPRITES+5)*4+1 ;
	sta oam_mirror+(STAGE_PIT_MOVING_PLATFORM_SPRITES+6)*4+1 ;
	sta oam_mirror+(STAGE_PIT_MOVING_PLATFORM_SPRITES+7)*4+1 ;

	lda #%00000011                                           ;
	sta oam_mirror+STAGE_PIT_MOVING_PLATFORM_SPRITES*4+2     ;
	sta oam_mirror+(STAGE_PIT_MOVING_PLATFORM_SPRITES+1)*4+2 ;
	sta oam_mirror+(STAGE_PIT_MOVING_PLATFORM_SPRITES+2)*4+2 ; Attributes
	sta oam_mirror+(STAGE_PIT_MOVING_PLATFORM_SPRITES+3)*4+2 ;
	sta oam_mirror+(STAGE_PIT_MOVING_PLATFORM_SPRITES+4)*4+2 ;
	sta oam_mirror+(STAGE_PIT_MOVING_PLATFORM_SPRITES+5)*4+2 ;
	sta oam_mirror+(STAGE_PIT_MOVING_PLATFORM_SPRITES+6)*4+2 ;
	sta oam_mirror+(STAGE_PIT_MOVING_PLATFORM_SPRITES+7)*4+2 ;

	; Place moving platform sprites
	; Fallthrough stage_pit_place_platform_sprites
.)

stage_pit_place_platform_sprites:
.(
	; Avoid placing sprites in rollback mode
	lda network_rollback_mode
	beq do_it
		rts
	do_it:

	; Y positions
	lda stage_data+STAGE_OFFSET_ELEMENTS+STAGE_PIT_MOVING_PLATFORM_1_OFFSET+STAGE_PLATFORM_OFFSET_TOP
	clc
	adc #15
	sta oam_mirror+STAGE_PIT_MOVING_PLATFORM_SPRITES*4
	sta oam_mirror+(STAGE_PIT_MOVING_PLATFORM_SPRITES+1)*4
	sta oam_mirror+(STAGE_PIT_MOVING_PLATFORM_SPRITES+2)*4
	sta oam_mirror+(STAGE_PIT_MOVING_PLATFORM_SPRITES+3)*4
	lda stage_data+STAGE_OFFSET_ELEMENTS+STAGE_PIT_MOVING_PLATFORM_2_OFFSET+STAGE_PLATFORM_OFFSET_TOP
	clc
	adc #15
	sta oam_mirror+(STAGE_PIT_MOVING_PLATFORM_SPRITES+4)*4
	sta oam_mirror+(STAGE_PIT_MOVING_PLATFORM_SPRITES+5)*4
	sta oam_mirror+(STAGE_PIT_MOVING_PLATFORM_SPRITES+6)*4
	sta oam_mirror+(STAGE_PIT_MOVING_PLATFORM_SPRITES+7)*4

	; X positions
	lda stage_data+STAGE_OFFSET_ELEMENTS+STAGE_PIT_MOVING_PLATFORM_1_OFFSET+STAGE_PLATFORM_OFFSET_LEFT
	clc
	adc #7
	sta oam_mirror+STAGE_PIT_MOVING_PLATFORM_SPRITES*4+3
	adc #8
	sta oam_mirror+(STAGE_PIT_MOVING_PLATFORM_SPRITES+1)*4+3
	adc #8
	sta oam_mirror+(STAGE_PIT_MOVING_PLATFORM_SPRITES+2)*4+3
	adc #8
	sta oam_mirror+(STAGE_PIT_MOVING_PLATFORM_SPRITES+3)*4+3
	lda stage_data+STAGE_OFFSET_ELEMENTS+STAGE_PIT_MOVING_PLATFORM_2_OFFSET+STAGE_PLATFORM_OFFSET_LEFT
	adc #7
	sta oam_mirror+(STAGE_PIT_MOVING_PLATFORM_SPRITES+4)*4+3
	adc #8
	sta oam_mirror+(STAGE_PIT_MOVING_PLATFORM_SPRITES+5)*4+3
	adc #8
	sta oam_mirror+(STAGE_PIT_MOVING_PLATFORM_SPRITES+6)*4+3
	adc #8
	sta oam_mirror+(STAGE_PIT_MOVING_PLATFORM_SPRITES+7)*4+3

	rts
.)

stage_pit_restore_screen:
.(
	; Do nothing when rollbacking - optimizable, could be checked by caller (already done on one call)
	.(
		lda network_rollback_mode
		beq ok
			rts
		ok:
	.)

	; Do noting if there is no restore operation running - optimizable, could have X loaded by caller (one call already checks for bpl)
	.(
		ldx stage_restore_screen_step
		bpl ok
			rts
		ok:
	.)

	; Write NT buffer corresponding to current step
	.(
		;ldx stage_restore_screen_step ; useless, done above
		lda steps_buffers_lsb, x
		ldy steps_buffers_msb, x
		jsr push_nt_buffer
	.)

	; Increment step
	.(
		inc stage_restore_screen_step
		lda stage_restore_screen_step
		cmp #NUM_RESTORE_STEPS
		bne ok
			lda #$ff
			sta stage_restore_screen_step
		ok:
	.)

	rts

	top_attributes:
	.byt $23, $c0, $20
	.byt %01010101, %01010101, %01010101, %01010101, %01010101, %01010101, %01010101, %01010101
	.byt %01010101, %01010101, %10010101, %01010101, %01010101, %01010101, %01011001, %01010101
	.byt %01010101, %01010101, %01010101, %01010101, %01010101, %01100101, %01010101, %01010101
	.byt %01100101, %01010101, %01010101, %01010101, %01010101, %01010101, %10010101, %01010101
	bot_attibutes:
	.byt $23, $e0, $20
	.byt %00000110, %00000000, %01000000, %01000000, %01010000, %00000001, %00000100, %00000000
	.byt %00000000, %00000000, %00000000, %00000101, %00000101, %00000000, %00000000, %00000000
	.byt %00000000, %00000000, %00000000, %01000000, %00000000, %00000000, %00000000, %00000000
	.byt %00000000, %00000000, %00000000, %00000000, %00000000, %00000000, %00000000, %00000000

	steps_buffers_lsb:
	.byt <stage_pit_palette_ntbuffer, <top_attributes, <bot_attibutes
	steps_buffers_msb:
	.byt >stage_pit_palette_ntbuffer, >top_attributes, >bot_attibutes
	NUM_RESTORE_STEPS = *-steps_buffers_msb
.)

+stage_pit_tick:
.(
	; Update background
	jsr stage_pit_restore_screen

	; Move platforms
	.(
		; Change platforms direction
		ldy #0 ; Y = platform index
		ldx #0 ; X = platform offset in stage data from first moving platform
		change_one_platform_direction:

			jsr apply_platform_waypoint

			ldx #STAGE_ELEMENT_SIZE
			iny
			cpy #2
			bne change_one_platform_direction

		; Move platforms and players on it
		ldx #0
		ldy #0
		lda stage_pit_platform1_direction_v
		sta tmpfield4
		lda stage_pit_platform1_direction_h
		sta tmpfield5

		check_one_player_one_platform:

			; Move players that are on platforms
			move_players_on_platform:
				tya
				clc
				adc #STAGE_OFFSET_ELEMENTS+STAGE_PIT_MOVING_PLATFORM_1_OFFSET
				cmp player_a_grounded, x
				bne next_check

					lda player_a_y, x
					clc
					adc tmpfield4
					sta player_a_y, x
					lda player_a_x, x
					clc
					adc tmpfield5
					sta player_a_x, x

				next_check:
				inx
				cpx #2
				bne move_players_on_platform

			; Move platform in stage's data
			lda stage_data+STAGE_OFFSET_ELEMENTS+STAGE_PIT_MOVING_PLATFORM_1_OFFSET+STAGE_PLATFORM_OFFSET_TOP, y
			clc
			adc tmpfield4
			sta stage_data+STAGE_OFFSET_ELEMENTS+STAGE_PIT_MOVING_PLATFORM_1_OFFSET+STAGE_PLATFORM_OFFSET_TOP, y
			lda stage_data+STAGE_OFFSET_ELEMENTS+STAGE_PIT_MOVING_PLATFORM_1_OFFSET+STAGE_PLATFORM_OFFSET_LEFT, y
			clc
			adc tmpfield5
			sta stage_data+STAGE_OFFSET_ELEMENTS+STAGE_PIT_MOVING_PLATFORM_1_OFFSET+STAGE_PLATFORM_OFFSET_LEFT, y
			lda stage_data+STAGE_OFFSET_ELEMENTS+STAGE_PIT_MOVING_PLATFORM_1_OFFSET+STAGE_PLATFORM_OFFSET_RIGHT, y
			clc
			adc tmpfield5
			sta stage_data+STAGE_OFFSET_ELEMENTS+STAGE_PIT_MOVING_PLATFORM_1_OFFSET+STAGE_PLATFORM_OFFSET_RIGHT, y

			; Prepare next platform
			cpy #STAGE_ELEMENT_SIZE
			beq end_move_platforms
			ldy #STAGE_ELEMENT_SIZE
			ldx #0
			lda stage_pit_platform2_direction_v
			sta tmpfield4
			lda stage_pit_platform2_direction_h
			sta tmpfield5
			jmp check_one_player_one_platform

		end_move_platforms:

		; Move platform sprites
		jmp stage_pit_place_platform_sprites

		;rts ; useless, jump to a subroutine
	.)

	; Modify platform's direction if on a waypoint
	;  register Y - Platform index
	;  register X - Platform offset in stage data from first moving platform
	;
	;  Overwrites tmpfield1 and tmpfield2
	apply_platform_waypoint:
	.(
		platform_index = tmpfield1
		new_direction_v = tmpfield2

		; Save platform index
		sty platform_index

		; Check if on a waypoint
		ldy #0 ; Y is the current waypoint index
		check_one_wp:
		lda waypoints_v, y
		cmp stage_data+STAGE_OFFSET_ELEMENTS+STAGE_PIT_MOVING_PLATFORM_1_OFFSET+STAGE_PLATFORM_OFFSET_TOP, x
		bne next_wp
		lda waypoints_h, y
		cmp stage_data+STAGE_OFFSET_ELEMENTS+STAGE_PIT_MOVING_PLATFORM_1_OFFSET+STAGE_PLATFORM_OFFSET_LEFT, x
		beq change_direction

		next_wp:
		iny
		cpy #4
		bne check_one_wp
		jmp end

		; Apply waypoint's direction to the platform
		change_direction:
		lda waypoints_direction_v, y
		sta new_direction_v
		lda waypoints_direction_h, y
		ldy platform_index
		sta stage_pit_platform1_direction_h, y
		lda new_direction_v
		sta stage_pit_platform1_direction_v, y

		; Restore register Y and return
		end:
		ldy platform_index
		rts
	.)

	waypoints_v:
	.byt STAGE_PIT_PLATFORM_MAX_HEIGHT, STAGE_PIT_PLATFORM_MAX_HEIGHT, STAGE_PIT_PLATFORM_MIN_HEIGHT, STAGE_PIT_PLATFORM_MIN_HEIGHT

	waypoints_h:
	.byt STAGE_PIT_PLATFORM_LEFTMOST,   STAGE_PIT_PLATFORM_RIGHTMOST,  STAGE_PIT_PLATFORM_RIGHTMOST,  STAGE_PIT_PLATFORM_LEFTMOST

	waypoints_direction_v:
	.byt $00, $01, $00, $ff

	waypoints_direction_h:
	.byt $01, $00, $ff, $00
.)

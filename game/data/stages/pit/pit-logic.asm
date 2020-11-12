STAGE_PIT_MOVING_PLATFORM_1_OFFSET=18
STAGE_PIT_MOVING_PLATFORM_2_OFFSET=22

#define STAGE_PIT_MOVING_PLATFORM_SPRITES $20
#define STAGE_PIT_NB_MOVING_PLATFORM_SPRITES 8


#define STAGE_PIT_PLATFORM_MAX_HEIGHT 88
#define STAGE_PIT_PLATFORM_MIN_HEIGHT 162
#define STAGE_PIT_PLATFORM_LEFTMOST 73
#define STAGE_PIT_PLATFORM_RIGHTMOST 137

stage_pit_init:
.(
	; Generic initialization stuff
	jsr stage_generic_init

	; Set stage's state
	lda #$ff
	sta stage_pit_platform1_direction_v
	lda #$01
	sta stage_pit_platform2_direction_v
	lda #0
	sta stage_pit_platform1_direction_h
	sta stage_pit_platform2_direction_h

	; Place moving platform sprites
	lda stage_data+STAGE_OFFSET_ELEMENTS+STAGE_PIT_MOVING_PLATFORM_1_OFFSET+STAGE_PLATFORM_OFFSET_TOP  ;
	clc
	adc #15
	sta oam_mirror+STAGE_PIT_MOVING_PLATFORM_SPRITES*4                                                 ;
	sta oam_mirror+(STAGE_PIT_MOVING_PLATFORM_SPRITES+1)*4                                             ; Y positions
	sta oam_mirror+(STAGE_PIT_MOVING_PLATFORM_SPRITES+2)*4                                             ;
	sta oam_mirror+(STAGE_PIT_MOVING_PLATFORM_SPRITES+3)*4                                             ;
	lda stage_data+STAGE_OFFSET_ELEMENTS+STAGE_PIT_MOVING_PLATFORM_2_OFFSET+STAGE_PLATFORM_OFFSET_TOP  ;
	clc
	adc #15
	sta oam_mirror+(STAGE_PIT_MOVING_PLATFORM_SPRITES+4)*4                                             ;
	sta oam_mirror+(STAGE_PIT_MOVING_PLATFORM_SPRITES+5)*4                                             ;
	sta oam_mirror+(STAGE_PIT_MOVING_PLATFORM_SPRITES+6)*4                                             ;
	sta oam_mirror+(STAGE_PIT_MOVING_PLATFORM_SPRITES+7)*4                                             ;

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

	lda stage_data+STAGE_OFFSET_ELEMENTS+STAGE_PIT_MOVING_PLATFORM_1_OFFSET+STAGE_PLATFORM_OFFSET_LEFT  ;
	clc
	adc #7
	sta oam_mirror+STAGE_PIT_MOVING_PLATFORM_SPRITES*4+3                                                ;
	adc #8
	sta oam_mirror+(STAGE_PIT_MOVING_PLATFORM_SPRITES+1)*4+3                                            ;
	adc #8
	sta oam_mirror+(STAGE_PIT_MOVING_PLATFORM_SPRITES+2)*4+3                                            ; X positions
	adc #8
	sta oam_mirror+(STAGE_PIT_MOVING_PLATFORM_SPRITES+3)*4+3                                            ;
	lda stage_data+STAGE_OFFSET_ELEMENTS+STAGE_PIT_MOVING_PLATFORM_2_OFFSET+STAGE_PLATFORM_OFFSET_LEFT  ;
	adc #7
	sta oam_mirror+(STAGE_PIT_MOVING_PLATFORM_SPRITES+4)*4+3                                            ;
	adc #8
	sta oam_mirror+(STAGE_PIT_MOVING_PLATFORM_SPRITES+5)*4+3                                            ;
	adc #8
	sta oam_mirror+(STAGE_PIT_MOVING_PLATFORM_SPRITES+6)*4+3                                            ;
	adc #8
	sta oam_mirror+(STAGE_PIT_MOVING_PLATFORM_SPRITES+7)*4+3                                            ;

	rts
.)

stage_pit_tick:
.(
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
			;  Note - Player's subpixel is not accounted,
			;         we prefer to move a player that is not really grounded
			;         than moving the platform through him
			move_players_on_platform:
				lda stage_data+STAGE_OFFSET_ELEMENTS+STAGE_PIT_MOVING_PLATFORM_1_OFFSET+STAGE_PLATFORM_OFFSET_LEFT, y
				sta tmpfield1
				lda stage_data+STAGE_OFFSET_ELEMENTS+STAGE_PIT_MOVING_PLATFORM_1_OFFSET+STAGE_PLATFORM_OFFSET_RIGHT, y
				sta tmpfield2
				lda stage_data+STAGE_OFFSET_ELEMENTS+STAGE_PIT_MOVING_PLATFORM_1_OFFSET+STAGE_PLATFORM_OFFSET_TOP, y
				sta tmpfield3
				lda player_a_y_low, x
				pha
				lda #$ff
				sta player_a_y_low, x
				jsr check_on_platform
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
				pla
				sta player_a_y_low, x
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

		; Move first platforms' sprites
		ldx #0 ; X = sprite's offset from first platform's first sprite
		ldy #0 ; Y = platform index
		move_one_sprite:

			cpx #STAGE_PIT_NB_MOVING_PLATFORM_SPRITES*4/2 ;
			bne end_platform_change                       ; Check if we just changed platform
			iny                                           ;
			end_platform_change:                          ;

			lda oam_mirror+STAGE_PIT_MOVING_PLATFORM_SPRITES*4, x   ;
			clc                                                     ;
			adc stage_pit_platform1_direction_v, y                  ;
			sta oam_mirror+STAGE_PIT_MOVING_PLATFORM_SPRITES*4, x   ; Apply movement to the sprite
			lda oam_mirror+STAGE_PIT_MOVING_PLATFORM_SPRITES*4+3, x ;
			clc                                                     ;
			adc stage_pit_platform1_direction_h, y                  ;
			sta oam_mirror+STAGE_PIT_MOVING_PLATFORM_SPRITES*4+3, x ;

			inx ;
			inx ; Point to the next sprite
			inx ;
			inx ;

			cpx #STAGE_PIT_NB_MOVING_PLATFORM_SPRITES*4 ; Loop on all platforms' sprites
			bne move_one_sprite                         ;

		end:
		rts
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

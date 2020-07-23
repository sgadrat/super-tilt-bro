state_transition_pre_scroll_down:
.(
	; Call the scrolling routine
	lda #0
	sta tmpfield3
	sta tmpfield4
	lda #<camera_steps
	sta extra_tmpfield1
	lda #>camera_steps
	sta extra_tmpfield2
	lda #1
	jsr scroll_transition

	; No need to adjust the stop position
	; we expect rendering to be disabled soon after we return

	rts

	camera_steps:
	.byt 10, 20, 40, 60, 100, 140, 180, 220, 240, $ff
.)

state_transition_pre_scroll_up:
.(
	; Call the scrolling routine
	lda #0
	sta tmpfield3
	sta tmpfield4
	lda #<camera_steps
	sta extra_tmpfield1
	lda #>camera_steps
	sta extra_tmpfield2
	lda #2
	jsr scroll_transition

	; No need to adjust the stop position
	; we expect rendering to be disabled soon after we return

	rts

	camera_steps:
	.byt 230, 220, 200, 180, 140, 100, 60, 20, 0, $ff
.)

state_transition_post_scroll_down:
.(
	; Call the scrolling routine
	lda #2
	sta tmpfield3
	lda #1
	sta tmpfield4
	lda #<camera_steps
	sta extra_tmpfield1
	lda #>camera_steps
	sta extra_tmpfield2
	lda #1
	jsr scroll_transition

	; Adjust stop position to scroll_y=0 of top nametable
	;   scrolling stops on scroll_y=239 of bottom nametable
	;   (with sprites being already accurately placed since their transition handle pixel number 240)
	lda #%10010000 ; NMI enabled, background pattern table at $1000, base nametable is top left
	sta ppuctrl_val
	lda #0
	sta scroll_y

	rts

	camera_steps:
	.byt 40, 80, 120, 160, 200, 240, 235, 239, 230, 239, 237, 235, 240, $ff
.)

state_transition_post_scroll_up:
.(
	; Call the scrolling routine
	lda #2
	sta tmpfield3
	lda #1
	sta tmpfield4
	lda #<camera_steps
	sta extra_tmpfield1
	lda #>camera_steps
	sta extra_tmpfield2
	lda #2
	jsr scroll_transition

	; No need to adjust stop scroll
	; transition already stops on scroll_y=0 of top nametable

	rts

	camera_steps:
	.byt 200, 160, 140, 120, 106, 93, 80, 67, 54, 41, 28, 15, 0, $ff
.)

; Transition by scrolling between two screen, keeping menus clouds
;  tmpfield3 - origin screen 0 for top nametable, 2 for bottom one
;  tmpfield4 - sprites are from starting or destination screen (0 - starting screen ; 1 - destination screen)
;  register A - transition direction (1 - down ; 2 - up)
scroll_transition:
.(
	STACK_FRAME_CNT_OFFSET = 0
	STACK_SCROLL_BEGIN_OFFSET = 3
	STACK_CLOUD_SCROLL_MSB_OFFSET = 4
	STACK_CLOUD_SCROLL_LSB_OFFSET = 5

	camera_steps_addr = extra_tmpfield1
	; extra_tmpfield2 reserved for camera_steps_addr MSB

	.(
		screen_sprites_offset_lsb = tmpfield1
		screen_sprites_offset_msb = tmpfield2
		origin_nametable = tmpfield3
		offset_sprites = tmpfield4

		; Compute values dependent of the direction
		cmp #1
		bne set_up_values

			lda origin_nametable ;
			ora #%10010000       ; Reactivate NMI, place scrolling on origin nametable
			sta ppuctrl_val      ;
			lda #240
			sta screen_sprites_offset_lsb
			lda #0
			sta screen_sprites_offset_msb
			lda #$fa
			pha      ; cloud_scroll_lsb
			lda #$ff
			pha      ; cloud_scroll_msb
			lda #0
			pha      ; scroll_begin
			jmp end_set_values

		set_up_values:
			lda origin_nametable ;
			eor #%00000010       ; Reactivate NMI, place scrolling on destination nametable
			ora #%10010000       ;
			sta ppuctrl_val      ;
			lda #$10
			sta screen_sprites_offset_lsb
			lda #$ff
			sta screen_sprites_offset_msb
			lda #$6
			pha      ; cloud_scroll_lsb
			lda #$0
			pha      ; cloud_scroll_msb
			lda #240
			pha      ; scroll_begin
			;jmp end_set_values ; useless - fallthrough

		end_set_values:

		; Avoid to offset sprites when starting from drawn screen
		lda offset_sprites
		bne do_not_touch_offsets
		lda #0
		sta screen_sprites_offset_lsb
		sta screen_sprites_offset_msb
		do_not_touch_offsets:

		; Save sprites y positions as 2 bytes values (to be able to go offscreen)
		ldx #0 ; OAM offset
		ldy #0 ; Sprite index
		save_one_sprite:

			; Store sprite's two bytes y position
			lda oam_mirror, x
			cmp #240
			bcs hidden_sprite

				; Visible sprite, place it at "Y + sprites offset"
				clc
				adc screen_sprites_offset_lsb
				sta screen_sprites_y_lsb, y
				lda screen_sprites_offset_msb
				adc #0
				sta screen_sprites_y_msb, y
				jmp two_byte_position_stored

			hidden_sprite:

				; This sprite was not visible, place it far from visible screen
				lda #$80
				sta screen_sprites_y_msb, y
				; Note - we don't care about LSB, we will scroll only one screen while $80xx is 128 screens away

			two_byte_position_stored:

			; Hide sprite
			; even cloud sprites, they already blink due to disabling rendering anyway
			lda #$fe
			sta oam_mirror, x

			; Next sprite
			iny
			inx
			inx
			inx
			inx
			bne save_one_sprite

		ldy #0
		scroll_frame:
			; Scroll camera according to camera_steps table
			lda (camera_steps_addr), y
			cmp #$ff
			beq clean
			cmp #240
			bne set_camera_scroll
				lda #239
			set_camera_scroll:
			sta scroll_y

			; Save parts of state in registers and tmpfields
			lda camera_steps_addr
			pha
			lda camera_steps_addr+1
			pha

			tya
			pha

			; Update sprites position
			jsr move_sprites

			; Sleep, and enable rendering if necessary
			pla
			pha
			bne simple_sleep

				; First frame, re-enable rendering
				lda ppuctrl_val
				sta PPUCTRL

				jsr sleep_frame  ; Avoid re-enabling mid-frame

				lda #%00011110 ; Enable sprites and background rendering
				sta PPUMASK    ;

				jmp end_sleep ; Skip sleeping as we already done it

			simple_sleep:

				; Just sleep, nothing fancy
				jsr sleep_frame

			end_sleep:

			; Restore saved state
			pla
			tay

			pla
			sta camera_steps_addr+1
			pla
			sta camera_steps_addr

			; Loop
			iny
			jmp scroll_frame

		clean:
		pla ; scroll_begin
		pla ; cloud_scroll_msb
		pla ; cloud_scroll_lsb

		end:
		rts
	.)

	; Scroll sprites
	;  stack+3+STACK_FRAME_CNT_OFFSET - frame number
	;  stack+3+STACK_CLOUD_SCROLL_LSB_OFFSET - clouds scroll step LSB
	;  stack+3+STACK_CLOUD_SCROLL_MSB_OFFSET - clouds scroll step MSB
	;  stack+3+STACK_SCROLL_BEGIN_OFFSET - initial position of the screen
	;  extra_tmpfield1, extra_tmpfield2 - camera_steps table address
	;
	; Overwrites all registers, tmpfield1, extra_tmpfield3, extra_tmpfield4 and extra_tmpfield5
	move_sprites:
	.(
		screen_sprites_end = tmpfield1
		sprites_offset_lsb = extra_tmpfield3
		sprites_offset_msb = extra_tmpfield4
		sprite_y_pixel = extra_tmpfield5

		STACK_CALLER = 1 + 2 ; 1 to be on the last initialized byte + 2 to skip current routine's address

		; Choose if clouds need to be updated
		jsr get_transition_id
		cmp #STATE_TRANSITION(GAME_STATE_TITLE, GAME_STATE_MODE_SELECTION)
		beq update_clouds
		cmp #STATE_TRANSITION(GAME_STATE_MODE_SELECTION, GAME_STATE_TITLE)
		beq update_clouds
		cmp #STATE_TRANSITION(GAME_STATE_MODE_SELECTION, GAME_STATE_CONFIG)
		beq update_clouds
		cmp #STATE_TRANSITION(GAME_STATE_CONFIG, GAME_STATE_MODE_SELECTION)
		beq update_clouds
		cmp #STATE_TRANSITION(GAME_STATE_TITLE, GAME_STATE_CREDITS)
		beq update_clouds
		cmp #STATE_TRANSITION(GAME_STATE_CREDITS, GAME_STATE_TITLE)
		beq update_clouds
		cmp #STATE_TRANSITION(GAME_STATE_CONFIG, GAME_STATE_CHARACTER_SELECTION)
		beq update_clouds
		cmp #STATE_TRANSITION(GAME_STATE_CHARACTER_SELECTION, GAME_STATE_CONFIG)
		beq update_clouds

			; Clouds do not need to be updated
			lda #64                ; All sprites are from the destination screen
			sta screen_sprites_end ;

			jmp update_screen_sprites

		update_clouds:
			; Clouds need to be updated
			tsx                                                             ;
			ldy #MENU_COMMON_NB_CLOUDS-1                                    ;
			vertical_one_cloud:                                             ;
				lda menu_common_cloud_1_y, y                                ;
				clc                                                         ;
				adc stack + STACK_CALLER + STACK_CLOUD_SCROLL_LSB_OFFSET, x ; Update clouds Y position
				sta menu_common_cloud_1_y, y                                ; based on cloud_scroll_lsb and cloud_scroll_msb from our caller
				lda menu_common_cloud_1_y_msb, y                            ;
				adc stack + STACK_CALLER + STACK_CLOUD_SCROLL_MSB_OFFSET, x ;
				sta menu_common_cloud_1_y_msb, y                            ;
				dey                                                         ;
				bpl vertical_one_cloud                                      ;

			jsr tick_menu ; Update horizontal clouds position
			jsr menu_position_clouds ; Force refresh of cloud sprites

			lda #64 - MENU_COMMON_NB_CLOUDS * MENU_COMMON_NB_SPRITE_PER_CLOUD ; Only sprites before clouds are from destination screen
			sta screen_sprites_end                                            ;

		; Move destination screen sprites
		update_screen_sprites:

		; Convert camera position to an offset from initial position (signed two bytes)
		tsx
		ldy stack + STACK_CALLER + STACK_FRAME_CNT_OFFSET, x

		lda stack + STACK_CALLER + STACK_SCROLL_BEGIN_OFFSET, x
		sec
		sbc (camera_steps_addr), y
		sta sprites_offset_lsb
		lda #0
		sbc #0
		sta sprites_offset_msb

		; Move sprites
		ldy #0 ; Current sprite index
		move_one_screen_sprite:

			; Compute 16 bit sprite position
			lda screen_sprites_y_lsb, y
			clc
			adc sprites_offset_lsb
			sta sprite_y_pixel
			lda screen_sprites_y_msb, y
			adc sprites_offset_msb

			; If msb not 0, hide sprite, else place it to lsb
			bne hide_sprite
				lda sprite_y_pixel
				jmp update_oam
			hide_sprite:
				lda #$fe

			update_oam:       ;
			pha               ;
			tya               ;
			asl               ; Update OAM sprite
			asl               ;
			tax               ;
			pla               ;
			sta oam_mirror, x ;

			iny                        ; Next sprite
			cpy screen_sprites_end     ;
			bne move_one_screen_sprite ;

		end:
		rts
	.)

	sleep_frame:
	.(
		jsr wait_next_frame
		jsr audio_music_tick
		rts
	.)
.)

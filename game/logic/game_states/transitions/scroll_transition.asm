state_transition_pre_scroll_down:
.(
	; Call the scrolling routine
	lda #0
	sta tmpfield3
	sta tmpfield4
	lda #1
	jsr scroll_transition

	; No need to force the stop position
	; we expect rendering to be disabled soon after we return

	rts
.)

state_transition_pre_scroll_up:
.(
	; Call the scrolling routine
	lda #0
	sta tmpfield3
	sta tmpfield4
	lda #2
	jsr scroll_transition

	; No need to force the stop position
	; we expect rendering to be disabled soon after we return

	rts
.)

state_transition_post_scroll_down:
.(
	; Call the scrolling routine
	lda #2
	sta tmpfield3
	lda #1
	sta tmpfield4
	lda #1
	jsr scroll_transition

	; Force stop on scroll_y=0 of top nametable
	lda #%10010000 ; NMI enabled, background pattern table at $1000, base nametable is top left
	sta ppuctrl_val
	lda #0
	sta scroll_y

	rts
.)

state_transition_post_scroll_up:
.(
	; Call the scrolling routine
	lda #2
	sta tmpfield3
	lda #1
	sta tmpfield4
	lda #2
	jsr scroll_transition

	; Force stop on scroll_y=0 of top nametable
	lda #%10010000 ; NMI enabled, background pattern table at $1000, base nametable is top left
	sta ppuctrl_val
	lda #0
	sta scroll_y

	rts
.)

; Transition by scrolling between two screen, keeping menus clouds
;  tmpfield3 - origin screen 0 for top nametable, 2 for bottom one
;  tmpfield4 - sprites are from starting or destination screen (0 - starting screen ; 1 - destination screen)
;  register A - transition direction (0 - no transition ; 1 - down ; 2 - up)
scroll_transition:
.(
	.(
		screen_sprites_offset_lsb = tmpfield1
		screen_sprites_offset_msb = tmpfield2
		origin_nametable = tmpfield3
		offset_sprites = tmpfield4

		; Compute values dependent of the direction
		cmp #0
		beq skip_scrolling
		cmp #1
		bne set_up_values

		lda origin_nametable ;
		ora #%10010000       ; Reactivate NMI, place scrolling on origin nametable
		sta ppuctrl_val      ;
		lda #240
		sta screen_sprites_offset_lsb
		lda #0
		sta screen_sprites_offset_msb
		lda #$fd
		pha      ; cloud_scroll_lsb
		lda #$ff
		pha      ; cloud_scroll_msb
		lda #10
		pha      ; scroll_step
		lda #0
		pha      ; scroll_begin
		lda #240
		pha      ; scroll_end
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
		lda #$3
		pha      ; cloud_scroll_lsb
		lda #$0
		pha      ; cloud_scroll_msb
		lda #$f6
		pha      ; scroll_step
		lda #240
		pha      ; scroll_begin
		lda #0
		pha      ; scroll_end
		jmp end_set_values

		skip_scrolling:
		lda #%10010010  ;
		sta ppuctrl_val ; Reactivate NMI
		sta PPUCTRL     ;
		jsr sleep_frame  ; Avoid re-enabling mid-frame
		lda #%00011110 ; Enable sprites and background rendering
		sta PPUMASK    ;
		jmp end

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

		lda oam_mirror, x             ;
		clc                           ;
		adc screen_sprites_offset_lsb ;
		sta screen_sprites_y_lsb, y   ; Store sprite's two bytes y position
		lda screen_sprites_offset_msb ;
		adc #0                        ;
		sta screen_sprites_y_msb, y   ;

		lda #$fe          ; Hide sprite
		sta oam_mirror, x ; (even cloud sprites, they already blink due to disabling rendering anyway)

		iny                 ;
		inx                 ;
		inx                 ; Next sprite
		inx                 ;
		inx                 ;
		bne save_one_sprite ;

		; Enable rendering
		lda ppuctrl_val
		sta PPUCTRL
		tsx            ;
		lda stack+2, x ; set scrolling to scroll_begin
		cmp #240       ;
		bne set_scroll ;
		lda #239       ;
		set_scroll     ;
		sta scroll_y   ;
		jsr sleep_frame  ; Avoid re-enabling mid-frame
		lda #%00011110 ; Enable sprites and background rendering
		sta PPUMASK    ;

		; Scroll to the next screen
		tsx
		lda stack+2, x ; scroll_begin

		scroll_frame:
		sta scroll_y

		cmp #240       ;
		bne no_correct ;
		lda #239       ; Avoid scrolling of 240 which is more "before 0" than "after 239"
		sta scroll_y   ;
		lda #240       ;
		no_correct:    ;

		clc
		tsx
		adc stack+3, x ; scroll_step

		pha
		jsr sleep_frame
		jsr move_sprites
		pla

		tsx
		cmp stack+1, x ; scroll_end
		bne scroll_frame

		clean:
		pla ; scroll_end
		pla ; scroll_begin
		pla ; scroll_step
		pla ; cloud_scroll_msb
		pla ; cloud_scroll_lsb

		end:
		rts
	.)

	move_sprites:
	.(
		screen_sprites_end = tmpfield1
		scroll_y_msb = tmpfield2

		; Choose if clouds need to be updated
		jsr get_transition_id
		cmp #STATE_TRANSITION(GAME_STATE_TITLE, GAME_STATE_CONFIG)
		beq update_clouds
		cmp #STATE_TRANSITION(GAME_STATE_CONFIG, GAME_STATE_TITLE)
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

		; Clouds need to be updated
		update_clouds:
		tsx                              ;
		ldy #MENU_COMMON_NB_CLOUDS-1     ;
		vertical_one_cloud:              ;
		lda menu_common_cloud_1_y, y     ;
		clc                              ;
		adc stack + 2 + 1 + 5, x         ; Update clouds Y position
		sta menu_common_cloud_1_y, y     ; based on cloud_scroll_lsb and cloud_scroll_msb from our caller
		lda menu_common_cloud_1_y_msb, y ;
		adc stack + 2 + 1 + 4, x         ;
		sta menu_common_cloud_1_y_msb, y ;
		dey                              ;
		bpl vertical_one_cloud           ;

		jsr tick_menu ; Update horizontal clouds position
		jsr menu_position_clouds ; Force refresh of cloud sprites

		lda #64 - MENU_COMMON_NB_CLOUDS * MENU_COMMON_NB_SPRITE_PER_CLOUD ; Only sprites before clouds are from destination screen
		sta screen_sprites_end                                            ;

		; Move destination screen sprites
		update_screen_sprites:

		tsx                      ;
		lda stack + 2 + 1 + 3, x ;
		bpl positive             ;
		lda #0                   ;
		jmp set_scroll_y_msb     ; Compute MSB of a 16-bit "-1 * scroll_y"
		positive:                ;
		lda #$ff                 ;
		set_scroll_y_msb:        ;
		sta scroll_y_msb         ;

		ldy #0 ; Current sprite index
		move_one_screen_sprite:

		tsx                         ;
		lda stack + 2 + 1 + 3, x    ;
		eor #%11111111              ;
		clc                         ;
		adc #1                      ;
		clc                         ; Scroll 16-bit sprite's position
		adc screen_sprites_y_lsb, y ;
		sta screen_sprites_y_lsb, y ;
		lda screen_sprites_y_msb, y ;
		adc scroll_y_msb            ;
		sta screen_sprites_y_msb, y ;

		cmp #0                      ;
		bne hide_sprite             ;
									;
		lda screen_sprites_y_lsb, y ; Compute updated position of the OAM sprite
		jmp update_oam              ;
									;
		hide_sprite:                ;
		lda #$fe                    ;

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

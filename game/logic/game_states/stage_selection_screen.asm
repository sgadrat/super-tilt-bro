init_stage_selection_screen:
.(
	; This state only use the generic data bank
	SWITCH_BANK(#DATA_BANK_NUMBER)

	; Construct nt buffers for palettes
	lda #<palette_stage_selection
	sta tmpfield1
	lda #>palette_stage_selection
	sta tmpfield2
	jsr construct_palettes_nt_buffer

	; Copy background from PRG-rom to PPU nametable
	lda #<nametable_stage_selection
	sta tmpfield1
	lda #>nametable_stage_selection
	sta tmpfield2
	jsr draw_zipped_nametable

	; Place sprites
	ldx #$00
	copy_one_byte:
	lda sprites, x
	sta oam_mirror, x
	inx
	bne copy_one_byte

	; Show initial selection
	lda #%10101010
	sta tmpfield1
	jsr stage_selection_screen_modify_selected

	; Wait VBI to process nt buffers
	bit PPUSTATUS ; Clear PPUSTATUS bit 7 to avoid starting at the middle of the current VBI

	lda #$80          ;
	wait_vbi:         ; Wait for PPUSTATUS bit 7 to be set
		bit PPUSTATUS ; indicating the begining of a VBI
		beq wait_vbi  ;

	; Process the batch of nt buffers immediately (while the PPU is disabled)
	jsr process_nt_buffers
	jsr reset_nt_buffers

	rts

#define STAGE_SELECT_SPRITE(y,tile,attr,x) .byt y, tile, attr, x
	sprites:
	; Up left
	STAGE_SELECT_SPRITE($37, TILE_MINI_STAGE_FLATLAND_0, $00, $30)
	STAGE_SELECT_SPRITE($37, TILE_MINI_STAGE_FLATLAND_0, $00, $38)
	STAGE_SELECT_SPRITE($37, TILE_MINI_STAGE_FLATLAND_0, $00, $40)
	STAGE_SELECT_SPRITE($37, TILE_MINI_STAGE_FLATLAND_0, $00, $48)

	STAGE_SELECT_SPRITE($3f, TILE_MINI_STAGE_FLATLAND_0, $00, $30)
	STAGE_SELECT_SPRITE($3f, TILE_MINI_STAGE_FLATLAND_1, $00, $38)
	STAGE_SELECT_SPRITE($3f, TILE_MINI_STAGE_FLATLAND_0, $00, $40)
	STAGE_SELECT_SPRITE($3f, TILE_MINI_STAGE_FLATLAND_0, $00, $48)

	STAGE_SELECT_SPRITE($47, TILE_MINI_STAGE_FLATLAND_2, $00, $30)
	STAGE_SELECT_SPRITE($47, TILE_MINI_STAGE_FLATLAND_3, $00, $38)
	STAGE_SELECT_SPRITE($47, TILE_MINI_STAGE_FLATLAND_4, $00, $40)
	STAGE_SELECT_SPRITE($47, TILE_MINI_STAGE_FLATLAND_2, $40, $48)

	STAGE_SELECT_SPRITE($4f, TILE_MINI_STAGE_FLATLAND_5, $00, $30)
	STAGE_SELECT_SPRITE($4f, TILE_MINI_STAGE_FLATLAND_6, $00, $38)
	STAGE_SELECT_SPRITE($4f, TILE_MINI_STAGE_FLATLAND_6, $00, $40)
	STAGE_SELECT_SPRITE($4f, TILE_MINI_STAGE_FLATLAND_5, $40, $48)
	; Up right
	STAGE_SELECT_SPRITE($37, TILE_MINI_STAGE_PIT_0, $00, $b0)
	STAGE_SELECT_SPRITE($37, TILE_MINI_STAGE_PIT_0, $00, $b8)
	STAGE_SELECT_SPRITE($37, TILE_MINI_STAGE_PIT_0, $00, $c0)
	STAGE_SELECT_SPRITE($37, TILE_MINI_STAGE_PIT_0, $00, $c8)

	STAGE_SELECT_SPRITE($3f, TILE_MINI_STAGE_PIT_0, $00, $b0)
	STAGE_SELECT_SPRITE($3f, TILE_MINI_STAGE_PIT_3, $00, $b8)
	STAGE_SELECT_SPRITE($3f, TILE_MINI_STAGE_PIT_0, $00, $c0)
	STAGE_SELECT_SPRITE($3f, TILE_MINI_STAGE_PIT_0, $00, $c8)

	STAGE_SELECT_SPRITE($47, TILE_MINI_STAGE_PIT_1, $00, $b0)
	STAGE_SELECT_SPRITE($47, TILE_MINI_STAGE_PIT_0, $00, $b8)
	STAGE_SELECT_SPRITE($47, TILE_MINI_STAGE_PIT_0, $00, $c0)
	STAGE_SELECT_SPRITE($47, TILE_MINI_STAGE_PIT_1, $40, $c8)

	STAGE_SELECT_SPRITE($4f, TILE_MINI_STAGE_PIT_2, $00, $b0)
	STAGE_SELECT_SPRITE($4f, TILE_MINI_STAGE_PIT_0, $00, $b8)
	STAGE_SELECT_SPRITE($4f, TILE_MINI_STAGE_PIT_3, $40, $c0)
	STAGE_SELECT_SPRITE($4f, TILE_MINI_STAGE_PIT_2, $40, $c8)
	; Down left
	STAGE_SELECT_SPRITE($87, TILE_MINI_STAGE_SKYRIDE_0, $00, $30)
	STAGE_SELECT_SPRITE($87, TILE_MINI_STAGE_SKYRIDE_0, $00, $38)
	STAGE_SELECT_SPRITE($87, TILE_MINI_STAGE_SKYRIDE_0, $00, $40)
	STAGE_SELECT_SPRITE($87, TILE_MINI_STAGE_SKYRIDE_0, $00, $48)

	STAGE_SELECT_SPRITE($8f, TILE_MINI_STAGE_SKYRIDE_0, $00, $30)
	STAGE_SELECT_SPRITE($8f, TILE_MINI_STAGE_SKYRIDE_1, $00, $38)
	STAGE_SELECT_SPRITE($8f, TILE_MINI_STAGE_SKYRIDE_1, $40, $40)
	STAGE_SELECT_SPRITE($8f, TILE_MINI_STAGE_SKYRIDE_0, $00, $48)

	STAGE_SELECT_SPRITE($97, TILE_MINI_STAGE_SKYRIDE_2, $00, $30)
	STAGE_SELECT_SPRITE($97, TILE_MINI_STAGE_SKYRIDE_2, $40, $38)
	STAGE_SELECT_SPRITE($97, TILE_MINI_STAGE_SKYRIDE_3, $00, $40)
	STAGE_SELECT_SPRITE($97, TILE_MINI_STAGE_SKYRIDE_2, $40, $48)

	STAGE_SELECT_SPRITE($9f, TILE_MINI_STAGE_SKYRIDE_4, $00, $30)
	STAGE_SELECT_SPRITE($9f, TILE_MINI_STAGE_SKYRIDE_5, $00, $38)
	STAGE_SELECT_SPRITE($9f, TILE_MINI_STAGE_SKYRIDE_6, $00, $40)
	STAGE_SELECT_SPRITE($9f, TILE_MINI_STAGE_SKYRIDE_4, $40, $48)
	; Down right
	STAGE_SELECT_SPRITE($87, TILE_MINI_STAGE_HUNT_3, $00, $b0)
	STAGE_SELECT_SPRITE($87, TILE_MINI_STAGE_HUNT_3, $00, $b8)
	STAGE_SELECT_SPRITE($87, TILE_MINI_STAGE_HUNT_3, $00, $c0)
	STAGE_SELECT_SPRITE($87, TILE_MINI_STAGE_HUNT_3, $00, $c8)

	STAGE_SELECT_SPRITE($8f, TILE_MINI_STAGE_HUNT_3, $00, $b0)
	STAGE_SELECT_SPRITE($8f, TILE_MINI_STAGE_HUNT_3, $00, $b8)
	STAGE_SELECT_SPRITE($8f, TILE_MINI_STAGE_HUNT_3, $00, $c0)
	STAGE_SELECT_SPRITE($8f, TILE_MINI_STAGE_HUNT_3, $00, $c8)

	STAGE_SELECT_SPRITE($97, TILE_MINI_STAGE_HUNT_0, $00, $b0)
	STAGE_SELECT_SPRITE($97, TILE_MINI_STAGE_HUNT_1, $00, $b8)
	STAGE_SELECT_SPRITE($97, TILE_MINI_STAGE_HUNT_2, $00, $c0)
	STAGE_SELECT_SPRITE($97, TILE_MINI_STAGE_HUNT_1, $80, $c8)

	STAGE_SELECT_SPRITE($9f, TILE_MINI_STAGE_HUNT_3, $00, $b0)
	STAGE_SELECT_SPRITE($9f, TILE_MINI_STAGE_HUNT_4, $00, $b8)
	STAGE_SELECT_SPRITE($9f, TILE_MINI_STAGE_HUNT_5, $00, $c0)
	STAGE_SELECT_SPRITE($9f, TILE_MINI_STAGE_HUNT_3, $00, $c8)
.)

stage_selection_screen_tick:
.(
	SWITCH_BANK(#DATA_BANK_NUMBER)

	; Clear already written buffers
	jsr reset_nt_buffers

	; Check if a button is released and trigger correct action
	ldx #0
	check_one_controller:

	lda controller_a_btns, x
	bne next_controller

	ldy #0
	btn_search_loop:
	lda buttons_numbering, y
	cmp controller_a_last_frame_btns, x
	beq jump_from_table
	iny
	cpy #6
	bne btn_search_loop

	next_controller:
	inx
	cpx #2
	bne check_one_controller
	jmp end

	jump_from_table:
	tya
	asl
	tay
	lda buttons_actions, y
	sta tmpfield1
	lda buttons_actions+1, y
	sta tmpfield2
	jmp (tmpfield1)

	end:
	rts

	; Go to the next screen
	next_screen:
	.(
		; Do nothing if the selected stage does not exists
		lda config_selected_stage
		cmp #4
		bcs end

		jsr fade_out

		; Start the game
		lda #GAME_STATE_INGAME
		jsr change_global_game_state
		; jmp end ; not needed, change_global_game_state does not return
	.)

	; Go to the previous screen
	previous_screen:
	.(
		; Return to config screen
		lda #GAME_STATE_CHARACTER_SELECTION
		jsr change_global_game_state
		; jmp end ; not needed, change_global_game_state does not return
	.)

	go_right:
	.(
		; Do nothing if already on the right of the screen
		lda config_selected_stage
		cmp #$01
		beq end
		cmp #$03
		beq end

		; Grey currently selected stage
		lda #%00000000
		sta tmpfield1
		jsr stage_selection_screen_modify_selected

		; Change selected stage
		inc config_selected_stage

		; Highlight currently selected stage
		lda #%10101010
		sta tmpfield1
		jsr stage_selection_screen_modify_selected

		jmp end
	.)

	go_left:
	.(
		; Do nothing if already on the left of the screen
		lda config_selected_stage
		cmp #$00
		beq end
		cmp #$02
		beq end

		; Grey currently selected stage
		lda #%00000000
		sta tmpfield1
		jsr stage_selection_screen_modify_selected

		; Change selected stage
		dec config_selected_stage

		; Highlight currently selected stage
		lda #%10101010
		sta tmpfield1
		jsr stage_selection_screen_modify_selected

		jmp end
	.)

	go_up:
	.(
		; Do nothing if already on the top of the screen
		lda config_selected_stage
		cmp #$00
		beq end
		cmp #$01
		beq end

		; Grey currently selected stage
		lda #%00000000
		sta tmpfield1
		jsr stage_selection_screen_modify_selected

		; Change selected stage
		dec config_selected_stage
		dec config_selected_stage

		; Highlight currently selected stage
		lda #%10101010
		sta tmpfield1
		jsr stage_selection_screen_modify_selected

		jmp end
	.)

	go_down:
	.(
		; Do nothing if already on the bottom of the screen
		lda config_selected_stage
		cmp #$02
		beq end
		cmp #$03
		beq end

		; Grey currently selected stage
		lda #%00000000
		sta tmpfield1
		jsr stage_selection_screen_modify_selected

		; Change selected stage
		inc config_selected_stage
		inc config_selected_stage

		; Highlight currently selected stage
		lda #%10101010
		sta tmpfield1
		jsr stage_selection_screen_modify_selected

		jmp end
	.)

	; Fade out transition
	;  Progressively mute music and change palettes to background color
	fade_out:
	.(
		; tmpfield1 - used by NMI

		ldy #0
		fade_step:
		jsr last_nt_buffer

		lda #$01                 ;
		sta nametable_buffers, x ;
		inx                      ;
		lda #$3f                 ;
		sta nametable_buffers, x ;
		inx                      ; Nametable buffer's header
		lda #$00                 ;
		sta nametable_buffers, x ;
		inx                      ;
		lda #32                  ;
		sta nametable_buffers, x ;
		inx                      ;

		copy_bg_byte:            ;
		lda palette_steps, y     ;
		sta nametable_buffers, x ;
		inx                      ;
		iny                      ;
		cpy #32                  ;
		beq end_copy             ; Copy step's palette to buffer's body
		cpy #32*2                ;
		beq end_copy             ;
		cpy #32*3                ;
		beq end_copy             ;
		jmp copy_bg_byte         ;
		end_copy:                ;

		lda #0                   ; Buffer's footer
		sta nametable_buffers, x ;

		tya                      ;
		pha                      ;
		lda #5                   ;
		sleep:                   ;
			pha                  ;
			jsr wait_next_frame  ;
			jsr audio_music_tick ; Sleep between steps
			jsr reset_nt_buffers ;
			pla                  ;
			sec                  ;
			sbc #1               ;
			bne sleep            ;
		pla                      ;
		tay                      ;

		cpy #32*3
		bne fade_step

		rts

		palette_steps:
		;.byt $21,$0d,$12,$00, $21,$00,$00,$00, $21,$0d,$28,$00, $21,$0d,$20,$10 ; original values, should exactly match the actual ones
		;.byt $21,$0d,$0d,$21, $21,$08,$19,$21, $21,$00,$00,$00, $21,$00,$00,$00 ;

		.byt $21,$01,$11,$01, $21,$01,$01,$01, $21,$01,$21,$01, $21,$01,$21,$11
		.byt $21,$01,$01,$21, $21,$01,$11,$21, $21,$01,$01,$01, $21,$01,$01,$01

		.byt $21,$11,$21,$11, $21,$11,$11,$11, $21,$11,$21,$11, $21,$11,$21,$21
		.byt $21,$11,$11,$21, $21,$11,$21,$21, $21,$11,$11,$11, $21,$11,$11,$11

		.byt $21,$21,$21,$21, $21,$21,$21,$21, $21,$21,$21,$21, $21,$21,$21,$21
		.byt $21,$21,$21,$21, $21,$21,$21,$21, $21,$21,$21,$21, $21,$21,$21,$21
	.)

	buttons_numbering:
	.byt CONTROLLER_BTN_RIGHT, CONTROLLER_BTN_LEFT, CONTROLLER_BTN_DOWN, CONTROLLER_BTN_UP, CONTROLLER_BTN_START
	.byt CONTROLLER_BTN_B
	buttons_actions:
	.word go_right,            go_left,             go_down,             go_up,             next_screen
	.word previous_screen
.)

; Modify highlighting of the selected level
;  tmpfield1 - %10101010 if to be activated, else %00000000
stage_selection_screen_modify_selected:
.(
	;
	; Minitature's sprites
	;

	; Point X to the atttribute bytes of the first sprite
	lda config_selected_stage
	asl
	asl
	asl
	asl
	asl
	asl
	; clc ; not needed, previous asl should not overflow
	adc #2
	tax

	; Change the palette of each sprites
	ldy #16 ; Number of sprites to modify
	change_one:
	lda #$01          ;
	eor oam_mirror, x ; Change the current byte
	sta oam_mirror, x ;
	inx ;
	inx ; point X to the next sprite's attributes byte
	inx ;
	inx ;
	dey            ; Loop on all related sprites
	bne change_one ;

	;
	; Frame's background
	;

	; Initialize working data
	jsr last_nt_buffer ; Set X after the last nametable buffer
	ldy config_selected_stage ;
	lda frame_adresses_lsb, y ; Set tmpfield2 to the lsb of the attribute's line
	sta tmpfield2             ;
	ldy #3 ; Set Y to the number of lines to affect

	; Write a nametable buffer for a line of the current frame
	set_line_attributes:
	lda tmpfield1 ; initialize current line attributes to the requested ones
	sta tmpfield3 ;

	cpy #3
	bne no_change_first_line
	lda config_selected_stage
	cmp #2
	bcs no_change_first_line
	lda tmpfield1 ; already loaded
	ora #%00001111
	sta tmpfield3
	no_change_first_line:

	cpy #1         ;
	bne no_change  ;
	lda tmpfield1  ; Tile's row following a stage block must use palette #3
	ora #%11110000 ;
	sta tmpfield3  ;
	no_change:     ;

	lda #$01
	sta nametable_buffers, x
	inx
	lda #$23
	sta nametable_buffers, x
	inx
	lda tmpfield2
	sta nametable_buffers, x
	inx
	lda #4
	sta nametable_buffers, x
	inx
	lda tmpfield3
	sta nametable_buffers, x
	inx
	sta nametable_buffers, x
	inx
	sta nametable_buffers, x
	inx
	sta nametable_buffers, x
	inx

	; Prepare next line
	lda #8        ;
	clc           ; Point tmpfield2 to the next line
	adc tmpfield2 ;
	sta tmpfield2 ;
	dey                     ; Loop until the number of lines is good
	bne set_line_attributes ;

	; Set the nametable buffer guarding byte
	lda #$00
	sta nametable_buffers, x

	rts

	frame_adresses_lsb:
	.byt $c8
	.byt $cc
	.byt $e0
	.byt $e4
.)

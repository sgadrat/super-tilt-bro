init_credits_screen:
.(
	.(
		line_num = $0005
		char_cursor_low = $0006
		char_cursor_high = $0007

		SWITCH_BANK(#DATA_BANK_NUMBER)

		; Construct nt buffers for palettes (to avoid changing it mid-frame)
		lda #<palette_title
		sta tmpfield1
		lda #>palette_title
		sta tmpfield2
		jsr construct_palettes_nt_buffer

		; Clear background
		lda #$00
		sta $40
		sta $41
		lda PPUSTATUS
		lda #$20
		sta PPUADDR
		lda #$00
		sta PPUADDR
		load_background:
		lda #$00
		sta PPUDATA
		inc $40
		bne end_inc_vector
		inc $41
		end_inc_vector:
		lda #$04
		cmp $41
		bne load_background
		lda #$00
		cmp $40
		bne load_background

		; Pimp nametable attributes
		lda PPUSTATUS
		lda #$23
		sta PPUADDR
		lda #$c0
		sta PPUADDR
		lda #%10100101
		jsr fill_attributes_line
		lda #%10100000
		jsr fill_attributes_line
		lda #%00000000
		jsr fill_attributes_line
		lda #%00000000
		jsr fill_attributes_line
		lda #%00000000
		jsr fill_attributes_line
		lda #%10100000
		jsr fill_attributes_line
		lda PPUSTATUS
		lda #$23
		sta PPUADDR
		lda #$c0
		sta PPUADDR

		; Write credits
		lda #1
		sta line_num
		lda #<credits_begin
		sta char_cursor_low
		lda #>credits_begin
		sta char_cursor_high
		ldy #0

		write_one_line:
		lda #32       ;
		sta tmpfield1 ;
		lda #0        ;
		sta tmpfield2 ;
		lda line_num  ;
		sta tmpfield3 ;
		jsr multiply  ;
		clc           ; Point PPUADDR to the line's begining
		lda #$02      ;
		adc tmpfield4 ; PPUADDR = $2000 + (32 * line num) + 2
		sta tmpfield4 ;           |       |                 `-> Keep 2 spaces at as left margin
		lda #$20      ;           |       `-------------------> Index of the line's leftmost tile in the nametable
		adc tmpfield5 ;           `---------------------------> Nametable's address
		sta tmpfield5 ;
		lda PPUSTATUS ;
		lda tmpfield5 ;
		sta PPUADDR   ;
		lda tmpfield4 ;
		sta PPUADDR   ;

		write_one_char:
		lda (char_cursor_low), y ;
		inc char_cursor_low      ; Load current character and point to
		bne end_inc_cursor       ; the next one
		inc char_cursor_high     ;
		end_inc_cursor:          ;

		cmp #$0a                 ;
		beq new_line             ; Considere opcodes
		cmp #$00                 ;  $0a - line break
		beq end_write_credits    ;  $00 - end of data
		cmp #$20                 ;  $20 - space
		beq space                ;  $2d - filled space
		cmp #$2d                 ;
		beq filled_space         ;

		sec                ;
		sbc #42            ; Generic case
		sta PPUDATA        ; tile_id = char_value - 42
		jmp write_one_char ;

		space:
		lda #00            ;
		sta PPUDATA        ; Space character, tile $00
		jmp write_one_char ;

		filled_space:
		lda #02            ;
		sta PPUDATA        ; Space filled with text-baground color, tile $02
		jmp write_one_char ;

		new_line:
		inc line_num       ; Increment line number and loop
		jmp write_one_line ; to the new line

		end_write_credits:

		; Initialize common menus effects
		jsr re_init_menu

		rts
	.)

	fill_attributes_line:
	.(
		ldx #0
		write_attribute_byte:
		sta PPUDATA
		inx
		cpx #8
		bne write_attribute_byte
		rts
	.)
.)

credits_screen_tick:
.(
	SWITCH_BANK(#DATA_BANK_NUMBER)

	; Play common menus effects
	jsr tick_menu

	; If all buttons of any controller are released on this frame, got to the next screen
	lda controller_a_btns
	bne check_controller_b
	cmp controller_a_last_frame_btns
	bne next_screen
	check_controller_b:
	lda controller_b_btns
	bne end
	cmp controller_b_last_frame_btns
	bne next_screen
	jmp end

	next_screen:
	lda #GAME_STATE_TITLE
	jsr change_global_game_state

	end:
	rts
.)

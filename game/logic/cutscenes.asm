.(
CUTSCENE_NB_ANIMATIONS = 4

; Stores requested animation state's address in tmpfield11/12
;  X - animation index
;
; Overwrites A, X, tmpfield11, tmpfield12
load_animation_addr:
.(
	animation_addr = tmpfield11

	lda #<cutscene_anims
	sta animation_addr
	lda #>cutscene_anims
	sta animation_addr+1

	cpx #0
	beq end_multiply
	multiply_by_13x:
		lda animation_addr
		clc
		adc #ANIMATION_STATE_LENGTH
		sta animation_addr
		lda animation_addr+1
		adc #0
		sta animation_addr+1

		dex
		bne multiply_by_13x
	end_multiply:

	rts
.)

&cutscene_init_anim:
.(
	parameter_addr = tmpfield1
	animation_addr = tmpfield11

	; Stack shenaningans to handle parameters being hardcoded after the jsr
	lda #13
	jsr inline_parameters

	; Call state initialization routine
	ldy #0 ; index
	lda (parameter_addr), y
	tax
	jsr load_animation_addr

	ldy #1 ; anim
	lda (parameter_addr), y
	sta tmpfield13
	iny
	lda (parameter_addr), y
	sta tmpfield14

	jsr animation_init_state

	; Set state's extra information
	ldy #4 ; direction
	lda (parameter_addr), y
	ldy #ANIMATION_STATE_OFFSET_DIRECTION
	sta (animation_addr), y

	ldy #5 ; x (lsb)
	lda (parameter_addr), y
	ldy #ANIMATION_STATE_OFFSET_X_LSB
	sta (animation_addr), y

	ldy #5+1 ; x (msb)
	lda (parameter_addr), y
	ldy #ANIMATION_STATE_OFFSET_X_MSB
	sta (animation_addr), y

	ldy #7 ; y (lsb)
	lda (parameter_addr), y
	ldy #ANIMATION_STATE_OFFSET_Y_LSB
	sta (animation_addr), y

	ldy #7+1 ; y (msb)
	lda (parameter_addr), y
	ldy #ANIMATION_STATE_OFFSET_Y_MSB
	sta (animation_addr), y

	ldy #0 ; index
	lda (parameter_addr), y
	asl
	asl
	asl
	asl
	ldy #ANIMATION_STATE_OFFSET_FIRST_SPRITE_NUM
	sta (animation_addr), y

	clc
	adc #15
	ldy #ANIMATION_STATE_OFFSET_LAST_SPRITE_NUM
	sta (animation_addr), y

	; Set cutscene specific extra information
	ldy #0 ; index
	lda (parameter_addr), y
	tax

	lda #1
	sta cutscene_anims_enabled, x

	lda #0
	sta cutscene_anims_pos_x_subpixel, x
	sta cutscene_anims_pos_y_subpixel, x

	ldy #9 ; velocity_h (lsb)
	lda (parameter_addr), y
	sta cutscene_anims_velocity_h_subpixel, x

	ldy #9+1 ; velocity_h (msb)
	lda (parameter_addr), y
	sta cutscene_anims_velocity_h_pixel, x

	ldy #11 ; velocity_v (lsb)
	lda (parameter_addr), y
	sta cutscene_anims_velocity_v_subpixel, x

	ldy #11+1 ; velocity_v (msb)
	lda (parameter_addr), y
	sta cutscene_anims_velocity_v_pixel, x

	ldy #13 ; player_number
	lda (parameter_addr), y
	sta cutscene_anims_player, x

	ldy #3 ; bank
	lda (parameter_addr), y
	sta cutscene_anims_bank, x

	; return
	rts
.)

#define INIT_ANIM(index,anim,bank,direction,pos_x,pos_y,velocity_h,velocity_v) .( :\
	jsr cutscene_init_anim :\
	.byt index       ; 0 :\
	.word anim       ; 1 :\
	.byt bank        ; 3 :\
	.byt direction   ; 4 :\
	.word pos_x      ; 5 :\
	.word pos_y      ; 7 :\
	.word velocity_h ; 9 ;TODO adapt to pal/ntsc using a lookup table and system_index :\
	.word velocity_v ;11 ;TODO adapt to pal/ntsc using a lookup table and system_index :\
	.word 0          ;13 ; player_number :\
.)

#define INIT_ANIM_FOR_PLAYER(index,anim,bank,direction,pos_x,pos_y,velocity_h,velocity_v,player) .( :\
	jsr cutscene_init_anim :\
	.byt index       ; 0 :\
	.word anim       ; 1 :\
	.byt bank        ; 3 :\
	.byt direction   ; 4 :\
	.word pos_x      ; 5 :\
	.word pos_y      ; 7 :\
	.word velocity_h ; 9 ;TODO adapt to pal/ntsc using a lookup table and system_index :\
	.word velocity_v ;11 ;TODO adapt to pal/ntsc using a lookup table and system_index :\
	.word player     ;12 :\
.)

&cutscene_anim_velocity:
.(
	parameter_addr = tmpfield1

	; Stack shenaningans to handle parameters being hardcoded after the jsr
	lda #5
	jsr inline_parameters

	; Change animation's velocity
	ldy #0
	lda (parameter_addr), y
	tax

	iny
	lda (parameter_addr), y
	sta cutscene_anims_velocity_h_subpixel, x
	iny
	lda (parameter_addr), y
	sta cutscene_anims_velocity_h_pixel, x

	iny
	lda (parameter_addr), y
	sta cutscene_anims_velocity_v_subpixel, x
	iny
	lda (parameter_addr), y
	sta cutscene_anims_velocity_v_pixel, x

	rts
.)

#define ANIM_VELOCITY(index, velocity_h,velocity_v) .( :\
	jsr cutscene_anim_velocity :\
	.byt index       ; 0:\
	.word velocity_h ; 1 ;TODO adapt to pal/ntsc using a lookup table and system_index :\
	.word velocity_v ; 3 ;TODO adapt to pal/ntsc using a lookup table and system_index :\
.)

&cutscene_clear_anim:
.(
	parameter_addr = tmpfield1
	last_sprite = tmpfield1
	animation_addr = tmpfield11

	; Stack shenaningans to handle parameters being hardcoded after the jsr
	lda #1
	jsr inline_parameters

	; Disable animation
	ldy #0 ; index
	lda (parameter_addr), y
	tax

	lda #0
	sta cutscene_anims_enabled, x

	; Hide animation's sprites
	jsr load_animation_addr

	ldy #ANIMATION_STATE_OFFSET_FIRST_SPRITE_NUM
	lda (animation_addr), y
	tax
	dex

	ldy #ANIMATION_STATE_OFFSET_LAST_SPRITE_NUM
	lda (animation_addr), y
	sta last_sprite

	hide_one_sprite:
		; Y = sprite offset in OAM
		inx
		txa
		asl
		asl
		tay

		; Hide sprite, putting it bellow screen
		lda #$fe
		sta oam_mirror, y

		; Loop
		cpx last_sprite
		bne hide_one_sprite

	rts
.)

#define CLEAR_ANIM(index) .( :\
	jsr cutscene_clear_anim :\
	.byt index :\
.)

&cutscene_set_palette:
.(
	parameter_addr = tmpfield1

	; Stack shenaningans to handle parameters being hardcoded after the jsr
	lda #4
	jsr inline_parameters

	; Construct a nametable buffer from parameters
	LAST_NT_BUFFER

	lda #1
	sta nametable_buffers, x
	inx
	lda #$3f
	sta nametable_buffers, x
	inx

	ldy #0
	lda (parameter_addr), y
	asl
	asl
	clc
	adc #1
	sta nametable_buffers, x
	inx

	lda #3
	sta nametable_buffers, x
	inx

	copy_colors:
		iny
		lda (parameter_addr), y
		sta nametable_buffers, x
		inx

		cpy #3
		bne copy_colors

	lda #0
	sta nametable_buffers, x
	stx nt_buffers_end
	inx

	rts
.)

#define SET_PALETTE(index,color1,color2,color3) .( :\
	jsr cutscene_set_palette :\
	.byt index :\
	.byt color1 :\
	.byt color2 :\
	.byt color3 :\
.)

&cutscene_set_bg_color:
.(
	parameter_addr = tmpfield1
	header_addr = tmpfield1
	payload_addr = tmpfield3

	; Stack shenaningans to handle parameters being hardcoded after the jsr
	lda #1
	jsr inline_parameters

	; Make an nt buffer to overwrite BG color
	lda parameter_addr
	sta payload_addr
	lda parameter_addr+1
	sta payload_addr+1

	lda #<buff_header
	sta header_addr
	lda #>buff_header
	sta header_addr+1

	jmp construct_nt_buffer

	;rts ; useless, jump to subroutine

	buff_header:
		.byt $3f, $00, 1
.)

#define CUTS_SET_BG_COLOR(color) .( :\
	jsr cutscene_set_bg_color :\
	.byt color :\
.)

&cutscene_text:
.(
	character_converter = tmpfield1
	;character_converter_msb = tmpfield2
	parameter_addr = tmpfield3 ; Note - not the same as usual tmpfield1 for parameter_addr
	;parameter_addr_msb = tmpfield4
	data_length = tmpfield5
	tmp_x_store = tmpfield6
	tmp_y_store = tmpfield7

	; Get first argument address (from return address)
	pla
	clc
	adc #1
	sta parameter_addr
	pla
	adc #0
	sta parameter_addr+1

	; Store character conversion routine address in zeropage to be able to jump on it
	ldy #0
	lda (parameter_addr), y
	sta character_converter
	iny
	lda (parameter_addr), y
	sta character_converter+1
	iny

	; Construct nametable buffer
	.(
		; X = begining of the buffer
		LAST_NT_BUFFER

		; Continuation byte
		lda #1
		sta nametable_buffers, x
		inx

		; PPU address
		iny
		lda (parameter_addr), y
		sta nametable_buffers, x
		inx
		dey
		lda (parameter_addr), y
		sta nametable_buffers, x
		inx
		iny
		iny

		; Save buffer's begining
		txa
		pha

		; Data
		lda #0
		sta data_length

		inx
		.(
			copy_one_char:
				lda (parameter_addr), y
				beq data_end

				stx tmp_x_store
				sty tmp_y_store
				jsr call_pointed_subroutine ; Note - expect character_converter to be correctly set (and be tmpfield1)
				ldx tmp_x_store
				ldy tmp_y_store

				sta nametable_buffers, x

				inc data_length
				inx
				iny
				jmp copy_one_char

			data_end:
		.)

		; Stop byte
		lda #0
		sta nametable_buffers, x
		stx nt_buffers_end

		; Data length
		pla
		tax
		lda data_length
		sta nametable_buffers, x
	.)

	; Return after parameters
	.(
		; Return address is (parameter_addr - 1) + (data_length + 1) + known_size_param
		lda #4-1+1 ; known_size_param - 1 + 1

		clc
		adc data_length ; + data_length

		adc parameter_addr
		sta parameter_addr
		lda #0
		adc parameter_addr+1 ; + parameter_addr
		;sta parameter_addr+1 ; useless, use value in A

		; Push computed address to stack to return to it
		pha
		lda parameter_addr
		pha
	.)

	rts
.)

; Convert an ascii value to its equivalent alphanum charaset stored at the end of the tileset
;  A - character to convert
&ascii_to_alphanum:
.(
	; Check character category
	cmp #"A"
	bcc not_alpha_upper
	cmp #"Z"+1
	bcs not_alpha_upper
		jmp alpha_upper
	not_alpha_upper:

	cmp #"a"
	bcc not_alpha_lower
	cmp #"z"+1
	bcs not_alpha_lower
		jmp alpha_lower
	not_alpha_lower:

	cmp #"0"
	bcc not_num
	cmp #"9"+1
	bcs not_num
		jmp num
	not_num:

	;jmp unknown ; fallthrough

	; Apply category
	unknown:
		lda #0
		rts

	alpha_upper:
		sec
		sbc #"A"-10
		jmp apply_charset_offset

	alpha_lower:
		sec
		sbc #"a"-10
		jmp apply_charset_offset

	num:
		sec
		sbc #"0"
		;jmp apply_charset_offset ; falltrhough

	; Apply offset of the charset in tiles
	apply_charset_offset:
	clc
	adc #$dc

	rts
.)

; Convert an ascii value to its equivalent alphanum charset + symbols stored at the end of the tileset
;  A - character to convert
&ascii_to_alphanum_symbols:
.(
	; Search symbol in the table
	ldx #n_symbols
	check_one_symbol:
		cmp ascii_symbols, x
		bne loop

			; Found, add first symbol offset and return
			txa
			clc
			adc #$cc
			rts

		loop:
		dex
		bpl check_one_symbol

	; Not found, fallback to ascii_to_alphanum
	jmp ascii_to_alphanum

	ascii_symbols:
		.asc " !#$%'()+,-.:=?@"
	n_symbols = *-ascii_symbols
.)

#define TEXT(col,row,data) .( :\
	jsr cutscene_text :\
	.word ascii_to_alphanum_symbols :\
	.word $2000+(row*32+col) :\
	.asc data, 0 :\
.)

; Wait a set number of frames while ticking animations, scrolling, and taking care of user skips.
;  A - Number of frames to play
;  X - Allow the user to skip this wait
;
; Overwrites all registers and all tmpfields
&cutscene_play_frames:
.(
	extended_byte = tmpfield1
	animation_addr = tmpfield11

	; Store parameters in easily reachable location
	; TODO should be parameters at the end of routine call, not in registers
	sta cutscene_frame_count
	stx cutscene_frames_skippable

	play_frames_loop:
		; Update animations
		.(
			ldx #CUTSCENE_NB_ANIMATIONS-1
			tick_one_animation:
				; Skip tick if animation is disabled
				lda cutscene_anims_enabled, x
				bne process
					jmp end_tick
				process:

				; Compute current animation pointer
				txa
				pha
				jsr load_animation_addr
				pla
				tax

				; Move animation
				lda cutscene_anims_pos_x_subpixel, x
				clc
				adc cutscene_anims_velocity_h_subpixel, x
				sta cutscene_anims_pos_x_subpixel, x

				ldy #ANIMATION_STATE_OFFSET_X_LSB
				lda (animation_addr), y
				adc cutscene_anims_velocity_h_pixel, x
				sta (animation_addr), y

				lda cutscene_anims_velocity_h_pixel, x
				SIGN_EXTEND()
				sta extended_byte

				ldy #ANIMATION_STATE_OFFSET_X_MSB
				lda (animation_addr), y
				adc extended_byte
				sta (animation_addr), y

				lda cutscene_anims_pos_y_subpixel, x
				clc
				adc cutscene_anims_velocity_v_subpixel, x
				sta cutscene_anims_pos_y_subpixel, x

				ldy #ANIMATION_STATE_OFFSET_Y_LSB
				lda (animation_addr), y
				adc cutscene_anims_velocity_v_pixel, x
				sta (animation_addr), y

				lda cutscene_anims_velocity_v_pixel, x
				SIGN_EXTEND()
				sta extended_byte

				ldy #ANIMATION_STATE_OFFSET_Y_MSB
				lda (animation_addr), y
				adc extended_byte
				sta (animation_addr), y

				; Update animation
				txa
				pha

				lda #<animation_draw
				sta extra_tmpfield1
				lda #>animation_draw
				sta extra_tmpfield2
				lda cutscene_anims_bank, x
				sta extra_tmpfield3
				lda #CURRENT_BANK_NUMBER
				sta extra_tmpfield4
				lda cutscene_anims_player, x
				tax
				stx player_number
				jsr trampoline

				pla
				tax
				pha

				TRAMPOLINE(animation_tick, cutscene_anims_bank COMMA x, #CURRENT_BANK_NUMBER)

				pla
				tax

				; Loop
				end_tick:
				dex
				bmi end_animations
				jmp tick_one_animation

			end_animations:
		.)

		; Auto scroll
		.(
			; Apply horizontal scroll
			lda cutscene_autoscroll_h
			clc
			adc scroll_x
			sta scroll_x

			; Apply vertical scroll
			lda cutscene_autoscroll_v
			clc
			adc scroll_y
			sta scroll_y

			; Ensure consistence with screen height being 240 pixels
			;  if (y >= 240)
			;    * switch nametable nametable
			;    if (cutscene_autoscroll_v >= 0)
			;      * y = y - 240
			;    else
			;      * y = 240 - (256 - y)
			.(
				lda scroll_y
				cmp #240
				bcc ok

					; Switch vertical nametable
					lda ppuctrl_val
					eor #%00000010
					sta ppuctrl_val

					; Adjust Y value on the new nametable
					lda cutscene_autoscroll_v
					bmi switch_to_top

						switch_to_bottom:
							lda scroll_y
							sec
							sbc #240
							sta scroll_y
							jmp ok

						switch_to_top:
							; Simplified formula
							;  y = 240 - (256 - y)
							;  y = 240 - 256 + y
							;  y = -16 + y
							;  y = y - 16
							lda scroll_y
							sec
							sbc #16
							sta scroll_y
							;jmp ok ; fallthrough

				ok:
			.)
		.)

		; Screen shake
		.(
			lda screen_shake_counter
			beq ok
				jsr shake_screen
			ok:
		.)

		; Bank-safe sleep_frame
		lda #<sleep_frame
		sta extra_tmpfield1
		lda #>sleep_frame
		sta extra_tmpfield2
		lda #CURRENT_BANK_NUMBER
		sta extra_tmpfield3
		sta extra_tmpfield4
		jsr trampoline

		jsr fetch_controllers

		; Handle inputs
		lda controller_a_btns
		bne ok
			; Stop cutscene if the player presses start
			lda controller_a_last_frame_btns
			cmp #CONTROLLER_BTN_START
			bne not_start
				lda #0
				rts
			not_start:

			; Stop playing frames if the player presses A (and frames are skippable)
			cmp #CONTROLLER_BTN_A
			bne not_a
				lda cutscene_frames_skippable
				beq not_a
					lda #1
					rts
			not_a:
		ok:

		; Loop
		dec cutscene_frame_count
		beq end
		jmp play_frames_loop

	end:
	lda #1
	rts
.)

#define PLAY_FRAMES(n) .( :\
	lda #n ;TODO adapt to ntsc/pal :\
	ldx #0 :\
	jsr cutscene_play_frames :\
	bne ok :\
		rts :\
	ok:\
.)

#define SKIPPABLE_FRAMES(n) .( :\
	lda #n ;TODO adapt to ntsc/pal :\
	ldx #1 :\
	jsr cutscene_play_frames :\
	bne ok :\
		rts :\
	ok:\
.)

#define DRAW_BUFFERS .( :\
	; On stack - as the user requested scene's end :\
	lda #0 :\
	pha :\
:\
	play_one_frame:\
		lda #1 :\
		ldx #0 :\
		jsr cutscene_play_frames :\
		bne ok :\
			pla :\
			lda #1 :\
			pha :\
		ok:\
:\
		lda nt_buffers_begin :\
		cmp nt_buffers_end :\
		bne play_one_frame :\
:\
	pla :\
	beq continue_scene :\
		rts :\
	continue_scene:\
.)

&cutscene_set_screen:
.(
	parameter_addr = tmpfield1

	lda #1
	jsr inline_parameters

	lda ppuctrl_val
	and #%11111100
	ldy #0
	ora (parameter_addr), y
	sta ppuctrl_val

	rts
.)

#define SET_SCREEN(screen_num) .( :\
	jsr cutscene_set_screen :\
	.byt screen_num :\
.)

&cutscene_set_scroll:
.(
	parameter_addr = tmpfield1

	lda #2
	jsr inline_parameters

	ldy #0
	lda (parameter_addr), y
	sta scroll_x
	iny

	lda (parameter_addr), y
	sta scroll_y

	rts
.)

#define CUTS_SET_SCROLL(h,v) .( :\
	jsr cutscene_set_scroll :\
	.byt h, v :\
.)

&cutscene_auto_scroll:
.(
	parameter_addr = tmpfield1

	lda #2
	jsr inline_parameters

	ldy #0
	lda (parameter_addr), y
	sta cutscene_autoscroll_h

	iny
	lda (parameter_addr), y
	sta cutscene_autoscroll_v

	rts
.)

#define AUTO_SCROLL(h,v) .( :\
	jsr cutscene_auto_scroll :\
	.byt <h :\
	.byt <v :\
.)

&cutscene_bg_update:
.(
	parameter_addr = tmpfield1
	data_addr = tmpfield3

	lda #5
	jsr inline_parameters

	ldy #3
	lda (parameter_addr), y
	sta data_addr
	iny
	lda (parameter_addr), y
	sta data_addr+1

	jmp construct_nt_buffer
	;rts ; useless, jump to subroutine
.)

#define BG_UPDATE(ppu_addr,len,data) .( :\
	jsr cutscene_bg_update :\
	.byt >ppu_addr :\
	.byt <ppu_addr :\
	.byt len :\
	.word data :\
.)

&cutscene_screen_shake:
.(
	parameter_addr = tmpfield1

	lda #3
	jsr inline_parameters

	ldy #0
	sty screen_shake_current_x
	sty screen_shake_current_y
	sty screen_shake_speed_h
	sty screen_shake_speed_v

	lda (parameter_addr), y
	sta screen_shake_counter
	iny

	lda (parameter_addr), y
	sta screen_shake_noise_h
	iny

	lda (parameter_addr), y
	sta screen_shake_noise_v

	rts
.)

#define CUTS_SCREEN_SHAKE(duration,h,v) .( :\
	jsr cutscene_screen_shake :\
	.byt duration, h, v :\
.)

.)

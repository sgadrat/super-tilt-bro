cutscene_sinbad_story_bird_msg_bank = CURRENT_BANK_NUMBER

#include "game/data/cutscenes/sinbad_story_bird_msg/screen.asm"
#include "game/data/cutscenes/sinbad_story_bird_msg/tilesets.asm"
#include "game/data/cutscenes/sinbad_story_bird_msg/anims.asm"

.(
&cutscene_sinbad_story_bird_msg:
.word cutscene_sinbad_story_bird_msg_palette
.word cutscene_sinbad_story_bird_msg_nametable
.word cutscene_sinbad_story_bird_msg_nametable2
.word cutscene_sinbad_story_bird_msg_bg_tileset
.word cutscene_sinbad_story_bird_msg_sprite_tileset
.word cutscene_sinbad_story_bird_msg_logic

CUTSCENE_NB_ANIMATIONS = 4

; Change return address and load a pointer to the first inline parameter
;  A - Size of inline parameters (in bytes)
;
; Output
;  tmpfield1,tmpfield2 - address of the first inline parameter
;
; Overwrites A, X, tmpfield1 to tmpfield5
inline_parameters:
.(
	parameter_addr = tmpfield1
	size = tmpfield3
	caller = tmpfield4
	caller_msb = tmpfield5

	; Save parameter
	sta size

	; Save our own return address
	pla
	sta caller
	pla
	sta caller_msb

	; Get first argument address (from return address)
	pla
	clc
	adc #1
	sta parameter_addr
	pla
	adc #0
	sta parameter_addr+1

	; Push modified return addr, to skip parameters
	lda parameter_addr
	;clc ; useless, previous adc shall not overflow
	dec size
	adc size
	tax
	lda parameter_addr+1
	adc #0
	pha
	txa
	pha

	; Return
	lda caller_msb
	pha
	lda caller
	pha
	rts
.)

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

init_anim:
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

	ldy #3 ; bank
	lda (parameter_addr), y
	sta cutscene_anims_bank, x

	; return
	rts
.)

#define INIT_ANIM(index,anim,bank,direction,pos_x,pos_y,velocity_h,velocity_v) .( :\
	jsr init_anim :\
	.byt index       ; 0 :\
	.word anim       ; 1 :\
	.byt bank        ; 3:\
	.byt direction   ; 4 :\
	.word pos_x      ; 5 :\
	.word pos_y      ; 7 :\
	.word velocity_h ; 9 ;TODO adapt to pal/ntsc using a lookup table and system_index :\
	.word velocity_v ;11 ;TODO adapt to pal/ntsc using a lookup table and system_index :\
.)

anim_velocity:
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
	jsr anim_velocity :\
	.byt index       ; 0:\
	.word velocity_h ; 1 ;TODO adapt to pal/ntsc using a lookup table and system_index :\
	.word velocity_v ; 3 ;TODO adapt to pal/ntsc using a lookup table and system_index :\
.)

clear_anim:
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
	jsr clear_anim :\
	.byt index :\
.)

set_palette:
.(
	parameter_addr = tmpfield1

	; Stack shenaningans to handle parameters being hardcoded after the jsr
	lda #4
	jsr inline_parameters

	;TODO construct a nametable buffer from parameters
	jsr last_nt_buffer

	lda #1
	sta nametable_buffers, x
	lda #$3f
	sta nametable_buffers+1, x
	lda #3
	sta nametable_buffers+3, x

	ldy #0
	lda (parameter_addr), y
	asl
	asl
	clc
	adc #1
	sta nametable_buffers+2, x

	copy_colors:
		iny
		lda (parameter_addr), y
		sta nametable_buffers+4, x
		inx

		cpy #3
		bne copy_colors

	lda #0
	sta nametable_buffers+4, x

	rts
.)

#define SET_PALETTE(index,color1,color2,color3) .( :\
	jsr set_palette :\
	.byt index :\
	.byt color1 :\
	.byt color2 :\
	.byt color3 :\
.)

play_frames:
.(
	extended_byte = tmpfield1
	animation_addr = tmpfield11

	play_frames_loop:
		pha

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
				ldx #0
				stx player_number
				jsr trampoline

				pla
				tax
				pha

				lda #<animation_tick
				sta extra_tmpfield1
				lda #>animation_tick
				sta extra_tmpfield2
				lda cutscene_anims_bank, x
				sta extra_tmpfield3
				lda #CURRENT_BANK_NUMBER
				sta extra_tmpfield4
				jsr trampoline

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
			lda cutscene_autoscroll_h
			clc
			adc scroll_x
			sta scroll_x

			lda cutscene_autoscroll_v
			clc
			adc scroll_y
			sta scroll_y
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

		jsr reset_nt_buffers

		; Loop
		pla
		sec
		sbc #1
		beq end
		jmp play_frames_loop

	end:
	rts
.)

#define PLAY_FRAMES(n) .( :\
	lda #n ;TODO adapt to ntsc/pal :\
	jsr play_frames :\
.)

set_screen:
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
	jsr set_screen :\
	.byt screen_num :\
.)

auto_scroll:
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
	jsr auto_scroll :\
	.byt <h :\
	.byt <v :\
.)

bg_update:
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
	jsr bg_update :\
	.byt >ppu_addr :\
	.byt <ppu_addr :\
	.byt len :\
	.word data :\
.)

cutscene_sinbad_story_bird_msg_logic:
.(
	; Birb going to Sinbad
	INIT_ANIM(0, sinbad_anim_idle, SINBAD_BANK_NUMBER, DIRECTION_RIGHT2, 146, 127, 0, 0) ; index, anim, bank, direction, x, y, velocity_h, velocity_v
	INIT_ANIM(1, cutscene_sinbad_story_bird_msg_anim_bird, cutscene_sinbad_story_bird_msg_bank, DIRECTION_LEFT2, 200, 80, -$0040, $0040) ; index, anim, bank, direction, x, y, velocity_h, velocity_v
	PLAY_FRAMES(220) ; n_frames

	; Showing letter
	CLEAR_ANIM(0)
	CLEAR_ANIM(1)
	SET_PALETTE(0, $21, $27, $37)
	SET_PALETTE(1, $11, $27, $19)
	SET_PALETTE(2, $27, $37, $19)
	SET_PALETTE(3, $27, $37, $11)
	SET_SCREEN(2)
	PLAY_FRAMES(220)

	; Sinbad going to adventure
	INIT_ANIM(0, sinbad_anim_idle, SINBAD_BANK_NUMBER, DIRECTION_RIGHT2, 146, 127, $0100, 0) ; index, anim, bank, direction, x, y, velocity_h, velocity_v
	SET_PALETTE(0, $17, $11, $20)
	SET_PALETTE(1, $17, $21, $20)
	SET_SCREEN(0)
	AUTO_SCROLL(-1, 0)
	PLAY_FRAMES(4)

	AUTO_SCROLL(-2, 0)
	ANIM_VELOCITY(0, $0200, 0)
	PLAY_FRAMES(4)

	AUTO_SCROLL(-3, 0)
	ANIM_VELOCITY(0, $0300, 0)
	PLAY_FRAMES(4)

	AUTO_SCROLL(-4, 0)
	ANIM_VELOCITY(0, $0400, 0)
	lda #%10010100 ; set vertical PPU write increments
	sta ppuctrl_val
	PLAY_FRAMES(2)

	BG_UPDATE($20db, 18, empty_sea)
	PLAY_FRAMES(2)
	BG_UPDATE($20da, 18, empty_sea)
	PLAY_FRAMES(2)
	BG_UPDATE($20d9, 18, empty_sea)
	PLAY_FRAMES(2)
	BG_UPDATE($20d8, 18, empty_sea)
	PLAY_FRAMES(2)
	BG_UPDATE($20d7, 18, empty_sea)
	PLAY_FRAMES(2)
	BG_UPDATE($20d6, 18, empty_sea)
	PLAY_FRAMES(2)
	BG_UPDATE($20d5, 18, empty_sea)
	PLAY_FRAMES(2)
	BG_UPDATE($20d4, 18, empty_sea)
	PLAY_FRAMES(2)
	BG_UPDATE($20d3, 18, empty_sea)
	PLAY_FRAMES(2)
	BG_UPDATE($20d2, 18, empty_sea)
	PLAY_FRAMES(2)
	BG_UPDATE($20d1, 18, empty_sea)
	PLAY_FRAMES(2)
	BG_UPDATE($20d0, 18, empty_sea)
	PLAY_FRAMES(2)
	BG_UPDATE($20cf, 18, empty_sea)
	PLAY_FRAMES(2)
	BG_UPDATE($20ce, 18, empty_sea)
	PLAY_FRAMES(2)
	BG_UPDATE($20cd, 18, empty_sea)
	PLAY_FRAMES(2)
	BG_UPDATE($20cc, 18, empty_sea)
	PLAY_FRAMES(2)

	rts

	empty_sea:
		.byt $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01
.)
.)

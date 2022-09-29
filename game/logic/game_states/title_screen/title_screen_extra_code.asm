TITLE_SCREEN_EXTRA_CODE_BANK_NUMBER = CURRENT_BANK_NUMBER

.(
&init_title_screen_extra:
.(
	; Initialize CHR-RAM
	;TODO to be removed once we successfuly got rid of CHR-BANK
	TRAMPOLINE(init_chr_ram, #CHR_BANK_NUMBER, #CURRENT_BANK_NUMBER)

	; Clear background of nametable 2
	jsr clear_bg_bot_left

	; Construct nt buffers for palettes (to avoid changing it mid-frame)
	lda #<title_screen_palette
	sta tmpfield1
	lda #>title_screen_palette
	sta tmpfield2
	jsr construct_palettes_nt_buffer

	; Copy background from PRG-rom to PPU nametable
	lda #<title_screen_nametable
	sta tmpfield1
	lda #>title_screen_nametable
	sta tmpfield2
	jsr draw_zipped_nametable

	; Place version number's dot
	lda #211           ; Y
	sta oam_mirror
	lda #TILE_TEXT_DOT ; Tile
	sta oam_mirror+1
	lda #$00           ; Attributes
	sta oam_mirror+2
	lda #177           ; X
	sta oam_mirror+3

	; Place NTSC indicator
	lda system_index
	beq ntsc_indicator_done
		lda #208                 ; Y
		sta oam_mirror+4
		lda #TILE_NTSC_INDICATOR ; Tile
		sta oam_mirror+5
		lda #$00                 ; Attributes
		sta oam_mirror+6
		lda #92                  ; X
		sta oam_mirror+7
	ntsc_indicator_done:

	; Reinit cheat code state
	lda #0
	sta title_cheatstate

	; Copy title screen's tileset in CHR-RAM
	jsr set_title_chr

	; Save original music state
	lda audio_music_enabled
	sta title_original_music_state

	; Choose between soft (keep continuity) or hard (reboot) initialization of music and menu animations
	lda previous_global_game_state
	cmp #GAME_STATE_MODE_SELECTION
	beq soft_init

		; Complete reinitialization
		lda #1
		sta title_original_music_state ;NOTE The only case for complete reinitialization is a fresh reset, assume we want music at boot

		jsr init_menu
		jsr init_title_animation
		jsr set_music_track
		jmp end_menu_init

	soft_init:
		; Soft reinitialization - keep continuity with previous menu
		lda #TITLE_ANIMATION_STEP_END
		sta title_animation_state
		jsr re_init_menu

	end_menu_init:

	rts

	; Set the CHR-RAM contents as expected by title screen
	;
	; Overwrites register A, registerY, tmpfield1, tmpfield2, tmpfield3
	;
	; Shall only be called while PPU rendering is turned off
	set_title_chr:
	.(
		tileset_addr = tmpfield1 ; Not movable, used by cpu_to_ppu_copy_tileset_background
		;tileset_addr_msb = tmpfield2 ; Not movable, used by cpu_to_ppu_copy_tileset_background

		lda #<tileset_logo
		sta tileset_addr
		lda #>tileset_logo
		sta tileset_addr+1
		jsr cpu_to_ppu_copy_tileset_background

		; Copy alphanum charset
		.(
			ppu_addr = $1dc0

			; Charset parameters
			lda #<charset_alphanum
			sta tmpfield3
			lda #>charset_alphanum
			sta tmpfield4
			ldx #%00000100 ; colors - ....ffbb

			; PPU position
			lda PPUSTATUS
			lda #>ppu_addr
			sta PPUADDR
			lda #<ppu_addr
			sta PPUADDR

			; Trampoline parameters
			lda #<cpu_to_ppu_copy_charset
			sta extra_tmpfield1
			lda #>cpu_to_ppu_copy_charset
			sta extra_tmpfield2
			lda #CHARSET_ALPHANUM_BANK_NUMBER
			sta extra_tmpfield3
			lda #CURRENT_BANK_NUMBER
			sta extra_tmpfield4

			; Call
			jmp trampoline
			;No return, jump to subroutine
		.)

		;rts ; useless, jump to subroutine
	.)

	init_title_animation:
	.(
		; Mute music
		jsr audio_mute_music

		; Clear animation state
		lda #0
		sta title_animation_frame
		sta title_animation_state

		; Set palette for hidden text and logo
		lda #<initial_palette
		sta tmpfield1
		lda #>initial_palette
		sta tmpfield2
		jsr construct_palettes_nt_buffer

		; Hide logo
		lda PPUSTATUS
		lda #$23
		sta PPUADDR
		lda #$c0
		sta PPUADDR

		ldx #40
		lda #%11111111
		set_attr_byte:
			sta PPUDATA
			dex
			bne set_attr_byte

		rts

		initial_palette:
		; Background
		.byt $21,$0f,$21,$30, $21,$24,$24,$24, $21,$00,$00,$00, $21,$21,$21,$21 ; 0 - logo, 1 - logo special,2 - unused, 3 - text
		; Sprites
		.byt $21,$21,$21,$00, $21,$00,$00,$00, $21,$00,$00,$00, $21,$0f,$00,$31 ; 0 - text, 1,2 - unused, 3 - cloud
	.)
.)

&title_screen_tick_extra:
.(
	.(
		; Play title screen animation
		jsr tick_title_animation

		; Play common menus effects
		jsr tick_menu

		; Check for cheat code (controller A only)
		ldx title_cheatstate
		lda controller_a_btns
		cmp controller_a_last_frame_btns
		beq press_any_key
		cmp cheatcode, x
		beq update_cheatcode
		jmp press_any_key

		update_cheatcode:
			cpx #19
			beq cheat_succeed
			inx
			txa
			sta title_cheatstate
			jmp end

			cheat_succeed:
				jsr default_config
				lda #2
				sta config_ticks_per_frame
				lda #3
				sta config_ai_level
				lda #GAME_STATE_INGAME
				jsr change_global_game_state

		; If all buttons of any controller are released on this frame, got to the next screen
		press_any_key:
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
				jsr title_screen_restore_music_state
				lda #GAME_STATE_MODE_SELECTION
				jsr change_global_game_state

		end:
			rts
	.)

	cheatcode:
		.byt CONTROLLER_BTN_UP, 0, CONTROLLER_BTN_UP, 0, CONTROLLER_BTN_DOWN, 0, CONTROLLER_BTN_DOWN, 0
		.byt CONTROLLER_BTN_LEFT, 0, CONTROLLER_BTN_RIGHT, 0, CONTROLLER_BTN_LEFT, 0, CONTROLLER_BTN_RIGHT, 0
		.byt CONTROLLER_BTN_B, 0, CONTROLLER_BTN_A, 0

	tick_title_animation:
	.(
		inc title_animation_frame

		ldx title_animation_state
		lda anim_state_handlers_lsb, x
		sta tmpfield1
		lda anim_state_handlers_msb, x
		sta tmpfield2
		jsr call_pointed_subroutine

		rts

		anim_state_handlers_lsb:
		.byt <hide_subtitle
		.byt <wait_logo, <wait
		.byt <show_super_1, <show_super_2, <shake, <wait
		.byt <show_tilt_1, <show_tilt_2, <shake, <wait
		.byt <show_bro_1, <show_bro_2, <shake, <wait
		.byt <subtitle_sfx, <show_subtitle, <wait
		.byt <play_music, <show_text
		.byt <dummy_routine
		anim_state_handlers_msb:
		.byt >hide_subtitle
		.byt >wait_logo, >wait
		.byt >show_super_1, >show_super_2, >shake, >wait
		.byt >show_tilt_1, >show_tilt_2, >shake, >wait
		.byt >show_bro_1, >show_bro_2, >shake, >wait
		.byt >subtitle_sfx, >show_subtitle, >wait
		.byt >play_music, >show_text
		.byt >dummy_routine

		time_begin:
		.byt 25, 30
		time_logo_parts:
		.byt 10, 12
		time_subtitle:
		.byt 5, 6
		time_text:
		.byt 10, 12

		+TITLE_ANIMATION_STEP_END = anim_state_handlers_msb-anim_state_handlers_lsb-1

		change_anim_state:
		.(
			inc title_animation_state
			lda #0
			sta title_animation_frame
			rts
		.)

		wait:
		.(
			lda title_animation_frame
			cmp title_wait_time
			bne end
				jsr change_anim_state
			end:
			rts
		.)

		hide_subtitle:
		.(
			lda #<subtitle_nt_buffer
			ldy #>subtitle_nt_buffer
			jsr push_nt_buffer

			jmp change_anim_state
			;rts

			subtitle_nt_buffer:
				.byt $22, $2c, 7, $00, $00, $00, $00, $00, $00, $00
		.)

		wait_logo:
		.(
			ldx system_index
			lda time_begin, x
			sta title_wait_time
			jmp change_anim_state
			;rts
		.)

		; Set contiguous attributes to the same value
		;  register A - attribute value
		;  register X - number of attibutes to change
		;  register Y - address of first attribute to set (LSB)
		set_attr:
		.(
			; Construct buffer
			sty title_buffer+1
			ldy #$23
			sty title_buffer+0
			stx title_buffer+2
			set_one_byte:
				sta title_buffer+2, x
				dex
				bne set_one_byte

			; Push buffer
			lda #<title_buffer
			ldy #>title_buffer
			jmp push_nt_buffer

			;rts ; useless, jump to subroutine
		.)

		; Set attributes of the "Super" part of the title
		;  register A - attribute value, set every two bits (ex. %01010101 to set attribute to palette 1)
		;
		; Overwrites all registers
		set_super_attr:
		.(
			; Upper part
			pha
			ldx #14
			ldy #$c1
			jsr set_attr

			; Lower part
			pla
			ora #%11110000
			ldx #6
			ldy #$d1
			jmp set_attr

			;rts ; useless, jump to subroutine
		.)

		show_super_1:
		.(
			; Change attributes to show part the logo
			lda #%01010101
			jsr set_super_attr

			; Play apparition sound
			jsr audio_play_death ;TODO sound crafted for this purpose

			; Go to next anim state
			jmp change_anim_state

			;rts
		.)

		show_super_2:
		.(
			; Change attributes to show part the logo
			lda #%00000000
			jsr set_super_attr

			; Initialize screen shake
			lda #4
			sta screen_shake_counter
			lda #3
			sta screen_shake_nextval_x
			lda #$fa
			sta screen_shake_nextval_y

			; Set wait timer
			ldx system_index
			lda time_logo_parts, x
			sta title_wait_time

			; Go to next anim state
			jsr change_anim_state

			rts
		.)

		show_tilt_1:
		.(
			; Change attributes to show part the logo
			lda #%01010000
			ldx #4
			ldy #$d0
			jsr set_attr

			lda #%01010101
			ldx #4
			ldy #$d8
			jsr set_attr

			lda #%01010101
			ldx #4
			ldy #$e0
			jsr set_attr

			; Play apparition sound
			jsr audio_play_death ;TODO sound crafted for this purpose

			; Go to next anim state
			jmp change_anim_state

			;rts
		.)

		show_tilt_2:
		.(
			; Change attributes to show part the logo
			lda #%00000000
			ldx #4
			ldy #$d0
			jsr set_attr

			lda #%00000000
			ldx #4
			ldy #$d8
			jsr set_attr

			lda #%00000000
			ldx #4
			ldy #$e0
			jsr set_attr

			; Initialize screen shake
			lda #4
			sta screen_shake_counter
			lda #3
			sta screen_shake_nextval_x
			lda #$fa
			sta screen_shake_nextval_y

			; Set wait timer
			ldx system_index
			lda time_logo_parts, x
			sta title_wait_time

			; Go to next anim state
			jsr change_anim_state

			rts
		.)

		show_bro_1:
		.(
			; Change attributes to show part the logo
			lda #%01010000
			ldx #4
			ldy #$d4
			jsr set_attr

			lda #%01010101
			ldx #4
			ldy #$dc
			jsr set_attr

			lda #%01010101
			ldx #4
			ldy #$e4
			jsr set_attr

			; Play apparition sound
			jsr audio_play_death ;TODO sound crafted for this purpose

			; Go to next anim state
			jmp change_anim_state

			;rts
		.)

		show_bro_2:
		.(
			; Change attributes to show part the logo
			lda #%00000000
			ldx #4
			ldy #$d4
			jsr set_attr

			lda #%00000000
			ldx #4
			ldy #$dc
			jsr set_attr

			lda #%00000000
			ldx #4
			ldy #$e4
			jsr set_attr

			; Initialize screen shake
			lda #4
			sta screen_shake_counter
			lda #3
			sta screen_shake_nextval_x
			lda #$fa
			sta screen_shake_nextval_y

			; Set wait timer
			ldx system_index
			lda time_subtitle, x
			sta title_wait_time

			; Go to next anim state
			jsr change_anim_state

			rts
		.)

		shake:
		.(
			jsr shake_screen

			lda screen_shake_counter
			bne end

				jsr change_anim_state

			end:
			rts
		.)

		subtitle_sfx:
		.(
			jsr audio_play_title_screen_subtitle
			jmp change_anim_state
			;rts
		.)

		show_subtitle:
		.(
			; Write subtitle on screen, two chars per frame
			lda #2
			pha

			write_one_char:
				lda title_animation_frame
				tax
				dex
				txa
				asl
				asl

				clc
				adc #<subtitle_nt_buffer_1
				pha
				lda #0
				adc #>subtitle_nt_buffer_1
				tay
				pla

				jsr push_nt_buffer

				lda title_animation_frame
				cmp #7
				bne next_char
					; Set wait timer
					ldx system_index
					lda time_text, x
					sta title_wait_time

					; Clear stack
					pla

					; Next state
					jmp change_anim_state
					; No return, jump to subroutine

				next_char:
				pla
				tay
				dey
				beq end
					tya
					pha

					inc title_animation_frame
					jmp write_one_char

			end:
			rts

			subtitle_nt_buffer_1:
				.byt $22, $2c, 1, TILE_CHAR_F
			subtitle_nt_buffer_2:
				.byt $22, $2d, 1, TILE_CHAR_O
			subtitle_nt_buffer_3:
				.byt $22, $2e, 1, TILE_CHAR_R
			subtitle_nt_buffer_4:
				.byt $22, $2f, 1, $00
			subtitle_nt_buffer_5:
				.byt $22, $30, 1, TILE_CHAR_N
			subtitle_nt_buffer_6:
				.byt $22, $31, 1, TILE_CHAR_E
			subtitle_nt_buffer_7:
				.byt $22, $32, 1, TILE_CHAR_S
		.)

		play_music:
		.(
			jsr set_music_track
			jsr title_screen_restore_music_state
			jmp change_anim_state
			;rts
		.)

		show_text:
		.(
			; Get color counter in Y
			lda title_animation_frame
			lsr
			tay

			; Select if we finished or have a color to set
			cpy #3
			beq finish

				; Change text color
				LAST_NT_BUFFER
				lda #1
				sta nametable_buffers, x
				inx
				lda #$3f
				sta nametable_buffers, x
				inx
				lda #$0d
				sta nametable_buffers, x
				inx
				lda #1
				sta nametable_buffers, x
				inx
				lda text_colors, y
				sta nametable_buffers, x
				inx
				lda #1
				sta nametable_buffers, x
				inx
				lda #$3f
				sta nametable_buffers, x
				inx
				lda #$11
				sta nametable_buffers, x
				inx
				lda #1
				sta nametable_buffers, x
				inx
				lda text_colors, y
				sta nametable_buffers, x
				inx
				lda #0
				sta nametable_buffers, x
				stx nt_buffers_end

				jmp end

			finish:
				; Finish by going to the next state
				jsr change_anim_state

			end:
			rts

			text_colors:
				.byt $24, $17, $0f
		.)
	.)
.)

title_screen_restore_music_state:
.(
	lda title_original_music_state
	beq mute

		jsr audio_unmute_music
		jmp end

	mute:
		jsr audio_mute_music

	end:
	rts
.)

set_music_track:
.(
	lda #<audio_music_weak
	sta extra_tmpfield1
	lda #>audio_music_weak
	sta extra_tmpfield2
	lda #CURRENT_BANK_NUMBER
	sta extra_tmpfield3
	;lda #CURRENT_BANK_NUMBER ; useless, already loaded value
	sta extra_tmpfield4
	jmp trampoline
	;rts ; useless, jump to subroutine
.)
.)

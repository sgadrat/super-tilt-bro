TITLE_SCREEN_EXTRA_CODE_BANK_NUMBER = CURRENT_BANK_NUMBER

.(
TITLE_ANIMATION_STEP_END = 5

&init_title_screen_extra:
.(
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
		lda #100                 ; X
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
	cmp #GAME_STATE_CREDITS
	beq soft_init

		; Complete reinitialization
		jsr init_menu
		jsr init_title_animation
		jsr set_music_track ; Note that it is important even if silenced, we dont want to risk unmuting without any music selected
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

		; Hide logo and text
		lda #<initial_palette
		sta tmpfield1
		lda #>initial_palette
		sta tmpfield2
		jsr construct_palettes_nt_buffer

		rts

		initial_palette:
		; Background
		.byt $21,$21,$21,$21, $21,$0f,$20,$00, $21,$20,$0f,$00, $21,$21,$21,$21, ; 0 - logo, 1 - credits title, 2 - credits section, 3 - text and number with same colors
		; Sprites
		.byt $21,$21,$21,$00, $21,$00,$00,$00, $21,$00,$00,$00, $21,$0f,$00,$31 ; 0 - text, 1,2 - unused, 3 - cloud
	.)
.)

&title_screen_tick_extra:
.(
	.(
		jsr reset_nt_buffers

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
		.byt <wait_logo, <show_logo, <shake, <wait_text, <show_text, <dummy_routine
		anim_state_handlers_msb:
		.byt >wait_logo, >show_logo, >shake, >wait_text, >show_text, >dummy_routine

#if anim_state_handlers_msb-anim_state_handlers_lsb <> TITLE_ANIMATION_STEP_END+1
#error TITLE_ANIMATION_STEP_END constant is out of sync with actual steps
#endif

		change_anim_state:
		.(
			inc title_animation_state
			lda #0
			sta title_animation_frame
			rts
		.)

		wait_logo:
		.(
			lda title_animation_frame
			cmp #25
			bne end

				jsr change_anim_state

			end:
			rts
		.)

		show_logo:
		.(
			; Change palette to show the logo
			jsr last_nt_buffer
			ldy #0
			copy_one_byte:
				lda logo_palette_nt_buffer, y
				sta nametable_buffers, x

				inx
				iny
				cpy #8
				bne copy_one_byte

			; Play apparition sound
			jsr audio_play_death ;TODO sound crafted for this purpose

			; Initialize sceen shake
			lda #4
			sta screen_shake_counter
			lda #3
			sta screen_shake_nextval_x
			lda #$fa
			sta screen_shake_nextval_y

			; Go to next anim state
			jsr change_anim_state

			rts

			logo_palette_nt_buffer:
				.byt $01, $3f, $01, $03, $0f, $21, $30, $00 ; Continuation byte, PPU addr MSB, PPU addr LSB, data size, data..., end byte
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

		wait_text:
		.(
			lda title_animation_frame
			cmp #20
			bne end

				jsr audio_play_title_screen_text
				jsr change_anim_state

			end:
			rts
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
				jsr last_nt_buffer
				lda #1
				sta nametable_buffers, x
				sta nametable_buffers+5, x
				lda #$3f
				sta nametable_buffers+1, x
				sta nametable_buffers+6, x
				lda #$0d
				sta nametable_buffers+2, x
				lda #$11
				sta nametable_buffers+7, x
				lda #1
				sta nametable_buffers+3, x
				sta nametable_buffers+8, x
				lda text_colors, y
				sta nametable_buffers+4, x
				sta nametable_buffers+9, x
				lda #0
				sta nametable_buffers+10, x

				jmp end

			finish:
				; Finish by finally enabling music and going to next state
				jsr set_music_track
				jsr title_screen_restore_music_state
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

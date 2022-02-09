cursed:
.(
	; Do nothing, still reserve 3 bytes, so it can be changed by a JMP to do soimething without changing address
	rti
	nop
	nop
.)

nmi:
.(
	; Save CPU registers
	php
	pha
	txa
	pha
	tya
	pha

	; Do not draw anything if not ready
	lda nmi_processing
	beq end

	; reload PPU OAM (Objects Attributes Memory) with fresh data from cpu memory
	lda #$00
	sta OAMADDR
	lda #$02
	sta OAMDMA

	; Rewrite nametable based on nt_buffers
	jsr process_nt_buffers

	; Scroll
	lda ppuctrl_val
	sta PPUCTRL
	lda PPUSTATUS
	lda scroll_x
	sta PPUSCROLL
	lda scroll_y
	sta PPUSCROLL

	; Inform that NMI is handled
	lda #$00
	sta nmi_processing

	end:

	; Restore CPU registers
	pla
	tay
	pla
	tax
	pla
	plp

	rti
.)

reset:
.(
	; First wait for vblank to make sure PPU is ready
	jsr wait_vbi

	; Ensure memory is zero-ed, we have to burn cycles anyway, waiting for the PPU
	ldx #0
	clrmem:
		lda #$00
		sta $0000, x
		sta $0100, x
		sta $0300, x
		sta $0400, x
		sta $0500, x
		sta $0600, x
		sta $0700, x
		lda #$fe
		sta oam_mirror, x    ;move all sprites off screen
		inx
		bne clrmem

	; Wait a second vblank
	;  PPU may need 2 frames to warm-up
	;  We use it to count cycles between frames (strong indicator of PAL versus NTSC)
	.(
		ldy #0
		ldx #0
		vblankwait2:
			inx
			bne ok
				iny
			ok:
			bit PPUSTATUS
			bpl vblankwait2

		; Y*256+X known values:
		;  $05b1 - FCEUX on NTSC mode
		;  $05b1 - Mesen on NTSC mode
		;  $05b1 - NTSC NES
		;
		;  $06d2 - FCEUX on PAL mode (bug? $06c9 when running on RAINBOW mapper)
		;  $06d2 - Mesen on PAL mode
		;  $06d2 - PAL NES
		;
		;  $078b - FCEUX on Dendy mode
		;  $078b - Mesen on Dendy mode
		;
		;TODO re-do measures, they predate the use of a subroutine to wait for first vblank
		cpy #$06
		bcs pal
			lda #1
			sta system_index
		pal:
	.)

	; Prepare to start the game
	lda #0
	sta audio_vframe_cnt
	jsr audio_init
	jsr global_init

	lda #INITIAL_GAME_STATE
	jsr change_global_game_state
	;rts ; useless, Fallthrough to forever (and actually change_global_game_state does not return)
.)

forever:
.(
	; Keep game's pace under control
	jsr wait_next_frame
	lda config_ticks_per_frame
	sta current_frame_tick

	; Update game state
	tick_state:
		; Call common routines to all states
		jsr audio_music_tick
		jsr fetch_controllers

		; Tick current game state
		lda global_game_state
		asl
		tax
		lda game_states_tick, x
		sta tmpfield1
		lda game_states_tick+1, x
		sta tmpfield2
		jsr call_pointed_subroutine

		; Call audio a second time if necessary to emulate 60Hz system
		jsr audio_music_extra_tick

		; Loop if there is multi-tick per frames
		dec current_frame_tick
		bne tick_state

	jmp forever
.)

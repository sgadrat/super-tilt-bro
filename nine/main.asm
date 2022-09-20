cursed:
.(
	; Do nothing, still reserve 3 bytes, so it can be changed by a JMP to do something without changing address
	rti
	nop
	nop
.)

nmi:
.(
	; Save CPU registers
	;  13 cycles
	pha
	txa
	pha
	tya
	pha

#if NMI_DRAW <> 0
#error code below expects NMI_DRAW to be zero
#endif

	; Do not draw anything if not ready
	;  5 cycles (18)
	lda nmi_processing
	bne special_processing

		; Reload PPU OAM (Objects Attributes Memory) with fresh data from cpu memory
		;  10 cycles (28)
		;lda #$00 ; Useless, ensured by BNE above
		sta OAMADDR
		lda #$02
		sta OAMDMA

		; 514 cycles of DMA (542)

		; Rewrite nametable based on nt_buffers
		;  6 cycles (548)
		jsr process_nt_buffers

		; Scroll
		;  3 + 4 + 4 + 3 + 4 + 3 + 4 = 25 cycles (573)
		lda ppuctrl_val
		sta PPUCTRL
		lda PPUSTATUS
		lda scroll_x
		sta PPUSCROLL
		lda scroll_y
		sta PPUSCROLL

		; NOTE from there, it is no more critical to be in v-blank

		; Inform that NMI is handled
		lda #NMI_SKIP
		sta nmi_processing

		; Return right now
		;  Inlined here instead at the natural end of routine, because drawing things on screen is the "normal"
		;  behavior, and the only one in wich the game tend to be in a performance-critical state
		end:
			pla
			tay
			pla
			tax
			pla

			rti

	special_processing:
	cmp #NMI_AUDIO
	beq nmi_tick_music
	jmp end

	nmi_tick_music:
	.(
		; Save tmpfield that can be modified by audio engine
		ldx #0
		save_one_couple:
			lda tmpfield1, x
			pha
			lda extra_tmpfield1, x
			pha
			inx
			cpx #5
			bne save_one_couple

		; Call audio engine, restoring current bank after
		lda current_bank
		pha
		jsr audio_music_extra_tick
		jsr audio_music_tick
		pla
		jsr switch_bank

		; Restore (extra_)tmpfields
		ldx #4
		restore_one_couple:
			pla
			sta extra_tmpfield1, x
			pla
			sta tmpfield1, x
			dex
			bpl restore_one_couple

		jmp end
	.)
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

	; Init NT buffers state
	jsr clear_nt_buffers

	; Prepare to start the game
	lda #0
	sta audio_vframe_cnt
	jsr audio_init
	jsr global_init

	lda #GAME_STATE_UNKNOWN
	sta global_game_state
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
		;TODO optimizable split game_states_tick is msb/lsb tables to avoid the asl
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

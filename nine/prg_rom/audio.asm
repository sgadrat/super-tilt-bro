audio_init:
.(
	jsr audio_mute_music
	lda #%00001111 ; ---DNT21
	STA APU_STATUS

	; Fallthrough to audio_cut_sfx
.)

audio_cut_sfx:
.(
	lda #$ff
	sta audio_fx_noise_current_opcode_bank

	rts
.)

; Play a sound effect
;  register Y - first opcode address lsb
;  register X - first opcode address msb
;  register A - effect bank
;
;  Overwrites register A
audio_play_sfx:
.(
	sty audio_fx_noise_current_opcode
	stx audio_fx_noise_current_opcode_msb
	sta audio_fx_noise_current_opcode_bank

	lda #0
	sta audio_fx_noise_wait_cnt
	sta audio_fx_noise_pitch_slide

	lda #%01000000
	sta audio_fx_noise_apu_period_byte
	lda #%00111111
	sta audio_fx_noise_apu_envelope_byte

	rts
.)

; Play a track
;  register Y - track info address lsb
;  register X - track info address msb
;  register A - track bank
;
;  Overwrites all registers, tmpfield1 to tmpfield4
audio_play_music:
.(
	; Set current track
	sty audio_current_track_lsb
	stx audio_current_track_msb
	sta audio_current_track_bank

	jsr switch_bank

	; Store native tempo in zeropage
	ldy #MUSIC_HEADER_TEMPO
	lda (audio_current_track_lsb), y
	sta audio_50hz

	; Init pulse channels
	ldx #0
	jsr init_channel

	ldx #1
	jsr init_channel

	; Init triangle channel
	lda #5 ; default note duration ;TODO get it from music header
	sta audio_triangle_default_note_duration

	lda #0
	sta audio_triangle_apu_timer_low_byte
	sta audio_triangle_apu_timer_high_byte
	sta audio_triangle_pitch_slide_lsb
	sta audio_triangle_pitch_slide_msb
	;lda #%10000000 ; CRRR RRRR  ; useless, channel is soft-silenced by init_channel, so next tick will mute it (even if first opcode is a WAIT)
	;sta APU_TRIANGLE_LINEAR_CNT ;

	ldx #2
	jsr init_channel

	; Init noise channel
	lda #%01000000
	sta audio_noise_apu_period_byte
	lda #%00111111
	sta audio_noise_apu_envelope_byte

	lda #%00001000
	sta APU_NOISE_LENGTH_CNT

	ldx #3
	jsr init_channel

	rts

	init_channel:
	.(
		; Set current sample
		lda #0
		sta audio_square1_sample_num, x

		; Remove any wait
		;lda #0 ; useless, done above
		sta audio_square1_wait_cnt, x

		; Set default pulse parameters
		cpx #2
		bcs end_pulse_specifics

			lda #5 ; default note duration ;TODO get it from music header
			sta audio_square1_default_note_duration, x

			lda #%00111111 ; DDLC VVVV - APU mirror
			sta audio_square1_apu_envelope_byte, x

			lda #%00001000 ; EPPP NSSS - direct write to APU
			.(
				cpx #0
				bne pulse_2
					sta APU_SQUARE1_SWEEP
					jmp ok
				pulse_2:
					sta APU_SQUARE2_SWEEP
				ok:
			.)

			; Remove any slide
			lda #0
			sta audio_square1_pitch_slide_lsb, x
			sta audio_square1_pitch_slide_msb, x

			; Soft-silence channel
			;lda #0 ; useless, done above
			sta audio_square1_apu_timer_low_byte, x
			sta audio_square1_apu_timer_high_byte, x

		end_pulse_specifics:

		; Set current opcode
		;TODO factorize with SAMPLE_END handling
#if \
	(MUSIC_HEADER_PULSE2_TRACK_OFFSET <> (MUSIC_HEADER_PULSE1_TRACK_OFFSET + 2)) || \
	(MUSIC_HEADER_TRIANGLE_TRACK_OFFSET <>  (MUSIC_HEADER_PULSE2_TRACK_OFFSET + 2)) || \
	(MUSIC_HEADER_NOISE_TRACK_OFFSET <>  (MUSIC_HEADER_TRIANGLE_TRACK_OFFSET + 2))
#error code below expects channels track offset in a specific order
#endif
		tmp_addr = tmpfield1
		tmp_addr_msb = tmpfield2

		txa ; Y = pulse1_track_offset + 2 * X = channel's samples list address' offset in music header
		asl
		clc
		adc #MUSIC_HEADER_PULSE1_TRACK_OFFSET
		tay

		lda (audio_current_track_lsb), y ; tmp_addr = channel's samples list address
		sta tmp_addr
		iny
		lda (audio_current_track_lsb), y
		sta tmp_addr_msb

		ldy #0 ; current opcode address = first sample's value
		lda (tmp_addr), y
		sta audio_square1_current_opcode, x
		iny
		lda (tmp_addr), y
		sta audio_square1_current_opcode_msb, x

		rts
	.)
.)

; Silence any music being played
;
;  Overwrites register A
audio_mute_music:
.(
	; Avoid any futher music tick
	lda #0
	sta audio_music_enabled

	; Silence square channels
	;lda #0 ; useless, set above
	sta APU_SQUARE1_TIMER_LOW
	sta APU_SQUARE1_LENGTH_CNT
	sta APU_SQUARE2_TIMER_LOW
	sta APU_SQUARE2_LENGTH_CNT

	; Silence triangle channel
	lda #%10000000
	sta APU_TRIANGLE_LINEAR_CNT

	; Silence noise channel
	lda #%00110000
	sta APU_NOISE_ENVELOPE

	rts
.)

; Restore playing music
;
;  Overwrites register A
audio_unmute_music:
.(
	; Reactivate ticks
	lda #1
	sta audio_music_enabled

	; Rewrite pulse registers as conditionals at tick's end may only partially update them
	ldx #1
	ldy #4
	square_reinit_loop:
		lda audio_square1_apu_envelope_byte, x
		sta APU_SQUARE1_ENVELOPE, y
		lda audio_square1_apu_timer_low_byte, x
		sta APU_SQUARE1_TIMER_LOW, y
		lda audio_square1_apu_timer_high_byte, x
		sta APU_SQUARE1_LENGTH_CNT, y

		dey
		dey
		dey
		dey
		dex
		bpl square_reinit_loop

	rts
.)

; Play a tick when two ticks are needed in one frame to play at normal speed
;
; Overwrites all registers, and tmpfield1 to tmpfield4
audio_music_extra_tick:
.(
	lda system_index
	bne ok ; skip if playing on NTSC system
	lda audio_50hz
	bne ok ; skip if music is PAL native
	dec audio_vframe_cnt
	bpl ok ; skip if it is not time to do an extra tick

			lda #4
			sta audio_vframe_cnt
			jmp audio_music_tick

	ok:
	rts
.)

; Play one tick of the audio engine
;
; Overwrites all registers, and tmpfield1 to tmpfield4
audio_music_tick:
.(
	apu_timer_high_byte = extra_tmpfield1
	apu_timer_low_byte = extra_tmpfield2
	current_opcode = extra_tmpfield3
	current_opcode_msb = extra_tmpfield4
	channel_number = extra_tmpfield5

	.(
		SWITCH_BANK(audio_current_track_bank)

		; Play music
		lda audio_music_enabled
		beq music_ok
			ldx #0
			jsr pulse_tick
			ldx #1
			jsr pulse_tick
			ldx #2
			jsr pulse_tick ; Triangle opcodes are compatible with pulse opcodes, just use pulse_tick
			jsr noise_tick
		music_ok:

		; Play sfx
		lda audio_fx_noise_current_opcode_bank
		bmi apply_music
			play_sfx:
				; SFX is active, play it to overwrite music
				jsr switch_bank
				jsr noise_fx_tick
				rts
			apply_music:
				; SFX is not active, apply register modifications made by the music
				lda audio_music_enabled
				beq sfx_ok
					jmp noise_apply_mirrored_apu
					; no return, jump to subroutine
		sfx_ok:
		; NOTE some branches don't reach the end

		rts
	.)

	noise_fx_tick:
	.(
		; Save music state
		lda audio_noise_pitch_slide : pha
		lda audio_noise_wait_cnt : pha
		lda audio_noise_current_opcode : pha
		lda audio_noise_current_opcode_msb : pha
		lda audio_noise_apu_envelope_byte : pha
		lda audio_noise_apu_period_byte : pha

		; Place sound effect state
		lda audio_fx_noise_pitch_slide : sta audio_noise_pitch_slide
		lda audio_fx_noise_wait_cnt : sta audio_noise_wait_cnt
		lda audio_fx_noise_current_opcode : sta audio_noise_current_opcode
		lda audio_fx_noise_current_opcode_msb : sta audio_noise_current_opcode_msb
		lda audio_fx_noise_apu_envelope_byte : sta audio_noise_apu_envelope_byte
		lda audio_fx_noise_apu_period_byte : sta audio_noise_apu_period_byte

		; Tick channel
		jsr noise_tick
		jsr noise_apply_mirrored_apu

		; Save new sound effect state
		lda audio_noise_pitch_slide : sta audio_fx_noise_pitch_slide
		lda audio_noise_wait_cnt : sta audio_fx_noise_wait_cnt
		lda audio_noise_current_opcode : sta audio_fx_noise_current_opcode
		lda audio_noise_current_opcode_msb : sta audio_fx_noise_current_opcode_msb
		lda audio_noise_apu_envelope_byte : sta audio_fx_noise_apu_envelope_byte
		lda audio_noise_apu_period_byte : sta audio_fx_noise_apu_period_byte

		; Restore music state
		pla : sta audio_noise_apu_period_byte
		pla : sta audio_noise_apu_envelope_byte
		pla : sta audio_noise_current_opcode_msb
		pla : sta audio_noise_current_opcode
		pla : sta audio_noise_wait_cnt
		pla : sta audio_noise_pitch_slide

		rts
	.)

	noise_tick:
	.(
		tmp_addr = tmpfield1
		tmp_addr_msb = tmpfield2

		; Pitch slide (add pitch slide value to frequency)
		lda audio_noise_apu_period_byte
		and #%00001111
		clc
		adc audio_noise_pitch_slide
		cmp #%00010000
		bcs overflow

			; No overflow, just store result (keeping original periodic and engine flags)
			.(
				sta tmpfield1
				lda audio_noise_apu_period_byte
				and #%11110000
				ora tmpfield1
				sta audio_noise_apu_period_byte
			.)

			jmp end_effects

		overflow:

			; Overflow, cap value to zero if slide is negative or $f is slide is positive
			.(
				lda audio_noise_pitch_slide
				bmi negative
					lda #%00001111
					ora audio_noise_apu_period_byte
					jmp store_result
				negative:
					lda #%11110000
					and audio_noise_apu_period_byte
				store_result:
				sta audio_noise_apu_period_byte
			.)

		end_effects:

		; Execute opcodes only if not in wait mode
		lda audio_noise_wait_cnt
		bne end_opcodes_execution

			; Execute opcodes until one activates wait mode
			execute_current_opcode:
				; Mirror opcode address in zero-page, to be usable in indirect addressing
				lda audio_noise_current_opcode
				sta current_opcode
				lda audio_noise_current_opcode_msb
				sta current_opcode_msb

				; Decode opcode
				ldy #0
				lda (current_opcode), y
				lsr
				lsr
				lsr
				lsr

				; Call opcode's routine
				;  Note - subroutines are ensured to be called with Y=0, and A containing the opcode byte
				tax

				lda noise_opcode_routines_lsb, x
				sta tmp_addr
				lda noise_opcode_routines_msb, x
				sta tmp_addr_msb
				lda (current_opcode), y
				jsr call_pointed_subroutine

				; Point to next opcode
				clc
				adc audio_noise_current_opcode
				sta audio_noise_current_opcode
				lda #0
				adc audio_noise_current_opcode_msb
				sta audio_noise_current_opcode_msb

				; Loop until we are in wait mode
				lda audio_noise_wait_cnt
				beq execute_current_opcode

		end_opcodes_execution:

		; Tick wait counter
		dec audio_noise_wait_cnt

		rts
	.)

	noise_apply_mirrored_apu:
	.(
		; Write mirrored APU registers, or silence the channel if silence flag is set
		bit audio_noise_apu_period_byte
		bvc regular_write
			lda #%00110000
			sta APU_NOISE_ENVELOPE
			jmp end_write_apu
		regular_write:
			lda audio_noise_apu_envelope_byte
			sta APU_NOISE_ENVELOPE
			lda audio_noise_apu_period_byte
			sta APU_NOISE_PERIOD
			lda #%00001000
			sta APU_NOISE_LENGTH_CNT
		end_write_apu:

		rts
	.)

	pulse_tick:
	.(
		tmp_addr = tmpfield1
		tmp_addr_msb = tmpfield2

		; Execute effects if not silenced (because silence is timer=0 while pitch-slide affects timer, thus unsilencing)
		lda audio_square1_apu_timer_low_byte, x
		bne do_effects
		lda audio_square1_apu_timer_high_byte, x
		and #%00000111
		beq end_effects
		do_effects:

			; Pitch slide (add pitch slide value to frequency)
			lda audio_square1_apu_timer_low_byte, x ; Add low bytes (straightforward)
			clc
			adc audio_square1_pitch_slide_lsb, x
			sta audio_square1_apu_timer_low_byte, x

			lda audio_square1_apu_timer_high_byte, x ; Add High bytes (need to byte extend current frequency sign bit)
			tay
			and #%00000100
			bne negative
				positive:
					tya
					and #%00000111
					jmp end_byte_extend
				negative:
					tya
					ora #%11111000
			end_byte_extend:

			adc audio_square1_pitch_slide_msb, x
			ora #%11111000 ; TODO long value for "length counter load" (see other similar comments)
			sta audio_square1_apu_timer_high_byte, x

		end_effects:

		; Save X to a reserved memory location
		txa
		sta channel_number

		; Execute opcodes only if not in wait mode
		lda audio_square1_wait_cnt, x
		bne end_opcodes_execution

			; Execute opcodes until one activates wait mode
			execute_current_opcode:
				; Mirror opcode address in zero-page, to be usable in indirect addressing
				lda audio_square1_current_opcode, x
				sta current_opcode
				lda audio_square1_current_opcode_msb, x
				sta current_opcode_msb

				; Decode opcode
				ldy #0
				lda (current_opcode), y
				lsr
				lsr
				lsr

				; Call opcode's routine
				;  Note - subroutines are ensured to be called wit Y=0, A containing the opcode byte, and X=channel_number
				tax

				lda pulse1_opcode_routines_lsb, x
				sta tmp_addr
				lda pulse1_opcode_routines_msb, x
				sta tmp_addr_msb
				ldx channel_number
				lda (current_opcode), y
				jsr call_pointed_subroutine

				ldx channel_number

				; Point to next opcode
				cmp #0
				beq skip_opcode_update ; Condition technically unecessary, but optimizing the worst case (SAMPLE_END returns zero and tends to be called for all channels at the same time)
					clc
					adc audio_square1_current_opcode, x
					sta audio_square1_current_opcode, x
					lda #0
					adc audio_square1_current_opcode_msb, x
					sta audio_square1_current_opcode_msb, x
				skip_opcode_update:

				; Loop until we are in wait mode
				lda audio_square1_wait_cnt, x
				beq execute_current_opcode

		end_opcodes_execution:

		; Tick wait counter
		dec audio_square1_wait_cnt, x

		; Write mirrored APU registers
		txa
		asl
		asl
		tay

		lda channel_number
		cmp #2 ; triangle
		beq triangle

			; Pulse channel
			;  copy mirrored envelope as is (a zero frequency cleanly mute the channel)
			;  avoid rewriting timer high bits if not modified (it resets phase, producing an audible "pop")
			lda audio_square1_apu_envelope_byte, x
			sta APU_SQUARE1_ENVELOPE, y

			lda audio_square1_apu_timer_low_byte, x
			sta APU_SQUARE1_TIMER_LOW, y

			lda audio_square1_apu_timer_high_byte, x
			cmp audio_square1_apu_timer_high_byte_old, x
			beq end_write_apu
				sta APU_SQUARE1_LENGTH_CNT, y
				sta audio_square1_apu_timer_high_byte_old, x

			jmp end_write_apu

		triangle:
			; Triangle channel
			;  silence channel on frequency 0 (avoiding a "pop" noise by violent change in frequency)
			;  simply copy timer, no phase problem when wrriting high bits
			lda audio_triangle_apu_timer_low_byte
			bne unmute
			lda audio_triangle_apu_timer_high_byte
			bne unmute
				lda #%10000000
				jmp write_linear_cnt
			unmute:
				lda audio_triangle_apu_timer_low_byte
				sta APU_TRIANGLE_TIMER_LOW
				lda audio_triangle_apu_timer_high_byte
				sta APU_TRIANGLE_LENGTH_CNT

				lda #%11111111

			write_linear_cnt:
			sta APU_TRIANGLE_LINEAR_CNT

		end_write_apu:

		rts
	.)

	opcode_noise_sample_end:
	.(
		ldx #3
		; Fallthrough
	.)
	opcode_sample_end:
	.(
		tmp_addr = tmpfield1
		tmp_addr_msb = tmpfield2
		sample_addr = tmpfield3
		sample_addr_msb = tmpfield4

		; Get next sample's address
#if \
	(MUSIC_HEADER_PULSE2_TRACK_OFFSET <> (MUSIC_HEADER_PULSE1_TRACK_OFFSET + 2)) || \
	(MUSIC_HEADER_TRIANGLE_TRACK_OFFSET <>  (MUSIC_HEADER_PULSE2_TRACK_OFFSET + 2)) || \
	(MUSIC_HEADER_NOISE_TRACK_OFFSET <>  (MUSIC_HEADER_TRIANGLE_TRACK_OFFSET + 2))
#error code below expects channels track offset in a specific order
#endif
		txa ; Y = pulse1_track_offset + 2 * X = channel's samples list address' offset in music header
		asl
		;clc ; useless, asl should not overflow
		adc #MUSIC_HEADER_PULSE1_TRACK_OFFSET
		tay

		lda (audio_current_track_lsb), y ; tmp_addr = channel's samples list address
		sta tmp_addr
		iny
		lda (audio_current_track_lsb), y
		sta tmp_addr_msb

		lda audio_square1_sample_num, x ; A = (++sample_num) * 2
		;clc ; useless, adc should not overflow, no other carry-setting opcode since
		adc #1
		sta audio_square1_sample_num, x
		asl

		;clc; useless, still no overflow ; sample_addr = current sample's address
		adc tmp_addr
		sta sample_addr
		lda #0
		adc tmp_addr_msb
		sta sample_addr_msb

		; If next sample is actually MUSIC_END, loop the channel
		;  Check only msb of MUSIC_END vector ($00 $00) as a sample in zero page is improbable
		ldy #1
		lda (sample_addr), y
		bne no_track_loop

			; Set current opcode to first sample's first opcode
			lda (tmp_addr), y
			sta audio_square1_current_opcode_msb, x
			dey ; note, sets Y to zero, equivalent to ldy #0 with oine less byte
			lda (tmp_addr), y
			sta audio_square1_current_opcode, x

			; Reset sample counter
			sty audio_square1_sample_num, x

			jmp end

		no_track_loop:

			; Set current opcode to new sample's first opcode
			lda (sample_addr), y
			sta audio_square1_current_opcode_msb, x
			dey ; note, sets Y to zero, equivalent to ldy #0 with oine less byte
			lda (sample_addr), y
			sta audio_square1_current_opcode, x

		end:
		lda #0
		rts
	.)

	opcode_chan_params:
	.(
		; OOOO Oddd  DDLC VVVV  EPPP NSSS

		; ddd - default note duration minus one
		;ldy #0 ; useless, ensured by caller
		lda (current_opcode), y
		and #%00000111
		sta audio_square1_default_note_duration, x
		inc audio_square1_default_note_duration, x

		; DDLC VVVV - direct write to APU (mirrored)
		iny
		lda (current_opcode), y
		sta audio_square1_apu_envelope_byte, x

		; EPPP NSSS - direct write to APU
		txa
		asl
		asl
		tax

		iny
		lda (current_opcode), y
		sta APU_SQUARE1_SWEEP, x

		lda #3
		rts
	.)

	; Generic volume setter
	;  X envelope byte offset
	;  Y volume to be set
	set_volume:
	.(
		; Reset volume bits in channel's envelope mirror
		lda audio_square1_apu_envelope_byte, x
		and #%11110000
		sta audio_square1_apu_envelope_byte, x

		; Place new volume bits
		tya
		ora audio_square1_apu_envelope_byte, x
		sta audio_square1_apu_envelope_byte, x

		lda #1
		rts
	.)

	opcode_chan_volume_low:
	.(
		; OOOO Ovvv

		; Extract volume value
		lda (current_opcode), y
		and #%00000111
		tay

		; Set channel's volume
		jmp set_volume

		;rts ; useless, jump to a routine
	.)

	opcode_chan_volume_high:
	.(
		; OOOO Ovvv

		; Extract volume value
		lda (current_opcode), y
		and #%00000111
		ora #%00001000
		tay

		; Set channel's volume
		jmp set_volume

		;rts ; useless, jump to a routine
	.)

	opcode_noise_set_volume:
	.(
		; OOOO vvvv

		; Extract volume value
		and #%00001111
		tay

		; Set channel's volume
		ldx #audio_noise_apu_envelope_byte-audio_square1_apu_envelope_byte
		jmp set_volume

		;rts useless, jump to a routine
	.)

	opcode_set_duty:
	.(
		; OOOO ODDz

		and #%00000110
		asl
		asl
		asl
		asl
		asl
		sta tmpfield1

		lda audio_square1_apu_envelope_byte, x
		and #%00111111
		ora tmpfield1
		sta audio_square1_apu_envelope_byte, x

		lda #1
		rts
	.)

	opcode_play_timed_freq:
	.(
		; OOOO OTTT  TTTT TTTT  DDDD DDDD

		; TTT TTTT TTTT - direct write to APU (mirrored)
		lda (current_opcode), y
		and #%00000111
		ora #%11111000 ;TODO this actually hardocode a long value for "length counter load", which should be adequat most times. If we want to play with it, actually use register mirroring, and add opcodes to handle this value
		sta audio_square1_apu_timer_high_byte, x

		iny
		lda (current_opcode), y
		sta audio_square1_apu_timer_low_byte, x

		; DDDD DDDD
		iny
		lda (current_opcode), y
		sta audio_square1_wait_cnt, x

		lda #3
		rts
	.)

	; Extract frequency from note lookup table
	;  register A - note index
	;
	; Output
	;  apu_timer_low_byte - frequency lsb
	;  apu_timer_high_byte - frequency msb
	;
	; Overwrites register A, register X, extra_tmpfield1, and extra_tmpfield2
	note_table_lookup:
	.(
		tax

		lda audio_notes_table_pal_high, x
		ora #%11111000 ;TODO this actually hardcode a long value for "length counter load", which should be adequat most times. If we want to play with it, actually use register mirroring, and add opcodes to handle this value
		sta apu_timer_high_byte

		lda audio_notes_table_pal_low, x
		sta apu_timer_low_byte

		rts
	.)

	opcode_play_note:
	.(
		; OOOO ODdd  zNNN NNNN

		default_note_duration = tmpfield1

		; Mirror state impacted while X is used in fixed memory location
		lda audio_square1_default_note_duration, x
		sta default_note_duration

		; D dd - set wait counter
		lda (current_opcode), y
		pha
		and #%00000011
		tax

		pla
		and #%00000100
		beq right_shift

			left_shift:
				lda default_note_duration
				one_left_shift:
					dex
					bmi end_wait_compute
					asl
					jmp one_left_shift

			right_shift:
				lda default_note_duration
				one_right_shift:
					dex
					bmi end_wait_compute
					lsr
					jmp one_right_shift

		end_wait_compute:
		ldx channel_number
		sta audio_square1_wait_cnt, x

		; NNN NNNN - set note frequency as read in the reference table
		iny
		lda (current_opcode), y
		jsr note_table_lookup

		; Copy state mirror to actual state
		ldx channel_number
		lda default_note_duration
		sta audio_square1_default_note_duration, x
		lda apu_timer_high_byte
		sta audio_square1_apu_timer_high_byte, x
		lda apu_timer_low_byte
		sta audio_square1_apu_timer_low_byte, x

		lda #2
		rts
	.)

	opcode_play_timed_note:
	.(
		; OOOO Oddd  dNNN NNNN

		; NNN NNNN - set note frequency as read in the reference table
		iny
		lda (current_opcode), y
		and #%01111111
		jsr note_table_lookup

		; ddd d - set wait counter
		lda (current_opcode), y
		rol
		dey
		lda (current_opcode), y
		rol
		and #%00001111
		clc
		adc #1
		ldx channel_number
		sta audio_square1_wait_cnt, x

		; Copy state mirror to actual state
		lda apu_timer_high_byte
		sta audio_square1_apu_timer_high_byte, x
		lda apu_timer_low_byte
		sta audio_square1_apu_timer_low_byte, x

		lda #2
		rts
	.)

	opcode_wait:
	.(
		; OOOO Oddd

		lda (current_opcode), y
		and #%00000111
		sta audio_square1_wait_cnt, x
		inc audio_square1_wait_cnt, x

		lda #1
		rts
	.)

	opcode_noise_wait:
	.(
		; OOOO dddd

		and #%00001111
		sta audio_noise_wait_cnt
		inc audio_noise_wait_cnt

		lda #1
		rts
	.)

	opcode_noise_long_wait:
	.(
		; OOOO .... DDDD DDDD

		ldx #audio_noise_wait_cnt-audio_square1_wait_cnt
		; Fallthrough
	.)
	opcode_long_wait:
	.(
		; OOOO O... DDDD DDDD

		iny
		lda (current_opcode), y
		sta audio_square1_wait_cnt, x

		lda #2
		rts
	.)

	opcode_halt:
	.(
		; OOOO Oddd

		; ddd - set wait counter
		lda (current_opcode), y
		and #%00000111
		sta audio_square1_wait_cnt, x
		inc audio_square1_wait_cnt, x

		; Silence the channel
		lda #0
		sta audio_square1_apu_timer_low_byte, x
		sta audio_square1_apu_timer_high_byte, x

		lda #1
		rts
	.)

	opcode_noise_halt:
	.(
		; OOOO dddd

		; dddd - set wait counter
		lda (current_opcode), y
		and #%00001111
		sta audio_noise_wait_cnt
		inc audio_noise_wait_cnt

		; Silence the channel
		lda audio_noise_apu_period_byte
		ora #%01000000
		sta audio_noise_apu_period_byte

		lda #1
		rts
	.)

	opcode_pitch_slide:
	.(
		; OOOO Oszz  TTTT TTTT

		; s - sign, set frequency high to byte extend of it
		lda (current_opcode), y
		and #%00000100
		beq set_value
			lda #$ff
		set_value:
		sta audio_square1_pitch_slide_msb, x

		; TTTT TTTT
		iny
		lda (current_opcode), y
		sta audio_square1_pitch_slide_lsb, x

		lda #2
		rts
	.)

	opcode_pulse_meta_uslide:
	.(
		opcode_byte = tmpfield1

		sta opcode_byte

		lda #$ff
		jmp opcode_pulse_meta_common
	.)
	opcode_pulse_meta_dslide:
	.(
		opcode_byte = tmpfield1

		sta opcode_byte

		lda #0
		; Fallthrough
	.)
	opcode_pulse_meta_common:
	.(
		; OOOO Ovsd [zNNN NNNN] DDDD DDDD [ddzz vvvv] [SSSS SSSS]

		opcode_byte = tmpfield1
		slide_msb = tmpfield2
		envelope_mask = tmpfield3
		has_note = tmpfield4

		; Store slide msb in temporary location
		sta slide_msb

		; Note
		.(
			; [zNNN NNNN] DDDD DDDD

			; zNNN NNNN
			lda opcode_byte
			and #%11111000
			cmp #(AUDIO_OP_META_WAIT_SLIDE_UP << 3)
			beq end_note
			cmp #(AUDIO_OP_META_WAIT_SLIDE_DOWN << 3)
			beq end_note

				iny
				lda (current_opcode), y
				jsr note_table_lookup

				ldx channel_number
				lda apu_timer_high_byte
				sta audio_square1_apu_timer_high_byte, x
				lda apu_timer_low_byte
				sta audio_square1_apu_timer_low_byte, x

			end_note:

			; DDDD DDDD
			iny
			lda (current_opcode), y
			sta audio_square1_wait_cnt, x
		.)

		; Volume and duty
		.(
			lda opcode_byte
			and #%00000101
			beq end_volume_duty

				; ddzz vvvv

				iny

				; Compute mask for old value (with bits set for bits we want to keep)
				lda #%00000100 ; volume present flag
				bit opcode_byte
				beq keep_volume
					lda #%00110000
					jmp set_volume_mask
				keep_volume:
					lda #%00111111
				set_volume_mask:
				sta envelope_mask

				lda #%00000001 ; duty present flag
				bit opcode_byte
				bne replace_duty
					lda #%11000000
					ora envelope_mask
					sta envelope_mask
					; no jump, replace_duty is empty
				replace_duty:
					; Nothing to do, existing mask is already correct

				; Apply mask to old value (bits to be changed are set to zero)
				lda audio_square1_apu_envelope_byte, x
				and envelope_mask

				; Set bits from new value
				ora (current_opcode), y
				sta audio_square1_apu_envelope_byte, x

			end_volume_duty:
		.)

		; Pitch slide
		.(
			lda opcode_byte
			and #%00000010
			beq end_pitch_slide

				; SSSS SSSS

				lda slide_msb
				sta audio_square1_pitch_slide_msb, x

				iny
				lda (current_opcode), y
				sta audio_square1_pitch_slide_lsb, x

			end_pitch_slide:
		.)

		; Return pre-computed opcode size
		iny
		tya
		rts
	.)

	opcode_noise_set_periodic:
	.(
		; OOOO zzzL

		and #%00000001
		beq unset
			lda audio_noise_apu_period_byte
			ora #%10000000
			jmp end
		unset:
			lda audio_noise_apu_period_byte
			and #%01111111

		end:
		sta audio_noise_apu_period_byte
		lda #1
		rts
	.)

	opcode_noise_play_timed_freq:
	.(
		; OOOO NNNN  dddd dddd

		; NNNN - update APU mirror (and reset silence flag)
		and #%00001111
		sta tmpfield1
		lda audio_noise_apu_period_byte
		and #%10110000
		ora tmpfield1
		sta audio_noise_apu_period_byte

		; dddd dddd
		iny
		lda (current_opcode), y
		sta audio_noise_wait_cnt

		lda #2
		rts
	.)

	opcode_noise_pitch_slide_up:
	.(
		; OOOO TTTT

		and #%00001111
		eor #%11111111
		clc
		adc #1
		sta audio_noise_pitch_slide

		lda #1
		rts
	.)

	opcode_noise_pitch_slide_down:
	.(
		; OOOO TTTT

		and #%00001111
		sta audio_noise_pitch_slide

		lda #1
		rts
	.)

	opcode_noise_end_sfx:
	.(
		; Don't tick this effect anymore
		jsr audio_cut_sfx

		; Silence the channel
		lda audio_noise_apu_period_byte
		ora #%01000000
		sta audio_noise_apu_period_byte

		; Set wait cnt to non-zero to exit the opcode loop
		lda #1
		sta audio_noise_wait_cnt

		; Return opcode size
		;lda #1 ; useless, done above
		rts
	.)

	pulse1_opcode_routines_lsb:
	.byt <opcode_sample_end, <opcode_chan_params, <opcode_chan_volume_low, <opcode_chan_volume_high, <opcode_play_timed_freq
	.byt <opcode_play_note, <opcode_wait, <opcode_long_wait, <opcode_halt, <opcode_pitch_slide
	.byt <opcode_set_duty, <opcode_play_timed_note, <opcode_pulse_meta_uslide, <opcode_pulse_meta_dslide, <opcode_pulse_meta_uslide
	.byt <opcode_pulse_meta_dslide
	pulse1_opcode_routines_msb:
	.byt >opcode_sample_end, >opcode_chan_params, >opcode_chan_volume_low, >opcode_chan_volume_high, >opcode_play_timed_freq
	.byt >opcode_play_note, >opcode_wait, >opcode_long_wait, >opcode_halt, >opcode_pitch_slide
	.byt >opcode_set_duty, >opcode_play_timed_note, >opcode_pulse_meta_uslide, >opcode_pulse_meta_dslide, >opcode_pulse_meta_uslide
	.byt >opcode_pulse_meta_dslide

	noise_opcode_routines_lsb:
	.byt <opcode_noise_sample_end, <opcode_noise_set_volume, <opcode_noise_set_periodic, <opcode_noise_play_timed_freq, <opcode_noise_wait
	.byt <opcode_noise_long_wait, <opcode_noise_halt, <opcode_noise_pitch_slide_up, <opcode_noise_pitch_slide_down, <opcode_noise_end_sfx
	noise_opcode_routines_msb:
	.byt >opcode_noise_sample_end, >opcode_noise_set_volume, >opcode_noise_set_periodic, >opcode_noise_play_timed_freq, >opcode_noise_wait
	.byt >opcode_noise_long_wait, >opcode_noise_halt, >opcode_noise_pitch_slide_up, >opcode_noise_pitch_slide_down, >opcode_noise_end_sfx
.)

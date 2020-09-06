audio_init:
.(
	jmp audio_mute_music
	;rts ; useless, jump to routine
.)

; Play a track
;  register A - track info address msb
;  register Y - track info address lsb
;
;  Overwrites all registers, tmpfield1 to tmpfield4
audio_play_music:
.(
	; Set current track
	sta audio_current_track_msb
	sty audio_current_track_lsb

	; Init pulse channels
	ldx #0
	jsr init_channel

	ldx #1
	jsr init_channel

	; Init triangle channle
	lda #5 ; default note duration ;TODO get it from music header
	sta audio_triangle_default_note_duration

	lda #%11111111 ; CRRR RRRR
	sta APU_TRIANGLE_LINEAR_CNT

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

		SWITCH_BANK(#MUSIC_BANK_NUMBER)

		; Set default pulse parameters
		cpx #2
		bcs end_pulse_specifics

			lda #5 ; default note duration ;TODO get it from music header
			sta audio_square1_default_note_duration, x

			lda #%00111111 ; DDLC VVVV - APU mirror
			sta audio_square1_apu_envelope_byte, x

			lda #%00000000 ; EPPP NSSS - direct write to APU
			.(
				cpx #0
				bne pulse_2
					sta APU_SQUARE1_SWEEP
					jmp ok
				pulse_2:
					sta APU_SQUARE2_SWEEP
				ok:
			.)

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
	lda #0
	sta audio_music_enabled

	;TODO higher level silencing of channels (like an halt opcode in each channel)
	;     (or by forcing silence in audio_music_tick at the "copy APU mirror to registers" step)
	;     that way, complex sfx can still be played
	lda #%00001000 ; ---DNT21
	sta APU_STATUS ;

	rts
.)

; Restore playing music
;
;  Overwrites register A
audio_unmute_music:
.(
	lda #1
	sta audio_music_enabled

	;TODO should be useless once audio_mute_music is fixed. Channels should be enabled at startup and never touched after that
	lda #%00001111 ; ---DNT21
	sta APU_STATUS ;

	rts
.)

; Restart the current track from its begining
;
;  Overwrites register A
audio_reset_music:
.(
	lda #0
	sta audio_square1_sample_num
	sta audio_square2_sample_num
	sta audio_triangle_sample_num
	sta audio_noise_sample_num
	;TODO current opcode?
	rts
.)

; Play one tick of the audio engine
;
; Overwrites all registers, and tmpfield1 to tmpfield4
audio_music_tick:
.(
	current_opcode = tmpfield3
	current_opcode_msb = tmpfield4
	channel_number = tmpfield5

	.(
		SWITCH_BANK(#MUSIC_BANK_NUMBER)

		lda audio_music_enabled
		beq end

			ldx #0
			jsr pulse_tick
			ldx #1
			jsr pulse_tick
			ldx #2
			jsr pulse_tick ; Triangle opcodes are compatible with pulse opcodes, just use pulse_tick
			jsr noise_tick

		end:
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

		; Write mirrored APU registers, or silence the channel if silence flag is set
		bit audio_noise_apu_period_byte
		bvc regular_write
			lda #0
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
				clc
				adc audio_square1_current_opcode, x
				sta audio_square1_current_opcode, x
				lda #0
				adc audio_square1_current_opcode_msb, x
				sta audio_square1_current_opcode_msb, x

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
		clc
		adc #MUSIC_HEADER_PULSE1_TRACK_OFFSET
		tay

		lda (audio_current_track_lsb), y ; tmp_addr = channel's samples list address
		sta tmp_addr
		iny
		lda (audio_current_track_lsb), y
		sta tmp_addr_msb

		lda audio_square1_sample_num, x ; A = (++sample_num) * 2
		clc
		adc #1
		sta audio_square1_sample_num, x
		asl

		clc ; sample_addr = current sample's address
		adc tmp_addr
		sta sample_addr
		lda #0
		adc tmp_addr_msb
		sta sample_addr_msb

		; If next sample is actually MUSIC_END, loop the channel
		;  Check only msb of MUSIC_END vector ($00 $00) as a sample in zero page is improbable
		ldy #1
		lda (sample_addr), y
		bne end_get_sample_addr

			; Reset sample counter
			lda #0
			sta audio_square1_sample_num, x

			; Get first sample's address
			lda tmp_addr ; sample_addr = first sample's addr
			sta sample_addr
			lda tmp_addr_msb
			sta sample_addr_msb

		end_get_sample_addr:

		; Set current opcode to new sample's first opcode
		ldy #0
		lda (sample_addr), y
		sta audio_square1_current_opcode, x
		iny
		lda (sample_addr), y
		sta audio_square1_current_opcode_msb, x

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

	opcode_play_note:
	.(
		; OOOO ODdd  zNNN NNNN

		default_note_duration = extra_tmpfield1
		apu_timer_high_byte = extra_tmpfield2
		apu_timer_low_byte = extra_tmpfield3

		; Mirror state impacted while X is used in fixed memory location
		lda audio_square1_default_note_duration, x
		sta default_note_duration
		lda audio_square1_apu_timer_high_byte, x
		sta apu_timer_high_byte
		lda audio_square1_apu_timer_low_byte, x
		sta apu_timer_low_byte

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
		;and #%01111111 ; useless - unused bit is forced to zero by spec
		tax

		lda audio_notes_table_high, x
		ora #%11111000 ;TODO this actually hardocode a long value for "length counter load", which should be adequat most times. If we want to play with it, actually use register mirroring, and add opcodes to handle this value
		sta apu_timer_high_byte

		lda audio_notes_table_low, x
		sta apu_timer_low_byte

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

	pulse1_opcode_routines_lsb:
	.byt <opcode_sample_end, <opcode_chan_params, <opcode_chan_volume_low, <opcode_chan_volume_high, <opcode_play_timed_freq
	.byt <opcode_play_note, <opcode_wait, <opcode_long_wait, <opcode_halt, <opcode_pitch_slide
	pulse1_opcode_routines_msb:
	.byt >opcode_sample_end, >opcode_chan_params, >opcode_chan_volume_low, >opcode_chan_volume_high, >opcode_play_timed_freq
	.byt >opcode_play_note, >opcode_wait, >opcode_long_wait, >opcode_halt, >opcode_pitch_slide

	noise_opcode_routines_lsb:
	.byt <opcode_noise_sample_end, <opcode_noise_set_volume, <opcode_noise_set_periodic, <opcode_noise_play_timed_freq, <opcode_noise_wait
	.byt <opcode_noise_long_wait, <opcode_noise_halt, <opcode_noise_pitch_slide_up, <opcode_noise_pitch_slide_down
	noise_opcode_routines_msb:
	.byt >opcode_noise_sample_end, >opcode_noise_set_volume, >opcode_noise_set_periodic, >opcode_noise_play_timed_freq, >opcode_noise_wait
	.byt >opcode_noise_long_wait, >opcode_noise_halt, >opcode_noise_pitch_slide_up, >opcode_noise_pitch_slide_down
.)
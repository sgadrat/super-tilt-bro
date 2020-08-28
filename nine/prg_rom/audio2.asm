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

	ldx #0
	jsr init_pulse_channel
	ldx #1
	jsr init_pulse_channel

	rts

	init_pulse_channel:
	.(
		; Set current sample
		lda #0
		sta audio_square1_sample_num, x

		; Remove any wait
		;lda #0 ; useless, done above
		sta audio_square1_wait_cnt, x

		; Set current opcode
		;TODO factorize with SAMPLE_END handling
		tmp_addr = tmpfield1
		tmp_addr_msb = tmpfield2

		SWITCH_BANK(#MUSIC_BANK_NUMBER)

		; Set default square1 parameters
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

		; Get current sample's address
		.( ; Y = channel's samples list address' offset in music header
			ldy #MUSIC_HEADER_PULSE1_TRACK_OFFSET
			cpx #0
			beq ok
				ldy #MUSIC_HEADER_PULSE2_TRACK_OFFSET
			ok:
		.)

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
	lda #%00001011 ; ---DNT21
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
	rts
.)

; Play one tick of the audio engine
;
; Overwrites all registers, and tmpfield1 to tmpfield4
audio_music_tick:
.(
	.(
		SWITCH_BANK(#MUSIC_BANK_NUMBER)

		lda audio_music_enabled
		beq end

			ldx #0
			jsr pulse_tick
			ldx #1
			jsr pulse_tick
			;TODO other channels

		end:
		rts
	.)

	pulse_tick:
	.(
		current_opcode = tmpfield3
		current_opcode_msb = tmpfield4
		pulse_channel_number = tmpfield5

		.(
			tmp_addr = tmpfield1
			tmp_addr_msb = tmpfield2

			; Execute effects if not silenced
			lda audio_square1_apu_timer_low_byte, x
			bne do_effects
			lda audio_square1_apu_timer_high_byte, x
			and #%00000111
			beq end_effects
			do_effects:

				; Pitch slide (add pitch slide value to frequency)
				lda audio_square1_apu_timer_low_byte, x ; Add low bytes (straightforward)
				clc
				adc audio_square1_pulse_slide_lsb, x
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

				adc audio_square1_pulse_slide_msb, x
				ora #%11111000 ; TODO long value for "length counter load" (see other similar comments)
				sta audio_square1_apu_timer_high_byte, x

			end_effects:

			; Save X to a reserved memory location
			txa
			sta pulse_channel_number

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
					;  Note - subroutines are called wit Y=0, and are free to expect it
					tax

					lda pulse1_opcode_routines_lsb, x
					sta tmp_addr
					lda pulse1_opcode_routines_msb, x
					sta tmp_addr_msb
					ldx pulse_channel_number
					jsr call_pointed_subroutine

					ldx pulse_channel_number

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

			lda audio_square1_apu_envelope_byte, x
			sta APU_SQUARE1_ENVELOPE, y
			lda audio_square1_apu_timer_low_byte, x
			sta APU_SQUARE1_TIMER_LOW, y

			lda audio_square1_apu_timer_high_byte, x
			cmp audio_square1_apu_timer_high_byte_old, x
			beq end_write_apu
				sta APU_SQUARE1_LENGTH_CNT, y
				sta audio_square1_apu_timer_high_byte_old, x

			end_write_apu:

			rts
		.)

		opcode_sample_end:
		.(
			tmp_addr = tmpfield1
			tmp_addr_msb = tmpfield2
			sample_addr = tmpfield3
			sample_addr_msb = tmpfield4

			; Get next sample's address
			cpx #0 ; tmp_addr = channel's samples list address
			bne pulse_2_header_pos
				ldy #MUSIC_HEADER_PULSE1_TRACK_OFFSET
				jmp header_pos_set
			pulse_2_header_pos:
				ldy #MUSIC_HEADER_PULSE2_TRACK_OFFSET
			header_pos_set:

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
			sta APU_SQUARE1_PERIOD, x

			lda #3
			rts
		.)

		opcode_chan_volume_low:
		.(
			; OOOO Ovvv

			; Reset volume bits in channel's envelope mirror
			lda audio_square1_apu_envelope_byte, x
			and #%11110000
			sta audio_square1_apu_envelope_byte, x

			; Place new volume bits
			lda (current_opcode), y
			and #%00000111
			ora audio_square1_apu_envelope_byte, x
			sta audio_square1_apu_envelope_byte, x

			lda #1
			rts
		.)

		opcode_chan_volume_high:
		.(
			; OOOO Ovvv

			; Reset volume bits in channel's envelope mirror
			lda audio_square1_apu_envelope_byte, x
			and #%11110000
			sta audio_square1_apu_envelope_byte, x

			; Place new volume bits
			lda (current_opcode), y
			and #%00000111
			ora #%00001000
			ora audio_square1_apu_envelope_byte, x
			sta audio_square1_apu_envelope_byte, x

			; Write to APU (mirrored)
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
			ldx pulse_channel_number
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
			ldx pulse_channel_number
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

		opcode_pitch_slide:
		.(
			; OOOO Oszz  TTTT TTTT

			; s - sign, set frequency high to byte extend of it
			lda (current_opcode), y
			and #%00000100
			beq set_value
				lda #$ff
			set_value:
			sta audio_square1_pulse_slide_msb, x

			; TTTT TTTT
			iny
			lda (current_opcode), y
			sta audio_square1_pulse_slide_lsb, x

			lda #2
			rts
		.)

		pulse1_opcode_routines_lsb:
		.byt <opcode_sample_end, <opcode_chan_params, <opcode_chan_volume_low, <opcode_chan_volume_high, <opcode_play_timed_freq
		.byt <opcode_play_note, <opcode_wait, <opcode_long_wait, <opcode_halt, <opcode_pitch_slide

		pulse1_opcode_routines_msb:
		.byt >opcode_sample_end, >opcode_chan_params, >opcode_chan_volume_low, >opcode_chan_volume_high, >opcode_play_timed_freq
		.byt >opcode_play_note, >opcode_wait, >opcode_long_wait, >opcode_halt, >opcode_pitch_slide
	.)
.)

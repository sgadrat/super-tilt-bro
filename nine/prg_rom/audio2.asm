audio_init:
.(
	jmp audio_mute_music
	;rts ; useless, jump to routine
.)

; Play a track
;  register A - track info address msb
;  register Y - track info address lsb
;
;  Overwrites register A, tmpfield1 to tmpfield4
audio_play_music:
.(
	; Set current track
	sta audio_current_track_msb
	sty audio_current_track_lsb

	; Set current sample
	lda #0
	sta audio_square1_sample_num

	; Set current opcode
	;TODO factorize with SAMPLE_END handling
	tmp_addr = tmpfield1
	tmp_addr_msb = tmpfield2

	SWITCH_BANK(#MUSIC_BANK_NUMBER)

	; Get current sample's address
	ldy #MUSIC_HEADER_PULSE_TRACK_OFFSET ; tmp_addr = channel's samples list address
	lda (audio_current_track_lsb), y
	sta tmp_addr
	iny
	lda (audio_current_track_lsb), y
	sta tmp_addr_msb

	ldy #0 ; current opcode address = first sample's value
	lda (tmp_addr), y
	sta audio_square1_current_opcode
	iny
	lda (tmp_addr), y
	sta audio_square1_current_opcode_msb

	end:
	rts
.)

; Silence any music being played
;
;  Overwrites register A
audio_mute_music:
.(
	lda #0
	sta audio_music_enabled

	;TODO higher level silencing of channels (like and halt opcode in each channel
	; that way, complex sfx can still be played
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

audio_music_tick:
.(
	.(
		SWITCH_BANK(#MUSIC_BANK_NUMBER)

		lda audio_music_enabled
		beq end

			jsr pulse1_tick
			;TODO other channels

		end:
		rts
	.)

	pulse1_tick:
	.(
		.(
			tmp_addr = tmpfield1
			tmp_addr_msb = tmpfield2

			; Execute opcodes only if not in wait mode
			lda audio_square1_wait_cnt
			bne tick_wait_cnt

				; Execute opcodes until one activates wait mode
				execute_current_opcode:
					; Decode opcode
					ldy #0
					lda (audio_square1_current_opcode), y
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
					jsr call_pointed_subroutine

					; Point to next opcode
					clc
					adc audio_square1_current_opcode
					sta audio_square1_current_opcode
					lda #0
					adc audio_square1_current_opcode_msb
					sta audio_square1_current_opcode_msb

					; Loop until we are in wait mode
					lda audio_square1_wait_cnt
					beq execute_current_opcode

			tick_wait_cnt:
			dec audio_square1_wait_cnt
			rts
		.)

		opcode_sample_end:
		.(
			tmp_addr = tmpfield1
			tmp_addr_msb = tmpfield2
			sample_addr = tmpfield3
			sample_addr_msb = tmpfield4

			; Get next sample's address
			ldy #MUSIC_HEADER_PULSE_TRACK_OFFSET ; tmp_addr = channel's samples list address
			lda (audio_current_track_lsb), y
			sta tmp_addr
			iny
			lda (audio_current_track_lsb), y
			sta tmp_addr_msb

			lda audio_square1_sample_num ; A = (++sample_num) * 2
			clc
			adc #1
			sta audio_square1_sample_num
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
				sta audio_square1_sample_num

				; Get first sample's address
				lda tmp_addr ; sample_addr = first sample's addr
				sta sample_addr
				lda tmp_addr_msb
				sta sample_addr_msb

			end_get_sample_addr:

			; Set current opcode to new sample's first opcode
			ldy #0
			lda (sample_addr), y
			sta audio_square1_current_opcode
			iny
			lda (sample_addr), y
			sta audio_square1_current_opcode_msb

			end:
			lda #0
			rts
		.)

		opcode_chan_params:
		.(
			; OOOO Oddd  DDLC VVVV  EPPP NSSS

			; ddd - default note duration minus one
			;ldy #0 ; useless, ensured by caller
			lda (audio_square1_current_opcode), y
			and #%00000111
			sta audio_square1_default_note_duration
			inc audio_square1_default_note_duration

			; DDLC VVVV - direct write to APU
			iny
			lda (audio_square1_current_opcode), y
			sta APU_SQUARE1_ENVELOPE
			sta audio_square1_apu_envelope_byte

			; EPPP NSSS - direct write to APU
			iny
			lda (audio_square1_current_opcode), y
			sta APU_SQUARE1_PERIOD

			lda #3
			rts
		.)

		opcode_chan_volume_low:
		.(
			; OOOO Ovvv

			; Reset volume bits in channel's envelope mirror
			lda audio_square1_apu_envelope_byte
			and #%11110000
			sta audio_square1_apu_envelope_byte

			; Place new volume bits
			lda (audio_square1_current_opcode), y
			and #%00000111
			ora audio_square1_apu_envelope_byte
			sta audio_square1_apu_envelope_byte

			; Write to APU
			sta APU_SQUARE1_ENVELOPE

			lda #1
			rts
		.)

		opcode_chan_volume_high:
		.(
			; OOOO Ovvv

			; Reset volume bits in channel's envelope mirror
			lda audio_square1_apu_envelope_byte
			and #%11110000
			sta audio_square1_apu_envelope_byte

			; Place new volume bits
			lda (audio_square1_current_opcode), y
			and #%00000111
			ora #%00001000
			ora audio_square1_apu_envelope_byte
			sta audio_square1_apu_envelope_byte

			; Write to APU
			sta APU_SQUARE1_ENVELOPE

			lda #1
			rts
		.)

		opcode_play_timed_freq:
		.(
			; OOOO OTTT  TTTT TTTT  DDDD DDDD

			; TTT TTTT TTTT - direct write to APU
			lda (audio_square1_apu_envelope_byte), y
			and #%00000111
			ora #%11111000 ;TODO this actually hardocode a long value for "length counter load", which should be adequat most times. If we want to play with it, mirror the APU register and add opcodes to handle this value
			sta APU_SQUARE1_LENGTH_CNT

			iny
			lda (audio_square1_apu_envelope_byte), y
			sta APU_SQUARE1_TIMER_LOW

			; DDDD DDDD
			iny
			lda (audio_square1_apu_envelope_byte), y
			sta audio_square1_wait_cnt

			lda #3
			rts
		.)

		opcode_play_note:
		.(
			; OOOO ODdd  zNNN NNNN

			; D dd - set wait counter
			lda (audio_square1_apu_envelope_byte), y
			pha
			and #%00000011
			tax

			pla
			and #%00000100
			beq right_shift

				left_shift:
					lda audio_square1_default_note_duration
					one_left_shift:
						dex
						bmi end_wait_compute
						asl
						jmp one_left_shift

				right_shift:
					lda audio_square1_default_note_duration
					one_right_shift:
						dex
						bmi end_wait_compute
						lsr
						jmp one_right_shift

			end_wait_compute:
			sta audio_square1_wait_cnt

			; NNN NNNN - set note frequency as read in the reference table
			iny
			lda (audio_square1_apu_envelope_byte), y
			;and #%01111111 ; useless - unused byte is forced to zero by spec
			tax

			lda audio_notes_table_high, x
			ora #%11111000 ; TODO this actually hardocode a long value for "length counter load", which should be adequat most times. If we want to play with it, mirror the APU register and add opcodes to handle this value
			sta APU_SQUARE1_LENGTH_CNT

			lda audio_notes_table_low, x
			sta APU_SQUARE1_TIMER_LOW

			lda #2
			rts
		.)

		opcode_wait:
		.(
			; OOOO Oddd

			lda (audio_square1_apu_envelope_byte), y
			and #%00000111
			sta audio_square1_wait_cnt
			inc audio_square1_wait_cnt

			lda #1
			rts
		.)

		opcode_long_wait:
		.(
			; OOOO O... DDDD DDDD

			iny
			lda (audio_square1_apu_envelope_byte), y
			sta audio_square1_wait_cnt

			lda #2
			rts
		.)

		opcode_halt:
		.(
			; OOOO Oddd

			; ddd - set wait counter
			lda (audio_square1_apu_envelope_byte), y
			and #%00000111
			sta audio_square1_wait_cnt

			; Silence the channel
			lda #0
			sta APU_SQUARE1_TIMER_LOW
			sta APU_SQUARE1_LENGTH_CNT

			lda #1
			rts
		.)

		pulse1_opcode_routines_lsb:
		.byt <opcode_sample_end, <opcode_chan_params, <opcode_chan_volume_low, <opcode_chan_volume_high, <opcode_play_timed_freq
		.byt <opcode_play_note, <opcode_wait, <opcode_long_wait, <opcode_halt

		pulse1_opcode_routines_msb:
		.byt >opcode_sample_end, >opcode_chan_params, >opcode_chan_volume_low, >opcode_chan_volume_high, >opcode_play_timed_freq
		.byt >opcode_play_note, >opcode_wait, >opcode_long_wait, >opcode_halt
	.)
.)

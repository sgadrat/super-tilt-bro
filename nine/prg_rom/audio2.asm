audio_init:
.(
	jmp audio_mute_music
	;rts ; useless, jump to routine
.)

; Play a track
;  register A - track info address msb
;  register Y - track info address lsb
;
;  Overwrites register A
audio_play_music:
.(
	sta audio_current_track_msb
	sty audio_current_track_lsb
	lda #0
	sta audio_square1_sample_num
	rts
.)

; Silence any music being played
;
;  Overwrites register A
audio_mute_music:
.(
	lda #0
	sta music_enabled

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
	sta music enabled

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
	sta audio_square1_sample_counter
	rts
.)

audio_music_tick:
.(
	.(
		SWITCH_BANK(#MUSIC_BANK_NUMBER)

		lda music_enabled
		beq end

			jsr pulse1_tick
			;TODO other channels

		end:
		rts
	.)

	pulse1_tick:
	.(
		;TODO
		rts
	.)
.)

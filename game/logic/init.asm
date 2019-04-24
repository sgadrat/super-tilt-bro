global_init:
.(
	jsr default_config

	; Enable music, but do not activate APU, it will be done when a music starts
	lda #$01
	sta audio_music_enabled

	rts
.)

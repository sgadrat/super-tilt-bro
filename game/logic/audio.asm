audio_music_ingame:
.(
	; Change selected track, so it varies from game to game
	dec config_ingame_track
	bpl ok
		lda #LAST_INGAME_TRACK
		sta config_ingame_track
	ok:

	; Play selected track
	ldx config_ingame_track
	ldy ingame_themes_lsb, x
	lda ingame_themes_bank, x
	pha
	lda ingame_themes_msb, x
	tax
	pla
	jmp audio_play_music

	;rts ; useless, jump to a subroutine

	ingame_themes_lsb:
		.byt <music_perihelium_info, <music_sinbad_info
	ingame_themes_msb:
		.byt >music_perihelium_info, >music_sinbad_info
	ingame_themes_bank:
		.byt music_perihelium_bank, music_sinbad_bank
	LAST_INGAME_TRACK = ingame_themes_msb - ingame_themes_lsb - 1
.)

audio_music_weak:
.(
	ldy #<music_title_info
	ldx #>music_title_info
	lda #music_title_bank
	jmp audio_play_music

	;rts ; useless, jump to a subroutine
.)

audio_music_gameover:
.(
	ldy #<music_jump_rope_info
	ldx #>music_jump_rope_info
	lda #music_jump_rope_bank
	jmp audio_play_music

	;rts ; useless, jump to a subroutine
.)

audio_play_crash:
.(
lda #%00000100         ; --LCVVVV
sta APU_NOISE_ENVELOPE ;
lda #%00001100       ; L---PPPP
sta APU_NOISE_PERIOD ;
lda #%00001000           ; LLLLL---
sta APU_NOISE_LENGTH_CNT
rts
.)

audio_play_death:
.(
lda #%00000100         ; --LCVVVV
sta APU_NOISE_ENVELOPE ;
lda #%10001101       ; L---PPPP
sta APU_NOISE_PERIOD ;
lda #%00001000           ; LLLLL---
sta APU_NOISE_LENGTH_CNT
rts
.)

audio_play_hit:
.(
	ldy #<sfx_test
	ldx #>sfx_test
	lda #SFX_BANK
	jmp audio_play_sfx
	;rts ; useless, jump to subroutine
.)

audio_play_parry:
.(
lda #%00000010         ; --LCVVVV
sta APU_NOISE_ENVELOPE ;
lda #%00000111       ; L---PPPP
sta APU_NOISE_PERIOD ;
lda #%10110000           ; LLLLL---
sta APU_NOISE_LENGTH_CNT
rts
.)

audio_play_shield_hit:
.(
lda #%00000010         ; --LCVVVV
sta APU_NOISE_ENVELOPE ;
lda #%00000111       ; L---PPPP
sta APU_NOISE_PERIOD ;
lda #%10110000           ; LLLLL---
sta APU_NOISE_LENGTH_CNT
rts
.)

audio_play_shield_break:
.(
lda #%00000100         ; --LCVVVV
sta APU_NOISE_ENVELOPE ;
lda #%00001011       ; L---PPPP
sta APU_NOISE_PERIOD ;
lda #%10110000           ; LLLLL---
sta APU_NOISE_LENGTH_CNT
rts
.)

audio_play_title_screen_text:
.(
lda #%00000100         ; --LCVVVV
sta APU_NOISE_ENVELOPE ;
lda #%10001000       ; L---PPPP
sta APU_NOISE_PERIOD ;
lda #%10110000           ; LLLLL---
sta APU_NOISE_LENGTH_CNT
rts
.)

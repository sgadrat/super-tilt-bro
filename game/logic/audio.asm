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

#define audio_preserve_x_y \
.(:\
	tya:\
	pha:\
	txa:\
	pha:\
.)

audio_play_sfx_from_common_bank:
.(
	lda #SFX_BANK
	jsr audio_play_sfx

	pla
	tax
	pla
	tay

	rts
.)

audio_play_crash:
.(
	audio_preserve_x_y
	ldy #<sfx_crash
	ldx #>sfx_crash
	jmp audio_play_sfx_from_common_bank
	;rts ; useless, jump to subroutine
.)

audio_play_death:
.(
	audio_preserve_x_y
	ldy #<sfx_death
	ldx #>sfx_death
	jmp audio_play_sfx_from_common_bank
	;rts ; useless, jump to subroutine
.)

audio_play_hit:
.(
	audio_preserve_x_y
	ldy #<sfx_hit
	ldx #>sfx_hit
	jmp audio_play_sfx_from_common_bank
	;rts ; useless, jump to subroutine
.)

audio_play_parry:
.(
	audio_preserve_x_y
	ldy #<sfx_parry
	ldx #>sfx_parry
	jmp audio_play_sfx_from_common_bank
	;rts ; useless, jump to subroutine
.)

audio_play_shield_hit:
.(
	audio_preserve_x_y
	ldy #<sfx_shield_hit
	ldx #>sfx_shield_hit
	jmp audio_play_sfx_from_common_bank
	;rts ; useless, jump to subroutine
.)

audio_play_shield_break:
.(
	audio_preserve_x_y
	ldy #<sfx_shield_break
	ldx #>sfx_shield_break
	jmp audio_play_sfx_from_common_bank
	;rts ; useless, jump to subroutine
.)

audio_play_title_screen_text:
.(
	audio_preserve_x_y
	ldy #<sfx_title_screen_text
	ldx #>sfx_title_screen_text
	jmp audio_play_sfx_from_common_bank
	;rts ; useless, jump to subroutine
.)

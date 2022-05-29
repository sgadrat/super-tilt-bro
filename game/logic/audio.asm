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

; Play a sound effect from the global effects list
;  register X - Index of the effect to play
;
; Overwrites register A
audio_play_sfx_from_list:
.(
	lda sfx_list_lsb, x
	sta audio_fx_noise_current_opcode
	lda sfx_list_msb, x
	sta audio_fx_noise_current_opcode_msb
	lda sfx_list_bnk, x
	sta audio_fx_noise_current_opcode_bank

	jmp audio_play_sfx_direct
	;rts ; Useless, jump to subroutine
.)

sfx_list_lsb:
	SFX_COUNTDOWN_TICK_IDX = * - sfx_list_lsb
	.byt <sfx_countdown_tick
	SFX_COUNTDOWN_REACH_IDX = * - sfx_list_lsb
	.byt <sfx_countdown_reach
sfx_list_msb:
	.byt >sfx_countdown_tick
	.byt >sfx_countdown_reach
sfx_list_bnk:
	.byt SFX_BANK
	.byt SFX_BANK

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

audio_play_title_screen_subtitle:
.(
	audio_preserve_x_y
	ldy #<sfx_title_screen_subtitle
	ldx #>sfx_title_screen_subtitle
	jmp audio_play_sfx_from_common_bank
	;rts ; useless, jump to subroutine
.)

audio_play_interface_click:
.(
	audio_preserve_x_y
	ldy #<sfx_interface_click
	ldx #>sfx_interface_click
	jmp audio_play_sfx_from_common_bank
	;rts ; useless, jump to subroutine
.)

audio_play_fast_fall:
.(
	audio_preserve_x_y
	ldy #<sfx_fast_fall
	ldx #>sfx_fast_fall
	jmp audio_play_sfx_from_common_bank
	;rts ; useless, jump to subroutine
.)

audio_play_land:
.(
	audio_preserve_x_y
	ldy #<sfx_land
	ldx #>sfx_land
	jmp audio_play_sfx_from_common_bank
	;rts ; useless, jump to subroutine
.)

audio_play_tech:
.(
	audio_preserve_x_y
	ldy #<sfx_tech
	ldx #>sfx_tech
	jmp audio_play_sfx_from_common_bank
	;rts ; useless, jump to subroutine
.)

audio_play_jump:
.(
	audio_preserve_x_y
	ldy #<sfx_jump
	ldx #>sfx_jump
	jmp audio_play_sfx_from_common_bank
	;rts ; useless, jump to subroutine
.)

audio_play_aerial_jump:
.(
	audio_preserve_x_y
	ldy #<sfx_aerial_jump
	ldx #>sfx_aerial_jump
	jmp audio_play_sfx_from_common_bank
	;rts ; useless, jump to subroutine
.)

audio_play_strike_lite:
.(
	audio_preserve_x_y
	ldy #<sfx_strike_lite
	ldx #>sfx_strike_lite
	jmp audio_play_sfx_from_common_bank
	;rts ; useless, jump to subroutine
.)

;TODO sfx in character-specific data (and bank)
sinbad_audio_play_jab3_land:
.(
	audio_preserve_x_y
	ldy #<sinbad_sfx_jab3_land
	ldx #>sinbad_sfx_jab3_land
	jmp audio_play_sfx_from_common_bank
	;rts ; useless, jump to subroutine
.)

audio_play_target_break:
.(
	audio_preserve_x_y
	ldy #<sfx_target_break
	ldx #>sfx_target_break
	jmp audio_play_sfx_from_common_bank
	;rts ; useless, jump to subroutine
.)

audio_play_teleport:
.(
	audio_preserve_x_y
	ldy #<sfx_teleport
	ldx #>sfx_teleport
	jmp audio_play_sfx_from_common_bank
	;rts ; useless, jump to subroutine
.)

; Place sprite tiles for a character in PPU memory
;  register X - Player number
;  config_player_a_character, x - Character number
;
; Overwrites register A, register X, register Y, tmpfield1, tmpfield2 and tmpfield3
; May change active bank
place_character_ppu_tiles:
.(
	ldy config_player_a_character, x

	SWITCH_BANK(characters_bank_number COMMA y)

	lda PPUSTATUS
	cpx #0
	bne player_b
		lda #>CHARACTERS_CHARACTER_A_TILES_OFFSET
		sta PPUADDR
		lda #<CHARACTERS_CHARACTER_A_TILES_OFFSET
		jmp end_set_ppu_addr
	player_b:
		lda #>CHARACTERS_CHARACTER_B_TILES_OFFSET
		sta PPUADDR
		lda #<CHARACTERS_CHARACTER_B_TILES_OFFSET
	end_set_ppu_addr:
	sta PPUADDR

	lda characters_tiles_data_lsb, y
	sta tmpfield1
	lda characters_tiles_data_msb, y
	sta tmpfield2
	lda characters_tiles_number, y
	sta tmpfield3
	jmp cpu_to_ppu_copy_tiles

	;rts ; useless, jump to subroutine
.)

; wait_next_frame while still ticking music
;
; Overwrites all registers, and some tmpfields and extra_tmpfields (see audio_music_tick)
sleep_frame:
.(
	jsr audio_music_extra_tick
	jsr wait_next_frame
	jmp audio_music_tick
	; rts ; useless, jump to a subroutine
.)

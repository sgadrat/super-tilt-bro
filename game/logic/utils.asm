; Place sprite tiles for a character in PPU memory
;  register X - Player number
;  config_player_a_character, x - Character number
;
; Overwrites register A, register Y, tmpfield1, tmpfield2 and tmpfield3
; May change active bank
place_character_ppu_tiles:
.(
	ldy config_player_a_character, x

; Place sprite tiles for a character in PPU memory
;  register X - Player number
;  register Y - Character number
;  config_player_a_character, x - Character number
;
; Overwrites register A, register Y, tmpfield1, tmpfield2 and tmpfield3
; May change active bank
;
; This variant does not read selected character selected in configuration
&place_character_ppu_tiles_direct:
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

; Copy common tiles in CHR-RAM
; TODO deprecated, when reworking a state, avoid depending on this flawed alphanum charset, use a standard one
;      this "common" set has
;       - An empty, solid 0 tile
;       - Numerics (fg=1 bg=3)
;       - "%"
;       - Alpha (fg=1 bg=2)
;      This difference in alpha/num colors is a leftover of CHR-ROM times, when one font must fit all screens
;
; Overwrites register A, register Y, tmpfield1, tmpfield2 and tmpfield3
; Switches bank
copy_common_tileset:
.(
	tileset_addr = tmpfield1 ; Not movable, used by cpu_to_ppu_copy_tileset
	;tileset_addr_msb = tmpfield2 ; Not movable, used by cpu_to_ppu_copy_tileset

	SWITCH_BANK(#TILESET_COMMON_BANK_NUMBER)

	lda #<tileset_common
	sta tileset_addr
	lda #>tileset_common
	sta tileset_addr+1

	PPU_COMMON_TILES_ADDR = ($2000-(tileset_common_end-tileset_common_tiles))
	lda PPUSTATUS
	lda #>PPU_COMMON_TILES_ADDR
	sta PPUADDR
	lda #<PPU_COMMON_TILES_ADDR
	sta PPUADDR

	jmp cpu_to_ppu_copy_tileset
	; rts; useless, jump to subroutine
.)

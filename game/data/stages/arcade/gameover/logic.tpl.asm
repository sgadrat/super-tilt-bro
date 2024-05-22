#include "game/data/stages/arcade/gameover/bg_tileset.asm"

!define "stage_name" {stage_arcade_gameover}
!define "extra_init" {
	TILE_BLACK = STAGE_FIRST_SPRITE_TILE
	TILE_STOCK = STAGE_FIRST_SPRITE_TILE+1

	; Load tilesets
	.(
		; Load a black sprite tile
		lda PPUSTATUS
		lda #>($0000+TILE_BLACK*16)
		sta PPUADDR
		lda #<($0000+TILE_BLACK*16)
		sta PPUADDR
		ldx #8
		lda #%11111111
		jsr ppu_fill
		ldx #8
		lda #%00000000
		jsr ppu_fill

		; Load token sprite
		lda #1:sta tmpfield8
		lda #0:sta tmpfield9
		lda #2:sta tmpfield10
		lda #3:sta tmpfield11
		lda #<modifier_remap:sta tmpfield4
		lda #>modifier_remap:sta tmpfield5

		lda #<sinbad_chr_illustrations
		sta tmpfield1
		lda #>sinbad_chr_illustrations
		sta tmpfield2
		lda #1
		sta tmpfield3
		TRAMPOLINE(cpu_to_ppu_copy_tiles_modified, #SINBAD_BANK_NUMBER, #CURRENT_BANK_NUMBER)
	.)

	; Set alphanum charset at the end of tileset
	.(
		lda PPUSTATUS
		lda #$1d
		sta PPUADDR
		lda #$c0
		sta PPUADDR

		lda #<charset_alphanum
		sta tmpfield3
		lda #>charset_alphanum
		sta tmpfield4

		ldx #CHARSET_COLOR(2,1)

		TRAMPOLINE(cpu_to_ppu_copy_charset, #CHARSET_ALPHANUM_BANK_NUMBER, #CURRENT_BANK_NUMBER)
	.)

	; Write time counter
	.(
		POSITION_X = 9
		POSITION_Y = 20
		FIRST_DIGIT_PPU_ADDR = $2000+POSITION_Y*32+POSITION_X
		lda #$52 ; colon tile
		sta tmpfield1
		lda #<FIRST_DIGIT_PPU_ADDR
		sta tmpfield2
		lda #>FIRST_DIGIT_PPU_ADDR
		sta tmpfield3
		TRAMPOLINE(arcade_mode_display_counter_params, #ARCADE_MODE_EXTRA_BANK_NUMBER, #CURRENT_BANK_NUMBER)
	.)

	; Place stock icon
	.(
		STOCK_SPRITE = INGAME_STAGE_FIRST_SPRITE
		lda #160
		sta oam_mirror+(STOCK_SPRITE*4)+0
		lda #TILE_STOCK
		sta oam_mirror+(STOCK_SPRITE*4)+1
		lda #0
		sta oam_mirror+(STOCK_SPRITE*4)+2
		lda #151
		sta oam_mirror+(STOCK_SPRITE*4)+3
	.)

	; Write stocks counter
	.(
		STOCK_POSITION_X = 21
		STOCK_POSITION_Y = 20
		STOCK_FIRST_DIGIT_PPU_ADDR = $2000+STOCK_POSITION_Y*32+STOCK_POSITION_X

		lda PPUSTATUS
		lda #>STOCK_FIRST_DIGIT_PPU_ADDR
		sta PPUADDR
		lda #<STOCK_FIRST_DIGIT_PPU_ADDR
		sta PPUADDR

		value = tmpfield1
		write_began = tmpfield3
		lda arcade_mode_nb_credits_used
		sta value
		lda #0
		sta write_began

		ldx #100
		jsr draw_digit
		ldx #10
		jsr draw_digit
		ldx #1
		jsr draw_digit
	.)

	; Hide player A portrait
	.(
		; Set palette 2 for the black tile to be actually black
		lda #$3f
		sta PPUADDR
		lda #$19
		sta PPUADDR
		lda #$0f
		sta PPUDATA

		; Recycle characters' portraits sprites to hide damage counter
		.(
			jmp data_end
				portrait_sprites_x:
					.byt 64, 72, 80, 88, 64, 72, 80, 88
			data_end:

			ldy #INGAME_PORTRAIT_LAST_SPRITE*4
			ldx #7
			loop:
				lda #207
				sta oam_mirror+0, y
				lda #TILE_BLACK
				sta oam_mirror+1, y
				lda #2
				sta oam_mirror+2, y
				lda portrait_sprites_x, x
				sta oam_mirror+3, y

				dey:dey:dey:dey
				dex
				bpl loop
		.)

		; Rewrite empty stock icon as a black tile
		lda PPUSTATUS
		lda #>($1000+(INGAME_CHARACTER_EMPTY_STOCK_TILE*16))
		sta PPUADDR
		lda #<($1000+(INGAME_CHARACTER_EMPTY_STOCK_TILE*16))
		sta PPUADDR
		ldx #16
		lda #%00000000
		jsr ppu_fill

		; Rewrite character illustrations as black tiles
		lda PPUSTATUS
		lda #$1d
		sta PPUADDR
		lda #$00
		sta PPUADDR
		ldx #16*5
		lda #%00000000
		jsr ppu_fill
	.)

	; Init Sinbad state + pos to be crashing on ground instead of spawning
	START_X = 16
	START_Y = 16
	VELOCITY_H = $0300
	VELOCITY_V = $ff00

	lda #START_X
	sta player_a_x
	lda #START_Y
	sta player_a_y
	lda #0
	sta player_a_x_screen
	sta player_a_y_screen
	sta player_a_x_low
	sta player_a_y_low

	lda #<VELOCITY_H
	sta player_a_velocity_h_low
	lda #>VELOCITY_H
	sta player_a_velocity_h
	lda #<VELOCITY_V
	sta player_a_velocity_v_low
	lda #>VELOCITY_V
	sta player_a_velocity_v

	lda #PLAYER_STATE_THROWN
	ldx #0
	sta player_a_state, x
	ldy config_player_a_character, x
	lda characters_start_routines_table_lsb, y
	sta tmpfield1
	lda characters_start_routines_table_msb, y
	sta tmpfield2
	TRAMPOLINE(player_state_action, characters_bank_number COMMA y, #CURRENT_BANK_NUMBER)
}

draw_digit:
.(
	value = tmpfield1
	digit = tmpfield2
	write_began = tmpfield3
	digit_mask = tmpfield4

	; Store mask
	stx digit_mask

	; Compute digit
	lda #TILE_CHAR_0
	sta digit
	lda value
	compute_loop:
	cmp digit_mask
	bcc compute_ok
		inc digit
		sec
		sbc digit_mask
		jmp compute_loop
	compute_ok:

	; Store updated value
	sta value

	; Draw digit
	lda write_began
	bne do_write
	lda digit_mask
	cmp #1
	beq do_write
	lda digit
	cmp #TILE_CHAR_0
	beq skip_write

		do_write:
		lda digit
		sta PPUDATA
		lda #1
		sta write_began

	skip_write:

	rts
.)

!define "extra_tick" {
	; Check player position, return to arcade or title screen if in trigger areas
	.(
		; Return to title screen if on the left
		SIGNED_CMP(player_a_x,player_a_x_screen, #<$fff0,#>$fff0)
		bpl no_title_screen
			lda #GAME_STATE_TITLE
			jmp change_global_game_state
			; No return
		no_title_screen:

		; Return to arcade mode if on the right
		SIGNED_CMP(player_a_x,player_a_x_screen, #<$0100,#>$0100)
		bmi no_continue
			lda #$ff
			sta arcade_mode_last_game_winner
			lda #GAME_STATE_ARCADE_MODE
			jmp change_global_game_state
			; No return
		no_continue:
	.)

	;TODO? hide sinbad sprites on black bands
}
!include "stages/std_stage.asm"

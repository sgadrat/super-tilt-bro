;TODO make it relocatable, to be executable from RAM
rescue:
.(
	current_sector = $00
	num_blocks = $01
	current_write_addr = $02
	current_write_addr_msb = $03

	; Set banking to 8+8+8+8 mode
	lda #1
	sta RAINBOW_CONFIGURATION ; change PRG mode to mode 1
	sta RAINBOW_PRG_BANKING_2 ; select 8K bank @ $A000
	lda #2
	sta RAINBOW_PRG_BANKING_3 ; select 8K bank @ $C000

	;TODO check ROM file existence

	; Open factory ROM file
	lda #<cmd_open_file
	ldx #>cmd_open_file
	jsr esp_send_cmd_short

	; Flash each sector
	lda #0
	sta current_sector
	flash_one_sector:
	.(
		; Select sector's bank
		lda current_sector
		lsr
		sta RAINBOW_PRG_BANKING_1

		; Store sector's address
		.(
			lda #%00000001
			bit current_sector
			bne second_sector
				first_sector:
					lda #$80
					bne write_val ; trick, always taken BNE (saves one byte over JMP)
				second_sector:
					lda #$90
			write_val:

			sta current_write_addr_msb
			lda #0
			sta current_write_addr
		.)

		; Enter erase sequence
		lda #$aa
		sta $d555
		lda #$55
		sta $aaaa
		lda #$80
		sta $d555

		; Erase sector
		lda #$aa
		sta $d555
		lda #$55
		sta $aaaa

		.(
			lda #$30
			ldy #0
			sta (current_write_addr), y
		.)

		; Rewrite sector, reading the file per blocks of 128 bytes (so there is 32 blocks per 4KB sector)
		lda #32
		sta num_blocks
		write_one_block:
		.(
			; Read one block
			lda #<cmd_read_block
			ldx #>cmd_read_block
			jsr esp_send_cmd_short

			;TODO remove me, dbug
			lda PPUSTATUS
			lda #$3f
			sta PPUADDR
			lda #$00
			sta PPUADDR
			lda #$20
			sta PPUDATA

			wait_answer:
				bit RAINBOW_FLAGS
				bpl wait_answer

			;TODO remove me, dbug
			lda PPUSTATUS
			lda #$3f
			sta PPUADDR
			lda #$00
			sta PPUADDR
			lda #$18
			sta PPUDATA

			; Burn response header
			lda RAINBOW_DATA ; Garbage byte
			nop
			lda RAINBOW_DATA ; Message length
			nop
			lda RAINBOW_DATA ; FROMESP_MSG_FILE_DATA
			nop
			lda RAINBOW_DATA ; Data length (should be 128, unless the file is shorter than expected)
			nop

			; Write data
			ldy #0
			write_one_byte:
			.(
				; Write byte sequence
				lda #$aa
				sta $d555
				lda #$55
				sta $aaaa
				lda #$a0
				sta $d555

				lda RAINBOW_DATA            ; value to write
				sta (current_write_addr), y ; destination address

				iny
				cpy #128
				bne write_one_byte
			.)

			; Update write pointer
			.(
				; current_write_addr,current_write_addr_msb += 128
				lda #%10000000
				eor current_write_addr
				sta current_write_addr
				bne ok
					inc current_write_addr_msb
				ok:
			.)

			; Loop
			dec num_blocks
			bne write_one_block
		.)

		; Loop
		inc current_sector
		lda current_sector
		cmp #127 ;TODO select between 128 (full rom flashing) or 127 (avoid flashing last sector)
		beq end
			jmp flash_one_sector
		end:
	.)

	; Restart
	jmp ($fffc)

	cmd_open_file:
		.byt 3, TOESP_MSG_FILE_OPEN, ESP_FILE_PATH_ROMS, 0
	cmd_read_block:
		.byt 2, TOESP_MSG_FILE_READ, 128
.)
rescue_end:

#echo
#echo rescue code size:
#print rescue_end-rescue

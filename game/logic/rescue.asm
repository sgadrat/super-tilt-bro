.(

current_sector = $00
num_blocks = $01
current_write_addr = $02
current_write_addr_msb = $03

; Self flash the PRG with raw ROM file in ESP/ROMS/0, and reboot
;
;  - Expects NMI to be disabled
&rescue:
.(
	;TODO check ROM file existence

#ifdef RESCUE_AUDIO_DEBUG
	; Enable noise channel to be able to output debug sounds
	lda #%00001000 ; ---DNT21
	sta APU_STATUS

	; Blip
	lda #%00000010         ; --LCVVVV
	sta APU_NOISE_ENVELOPE ;
	lda #%00000111       ; L---PPPP
	sta APU_NOISE_PERIOD ;
	lda #%10110000           ; LLLLL---
	sta APU_NOISE_LENGTH_CNT
#endif

	; Enable debug output
	lda #<cmd_set_debug
	ldx #>cmd_set_debug
	jsr esp_send_cmd_short

	; Open factory ROM file
	lda #<cmd_open_file
	ldx #>cmd_open_file
	jsr esp_send_cmd_short

	; Flash safe sectors
	jsr flash_safe_sectors_and_return

	;TODO Select between flashing the static sector or reset there
	jmp ($fffc)
	;rts ; useless, jumped to reset vector

	cmd_open_file:
		.byt 3, TOESP_MSG_FILE_OPEN, ESP_FILE_PATH_ROMS, 0

	cmd_set_debug:
		.byt 2, TOESP_MSG_DEBUG_SET_LEVEL, 3
.)


; Self flash the PRG with data read from open ESP file, and reboot
;
;  - Expects NMI to be disabled
;  - Expects to be able to read 127 blocks of 4KB with ESP FILE_READ commands
;  - Does not flash the last sector (containing rescue code)
&flash_safe_sectors:
.(
	; Flash sectors
	jsr flash_safe_sectors_and_return

	; Reset
	jmp ($fffc)
.)

; Self flash the PRG with data read from open ESP file, and reboot
;
;  - Expects NMI to be disabled
;  - Expects to be able to read 128 blocks of 4KB with ESP FILE_READ commands
;  - Flashes the last sector (containing rescue code), this is unsafe, may need to reprogram the ROM externally on fail
&flash_all_sectors:
.(
	; Flash sectors
	jsr flash_safe_sectors_and_return
	jmp flash_static_sector
.)

flash_static_sector:
.(
	;TODO copy flash_one_sector in memory, and flash the static sector
	;TODO flash_one_sector shall be relocatable for that

	; Reset
	jmp ($fffc)
.)

flash_safe_sectors_and_return:
.(
	; Set banking to 8+8+8+8 mode
	lda #1
	sta RAINBOW_CONFIGURATION ; change PRG mode to mode 1
	sta RAINBOW_PRG_BANKING_2 ; select 8K bank @ $A000
	lda #2
	sta RAINBOW_PRG_BANKING_3 ; select 8K bank @ $C000

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
			;TODO not relocatable - absolute address of cmd_read_block, and dependency on external routine
			lda #<cmd_read_block
			ldx #>cmd_read_block
			jsr esp_send_cmd_short

			wait_answer:
				bit RAINBOW_FLAGS
				bpl wait_answer

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
		cmp #127 ; Notice, 127 sectors, do not override the last (128th) sector
		beq end
			jmp flash_one_sector ; TODO not relocatable, absolute address of flash_one_sector
		end:
	.)

	; Return
	rts

	cmd_read_block:
		.byt 2, TOESP_MSG_FILE_READ, 128
.)
rescue_end:

#echo
#echo rescue code size:
#print rescue_end-rescue

.)

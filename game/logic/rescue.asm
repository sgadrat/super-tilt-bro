.(

current_sector = $00
num_blocks = $01
current_write_addr = $02
current_write_addr_msb = $03

flash_sectors_ram = $300

; About read sequences, pin names, etc in comments, read the doc
;  https://github.com/BrokeStudio/rainbow-lib/blob/master/rainbow-prg-rom-self-flashing.md
;  http://ww1.microchip.com/downloads/en/DeviceDoc/20005022C.pdf

; Self flash the PRG with raw ROM file in ESP/ROMS/0, and reboot
;
;  - Expects NMI to be disabled
&rescue:
.(
	;TODO check ROM file existence

	; Enable noise channel to be able to output debug sounds
	lda #%00001000 ; ---DNT21
	sta APU_STATUS

#if 0
	; Disabled, the operation is slown a lot when logs are activated
	; Enable debug output
	lda #<cmd_set_debug
	ldx #>cmd_set_debug
	jsr esp_send_cmd_short
#endif

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

#if 0
	cmd_set_debug:
		.byt 2, TOESP_MSG_DEBUG_SET_LEVEL, 3
#endif
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

	; Copy flash_sectors routine in RAM
	copy_ptr_rom = tmpfield1
	copy_ptr_ram = tmpfield3

	lda #<flash_sectors_rom
	sta copy_ptr_rom
	lda #>flash_sectors_rom
	sta copy_ptr_rom+1
	lda #<flash_sectors_ram
	sta copy_ptr_ram
	lda #>flash_sectors_ram
	sta copy_ptr_ram+1

	copy_routine:
	.(
		copy_one_page:
		.(
			ldy #0
			copy_one_byte:
				lda (copy_ptr_rom), y
				sta (copy_ptr_ram), y
				iny
				bne copy_one_byte

			inc copy_ptr_rom+1
			inc copy_ptr_ram+1
		.)

		; Copy pages until msb of pointer > msb routine's end
		lda flash_sectors_rom+1
		beq ok
		lda #>end_flash_sector_rom
		cmp flash_sectors_rom+1
		bcs copy_one_page
		ok:
	.)

	; Call flash_sectors
	jsr flash_sectors_ram

	; Return
	rts

	cmd_read_block:
		.byt 2, TOESP_MSG_FILE_READ, 128
.)

; Flash each sector
flash_sectors_rom:
.(
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
					bne write_val ; trick, always taken BNE (saves one byte over JMP, and is relocatable)
				second_sector:
					lda #$90
			write_val:

			sta current_write_addr_msb
			lda #0
			sta current_write_addr
		.)

		; Enter erase sequence
		jsr flash_sectors_ram+(erase_sector_sequence-flash_sectors_rom)

		BLOCK_SIZE = 128
		; Rewrite sector, reading the file per blocks of 128 bytes (so there is 32 blocks per 4KB sector)
		lda #(4096 / BLOCK_SIZE)
		sta num_blocks
		write_one_block:
		.(
			; Read one block
			wait_esp_ready:
				bit RAINBOW_FLAGS
				bmi wait_esp_ready

			lda #2
			sta RAINBOW_DATA
			lda #TOESP_MSG_FILE_READ
			sta RAINBOW_DATA
			lda #BLOCK_SIZE
			sta RAINBOW_DATA

			wait_answer:
				bit RAINBOW_FLAGS
				bpl wait_answer

			; Burn response header
			;  Garbage byte
			;  Message length
			;  FROMESP_MSG_FILE_DATA
			;  Data length (should be BLOCK_SIZE, unless the file is shorter than expected)
			ldx #4
			burn_byte:
				lda RAINBOW_DATA
				dex
				bne burn_byte

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
				sta tmpfield1

				; Wait programation execution
				;  Must read the expected value twice in a row, ensuring DQ6 oscilating behaviour ended
				wait_write_complete:
					lda (current_write_addr), y
					cmp tmpfield1
					bne wait_write_complete
					lda (current_write_addr), y
					cmp tmpfield1
					bne wait_write_complete

				iny
				cpy #BLOCK_SIZE
				bne write_one_byte
			.)

			; Update write pointer
			.(
#if BLOCK_SIZE = 128
				; current_write_addr,current_write_addr_msb += 128
				lda #%10000000
				eor current_write_addr
				sta current_write_addr
				bne ok
					inc current_write_addr_msb
				ok:
#else
				lda current_write_addr
				clc
				adc #BLOCK_SIZE
				sta current_write_addr
				lda current_write_addr_msb
				adc #0
				sta current_write_addr_msb
#endif
			.)

			; Loop
			dec num_blocks
			bne write_one_block
		.)

		; Loop
		inc current_sector
		lda current_sector
		cmp #127 ; Notice, 127 sectors, do not override the last (128th) sector
		bne flash_one_sector
	.)

	; Return
	rts

	erase_sector_sequence:
	.(
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

		; Blip
		lda #%00000010         ; --LCVVVV
		sta APU_NOISE_ENVELOPE ;
		lda #%00000111       ; L---PPPP
		sta APU_NOISE_PERIOD ;
		lda #%10110000           ; LLLLL---
		sta APU_NOISE_LENGTH_CNT

		; Wait erase execution
		;  Wait for the value to be the erased byte, reading it once while erasing, DQ7 is forced to zero
		wait_completion:
			lda (current_write_addr), y
			cmp #$ff
			bne wait_completion

		rts
	.)
.)
end_flash_sector_rom:

rescue_end:

#echo
#echo rescue code size:
#print rescue_end-rescue

.)

;; Flashing operations, with special care of keeping a maximum of info about failures
;;
;; Here's the chip's datasheet, comments reference it a lot
;;   www.infineon.com/dgdl/Infineon-S29GL064S_64-MBIT_(8_MBYTE)_3.0_V_FLASH_MEMORY-DataSheet-v09_00-EN.pdf?fileId=8ac78c8c7d0d8da4017d0ed12bd84d2d

.(
erase_sector_rom = *
* = $0200
erase_sector_ram:
.(
	; Erase command sequence
	lda #$aa
	ldx #$55
	ldy #$80

	sta $8aaa
	stx $8555
	sty $8aaa
	sta $8aaa
	stx $8555

	; Actual sector erase command
	lda #$30
	sta $8000

	; Wait for operation end
	.(
		;; Implementation of "Figure 14 Toggle bit algorithm" with tweaks
		;;  - Simplified by reading two bytes after the loop, instead of looping between both reads
		;;  - Added a hard timeout of roughly 10 seconds, at this point we inform the user even if DQ5 is still unset
		;;      Sector erase time - 1000 ms MAX
		;;      Programming time  - 1200 us MAX
		;;      (See tables 78 and 79)

		timeout_byte0 = erase_sector_status
		timeout_byte1 = erase_sector_status+1
		timeout_byte2 = erase_sector_status+2

		; Init timeout counter
		lda #0
		sta timeout_byte0
		sta timeout_byte1
		sta timeout_byte2

		wait_same_value:
			; Increment timeout counter
			.(
				; An iteration is >= 24 cycles
				;  $0d0000 iterations is > 10 seconds (counting 0.5 us per cycle)
				inc timeout_byte0
				bne ok
					inc timeout_byte1
					bne ok
						inc timeout_byte2
						lda timeout_byte2
						cmp #$0d
						beq timeout
				ok:
			.)

			; Read twice, success if the value doesn't change (we are reading flash data)
			lda $8000
			cmp $8000
			beq success

			; Value changed, the first read is status bits, the second may be status or data
			; Check DQ5 (Exceeded timing limits)
			lda $8000
			and #%00100000
			beq wait_same_value

			; DQ5 is set, it may be that we are reading the programed data (success) or timeout happened (failure)
			; Read twice to know if we are reading data or status bits
			lda $8000
			cmp $8000
			beq success
			bne failure ; equivalent to "jmp failure" (saving a byte)

		success:
			; I love it when a plan comes together
			lda #$00
			sta erase_sector_result
			rts

		timeout:
			; The erase is still in progress, for way longer than permitted by the datasheet
			; Sad news, it seems that there is no way to cancel it to fail properly
			;  Only valid command is "Erase Suspend" which pauses the erasure, then we can resume but not cancel
			;
			; Suspend the erase operation, so we can return executing code on other sectors (our caller is not on the erased sector)

			; Write "Erase Suspend" command
			;  tESL = 30 us MAX
			lda #$b0
			sta $8000

			; Wait for fixed bank to be readable
			;  This is longer than 30 us
			ldy #30
			timeout_wait:
				dey
				bne timeout_wait

			; Check that fixed bank is readable
			;  Try multiple times, if it definitely fails handle the error while staying on RAM
			ldy #30
			timeout_check:
			.(
				dey
				bne ok
					jmp fatal_timeout
				ok:

				lda $c000
				cmp $c000
				bne timeout_check
			.)

			; Set result
			lda #$81
			sta erase_sector_result
			rts

		failure:
			; The erase failed and the chip detected it correctly
			;
			; Set the chip in a usable state before returning the error code, so the flashing can continue

			; Write RESET command to return the flash in reading mode
			lda #$f0
			sta $8000

			; Wait for return to reading mode
			;  tTOR = 2 us MAX
			;  (that's approximatively 4 6502-cycles, wait a bigger timeout)
			ldy #5
			fail_wait:
				dey
				beq fail_wait_abort

				lda $8000
				cmp $8000
				bne fail_wait
			fail_wait_abort:

			; Check if we timeouted
			cpy #0
			beq failure_unusable
				failure_usable:
					; The chip is back in reading mode
					lda #$02
					sta erase_sector_result
					rts
				failure_unusable:
					; The chip still outputs garbage
					lda #$82
					sta erase_sector_result
					rts

			;rts ; useless, all branches return
	.)

	;rts ; useless, all branches return
.)

flash_wait_vbi:
.(
	bit PPUSTATUS
	vblankwait:
		bit PPUSTATUS
		bpl vblankwait
	rts
.)

write_str:
.(
	addr = erase_sector_status

	sta PPUADDR

	stx addr
	sty addr+1

	ldy #$ff
	write_byte:
		iny
		lda (addr), y
		sta PPUDATA
		bne write_byte

	; Fallthrough to flash_post_vbi
.)

flash_post_vbi:
.(
	lda PPUSTATUS
	lda #0
	sta PPUSCROLL
	sta PPUSCROLL

	lda PPUCTRL
	and #%11111100 ; set scroll bits to zero
	sta PPUCTRL

	rts
.)

fatal_timeout:
.(
	ppu_addr = $2323

	; Wait VBI
	jsr flash_wait_vbi

	; Write first line
	.(
		;bit PPUSTATUS ; useless, done by flash_wait_vbi
		lda #>ppu_addr
		sta PPUADDR
		lda #<ppu_addr
		ldx #<first_line
		ldy #>first_line
		jsr write_str
	.)

	; Wait VBI
	jsr flash_wait_vbi

	; Write first line
	.(
		;bit PPUSTATUS ; useless, done by flash_wait_vbi
		lda #>(ppu_addr+$20)
		sta PPUADDR
		lda #<(ppu_addr+$20)
		ldx #<second_line
		ldy #>second_line
		jsr write_str
	.)

	; Never return
	trap:
		jsr flash_wait_vbi
		jsr flash_post_vbi
	jmp trap

	first_line:
		.byt "ERROR operation timeout", 0
	second_line:
		.byt "Please shutdown, and retry.", 0
.)
erase_sector_end = *
erase_sector_size = erase_sector_end - erase_sector_ram
* = erase_sector_rom + erase_sector_size

; Erase a flash sector
;  Swapable bank must be on the first bank of the sector
;
;  Return value in erase_sector_result
;   U... RRRR
;   |    \____ Result
;   \_________ Usable - 0 if the chip can be used, 1 if it is in an unstable state
;
;  Result values
;   - 0, Success
;   - 1, Timeout
;   - 2, Failure
;
;  If the chip is in an unstable state, there is no better solution than power-off/power-on the system
+erase_sector:
.(
	; Copy real implementation in RAM
	rom_addr = erase_sector_status
	ram_addr = erase_sector_status+2 ; Note - this works because we can safely overflow on erase_sector_result

	lda #<erase_sector_rom
	sta rom_addr
	lda #>erase_sector_rom
	sta rom_addr+1

	lda #<erase_sector_ram
	sta ram_addr
	lda #>erase_sector_ram
	sta ram_addr+1

	copy_one_page:

		; Copy page's bytes
		ldy #0
		copy_one_byte:
			lda (rom_addr), y
			sta (ram_addr), y

			iny
			bne copy_one_byte

		; Update pointers
		inc ram_addr+1
		inc rom_addr+1

		; Check if we copied all necessary pages
		lda ram_addr+1
		cmp #>(erase_sector_end+$0100)
		bne copy_one_page

	; Execute from RAM
	jmp erase_sector_ram
	;rts ; useless, jump to subroutine
.)
.)

;; Flashing operations, with special care of keeping a maximum of info about failures
;;
;; Here's the chip's datasheet, comments reference it a lot
;;   www.infineon.com/dgdl/Infineon-S29GL064S_64-MBIT_(8_MBYTE)_3.0_V_FLASH_MEMORY-DataSheet-v09_00-EN.pdf?fileId=8ac78c8c7d0d8da4017d0ed12bd84d2d

.(
flash_code_rom = *
* = flash_code_ram

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
;   - 3, Internal error in wait routine (should never happen)
;   - any other value, bug in this routine
;
;  If the chip is in an unstable state, there is no better solution than power-off/power-on the system
+rescue_erase_sector:
.(
	; Erase command sequence
	lda #$aa
	sta $8aaa
	lda #$55
	sta $8555
	lda #$80
	sta $8aaa
	lda #$aa
	sta $8aaa
	lda #$55
	sta $8555

	; Actual sector erase command
	lda #$30
	sta $8000

	; Wait for operation end
	.(
		jump_address = flash_operation_status

		lda #$00
		sta flash_operation_address
		lda #$80
		sta flash_operation_address+1
		ldy #0
		jsr wait_write_end

		cpx #4
		bcs internal_error
		lda operation_handlers_lsb, x
		sta jump_address
		lda operation_handlers_msb, x
		sta jump_address+1
		jmp (jump_address)

			internal_error:
				; This is a bug, wait_write_end should never return undocumented error codes
				;
				; Check that fixed bank is readable
				;  Try multiple times, if it definitely fails handle the error while staying on RAM
				ldy #30
				internal_check:
				.(
					dey
					bne ok
						jmp fatal_internal
					ok:

					lda $c000
					cmp $c000
					bne timeout_check
				.)

				lda #$03
				sta erase_sector_result
				rts

			success:
				; Everything went fine
				lda #$00
				sta erase_sector_result
				rts

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

		operation_handlers_lsb:
			.byt <success, <timeout, <failure_usable, <failure_unusable
		operation_handlers_msb:
			.byt >success, >timeout, >failure_usable, >failure_unusable
	.)

	;rts ; useless, all branches return
.)

; Program a page of the flash
;  flash_operation_address - address of the first byte in the page
;  program_data - data to write
;
; Output
;  program_page_result_flags - F... ...E
;   F - Fatal error, the chip is in unknown state. The wisest thing to do is to power off the NES.
;   E - Error, set if any error (fatal or not) has happened
;
; program_page_result_count - Number of errors that happened
;  Zero means 256 if E flag is set
+rescue_program_page:
.(
	; Init result values
	lda #0
	sta program_page_result_flags
	sta program_page_result_count

	; Program byte by byte
	;  We avoid write buffer programming for compatibility reasons
	ldy #0
	program_one_byte:
		; Program byte
		lda #$aa
		sta $8aaa
		lda #$55
		sta $8555
		lda #$a0
		sta $8aaa

		lda program_data, y
		sta (flash_operation_address), y

		; Wait operation end
		jsr wait_write_end

		; Check operation result
		cpx #0
		bne operation_failed

			program_next_byte:
				iny
				bne program_one_byte
				rts

			operation_failed:
			.(
				; Count the error
				inc program_page_result_count

				; Set error flag
				lda program_page_result_flags
				ora #%00000001
				sta program_page_result_flags

				; Handle fatal cases
				cpx #1
				beq fatal
				cpx #3
				bne program_next_byte
					fatal:
						; Check if ROM is readable
						lda $c000
						cmp $c000
						beq rom_ok

							rom_unreadable:
								; Stay in RAM to display an error message
								jmp fatal_program

							rom_ok:
								; Set fatal flag and return immediately
								lda program_page_result_flags
								ora #%10000000
								sta program_page_result_flags

								rts
			.)

	;rts ; useless, no branch return
.)

; Wait for an Erase or Program command to end
;  (flash_operation_address), y - Adresse where to read status bits
;
; Output
;  Register X
;   0 - success
;   1 - timeout
;   2 - failure (chip reseted to read mode)
;   3 - failure (unable to come back to read mode)
;   any other - bug
;
; Overwrites flash_operation_status, A, X
wait_write_end:
.(
	;; Implementation of "Figure 14 Toggle bit algorithm" with tweaks
	;;  - Simplified by reading two bytes after the loop, instead of looping between both reads
	;;  - Added a hard timeout of roughly 10 seconds, at this point we inform the user even if DQ5 is still unset
	;;      Sector erase time - 1000 ms MAX
	;;      Programming time  - 1200 us MAX
	;;      (See tables 78 and 79)

	timeout_byte0 = flash_operation_status
	timeout_byte1 = flash_operation_status+1
	timeout_byte2 = flash_operation_status+2

	; Init timeout counter
	lda #0
	sta timeout_byte0
	sta timeout_byte1
	sta timeout_byte2

	wait_same_value:
		; Increment timeout counter
		.(
			; An iteration is >= 27 cycles
			;  $0c0000 iterations is > 10 seconds (counting 0.5 us per cycle)
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
		lda (flash_operation_address), y
		cmp (flash_operation_address), y
		beq success

		; Value changed, the first read is status bits, the second may be status or data
		; Check DQ5 (Exceeded timing limits)
		lda (flash_operation_address), y
		and #%00100000
		beq wait_same_value

		; DQ5 is set, it may be that we are reading the programed data (success) or timeout happened (failure)
		; Read twice to know if we are reading data or status bits
		lda (flash_operation_address), y
		cmp (flash_operation_address), y
		beq success
		bne failure ; equivalent to "jmp failure" (saving a byte)

	success:
		; I love it when a plan comes together
		ldx #$00
		rts

	timeout:
		; The operation is still in progress, for way longer than permitted by the datasheet
		ldx #$01
		rts

	failure:
		; The operation failed and the chip detected it correctly
		;
		; Set the chip in a usable state before returning the error code, so the flashing can continue

		; Write RESET command to return the flash in reading mode
		lda #$f0
		sta (flash_operation_address), y

		; Wait for return to reading mode
		;  tTOR = 2 us MAX
		;  (that's approximatively 4 6502-cycles, wait a bigger timeout)
		ldx #5
		fail_wait:
			dex
			beq fail_wait_abort

			lda (flash_operation_address), y
			cmp (flash_operation_address), y
			bne fail_wait
		fail_wait_abort:

		; Check if we timeouted
		cpx #0
		beq failure_unusable
			failure_usable:
				; The chip is back in reading mode
				ldx #$02
				rts
			failure_unusable:
				; The chip still outputs garbage
				ldx #$03
				rts

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
	addr = flash_operation_status

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
	ldx #<msg
	ldy #>msg
	jmp fatal_common

	msg:
		.byt "ERROR operation timeout", 0
.)

fatal_internal:
.(
	ldx #<msg
	ldy #>msg
	jmp fatal_common

	msg:
		.byt "ERROR operation wait fail", 0
.)

fatal_program:
.(
	ldx #<msg
	ldy #>msg
	jmp fatal_common

	msg:
		.byt "ERROR write operation fail", 0
.)

fatal_common:
.(
	ppu_addr = $2323

	; Write first line
	.(
		;bit PPUSTATUS ; useless, done by flash_wait_vbi
		lda #>ppu_addr
		sta PPUADDR
		lda #<ppu_addr
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

	second_line:
		.byt "Please shutdown, and retry.", 0
.)
flash_code_end = *
flash_code_size = flash_code_end - flash_code_ram
* = flash_code_rom + flash_code_size

; Place flash code in RAM
;  Call this before any call on a flashing routine
+rescue_prepare_flash_code:
.(
	; Copy real implementation in RAM
	rom_addr = flash_operation_status
	ram_addr = flash_operation_status+2 ; Note - this works because we can safely overflow on erase_sector_result

	lda #<flash_code_rom
	sta rom_addr
	lda #>flash_code_rom
	sta rom_addr+1

	lda #<flash_code_ram
	sta ram_addr
	lda #>flash_code_ram
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
		cmp #>(flash_code_end+$0100)
		bne copy_one_page

	rts
.)
.)

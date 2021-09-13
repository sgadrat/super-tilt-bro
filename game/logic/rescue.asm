.(

current_sector = $00
num_blocks = $01
current_write_addr = $02
current_write_addr_msb = $03
num_sectors_to_flash = $04
num_failed_erase = $05
num_failed_write = $06
last_num_failed_erase = $07
last_num_failed_write = $08
timeout_count_msb = $09

rescue_oam_mirror = $200
flash_sectors_ram = $300

PROGRESS_BAR_POS = $29e8
PROGRESS_BAR_LEN = 16

; About read sequences, pin names, etc in comments, read the doc
;  https://github.com/BrokeStudio/rainbow-lib/blob/master/rainbow-prg-rom-self-flashing.md
;  http://ww1.microchip.com/downloads/en/DeviceDoc/20005022C.pdf

; Self flash the PRG with raw ROM file in ESP/ROMS/0, and reboot
;  Register A - 0 to flash only safe sectors, 1 to flash all sectors
;
;  - Expects NMI to be disabled
&rescue:
.(
	; Save parameter
	pha

	; ESP enable, the full ultra safe sequence
	lda #%00000001    ; Enable communication with the ESP
	sta RAINBOW_FLAGS

	lda #<esp_cmd_clear_buffers ; Clear RX/TX buffers
	ldx #>esp_cmd_clear_buffers
	jsr esp_send_cmd_short

	ldx #2              ; Wait two frames for the clear to happen
	bit PPUSTATUS
	vblank_wait:
		bit PPUSTATUS
		bpl vblank_wait
	dex
	bne vblank_wait

	wait_empty_buffer:        ; Be really sure that the clear happened
		bit RAINBOW_FLAGS
		bmi wait_empty_buffer

	lda #<esp_cmd_get_esp_status ; Wait for ESP to be ready
	ldx #>esp_cmd_get_esp_status
	jsr esp_send_cmd_short
	jsr esp_wait_answer

	lda RAINBOW_DATA ; Burn garbage byte

	.( ; Message length, must be 1
		ldx RAINBOW_DATA
		cpx #1
		beq ok
			jmp fatal_failure
		ok:
	.)

	.( ; Message type, must be READY
		lda RAINBOW_DATA
		cmp #FROMESP_MSG_READY
		beq ok
			jmp fatal_failure
		ok:
	.)

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

	; Check ROM file existence
	.(
		lda #<esp_cmd_rom_file_exists
		ldx #>esp_cmd_rom_file_exists
		jsr esp_send_cmd_short
		jsr esp_wait_answer

		lda RAINBOW_DATA ; Garbage byte
		nop

		lda RAINBOW_DATA
		cmp #2
		beq expected_length
			jmp fatal_failure
		expected_length:

		lda RAINBOW_DATA ; Message type
		cmp #FROMESP_MSG_FILE_EXISTS
		beq expected_type
			jmp fatal_failure
		expected_type:

		lda RAINBOW_DATA ; Result - 0, file not found - 1, file exists
		bne file_exists ; loosy condition, accept any other value than 0 - better allow flashing if ESP_FILE_EXISTS api was extended
			jmp fatal_failure
		file_exists:
	.)

	; Open factory ROM file
	lda #<cmd_open_file
	ldx #>cmd_open_file
	jsr esp_send_cmd_short

	; Flash sectors according to parameter
	pla
	bne flash_all_sectors
	jmp flash_safe_sectors

	;rts ; useless, jumped to subroutine

	cmd_open_file:
		.byt 4, TOESP_MSG_FILE_OPEN, ESP_FILE_MODE_AUTO, ESP_FILE_PATH_ROMS, 0

	esp_cmd_rom_file_exists:
		.byt 4, TOESP_MSG_FILE_EXISTS, ESP_FILE_MODE_AUTO, ESP_FILE_PATH_ROMS, 0

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
	lda #127
	jmp flash_sectors_launch
.)

; Self flash the PRG with data read from open ESP file, and reboot
;
;  - Expects NMI to be disabled
;  - Expects to be able to read 128 blocks of 4KB with ESP FILE_READ commands
;  - Flashes the last sector (containing rescue code), this is unsafe, may need to reprogram the ROM externally on fail
&flash_all_sectors:
.(
	; Flash sectors
	lda #128
	;jmp flash_sectors_launch ; useless, fallthrough
.)

flash_sectors_launch:
.(
	; Save parameter
	sta num_sectors_to_flash

	; Set banking to 8+8+8+8 mode
	lda #%00011111 ; ssmm.rccp
	sta RAINBOW_CONFIGURATION ; change PRG mode to mode 1
	lda #1
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
		lda copy_ptr_rom+1
		beq ok
		lda #>end_flash_sector_rom
		cmp copy_ptr_rom+1
		bcs copy_one_page
		ok:
	.)

	; Call flash_sectors
	jsr prepare_display
	jmp flash_sectors_ram

	;rts ; useless, jump to a subroutine that never returns anyway
.)

&prepare_display:
.(
	&RESCUE_TILE_FILL_0 = 0
	&RESCUE_TILE_FILL_1 = 3
	&RESCUE_TILE_FILL_2 = 1
	&RESCUE_TILE_FILL_3 = 2
	RESCUE_TILE_DELIM_LEFT = 4
	RESCUE_TILE_DELIM_RIGHT = 5

	; Copy chr tiles
	bit PPUSTATUS
	lda #$00
	sta PPUADDR
	sta PPUADDR

	lda #%00000000 ; Filled tiles, in order "0, 2, 3, 1"
	ldx #16+8
	jsr ppu_fill
	lda #%11111111
	ldx #8+16+8
	jsr ppu_fill
	lda #%00000000
	ldx #8
	jsr ppu_fill

	lda #%00000011 ; Vertical bar on the right of the tile
	ldx #8
	jsr ppu_fill
	lda #%00000000
	ldx #8
	jsr ppu_fill

	lda #%11000000 ; Vertical bar on the left of the tile
	ldx #8
	jsr ppu_fill
	lda #%00000000
	ldx #8
	jsr ppu_fill

	; Init palettes
	lda #$3f
	sta PPUADDR
	lda #$00
	sta PPUADDR
	lda #$21
	sta PPUDATA
	lda #$0f
	sta PPUDATA
	lda #$18
	sta PPUDATA
	lda #$16
	sta PPUDATA

	; Init OAM mirror
	ldx #0
	lda #$fe
	oam_mirror_loop:
		sta rescue_oam_mirror, x
		inx
		bne oam_mirror_loop

	; Draw nametable
	jsr clear_bg_bot_left

	bit PPUSTATUS
	lda #>(PROGRESS_BAR_POS-1)
	sta PPUADDR
	lda #<(PROGRESS_BAR_POS-1)
	sta PPUADDR
	lda #RESCUE_TILE_DELIM_LEFT
	sta PPUDATA
	lda #>(PROGRESS_BAR_POS+PROGRESS_BAR_LEN)
	sta PPUADDR
	lda #<(PROGRESS_BAR_POS+PROGRESS_BAR_LEN)
	sta PPUADDR
	lda #RESCUE_TILE_DELIM_RIGHT
	sta PPUDATA

	; Activate rendering
	jsr wait_vbi
	lda #%00000010 ; VPHB.SINN - don't enable NMI (not supported in rescue), sprites and BG both use pattern table 0, bot-left nametable
	sta PPUCTRL
	lda #%00011110 ; BGRs.bMmG
	sta PPUMASK
	lda #0
	sta PPUSCROLL
	sta PPUSCROLL

	; OAM DMA
	lda #$00
	sta OAMADDR
	lda #>rescue_oam_mirror
	sta OAMDMA

	rts
.)

fatal_failure:
.(
	jsr wait_vbi

	lda PPUSTATUS
	lda #$3f
	sta PPUADDR
	lda #$00
	sta PPUADDR
	lda #$16
	ldx #32
	testdll:
	sta PPUDATA
	dex
	bne testdll

	infinite_loop:
		bne infinite_loop
.)

; Flash each sector
flash_sectors_rom:
.(
	lda #0
	sta num_failed_erase
	sta num_failed_write
	sta last_num_failed_erase
	sta last_num_failed_write
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
				;
				;  Max time to write is 20 microseconds
				;   Considering 0.5 microseconds per cycle, we can timeout after 40 cycles
				.(
					LOOP_BEST_TIME_IN_CYCLES = 2+2+1+5+3+2+1
					SECURITY_MARGIN = 4
					NUM_ITERATIONS_BEFORE_TIMEOUT = (SECURITY_MARGIN * 20) / LOOP_BEST_TIME_IN_CYCLES
#if NUM_ITERATIONS_BEFORE_TIMEOUT <> 5
#error resulting timeout is not the expected one
#endif
					ldx #NUM_ITERATIONS_BEFORE_TIMEOUT+1
					wait_write_complete:
						dex ; 2 cycles
						bne continue ; 2+1 cycles
							; Timeout, increment num_failed_write (avoiding to loop to zero) and quit the loop
							inc num_failed_write
							bne end_wait_write_complete
							inc num_failed_write
							bne end_wait_write_complete
						continue:

						lda (current_write_addr), y ; 5 cycles
						cmp tmpfield1               ; 3 cycles
						bne wait_write_complete     ; 2+1 cycles
						lda (current_write_addr), y
						cmp tmpfield1
						bne wait_write_complete
					end_wait_write_complete:
				.)

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
		jsr flash_sectors_ram+(show_progress-flash_sectors_rom)
		lda current_sector
		cmp num_sectors_to_flash
		beq end
		jmp flash_sectors_ram+(flash_one_sector-flash_sectors_rom)
		end:
	.)

	; Last progress tick if num_sectors_to_flash is lower than 128
	;  Only known case is 127 (all but the last sector), we want to fill the bar to show if there was errors
	lda #128
	cmp num_sectors_to_flash
	beq end_last_progress_tick
		; lda #128 ; useless, done above
		sta current_sector
		jsr flash_sectors_ram+(show_progress-flash_sectors_rom)
	end_last_progress_tick:

	; Block if there was error to let time to see it
	.(
		lda num_failed_erase
		bne block
		lda num_failed_write
		beq ok
			block:
				bne block ; not a conditional jump, Z flag ensured to be clear

		ok:
	.)

	; Reset
	jmp ($fffc)

	show_progress:
	.(
		lda current_sector
		and #%00000111
		bne end

			; A = index of the tile to show
			lda current_sector
			lsr
			lsr
			lsr

			; Wait a vblank
			bit PPUSTATUS
			vblankwait:
				bit PPUSTATUS
				bpl vblankwait

			; Set PPU address to tile in the nametable
			;bit PPUSTATUS ; useless, done at least two times above
			clc
			adc #<(PROGRESS_BAR_POS-1)
			pha
			lda #0
			adc #>(PROGRESS_BAR_POS-1)
			sta PPUADDR
			pla
			sta PPUADDR

			; Compute next tile value
			;  FILL_1 - OK
			;  FILL_2 - Write failed
			;  FILL_3 - Sector erase failed
			.(
				lda num_failed_erase
				cmp last_num_failed_erase
				bne erase_failure
				lda num_failed_write
				cmp last_num_failed_write
				bne write_failure

					no_failure:
						lda #RESCUE_TILE_FILL_1
						bne ok
					erase_failure:
						lda #RESCUE_TILE_FILL_3
						bne ok
					write_failure:
						lda #RESCUE_TILE_FILL_2
#if RESCUE_TILE_FILL_1 = 0
#error above code expect RESCUE_TILE_FILL_1 not to be zero
#endif
#if RESCUE_TILE_FILL_3 = 0
#error above code expect RESCUE_TILE_FILL_3 not to be zero
#endif

				ok:

				pha

				lda num_failed_write
				sta last_num_failed_write
				lda num_failed_erase
				sta last_num_failed_erase
			.)

			; Write new tile value
			pla
			sta PPUDATA

			; Reset scrolling (may be modified by writes to PPUADDR)
			lda #0
			sta PPUSCROLL
			sta PPUSCROLL

		end:
		rts
	.)

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

		; Tchack!
		lda #%00000010         ; --LCVVVV
		sta APU_NOISE_ENVELOPE ;
		lda #%00000111       ; L---PPPP
		sta APU_NOISE_PERIOD ;
		lda #%10110000           ; LLLLL---
		sta APU_NOISE_LENGTH_CNT

		; Wait erase execution
		;  Wait for the value to be the erased byte, reading it once while erasing, DQ7 is forced to zero
		;
		;  Max time to erase is 25 milliseconds
		;   Considering 0.0005 miliseconds per cycle, we can timeout after 50,000 cycles
		LOOP_BEST_TIME_IN_CYCLES = 2+2+1+5+2+2+1
		NUM_ITERATIONS_BEFORE_MAX_TIME = 50000 / LOOP_BEST_TIME_IN_CYCLES
		NUM_ITERATIONS_BEFORE_TIMEOUT = NUM_ITERATIONS_BEFORE_MAX_TIME * 2
#if NUM_ITERATIONS_BEFORE_TIMEOUT <> $1a0a
#error resulting timeout is not the expected one
#endif
		lda #0
		sta timeout_count_msb
		tax
		wait_completion:
			inx          ; 2 cycles
			bne continue ; 2+1 cycles
				inc timeout_count_msb
				lda timeout_count_msb
				cmp #>(NUM_ITERATIONS_BEFORE_TIMEOUT)
				bne continue

					; Timeout, increment num_failed_erase (without looping to zero), and stop the loop
					inc num_failed_erase
					bne end_wait_completion
					inc num_failed_erase
					bne end_wait_completion
			continue:

			lda (current_write_addr), y ; 5 cycles
			cmp #$ff                    ; 2 cycles
			bne wait_completion         ; 2+1 cycles
		end_wait_completion:

		rts
	.)
.)
end_flash_sector_rom:

rescue_end:

#echo
#echo rescue code size:
#print rescue_end-rescue
#echo
#echo rescue code in RAM size:
#print end_flash_sector_rom-flash_sectors_rom

.)

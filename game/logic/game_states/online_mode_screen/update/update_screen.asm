+UPDATE_SCREEN_BANK_NUMBER = CURRENT_BANK_NUMBER

#include "game/logic/game_states/online_mode_screen/update/tileset_segments.asm"
#include "game/logic/game_states/online_mode_screen/update/update.built.asm"

;
; Constants
;

first_game_sector = 1
banks_per_sector = 4
segments_per_bank = 16
n_game_banks = 32
n_game_sectors = 8

sector_tile_none = 0
sector_tile_unchanged = 1
sector_tile_erased = 2
sector_tile_writing = 3
sector_tile_ok = 4
sector_tile_error = 5

;
; Code made to be run from RAM
;

flash_code_ram = $0200
flash_code_rom = *
* = flash_code_ram

; Specific macro here to avoid useless update of current_bank
#define FLASH_SWITCH_BANK(n) :\
	lda n:\
	sta RAINBOW_PRG_BANK_8000_MODE_1_LO

; List of the first bank in each sector to flash
; (reversed to iterate from end to start)
sector_banks:
	.byt (7+first_game_sector)*banks_per_sector
	.byt (6+first_game_sector)*banks_per_sector
	.byt (5+first_game_sector)*banks_per_sector
	.byt (4+first_game_sector)*banks_per_sector
	.byt (3+first_game_sector)*banks_per_sector
	.byt (2+first_game_sector)*banks_per_sector
	.byt (1+first_game_sector)*banks_per_sector
	.byt (0+first_game_sector)*banks_per_sector
#if n_game_sectors <> *-sector_banks
#error sector_banks table size missmatch n_game_sectors
#endif
#if n_game_sectors > 128
#error code below expects less than 129 sectors (because sign bit)
#endif

+update_screen_flash_game:
.(
	flash_operation_address = tmpfield3

	; Flash the game region
	.(
		; Erase sectors
		.(
			ldx #n_game_sectors-1
			erase_one_sector:
				; Switch to first bank in the sector
				FLASH_SWITCH_BANK(sector_banks COMMA x)

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

				; Update display
				;TODO

				; Wait for operation end
				wait_erase_end:
					lda $8000
					cmp $8000
					bne wait_erase_end

				; Loop
				dex
				bpl erase_one_sector
		.)

		; Program pages
		.(
			current_flash_bank = tmpfield5
			flash_bank_left = tmpfield6
			current_segment_in_bank = tmpfield7
			next_segment_ppu_address_lsb = tmpfield8
			next_segment_ppu_address_msb = tmpfield9

			; Init progress display
			lda #<$2063
			sta next_segment_ppu_address_lsb
			lda #>$2063
			sta next_segment_ppu_address_msb

			; Init progress sound (note - it emits a sound)
			; NOTE - play a sound as start bit has great chances to be set,
			;        better write in APU_NOISE_LENGTH_CNT and control duration
			lda #%00001111 ; --lc.vvvv
			sta APU_NOISE_ENVELOPE
			lda #%00001000 ; M---.PPPP
			sta APU_NOISE_PERIOD
			lda #%00001000 ; llll.l---
			sta APU_NOISE_LENGTH_CNT

			; Program all banks
			lda #first_game_sector*banks_per_sector
			sta current_flash_bank
			lda #n_game_banks
			sta flash_bank_left
			program_one_bank:
				; Init write pointer to the begining of the bank
				lda #$00
				sta flash_operation_address
				lda #$80
				sta flash_operation_address+1

				; Switch to game bank to program
				FLASH_SWITCH_BANK(current_flash_bank)

				; Program bank's pages
				lda #segments_per_bank
				sta current_segment_in_bank
				program_one_segment:
					; Program the segment
					jsr program_page
					jsr program_page
					jsr program_page
					jsr program_page

					; Play sound
					lda #%00011000 ; llll.l---
					sta APU_NOISE_LENGTH_CNT

					; Update display
					.(
						; Change segment's tile on screen
						bit PPUSTATUS
						vblankwait:
							bit PPUSTATUS
							bpl vblankwait

						lda PPUSTATUS
						lda next_segment_ppu_address_msb
						sta PPUADDR
						lda next_segment_ppu_address_lsb
						sta PPUADDR
						lda #sector_tile_ok
						sta PPUDATA

						lda #0
						sta PPUSCROLL
						sta PPUSCROLL

						lda ppuctrl_val
						sta PPUCTRL

						; Update next segment screen address
						lda next_segment_ppu_address_lsb
						and #$1f
						cmp #$1c
						bne simple_inc
							change_line:
								lda next_segment_ppu_address_lsb
								clc
								adc #7
								sta next_segment_ppu_address_lsb
								jmp screen_address_msb
							simple_inc:
								inc next_segment_ppu_address_lsb

							screen_address_msb:
							bcc ok
								inc next_segment_ppu_address_msb
						ok:
					.)

					; Loop
					dec current_segment_in_bank
					bne program_one_segment

				; Loop
				inc current_flash_bank
				dec flash_bank_left
				bne program_one_bank
		.)

		; Switch to rainbow RESET vectors
		;  At least emulator needs it,
		;  jumping to $fffc without the good bank here seems to trigger unstable behavior.
		lda #1
		sta RAINBOW_PRG_BANK_C000_MODE_1_LO

		jmp ($fffc)
		;rts ; useless, jump to reset vector
	.)

	; Overwrites all registers
	program_page:
	.(
		; Read half a page worth of data from file (impossible to read 256 bytes with current rainbow API)
		jsr esp_read_file_128

		; Program flash with bytes from file
		ldy #0
		ldx #0
		program_one_byte:
			; Program byte
			lda #$aa
			sta $8aaa
			lda #$55
			sta $8555
			lda #$a0
			sta $8aaa

			lda esp_rx_buffer+ESP_MSG_PAYLOAD+1, x
			sta (flash_operation_address), y

			wait_same_value:
				lda (flash_operation_address), y
				cmp (flash_operation_address), y
				bne wait_same_value

			; Loop
			inx
			iny

			;cpy #0 ; useless Z flag set by iny above
			beq page_programmed
			cpy #128
			bne program_one_byte

			; Y == 128 - We finished first half, read second half
			sta RAINBOW_WIFI_RX
			jsr esp_read_file_128
			ldy #128
			ldx #0
			jmp program_one_byte

		page_programmed:
		sta RAINBOW_WIFI_RX
		inc flash_operation_address+1
		rts
	.)
.)

; Read 128 bytes of the open file
;
; Overwrites all registers, tmpfield1 and tmpfield2
esp_read_file_128:
.(
	jsr ram_esp_wait_tx

	lda #2
	sta esp_tx_buffer
	lda #TOESP_MSG_FILE_READ
	sta esp_tx_buffer+1
	lda #128
	sta esp_tx_buffer+2

	sta RAINBOW_WIFI_TX

	jmp ram_esp_wait_rx

	;rts ; useless, jump to subroutine
.)

; Wait for ESP data to be ready to read
ram_esp_wait_rx:
.(
    wait_ready_bit:
        bit RAINBOW_WIFI_RX
        bpl wait_ready_bit
    rts
.)

; Wait for mapper to be ready to send data to esp
ram_esp_wait_tx:
.(
    wait_ready_bit:
        bit RAINBOW_WIFI_TX
        bpl wait_ready_bit
    rts
.)

flash_code_ram_end = *
flash_code_size = flash_code_ram_end - flash_code_ram
flash_code_rom_end = flash_code_rom + flash_code_size
* = flash_code_rom_end

;
; Code made to be run from ROM
;

+start_update_screen:
.(
	jsr reinit_c_stack
	jmp update_game
	; rts ; useless, jump to subroutine
.)

+update_screen_prepare_flash_code:
.(
	rom_ptr = tmpfield1
	ram_ptr = tmpfield3

	; Copy flash code in RAM
	lda #<flash_code_rom
	sta rom_ptr
	lda #>flash_code_rom
	sta rom_ptr+1

	lda #<flash_code_ram
	sta ram_ptr
	lda #>flash_code_ram
	sta ram_ptr+1

	ldy #0
	copy_one_byte:
		lda (rom_ptr), y
		sta (ram_ptr), y

		iny
		bne copy_one_byte

		inc rom_ptr+1
		inc ram_ptr+1

		lda ram_ptr
		cmp #<flash_code_ram_end
		lda ram_ptr+1
		sbc #>flash_code_ram_end

		bcc copy_one_byte

	rts
.)

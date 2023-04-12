; Ensure mapper init code is in the real fixed bank (rainbow mapper actually use an 8k fixed bank)
#ifdef MAPPER_RAINBOW
#if * < $e000
.dsb $e000-*, 0
#endif
#endif

#ifdef MAPPER_UNROM
bank_table:
.byt 0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32
#endif

mapper_init:
.(
	; Generic initialization code
	sei               ; disable IRQs
	ldx #$40
	cld               ; disable decimal mode
	stx APU_FRAMECNT  ; disable APU frame IRQ
	ldx #$FF
	txs               ; Set up stack
	inx               ; now X = 0
	stx PPUCTRL       ; disable NMI
	stx ppuctrl_val   ;
	stx PPUMASK       ; disable rendering
	stx APU_DMC_FLAGS ; disable DMC IRQs

#ifdef MAPPER_RAINBOW

	; Enable ESP, disable IRQ
	;TODO disable ESP here, enable it when needed
	ESP_ENABLE(1, 0)

	; Set PRG ROM banking
	lda #>FIXED_BANK_NUMBER ; CUUUUUUU - PRG-ROM, fixed bank
	sta RAINBOW_PRG_BANK_C000_MODE_1_HI
	lda #<FIXED_BANK_NUMBER ; LLLLLLLL - fixed bank
	sta RAINBOW_PRG_BANK_C000_MODE_1_LO
	lda #%00000001 ; A....OOO - PRG-RAM 8K, PRG-ROM 16K+16K
	sta RAINBOW_PRG_BANKING_MODE

	lda #%00000000 ; CUUUUUUU - PRG-ROM, first bank
	sta RAINBOW_PRG_BANK_8000_MODE_1_HI
	lda #%00000000 ; LLLLLLLL - first bank
	sta RAINBOW_PRG_BANK_8000_MODE_1_LO

	; Set CHR-RAM
	lda #%01000000 ; CCE..BBB - CHR-RAM, Disable Sprite extension, 8K CHR banking
	sta RAINBOW_CHR_CONTROL

	; Select CHR bank
	;  Disabled - matches reset value of the register, and ultimately we don't care we are not using CHR RAM banking
	;lda #0
	;sta RAINBOW_CHR_BANKING_1_HI
	;sta RAINBOW_CHR_BANKING_1_LO

	; Set Horizontal mirroring
	; Nothing, reset values are fine

	; Select the first FPGA WRAM bank to be mapped at CPU address $5000 to $5fff
	;  half of the second one is always mapped at $4800, using the second by default avoids mirroring
	lda #0
	sta RAINBOW_FPGA_RAM_BANKING

	; Select PRG-RAM bank to be mapped at $6000 to $7fff
	lda #%10000000 ; CuUUUUUU - PRG-RAM, bank 0
	sta RAINBOW_PRG_RAM_BANKING_1_HI
	lda #%00000000 ; LLLLLLLL - bank 0
	sta RAINBOW_PRG_RAM_BANKING_1_LO

	; Place TX/RX buffers
	lda #%00000000 ; Buffer at $4800
	sta RAINBOW_WIFI_RX_DEST
	lda #%00000001 ; Buffer at $4900
	sta RAINBOW_WIFI_TX_SOURCE

	; Disable sound extension
	lda #%00000000 ; E...FFFF - disable, (don't care of frequency) ; useless - the value in A is already good
	sta RAINBOW_PULSE_CHANNEL_1_FREQ_HIGH
	sta RAINBOW_PULSE_CHANNEL_2_FREQ_HIGH
	sta RAINBOW_SAW_CHANNEL_FREQ_HIGH

	; Enter rescue mode if magic buttons are pressed
	.(
		jsr fetch_controllers
		lda controller_a_btns
		cmp #CONTROLLER_BTN_UP+CONTROLLER_BTN_SELECT
		beq safe_rescue
		cmp #CONTROLLER_BTN_UP+CONTROLLER_BTN_SELECT+CONTROLLER_BTN_B
		bne no_rescue
			full_rescue:
				lda #1
				jmp rescue
			safe_rescue:
				lda #0
				jmp rescue
		no_rescue:
	.)
#endif

	jmp reset ; mapper_init is the physical entry point, let's jump to the generic entry point
.)

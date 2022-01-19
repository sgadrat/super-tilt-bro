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
	lda #%00000001
	sta RAINBOW_WIFI_CONF

	; Configure rainbow mapper
	lda #%00011110 ; ssmmrccp - horizontal mirroring, CHR-RAM, 8k CHR window, 16k+8k+8k PRG banking
	sta RAINBOW_CONFIGURATION

	; Select the PRG bank just before the last for the variable 8k window (emulating 16k variable + 16k fixed banking)
	lda #%00111110 ; c.BBBBbb - PRG-ROM, before the last bank
	sta RAINBOW_PRG_BANKING_3

	; Select the first CHR-BANK (Actually we don't care, the game don't use CHR banking, but let's be consistent)
	lda #%00000000 ; .......u - bank number's upper bit (always zero if not in 1K CHR window)
	sta RAINBOW_CHR_BANKING_UPPER
	lda #%00000000 ; BBBBBBBB - first bank
	sta RAINBOW_CHR_BANKING_1

	; Select the second FPGA WRAM bank
	;  half of the first one is always mapped at $4800, using the second by default avoids mirroring
	lda #%00000001
	sta RAINBOW_FPGA_WRAM_BANKING

	; Select the first WRAM bank
	lda #%00000000 ; ccBBBBbb - WRAM, first bank
	sta RAINBOW_WRAM_BANKING

	; Disable scanline IRQ
	sta RAINBOW_IRQ_DISABLE

	; Disable sound extension
	;lda #%00000000 ; E...FFFF - disable, (don't care of frequency) ; useless - the value in A is already good
	sta RAINBOW_PULSE_CHANNEL_1_FREQ_HIGH
	sta RAINBOW_PULSE_CHANNEL_2_FREQ_HIGH
	sta RAINBOW_SAW_CHANNEL_FREQ_HIGH

	; Set ESP messages memory to consecutive pages
	lda #0
	sta RAINBOW_WIFI_RX_DEST
	lda #1
	sta RAINBOW_WIFI_TX_SOURCE

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

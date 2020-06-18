; Ensure mapper init code is in the real fixed bank (rainbow mapper actually use an 8k fixed bank)
#ifdef MAPPER_RAINBOW
#if * < $e000
.dsb $e000-*, 0
#endif
#endif

mapper_init:
.(
#ifdef MAPPER_RAINBOW
	; Configure rainbow mapper
	lda #%00011110 ; ssmmrccp - horizontal mirroring, CHR-RAM, 8k CHR window, 16k+8k+8k PRG banking
	sta RAINBOW_CONFIGURATION

	; Select the PRG bank just before the last for the variable 8k window (emulating 16k variable + 16k fixed banking)
	lda #%00111110 ; c.BBBBbb - PRG-ROM, befor the last bank
	sta RAINBOW_PRG_BANKING_3

	; Select the first CHR-BANK (Actually we don't care, the game don't use CHR banking, but let's be consistent)
	lda #%00000000 ; BBBBBBBB - first bank
	sta RAINBOW_CHR_BANKING_1

	; Disable scanline IRQ
	sta RAINBOW_IRQ_DISABLE

	; Disable sound extension
	;lda #%00000000 ; E...FFFF - disable, (don't care of frequency) ; useless - the value in A is already good
	sta RAINBOW_PULSE_CHANNEL_1_FREQ_HIGH
	sta RAINBOW_PULSE_CHANNEL_2_FREQ_HIGH
	sta RAINBOW_SAW_CHANNEL_FREQ_HIGH
#endif

	jmp reset ; mapper_init is the physical entry point, let's jump to the generic entry point
.)

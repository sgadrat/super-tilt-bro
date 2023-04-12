+rainbow_nmi:
+rainbow_irq:
.(
	rti
.)

+rainbow_reset:
.(
	;TODO Choose between rebooting in rescue mode, or on the game
	;TODO rescue mode

	; Boot the game
	.(
		rainbow_trampoline_init_ram = $100

		; Copy trampoline init in RAM
		ldx #rainbow_trampoline_init_end-rainbow_trampoline_init-1
		copy_one_byte:
			lda rainbow_trampoline_init, x
			sta rainbow_trampoline_init_ram, x

			dex
			bpl copy_one_byte

		; Execute trampoline init
		jmp rainbow_trampoline_init_ram
	.)
.)

rainbow_trampoline_init:
.(
	; Set PRG ROM banking to 16K+16K, with game's fixed bank in the second slot
	lda #>FIXED_BANK_NUMBER ; CUUUUUUU - PRG-ROM, fixed bank
	sta RAINBOW_PRG_BANK_C000_MODE_1_HI
	lda #<FIXED_BANK_NUMBER ; LLLLLLLL - fixed bank
	sta RAINBOW_PRG_BANK_C000_MODE_1_LO
	lda #%00000001 ; A....OOO - PRG-RAM 8K, PRG-ROM 16K+16K
	sta RAINBOW_PRG_BANKING_MODE

	; Jump to new reset vector
	jmp ($fffc)
.)
rainbow_trampoline_init_end:

+rainbow_nmi:
+rainbow_irq:
.(
	rti
.)

+rainbow_reset:
.(
	; Choose between rebooting in rescue mode, or on the game
	btn_select = $20
	btn_b = $40
	jsr rescue_fetch_controllers

	lda rescue_controller_a_btns
	cmp #btn_select+btn_b
	beq boot_rescue

		; Boot the game
		boot_game:
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

		; Boot rescue mode
		boot_rescue:
		.(
			; Generic initialization code
			sei               ; disable IRQs
			ldx #$40
			cld               ; disable decimal mode
			stx APU_FRAMECNT  ; disable APU frame IRQ
			ldx #$ff
			txs               ; Set up stack
			inx               ; now X = 0
			stx PPUCTRL       ; disable NMI
			stx PPUMASK       ; disable rendering
			stx APU_DMC_FLAGS ; disable DMC IRQs

			; Ensure memory is zero-ed
			ldx #0
			clrmem:
			lda #$00
			sta $0000, x
			sta $0100, x
			sta $0200, x
			sta $0300, x
			sta $0400, x
			sta $0500, x
			sta $0600, x
			sta $0700, x
			inx
			bne clrmem

			; Initialize C stack
			lda #<c_stack_end
			sta _sp0
			lda #>c_stack_end
			sta _sp1

			; Call rainbow rescue code
			jmp rainbow_rescue
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
	jmp ($fff8)
.)
rainbow_trampoline_init_end:

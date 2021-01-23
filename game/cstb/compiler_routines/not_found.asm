; Functions assumed to be present by the compiler

.(
#iflused memcpy
;TODO preserve _r0 and _r1 to return the expected value
&memcpy:
.(
	dest_lsb = _r0
	dest_msb = _r1
	src_lsb = _r2
	src_msb = _r3
	size_lsb = _r4
	size_msb = _r5

	ldy #0

	copy_one_byte:
		; Size check
		lda size_msb
		bne copy_it
		lda size_lsb
		beq end
		copy_it:

		; Copy byte
		lda (src_lsb), y
		sta (dest_lsb), y

		; Increment pointers
		clc
		lda dest_lsb
		adc #1
		sta dest_lsb
		lda dest_msb
		adc #0
		sta dest_msb

		clc
		lda src_lsb
		adc #1
		sta src_lsb
		lda src_msb
		adc #0
		sta src_msb

		; Decrement size
		lda size_lsb
		sec
		sbc #1
		sta size_lsb
		lda size_msb
		sbc #0
		sta size_msb

		jmp copy_one_byte

	end:
	rts
.)
#endif
.)

; File imported from 6502-gcc's gcc-src/libgcc/config/6502/savestack.S

.(
#iflused __m65x_savestack_s7s0
&__m65x_savestack_s7s0:
	pla
	sta _tmp0
	pla
	sta _tmp1
	lda _s7
	pha
	lda _s6
	pha
	lda _s5
	pha
	lda _s4
	pha
	lda _s3
	pha
	lda _s2
	pha
	lda _s1
	pha
	lda _s0
	pha
	inc _tmp0
	bne end
		inc _tmp1
	end:
	jmp (_tmp0)
#endif

#iflused __m65x_restorestack_s7s0_rts
&__m65x_restorestack_s7s0_rts:
	pla
	sta _s0
	pla
	sta _s1
	pla
	sta _s2
	pla
	sta _s3
	pla
	sta _s4
	pla
	sta _s5
	pla
	sta _s6
	pla
	sta _s7
	rts
#endif
.)

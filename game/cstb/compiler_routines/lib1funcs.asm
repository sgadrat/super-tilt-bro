; File imported from 6502-gcc's gcc-src/libgcc/config/6502/lib1funcs.S

#iflused __bswapsi2
__bswapsi2:
.(
.(
	lda _r3
	ldx _r0
	stx _r3
	sta _r0
	lda _r2
	ldx _r1
	stx _r2
	sta _r1
	rts
.)
.)
#endif

#iflused __bswapdi2
__bswapdi2:
.(
.(
	ldx #0
	ldy #7
loop:
	lda _r0,x
	pha
	lda _r0,y
	sta _r0,x
	pla
	sta _r0,y
	dey
	inx
	cpx #4
	bne loop
	rts
.)
	rts
.)
#endif

#iflused __cmpsi2
__cmpsi2:
.(
	lda _r0
	cmp _r4
	lda _r1
	sbc _r5
	lda _r2
	sbc _r6
	lda _r3
	sbc _r7
	bvc no_ov
	eor #$80
no_ov:
	bmi less
	lda _r0
	cmp _r4
	bne greater
	lda _r1
	cmp _r5
	bne greater
	lda _r2
	cmp _r6
	bne greater
	lda _r3
	cmp _r7
	bne greater
	lda #1
	sta _r0
	lda #0
	sta _r1
	rts
greater:
	lda #2
	sta _r0
	lda #0
	sta _r1
	rts
less:
	lda #0
	sta _r0
	sta _r1
	rts
.)
#endif

#iflused __cmpdi2
__cmpdi2:
.(
        ldy #0
        lda _r0
        cmp (_sp0),y
        iny
        lda _r1
        sbc (_sp0),y
        iny
        lda _r2
        sbc (_sp0),y
        iny
        lda _r3
        sbc (_sp0),y
        iny
        lda _r4
        sbc (_sp0),y
        iny
        lda _r5
        sbc (_sp0),y
        iny
        lda _r6
        sbc (_sp0),y
        iny
        lda _r7
        sbc (_sp0),y
        bvc no_ov
        eor #$80
no_ov:
        bmi less
        ldy #0
samecheck:
        lda _r0,y
        cmp (_sp0),y
        bne greater
        iny
        cpy #8
        bne samecheck
        lda #1
        sta _r0
        lda #0
        sta _r1
        rts
greater:
        lda #2
        sta _r0
        lda #0
        sta _r1
        rts
less:
        lda #0
        sta _r0
        sta _r1
        rts
.)
#endif

#iflused __ucmpdi2
__ucmpdi2:
.(
        ldy #7
        lda _r7
        cmp (_sp0),y
        bcc less
        bne greater
        dey
        lda _r6
        cmp (_sp0),y
        bcc less
        bne greater
        dey
        lda _r5
        cmp (_sp0),y
        bcc less
        bne greater
        dey
        lda _r4
        cmp (_sp0),y
        bcc less
        bne greater
        dey
        lda _r3
        cmp (_sp0),y
        bcc less
        bne greater
        dey
        lda _r2
        cmp (_sp0),y
        bcc less
        bne greater
        dey
        lda _r1
        cmp (_sp0),y
        bcc less
        bne greater
        dey
        lda _r0
        cmp (_sp0),y
        bcc less
        bne greater
        lda #1
        sta _r0
        lda #0
        sta _r1
        rts
less:
        lda #0
        sta _r0
        sta _r1
        rts
greater:
        lda #2
        sta _r0
        lda #0
        sta _r1
        rts
.)
#endif

#iflused __ashldi3
__ashldi3:
.(
        ldy #0
        lda (_sp0),y
        tax
        beq done
        lda _r0
loop:
        asl
        rol _r1
        rol _r2
        rol _r3
        rol _r4
        rol _r5
        rol _r6
        rol _r7
        dex
        bne loop
        sta _r0
done:
        rts
.)
#endif

#iflused __lshrdi3
__lshrdi3:
.(
        ldy #0
        lda (_sp0),y
        tax
        beq done
        lda _r7
loop:
        lsr
        ror _r6
        ror _r5
        ror _r4
        ror _r3
        ror _r2
        ror _r1
        ror _r0
        dex
        bne loop
        sta _r7
done:
        rts
.)
#endif

#iflused __ashrdi3
__ashrdi3:
.(
        ldy #0
        lda (_sp0),y
        tax
        beq done
        lda _r7
loop:
        cmp #$80
        ror
        ror _r6
        ror _r5
        ror _r4
        ror _r3
        ror _r2
        ror _r1
        ror _r0
        dex
        bne loop
        sta _r7
done:
        rts
.)
#endif

#iflused __muldi3
__muldi3:
.(
        ldy #0
        ldx #0
copyop2:
        lda (_sp0),y
        sta _e0,y
        stx _e8,y
        iny
        cpy #8
        bne copyop2
        ldx #64
loop:
        lsr _r7
        ror _r6
        ror _r5
        ror _r4
        ror _r3
        ror _r2
        ror _r1
        ror _r0
        bcc no_add
        clc
        lda _e8
        adc _e0
        sta _e8
        lda _e9
        adc _e1
        sta _e9
        lda _e10
        adc _e2
        sta _e10
        lda _e11
        adc _e3
        sta _e11
        lda _e12
        adc _e4
        sta _e12
        lda _e13
        adc _e5
        sta _e13
        lda _e14
        adc _e6
        sta _e14
        lda _e15
        adc _e7
        sta _e15
no_add:
        asl _e0
        rol _e1
        rol _e2
        rol _e3
        rol _e4
        rol _e5
        rol _e6
        rol _e7
        dex
        bne loop

        ldx #0
copyout:
        lda _e8,x
        sta _r0,x
        inx
        cpx #8
        bne copyout
        rts
.)
#endif

#iflused __udivdi3
__udivdi3:
.(
        lda #0
        ldx #0
        ; e0...e7 are the quotient.
        ; e8...e15 are the remainder.
clear:
        sta _e0,x
        inx
        cpx #16
        bne clear

        ldx #64
loop:
        asl _r0         ; shift numerator
        rol _r1
        rol _r2
        rol _r3
        rol _r4
        rol _r5
        rol _r6
        rol _r7
        rol _e8         ; left-shift remainder
        rol _e9
        rol _e10
        rol _e11
        rol _e12
        rol _e13
        rol _e14
        rol _e15

        ldy #0
        sec
        lda _e8
        sbc (_sp0),y
        pha
        iny
        lda _e9
        sbc (_sp0),y
        pha
        iny
        lda _e10
        sbc (_sp0),y
        pha
        iny
        lda _e11
        sbc (_sp0),y
        pha
        iny
        lda _e12
        sbc (_sp0),y
        pha
        iny
        lda _e13
        sbc (_sp0),y
        pha
        iny
        lda _e14
        sbc (_sp0),y
        pha
        iny
        lda _e15
        sbc (_sp0),y
        bcc less
        rol _e0
        rol _e1
        rol _e2
        rol _e3
        rol _e4
        rol _e5
        rol _e6
        rol _e7
        sta _e15
        pla
        sta _e14
        pla
        sta _e13
        pla
        sta _e12
        pla
        sta _e11
        pla
        sta _e10
        pla
        sta _e9
        pla
        sta _e8
        jmp next_bit
less:
        pla
        pla
        pla
        pla
        pla
        pla
        pla
        asl _e0
        rol _e1
        rol _e2
        rol _e3
        rol _e4
        rol _e5
        rol _e6
        rol _e7
next_bit:
        dex
        beq done
        ; Tsk, out of range!
        jmp loop
done:

        ; Put quotient in the right place
        ldx #0
copyout:
        lda _e0,x
        sta _r0,x
        inx
        cpx #8
        bne copyout

        rts
.)
#endif

#iflused __umoddi3
__umoddi3:
.(
        jsr __udivdi3
        ; The above function left the remainder in e8...e15.  Those aren't
        ; normally live across procedure call boundaries, but it doesn't matter
        ; here because the whole lifetime is under our control.
        ldx #0
copyout:
        lda _e8,x
        sta _r0,x
        inx
        cpx #8
        bne copyout
        rts
.)
#endif

#iflused __negsi2
__negsi2:
.(
	ldx #0
	txa
	sec
	sbc _r0
	sta _r0
	txa
	sbc _r1
	sta _r1
	txa
	sbc _r2
	sta _r2
	txa
	sbc _r3
	sta _r3
	rts
.)
#endif

#iflused __negdi2
__negdi2:
.(
        ldx #0
        txa
        sec
        sbc _r0
        sta _r0
        txa
        sbc _r1
        sta _r1
        txa
        sbc _r2
        sta _r2
        txa
        sbc _r3
        sta _r3
        txa
        sbc _r4
        sta _r4
        txa
        sbc _r5
        sta _r5
        txa
        sbc _r6
        sta _r6
        txa
        sbc _r7
        sta _r7
        rts
.)
#endif

#iflused __ashlqi3
__ashlqi3:
.(
.(
	ldx _r1
	beq done
loop:
	asl _r0
	dex
	bne loop
done:
	rts
.)
.)
#endif

#iflused __lshrqi3
__lshrqi3:
.(
.(
	ldx _r1
	beq done
loop:
	lsr _r0
	dex
	bne loop
done:
	rts
.)
.)
#endif

#iflused __ashrqi3
__ashrqi3:
.(
.(
	ldx _r1
	beq done
	lda _r0
loop:
	cmp #$80
	ror
	dex
	bne loop
	sta _r0
done:
	rts
.)
.)
#endif

#iflused __ashlhi3
__ashlhi3:
.(
.(
	ldx _r2
	beq done
	lda _r0
loop:
	asl
	rol _r1
	dex
	bne loop
	sta _r0
done:
.)
	rts
.)
#endif

#iflused __lshrhi3
__lshrhi3:
.(
.(
	ldx _r2
	beq done
	lda _r1
loop:
	lsr
	ror _r0
	dex
	bne loop
	sta _r1
done:
.)
	rts
.)
#endif

#iflused __ashrhi3
__ashrhi3:
.(
.(
	ldx _r2
	beq done
	lda _r1
loop:
	cmp #$80
	ror
	ror _r0
	dex
	bne loop
	sta _r1
done:
	rts
.)
.)
#endif

#iflused __ashlsi3
__ashlsi3:
.(
.(
	ldx _r4
	beq done
	lda _r0
loop:
	asl
	rol _r1
	rol _r2
	rol _r3
	dex
	bne loop
	sta _r0
done:
	rts
.)
.)
#endif

#iflused __lshrsi3
__lshrsi3:
.(
.(
	ldx _r4
	beq done
	lda _r3
loop:
	lsr
	ror _r2
	ror _r1
	ror _r0
	dex
	bne loop
	sta _r3
done:
	rts
.)
.)
#endif

#iflused __ashrsi3
__ashrsi3:
.(
.(
	ldx _r4
	beq done
	lda _r3
loop:
	cmp #$80
	ror
	ror _r2
	ror _r1
	ror _r0
	dex
	bne loop
	sta _r3
done:
	rts
.)
.)
#endif

#iflused __mulqi3
__mulqi3:
.(
.(
	ldx #0
loop:
	lsr _r1
	bcc no_add
	txa
	clc
	adc _r0
	tax
no_add:
	asl _r0
	bne loop
	stx _r0
	rts
.)
.)
#endif

#iflused __mulhi3
__mulhi3:
.(
        ldx #0
        ldy #0
loop:
        lsr _r1
        ror _r0
        bcc no_add
        txa
        clc
        adc _r2
        tax
        tya
        adc _r3
        tay
no_add:
        asl _r2
        rol _r3
        lda _r2
        ora _r3
        bne loop
        stx _r0
        sty _r1
        rts
.)
#endif

#iflused __mulsi3
__mulsi3:
.(
.(
	lda _s0
	pha
	lda _s1
	pha
	lda _s2
	pha
	lda _s3
	pha

	lda #0
	sta _s0
	sta _s1
	sta _s2
	sta _s3

	ldx #32
loop:
	lsr _r7
	ror _r6
	ror _r5
	ror _r4
	bcc no_add
	clc
	lda _s0
	adc _r0
	sta _s0
	lda _s1
	adc _r1
	sta _s1
	lda _s2
	adc _r2
	sta _s2
	lda _s3
	adc _r3
	sta _s3
no_add:
	asl _r0
	rol _r1
	rol _r2
	rol _r3

	dex
	bne loop

	lda _s0
	sta _r0
	lda _s1
	sta _r1
	lda _s2
	sta _r2
	lda _s3
	sta _r3

	pla
	sta _s3
	pla
	sta _s2
	pla
	sta _s1
	pla
	sta _s0
	rts
.)
.)
#endif

#iflused __udivqi3
__udivqi3:
.(
.(
	lda #0
	sta _r2		; quotient
	sta _r3		; remainder
	ldx #8
loop:
	asl _r0
	rol _r3
	lda _r3
	sec
	sbc _r1
	bcc less
	rol _r2
	sta _r3
	dex
	bne loop
	jmp done
less:
	rol _r2
	dex
	bne loop
done:
	lda _r2
	sta _r0
	lda _r3
	sta _r1
	rts
.)
.)
#endif

#iflused __umodqi3
__umodqi3:
.(
	jsr __udivqi3
	lda _r1
	sta _r0
	rts
.)
#endif

#iflused __divhi3
__divhi3:
.(
        lda _r1
        eor _r3
        pha

        lda _r1
        bpl a_positive
        jsr __neghi2
a_positive:

        lda _r3
        bpl b_positive
        lda #0
        sec
        sbc _r2
        sta _r2
        lda #0
        sbc _r3
        sta _r3
b_positive:

        jsr __udivhi3

        pla
        bpl res_positive
        ; tailcall
        jmp __neghi2
res_positive:

        rts
.)
#endif

#iflused __modhi3
__modhi3:
.(
        lda _r1
        pha

        bpl numerator_positive
        jsr __neghi2
numerator_positive:
        lda _r3
        bpl denominator_positive
        lda #0
        sec
        sbc _r2
        sta _r2
        lda #0
        sbc _r3
        sta _r3
denominator_positive:
        jsr __umodhi3
        pla
        bpl result_positive
        ; tailcall
        jmp __neghi2
result_positive:
        rts
.)
#endif

#iflused __neghi2
__neghi2:
.(
        lda #0
        sec
        sbc _r0
        sta _r0
        lda #0
        sbc _r1
        sta _r1
        rts
.)
#endif

#iflused __umodhi3
__umodhi3:
.(
        jsr __udivhi3
        lda _r6
        sta _r0
        lda _r7
        sta _r1
        rts
.)
#endif

#iflused __udivhi3
__udivhi3:
.(
        ; (_r1, _r0) / (_r3, _r2)
        ; quotient in _r5, _r4
        ; remainder in _r7, _r6
        lda #0
        sta _r4
        sta _r5
        sta _r6
        sta _r7
        ldx #16
loop:
        asl _r0         ; left-shift numerator
        rol _r1
        rol _r6         ; shift high-order bit into remainder
        rol _r7
        lda _r6         ; compare remainder with denominator
        sec
        sbc _r2
        tay
        lda _r7
        sbc _r3
        bcc notgreater
        rol _r4
        rol _r5
        sty _r6
        sta _r7
        jmp next
notgreater:
        asl _r4
        rol _r5
next:
        dex
        bne loop
        lda _r4
        sta _r0
        lda _r5
        sta _r1
        rts
.)
#endif

#iflused __udivsi3
        ; This might as well use the _eN registers instead of clobbering the
        ; _sN registers. FIXME!
__udivsi3:
.(
	lda _s0
	pha
	lda _s1
	pha
	lda _s2
	pha
	lda _s3
	pha
	lda _s4
	pha
	lda _s5
	pha
	lda _s6
	pha
	lda _s7
	pha

	lda #0
	sta _s0		; quotient
	sta _s1
	sta _s2
	sta _s3
	sta _s4		; remainder
	sta _s5
	sta _s6
	sta _s7

	ldx #32
loop:
	asl _r0		; shift numerator
	rol _r1
	rol _r2
	rol _r3
	rol _s4		; left-shift remainder
	rol _s5
	rol _s6
	rol _s7

	sec
	lda _s4
	sbc _r4
	pha
	lda _s5
	sbc _r5
	pha
	lda _s6
	sbc _r6
	pha
	lda _s7
	sbc _r7
	bcc less
	rol _s0
	rol _s1
	rol _s2
	rol _s3
	sta _s7
	pla
	sta _s6
	pla
	sta _s5
	pla
	sta _s4
	jmp next_bit
less:
	pla
	pla
	pla
	asl _s0
	rol _s1
	rol _s2
	rol _s3
next_bit:
	dex
	bne loop

	; Put quotient in the right place
	lda _s0
	sta _r0
	lda _s1
	sta _r1
	lda _s2
	sta _r2
	lda _s3
	sta _r3

	; Stash remainder too
	lda _s4
	sta _r4
	lda _s5
	sta _r5
	lda _s6
	sta _r6
	lda _s7
	sta _r7

	pla
	sta _s7
	pla
	sta _s6
	pla
	sta _s5
	pla
	sta _s4
	pla
	sta _s3
	pla
	sta _s2
	pla
	sta _s1
	pla
	sta _s0
	rts
.)
.)
#endif

#iflused __umodsi3
__umodsi3:
.(
	jsr __udivsi3
	lda _r4
	sta _r0
	lda _r5
	sta _r1
	lda _r6
	sta _r2
	lda _r7
	sta _r3
	rts
.)
#endif

#iflused __divsi3
__divsi3:
.(
	lda _r3
	eor _r7
	pha

	lda _r3
	bpl numerator_positive
	jsr __negsi2
numerator_positive:
	lda _r7
	bpl denominator_positive
	ldx #0
	txa
	sec
	sbc _r4
	sta _r4
	txa
	sbc _r5
	sta _r5
	txa
	sbc _r6
	sta _r6
	txa
	sbc _r7
	sta _r7
denominator_positive:
	jsr __udivsi3
	pla
	bpl result_positive
	; tailcall
	jmp __negsi2
result_positive:
	rts
.)
#endif

#iflused __modsi3
__modsi3:
.(
	lda _r3
	pha

	bpl numerator_positive
	jsr __negsi2
numerator_positive:
	lda _r7
	bpl denominator_positive
	ldx #0
	txa
	sec
	sbc _r4
	sta _r4
	txa
	sbc _r5
	sta _r5
	txa
	sbc _r6
	sta _r6
	txa
	sbc _r7
	sta _r7
denominator_positive:
	jsr __umodsi3
	pla
	bpl result_positive
	; tailcall
	jmp __negsi2
result_positive:
	rts
.)
#endif

#iflused __ltsf2
	; Helper routine used by ltsf/lesf/gtsf/gesf.  This has to go
	; somewhere, so put it here.
	; On entry the Y register has
	;   - zero for a regular comparison
	;   - nonzero for a reversed comparison
	; On exit the accumulator has
	;   - 0x80 for "less than" result
	;   - zero for "greater than or equal" result.
__m65x_fpcmp:
.(
	lda _r2
	tax
	and #$80
	sta _tmp0
	txa
	and #$7f
	sta _r2

	lda _r6
	tax
	and #$80
	sta _tmp1
	txa
	and #$7f
	sta _r6

	; -X < -Y == X > Y == Y < X
	lda _tmp0
	and _tmp1
	bpl not_both_negative
	jmp maybe_reverse_cmp
not_both_negative:
	lda _tmp0
	eor _tmp1
	bpl not_one_only
	; Now we have one of:
	; -X <  Y
	;  X < -Y
	; -X >  Y  (reversed)
	;  X > -Y
	cpy #0
	bne reverse
	lda _tmp0
	rts
reverse:
	lda _tmp1
	rts
not_one_only:

	cpy #0
	bne reverse_cmp
forward_cmp:
.(
	; mantissa
	lda _r0
	cmp _r4
	lda _r1
	sbc _r5
	lda _r2
	sbc _r6
	; exponent
	lda _r3
	sbc _r7
	bcc less
	lda #0
	rts
less:
	lda #$80
	rts
.)

maybe_reverse_cmp:
	cpy #0
	bne forward_cmp
reverse_cmp:
.(
	; mantissa
	lda _r4
	cmp _r0
	lda _r5
	sbc _r1
	lda _r6
	sbc _r2
	; exponent
	lda _r7
	sbc _r3
	bcc less
	lda #0
	rts
less:
	lda #$80
	rts
.)
.)

__ltsf2:
	ldy #0
	jsr __m65x_fpcmp
	sta _r0
	rts
.)
#endif

#iflused __gesf2
__gesf2:
.(
	ldy #0
	jsr __m65x_fpcmp
	eor #$80
	sta _r0
	rts
.)
#endif

#iflused __gtsf2
__gtsf2:
.(
	ldy #1
	jsr __m65x_fpcmp
	sta _r0
	rts
.)
#endif

#iflused __lesf2
__lesf2:
.(
	ldy #1
	jsr __m65x_fpcmp
	eor #$80
	sta _r0
	rts
.)
#endif

#iflused __eqsf2
__eqsf2:
.(
.(
	lda _r2
	and #$7f
	ora _r3
	ora _r1
	ora _r0
	bne not_plusminus_zero

	lda _r6
	and #$7f
	ora _r7
	ora _r5
	ora _r4
	beq eq

not_plusminus_zero:
	lda _r0
	cmp _r4
	bne ne
	lda _r1
	cmp _r5
	bne ne
	lda _r2
	cmp _r6
	bne ne
	lda _r3
	cmp _r7
	bne ne
eq:
	lda #1
	sta _r0
	rts
ne:
	lda #0
	sta _r0
	rts
.)
.)
#endif

#iflused __nesf2
__nesf2:
.(
	jsr __eqsf2
	lda _r0
	eor #1
	sta _r0
	rts
.)
#endif

#iflused __addsf3
#include "addsf3.S"
.)
#endif

#iflused __subsf3
__subsf3:
.(
	lda _r6
	eor #$80
	sta _r6
	jmp __addsf3
.)
#endif

#iflused __mulsf3
__mulsf3:
.(
	lda _s2
	pha
	lda _s1
	pha
	lda _s0
	pha

	lda _r2
	eor _r6
	and #$80
	sta _m65x_fpe0_sign

.(
	lda _r2
	and #$7f
	ldx _r3
	beq a_exp_zero
	ora #$80
a_exp_zero:
	sta _r2
	stx _m65x_fpe0_exp

	lda _r6
	and #$7f
	ldx _r7
	beq b_exp_zero
	ora #$80
b_exp_zero:
	stx _m65x_fpe1_exp
	tax
.)

	lda _r4
	sta _r3
	lda _r5
	sta _r4
	stx _r5

	; Do the actual multiplication.
.(

	lda #0
	sta _r6
	sta _r7
	sta _m65x_fpe0_mant
	sta _m65x_fpe0_mant+1
	sta _m65x_fpe0_mant+2
	sta _m65x_fpe0_mant+3
	sta _m65x_fpe0_mant+4

	; s2,s1,s0,r2,r1,r0
	sta _s0
	sta _s1
	sta _s2

	ldx #24
loop:
	lsr _r5
	ror _r4
	ror _r3
	bcc no_add
	clc
	lda _r6
	adc _r0
	sta _r6
	lda _r7
	adc _r1
	sta _r7
	lda _m65x_fpe0_mant
	adc _r2
	sta _m65x_fpe0_mant
	lda _m65x_fpe0_mant+1
	adc _s0
	sta _m65x_fpe0_mant+1
	lda _m65x_fpe0_mant+2
	adc _s1
	sta _m65x_fpe0_mant+2
	lda _m65x_fpe0_mant+3
	adc _s2
	sta _m65x_fpe0_mant+3
	bcc :+
	inc _m65x_fpe0_mant+4
	:
no_add:
	asl _r0
	rol _r1
	rol _r2
	rol _s0
	rol _s1
	rol _s2
	dex
	bne loop

	asl _r6
	rol _r7
	rol _m65x_fpe0_mant
	rol _m65x_fpe0_mant+1
	rol _m65x_fpe0_mant+2
	rol _m65x_fpe0_mant+3
	rol _m65x_fpe0_mant+4

.)

	ldx #0

	lda _m65x_fpe0_exp
	clc
	adc _m65x_fpe1_exp
	sta _m65x_fpe0_exp
	bcc :+
	inx
	:

	lda _m65x_fpe0_exp
	sec
	sbc #127
	sta _m65x_fpe0_exp
	bcs :+
	dex
	:
	; FIXME: clamping to zero/max_float goes here.

.(
	lda _m65x_fpe0_mant+1
	ora _m65x_fpe0_mant+2
	ora _m65x_fpe0_mant+3
	bne not_zero
	sta _m65x_fpe0_exp
	jmp done
not_zero:
	jsr _m65x_renormalize_right
done:
.)

	lda _m65x_fpe0_mant+1
	sta _r0
	lda _m65x_fpe0_mant+2
	sta _r1
	lda _m65x_fpe0_mant+3
	and #$7f
	ora _m65x_fpe0_sign
	sta _r2
	lda _m65x_fpe0_exp
	sta _r3

	pla
	sta _s0
	pla
	sta _s1
	pla
	sta _s2

	rts
.)
#endif

#iflused __divsf3
	; A plain implementation of the "Integer division (unsigned) with
	; remainder" algorithm given on Wikipedia:
	;   [if D == 0 then error(DivisionByZeroException) end]
	;   Q := 0                 -- initialize quotient and remainder to zero
	;   R := 0                     
	;   for i = n-1...0 do     -- where n is number of bits in N
	;     R := R << 1          -- left-shift R by 1 bit
	;     R(0) := N(i)         -- set the least-significant bit of R equal
	;     if R >= D then	      to bit i of the numerator
	;       R = R - D
	;       Q(i) := 1
	;     end
	;   end
__divsf3:
	lda _s2
	pha
	lda _s1
	pha
	lda _s0
	pha

	lda _r2
	eor _r6
	and #$80
	sta _m65x_fpe0_sign

.(
	lda _r2
	and #$7f
	ldx _r3
	beq a_exp_zero
	ora #$80
a_exp_zero:
	sta _r2
	stx _m65x_fpe0_exp

	lda _r6
	and #$7f
	ldx _r7
	beq b_exp_zero
	ora #$80
b_exp_zero:
	sta _r6
	stx _m65x_fpe1_exp
.)

	lda #0
	sta _s2
	sta _s1
	sta _s0

	; Result goes here. We want the eventual answer in fpe0_mant+[1,2,3].
	sta _m65x_fpe0_mant
	sta _m65x_fpe0_mant+1
	sta _m65x_fpe0_mant+2
	sta _m65x_fpe0_mant+3
	sta _m65x_fpe0_mant+4
	sta _r3

	; The remainder
	sta _m65x_fpe1_mant
	sta _m65x_fpe1_mant+1
	sta _m65x_fpe1_mant+2
	sta _m65x_fpe1_mant+3
	sta _m65x_fpe1_mant+4
	sta _r7

	; r2,r1,r0,s2,s1,s0 = a_mant << 23

	lsr _r2
	ror _r1
	ror _r0
	ror _s2
	ror _s1
	ror _s0

	; result[47:0] = r2,r1,r0,s2,s1,s0 / r6,r5,r4
.(
	ldx #48
loop:
	; get the i'th bit of N (starting from highest-order bit).
	asl _s0
	rol _s1
	rol _s2
	rol _r0
	rol _r1
	rol _r2
	; R = (R << 1) | (N[i] ? 1 : 0)
	rol _m65x_fpe1_mant
	rol _m65x_fpe1_mant+1
	rol _m65x_fpe1_mant+2
	rol _m65x_fpe1_mant+3
	rol _m65x_fpe1_mant+4
	rol _r7

	; Test D <= R
	sec
	lda _m65x_fpe1_mant
	sbc _r4
	pha
	lda _m65x_fpe1_mant+1
	sbc _r5
	pha
	lda _m65x_fpe1_mant+2
	sbc _r6
	pha
	lda _m65x_fpe1_mant+3
	sbc #0
	pha
	lda _m65x_fpe1_mant+4
	sbc #0
	pha
	lda _r7
	sbc #0
	bcc less
	rol _m65x_fpe0_mant+1
	rol _m65x_fpe0_mant+2
	rol _m65x_fpe0_mant+3
	rol _m65x_fpe0_mant+4
	rol _m65x_fpe0_mant
	rol _r3
	sta _r7
	pla
	sta _m65x_fpe1_mant+4
	pla
	sta _m65x_fpe1_mant+3
	pla
	sta _m65x_fpe1_mant+2
	pla
	sta _m65x_fpe1_mant+1
	pla
	sta _m65x_fpe1_mant
	jmp next_bit
less:
	pla
	pla
	pla
	pla
	pla
	asl _m65x_fpe0_mant+1
	rol _m65x_fpe0_mant+2
	rol _m65x_fpe0_mant+3
	rol _m65x_fpe0_mant+4
	rol _m65x_fpe0_mant
	rol _r3
next_bit:
	dex
	bne loop
.)

	; Remove junk in high-order & low-order bits.
	lda #0
	sta _m65x_fpe0_mant
	sta _m65x_fpe0_mant+4

	; High-order exponent byte.
	ldx #0

	lda _m65x_fpe0_exp
	sec
	sbc _m65x_fpe1_exp
	sta _m65x_fpe0_exp
	bcs :+
	dex
	:

	lda _m65x_fpe0_exp
	clc
	adc #127
	sta _m65x_fpe0_exp
	bcc :+
	inx
	:

	; FIXME: Handle exponent overflow/underflow here.

.(
	lda _m65x_fpe0_mant+1
	ora _m65x_fpe0_mant+2
	ora _m65x_fpe0_mant+3
	bne not_zero
	sta _m65x_fpe0_exp
	jmp done
not_zero:
	jsr _m65x_renormalize_left
done:
.)

	lda _m65x_fpe0_mant+1
	sta _r0
	lda _m65x_fpe0_mant+2
	sta _r1
	lda _m65x_fpe0_mant+3
	and #$7f
	ora _m65x_fpe0_sign
	sta _r2
	lda _m65x_fpe0_exp
	sta _r3

	pla
	sta _s0
	pla
	sta _s1
	pla
	sta _s2

	rts
.)
#endif

#iflused __fixsfsi
__fixsfsi:
.(
	lda _r2
	and #$80
	sta _m65x_fpe0_sign

	jsr __fixunssfsi

	lda _m65x_fpe0_sign
	bpl not_negative
	ldx #0
	txa
	sec
	sbc _r0
	sta _r0
	txa
	sbc _r1
	sta _r1
	txa
	sbc _r2
	sta _r2
	txa
	sbc _r3
	sta _r3
not_negative:

	rts
.)
#endif

#iflused __fixunssfsi
__fixunssfsi:
.(
	lda _r2
	and #$7f
	ldx _r3
	beq a_exp_zero
	ora #$80
a_exp_zero:
	sta _r2
	stx _m65x_fpe0_exp

	cpx #127
	bcs over_one
	lda #0
	sta _r0
	sta _r1
	sta _r2
	sta _r3
	rts
over_one:

	; r3 is part of the result now.
	lda #0
	sta _r3

.(
	lda #150
	sec
	sbc _m65x_fpe0_exp
	bcc shift_left
	; shifting right by 'A' places
	tax
	beq exit
right_shift_loop:
	lsr _r3
	ror _r2
	ror _r1
	ror _r0
	dex
	bne right_shift_loop
exit:
	rts
shift_left:
	eor #$ff
	tax
	inx
left_shift_loop:
	asl _r0
	rol _r1
	rol _r2
	rol _r3
	dex
	bne left_shift_loop
.)

	rts
.)
#endif

#iflused __floatunsisf
__floatunsisf:
.(
	; All zero, just return zero.
	lda _r0
	ora _r1
	ora _r2
	ora _r3
	bne notzero
	rts
notzero:

	lda #150
	sta _m65x_fpe0_exp
	lda #0
	sta _m65x_fpe0_mant

	lda _r0
	sta _m65x_fpe0_mant+1
	lda _r1
	sta _m65x_fpe0_mant+2
	ldx _r2
	stx _m65x_fpe0_mant+3
	lda _r3
	sta _m65x_fpe0_mant+4

	bne rightshift
	cpx #$80
	bcs rightshift
	; We need to shift left until the mantissa is normalized.
	jsr _m65x_renormalize_left
	jmp repack
rightshift:
	jsr _m65x_renormalize_right
repack:

	bit _m65x_fpe0_mant
	bpl no_rounding
	inc _m65x_fpe0_mant+1
	bne no_rounding
	inc _m65x_fpe0_mant+2
	bne no_rounding
	inc _m65x_fpe0_mant+3
	bne no_rounding
	inc _m65x_fpe0_mant+4
	jsr _m65x_renormalize_right
no_rounding:

	lda _m65x_fpe0_mant+1
	sta _r0
	lda _m65x_fpe0_mant+2
	sta _r1
	lda _m65x_fpe0_mant+3
	and #$7f
	sta _r2
	lda _m65x_fpe0_exp
	sta _r3

	rts
.)
#endif

#iflused __floatsisf
__floatsisf:
.(
	lda _r3
	and #$80
	sta _m65x_fpe0_sign
	bpl not_negative
	ldx #0
	txa
	sec
	sbc _r0
	sta _r0
	txa
	sbc _r1
	sta _r1
	txa
	sbc _r2
	sta _r2
	txa
	sbc _r3
	sta _r3
not_negative:
	jsr __floatunsisf

	lda _r2
	ora _m65x_fpe0_sign
	sta _r2

	rts
.)
#endif

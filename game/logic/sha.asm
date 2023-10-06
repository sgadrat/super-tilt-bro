; 6502 implementation of Wikipedia's pseudo code for sha256
;  en.wikipedia.org/wiki/SHA-2#Pseudocode

+SHA_BANK_NUMBER = CURRENT_BANK_NUMBER

.(
; Message schedule array "w"
;  Stores 64 32-bit words,
;  w0 is a table of the MSB of each word
;  w3 is a table of the LSB of each word
w0 = sha_w
w1 = w0+64
w2 = w1+64
w3 = w2+64

; Hash result "h"
;  Stores 8 32-bit words,
;  h0 is the first word, big endian
;  h7 is the last word, big endian
h0 = sha_h
h1 = h0+4
h2 = h1+4
h3 = h2+4
h4 = h3+4
h5 = h4+4
h6 = h5+4
h7 = h6+4

; Working variables
;  8 independent words
a = sha_working_variables
b = a+4
c = b+4
d = c+4
e = d+4
f = e+4
g = f+4
h = g+4

s0 = tmpfield1 ; to tmpfield4
s1 = tmpfield5 ; to tmpfield8
temp1 = tmpfield9 ; to tmpfield12
temp2 = tmpfield13 ; to tmpfield16

; Note this one is not in sha256 pseudocode
;      most code can be factorized by generalizing it as an intermediary variable
temp3 = extra_tmpfield1 ; to extra_tmpfield4

; Round constants K
;  Stores 64 32-bit words,
;  k0 is a table of the MSB of each word
;  k3 is a table of the LSB of each word
;
;  Will be indexed, should be aligned on 256 bytes
k0:
.byt $42, $71, $b5, $e9, $39, $59, $92, $ab
.byt $d8, $12, $24, $55, $72, $80, $9b, $c1
.byt $e4, $ef, $0f, $24, $2d, $4a, $5c, $76
.byt $98, $a8, $b0, $bf, $c6, $d5, $06, $14
.byt $27, $2e, $4d, $53, $65, $76, $81, $92
.byt $a2, $a8, $c2, $c7, $d1, $d6, $f4, $10
.byt $19, $1e, $27, $34, $39, $4e, $5b, $68
.byt $74, $78, $84, $8c, $90, $a4, $be, $c6
k1:
.byt $8a, $37, $c0, $b5, $56, $f1, $3f, $1c
.byt $07, $83, $31, $0c, $be, $de, $dc, $9b
.byt $9b, $be, $c1, $0c, $e9, $74, $b0, $f9
.byt $3e, $31, $03, $59, $e0, $a7, $ca, $29
.byt $b7, $1b, $2c, $38, $0a, $6a, $c2, $72
.byt $bf, $1a, $4b, $6c, $92, $99, $0e, $6a
.byt $a4, $37, $48, $b0, $1c, $d8, $9c, $2e
.byt $8f, $a5, $c8, $c7, $be, $50, $f9, $71
k2:
.byt $2f, $44, $fb, $db, $c2, $11, $82, $5e
.byt $aa, $5b, $85, $7d, $5d, $b1, $06, $f1
.byt $69, $47, $9d, $a1, $2c, $84, $a9, $88
.byt $51, $c6, $27, $7f, $0b, $91, $63, $29
.byt $0a, $21, $6d, $0d, $73, $0a, $c9, $2c
.byt $e8, $66, $8b, $51, $e8, $06, $35, $a0
.byt $c1, $6c, $77, $bc, $0c, $aa, $ca, $6f
.byt $82, $63, $78, $02, $ff, $6c, $a3, $78
k3:
.byt $98, $91, $cf, $a5, $5b, $f1, $a4, $d5
.byt $98, $01, $be, $c3, $74, $fe, $a7, $74
.byt $c1, $86, $c6, $cc, $6f, $aa, $dc, $da
.byt $52, $6d, $c8, $c7, $f3, $47, $51, $67
.byt $85, $38, $fc, $13, $54, $bb, $2e, $85
.byt $a1, $4b, $70, $a3, $19, $24, $85, $70
.byt $16, $08, $4c, $b5, $b3, $4a, $4f, $f3
.byt $ee, $6f, $14, $08, $fa, $eb, $f7, $f2

; Initial value of sha_h
;  8 32-bit words, big endian
initial_hash:
.byt $6a, $09, $e6, $67
.byt $bb, $67, $ae, $85
.byt $3c, $6e, $f3, $72
.byt $a5, $4f, $f5, $3a
.byt $51, $0e, $52, $7f
.byt $9b, $05, $68, $8c
.byt $1f, $83, $d9, $ab
.byt $5b, $e0, $cd, $19

#define RIGHTROTATE(var) .( :\
	; Save Y :\
	tya:pha :\
:\
	; Rotate 8 bits at once :\
	.( :\
		rotate_byte:\
			cpx #8 :\
			bcc ok :\
:\
			ldy var+3 :\
:\
			lda var+2 :\
			sta var+3 :\
			lda var+1 :\
			sta var+2 :\
			lda var+0 :\
			sta var+1 :\
:\
			sty var+0 :\
:\
			txa :\
			sec :\
			sbc #8 :\
			tax :\
:\
			jmp rotate_byte :\
		ok:\
	.):\
:\
	; Rotate the remaining bits :\
	.( :\
		rotate_bit:\
			cpx #0 :\
			beq ok :\
:\
			lda var+3 :\
			lsr :\
			ror var+0 :\
			ror var+1 :\
			ror var+2 :\
			ror var+3 :\
:\
			dex :\
			jmp rotate_bit :\
:\
		ok:\
	.) :\
:\
	; Restore Y :\
	pla:tay :\
.)

#define COPY32(dest,src) .( :\
	lda src+0:sta dest+0 :\
	lda src+1:sta dest+1 :\
	lda src+2:sta dest+2 :\
	lda src+3:sta dest+3 :\
.)

#define AND32(dest,operand_a,operand_b) .( :\
	lda operand_a+0:and operand_b+0:sta dest+0 :\
	lda operand_a+1:and operand_b+1:sta dest+1 :\
	lda operand_a+2:and operand_b+2:sta dest+2 :\
	lda operand_a+3:and operand_b+3:sta dest+3 :\
.)

#define ADD32(dest,operand_a,operand_b) .( :\
	clc :\
	lda operand_a+3 : adc operand_b+3 : sta dest+3 :\
	lda operand_a+2 : adc operand_b+2 : sta dest+2 :\
	lda operand_a+1 : adc operand_b+1 : sta dest+1 :\
	lda operand_a+0 : adc operand_b+0 : sta dest+0 :\
.)

#define XOR32(dest,operand_a,operand_b) .( :\
	lda operand_a+0:eor operand_b+0:sta dest+0 :\
	lda operand_a+1:eor operand_b+1:sta dest+1 :\
	lda operand_a+2:eor operand_b+2:sta dest+2 :\
	lda operand_a+3:eor operand_b+3:sta dest+3 :\
.)

; Copy the word w[x] to s0 while rotating it 1 bit to the right
copy_rotate_s0_wx:
.(
	lda w3, x
	lsr
	lda w0, x
	ror
	sta s0
	lda w1, x
	ror
	sta s0+1
	lda w2, x
	ror
	sta s0+2
	lda w3, x
	ror
	sta s0+3

	rts
.)

; Rotate s0 to the right by x bits
rotate_s0:
.(
	rotate:
		lda s0+3
		lsr
		ror s0
		ror s0+1
		ror s0+2
		ror s0+3

		dex
		bne rotate

	rts
.)

; Rotate temp1 to the right by x bits
rotate_temp1:
.(
	rotate:
		lda temp1+3
		lsr
		ror temp1
		ror temp1+1
		ror temp1+2
		ror temp1+3

		dex
		bne rotate

	rts
.)

s0_xor_temp1:
.(
	lda s0+0
	eor temp1+0
	sta s0+0
	lda s0+1
	eor temp1+1
	sta s0+1
	lda s0+2
	eor temp1+2
	sta s0+2
	lda s0+3
	eor temp1+3
	sta s0+3
	rts
.)

s0_xor_temp2:
.(
	lda s0+0
	eor temp2+0
	sta s0+0
	lda s0+1
	eor temp2+1
	sta s0+1
	lda s0+2
	eor temp2+2
	sta s0+2
	lda s0+3
	eor temp2+3
	sta s0+3
	rts
.)

s1_xor_temp1:
.(
	lda s1+0
	eor temp1+0
	sta s1+0
	lda s1+1
	eor temp1+1
	sta s1+1
	lda s1+2
	eor temp1+2
	sta s1+2
	lda s1+3
	eor temp1+3
	sta s1+3
	rts
.)

; Compute SHA-256 checksum
;  Input
;   sha_msg to sha_msg+54 - message
;   sha_length_lsb, sha_length_msb - message length in bits
;
;  Output
;   sha_h to sha_h+31 - result, in big endian
;
;  Overwrites
;   all registers, sha_w to sha_w+255
;
;  Limitations
;   - Length must be a multiple of eight bits
;     - It avoids padding a partial byte at the end of message
;   - Length must be <= 440 bits (55 bytes)
;     - It allows to process only one chunk
+sha256_sum:
.(
	; Initialize hash values
	.(
		ldx #31
		copy_one_byte:
			lda initial_hash, x
			sta sha_h, x
			dex
			bpl copy_one_byte
	.)

	; Pre-processing (Padding)
	.(
		; Begin with the original message of length L bits
		; Append a single '1' bit
		lda sha_length_msb
		lsr
		sta tmpfield1
		lda sha_length_lsb
		ror
		sta tmpfield2

		lsr tmpfield1
		ror tmpfield2

		lsr tmpfield1
		lda tmpfield2
		ror

		tax
		lda #%10000000
		sta sha_msg, x

		; Append K '0' bits, where K is the minimum number >= 0 such that (L + 1 + K + 64) is a multiple of 512
		.(
			lda #0
			fill_one_byte:
				inx
				cpx #56+6 ; +6 to fill MSBs of L with zeros
				beq ok

					sta sha_msg, x
					jmp fill_one_byte
			ok:
		.)

		; Append L as a 64-bit big-endian integer, making the total post-processed length a multiple of 512 bits
		lda sha_length_msb
		sta sha_msg+56+6
		lda sha_length_lsb
		sta sha_msg+56+7
	.)

	; Process the message as a single 512 bits chunk
	.(
		; Copy chunk into first 16 words w[0..15] of the message schedule array
		.(
			nb_words = 16

			ldx #0
			ldy #0
			copy_one_word:
				lda sha_msg+0, x
				sta w0, y
				lda sha_msg+1, x
				sta w1, y
				lda sha_msg+2, x
				sta w2, y
				lda sha_msg+3, w
				sta w3, y

				inx:inx:inx:inx
				iny
				cpy #nb_words
				bne copy_one_word
		.)

		; Extend the first 16 words into the remaining 48 words w[16..63] of the message schedule array
		.(
			; For i from 16 to 63
			;  Note - Pseudocode's i is register y
			generate_one_word:
				; s0 = (w[i-15] rightrotate  7) xor (w[i-15] rightrotate 18) xor (w[i-15] rightshift  3)
				.(
					; x = y - 15
					tya
					sec
					sbc #15
					tax
					pha

					; s0 = w[i-15] rightrotate  7
					jsr copy_rotate_s0_wx
					ldx #6
					jsr rotate_s0
					pla:tax
					pha

					; temp1 = w[i-15] rightrotate 18
					lda w0, x
					sta temp1+2
					lda w1, x
					sta temp1+3
					lda w2, x
					sta temp1+0
					lda w3, x
					sta temp1+1
					ldx #2
					jsr rotate_temp1
					pla:tax

					; s0 = s0 xor temp1
					jsr s0_xor_temp1

					; temp1 = w[i-15] rightshift  3
					lda w0, x
					lsr
					sta temp1+0
					lda w1, x
					ror
					sta temp1+1
					lda w2, x
					ror
					sta temp1+2
					lda w3, x
					ror
					sta temp1+3

					lsr temp1+0
					ror temp1+1
					ror temp1+2
					ror temp1+3

					lsr temp1+0
					ror temp1+1
					ror temp1+2
					ror temp1+3

					; s0 = s0 xor temp1
					jsr s0_xor_temp1
				.)

				; s1 = (w[i-2] rightrotate 17) xor (w[i-2] rightrotate 19) xor (w[i-2] rightshift 10)
				.(
					; x = y - 2
					tya
					tax
					dex:dex
					txa
					pha

					; s1 = w[i-2] rightrotate  17
					lda w0, x
					sta s1+2
					lda w1, x
					sta s1+3
					lda w2, x
					sta s1+0
					lda w3, x
					sta s1+1

					lda s1+3
					lsr
					ror s1+0
					ror s1+1
					ror s1+2
					ror s1+3

					; temp1 = w[i-2] rightrotate 19
					lda w0, x
					sta temp1+2
					lda w1, x
					sta temp1+3
					lda w2, x
					sta temp1+0
					lda w3, x
					sta temp1+1
					ldx #3
					jsr rotate_temp1
					pla:tax

					; s1 = s1 xor temp1
					jsr s1_xor_temp1

					; temp1 = w[i-2] rightshift 10
					lda #0
					sta temp1+0
					lda w0, x
					sta temp1+1
					lda w1, x
					sta temp1+2
					lda w2, x
					sta temp1+3

					lsr temp1+1
					ror temp1+2
					ror temp1+3

					lsr temp1+1
					ror temp1+2
					ror temp1+3

					; s1 = s1 xor temp1
					jsr s1_xor_temp1
				.)

				; w[i] = w[i-16] + s0 + w[i-7] + s1
				.(
					; x = i - 16
					tya
					sec
					sbc #16
					tax

					; temp1 = w[i-16] + s0
					clc
					lda w3, x
					adc s0+3
					sta temp1+3
					lda w2, x
					adc s0+2
					sta temp1+2
					lda w1, x
					adc s0+1
					sta temp1+1
					lda w0, x
					adc s0+0
					sta temp1+0

					; x = i - 7
					tya
					sec
					sbc #7
					tax

					; temp1 = temp1 + w[i-7]
					clc
					lda w3, x
					adc temp1+3
					sta temp1+3
					lda w2, x
					adc temp1+2
					sta temp1+2
					lda w1, x
					adc temp1+1
					sta temp1+1
					lda w0, x
					adc temp1+0
					sta temp1+0

					; w[i] = temp1 + s1
					clc
					lda temp1+3
					adc s1+3
					sta w3, y

					lda temp1+2
					adc s1+2
					sta w2, y

					lda temp1+1
					adc s1+1
					sta w1, y

					lda temp1+0
					adc s1+0
					sta w0, y
				.)

				; Loop
				iny
				cpy #64
				beq end_generate_one_word
				jmp generate_one_word
				end_generate_one_word:
		.)

		; Initialize working variables to current hash value
		.(
			ldx #8*4
			copy_one_byte:
				lda sha_h, x
				sta sha_working_variables, x
				dex
				bpl copy_one_byte
		.)

		; Compression function main loop
		.(
			; for i from 0 to 63
			ldy #0
			compression_iteration:
				; S1 = (e rightrotate 6) xor (e rightrotate 11) xor (e rightrotate 25)
				.(
					; s1 = e rightrotate 6
					COPY32(s1, e)
					ldx #6
					RIGHTROTATE(s1)

					; temp1 = e rightrotate 11
					COPY32(temp1, e)
					ldx #11
					RIGHTROTATE(temp1)

					; s1 = s1 xor temp1
					jsr s1_xor_temp1

					; temp1 = e rightrotate 25
					COPY32(temp1, e)
					ldx #25
					RIGHTROTATE(temp1)

					; s1 = s1 xor temp1
					jsr s1_xor_temp1
				.)

				; temp1 = (e and f) xor ((not e) and g)
				.(
					; temp1 = e and f
					AND32(temp1, e, f)

					; temp2 = ((not e) and g)
					lda e+0:eor #$ff:sta temp2+0
					lda e+1:eor #$ff:sta temp2+1
					lda e+2:eor #$ff:sta temp2+2
					lda e+3:eor #$ff:sta temp2+3
					AND32(temp2, temp2, g)

					; temp1 = temp1 xor temp2
					XOR32(temp1, temp1, temp2)
				.)

				; temp1 = h + S1 + temp1 + k[i] + w[i]
				.(
					; temp1 = temp1 + s1
					ADD32(temp1, temp1, s1)

					; temp1 = temp1 + h
					ADD32(temp1, temp1, h)

					; temp1 = temp1 + k[i]
					clc
					lda temp1+3 : adc k3, y : sta temp1+3
					lda temp1+2 : adc k2, y : sta temp1+2
					lda temp1+1 : adc k1, y : sta temp1+1
					lda temp1+0 : adc k0, y : sta temp1+0

					; temp1 = temp1 + w[i]
					clc
					lda temp1+3 : adc w3, y : sta temp1+3
					lda temp1+2 : adc w2, y : sta temp1+2
					lda temp1+1 : adc w1, y : sta temp1+1
					lda temp1+0 : adc w0, y : sta temp1+0
				.)

				; S0 = (a rightrotate 2) xor (a rightrotate 13) xor (a rightrotate 22)
				.(
					; s0 = a rightrotate 2
					.(
						COPY32(s0, a)
						ldx #2
						RIGHTROTATE(s0)
					.)

					; temp2 = a rightrotate 13
					.(
						COPY32(temp2, a)
						ldx #13
						RIGHTROTATE(temp2)
					.)

					; s0 = s0 xor temp2
					jsr s0_xor_temp2

					; temp2 = a rightrotate 22
					.(
						COPY32(temp2, a)
						ldx #22
						RIGHTROTATE(temp2)
					.)

					; s0 = s0 xor temp2
					jsr s0_xor_temp2
				.)

				; temp2 = (a and b) xor (a and c) xor (b and c)
				.(
					; temp2 = a and b
					AND32(temp2, a, b)

					; temp3 = a and c
					AND32(temp3, a, c)

					; temp2 = temp2 xor temp3
					XOR32(temp2, temp2, temp3)

					; temp3 = b and c
					AND32(temp3, b, c)

					; temp2 = temp2 xor temp3
					XOR32(temp2, temp2, temp3)
				.)

				; temp2 = S0 + temp2
				ADD32(temp2, s0, temp2)

				; Note - could be a loop shifting bytes by 4 place, then adding temp1 to e and recomputing a
				; h = g
				COPY32(h, g)
				; g = f
				COPY32(g, f)
				; f = e
				COPY32(f, e)
				; e = d + temp1
				ADD32(e, d, temp1)
				; d = c
				COPY32(d, c)
				; c = b
				COPY32(c, b)
				; b = a
				COPY32(b, a)
				; a = temp1 + temp2
				ADD32(a, temp1, temp2)

				; Loop
				iny
				cpy #64
				beq end_compression_iteration
				jmp compression_iteration
				end_compression_iteration:
		.)

		; Add the compressed chunk to the current hash value
		.(
			ADD32(h0, h0, a)
			ADD32(h1, h1, b)
			ADD32(h2, h2, c)
			ADD32(h3, h3, d)
			ADD32(h4, h4, e)
			ADD32(h5, h5, f)
			ADD32(h6, h6, g)
			ADD32(h7, h7, h)
		.)
	.)

	; Result is in sha_h, big endian
	rts
.)
.)

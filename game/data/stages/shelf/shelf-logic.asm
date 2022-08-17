+stage_skyride_fadeout: .(
	header = tmpfield1 ; construct_nt_buffer parameter
	payload = tmpfield3 ; construct_nt_buffer parameter

	lda #<palette_header
	sta header
	lda #>palette_header
	sta header+1

	lda stage_skyride_fadeout_lsb, x
	sta payload
	lda stage_skyride_fadeout_msb, x
	sta payload+1

	jmp construct_nt_buffer

	;rts ; useless, jump to subroutine

	palette_header:
	.byt $3f, $00, $10
.)

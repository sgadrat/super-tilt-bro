.(
; Decompress a page from rescue image
;  hfm_data_stream_index - ID of the data stream in huffmunch bank
;  $8000 - must be swapped to the bank containing the compressed data
;
; Output
;  decompress_page_result
;   0 - Success
;   1 - Failed to decompress data
;
; Each bank containing compressed data is composed of multiple data streams of
; 256 bytes. hfm_data_stream_index is the index of the desired stream from the
; begining of the compressed bank.
;
; More information in documentation/rescue.rst
+rescue_decompress_page:
.(
	; Load huffmunch on the compressed page
	.(
		lda #$00
		sta huffmunch_zpblock+0
		lda #$80
		sta huffmunch_zpblock+1

		ldx hfm_data_stream_index
		ldy hfm_data_stream_index+1

		jsr huffmunch_load
	.)

	; Check size matches expectation
	.(
		cpy #$01
		bne invalid_size
		cpx #$00
		beq ok
			invalid_size:
				lda #1
				sta decompress_page_result
				rts
		ok:
	.)

	; Decompress page
	;ldx #$00 ; useless, ensured by cpx above
	decompress_one_byte:
		stx decompress_page_result
		jsr huffmunch_read
		ldx decompress_page_result

		sta program_data, x

		inx
		bne decompress_one_byte

	; Return success
	lda #0
	sta decompress_page_result

	rts
.)
.)

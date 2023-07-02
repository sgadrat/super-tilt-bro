;-------------------------------------------------------------------------------
; Invariable messages
;-------------------------------------------------------------------------------

esp_cmd_clear_buffers:
	.byt 1, TOESP_MSG_CLEAR_BUFFERS

esp_cmd_connect:
	.byt 1, TOESP_MSG_SERVER_CONNECT;

esp_cmd_get_esp_status:
	.byt 1, TOESP_MSG_GET_ESP_STATUS

;-------------------------------------------------------------------------------
; Utility routines
;-------------------------------------------------------------------------------

; Shorter call convention for esp_send_cmd
;  register A - address of the command data (lsb)
;  register X - address of the command data (msb)
;
; Overwrites all registers, tmpfield1 and tmpfield2
esp_send_cmd_short:
.(
	sta tmpfield1
	stx tmpfield2
	;rts ; Fallthrough to esp_send_cmd
.)

; Send a command to the ESP
;  tmpfield1,tmpfield2 - address of the command data
;
; Command data follows the format
;  First byte is the message length (number of bytes following this first byte).
;  Second byte is the command opcode.
;  Any remaining bytes are parameters for the command.
;
; Overwrites all registers
esp_send_cmd:
.(
	; Wait for the mapper to be ready to send a message to ESP
	jsr esp_wait_tx

	; Get length field
	ldy #0
	lda (tmpfield1), y
	tax

	; Copy message
	sta esp_tx_buffer
	copy_payload_byte:
		iny
		lda (tmpfield1), y
		sta esp_tx_buffer, y

		dex
		bne copy_payload_byte

	; Send message
	sta RAINBOW_WIFI_TX

	rts
.)

; Retrieve a message from ESP
;  tmpfield1,tmpfield2 - address where the message is stored
;
; Message data follows the format
;  First byte is the message length (number of bytes following this first byte).
;  Second byte is the message type.
;  Any remaining bytes are payload of the message.
;
; Output
;  - Retrieved message is stored at address pointed by tmpfield1,tmpfield2
;  - Y number of bytes retrieved (zero if there was no message, message length otherwise)
;
; Note
;  - Y returns the contents of the "message length" field, so it is one less than the number
;    of bytes writen in memory.
;  - First byte of destination is always written (to zero if there was no message)
;  - It is indistinguishable if there was a message with a length field of zero or there
;    was no message.
;
; Overwrites all registers
esp_get_msg:
.(
	ldy #0

	bit RAINBOW_WIFI_RX
	bmi store_msg

		; No message, set msg_len to zero
		lda #0
		sta (tmpfield1), y
		rts

	store_msg:
		; Copy message in destination buffer
		lda esp_rx_buffer
		sta (tmpfield1), y
		tax

		store_payload:
			iny
			lda esp_rx_buffer, y
			sta (tmpfield1), y

			dex
			bne store_payload

		; Acknoledge message reception
		sta RAINBOW_WIFI_RX

	rts
.)

; Wait for ESP data to be ready to read
esp_wait_rx:
.(
	wait_ready_bit:
		bit RAINBOW_WIFI_RX
		bpl wait_ready_bit
	rts
.)

; Wait for mapper to be ready to send data to esp
esp_wait_tx:
.(
	wait_ready_bit:
		bit RAINBOW_WIFI_TX
		bpl wait_ready_bit
	rts
.)

; Helper macro, calling esp_send_cmd on a known label
#define ESP_SEND_CMD(data) \
	lda #<(data) :\
	sta tmpfield1 :\
	lda #>(data) :\
	sta tmpfield1+1 :\
	jsr esp_send_cmd

; Header macro, prepare a debug_log message
;  len - Length of the message in bytes
;
; Overwrites register A
;
; Note - the message header is sent to ESP, message contents must follow
#define ESP_DEBUG_LOG_HEADER(len) .(:\
	lda #len+2:\
	sta RAINBOW_DATA:\
	lda #TOESP_MSG_DEBUG_LOG:\
	sta RAINBOW_DATA:\
	lda #len:\
	sta RAINBOW_DATA:\
.)

; Send a debug_log message containing bytes after this macro call
;  len - Length of the message in bytes
;  data after the macro call - data to send
;
; Overwrites register A
#define ESP_DEBUG_LOG(len) .(:\
	txa:\
	pha:\
	lda #len+2:\
	sta RAINBOW_DATA:\
	lda #TOESP_MSG_DEBUG_LOG:\
	sta RAINBOW_DATA:\
	lda #len:\
	sta RAINBOW_DATA:\
\
	ldx #0:\
	send_one_byte:\
		lda msg_data, x:\
		sta RAINBOW_DATA:\
		inx:\
		cpx #len:\
		bne send_one_byte:\
\
	pla:\
	tax:\
	jmp msg_data+len:\
	msg_data:\
.)

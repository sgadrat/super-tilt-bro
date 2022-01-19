; Helper macro, calling esp_send_cmd on a known label
#define ESP_SEND_CMD(data) \
	lda #<(data) :\
	sta tmpfield1 :\
	lda #>(data) :\
	sta tmpfield1+1 :\
	jsr esp_send_cmd

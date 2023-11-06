#pragma once
#include "cstb/utils.h"
#include "cstb/mem_labels.h"
#include <stdint.h>
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wunused-function"

////////////////////////////////////
// Constants
////////////////////////////////////

#include "cstb/rainbow_constants.h"

////////////////////////////////////
// Registers
////////////////////////////////////

extern uint8_t volatile RAINBOW_MAPPER_VERSION;
extern uint8_t volatile RAINBOW_WIFI_CONF;
extern uint8_t volatile RAINBOW_WIFI_RX;
extern uint8_t volatile RAINBOW_WIFI_TX;
extern uint8_t volatile RAINBOW_WRAM_BANKING;

////////////////////////////////////
// Buffers
////////////////////////////////////

extern uint8_t esp_rx_buffer;
extern uint8_t esp_tx_buffer;

////////////////////////////////////
// Routines without arguments
//  simply declare it as extern
////////////////////////////////////

////////////////////////////////////
// Routines that need some glue code
//  implement the glue
////////////////////////////////////

void esp_send_cmd();
static void wrap_esp_send_cmd(uint8_t const* cmd) {
	*tmpfield1 = ptr_lsb(cmd);
	*tmpfield2 = ptr_msb(cmd);
	esp_send_cmd();
}

void esp_get_msg();
static uint8_t wrap_esp_get_msg(uint8_t* dest) {
	*tmpfield1 = ptr_lsb(dest);
	*tmpfield2 = ptr_msb(dest);
	esp_get_msg();
	return *dest;
}

////////////////////////////////////
// Utility functions that have no asm counterpart
////////////////////////////////////

static bool esp_rx_message_ready() {
	return (RAINBOW_WIFI_RX & 0x80) != 0;
}

static void esp_rx_message_acknowledge() {
	RAINBOW_WIFI_RX = 0;
}

static void esp_tx_message_send() {
	RAINBOW_WIFI_TX = 0;
}

static void esp_wait_answer(uint8_t type) {
	uint8_t* const rx = &esp_rx_buffer;

	bool found = false;
	while(!found) {
		esp_wait_rx();
		if (rx[ESP_MSG_TYPE] != type) {
			esp_rx_message_acknowledge();
		}else {
			found = true;
		}
	}
}

static void esp_enable_wifi(bool wifi, bool access_point, bool web_server) {
	esp_wait_tx();

	uint8_t* const buff = &esp_tx_buffer;
	buff[0] = 2;
	buff[1] = TOESP_MSG_WIFI_SET_CONFIG;
	buff[2] = (wifi?1:0) + (access_point?2:0) + (web_server?4:0);
	esp_tx_message_send();
}

static void esp_set_server_settings(uint16_t port, char const* host) {
	uint8_t const host_len = strnlen8(host, 200); // Lil' bit below 256 because ESP message headers + port information

	esp_wait_tx();

	uint8_t* const buff = &esp_tx_buffer;
	buff[0] = host_len + 4;
	buff[1] = TOESP_MSG_SERVER_SET_SETTINGS;
	buff[2] = u16_msb(port);
	buff[3] = u16_lsb(port);
	buff[4] = host_len;
	wrap_fixed_memcpy(buff+5, (uint8_t*)host, host_len);

	esp_tx_message_send();
}

static void esp_file_close() {
	uint8_t* const tx = &esp_tx_buffer;

	esp_wait_tx();
	tx[0] = 1;
	tx[1] = TOESP_MSG_FILE_CLOSE;
	esp_tx_message_send();
}

static bool esp_file_exists(uint8_t path, uint8_t file) {
	uint8_t* const tx = &esp_tx_buffer;
	uint8_t* const rx = &esp_rx_buffer;

	esp_wait_tx();
	tx[0] = 4;
	tx[1] = TOESP_MSG_FILE_EXISTS;
	tx[2] = ESP_FILE_MODE_AUTO;
	tx[3] = path;
	tx[4] = file;
	esp_tx_message_send();

	esp_wait_answer(FROMESP_MSG_FILE_EXISTS);
	bool exists = rx[ESP_MSG_PAYLOAD];
	esp_rx_message_acknowledge();

	return exists;
}

static void esp_file_open(uint8_t path, uint8_t file) {
	uint8_t* const tx = &esp_tx_buffer;

	esp_wait_tx();
	tx[0] = 4;
	tx[1] = TOESP_MSG_FILE_OPEN;
	tx[2] = ESP_FILE_MODE_AUTO;
	tx[3] = path;
	tx[4] = file;
	esp_tx_message_send();
}

static uint8_t esp_file_read(uint8_t* dest, uint8_t count) {
	uint8_t* const tx = &esp_tx_buffer;
	uint8_t* const rx = &esp_rx_buffer;

	esp_wait_tx();
	tx[0] = 2;
	tx[1] = TOESP_MSG_FILE_READ;
	tx[2] = count;
	esp_tx_message_send();

	esp_wait_answer(FROMESP_MSG_FILE_DATA);
	uint8_t n_read = rx[ESP_MSG_PAYLOAD+0];
	wrap_fixed_memcpy(dest, rx+ESP_MSG_PAYLOAD+1, n_read);
	esp_rx_message_acknowledge();

	return n_read;
}

static void esp_file_write(uint8_t* src, uint8_t count) {
	uint8_t* const tx = &esp_tx_buffer;

	esp_wait_tx();
	tx[0] = count + 1;
	tx[1] = TOESP_MSG_FILE_WRITE;
	wrap_fixed_memcpy(tx+2, src, count);
	esp_tx_message_send();
}

#pragma GCC diagnostic pop

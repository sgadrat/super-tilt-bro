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

static void esp_tx_ready() {
}

static void esp_tx_message_send() {
	RAINBOW_WIFI_TX = 0;
}

static void esp_set_server_settings(uint16_t port, char const* host) {
	uint8_t const host_len = strnlen8(host, 200); // Lil' bit below 256 because ESP message headers + port information

	esp_wait_tx();

	uint8_t* buff = &esp_tx_buffer;
	buff[0] = host_len + 3;
	buff[1] = TOESP_MSG_SERVER_SET_SETTINGS;
	buff[2] = u16_msb(port);
	buff[3] = u16_lsb(port);
	wrap_fixed_memcpy(buff+4, (uint8_t*)host, host_len);

	esp_tx_message_send();
}

#pragma GCC diagnostic pop

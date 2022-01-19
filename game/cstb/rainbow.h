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

#pragma GCC diagnostic pop

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

static uint8_t const ESP_MSG_SIZE = 0;
static uint8_t const ESP_MSG_TYPE = 1;
static uint8_t const ESP_MSG_PAYLOAD = 2;

////////////////////////////////////
// Registers
////////////////////////////////////

extern uint8_t volatile RAINBOW_DATA;
extern uint8_t volatile RAINBOW_FLAGS;
extern uint8_t volatile RAINBOW_WRAM_BANKING;

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

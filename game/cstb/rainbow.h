#pragma once
#include "cstb/utils.h"
#include "cstb/mem_labels.h"
#include <stdint.h>
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wunused-function"

////////////////////////////////////
// Constants
////////////////////////////////////

static uint8_t const TOESP_MSG_GET_ESP_STATUS = 0;
static uint8_t const TOESP_MSG_DEBUG_GET_LEVEL = 1;
static uint8_t const TOESP_MSG_DEBUG_SET_LEVEL = 2;
static uint8_t const TOESP_MSG_DEBUG_LOG = 3;
static uint8_t const TOESP_MSG_CLEAR_BUFFERS = 4;
static uint8_t const TOESP_MSG_E2N_BUFFER_DROP = 5;
static uint8_t const TOESP_MSG_GET_WIFI_STATUS = 6;
static uint8_t const TOESP_MSG_GET_RND_BYTE = 7;
static uint8_t const TOESP_MSG_GET_RND_BYTE_RANGE = 8;
static uint8_t const TOESP_MSG_GET_RND_WORD = 9;
static uint8_t const TOESP_MSG_GET_RND_WORD_RANGE = 10;
static uint8_t const TOESP_MSG_GET_SERVER_STATUS = 11;
static uint8_t const TOESP_MSG_GET_SERVER_PING = 12;
static uint8_t const TOESP_MSG_SET_SERVER_PROTOCOL = 13;
static uint8_t const TOESP_MSG_GET_SERVER_SETTINGS = 14;
static uint8_t const TOESP_MSG_GET_SERVER_CONFIG_SETTINGS = 15;
static uint8_t const TOESP_MSG_SET_SERVER_SETTINGS = 16;
static uint8_t const TOESP_MSG_RESTORE_SERVER_SETTINGS = 17;
static uint8_t const TOESP_MSG_CONNECT_TO_SERVER = 18;
static uint8_t const TOESP_MSG_DISCONNECT_FROM_SERVER = 19;
static uint8_t const TOESP_MSG_SEND_MESSAGE_TO_SERVER = 20;
static uint8_t const TOESP_MSG_FILE_OPEN = 21;
static uint8_t const TOESP_MSG_FILE_CLOSE = 22;
static uint8_t const TOESP_MSG_FILE_EXISTS = 23;
static uint8_t const TOESP_MSG_FILE_DELETE = 24;
static uint8_t const TOESP_MSG_FILE_SET_CUR = 25;
static uint8_t const TOESP_MSG_FILE_READ = 26;
static uint8_t const TOESP_MSG_FILE_WRITE = 27;
static uint8_t const TOESP_MSG_FILE_APPEND = 28;
static uint8_t const TOESP_MSG_FILE_COUNT = 29;
static uint8_t const TOESP_MSG_FILE_GET_LIST = 30;
static uint8_t const TOESP_MSG_FILE_GET_FREE_ID = 31;
static uint8_t const TOESP_MSG_FILE_GET_INFO = 32;

static uint8_t const FROMESP_MSG_READY = 0;
static uint8_t const FROMESP_MSG_DEBUG_LEVEL = 1;
static uint8_t const FROMESP_MSG_FILE_EXISTS = 2;
static uint8_t const FROMESP_MSG_FILE_DELETE = 3;
static uint8_t const FROMESP_MSG_FILE_LIST = 4;
static uint8_t const FROMESP_MSG_FILE_DATA = 5;
static uint8_t const FROMESP_MSG_FILE_COUNT = 6;
static uint8_t const FROMESP_MSG_FILE_ID = 7;
static uint8_t const FROMESP_MSG_FILE_INFO = 8;
static uint8_t const FROMESP_MSG_WIFI_STATUS = 9;
static uint8_t const FROMESP_MSG_SERVER_STATUS = 10;
static uint8_t const FROMESP_MSG_SERVER_PING = 11;
static uint8_t const FROMESP_MSG_HOST_SETTINGS = 12;
static uint8_t const FROMESP_MSG_RND_BYTE = 13;
static uint8_t const FROMESP_MSG_RND_WORD = 14;
static uint8_t const FROMESP_MSG_MESSAGE_FROM_SERVER = 15;

static uint8_t const ESP_FILE_PATH_SAVE = 0;
static uint8_t const ESP_FILE_PATH_ROMS = 1;
static uint8_t const ESP_FILE_PATH_USER = 2;

static uint8_t const ESP_PROTOCOL_WEBSOCKET = 0;
static uint8_t const ESP_PROTOCOL_UDP = 1;

////////////////////////////////////
// Registers
////////////////////////////////////

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

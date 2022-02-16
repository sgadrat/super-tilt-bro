#pragma once

#include <stdint.h>

static uint16_t const STNP_CLI_MSG_TYPE_CONNECTION = 0;
static uint16_t const STNP_CLI_MSG_TYPE_CONTROLLER_STATE = 1;

static uint16_t const STNP_SRV_MSG_TYPE_CONNECTED = 0;
static uint16_t const STNP_SRV_MSG_TYPE_START_GAME = 1;
static uint16_t const STNP_SRV_MSG_TYPE_NEWSTATE = 2;
static uint16_t const STNP_SRV_MSG_TYPE_GAMEOVER = 3;
static uint16_t const STNP_SRV_MSG_TYPE_DISCONNECTED = 4;

static uint16_t const STNP_START_GAME_FIELD_STAGE = 1;
static uint16_t const STNP_START_GAME_FIELD_STOCK = 2;
static uint16_t const STNP_START_GAME_FIELD_PLAYER_NUMBER = 3;
static uint16_t const STNP_START_GAME_FIELD_PLAYER_CONNECTIONS = 4;
static uint16_t const STNP_START_GAME_FIELD_PA_CHARACTER = 5;
static uint16_t const STNP_START_GAME_FIELD_PB_CHARACTER = 6;
static uint16_t const STNP_START_GAME_FIELD_PA_PALETTE = 7;
static uint16_t const STNP_START_GAME_FIELD_PB_PALETTE = 8;

static uint16_t const STNP_DISCONNECTED_FIELD_REASON = 1;

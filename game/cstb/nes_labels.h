#pragma once
#include <stdint.h>

// PPU registers
//  http://wiki.nesdev.com/w/index.php/PPU_registers

static uint8_t volatile* const PPUCTRL = (uint8_t volatile* const)0x2000;
static uint8_t volatile* const PPUMASK = (uint8_t volatile* const)0x2001;
static uint8_t volatile* const PPUSTATUS = (uint8_t volatile* const)0x2002;
static uint8_t volatile* const OAMADDR = (uint8_t volatile* const)0x2003;
static uint8_t volatile* const OAMDATA = (uint8_t volatile* const)0x2004;
static uint8_t volatile* const PPUSCROLL = (uint8_t volatile* const)0x2005;
static uint8_t volatile* const PPUADDR = (uint8_t volatile* const)0x2006;
static uint8_t volatile* const PPUDATA = (uint8_t volatile* const)0x2007;
static uint8_t volatile* const OAMDMA = (uint8_t volatile* const)0x4014;

// APU registers
//  http://wiki.nesdev.com/w/index.php/APU

static uint8_t volatile* const APU_SQUARE1_ENVELOPE = (uint8_t volatile* const)0x4000;
static uint8_t volatile* const APU_SQUARE1_PERIOD = (uint8_t volatile* const)0x4001; //TODO remove, deprecated by APU_SQUARE1_SWEEP
static uint8_t volatile* const APU_SQUARE1_SWEEP = (uint8_t volatile* const)0x4001;
static uint8_t volatile* const APU_SQUARE1_TIMER_LOW = (uint8_t volatile* const)0x4002;
static uint8_t volatile* const APU_SQUARE1_LENGTH_CNT = (uint8_t volatile* const)0x4003;

static uint8_t volatile* const APU_SQUARE2_ENVELOPE = (uint8_t volatile* const)0x4004;
static uint8_t volatile* const APU_SQUARE2_SWEEP = (uint8_t volatile* const)0x4005;
static uint8_t volatile* const APU_SQUARE2_TIMER_LOW = (uint8_t volatile* const)0x4006;
static uint8_t volatile* const APU_SQUARE2_LENGTH_CNT = (uint8_t volatile* const)0x4007;

static uint8_t volatile* const APU_TRIANGLE_LINEAR_CNT = (uint8_t volatile* const)0x4008;
static uint8_t volatile* const APU_TRIANGLE_TIMER_LOW = (uint8_t volatile* const)0x400a;
static uint8_t volatile* const APU_TRIANGLE_LENGTH_CNT = (uint8_t volatile* const)0x400b;

static uint8_t volatile* const APU_NOISE_ENVELOPE = (uint8_t volatile* const)0x400c;
static uint8_t volatile* const APU_NOISE_PERIOD = (uint8_t volatile* const)0x400e;
static uint8_t volatile* const APU_NOISE_LENGTH_CNT = (uint8_t volatile* const)0x400f;

static uint8_t volatile* const APU_DMC_FLAGS = (uint8_t volatile* const)0x4010;

static uint8_t volatile* const APU_STATUS = (uint8_t volatile* const)0x4015;
static uint8_t volatile* const APU_FRAMECNT = (uint8_t volatile* const)0x4017;

// Controller ports

static uint8_t volatile* const CONTROLLER_A = (uint8_t volatile* const)0x4016;
static uint8_t volatile* const CONTROLLER_B = (uint8_t volatile* const)0x4017;

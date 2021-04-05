#pragma once
#include <cstb/types.h>
#include <stdint.h>
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wunused-function"

static uint8_t u16_lsb(uint16_t val) {
	return ((int)val) & 0x00ff;
}

static uint8_t u16_msb(uint16_t val) {
	return (((int)val) >> 8) & 0x00ff;
}

static uint8_t i16_lsb(int16_t val) {
	return ((int)val) & 0x00ff;
}

static uint8_t i16_msb(int16_t val) {
	return (((int)val) >> 8) & 0x00ff;
}

static uint8_t ptr_lsb(void const* ptr) {
	return u16_lsb((uint16_t)ptr);
}

static uint8_t ptr_msb(void const* ptr) {
	return u16_msb((uint16_t)ptr);
}

static uint8_t const* ptr(uint8_t lsb, uint8_t msb) {
	return (uint8_t const*)((((uint16_t)(msb)) << 8) + lsb);
}

static int16_t min(int16_t a, int16_t b) {
	return a < b ? a : b;
}

static int16_t max(int16_t a, int16_t b) {
	return a > b ? a : b;
}

static uint32_t random(uint32_t seed)
{
  seed ^= seed << 13;
  seed ^= seed >> 17;
  seed ^= seed << 5;
  return seed;
}

/** strnlen working on 8bit values */
static uint8_t strnlen8(char const* s, uint8_t maxlen) {
	uint8_t len = 0;
	while (len < maxlen && s[len] != 0) {
		++len;
	}
	return len;
}

#pragma GCC diagnostic pop

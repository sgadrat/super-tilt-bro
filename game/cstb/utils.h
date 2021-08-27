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

/**
 * Return 0 if the built ROM has networking feature, else 1
 *
 * Use it instead of "#ifdef NO_NETWORK", which is not sensible to the ROM built.
 */
static uint8_t no_network() {
	uint8_t res;
	asm(
		"\r\n" // empty first line. It may be indented, breaking preprocessor parsing
		"#ifdef NO_NETWORK\r\n"
		"lda #1\r\n"
		"#else\r\n"
		"lda #0\r\n"
		"#endif\r\n"
		"sta %0"
		: "=r"(res)
		:
		: "a"
	);
	return res;
}

/** strnlen working on 8bit values */
static uint8_t strnlen8(char const* s, uint8_t maxlen) {
	uint8_t len = 0;
	while (len < maxlen && s[len] != 0) {
		++len;
	}
	return len;
}

extern uint8_t const CURRENT_BANK_NUMBER; // Actually an ASM macro, use its address or "code_bank()"
/** Return the bank in which the calling code is stored */
static uint8_t code_bank() {
	return ptr_lsb(&CURRENT_BANK_NUMBER);
}

#define CONST_HUNDREDS(val) ((((val) % 1000) / 100))
#define CONST_TENS(val) ((((val) % 100) / 10))
#define CONST_UNITS(val) ((val) % 10)

#pragma GCC diagnostic pop

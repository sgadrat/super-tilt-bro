#pragma once
#include <cstb/mem_labels.h>
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

static uint8_t u32_byte0(uint32_t val) {
	return val & 0x000000ff;
}

static uint8_t u32_byte1(uint32_t val) {
	return (val & 0x0000ff00) >> 8;
}

static uint8_t u32_byte2(uint32_t val) {
	return (val & 0x00ff0000) >> 16;
}

static uint8_t u32_byte3(uint32_t val) {
	return (val & 0xff000000) >> 24;
}

static uint32_t u32(uint8_t byte0, uint8_t byte1, uint8_t byte2, uint8_t byte3) {
	return ((uint32_t)(byte3) << 24) + ((uint32_t)(byte2) << 16) + ((uint32_t)(byte1) << 8) + (uint32_t)(byte0);
}

static uint16_t u16(uint8_t lsb, uint8_t msb) {
	return ((uint16_t)msb) * 256 + lsb;
}

static int16_t i16(uint8_t lsb, uint8_t msb) {
	return -(0x10000 - u16(lsb, msb));
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

static uint8_t capped_dec(uint8_t val, uint8_t max) {
	if (val == 0) {
		return max;
	}
	return val - 1;
}

static uint8_t capped_inc(uint8_t val, uint8_t max) {
	if (val == max) {
		return 0;
	}
	return val + 1;
}

static uint8_t limit_add(uint8_t val, uint8_t step, uint8_t max) {
	if (step > max || val >= max - step) {
		return max;
	}
	return val + step;
}

static uint8_t limit_sub(uint8_t val, uint8_t step, uint8_t min) {
	if (val <= (uint16_t)(min) + step) {
		return min;
	}
	return val - step;
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

/**
 * @brief Reset background color to sky-blue, for use when leaving a screen that uses another color.
 *
 * Force sky-blue as background color to avoid a flash during transition from a screen using another color.
 * Voluntary side effect: cancels any remaining nt buffer.
 */
static void reset_bg_color() {
	static uint8_t const palette_buffer[] = {0x01, 0x3f, 0x00, 0x01, 0x21, 0x00};
	uint8_t nt_offset = *nt_buffers_begin;
	for (uint8_t i = 0; i < sizeof(palette_buffer); ++i, ++nt_offset) {
		nametable_buffers[nt_offset] = palette_buffer[i];
	}
	*nt_buffers_end = nt_offset - 1;
}

extern uint8_t const CURRENT_BANK_NUMBER; // Actually an ASM macro, use its address or "code_bank()"
/** Return the bank in which the calling code is stored */
static uint8_t code_bank() {
	return ptr_lsb(&CURRENT_BANK_NUMBER);
}

/** Return the byte offset of a tile in VRAM */
static uint16_t ppu_tile_offset(uint8_t tile_index) {
	return (uint16_t)(tile_index) << 4;
}

/** Return the offset of the last nametable buffer in nametable_buffers array */
static uint8_t get_last_nt_buffer() {
	return *nt_buffers_end;
}

/** Set the offset of the last nametable buffer in nametable_buffers array */
static void set_last_nt_buffer(uint8_t offset) {
	*nt_buffers_end = offset;
}

/** Set values of an OAM sprite */
static void place_sprite(uint8_t sprite_idx, uint8_t y, uint8_t tile, uint8_t attributes, uint8_t x) {
	uint8_t const offset = sprite_idx * 4;
	oam_mirror[offset+0] = y;
	oam_mirror[offset+1] = tile;
	oam_mirror[offset+2] = attributes;
	oam_mirror[offset+3] = x;
}

#define CONST_HUNDREDS(val) ((((val) % 1000) / 100))
#define CONST_TENS(val) ((((val) % 100) / 10))
#define CONST_UNITS(val) ((val) % 10)

#pragma GCC diagnostic pop

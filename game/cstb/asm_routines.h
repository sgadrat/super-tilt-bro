#pragma once
#include "cstb/utils.h"
#include "cstb/mem_labels.h"
#include "cstb/nes_labels.h"
#include <stdint.h>
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wunused-function"

////////////////////////////////////
// Routines without arguments
//  simply declare it as extern
////////////////////////////////////

void audio_music_extra_tick();
void audio_music_tick();
void audio_mute_music();
void audio_play_interface_click();
void audio_unmute_music();
void dummy_routine();
void flash_all_sectors();
void fetch_controllers();
void flash_safe_sectors();
void init_menu();
void process_nt_buffers();
void reset_nt_buffers();
void re_init_menu();
void sleep_frame();
void tick_menu();
void wait_next_frame();

////////////////////////////////////
// Routines that need some glue code
//  implement the glue
////////////////////////////////////

static void wrap_trampoline(uint8_t call_bank, uint8_t return_bank, void(*routine)());

void animation_draw();
static void wrap_animation_draw(uint8_t const* animation_state) {
	*tmpfield11 = ptr_lsb(animation_state);
	*tmpfield12 = ptr_msb(animation_state);
	animation_draw();
}
static void long_animation_draw(uint8_t bank, uint8_t const* animation_state) {
	*tmpfield11 = ptr_lsb(animation_state);
	*tmpfield12 = ptr_msb(animation_state);
	wrap_trampoline(bank, code_bank(), &animation_draw);
}

void animation_init_state();
static void wrap_animation_init_state(uint8_t* animation_state, uint8_t const* animation_data) {
	*tmpfield11 = ptr_lsb(animation_state);
	*tmpfield12 = ptr_msb(animation_state);
	*tmpfield13 = ptr_lsb(animation_data);
	*tmpfield14 = ptr_msb(animation_data);
	animation_init_state();
}

void animation_tick();
static void wrap_animation_tick(uint8_t const* animation_state) {
	*tmpfield11 = ptr_lsb(animation_state);
	*tmpfield12 = ptr_msb(animation_state);
	animation_tick();
}
static void long_animation_tick(uint8_t bank, uint8_t const* animation_state) {
	*tmpfield11 = ptr_lsb(animation_state);
	*tmpfield12 = ptr_msb(animation_state);
	wrap_trampoline(bank, code_bank(), &animation_tick);
}

void animation_state_change_animation();
static void wrap_animation_state_change_animation(uint8_t const* animation_state, uint8_t const* animation_data) {
	*tmpfield11 = ptr_lsb(animation_state);
	*tmpfield12 = ptr_msb(animation_state);
	*tmpfield13 = ptr_lsb(animation_data);
	*tmpfield14 = ptr_msb(animation_data);
	animation_state_change_animation();
}

void change_global_game_state();
static void wrap_change_global_game_state(uint8_t new_state) {
	asm(
		"lda %0\n\t"
		"jsr change_global_game_state"
		:
		: "r"(new_state)
		: "memory" // do not clobber "a", change_global_game_state will not return anyway ; clobber "memory", we want all previous memory writes to be effective
	);
}

void trampoline();
static void wrap_trampoline(uint8_t call_bank, uint8_t return_bank, void(*routine)()) {
	*extra_tmpfield1 = ptr_lsb(routine);
	*extra_tmpfield2 = ptr_msb(routine);
	*extra_tmpfield3 = call_bank;
	*extra_tmpfield4 = return_bank;
	trampoline();
}

void cpu_to_ppu_copy_charset();
static void long_cpu_to_ppu_copy_charset(uint8_t bank, uint8_t const* charset, uint16_t ppu_addr, uint8_t foreground, uint8_t background) {
	// Set parameters
	*tmpfield3 = ptr_lsb(charset);
	*tmpfield4 = ptr_msb(charset);
	uint8_t const colors = (foreground << 2) | background;

	// Set PPU ADDR to destination
	*PPUSTATUS;
	*PPUADDR = u16_msb(ppu_addr);
	*PPUADDR = u16_lsb(ppu_addr);

	// Set trampoline parameters
	*extra_tmpfield1 = ptr_lsb(&cpu_to_ppu_copy_charset);
	*extra_tmpfield2 = ptr_msb(&cpu_to_ppu_copy_charset);
	*extra_tmpfield3 = bank;
	*extra_tmpfield4 = code_bank();

	// Call
	asm(
		"ldx %0\n\t"
		"jsr trampoline"
		:
		: "r"(colors)
		: "a", "x", "y", "memory"
	);
}

void cpu_to_ppu_copy_tileset();
static void wrap_cpu_to_ppu_copy_tileset(uint8_t const* tileset, uint16_t ppu_addr) {
	// Set cpu_to_ppu_copy_tileset parameters
	*tmpfield1 = ptr_lsb(tileset);
	*tmpfield2 = ptr_msb(tileset);

	// Set PPU ADDR to destination
	*PPUSTATUS;
	*PPUADDR = u16_msb(ppu_addr);
	*PPUADDR = u16_lsb(ppu_addr);

	// Call
	cpu_to_ppu_copy_tileset();
}
static void long_cpu_to_ppu_copy_tileset(uint8_t bank, uint8_t const* tileset, uint16_t ppu_addr) {
	// Set cpu_to_ppu_copy_tileset parameters
	*tmpfield1 = ptr_lsb(tileset);
	*tmpfield2 = ptr_msb(tileset);

	// Set PPU ADDR to destination
	*PPUSTATUS;
	*PPUADDR = u16_msb(ppu_addr);
	*PPUADDR = u16_lsb(ppu_addr);

	// Call
	wrap_trampoline(bank, code_bank(), &cpu_to_ppu_copy_tileset);
}

void cpu_to_ppu_copy_tileset_background();
static void long_cpu_to_ppu_copy_tileset_background(uint8_t bank, uint8_t const* tileset) {
	// Set cpu_to_ppu_copy_tileset parameters
	*tmpfield1 = ptr_lsb(tileset);
	*tmpfield2 = ptr_msb(tileset);

	// Call
	wrap_trampoline(bank, code_bank(), &cpu_to_ppu_copy_tileset_background);
}

void cpu_to_ppu_copy_tiles();
static void wrap_cpu_to_ppu_copy_tiles(uint8_t const* tileset, uint16_t ppu_addr, uint8_t num_bytes) {
	// Set cpu_to_ppu_copy_tiles parameters
	*tmpfield1 = ptr_lsb(tileset);
	*tmpfield2 = ptr_msb(tileset);
	*tmpfield3 = num_bytes;

	// Set PPU ADDR to destination
	*PPUSTATUS;
	*PPUADDR = u16_msb(ppu_addr);
	*PPUADDR = u16_lsb(ppu_addr);

	// Call
	cpu_to_ppu_copy_tiles();
}

void construct_nt_buffer();
static void wrap_construct_nt_buffer(uint8_t const* header, uint8_t const* payload) {
	*tmpfield1 = ptr_lsb(header);
	*tmpfield2 = ptr_msb(header);
	*tmpfield3 = ptr_lsb(payload);
	*tmpfield4 = ptr_msb(payload);
	construct_nt_buffer();
}

void construct_palettes_nt_buffer();
static void wrap_construct_palettes_nt_buffer(uint8_t const* palette) {
	*tmpfield1 = ptr_lsb(palette);
	*tmpfield2 = ptr_msb(palette);
	construct_palettes_nt_buffer();
}
static void long_construct_palettes_nt_buffer(uint8_t bank, uint8_t const* palette) {
	*tmpfield1 = ptr_lsb(palette);
	*tmpfield2 = ptr_msb(palette);
	wrap_trampoline(bank, code_bank(), &construct_palettes_nt_buffer);
}

void draw_zipped_nametable();
static void wrap_draw_zipped_nametable(uint8_t const* nametable) {
	*tmpfield1 = ptr_lsb(nametable);
	*tmpfield2 = ptr_msb(nametable);
	draw_zipped_nametable();
}
static void long_draw_zipped_nametable(uint8_t bank, uint8_t const* nametable) {
	*tmpfield1 = ptr_lsb(nametable);
	*tmpfield2 = ptr_msb(nametable);
	wrap_trampoline(bank, code_bank(), &draw_zipped_nametable);
}

void fixed_memcpy();
static void wrap_fixed_memcpy(uint8_t* dest, uint8_t const* src, uint8_t size) {
	// Prepare fixed_memcpy parameters
	*tmpfield1 = ptr_lsb(dest);
	*tmpfield2 = ptr_msb(dest);
	*tmpfield3 = ptr_lsb(src);
	*tmpfield4 = ptr_msb(src);
	*tmpfield5 = size;

	// Call fixed_memcpy
	fixed_memcpy();
}
static void long_memcpy(uint8_t* dest, uint8_t src_bank, uint8_t const* src, uint8_t size) {
	// Prepare fixed_memcpy parameters
	*tmpfield1 = ptr_lsb(dest);
	*tmpfield2 = ptr_msb(dest);
	*tmpfield3 = ptr_lsb(src);
	*tmpfield4 = ptr_msb(src);
	*tmpfield5 = size;

	// Call fixed_memcpy via trampoline
	wrap_trampoline(src_bank, code_bank(), &fixed_memcpy);
}

/**
 * @brief memcpy, adapted to 8bit cpu
 *
 * This is actually a shorthand alias for wrap_fixed_memcpy.
 * It is recomended over libc's memcpy when possible as it is way faster and lighter.
 *
 * Caveats:
 *  - Limited to 255 bytes max
 *  - Does not copy bytes in natural order (do not use on volatile memory areas)
 *  - No return value
 */
static void memcpy8(uint8_t* dest, uint8_t const* src, uint8_t size) {
	wrap_fixed_memcpy(dest, src, size);
}

void get_unzipped_bytes();
static void wrap_get_unzipped_bytes(uint8_t* dest, uint8_t const* zipped, uint16_t offset, uint8_t count) {
	*tmpfield1 = ptr_lsb(zipped);
	*tmpfield2 = ptr_msb(zipped);
	*tmpfield3 = u16_lsb(offset);
	*tmpfield4 = u16_msb(offset);
	*tmpfield5 = count;
	*tmpfield6 = ptr_lsb(dest);
	*tmpfield7 = ptr_msb(dest);
	get_unzipped_bytes();
}

static void long_get_unzipped_bytes(uint8_t bank, uint8_t* dest, uint8_t const* zipped, uint16_t offset, uint8_t count) {
	*tmpfield1 = ptr_lsb(zipped);
	*tmpfield2 = ptr_msb(zipped);
	*tmpfield3 = u16_lsb(offset);
	*tmpfield4 = u16_msb(offset);
	*tmpfield5 = count;
	*tmpfield6 = ptr_lsb(dest);
	*tmpfield7 = ptr_msb(dest);
	wrap_trampoline(bank, code_bank(), &get_unzipped_bytes);
}

void last_nt_buffer();
static uint8_t wrap_last_nt_buffer() {
	uint8_t index;
	asm(
		"jsr last_nt_buffer\n\t"
		"stx %0"
		: "=r"(index)
		:
		: "a", "x"
	);
	return index;
}

void push_nt_buffer();
static void wrap_push_nt_buffer(uint8_t const* buffer) {
	uint8_t const msb = (uint8_t)((int)(buffer) >> 8);
	uint8_t const lsb = (uint8_t)((int)(buffer) & 0x00ff);

	asm(
		"ldy %0\n\t"
		"lda %1\n\t"
		"jsr push_nt_buffer"
		:
		: "r"(msb), "r"(lsb)
		: "a", "x", "y", "memory"
	);
}

static void long_sleep_frame() {
	wrap_trampoline(code_bank(), code_bank(), &sleep_frame);
}

#pragma GCC diagnostic pop

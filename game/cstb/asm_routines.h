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

void audio_music_tick();
void audio_mute_music();
void audio_unmute_music();
void dummy_routine();
void fetch_controllers();
void init_menu();
void process_nt_buffers();
void reset_nt_buffers();
void re_init_menu();
void tick_menu();
void wait_next_frame();

////////////////////////////////////
// Routines that need some glue code
//  implement the glue
////////////////////////////////////

void animation_draw();
static void wrap_animation_draw(uint8_t const* animation_state, uint16_t camera_x, uint16_t camera_y) {
	*tmpfield11 = ptr_lsb(animation_state);
	*tmpfield12 = ptr_msb(animation_state);
	*tmpfield13 = u16_lsb(camera_x);
	*tmpfield14 = u16_msb(camera_x);
	*tmpfield15 = u16_lsb(camera_y);
	*tmpfield16 = u16_msb(camera_y);
	animation_draw();
}

void animation_init_state();
static void wrap_animation_init_state(uint8_t const* animation_state, uint8_t const* animation_data) {
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

void draw_zipped_nametable();
static void wrap_draw_zipped_nametable(uint8_t const* nametable) {
	*tmpfield1 = ptr_lsb(nametable);
	*tmpfield2 = ptr_msb(nametable);
	draw_zipped_nametable();
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

#pragma GCC diagnostic pop

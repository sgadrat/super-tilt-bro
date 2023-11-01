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

void audio_cut_sfx();
void audio_music_extra_tick();
void audio_music_tick();
void audio_mute_music();
void audio_play_interface_click();
void audio_play_interface_deny();
void audio_unmute_music();
void clear_bg_bot_left();
void clear_nt_buffers();
void dummy_routine();
void esp_wait_rx();
void esp_wait_tx();
void fetch_controllers();
void init_menu();
void particle_handlers_reinit();
void process_nt_buffers();
void re_init_menu();
void sleep_frame();
void stop_rendering();
void tick_menu();
void wait_next_frame();
void wait_vbi();

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

void audio_play_music_direct();
static void wrap_audio_play_music(uint8_t track_bank, uint8_t const* track_info) {
	*audio_current_track_lsb = ptr_lsb(track_info);
	*audio_current_track_msb = ptr_msb(track_info);
	*audio_current_track_bank = track_bank;
	wrap_trampoline(code_bank(), code_bank(), audio_play_music_direct);
}

void audio_play_sfx_from_list();
static void wrap_audio_play_sfx_from_list(uint8_t sfx_index) {
	asm(
		"ldx %0\n\t"
		"jsr audio_play_sfx_from_list"
		:
		: "r"(sfx_index)
		: "a", "x", "memory"
	);
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

void change_global_game_state_lite();
static void wrap_change_global_game_state_lite(uint8_t new_state, uint8_t const* init_routine) {
	*tmpfield1 = ptr_lsb(init_routine);
	*tmpfield2 = ptr_msb(init_routine);
	*tmpfield3 = new_state;
	change_global_game_state_lite();
}

static void long_change_global_game_state_lite(uint8_t bank, uint8_t new_state, uint8_t const* init_routine) {
	*tmpfield1 = ptr_lsb(init_routine);
	*tmpfield2 = ptr_msb(init_routine);
	*tmpfield3 = new_state;
	wrap_trampoline(bank, code_bank(), &change_global_game_state_lite);
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

void cpu_to_ppu_copy_charset_raw();
static void long_cpu_to_ppu_copy_charset_raw(uint8_t bank, uint8_t const* charset, uint16_t ppu_addr, uint8_t foreground, uint8_t background, uint8_t count) {
	// Set parameters
	*tmpfield3 = ptr_lsb(charset);
	*tmpfield4 = ptr_msb(charset);
	*tmpfield7 = count;
	uint8_t const colors = (foreground << 2) | background;

	// Set PPU ADDR to destination
	*PPUSTATUS;
	*PPUADDR = u16_msb(ppu_addr);
	*PPUADDR = u16_lsb(ppu_addr);

	// Set trampoline parameters
	*extra_tmpfield1 = ptr_lsb(&cpu_to_ppu_copy_charset_raw);
	*extra_tmpfield2 = ptr_msb(&cpu_to_ppu_copy_charset_raw);
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

void cpu_to_ppu_copy_tileset_modified();
static void long_cpu_to_ppu_copy_tileset_modified(uint8_t bank, uint8_t const* tileset, void(*modifier)(), uint16_t ppu_addr) {
	*tmpfield1 = ptr_lsb(tileset);
	*tmpfield2 = ptr_msb(tileset);
	*tmpfield4 = ptr_lsb(modifier);
	*tmpfield5 = ptr_msb(modifier);

	*PPUSTATUS;
	*PPUADDR = u16_msb(ppu_addr);
	*PPUADDR = u16_lsb(ppu_addr);

	wrap_trampoline(bank, code_bank(), &cpu_to_ppu_copy_tileset_modified);
}

void cpu_to_ppu_copy_tiles_modified();
static void long_cpu_to_ppu_copy_tiles_modified(uint8_t bank, uint8_t const* tileset, void(*modifier)(), uint16_t ppu_addr, uint8_t n_tiles) {
	*tmpfield1 = ptr_lsb(tileset);
	*tmpfield2 = ptr_msb(tileset);
	*tmpfield3 = n_tiles;
	*tmpfield4 = ptr_lsb(modifier);
	*tmpfield5 = ptr_msb(modifier);

	*PPUSTATUS;
	*PPUADDR = u16_msb(ppu_addr);
	*PPUADDR = u16_lsb(ppu_addr);

	wrap_trampoline(bank, code_bank(), &cpu_to_ppu_copy_tiles_modified);
}

void cpu_to_ppu_copy_tiles();
static void wrap_cpu_to_ppu_copy_tiles(uint8_t const* tileset, uint16_t ppu_addr, uint8_t num_tiles) {
	// Set cpu_to_ppu_copy_tiles parameters
	*tmpfield1 = ptr_lsb(tileset);
	*tmpfield2 = ptr_msb(tileset);
	*tmpfield3 = num_tiles;

	// Set PPU ADDR to destination
	*PPUSTATUS;
	*PPUADDR = u16_msb(ppu_addr);
	*PPUADDR = u16_lsb(ppu_addr);

	// Call
	cpu_to_ppu_copy_tiles();
}
static void long_cpu_to_ppu_copy_tiles(uint8_t bank, uint8_t const* tileset, uint16_t ppu_addr, uint8_t num_tiles) {
	// Set cpu_to_ppu_copy_tiles parameters
	*tmpfield1 = ptr_lsb(tileset);
	*tmpfield2 = ptr_msb(tileset);
	*tmpfield3 = num_tiles;

	// Set PPU ADDR to destination
	*PPUSTATUS;
	*PPUADDR = u16_msb(ppu_addr);
	*PPUADDR = u16_lsb(ppu_addr);

	// Call
	wrap_trampoline(bank, code_bank(), &cpu_to_ppu_copy_tiles);
}

void construct_nt_buffer();
static void wrap_construct_nt_buffer(uint8_t const* header, uint8_t const* payload) {
	*tmpfield1 = ptr_lsb(header);
	*tmpfield2 = ptr_msb(header);
	*tmpfield3 = ptr_lsb(payload);
	*tmpfield4 = ptr_msb(payload);
	construct_nt_buffer();
}
static void long_construct_nt_buffer(uint8_t bank, uint8_t const* header, uint8_t const* payload) {
	*tmpfield1 = ptr_lsb(header);
	*tmpfield2 = ptr_msb(header);
	*tmpfield3 = ptr_lsb(payload);
	*tmpfield4 = ptr_msb(payload);
	wrap_trampoline(bank, code_bank(), &construct_nt_buffer);
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

void draw_zipped_vram();
static void wrap_draw_zipped_vram(uint8_t const* nametable, uint16_t ppu_addr) {
	*tmpfield1 = ptr_lsb(nametable);
	*tmpfield2 = ptr_msb(nametable);
	*PPUSTATUS;
	*PPUADDR = u16_msb(ppu_addr);
	*PPUADDR = u16_lsb(ppu_addr);
	draw_zipped_vram();
}
static void long_draw_zipped_vram(uint8_t bank, uint8_t const* nametable, uint16_t ppu_addr) {
	*tmpfield1 = ptr_lsb(nametable);
	*tmpfield2 = ptr_msb(nametable);
	*PPUSTATUS;
	*PPUADDR = u16_msb(ppu_addr);
	*PPUADDR = u16_lsb(ppu_addr);
	wrap_trampoline(bank, code_bank(), &draw_zipped_vram);
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

void place_character_ppu_tiles_direct();
static void wrap_place_character_ppu_tiles_direct(uint8_t player_num, uint8_t char_num) {
	asm(
		"ldx %0\n\t"
		"ldy %1\n\t"
		"jsr place_character_ppu_tiles_direct"
		:
		: "r"(player_num), "r"(char_num)
		: "a", "x", "y", "memory"
	);
}
static void long_place_character_ppu_tiles_direct(uint8_t player_num, uint8_t char_num) {
	asm(
		"ldx %0\n\t"
		"ldy %1\n\t"
		"lda #<place_character_ppu_tiles_direct\n\t"
		"sta extra_tmpfield1\n\t"
		"lda #>place_character_ppu_tiles_direct\n\t"
		"sta extra_tmpfield2\n\t"
		"lda #CURRENT_BANK_NUMBER\n\t"
		"sta extra_tmpfield3\n\t"
		"sta extra_tmpfield4\n\t"
		"jsr trampoline"
		:
		: "r"(player_num), "r"(char_num)
		: "a", "x", "y", "memory"
	);
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

void sha256_sum();
static void wrap_sha256_sum(uint8_t const* data, uint8_t data_length) {
	memcpy8(sha_msg, data, data_length);
	uint16_t const data_length_bits = (uint16_t)(data_length) * 8;
	*sha_length_lsb = u16_lsb(data_length_bits);
	*sha_length_msb = u16_msb(data_length_bits);
	sha256_sum();
}

void start_rendering();
static void wrap_start_rendering(uint8_t scroll_nametable) {
	asm(
		"lda %0\n\t"
		"jsr start_rendering"
		:
		: "r"(scroll_nametable)
		: "a", "memory"
	);
}

#pragma GCC diagnostic pop

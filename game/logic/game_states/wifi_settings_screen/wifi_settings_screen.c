#include <cstb.h>

///////////////////////////////////////
// C types for structured data
///////////////////////////////////////

///////////////////////////////////////
// Global labels from the ASM codebase
///////////////////////////////////////

extern uint8_t const CURRENT_BANK_NUMBER; // Actually an ASM macro, use its address or "code_bank()"
extern uint8_t const TILESET_ASCII_BANK_NUMBER; // Actually a label, use its address or "tileset_ascii_bank()"

extern uint8_t const tileset_ascii;

///////////////////////////////////////
// Screen specific ASM functions
///////////////////////////////////////

///////////////////////////////////////
// Screen specific ASM labels
///////////////////////////////////////

extern uint8_t const menu_wifi_settings_nametable;
extern uint8_t const menu_wifi_settings_palette;
extern uint8_t const tileset_menu_wifi_settings;

///////////////////////////////////////
// Constants specific to this file
///////////////////////////////////////

///////////////////////////////////////
// Utility functions
///////////////////////////////////////

static uint8_t tileset_ascii_bank() {
	return ptr_lsb(&TILESET_ASCII_BANK_NUMBER);
}

static uint8_t code_bank() {
	return ptr_lsb(&CURRENT_BANK_NUMBER);
}

//TODO Share code with menu_online_mode
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

///////////////////////////////////////
// State implementation
///////////////////////////////////////

#if 0
void audio_play_parry();
static void sound_effect_click() {
	audio_play_parry();
}
#endif

void init_wifi_settings_screen_extra() {
	// Draw static part of the screen
	wrap_construct_palettes_nt_buffer(&menu_wifi_settings_palette);
	wrap_draw_zipped_nametable(&menu_wifi_settings_nametable);
	wrap_cpu_to_ppu_copy_tileset(&tileset_menu_wifi_settings, 0x1000);
	long_cpu_to_ppu_copy_tileset(tileset_ascii_bank(), &tileset_ascii, 0x1200);
}

void wifi_settings_screen_tick_extra() {
	reset_nt_buffers();
}

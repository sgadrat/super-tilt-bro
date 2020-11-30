#include <cstb.h>
#include <stdint.h>

//TODO thys ar asm lobel
//CONFIG_SCREEN_EXTRA_BANK_NUMBER = CURRENT_BANK_NUMBER

static uint8_t const TILE_ICON_MUSIC_1 = 0xe8;
static uint8_t const TILE_ICON_MUSIC_2 = 0xe9;
static uint8_t const TILE_ICON_MUSIC_3 = 0xea;
static uint8_t const TILE_ICON_MUSIC_4 = 0xeb;
static uint8_t const TILE_ICON_STOCKS_1 = 0xec;
static uint8_t const TILE_ICON_STOCKS_2 = 0xed;
static uint8_t const TILE_ICON_STOCKS_3 = 0xee;
static uint8_t const TILE_ICON_STOCKS_4 = 0xef;
static uint8_t const TILE_ICON_PLAYER_1 = 0xf0;
static uint8_t const TILE_ICON_PLAYER_2 = 0xf1;
static uint8_t const TILE_ICON_PLAYER_3 = 0xf2;
static uint8_t const TILE_ICON_PLAYER_4 = 0xf3;

static uint8_t const CONFIG_SCREEN_NB_OPTIONS = 3;
static uint8_t const sprites[] = {
		0x4f, TILE_ICON_MUSIC_1, 0x00, 0x50,
		0x4f, TILE_ICON_MUSIC_2, 0x00, 0x58,
		0x57, TILE_ICON_MUSIC_3, 0x00, 0x50,
		0x57, TILE_ICON_MUSIC_4, 0x00, 0x58,
		0x6f, TILE_ICON_STOCKS_1, 0x00, 0x50,
		0x6f, TILE_ICON_STOCKS_2, 0x00, 0x58,
		0x77, TILE_ICON_STOCKS_3, 0x00, 0x50,
		0x77, TILE_ICON_STOCKS_4, 0x00, 0x58,
		0x8f, TILE_ICON_PLAYER_1, 0x00, 0x50,
		0x8f, TILE_ICON_PLAYER_2, 0x00, 0x58,
		0x97, TILE_ICON_PLAYER_3, 0x00, 0x50,
		0x97, TILE_ICON_PLAYER_4, 0x00, 0x58,
};

void config_update_screen();

void init_config_screen_extra() {
	// Place sprites
	for (uint8_t x = 0; x < 48; ++x) {
		oam_mirror[x] = sprites[x];
	}

	// Init local options values from global state
	*config_music_enabled = *audio_music_enabled;
	*config_selected_option = 0;

	// Adapt to configuration's state
	config_update_screen();

	// Process the batch of nt buffers immediately (while the PPU is disabled)
	process_nt_buffers();
	reset_nt_buffers();

	// Initialize common menus effects
	re_init_menu();
}

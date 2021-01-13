#include <cstb.h>

///////////////////////////////////////
// C types for structured data
///////////////////////////////////////

///////////////////////////////////////
// Global labels from the ASM codebase
///////////////////////////////////////

extern uint8_t const menu_online_mode_nametable;
extern uint8_t const menu_online_mode_palette;
extern uint8_t const tileset_menu_online_mode;
extern uint8_t const tileset_menu_online_mode_sprites;

///////////////////////////////////////
// Screen specific ASM functions
///////////////////////////////////////

///////////////////////////////////////
// Constants specific to this file
///////////////////////////////////////

uint8_t const NB_OPTIONS = 3;
uint8_t const OPTION_CASUAL = 0;
uint8_t const OPTION_RANKED = 1;
uint8_t const OPTION_LOGIN = 2;

//uint8_t const NB_SPRITE_PER_OPTION = 16;
#define NB_SPRITE_PER_OPTION 16

static uint8_t const earth_sprite_per_option[][NB_SPRITE_PER_OPTION] = {
	{
		255, 255, 0, 1,
		255, 2, 3, 4,
		5, 6, 7, 8,
		9, 10, 11, 12
	},
	{
		13, 14, 255, 255,
		15, 16, 17, 255,
		18, 19, 20, 21,
		22, 23, 24, 25
	},
	{
		26, 27, 28, 29,
		30, 31, 32, 33,
		255, 34, 35, 36,
		255, 255, 37, 38
	},
};

struct Position16 {
    uint16_t x;
    uint16_t y;
};

static struct Position16 const first_earth_sprite_per_option[] = {
	{80, 79},
	{144, 79},
	{80, 143},
};

///////////////////////////////////////
// Utility functions
///////////////////////////////////////

///////////////////////////////////////
// State implementation
///////////////////////////////////////

void audio_play_parry();
static void sound_effect_click() {
	audio_play_parry();
}

static void next_screen() {
	switch (*online_mode_selection_current_option) {
		case OPTION_CASUAL:
			wrap_change_global_game_state(GAME_STATE_CHARACTER_SELECTION);
			break;
		case OPTION_RANKED:
			//TODO
			break;
		case OPTION_LOGIN:
			//TODO
			break;
	}
}

static void previous_screen() {
	wrap_change_global_game_state(GAME_STATE_MODE_SELECTION);
}

static void take_input(uint8_t controller_btns, uint8_t last_fame_btns) {
	if (controller_btns != last_fame_btns) {
		switch (controller_btns) {
			case CONTROLLER_BTN_DOWN:
				sound_effect_click();
				*online_mode_selection_current_option = (*online_mode_selection_current_option + 2) % NB_OPTIONS;
				break;
			case CONTROLLER_BTN_UP:
				sound_effect_click();
				if (*online_mode_selection_current_option < 2) {
					*online_mode_selection_current_option += NB_OPTIONS;
				}
				*online_mode_selection_current_option -= 2;
				break;
			case CONTROLLER_BTN_LEFT:
				sound_effect_click();
				if (*online_mode_selection_current_option > 0) {
					--*online_mode_selection_current_option;
				}else {
					*online_mode_selection_current_option = NB_OPTIONS - 1;
				}
				break;
			case CONTROLLER_BTN_RIGHT:
				sound_effect_click();
				*online_mode_selection_current_option = (*online_mode_selection_current_option + 1) % NB_OPTIONS;
				break;

			// Buttons that take effect on release
			case 0:
				switch (last_fame_btns) {
					case CONTROLLER_BTN_A:
					case CONTROLLER_BTN_START:
						sound_effect_click();
						next_screen();
						break;
					case CONTROLLER_BTN_B:
						sound_effect_click();
						previous_screen();
						break;
					default:
						break;
				};
				break;
			default:
				break;
		};
	}
}

static void highlight_option() {
	// Place earth sprites behind selected box, and above others
	for (uint8_t option = 0; option < NB_OPTIONS; ++option) {
		uint8_t const attributes = (option == *online_mode_selection_current_option ? 0x20 : 0x00);
		for (uint8_t y = 0; y < 4; ++y) {
			for (uint8_t x = 0; x < 4; ++x) {
				uint8_t const tile_index = earth_sprite_per_option[option][y * 4 + x];
				if (tile_index != 255) {
					uint8_t const sprite_num = option * NB_SPRITE_PER_OPTION + y * 4 + x;
					uint8_t const sprite_offset = sprite_num * 4;
					oam_mirror[sprite_offset + 2] = attributes;
				}
			}
		}
	}

	// Set boxes palette
	static uint8_t const buffers_header[][3+48] = {
		{
			0x23, 0xc8, 48,
			0x5f, 0x50, 0x50, 0x50, 0x00, 0x00, 0x00, 0x00,
			0x55, 0x55, 0x55, 0x11, 0x00, 0x00, 0x00, 0x00,
			0x05, 0x05, 0x05, 0x01, 0x00, 0x00, 0x00, 0x00,
			0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
			0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
			0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
		},
		{
			0x23, 0xc8, 48,
			0x0f, 0x00, 0x00, 0x00, 0x50, 0x50, 0x50, 0x50,
			0x00, 0x00, 0x00, 0x00, 0x44, 0x55, 0x55, 0x55,
			0x00, 0x00, 0x00, 0x00, 0x04, 0x05, 0x05, 0x05,
			0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
			0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
			0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
		},
		{
			0x23, 0xc8, 48,
			0x0f, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
			0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
			0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
			0x50, 0x50, 0x50, 0x10, 0x00, 0x00, 0x00, 0x00,
			0x55, 0x55, 0x55, 0x11, 0x00, 0x00, 0x00, 0x00,
			0x05, 0x05, 0x05, 0x05, 0x00, 0x00, 0x00, 0x00,
		},
	};
	wrap_push_nt_buffer(buffers_header[*online_mode_selection_current_option]);
}

void init_online_mode_screen_extra() {
	// Draw static part of the screen
	wrap_construct_palettes_nt_buffer(&menu_online_mode_palette);
	wrap_draw_zipped_nametable(&menu_online_mode_nametable);
	wrap_cpu_to_ppu_copy_tiles((&tileset_menu_online_mode)+1, 0x1000, tileset_menu_online_mode);
	wrap_cpu_to_ppu_copy_tiles((&tileset_menu_online_mode_sprites)+1, 0x0000, tileset_menu_online_mode_sprites);

	// Place earth sprites
	for (uint8_t option = 0; option < NB_OPTIONS; ++option) {
		struct Position16 const sprites_postion = first_earth_sprite_per_option[option];
		for (uint8_t y = 0; y < 4; ++y) {
			uint8_t const pixel_y = sprites_postion.y + 8 * y;
			for (uint8_t x = 0; x < 4; ++x) {
				uint8_t const tile_index = earth_sprite_per_option[option][y * 4 + x];
				if (tile_index != 255) {
					uint8_t const pixel_x = sprites_postion.x + 8 * x;
					uint8_t const sprite_num = option * NB_SPRITE_PER_OPTION + y * 4 + x;
					uint8_t const sprite_offset = sprite_num * 4;
					oam_mirror[sprite_offset + 0] = pixel_y;
					oam_mirror[sprite_offset + 1] = tile_index;
					oam_mirror[sprite_offset + 2] = 0;
					oam_mirror[sprite_offset + 3] = pixel_x;
				}
			}
		}
	}

	// Initialize state
	*online_mode_selection_current_option = 0;
}

void online_mode_screen_tick_extra() {
	reset_nt_buffers();

	for (uint8_t player = 0; player < 2; ++player) {
		take_input(controller_a_btns[player], controller_a_last_frame_btns[player]);
	}

	highlight_option();
}

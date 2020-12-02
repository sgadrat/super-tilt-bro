#include <cstb.h>
#include <stddef.h>
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
static uint8_t const OPTION_MUSIC = 0;
//static uint8_t const OPTION_STOCKS = 1;
//static uint8_t const OPTION_AI = 2;

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

static uint8_t const options_last_value[] = {1, 4, 3};
static uint8_t* const options_variable[] = {config_music_enabled, config_initial_stocks, config_ai_level};

static void updated_music_option(uint8_t new_value) {
	if (new_value == 0) {
		audio_mute_music();
	}else {
		audio_unmute_music();
	}
}

static void next_value() {
	uint8_t const option = *config_selected_option;
	uint8_t* const option_value = options_variable[option];

	if (*option_value < options_last_value[option]) {
		++*option_value;
	}else {
		*option_value = 0;
	}

	if (option == OPTION_MUSIC) {
		updated_music_option(*option_value);
	}
}

static void previous_value() {
	uint8_t const option = *config_selected_option;
	uint8_t* const option_value = options_variable[option];

	if (*option_value > 0) {
		--*option_value;
	}else {
		*option_value = options_last_value[option];
	}

	if (option == OPTION_MUSIC) {
		updated_music_option(*option_value);
	}
}

static void next_option() {
	if (*config_selected_option < CONFIG_SCREEN_NB_OPTIONS - 1) {
		++*config_selected_option;
	}else {
		*config_selected_option = 0;
	}
}

static void previous_option() {
	if (*config_selected_option > 0) {
		--*config_selected_option;
	}else {
		*config_selected_option = CONFIG_SCREEN_NB_OPTIONS - 1;
	}
}

static void next_screen() {
	wrap_change_global_game_state(GAME_STATE_CHARACTER_SELECTION);
}

static void previous_screen() {
	wrap_change_global_game_state(GAME_STATE_MODE_SELECTION);
}

static void config_update_screen() {
	static uint8_t const highlight_headers[][3] = {
		{0x23, 0xd3, 0x03},
		{0x23, 0xdb, 0x03},
		{0x23, 0xe3, 0x03},
	};
	static uint8_t const highlight_on[3] = {0x50, 0x50, 0x50};
	static uint8_t const highlight_off[3] = {0x00, 0x00, 0x00};

	static uint8_t const buffer_on[] = {0x21, 0x70, 0x03, 0xf4, 0xf3, 0x02};
	static uint8_t const buffer_off[] = {0x21, 0x70, 0x03, 0xf4, 0xeb, 0xeb};
	static uint8_t const buffer_one[] = {0x21, 0xee, 0x06, 0x02, 0xf4, 0xf3, 0xea, 0x02, 0x02};
	static uint8_t const buffer_two[] = {0x21, 0xee, 0x06, 0x02, 0xf9, 0xfc, 0xf4, 0x02, 0x02};
	static uint8_t const buffer_three[] = {0x21, 0xee, 0x06, 0x02, 0xf9, 0xed, 0xf7, 0xea, 0xea};
	static uint8_t const buffer_four[] = {0x21, 0xee, 0x06, 0x02, 0xeb, 0xf4, 0xfa, 0xf7, 0x02};
	static uint8_t const buffer_five[] = {0x21, 0xee, 0x06, 0x02, 0xeb, 0xee, 0xfb, 0xea, 0x02};
	static uint8_t const buffer_human[] = {0x22, 0x6e, 0x06, 0x02, 0xed, 0xfa, 0xf2, 0xe6, 0xf3};
	static uint8_t const buffer_easy[] = {0x22, 0x6e, 0x06, 0x02, 0xea, 0xe6, 0xf8, 0xfe, 0x02};
	static uint8_t const buffer_fair[] = {0x22, 0x6e, 0x06, 0x02, 0xeb, 0xe6, 0xee, 0xf7, 0x02};
	static uint8_t const buffer_hard[] = {0x22, 0x6e, 0x06, 0x02, 0xed, 0xe6, 0xf7, 0xe9, 0x02};
	static uint8_t const* options_buffers[] = {
		buffer_off,   buffer_on,   NULL,         NULL,        NULL,
		buffer_one,   buffer_two,  buffer_three, buffer_four, buffer_five,
		buffer_human, buffer_easy, buffer_fair,  buffer_hard
	};

	for (uint8_t option = 0; option < CONFIG_SCREEN_NB_OPTIONS; ++option) {
		// Highlight option
		uint8_t const is_selected = (option == *config_selected_option);
		wrap_construct_nt_buffer(highlight_headers[option], is_selected ? highlight_on : highlight_off);

		// Draw option's value
		wrap_push_nt_buffer(options_buffers[option*5 + *options_variable[option]]);
	}
}

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

void config_screen_tick_extra() {
	// Clear already written buffers
	reset_nt_buffers();

	// Play common menus effects
	tick_menu();

	// Check if a button is released and trigger correct action
	for (uint8_t controller = 0; controller < 2; ++controller) {
		if (*(controller_a_btns + controller) == 0) {
			switch (*(controller_a_last_frame_btns + controller)) {
				case CONTROLLER_BTN_RIGHT:
					next_value(); break;
				case CONTROLLER_BTN_LEFT:
					previous_value(); break;
				case CONTROLLER_BTN_DOWN:
					next_option(); break;
				case CONTROLLER_BTN_UP:
					previous_option(); break;
				case CONTROLLER_BTN_START:
					next_screen(); break;
				case CONTROLLER_BTN_B:
					previous_screen(); break;
				case CONTROLLER_BTN_A:
					next_value(); break;
				default:
					break;
			}
		}
	}

	// Redraw
	config_update_screen();
}

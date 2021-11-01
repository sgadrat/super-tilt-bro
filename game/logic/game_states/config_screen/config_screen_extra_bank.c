#include <cstb.h>
#include <stddef.h>
#include <stdint.h>

///////////////////////////////////////
// C types for structured data
///////////////////////////////////////

typedef struct CursorState {
	uint8_t goal_y;
	uint8_t step_y;
} __attribute__((__packed__)) CursorState;

static CursorState* Cursor(uint8_t* raw) {
	return (CursorState*)raw;
}

///////////////////////////////////////
// Global labels from the ASM codebase
///////////////////////////////////////

extern uint8_t const charset_alphanum;
extern uint8_t const tileset_menu_config;
extern uint8_t const tileset_menu_config_sprites;
extern uint8_t const menu_config_anim_cursor;
extern uint8_t const menu_config_nametable;
extern uint8_t const menu_config_palette;

// Labels, use their address or the respective *_bank() helper function
extern uint8_t const CHARSET_ALPHANUM_BANK_NUMBER;
extern uint8_t const MENU_CONFIG_SCREEN_BANK_NUMBER;
extern uint8_t const MENU_CONFIG_TILESET_BANK_NUMBER;
extern uint8_t const MENU_CONFIG_ANIMS_BANK_NUMBER;

///////////////////////////////////////
// Constants specific to this file
///////////////////////////////////////

static uint8_t const CONFIG_SCREEN_NB_OPTIONS = 3;
static uint8_t const OPTION_MUSIC = 0;
//static uint8_t const OPTION_STOCKS = 1;
//static uint8_t const OPTION_AI = 2;

static uint8_t const CURSOR_ANIM_FIRST_SPRITE = 0;
static uint8_t const CURSOR_ANIM_LAST_SPRITE = 5;

static uint8_t const options_last_value[] = {1, 4, 3};
static uint8_t* const options_variable[] = {config_music_enabled, config_initial_stocks, config_ai_level};

static uint8_t const cursor_pos_y[] = {79, 111, 143};
static uint8_t const CURSOR_POS_X = 104;

///////////////////////////////////////
// Utility functions
///////////////////////////////////////

static uint8_t anims_bank() {
	return ptr_lsb(&MENU_CONFIG_ANIMS_BANK_NUMBER);
}

static uint8_t charset_bank() {
	return ptr_lsb(&CHARSET_ALPHANUM_BANK_NUMBER);
}

static uint8_t screen_bank() {
	return ptr_lsb(&MENU_CONFIG_SCREEN_BANK_NUMBER);
}

static uint8_t tileset_bank() {
	return ptr_lsb(&MENU_CONFIG_TILESET_BANK_NUMBER);
}

///////////////////////////////////////
// State implementation
///////////////////////////////////////

static void move_cursor();

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

	move_cursor();
}

static void previous_option() {
	if (*config_selected_option > 0) {
		--*config_selected_option;
	}else {
		*config_selected_option = CONFIG_SCREEN_NB_OPTIONS - 1;
	}

	move_cursor();
}

static void next_screen() {
	wrap_change_global_game_state(GAME_STATE_CHARACTER_SELECTION);
}

static void previous_screen() {
	wrap_change_global_game_state(GAME_STATE_MODE_SELECTION);
}

static void update_screen() {
	static uint8_t const highlight_headers[][3] = {
		{0x23, 0xd3, 0x03},
		{0x23, 0xdb, 0x03},
		{0x23, 0xe3, 0x03},
	};
	static uint8_t const highlight_on[3] = {0x50, 0x50, 0x10};
	static uint8_t const highlight_off[3] = {0xf0, 0xf0, 0x30};

	uint8_t const CHAR_SPACE = 0x38;

	static uint8_t const buffer_on[] = {0x21, 0x70, 0x03, 0xf4, 0xf3, CHAR_SPACE};
	static uint8_t const buffer_off[] = {0x21, 0x70, 0x03, 0xf4, 0xeb, 0xeb};

	static uint8_t const buffer_one[] = {0x21, 0xee, 0x06, CHAR_SPACE, 0xf4, 0xf3, 0xea, CHAR_SPACE, CHAR_SPACE};
	static uint8_t const buffer_two[] = {0x21, 0xee, 0x06, CHAR_SPACE, 0xf9, 0xfc, 0xf4, CHAR_SPACE, CHAR_SPACE};
	static uint8_t const buffer_three[] = {0x21, 0xee, 0x06, CHAR_SPACE, 0xf9, 0xed, 0xf7, 0xea, 0xea};
	static uint8_t const buffer_four[] = {0x21, 0xee, 0x06, CHAR_SPACE, 0xeb, 0xf4, 0xfa, 0xf7, CHAR_SPACE};
	static uint8_t const buffer_five[] = {0x21, 0xee, 0x06, CHAR_SPACE, 0xeb, 0xee, 0xfb, 0xea, CHAR_SPACE};

	static uint8_t const buffer_human[] = {0x22, 0x6e, 0x06, CHAR_SPACE, 0xed, 0xfa, 0xf2, 0xe6, 0xf3};
	static uint8_t const buffer_easy[] = {0x22, 0x6e, 0x06, CHAR_SPACE, 0xea, 0xe6, 0xf8, 0xfe, CHAR_SPACE};
	static uint8_t const buffer_fair[] = {0x22, 0x6e, 0x06, CHAR_SPACE, 0xeb, 0xe6, 0xee, 0xf7, CHAR_SPACE};
	static uint8_t const buffer_hard[] = {0x22, 0x6e, 0x06, CHAR_SPACE, 0xed, 0xe6, 0xf7, 0xe9, CHAR_SPACE};

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

static void init_cursor() {
	// Init animation
	long_animation_init_state(anims_bank(), config_screen_cursor_anim, &menu_config_anim_cursor);
	Anim(config_screen_cursor_anim)->x = CURSOR_POS_X;
	Anim(config_screen_cursor_anim)->y = cursor_pos_y[*config_selected_option];
	Anim(config_screen_cursor_anim)->first_sprite_num = CURSOR_ANIM_FIRST_SPRITE;
	Anim(config_screen_cursor_anim)->last_sprite_num = CURSOR_ANIM_LAST_SPRITE;

	// Init cursor state
	Cursor(config_screen_cursor_state)->goal_y = cursor_pos_y[*config_selected_option];
	Cursor(config_screen_cursor_state)->step_y = 0;
}

static void tick_cursor() {
	CursorState* cursor = Cursor(config_screen_cursor_state);
	Animation* anim = Anim(config_screen_cursor_anim);

	// Place cursor
	int16_t const diff_y = cursor->goal_y - (int16_t)anim->y;
	int16_t const move_y = max(-cursor->step_y, min(cursor->step_y, diff_y));
	anim->y += move_y;

	// Tick animation
	*player_number = 0;
	long_animation_draw(anims_bank(), config_screen_cursor_anim);
	long_animation_tick(anims_bank(), config_screen_cursor_anim);
}

static void move_cursor() {
	CursorState* cursor = Cursor(config_screen_cursor_state);
	Animation* anim = Anim(config_screen_cursor_anim);
	cursor->goal_y = cursor_pos_y[*config_selected_option]; 
	if (cursor->goal_y > anim->y) {
		cursor->step_y = max(1, (cursor->goal_y - anim->y) / 4);
	}else {
		cursor->step_y = max(1, (anim->y - cursor->goal_y) / 4);
	}
}

void init_config_screen_extra() {
	// Draw screen
	long_cpu_to_ppu_copy_tileset_background(tileset_bank(), &tileset_menu_config);
	long_cpu_to_ppu_copy_tileset(tileset_bank(), &tileset_menu_config_sprites, 0x0000);
	long_draw_zipped_nametable(screen_bank(), &menu_config_nametable);
	long_cpu_to_ppu_copy_charset(charset_bank(), &charset_alphanum, 0x1dc0, 3, 2);

	// Init local options values from global state
	*config_music_enabled = *audio_music_enabled;
	*config_selected_option = 0;

	// Adapt to configuration's state
	update_screen();

	// Process the batch of nt buffers immediately (while the PPU is disabled)
	process_nt_buffers();
	reset_nt_buffers();

	// Construct palettes buffer
	//  NOTE - after batch processing of nt-buffers, this one will produce a glitch if done outside of vblank
	long_construct_palettes_nt_buffer(screen_bank(), &menu_config_palette);

	// Initialize common menus effects
	if (*previous_global_game_state == GAME_STATE_MODE_SELECTION) {
		// Transitioning from a screen with menu effects, simply reinit
		re_init_menu();
	}else {
		// Common menu effects
		init_menu();

		// Set clouds Y position
		for (uint8_t cloud_index = 0; cloud_index < MENU_COMMON_NB_CLOUDS; ++cloud_index) {
			int16_t y_pos = i16(menu_common_cloud_1_y[cloud_index], menu_common_cloud_1_y_msb[cloud_index]);
			y_pos -= 37 * 2 * 2; // Each half-screen moves clouds 37 pixels up. Config screen is 2 screens down from initial state.
			menu_common_cloud_1_y[cloud_index] = i16_lsb(y_pos);
			menu_common_cloud_1_y_msb[cloud_index] = i16_msb(y_pos);
		}
	}

	// Initialize screen-specific effects
	init_cursor();
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
					audio_play_interface_click();
					next_value(); break;
				case CONTROLLER_BTN_LEFT:
					audio_play_interface_click();
					previous_value(); break;
				case CONTROLLER_BTN_DOWN:
					audio_play_interface_click();
					next_option(); break;
				case CONTROLLER_BTN_UP:
					audio_play_interface_click();
					previous_option(); break;
				case CONTROLLER_BTN_START:
				case CONTROLLER_BTN_A:
					audio_play_interface_click();
					next_screen(); break;
				case CONTROLLER_BTN_B:
					audio_play_interface_click();
					previous_screen(); break;
				default:
					break;
			}
		}
	}

	// Redraw
	tick_cursor();
	update_screen();
}

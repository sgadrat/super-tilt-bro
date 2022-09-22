#include <cstb.h>

///////////////////////////////////////
// Global labels from the ASM codebase
///////////////////////////////////////

extern uint8_t const charset_alphanum;
extern uint8_t const menu_mode_selection_palette;
extern uint8_t const nametable_mode_selection;
extern uint8_t const tileset_menu_mode_selection;

// Labels, use their address or the associtated *_bank() function
extern uint8_t const CHARSET_ALPHANUM_BANK_NUMBER;
extern uint8_t const MENU_MODE_SELECTION_SCREEN_BANK;
extern uint8_t const MENU_MODE_SELECTION_TILESET_BANK;

///////////////////////////////////////
// Constants specific to this file
///////////////////////////////////////

//static uint8_t const NB_OPTIONS = 5;
static uint8_t const OPTION_LOCAL = 0;
static uint8_t const OPTION_ONLINE = 1;
//static uint8_t const OPTION_SUPPORT = 2;
//static uint8_t const OPTION_CREDITS = 3;
static uint8_t const OPTION_ARCADE = 4;

///////////////////////////////////////
// Utility functions
///////////////////////////////////////

#define ATT(br, bl, tr, tl) ((br << 6) + (bl << 4) + (tr << 2) + tl)

static uint8_t charset_bank() {
	return ptr_lsb(&CHARSET_ALPHANUM_BANK_NUMBER);
}

static uint8_t screen_bank() {
	return ptr_lsb(&MENU_MODE_SELECTION_SCREEN_BANK);
}

static uint8_t tileset_bank() {
	return ptr_lsb(&MENU_MODE_SELECTION_TILESET_BANK);
}

/** Not a real yield, pass a frame "as if" it gone through main loop */
static void yield() {
	wrap_trampoline(code_bank(), code_bank(), &sleep_frame);
	fetch_controllers();
}

///////////////////////////////////////
// State implementation
///////////////////////////////////////

static void go_up() {
	audio_play_interface_click();
	static uint8_t const dest_option[] = {3, 4, 0, 2, 2};
	*menu_state_mode_selection_current_option = dest_option[*menu_state_mode_selection_current_option];
}

static void go_down() {
	audio_play_interface_click();
	static uint8_t const dest_option[] = {2, 2, 3, 0, 1};
	*menu_state_mode_selection_current_option = dest_option[*menu_state_mode_selection_current_option];
}

static void go_left() {
	audio_play_interface_click();
	static uint8_t const dest_option[] = {1, 0, 0, 4, 3};
	*menu_state_mode_selection_current_option = dest_option[*menu_state_mode_selection_current_option];
}

static void go_right() {
	audio_play_interface_click();
	static uint8_t const dest_option[] = {1, 0, 1, 4, 3};
	*menu_state_mode_selection_current_option = dest_option[*menu_state_mode_selection_current_option];
}

static void previous_screen() {
	audio_play_interface_click();
	wrap_change_global_game_state(GAME_STATE_TITLE);
}

static void next_screen() {
	static uint8_t const option_to_game_state[] = {
		GAME_STATE_CONFIG,
		GAME_STATE_ONLINE_MODE_SELECTION,
		GAME_STATE_DONATION,
		GAME_STATE_CREDITS,
		GAME_STATE_ARCADE_MODE
	};

	if (no_network()) {
		if (*menu_state_mode_selection_current_option == OPTION_ONLINE) {
			return;
		}
	}

	audio_play_interface_click();
	if (*menu_state_mode_selection_current_option == OPTION_LOCAL || *menu_state_mode_selection_current_option == OPTION_ONLINE) {
		_Static_assert(OPTION_LOCAL == GAME_MODE_LOCAL, "Code bellow expects options number on the screen to mirror game mode numbers");
		_Static_assert(OPTION_ONLINE == GAME_MODE_ONLINE, "Code bellow expects options number on the screen to mirror game mode numbers");
		*config_game_mode = *menu_state_mode_selection_current_option;
	}
	if (*menu_state_mode_selection_current_option == OPTION_ARCADE) {
		*arcade_mode_current_encounter = 0;
	}
	wrap_change_global_game_state(option_to_game_state[*menu_state_mode_selection_current_option]);
}

static void show_selected_option(uint8_t shine) {
	// Attributes-table related constants
	static uint8_t const boxes_attributes_no_highlight[] = {
		/**/          ATT(0,0,0,0), ATT(0,0,0,0), ATT(0,0,0,0), ATT(0,0,0,0), ATT(0,0,0,0), ATT(0,0,0,0), ATT(0,0,0,0),
		ATT(0,0,0,0), ATT(0,0,0,0), ATT(0,0,0,0), ATT(0,0,0,0), ATT(0,0,0,0), ATT(0,0,0,0), ATT(0,0,0,0), ATT(0,0,0,0),
		ATT(0,0,0,0), ATT(0,0,0,0), ATT(0,0,0,0), ATT(0,0,0,0), ATT(0,0,0,0), ATT(0,0,0,0), ATT(0,0,0,0), ATT(0,0,0,0),
		ATT(0,0,0,0), ATT(0,0,0,0), ATT(0,0,0,0), ATT(0,0,0,0), ATT(0,0,0,0), ATT(0,0,0,0), ATT(0,0,0,0), ATT(0,0,0,0),
		ATT(0,0,0,0), ATT(0,0,0,0), ATT(0,0,0,0), ATT(0,0,0,0), ATT(0,0,0,0), ATT(0,0,0,0), ATT(0,0,0,0),
	};
	static uint8_t const boxes_attributes_no_highlight_no_network[] = {
		/**/          ATT(0,0,0,0), ATT(0,0,0,0), ATT(0,0,0,0), ATT(3,3,3,3), ATT(3,3,3,3), ATT(3,3,3,3), ATT(3,3,3,3),
		ATT(0,0,0,0), ATT(0,0,0,0), ATT(0,0,0,0), ATT(0,0,0,0), ATT(3,3,3,3), ATT(3,3,3,3), ATT(3,3,3,3), ATT(3,3,3,3),
		ATT(0,0,0,0), ATT(0,0,0,0), ATT(0,0,0,0), ATT(0,0,0,0), ATT(0,0,0,0), ATT(0,0,0,0), ATT(0,0,0,0), ATT(0,0,0,0),
		ATT(0,0,0,0), ATT(0,0,0,0), ATT(0,0,0,0), ATT(0,0,0,0), ATT(0,0,0,0), ATT(0,0,0,0), ATT(0,0,0,0), ATT(0,0,0,0),
		ATT(0,0,0,0), ATT(0,0,0,0), ATT(0,0,0,0), ATT(0,0,0,0), ATT(0,0,0,0), ATT(0,0,0,0), ATT(0,0,0,0),
	};
	static uint8_t const boxes_attributes_first_attribute_per_option[] = {0, 3, 17, 24, 27};
	static uint8_t const boxes_attributes_nb_columns_per_option[] = {3, 4, 4, 3, 3};
	static uint8_t const boxes_attributes_nb_rows_per_option[] = {2, 2, 1, 2, 2};
	static uint8_t const boxes_attributes_buff_header[] = {0x23, 0xd1, sizeof(boxes_attributes_no_highlight)};

	uint8_t const disabled_option = (no_network() && *menu_state_mode_selection_current_option == OPTION_ONLINE);
	uint8_t const active_attribute_value = (disabled_option ? ATT(3,3,3,3) : ATT(1,1,1,1));
	uint8_t const shiny_attribute_value = ATT(2,2,2,2);

	// Derivate the "nothing highligthed" attribute table to highlight the good box
	memcpy8(
		mode_selection_mem_buffer,
		no_network() ? boxes_attributes_no_highlight_no_network : boxes_attributes_no_highlight,
		sizeof(boxes_attributes_no_highlight)
	);
	uint8_t const first_attribute = boxes_attributes_first_attribute_per_option[*menu_state_mode_selection_current_option];
	uint8_t const nb_columns = boxes_attributes_nb_columns_per_option[*menu_state_mode_selection_current_option];
	uint8_t const nb_rows = boxes_attributes_nb_rows_per_option[*menu_state_mode_selection_current_option];
	for (uint8_t x = 0; x < nb_columns; ++x) {
		for (uint8_t y = 0; y < nb_rows; ++y) {
			uint8_t const attribute_index = y * 8 + x + first_attribute;
			mode_selection_mem_buffer[attribute_index] = active_attribute_value;
			if (shine && x < 2) {
				mode_selection_mem_buffer[attribute_index+1] = shiny_attribute_value;
			}
		}
		if (shine && x < 2) {
			wrap_construct_nt_buffer(boxes_attributes_buff_header, mode_selection_mem_buffer);
			yield();
		}
	}

	// Draw resulting attribute table
	wrap_construct_nt_buffer(boxes_attributes_buff_header, mode_selection_mem_buffer);
}

void init_mode_selection_screen_extra() {
	// Draw screen
	long_construct_palettes_nt_buffer(screen_bank(), &menu_mode_selection_palette);
	long_draw_zipped_nametable(screen_bank(), &nametable_mode_selection);
	long_cpu_to_ppu_copy_tileset_background(tileset_bank(), &tileset_menu_mode_selection);
	long_cpu_to_ppu_copy_charset(charset_bank(), &charset_alphanum, 0x1dc0, 1, 3);

	// Setup common menu effects
	re_init_menu();

	// Initialize state
	show_selected_option(0);
}

void mode_selection_screen_tick_extra() {
	// Play common menus effects
	tick_menu();

	// Check if a button is released and trigger correct action
	uint8_t original_option = *menu_state_mode_selection_current_option;
	for (uint8_t controller = 0; controller < 2; ++controller) {
		if (*(controller_a_btns + controller) == 0) {
			switch (*(controller_a_last_frame_btns + controller)) {
				case CONTROLLER_BTN_UP:
					go_up(); break;
				case CONTROLLER_BTN_DOWN:
					go_down(); break;
				case CONTROLLER_BTN_LEFT:
					go_left(); break;
				case CONTROLLER_BTN_RIGHT:
					go_right(); break;
				case CONTROLLER_BTN_B:
					previous_screen(); break;
				case CONTROLLER_BTN_START:
				case CONTROLLER_BTN_A:
					next_screen(); break;
			}
		}
	}

	if (*menu_state_mode_selection_current_option != original_option) {
		show_selected_option(1);
	}
}

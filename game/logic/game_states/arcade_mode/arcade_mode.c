#include <cstb.h>

///////////////////////////////////////
// Global labels from the ASM codebase
///////////////////////////////////////

extern uint8_t const charset_alphanum;

// Labels, use their address or the associtated function
extern uint8_t const CHARSET_ALPHANUM_BANK_NUMBER; // charset_bank()

///////////////////////////////////////
// Constants specific to this file
///////////////////////////////////////

typedef struct Encounter {
	uint8_t character;
	uint8_t difficulty;
	uint8_t skin;
} Encounter;

static Encounter const encounters[] = {
	{0, 1, 0},
	{1, 2, 0},
	{2, 3, 0},
	{0, 4, 1},
};
uint8_t const n_encounters = sizeof(encounters) / sizeof(Encounter);

static uint8_t const INPUT_NONE = 0;
static uint8_t const INPUT_BACK = 1;
static uint8_t const INPUT_NEXT = 2;

///////////////////////////////////////
// Utility functions
///////////////////////////////////////

static uint8_t charset_bank() {
	return ptr_lsb(&CHARSET_ALPHANUM_BANK_NUMBER);
}

/** Not a real yield, pass a frame "as if" it gone through main loop */
static void yield() {
	long_sleep_frame();
	fetch_controllers();
	reset_nt_buffers();
}

//TODO put it in cstb utils and use it in netplay_menu (if still used in the final arcade mode)
static uint8_t alpha_tile(char c) {
	// This is with alphanum charset placed at the end on patterns
	uint8_t const TILE_A = 230;
	uint8_t const TILE_0 = TILE_A - 10;

	if (c == ' ') {
		return 0;
	}
	if (c >= '0' && c <= '9') {
		return TILE_0 + (c - '0');
	}
	return TILE_A + (c - 'a');
}
static void set_text(char const* text, uint8_t line, uint8_t col) {
	uint16_t const ppu_addr = 0x2000 + line * 32 + col;
	uint16_t const size = strnlen8(text, 32);;
	arcade_mode_bg_mem_buffer[0] = u16_msb(ppu_addr);
	arcade_mode_bg_mem_buffer[1] = u16_lsb(ppu_addr);
	arcade_mode_bg_mem_buffer[2] = size;
	for (uint8_t tile = 0; tile < size; ++tile) {
		arcade_mode_bg_mem_buffer[3+tile] = alpha_tile(text[tile]);
	}
	wrap_push_nt_buffer(arcade_mode_bg_mem_buffer);
}

///////////////////////////////////////
// State implementation
///////////////////////////////////////

static Encounter current_encounter() {
	return encounters[*arcade_mode_current_encounter];
}

static void previous_screen() {
	wrap_change_global_game_state(GAME_STATE_TITLE);
}

static void next_screen() {
	*config_initial_stocks = 0;
	*config_ai_level = min(current_encounter().difficulty, 3);
	*config_selected_stage = 0;
	*config_player_a_character_palette = 0;
	*config_player_b_character_palette = current_encounter().skin;
	*config_player_a_weapon_palette = 0;
	*config_player_b_weapon_palette = current_encounter().skin;
	*config_player_a_character = 0;
	*config_player_b_character = current_encounter().character;
	*config_game_mode = GAME_MODE_ARCADE;
	wrap_change_global_game_state(GAME_STATE_INGAME);
}

void init_arcade_mode_extra() {
	// Draw screen
	//long_construct_palettes_nt_buffer(screen_bank(), &menu_mode_selection_palette);
	//long_draw_zipped_nametable(screen_bank(), &nametable_mode_selection);
	//long_cpu_to_ppu_copy_tileset_background(tileset_bank(), &tileset_menu_mode_selection);
	long_cpu_to_ppu_copy_charset(charset_bank(), &charset_alphanum, 0x1dc0, 1, 3);

	//TODO have a variant of clear_bg_bot_left that takes parameters and call that
	*PPUSTATUS;
	*PPUADDR = 0x24;
	*PPUADDR = 0x00;
	for (uint16_t i = 0 ; i < 0x0400; ++i) {
		*PPUDATA = 0;
	}

	// Initialize state
	//NOTE arcade_mode_current_encounter must be initialized before change_global_game_state,
	//     we expect to preserve their values while going to ingame state
	if (*arcade_mode_current_encounter == 0) {
		*arcade_mode_last_game_winner = 0;
		*arcade_mode_player_damages = 0;
	}
}

uint8_t input() {
	for (uint8_t controller = 0; controller < 2; ++controller) {
		if (*(controller_a_btns + controller) == 0) {
			switch (*(controller_a_last_frame_btns + controller)) {
				case CONTROLLER_BTN_B:
					return INPUT_BACK; break;
				case CONTROLLER_BTN_START:
				case CONTROLLER_BTN_A:
					return INPUT_NEXT; break;
			}
		}
	}
	return INPUT_NONE;
}

void wait_input() {
	while (true) {
		switch(input()) {
			case INPUT_BACK:
				previous_screen(); break;
			case INPUT_NEXT:
				yield(); //HACK without it next input read will read the same thing
				return;
		}
		yield();
	}
}

void arcade_mode_tick_extra() {
	reset_nt_buffers();

	//FIXME should use data from characters
	static char const* const character_names[] = {
		"sinbad",
		"kiki",
		"pepper"
	};

	static char const* const difficulty_names[] = {
		"human",
		"easy",
		"fair",
		"hard",
		"evil"
	};

	// Gameover handling
	if (*arcade_mode_last_game_winner != 0) {
		set_text("gameover", 13, 11);
		wait_input();
		previous_screen();
	}

	// Story time
	if (*arcade_mode_current_encounter == 0) {
		set_text("you find a letter", 13, 4);
		wait_input();
		set_text("dear sinbad", 10, 4);
		set_text("please join our party", 12, 4);
		set_text("it will be fun   ", 13, 4);
		yield();
		set_text("beware of fighters on", 15, 4);
		set_text("the road", 16, 4);
		set_text("we have cake", 18, 4);
		set_text("sincerly", 20, 4);
		wait_input();
		set_text("           ", 10, 4);
		set_text("                     ", 12, 4);
		set_text("                 ", 13, 4);
		yield();
		set_text("                     ", 15, 4);
		set_text("        ", 16, 4);
		set_text("            ", 18, 4);
		set_text("        ", 20, 4);
		yield();
	}

	if (*arcade_mode_current_encounter == n_encounters - 1) {
		set_text("yeah", 12, 4);
		set_text("here is the party", 13, 4);
		wait_input();
		set_text("wait", 15, 4);
		wait_input();
		set_text("what", 16, 4);
		wait_input();
		set_text("    ", 15, 4);
		set_text("    ", 16, 4);
		yield();
		set_text("booooommmmm", 12, 4);
		set_text("                 ", 13, 4);
		set_text("a big meteor crash", 14, 4);
		wait_input();
		set_text("evil sinbad comes", 12, 4);
		set_text("and laugh at you", 13, 4);
		set_text("                  ", 14, 4);
		wait_input();
		set_text("                 ", 12, 4);
		set_text("                ", 13, 4);
		yield();
	}

	if (*arcade_mode_current_encounter == n_encounters) {
		set_text("congratulation", 15, 10);
		wait_input();
		previous_screen();
	}

	// Display next encounter
	set_text("next encounter", 13, 10);
	set_text(character_names[current_encounter().character], 14, 12);
	set_text(difficulty_names[current_encounter().difficulty], 15, 12);

	// Check if a button is released and trigger correct action
	while (true) {
		switch(input()) {
			case INPUT_BACK:
				previous_screen(); break;
			case INPUT_NEXT:
				next_screen(); break;
		}
		yield();
	}
}

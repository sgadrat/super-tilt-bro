#pragma once
#include <cstb.h>
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wunused-function"

///////////////////////////////////////
// Type definitions
///////////////////////////////////////

typedef struct Cutscene {
	uint8_t const* palette;
	uint8_t const* nametable;
	uint8_t const* nametable_bot;
	uint8_t const* bg_tileset;
	uint8_t const* sprites_tileset;
	void(*logic)();
	void(*init)();
} __attribute__((__packed__)) Cutscene;

typedef struct Encounter {
	uint8_t type;
	union {
		struct {
			uint8_t character;
			uint8_t difficulty;
			uint8_t skin;
			uint8_t stage;
			uint16_t silver_time;
			uint16_t gold_time;
		} fight;
		struct {
			uint8_t stage;
			uint16_t silver_time;
			uint16_t gold_time;
		} run;
		struct {
			uint8_t stage;
			uint16_t silver_time;
			uint16_t gold_time;
		} targets; //NOTE some code expect "target" to have the exact same layout as "run" (code should be fixed if needed)
		struct {
			uint8_t const* scene;
			uint8_t bank;
		} cutscene;
	};
} __attribute__((__packed__)) Encounter;

///////////////////////////////////////
// Global labels from the ASM codebase
///////////////////////////////////////

extern uint8_t const arcade_encounters; // encounters()
extern uint8_t const arcade_n_encounters; // n_encounters()
extern uint8_t const ARCADE_MODE_EXTRA_BANK_NUMBER; // arcade_bank()
extern uint8_t const CHARSET_ALPHANUM_BANK_NUMBER; // charset_alphanum_bank()
extern uint8_t const CHARSET_SYMBOLS_BANK_NUMBER; // charset_symbols_bank()
extern uint8_t const ENCOUNTER_ENTRY_SIZE; // encounter_entry_size()
extern uint8_t const ENCOUNTER_FIGHT; // encounter_type_fight()
extern uint8_t const ENCOUNTER_RUN; // encounter_type_run()
extern uint8_t const ENCOUNTER_TARGETS; // encounter_type_targets()
extern uint8_t const ENCOUNTER_CUTSCENE; // encounter_type_cutscene()
extern uint8_t const ENCOUNTER_GAMEOVER; // encounter_type_gameover()

///////////////////////////////////////
// Constants specific to this file
///////////////////////////////////////

static uint8_t const INPUT_NONE = 0;
static uint8_t const INPUT_BACK = 1;
static uint8_t const INPUT_NEXT = 2;
static uint8_t const INPUT_SKIP = 3;

static uint8_t const COPPER_MEDAL = 0;
static uint8_t const SILVER_MEDAL = 1;
static uint8_t const GOLD_MEDAL = 2;
static uint8_t const MYTHRIL_MEDAL = 3;
static uint8_t const TAS_MEDAL = 4;
static uint8_t const CHOCOLATE_MEDAL = 5;

static uint8_t const BITS_PER_MEDAL = 2; //NOTE: only up to gold are stored as stage result

///////////////////////////////////////
// Utility functions
///////////////////////////////////////

static uint8_t arcade_bank() {
	return ptr_lsb(&ARCADE_MODE_EXTRA_BANK_NUMBER);
}

static uint8_t charset_alphanum_bank() {
	return ptr_lsb(&CHARSET_ALPHANUM_BANK_NUMBER);
}

static uint8_t charset_symbols_bank() {
	return ptr_lsb(&CHARSET_SYMBOLS_BANK_NUMBER);
}

static Encounter const* encounters() {
	return (Encounter const*)(&arcade_encounters);
}
static uint8_t encounter_entry_size() {
	return ptr_lsb(&ENCOUNTER_ENTRY_SIZE);
}

static uint8_t encounter_type_fight() {
	return ptr_lsb(&ENCOUNTER_FIGHT);
}

static uint8_t encounter_type_run() {
	return ptr_lsb(&ENCOUNTER_RUN);
}

static uint8_t encounter_type_targets() {
	return ptr_lsb(&ENCOUNTER_TARGETS);
}

static uint8_t encounter_type_cutscene() {
  return ptr_lsb(&ENCOUNTER_CUTSCENE);
}

static uint8_t encounter_type_gameover() {
  return ptr_lsb(&ENCOUNTER_GAMEOVER);
}

static uint8_t n_encounters() {
	return ptr_lsb(&arcade_n_encounters);
}

static void load_encounter(Encounter const* encounter, uint8_t bank) {
	long_memcpy(arcade_mode_encounter, bank, (uint8_t const*)encounter, encounter_entry_size());
}

static Encounter* loaded_encounter() {
	return (Encounter*)arcade_mode_encounter;
}

/** Not a real yield, pass a frame "as if" it gone through main loop */
static void yield() {
	long_sleep_frame();
	fetch_controllers();
}

static uint32_t timestamp(uint8_t minutes, uint8_t seconds, uint8_t frames) {
	uint8_t const frame_base = (*system_index ? 60 : 50);
	return
		(uint32_t)(minutes) * 60 * frame_base +
		seconds * frame_base +
		frames
	;
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

static void clear_screen() {
	// Clear unprocessed buffers
	clear_nt_buffers();

	// Reset scrolling
	*scroll_x = 0;
	*scroll_y = 0;

	// Clear particles
	particle_handlers_reinit();

	// Hide all sprites
	for (uint8_t i = 0; i != 255; ++i) {
		oam_mirror[i] = 0xfe;
	}
}

static uint8_t input() {
	for (uint8_t controller = 0; controller < 2; ++controller) {
		if (*(controller_a_btns + controller) == 0) {
			switch (*(controller_a_last_frame_btns + controller)) {
				case CONTROLLER_BTN_B:
					return INPUT_BACK;
				case CONTROLLER_BTN_START:
					return INPUT_SKIP;
				case CONTROLLER_BTN_A:
					return INPUT_NEXT;
			}
		}
	}
	return INPUT_NONE;
}

static uint8_t wait_input() {
	while (true) {
		uint8_t const value = input();
		if (value != INPUT_NONE) {
			yield(); //HACK without it next input read will read the same thing
			return value;
		}
		yield();
	}
}

static _Bool skip_input() {
	uint8_t const value = input();
	return value != INPUT_NONE;
}

static _Bool pause(uint8_t time) {
	while(time) {
		if (skip_input()) {
			yield(); //HACK without it next input read will read the same thing
			return true;
		}
		--time;
		yield();
	}
	return false;
}

static uint8_t get_medal(uint8_t index) {
	uint32_t const medals = u32(arcade_mode_medals[2], arcade_mode_medals[1], arcade_mode_medals[0], 0);
	return (medals >> (BITS_PER_MEDAL * index)) & 0x00000003;
}
#pragma GCC diagnostic pop

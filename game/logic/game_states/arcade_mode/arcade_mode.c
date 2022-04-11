#include <cstb.h>

///////////////////////////////////////
// Global labels from the ASM codebase
///////////////////////////////////////

extern uint8_t const arcade_mode_palette;
extern uint8_t const charset_alphanum;
extern uint8_t const cutscene_sinbad_story_bird_msg;
extern uint8_t const cutscene_sinbad_story_kiki_encounter;
extern uint8_t const cutscene_sinbad_story_pepper_encounter;
extern uint8_t const cutscene_sinbad_story_sinbad_encounter;

// Labels, use their address or the associated function
extern uint8_t const ARCADE_MODE_SCREEN_BANK; // screen_bank()
extern uint8_t const CHARSET_ALPHANUM_BANK_NUMBER; // charset_bank()
extern uint8_t const cutscene_sinbad_story_bird_msg_bank;
extern uint8_t const cutscene_sinbad_story_kiki_encounter_bank;
extern uint8_t const cutscene_sinbad_story_pepper_encounter_bank;
extern uint8_t const cutscene_sinbad_story_sinbad_encounter_bank;
extern uint8_t const stage_arcade_first_index;

///////////////////////////////////////
// Constants specific to this file
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
		} fight;
		struct {
			uint8_t stage;
		} run;
		struct {
			uint8_t stage;
		} targets;
		struct {
			uint8_t const* scene;
			uint16_t bank;
		} cutscene;
	};
} __attribute__((__packed__)) Encounter;

#define ENCOUNTER_FIGHT 0
#define ENCOUNTER_RUN 1
#define ENCOUNTER_TARGETS 2
#define ENCOUNTER_CUTSCENE 3

static Encounter const encounters[] = {
	{.type = ENCOUNTER_CUTSCENE, {.cutscene={&cutscene_sinbad_story_bird_msg, (uint16_t)&cutscene_sinbad_story_bird_msg_bank}}},
	{.type = ENCOUNTER_TARGETS, {.targets={1}}},
	{.type = ENCOUNTER_CUTSCENE, {.cutscene={&cutscene_sinbad_story_sinbad_encounter, (uint16_t)&cutscene_sinbad_story_sinbad_encounter_bank}}},
	{.type = ENCOUNTER_FIGHT, {.fight={0, 1, 0}}},
	{.type = ENCOUNTER_RUN, {.run={0}}},
	{.type = ENCOUNTER_CUTSCENE, {.cutscene={&cutscene_sinbad_story_kiki_encounter, (uint16_t)&cutscene_sinbad_story_kiki_encounter_bank}}},
	{.type = ENCOUNTER_FIGHT, {.fight={1, 2, 0}}},
	{.type = ENCOUNTER_RUN, {.run={0}}},
	{.type = ENCOUNTER_CUTSCENE, {.cutscene={&cutscene_sinbad_story_pepper_encounter, (uint16_t)&cutscene_sinbad_story_pepper_encounter_bank}}},
	{.type = ENCOUNTER_FIGHT, {.fight={2, 3, 0}}},
	{.type = ENCOUNTER_FIGHT, {.fight={0, 4, 1}}},
};
uint8_t const n_encounters = sizeof(encounters) / sizeof(Encounter);

static uint8_t const INPUT_NONE = 0;
static uint8_t const INPUT_BACK = 1;
static uint8_t const INPUT_NEXT = 2;

///////////////////////////////////////
// Utility functions
///////////////////////////////////////

static uint8_t screen_bank() {
	return ptr_lsb(&ARCADE_MODE_SCREEN_BANK);
}

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

static void set_num(uint8_t num, uint8_t line, uint8_t col) {
	arcade_mode_bg_mem_buffer[6+0] = '0'+(num/100);
	num %= 100;
	arcade_mode_bg_mem_buffer[6+1] = '0'+(num/10);
	num %= 10;
	arcade_mode_bg_mem_buffer[6+2] = '0'+(num);
	arcade_mode_bg_mem_buffer[6+3] = 0;
	set_text((char*)arcade_mode_bg_mem_buffer+6, line, col);
}

///////////////////////////////////////
// State implementation
///////////////////////////////////////

static Encounter current_encounter() {
	return encounters[*arcade_mode_current_encounter];
}

static void start_cutscene() {
	// Retrieve cutscene info from distant bank
	Encounter const encounter = current_encounter();
	long_memcpy(arcade_mode_bg_mem_buffer, encounter.cutscene.bank, encounter.cutscene.scene, sizeof(Cutscene));
	Cutscene const* cutscene = (Cutscene*)arcade_mode_bg_mem_buffer;

	// Stop rendering
	*nmi_processing = NMI_AUDIO;
	*PPUCTRL = 0x90;
	*PPUMASK = 0;
	*ppuctrl_val = 0; //NOTE copying change_global_game_state, may have to be 0x90

	reset_nt_buffers();
	*scroll_x = 0;
	*scroll_y = 0;

	particle_handlers_reinit();

	for (uint8_t i = 0; i != 255; ++i) {
		oam_mirror[i] = 0xfe;
	}

	// Draw screen
	long_construct_palettes_nt_buffer(encounter.cutscene.bank, cutscene->palette);
	long_draw_zipped_nametable(encounter.cutscene.bank, cutscene->nametable);
	long_draw_zipped_vram(encounter.cutscene.bank, cutscene->nametable_bot, 0x2800);
	long_cpu_to_ppu_copy_tileset_background(encounter.cutscene.bank, cutscene->bg_tileset);
	long_place_character_ppu_tiles_direct(0, 0);
	long_cpu_to_ppu_copy_tileset(encounter.cutscene.bank, cutscene->sprites_tileset, 0);

	// Call cutscene initialization routine
	wrap_trampoline(encounter.cutscene.bank, code_bank(), cutscene->init);

	// Reactivate rendering
	*ppuctrl_val = 0x90;
	*PPUCTRL = 0x90;
	wait_next_frame();
	*PPUMASK = 0x1e;

	// Prepare cutscene state
	cutscene_anims_enabled[0] = 0;
	cutscene_anims_enabled[1] = 0;
	cutscene_anims_enabled[2] = 0;
	cutscene_anims_enabled[3] = 0;
	*cutscene_autoscroll_h = 0;
	*cutscene_autoscroll_v = 0;

	// Call cutscene's logic
	wrap_trampoline(encounter.cutscene.bank, code_bank(), cutscene->logic);

	// Change gamestate to ourself, cutscenes are exploited alongside other gamestates
	++*arcade_mode_current_encounter;
	wrap_change_global_game_state(GAME_STATE_ARCADE_MODE);
}

static void previous_screen() {
	wrap_change_global_game_state(GAME_STATE_TITLE);
}

static void next_screen() {
	*config_initial_stocks = 0;
	*config_player_a_character_palette = 0;
	*config_player_a_weapon_palette = 0;
	*config_player_a_character = 0;
	*arcade_mode_stage_type = current_encounter().type;
	*config_game_mode = GAME_MODE_ARCADE;

	if (*arcade_mode_stage_type == ENCOUNTER_FIGHT) {
		*config_ai_level = min(current_encounter().fight.difficulty, 3);
		*config_selected_stage = 0;
		*config_player_b_character_palette = current_encounter().fight.skin;
		*config_player_b_weapon_palette = current_encounter().fight.skin;
		*config_player_b_character = current_encounter().fight.character;
		*config_player_a_present = true;
		*config_player_b_present = true;
	}else if (*arcade_mode_stage_type == ENCOUNTER_RUN || *arcade_mode_stage_type == ENCOUNTER_TARGETS) {
		*config_ai_level = 0;
		*config_selected_stage = ptr_lsb(&stage_arcade_first_index) + current_encounter().run.stage;
		*config_player_b_character_palette = 0;
		*config_player_b_weapon_palette = 0;
		*config_player_b_character = 0;
		*config_player_a_present = true;
		*config_player_b_present = false;
	}else {
		start_cutscene();
	}

	wrap_change_global_game_state(GAME_STATE_INGAME);
}

static uint8_t input() {
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

static void wait_input() {
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

static void display_timer() {
	set_num(*arcade_mode_counter_minutes, 5, 4);
	set_text("min", 5, 8);
	set_num(*arcade_mode_counter_seconds, 5, 12);
	set_text("seconds", 5, 16);
	yield();
}

void init_arcade_mode_extra() {
	// Draw screen
	long_construct_palettes_nt_buffer(screen_bank(), &arcade_mode_palette);
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
		*arcade_mode_counter_frames = 0;
		*arcade_mode_counter_seconds = 0;
		*arcade_mode_counter_minutes = 0;
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
		display_timer();
		set_text("gameover", 13, 11);
		wait_input();
		previous_screen();
	}

	// Story time
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
		display_timer();
		set_text("congratulation", 15, 10);
		wait_input();
		previous_screen();
	}

	// Display timer
	display_timer();

	// Launch next encounter
	if (current_encounter().type == ENCOUNTER_CUTSCENE) {
		next_screen();
	}else {
		// Display next encounter
		if (current_encounter().type == ENCOUNTER_FIGHT) {
			set_text("next encounter", 13, 10);
			set_text(character_names[current_encounter().fight.character], 14, 12);
			set_text(difficulty_names[current_encounter().fight.difficulty], 15, 12);
		}else if (current_encounter().type == ENCOUNTER_RUN) {
			set_text("reach the exit", 13, 10);
		}else {
			set_text("break the targets", 12, 10);
		}

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
}

#include <cstb.h>

///////////////////////////////////////
// Global labels from the ASM codebase
///////////////////////////////////////

void arcade_mode_display_counter();

extern uint8_t const arcade_mode_palette;
extern uint8_t const charset_alphanum;
extern uint8_t const cutscene_sinbad_story_bird_msg;
extern uint8_t const cutscene_sinbad_story_kiki_encounter;
extern uint8_t const cutscene_sinbad_story_meteor;
extern uint8_t const cutscene_sinbad_story_pepper_encounter;
extern uint8_t const cutscene_sinbad_story_sinbad_encounter;
extern uint8_t const arcade_encounters; // encounters()

// Labels, use their address or the associated function
extern uint8_t const ARCADE_MODE_EXTRA_BANK_NUMBER; // arcade_bank()
extern uint8_t const ARCADE_MODE_SCREEN_BANK; // screen_bank()
extern uint8_t const arcade_n_encounters; // n_encounters()
extern uint8_t const CHARSET_ALPHANUM_BANK_NUMBER; // charset_bank()
extern uint8_t const cutscene_sinbad_story_bird_msg_bank;
extern uint8_t const cutscene_sinbad_story_kiki_encounter_bank;
extern uint8_t const cutscene_sinbad_story_meteor_bank;
extern uint8_t const cutscene_sinbad_story_pepper_encounter_bank;
extern uint8_t const cutscene_sinbad_story_sinbad_encounter_bank;
extern uint8_t const ENCOUNTER_FIGHT; // encounter_type_fight()
extern uint8_t const ENCOUNTER_RUN; // encounter_type_run()
extern uint8_t const ENCOUNTER_TARGETS; // encounter_type_targets()
//extern uint8_t const ENCOUNTER_CUTSCENE; // encounter_type_cutscene()
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

static uint8_t const INPUT_NONE = 0;
static uint8_t const INPUT_BACK = 1;
static uint8_t const INPUT_NEXT = 2;

static uint8_t const BRONZE_MEDAL = 0;
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

static uint8_t charset_bank() {
	return ptr_lsb(&CHARSET_ALPHANUM_BANK_NUMBER);
}

static Encounter const* encounters() {
	return (Encounter const*)(&arcade_encounters);
}

static uint8_t n_encounters() {
	return ptr_lsb(&arcade_n_encounters);
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

//static uint8_t encounter_type_cutscene() {
//	return ptr_lsb(&ENCOUNTER_CUTSCENE);
//}

static uint8_t screen_bank() {
	return ptr_lsb(&ARCADE_MODE_SCREEN_BANK);
}

/** Not a real yield, pass a frame "as if" it gone through main loop */
static void yield() {
	long_sleep_frame();
	fetch_controllers();
}

uint32_t timestamp(uint8_t minutes, uint8_t seconds, uint8_t frames) {
	uint8_t const frame_base = (*system_index ? 60 : 50);
	return
		minutes * 60 * frame_base +
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

///////////////////////////////////////
// State implementation
///////////////////////////////////////

static Encounter current_encounter() {
	return encounters()[*arcade_mode_current_encounter];
}

static Encounter previous_encounter() {
	return encounters()[(*arcade_mode_current_encounter) - 1];
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

	clear_nt_buffers();
	*scroll_x = 0;
	*scroll_y = 0;

	particle_handlers_reinit();

	for (uint8_t i = 0; i != 255; ++i) {
		oam_mirror[i] = 0xfe;
	}

	// Draw screen
	long_construct_palettes_nt_buffer(encounter.cutscene.bank, cutscene->palette);
	long_draw_zipped_nametable(encounter.cutscene.bank, cutscene->nametable);
	if (cutscene->nametable_bot != (void*)0xffff) {
		long_draw_zipped_vram(encounter.cutscene.bank, cutscene->nametable_bot, 0x2800);
	}
	if (cutscene->bg_tileset != (void*)0xffff) {
		long_cpu_to_ppu_copy_tileset_background(encounter.cutscene.bank, cutscene->bg_tileset);
	}
	long_place_character_ppu_tiles_direct(0, 0);
	if (cutscene->sprites_tileset != (void*)0xffff) {
		long_cpu_to_ppu_copy_tileset(encounter.cutscene.bank, cutscene->sprites_tileset, 0);
	}

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
	*cutscene_sprite0_hit = 0;
	*screen_shake_counter = 0;

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

	if (*arcade_mode_stage_type == encounter_type_fight()) {
		*config_ai_level = min(current_encounter().fight.difficulty, 3);
		*config_selected_stage = current_encounter().fight.stage;
		*config_player_b_character_palette = current_encounter().fight.skin;
		*config_player_b_weapon_palette = current_encounter().fight.skin;
		*config_player_b_character = current_encounter().fight.character;
		*config_player_a_present = true;
		*config_player_b_present = true;
		*arcade_mode_saved_counter_frames = *arcade_mode_counter_frames;
		*arcade_mode_saved_counter_seconds = *arcade_mode_counter_seconds;
		*arcade_mode_saved_counter_minutes = *arcade_mode_counter_minutes;
	}else if (*arcade_mode_stage_type == encounter_type_run() || *arcade_mode_stage_type == encounter_type_targets()) {
		*config_ai_level = 0;
		*config_selected_stage = ptr_lsb(&stage_arcade_first_index) + current_encounter().run.stage;
		*config_player_b_character_palette = 0;
		*config_player_b_weapon_palette = 0;
		*config_player_b_character = 0;
		*config_player_a_present = true;
		*config_player_b_present = false;
		*arcade_mode_saved_counter_frames = *arcade_mode_counter_frames;
		*arcade_mode_saved_counter_seconds = *arcade_mode_counter_seconds;
		*arcade_mode_saved_counter_minutes = *arcade_mode_counter_minutes;
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

static void display_timer() {
	// Display time
	wrap_trampoline(arcade_bank(), code_bank(), &arcade_mode_display_counter);

	// Display credits
	if (*arcade_mode_nb_credits_used != 0) {
		uint8_t const credits_used = min(*arcade_mode_nb_credits_used, 10);

		uint8_t const position_y = 4;
		uint8_t const position_x = 3;
		uint16_t const ppu_addr = 0x2000 + position_y * 32 + position_x;

		uint8_t const i = get_last_nt_buffer();
		nametable_buffers[i] = 1;
		nametable_buffers[(i+1) % 256] = u16_msb(ppu_addr);
		nametable_buffers[(i+2) % 256] = u16_lsb(ppu_addr);
		nametable_buffers[(i+3) % 256] = credits_used;

		for (uint8_t credit_num = 0; credit_num < credits_used; ++credit_num) {
			nametable_buffers[(i+4+credit_num) % 256] = 0xd0; //TODO name the stock tile (and actually use a specific tile for credits)
		}

		uint8_t const end_offset = (i+4+credits_used) % 256;
		nametable_buffers[end_offset] = 0;
		set_last_nt_buffer(end_offset);
	}

	// Pass a frame to process nt buffers
	yield();
}

static void reinit_player_state() {
	*arcade_mode_last_game_winner = 0;
	*arcade_mode_player_damages = 0;
}

static void gameover_screen() {
	display_timer();
	set_text("gameover", 13, 11);
	set_text("continue", 15, 11);
	set_text("yes  start", 16, 13);
	set_text("no   b", 17, 13);
	if (wait_input() == INPUT_BACK) {
		previous_screen();
	}
	++*arcade_mode_nb_credits_used;
	reinit_player_state();
}

static uint8_t get_medal(uint8_t index) {
	uint32_t const medals = u32(arcade_mode_medals[2], arcade_mode_medals[1], arcade_mode_medals[0], 0);
	return (medals >> (BITS_PER_MEDAL * index)) & 0x00000003;
}

static void congratulations_screen() {
	// Show timer
	display_timer();

	// Congratulate player
	set_text("congratulations", 13, 9);
	wait_input();

	// Display medals
	uint8_t n_medals = 0;
	Encounter const* const first_encounter = (Encounter const* const)(&arcade_encounters);
	for (Encounter const* encounter = first_encounter; (uint8_t)(encounter - first_encounter) < n_encounters(); ++encounter) {
		if (
			encounter->type == encounter_type_run() ||
			encounter->type == encounter_type_targets() ||
			encounter->type == encounter_type_fight()
		)
		{
			++n_medals;
		}
	}

	char const* const medal_names[] = {
		"bronze",
		"silver",
		"gold",
		"mythril",
		"toolassistium",
		"chocolate",
	};
	uint8_t line = 15;
	uint8_t current_medal_index = n_medals;
	while (current_medal_index > 0) {
		--current_medal_index;
		set_text(medal_names[get_medal(current_medal_index)], line, 9);
		++line;
	}

	// Compute final medal
	uint8_t final_medal = BRONZE_MEDAL;

	uint32_t const global_timer = timestamp(*arcade_mode_counter_minutes, *arcade_mode_counter_seconds, *arcade_mode_counter_frames);
	if (global_timer < timestamp(1,0,0)) { // World record TAS (hypotetical for now)
		final_medal = CHOCOLATE_MEDAL;
	}else if (global_timer < timestamp(1,1,14)) { // World record Human (hypotetical for now, just me doing my normal strat as speedrun)
		final_medal = TAS_MEDAL;
	}else {
		// Compute score (sum of medals)
		uint8_t score = 0;
		current_medal_index = n_medals;
		while (current_medal_index > 0) {
			--current_medal_index;
			score += get_medal(current_medal_index);
		}

		// Perfect score means mythril, else take the average of medals
		if (score == GOLD_MEDAL * n_medals && *arcade_mode_nb_credits_used == 0) {
			final_medal = MYTHRIL_MEDAL;
		}else {
			final_medal = (score + n_medals/2) / n_medals;
		}
	}

	// Display final medal
	set_text(medal_names[final_medal], line+1, 4);

	// Wait and quit arcade mode
	wait_input();
	previous_screen();
}

void init_arcade_mode_extra() {
	// Draw screen
	long_construct_palettes_nt_buffer(screen_bank(), &arcade_mode_palette);
	//long_draw_zipped_nametable(screen_bank(), &nametable_mode_selection);
	//long_cpu_to_ppu_copy_tileset_background(tileset_bank(), &tileset_menu_mode_selection);
	long_cpu_to_ppu_copy_charset(charset_bank(), &charset_alphanum, 0x1dc0, 0, 1);

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
		reinit_player_state();
		*arcade_mode_counter_frames = 0;
		*arcade_mode_counter_seconds = 0;
		*arcade_mode_counter_minutes = 0;
		*arcade_mode_nb_credits_used = 0;
		arcade_mode_medals[0] = 0;
		arcade_mode_medals[1] = 0;
		arcade_mode_medals[2] = 0;
	}
}

void arcade_mode_tick_extra() {
	// Update medals
	if (*arcade_mode_current_encounter > 0) {
		//NOTE To lose a stock doesn't impact calculation, it resets stage's counter.
		//     The player can lose the stock on purpose to aim for gold.

		// Get medal times
		uint32_t silver_time;
		uint32_t gold_time;
		if (previous_encounter().type == encounter_type_run() || previous_encounter().type == encounter_type_targets()) {
			silver_time = timestamp(
				0,
				u16_msb(previous_encounter().run.silver_time),
				u16_lsb(previous_encounter().run.silver_time)
			);
			gold_time = timestamp(
				0,
				u16_msb(previous_encounter().run.gold_time),
				u16_lsb(previous_encounter().run.gold_time)
			);
		}else /*if (previous_encounter().type == encounter_type_fight())*/ {
			silver_time = timestamp(
				0,
				u16_msb(previous_encounter().fight.silver_time),
				u16_lsb(previous_encounter().fight.silver_time)
			);
			gold_time = timestamp(
				0,
				u16_msb(previous_encounter().fight.gold_time),
				u16_lsb(previous_encounter().fight.gold_time)
			);
		}

		// Check medal acquired
		uint32_t const encounter_time =
			timestamp(*arcade_mode_counter_minutes, *arcade_mode_counter_seconds, *arcade_mode_counter_frames) -
			timestamp(*arcade_mode_saved_counter_minutes, *arcade_mode_saved_counter_seconds, *arcade_mode_saved_counter_frames)
		;
		uint8_t medal = BRONZE_MEDAL;
		if (encounter_time < gold_time) {
			medal = GOLD_MEDAL;
		}else if (encounter_time < silver_time) {
			medal = SILVER_MEDAL;
		}

		// Save medal
		uint32_t medals = u32(arcade_mode_medals[2], arcade_mode_medals[1], arcade_mode_medals[0], 0);
		medals <<= BITS_PER_MEDAL;
		medals |= medal;
		arcade_mode_medals[2] = u32_byte0(medals);
		arcade_mode_medals[1] = u32_byte1(medals);
		arcade_mode_medals[0] = u32_byte2(medals);
	}

	// Game ended handling
	if (*arcade_mode_last_game_winner != 0) {
		gameover_screen();
	}

	if (*arcade_mode_current_encounter == n_encounters()) {
		congratulations_screen();
	}

	// Launch next encounter
	next_screen();
}

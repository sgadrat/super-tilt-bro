#include "logic/game_states/arcade_mode/arcade_mode.h"
#include <cstb.h>

///////////////////////////////////////
// Global labels from the ASM codebase
///////////////////////////////////////

void arcade_mode_display_counter();
void arcade_congratz();

extern uint8_t const arcade_mode_palette;
extern uint8_t const charset_alphanum;
extern uint8_t const cutscene_sinbad_story_bird_msg;
extern uint8_t const cutscene_sinbad_story_kiki_encounter;
extern uint8_t const cutscene_sinbad_story_meteor;
extern uint8_t const cutscene_sinbad_story_pepper_encounter;
extern uint8_t const cutscene_sinbad_story_sinbad_encounter;

// Labels, use their address or the associated function
extern uint8_t const ARCADE_MODE_CONGRATZ_BANK_NUMBER; // congratz_bank()
extern uint8_t const ARCADE_MODE_SCREEN_BANK; // screen_bank()
extern uint8_t const SFX_COUNTDOWN_REACH_IDX;
extern uint8_t const cutscene_sinbad_story_bird_msg_bank;
extern uint8_t const cutscene_sinbad_story_kiki_encounter_bank;
extern uint8_t const cutscene_sinbad_story_meteor_bank;
extern uint8_t const cutscene_sinbad_story_pepper_encounter_bank;
extern uint8_t const cutscene_sinbad_story_sinbad_encounter_bank;
extern uint8_t const stage_arcade_first_index;
extern uint8_t const stage_arcade_gameover_index;

///////////////////////////////////////
// Constants specific to this file
///////////////////////////////////////

///////////////////////////////////////
// Utility functions
///////////////////////////////////////

static uint8_t congratz_bank() {
	return ptr_lsb(&ARCADE_MODE_CONGRATZ_BANK_NUMBER);
}

static uint8_t screen_bank() {
	return ptr_lsb(&ARCADE_MODE_SCREEN_BANK);
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
	stop_rendering();
	clear_screen();

	// Draw screen
	long_construct_palettes_nt_buffer(encounter.cutscene.bank, cutscene->palette);
	if (cutscene->nametable != (void*)0xffff) {
		long_draw_zipped_nametable(encounter.cutscene.bank, cutscene->nametable);
	}
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
	wrap_start_rendering(0);

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

	// Change gamestate to ourself, we just played the cutscene and now want to check next encounter like any other
	*arcade_mode_lvl_cap = MAX_AI_LEVEL;
	++*arcade_mode_current_encounter;
	wrap_change_global_game_state(GAME_STATE_ARCADE_MODE);
}

static void next_screen() {
	*config_initial_stocks = 0;
	*config_player_a_character_palette = 0;
	*config_player_a_weapon_palette = 0;
	*config_player_a_character = 0;
	*arcade_mode_stage_type = current_encounter().type;
	*config_game_mode = GAME_MODE_ARCADE;

	if (*arcade_mode_stage_type == encounter_type_fight()) {
		*config_ai_level = min(current_encounter().fight.difficulty, *arcade_mode_lvl_cap);
		*config_selected_stage = current_encounter().fight.stage;
		*config_player_b_character_palette = current_encounter().fight.skin;
		*config_player_b_weapon_palette = current_encounter().fight.skin;
		*config_player_b_character = current_encounter().fight.character;
		*config_player_a_present = true;
		*config_player_b_present = true;
		*arcade_mode_saved_counter_frames = *arcade_mode_counter_frames;
		*arcade_mode_saved_counter_seconds = *arcade_mode_counter_seconds;
		*arcade_mode_saved_counter_minutes = *arcade_mode_counter_minutes;
		wrap_audio_play_sfx_from_list(ptr_lsb(&SFX_COUNTDOWN_REACH_IDX));
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

static void reinit_player_state() {
	*arcade_mode_last_game_winner = 0;
	*arcade_mode_player_damages = 0;
}

static void gameover_screen() {
	// Update arcade mode's state
	if (*arcade_mode_nb_credits_used != 0xff) {
		++*arcade_mode_nb_credits_used;
	}
	reinit_player_state();
	if (*arcade_mode_lvl_cap > 1) {
		--*arcade_mode_lvl_cap;
	}

	// Start the gameover "encounter"
	*config_initial_stocks = 0;
	*config_player_a_character_palette = 0;
	*config_player_a_weapon_palette = 0;
	*config_player_a_character = 0;
	*arcade_mode_stage_type = encounter_type_gameover();
	*config_game_mode = GAME_MODE_ARCADE;

	*config_ai_level = 0;
	*config_selected_stage = ptr_lsb(&stage_arcade_gameover_index);
	*config_player_b_character_palette = 0;
	*config_player_b_weapon_palette = 0;
	*config_player_b_character = 0;
	*config_player_a_present = true;
	*config_player_b_present = false;

	wrap_change_global_game_state(GAME_STATE_INGAME);
}

void init_arcade_mode_extra() {
	// Draw screen
	long_construct_palettes_nt_buffer(screen_bank(), &arcade_mode_palette);
	//long_draw_zipped_nametable(screen_bank(), &nametable_mode_selection);
	//long_cpu_to_ppu_copy_tileset_background(tileset_bank(), &tileset_menu_mode_selection);
	long_cpu_to_ppu_copy_charset(charset_alphanum_bank(), &charset_alphanum, 0x1dc0, 0, 1);

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
		*arcade_mode_lvl_cap = MAX_AI_LEVEL;
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
	if (*arcade_mode_current_encounter > 0 && previous_encounter().type != encounter_type_cutscene() && *arcade_mode_last_game_winner == 0) {
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
		uint8_t medal = COPPER_MEDAL;
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
	if (*arcade_mode_last_game_winner != 0 && *arcade_mode_last_game_winner != 0xff) {
		gameover_screen();
	}

	if (*arcade_mode_current_encounter == n_encounters()) {
		wrap_trampoline(congratz_bank(), code_bank(), arcade_congratz);
	}

	// Launch next encounter
	next_screen();
}

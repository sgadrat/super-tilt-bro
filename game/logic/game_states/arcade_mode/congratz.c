#include "logic/game_states/arcade_mode/arcade_mode.h"
#include <cstb.h>

///////////////////////////////////////
// Global labels from the ASM codebase
///////////////////////////////////////

extern uint8_t const char_colon;
extern uint8_t const charset_alphanum;
extern uint8_t const arcade_congratz_bg_tileset;
extern uint8_t const arcade_congratz_chocolate_medal_buffer;
extern uint8_t const arcade_congratz_copper_medal_buffer;
extern uint8_t const arcade_congratz_gold_medal_buffer;
extern uint8_t const arcade_congratz_medal_buffer_header;
extern uint8_t const arcade_congratz_mythril_medal_buffer;
extern uint8_t const arcade_congratz_nametable;
extern uint8_t const arcade_congratz_palette;
extern uint8_t const arcade_congratz_silver_medal_buffer;
extern uint8_t const arcade_congratz_sky_palette_buffer;
extern uint8_t const arcade_congratz_tas_medal_buffer;
extern uint8_t const arcade_congratz_tiny_medal_tileset;
extern uint8_t const music_sinbad2_info;
extern uint8_t const sinbad_chr_illustrations;

void modifier_remap();

// Labels, use their address or the associated function
extern uint8_t const ARCADE_CONGRATZ_BG_TILESET_BANK_NUMBER; // bg_tileset_bank()
extern uint8_t const ARCADE_CONGRATZ_SCREEN_BANK_NUMBER; // screen_bank()
extern uint8_t const ARCADE_CONGRATZ_TINY_MEDAL_TILESET_BANK_NUMBER; // tiny_medal_bank()
extern uint8_t const SFX_DEATH_IDX;
extern uint8_t const SFX_SHIELD_HIT_IDX;
extern uint8_t const SINBAD_BANK_NUMBER; // sinbad_bank()
extern uint8_t const music_sinbad2_bank;

///////////////////////////////////////
// Constants specific to this file
///////////////////////////////////////

static uint8_t const tiny_medals_x[] = {120, 167, 186, 167, 120, 73, 54, 73};
static uint8_t const tiny_medals_y[] = {97, 110, 143, 176, 189, 176, 143, 110};
static uint8_t const medal_center_x = 120;
static uint8_t const medal_center_y = 143;
static uint8_t const SPRITE_MEDALS = 0;

///////////////////////////////////////
// Utility functions
///////////////////////////////////////

static uint8_t bg_tileset_bank() {
	return ptr_lsb(&ARCADE_CONGRATZ_BG_TILESET_BANK_NUMBER);
}

static uint8_t screen_bank() {
	return ptr_lsb(&ARCADE_CONGRATZ_SCREEN_BANK_NUMBER);
}

static uint8_t sinbad_bank() {
	return ptr_lsb(&SINBAD_BANK_NUMBER);
}

static uint8_t tiny_medal_bank() {
	return ptr_lsb(&ARCADE_CONGRATZ_TINY_MEDAL_TILESET_BANK_NUMBER);
}

///////////////////////////////////////
// State implementation
///////////////////////////////////////

static void next_screen() {
	wrap_change_global_game_state(GAME_STATE_TITLE);
}

static uint8_t compute_final_medal(uint8_t n_medals) {
	uint8_t final_medal = COPPER_MEDAL;

	uint32_t const global_timer = timestamp(*arcade_mode_counter_minutes, *arcade_mode_counter_seconds, *arcade_mode_counter_frames);
	if (global_timer < timestamp(1,0,0)) { // World record TAS (hypotetical for now)
		final_medal = CHOCOLATE_MEDAL;
	}else if (global_timer < timestamp(1,26,48)) { // World record Human
		final_medal = TAS_MEDAL;
	}else {
		// Compute score (sum of medals)
		uint8_t score = 0;
		uint8_t current_medal_index = n_medals;
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

	return final_medal;
}

static uint8_t count_medals() {
	uint8_t n_medals = 0;
	Encounter const* const first_encounter = encounters();
	for (Encounter const* encounter = first_encounter; (uint8_t)(encounter - first_encounter) < n_encounters(); ++encounter) {
		load_encounter(encounter, arcade_bank());
		if (loaded_encounter()->type != encounter_type_cutscene()) {
			++n_medals;
		}
	}
	return n_medals;
}

static uint8_t medal_goal_x(uint8_t medal_idx, uint8_t n_medals) {
	uint8_t const medals_table_offset = sizeof(tiny_medals_x) / n_medals;
	return tiny_medals_x[medal_idx * medals_table_offset];
}

static uint8_t medal_goal_y(uint8_t medal_idx, uint8_t n_medals) {
	uint8_t const medals_table_offset = sizeof(tiny_medals_y) / n_medals;
	return tiny_medals_y[medal_idx * medals_table_offset];
}

static void move_sprite(uint8_t sprite_idx, uint8_t x, uint8_t y) {
	oam_mirror[sprite_idx*4+0] = y;
	oam_mirror[sprite_idx*4+3] = x;
}

static void place_medal(uint8_t medal_idx, uint16_t x, uint16_t y) {
	move_sprite(SPRITE_MEDALS + 0 + 4 * medal_idx, u16_msb(x)+0, u16_msb(y)+0);
	move_sprite(SPRITE_MEDALS + 1 + 4 * medal_idx, u16_msb(x)+8, u16_msb(y)+0);
	move_sprite(SPRITE_MEDALS + 2 + 4 * medal_idx, u16_msb(x)+0, u16_msb(y)+8);
	move_sprite(SPRITE_MEDALS + 3 + 4 * medal_idx, u16_msb(x)+8, u16_msb(y)+8);
	arcade_mode_congratz_medals_x_subpixel[medal_idx] = u16_lsb(x);
	arcade_mode_congratz_medals_y_subpixel[medal_idx] = u16_lsb(y);
}

static void move_medals(uint8_t n_medals) {
	//uint16_t const max_speed = 0x0400;
	//uint16_t const min_speed = 0x0080;
	for (uint8_t medal_idx = 0; medal_idx < n_medals; ++medal_idx) {
		uint8_t const sprite_idx = SPRITE_MEDALS + 4 * medal_idx;
		uint8_t const oam_idx = sprite_idx * 4;
		int32_t const current_y = u16(arcade_mode_congratz_medals_y_subpixel[medal_idx], oam_mirror[oam_idx+0]);
		if (current_y >= 0xf000) {
			continue;
		}
		int32_t const current_x = u16(arcade_mode_congratz_medals_x_subpixel[medal_idx], oam_mirror[oam_idx+3]);
		int32_t const goal_x = u16(0, medal_goal_x(medal_idx, n_medals));
		int32_t const goal_y = u16(0, medal_goal_y(medal_idx, n_medals));
		int32_t const diff_x = goal_x - current_x;
		int32_t const diff_y = goal_y - current_y;
		int32_t const end_x = current_x + (diff_x / 4);
		int32_t const end_y = current_y + (diff_y / 4);
		place_medal(medal_idx, end_x, end_y);
	}
}

static void pause_medal(uint8_t time, uint8_t n_medals) {
	while (time) {
		move_medals(n_medals);
		if (pause(1)) {
			return;
		}
		--time;
	}
}

void arcade_congratz() {
	uint8_t const TILE_0 = 246;
	uint8_t const TILE_COLON = TILE_0 - 1;
	uint8_t const TILE_STOCK = 0;
	uint8_t const TILE_TINY_MEDAL_NW = TILE_STOCK+1;
	uint8_t const TILE_TINY_MEDAL_NE = TILE_TINY_MEDAL_NW+1;
	uint8_t const TILE_TINY_MEDAL_SW = TILE_TINY_MEDAL_NE+1;
	uint8_t const TILE_TINY_MEDAL_SE = TILE_TINY_MEDAL_SW+1;
	uint8_t const SPRITE_STOCK = 63;

	// Set music
	wrap_audio_play_music(ptr_lsb(&music_sinbad2_bank), &music_sinbad2_info);

	// Draw screen
	stop_rendering();
	clear_screen();
	clear_bg_bot_left();

	long_construct_palettes_nt_buffer(screen_bank(), &arcade_congratz_palette);
	long_draw_zipped_nametable(screen_bank(), &arcade_congratz_nametable);
	long_cpu_to_ppu_copy_tileset_background(bg_tileset_bank(), &arcade_congratz_bg_tileset);
	long_cpu_to_ppu_copy_charset_raw(charset_alphanum_bank(), &charset_alphanum + 1, 0x1000 + ppu_tile_offset(TILE_0), 1, 2, 10);
	long_cpu_to_ppu_copy_charset_raw(charset_symbols_bank(), &char_colon, 0x1000 + ppu_tile_offset(TILE_COLON), 1, 2, 1);
	long_cpu_to_ppu_copy_tileset(tiny_medal_bank(), &arcade_congratz_tiny_medal_tileset, 0x0000 + ppu_tile_offset(TILE_TINY_MEDAL_NW));

	*tmpfield8 = 1;
	*tmpfield9 = 0;
	*tmpfield10 = 2;
	*tmpfield11 = 3;
	long_cpu_to_ppu_copy_tiles_modified(sinbad_bank(), &sinbad_chr_illustrations, &modifier_remap, 0x0000 + ppu_tile_offset(TILE_STOCK), 1);

	// Draw timer value
	uint8_t const timer_header[] = {0x21, 0x0a, 7};
	arcade_mode_bg_mem_buffer[0] = TILE_0 + *arcade_mode_counter_minutes;
	arcade_mode_bg_mem_buffer[1] = TILE_COLON;
	arcade_mode_bg_mem_buffer[2] = TILE_0 + (*arcade_mode_counter_seconds / 10);
	arcade_mode_bg_mem_buffer[3] = TILE_0 + (*arcade_mode_counter_seconds % 10);
	arcade_mode_bg_mem_buffer[4] = TILE_COLON;
	arcade_mode_bg_mem_buffer[5] = TILE_0 + (*arcade_mode_counter_frames / 10);
	arcade_mode_bg_mem_buffer[6] = TILE_0 + (*arcade_mode_counter_frames % 10);
	wrap_construct_nt_buffer(timer_header, arcade_mode_bg_mem_buffer);

	// Draw stocks counter
	arcade_mode_bg_mem_buffer[0] = 0x21;
	arcade_mode_bg_mem_buffer[1] = 0x15;
	if (*arcade_mode_nb_credits_used >= 100) {
		arcade_mode_bg_mem_buffer[2] = 3;
		arcade_mode_bg_mem_buffer[3] = TILE_0 + CONST_HUNDREDS(*arcade_mode_nb_credits_used);
		arcade_mode_bg_mem_buffer[4] = TILE_0 + CONST_TENS(*arcade_mode_nb_credits_used);
		arcade_mode_bg_mem_buffer[5] = TILE_0 + CONST_UNITS(*arcade_mode_nb_credits_used);
	}else if (*arcade_mode_nb_credits_used >= 10) {
		arcade_mode_bg_mem_buffer[2] = 2;
		arcade_mode_bg_mem_buffer[3] = TILE_0 + CONST_TENS(*arcade_mode_nb_credits_used);
		arcade_mode_bg_mem_buffer[4] = TILE_0 + CONST_UNITS(*arcade_mode_nb_credits_used);
	}else {
		arcade_mode_bg_mem_buffer[2] = 1;
		arcade_mode_bg_mem_buffer[3] = TILE_0 + (*arcade_mode_nb_credits_used);
	}
	wrap_push_nt_buffer(arcade_mode_bg_mem_buffer);

	// Place stock icon
	uint8_t const stock_y = 63;
	uint8_t const stock_x = 152;
	place_sprite(SPRITE_STOCK, stock_y, TILE_STOCK, 3, stock_x);

	// Show screen
	*scroll_y = 0xb0;
	oam_mirror[SPRITE_STOCK*4+0] = stock_y + (~(*scroll_y)+1) - 16;
	wrap_start_rendering(2);
	pause(25);

	// Display background
	long_construct_nt_buffer(screen_bank(), &arcade_congratz_sky_palette_buffer, (&arcade_congratz_sky_palette_buffer)+3);

	// Scroll score box up
	uint8_t const scroll_acceleration = 1;
	uint8_t const scroll_max_speed = 8;
	uint8_t const scroll_min_speed = 1;
	uint8_t const scroll_deceleration_point = 240 - ((scroll_max_speed * scroll_max_speed / 2) / scroll_acceleration);
	uint8_t scroll_speed = scroll_min_speed;
	while (*scroll_y < 240) {
		yield();
		if (skip_input()) {
			break;
		}

		if (*scroll_y < scroll_deceleration_point) {
			scroll_speed = limit_add(scroll_speed, scroll_acceleration, scroll_max_speed);
		}else {
			scroll_speed = limit_sub(scroll_speed, scroll_acceleration, scroll_min_speed);
		}

		*scroll_y += scroll_speed;
		oam_mirror[SPRITE_STOCK*4+0] = stock_y + (~(*scroll_y)+1) - 16;
	}

	*scroll_y = 0;
	oam_mirror[SPRITE_STOCK*4+0] = stock_y;
	*ppuctrl_val = 0x90;

	// Compute medals info
	uint8_t const n_medals = count_medals();
	uint8_t const final_medal = compute_final_medal(n_medals);

	// Display tiny medals
	for (uint8_t medal_idx = 0; medal_idx < n_medals; ++medal_idx) {
		uint8_t const medal_x = medal_center_x;
		uint8_t const medal_y = medal_center_y;
		uint8_t const medal_attribs = get_medal(n_medals - 1 - medal_idx);

		place_sprite(SPRITE_MEDALS + 0 + 4 * medal_idx, medal_y+0, TILE_TINY_MEDAL_NW, medal_attribs, medal_x+0);
		place_sprite(SPRITE_MEDALS + 1 + 4 * medal_idx, medal_y+0, TILE_TINY_MEDAL_NE, medal_attribs, medal_x+8);
		place_sprite(SPRITE_MEDALS + 2 + 4 * medal_idx, medal_y+8, TILE_TINY_MEDAL_SW, medal_attribs, medal_x+0);
		place_sprite(SPRITE_MEDALS + 3 + 4 * medal_idx, medal_y+8, TILE_TINY_MEDAL_SE, medal_attribs, medal_x+8);

		wrap_audio_play_sfx_from_list(ptr_lsb(&SFX_SHIELD_HIT_IDX));
		pause_medal(10, n_medals);
	}
	pause_medal(20, n_medals);

	// Display final medal
	uint8_t const* const medal_palette_buffers[] = {
		&arcade_congratz_copper_medal_buffer,
		&arcade_congratz_silver_medal_buffer,
		&arcade_congratz_gold_medal_buffer,
		&arcade_congratz_mythril_medal_buffer,
		&arcade_congratz_tas_medal_buffer,
		&arcade_congratz_chocolate_medal_buffer,
	};
	long_construct_nt_buffer(screen_bank(), &arcade_congratz_medal_buffer_header, medal_palette_buffers[final_medal]);
	wrap_audio_play_sfx_from_list(ptr_lsb(&SFX_DEATH_IDX));
	pause_medal(1, n_medals);

	// Wait and quit arcade mode
	wait_input();
	next_screen();
}

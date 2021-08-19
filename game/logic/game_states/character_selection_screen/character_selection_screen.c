#include <cstb.h>

///////////////////////////////////////
// C types for structured data
///////////////////////////////////////

struct BgTaskState {
	uint8_t step;

	uint8_t player;
	uint16_t ppu_addr;
	uint8_t const* prg_addr;
	uint8_t count;
} __attribute__((__packed__));

struct FixScreenTaskState {
	uint8_t step;
	uint8_t count;
} __attribute__((__packed__));

///////////////////////////////////////
// Global labels from the ASM codebase
///////////////////////////////////////

extern uint8_t const anim_empty;
extern uint8_t const char_selection_nametable;
extern uint8_t const char_selection_palette;
extern uint8_t const characters_bank_number;
extern uint8_t const characters_palettes_lsb;
extern uint8_t const characters_palettes_msb;
extern uint8_t const characters_properties_lsb;
extern uint8_t const characters_properties_msb;
extern uint8_t const characters_weapon_palettes_lsb;
extern uint8_t const characters_weapon_palettes_msb;
extern uint8_t const characters_tiles_data_lsb;
extern uint8_t const characters_tiles_data_msb;
extern uint8_t const menu_character_selection_anim_builders;
extern uint8_t const menu_character_selection_anim_p1_token;
extern uint8_t const menu_character_selection_anim_p2_token;
extern uint8_t const tileset_charset_alphanum_fg0_bg2;
extern uint8_t const tileset_menu_char_select;
extern uint8_t const tileset_menu_char_select_random_statue_tiles;
extern uint8_t const tileset_menu_char_select_sprites;

extern uint8_t const CHARACTERS_NUMBER; // This is actually a value label, use the address of this variable
extern uint8_t const TILESET_CHARSET_ALPHANUM_FG0_BG2_BANK_NUMBER; // Actually a label, use its address or "charset_bank()"

static uint8_t const TILE_CHAR_A = 230;
static uint8_t const TILE_CHAR_R = TILE_CHAR_A + ('r' - 'a');
static uint8_t const TILE_CHAR_N = TILE_CHAR_A + ('n' - 'a');
static uint8_t const TILE_CHAR_D = TILE_CHAR_A + ('d' - 'a');
static uint8_t const TILE_CHAR_O = TILE_CHAR_A + ('o' - 'a');
static uint8_t const TILE_CHAR_M = TILE_CHAR_A + ('m' - 'a');

void audio_play_interface_click();

///////////////////////////////////////
// Character selection's ASM functions
///////////////////////////////////////

void character_selection_screen_copy_portrait();
void character_selection_tick_char_anims();
void character_selection_copy_to_nt_buffer();
void character_selection_get_char_property();
void character_selection_construct_char_nt_buffer();
void character_selection_change_global_game_state_lite();
void character_selection_get_unzipped_bytes();
void character_selection_reset_music();

static uint16_t wrap_character_selection_get_char_property(uint8_t character, uint8_t property_offset) {
	*tmpfield1 = character;
	*tmpfield2 = property_offset;
	character_selection_get_char_property();
	return (((uint16_t)*tmpfield6) << 8) + *tmpfield5;
}

static void wrap_character_selection_construct_char_nt_buffer(uint8_t character, uint8_t const* header, uint8_t const* data) {
	*tmpfield1 = ptr_lsb(header);
	*tmpfield2 = ptr_msb(header);
	*tmpfield3 = ptr_lsb(data);
	*tmpfield4 = ptr_msb(data);
	*tmpfield5 = character;
	character_selection_construct_char_nt_buffer();
}

//TODO Check if reasonable to remove this implementation, and call "get_unzipped_bytes" instead
//     (should be slightly slower)
static void wrap_character_selection_get_unzipped_bytes(uint8_t const* zipped, uint16_t offset, uint8_t count) {
	*tmpfield1 = ptr_lsb(zipped);
	*tmpfield2 = ptr_msb(zipped);
	*tmpfield3 = u16_lsb(offset);
	*tmpfield4 = u16_msb(offset);
	*tmpfield5 = count;
	character_selection_get_unzipped_bytes();
}

///////////////////////////////////////
// Constants specific to this file
///////////////////////////////////////

static uint8_t const TILE_DICE_NW = 0x3b;
static uint8_t const TILE_DICE_NE = 0x3c;
static uint8_t const TILE_DICE_SW = 0x3d;
static uint8_t const TILE_DICE_SE = 0x3e;

static uint8_t const BG_FIRST_STEP = 0;
static uint8_t const BG_STEP_CHAR_NAME = 0;
static uint8_t const BG_STEP_STATUE_1 = 1;
static uint8_t const BG_STEP_STATUE_2 = 2;
static uint8_t const BG_STEP_CHAR_TILESET_1 = 3;
static uint8_t const BG_STEP_CHAR_TILESET_2 = 4;
static uint8_t const BG_STEP_ANIMATION = 5;
static uint8_t const BG_STEP_UPDATE_PALETTES = 6;
static uint8_t const BG_STEP_DEACTIVATED = 255;

static uint8_t const FIX_SCREEN_FIRST_STEP = 0;
static uint8_t const FIX_SCREEN_STEP_BG_INIT = 0;
static uint8_t const FIX_SCREEN_STEP_BG = 1;
static uint8_t const FIX_SCREEN_STEP_PORTRAITS = 2;
static uint8_t const FIX_SCREEN_STEP_DEACTIVATED = 255;

static uint8_t const CONTROL_ONE_PLAYER = 0;
static uint8_t const CONTROL_TWO_PLAYERS = 1;
static uint8_t const CONTROL_ONE_CHARACTER = 2;

static uint16_t const portrait_screen_pos[] = {0x224e, 0x2290, 0x22ce, 0x2310, 0x234e};

struct Position16 {
	uint16_t x;
	uint16_t y;
};

static struct Position16 const player_a_token_positions[] = {{124,143}, {112,159}, {124,175}, {112,191}, {124,207}};
static struct Position16 const player_b_token_positions[] = {{126,151}, {114,167}, {126,183}, {114,199}, {126,215}};

static struct Position16 const builder_anims_start_pos[] = {{32,79}, {176,79}};

///////////////////////////////////////
// Utility functions
///////////////////////////////////////

static uint8_t charset_bank() {
	return ptr_lsb(&TILESET_CHARSET_ALPHANUM_FG0_BG2_BANK_NUMBER);
}

static struct BgTaskState* Task(uint8_t* raw) {
	return (struct BgTaskState*)raw;
}

static struct FixScreenTaskState* FixScreen() {
	return (struct FixScreenTaskState*)character_selection_fix_screen_bg_task;
}

static uint8_t bitswap(uint8_t val) {
#if 0
	return
		((val >> 7) & 0x01) +
		((val >> 5) & 0x02) +
		((val >> 3) & 0x04) +
		((val >> 1) & 0x08) +
		((val << 1) & 0x10) +
		((val << 3) & 0x20) +
		((val << 5) & 0x40) +
		((val << 7) & 0x80)
	;
#else
	// Note: gcc fails to optimize the above solution, and that bothers me
	asm(
		"lda #0\r\n"
		"asl %0\r\n"
		"ror\r\n"
		"asl %0\r\n"
		"ror\r\n"
		"asl %0\r\n"
		"ror\r\n"
		"asl %0\r\n"
		"ror\r\n"
		"asl %0\r\n"
		"ror\r\n"
		"asl %0\r\n"
		"ror\r\n"
		"asl %0\r\n"
		"ror\r\n"
		"asl %0\r\n"
		"ror\r\n"
		"sta %0"
		: "+r"(val)
		:
		: "a"
	);
	return val;
#endif
}

static void construct_sprite_palette_buffer(uint8_t player, uint8_t palette_num, uint8_t const* data) {
	character_selection_mem_buffer[0] = 0x3f;
	character_selection_mem_buffer[1] = 0x11 + player * 8 + palette_num * 4;
	character_selection_mem_buffer[2] = 3;

	uint8_t const character = config_requested_player_a_character[player];
	wrap_character_selection_construct_char_nt_buffer(character, character_selection_mem_buffer, data);
}

static void copy_character_property(uint8_t character, uint8_t property_offset, uint8_t size) {
	uint8_t const* property_table = ptr((&characters_properties_lsb)[character], (&characters_properties_msb)[character]);
	long_memcpy(
		character_selection_mem_buffer,
		(&characters_bank_number)[character],
		property_table + property_offset,
		size
	);
}

static void copy_character_portrait(uint8_t character) {
	uint8_t const* portrait = (uint8_t const*)wrap_character_selection_get_char_property(character, CHARACTERS_PROPERTIES_ILLUSTRATIONS_ADDR_OFFSET);
	long_memcpy(
		character_selection_mem_buffer,
		(&characters_bank_number)[character],
		portrait + 16,
		4 * 16
	);
}

static void copy_to_nt_buffer(uint16_t ppu_addr, uint8_t n_bytes, uint8_t bank, uint8_t const* prg_addr) {
	uint8_t ntbuf_index = wrap_last_nt_buffer();
	nametable_buffers[ntbuf_index] = 1;
	nametable_buffers[ntbuf_index+1] = u16_msb(ppu_addr);
	nametable_buffers[ntbuf_index+2] = u16_lsb(ppu_addr);
	nametable_buffers[ntbuf_index+3] = n_bytes;
	long_memcpy(
		nametable_buffers + ntbuf_index + 4,
		bank,
		prg_addr,
		n_bytes
	);
	nametable_buffers[ntbuf_index+4+n_bytes] = 0;
}

static void copy_to_nt_buffer_from_char(uint8_t character, uint16_t ppu_addr, uint8_t n_bytes, uint8_t const* prg_addr) {
	uint8_t bank = (character >= (uint16_t)(&CHARACTERS_NUMBER) ? code_bank() : (&characters_bank_number)[character]);
	copy_to_nt_buffer(ppu_addr, n_bytes, bank, prg_addr);
}

///////////////////////////////////////
// State implementation
///////////////////////////////////////

static void tick_bg_tasks();

static void change_screen_cleaning() {
	// Copy selected values in actual values
	*config_player_a_character = *config_requested_player_a_character;
	*config_player_b_character = *config_requested_player_b_character;
	*config_player_a_weapon_palette = *config_requested_player_a_palette;
	*config_player_a_character_palette = *config_requested_player_a_palette;
	*config_player_b_weapon_palette = *config_requested_player_b_palette;
	*config_player_b_character_palette = *config_requested_player_b_palette;

	// Resolve random characters
	for (uint8_t player_num = 0; player_num < 2; ++player_num) {
		if (config_player_a_character[player_num] == (uint16_t)(&CHARACTERS_NUMBER)) {
			config_player_a_character[player_num] = character_selection_player_a_rnd[player_num] % (uint16_t)(&CHARACTERS_NUMBER);
		}
	}
}

static void next_screen() {
	change_screen_cleaning();

	// Finish any remaining drawings
	while(
		Task(character_selection_player_a_bg_task)->step <= BG_STEP_STATUE_2 ||
		Task(character_selection_player_b_bg_task)->step <= BG_STEP_STATUE_2
	)
	{
		wait_next_frame();
		reset_nt_buffers();
		tick_bg_tasks();
	}
	wait_next_frame();

	// Change state (without change_global_game_state(), we do not want transition)
	reset_nt_buffers();
	character_selection_change_global_game_state_lite();
}

static void previous_screen() {
	change_screen_cleaning();

	// Force sky-blue as background color to avoid a black flash during transition
	// (voluntary side effect: cancels any remaining nt buffer to not risk to have nmi longer than vblank)
	static uint8_t const palette_buffer[] = {0x01, 0x3f, 0x00, 0x01, 0x21, 0x00};
	for (uint8_t i = 0; i < sizeof(palette_buffer); ++i) {
		nametable_buffers[i] = palette_buffer[i];
	}

	wrap_change_global_game_state(*config_game_mode == GAME_MODE_ONLINE ? GAME_STATE_ONLINE_MODE_SELECTION : GAME_STATE_CONFIG);
}

static void tick_fix_screen() {
	struct FixScreenTaskState* task = FixScreen();

	switch (task->step) {
		case FIX_SCREEN_STEP_DEACTIVATED:
			break;

		case FIX_SCREEN_STEP_BG_INIT:
			task->count = 17;
			character_selection_mem_buffer[18] = 16;
			++task->step;
			__attribute__((fallthrough));

		case FIX_SCREEN_STEP_BG: {
			// Update palette of reconstructed rows
			static uint8_t const attribute_buffers[][7] = {
				{0x23, 0xe2, 4, 0x00, 0x40, 0x00, 0x00},
				{0x23, 0xea, 4, 0xaa, 0x40, 0x01, 0xaa},
				{0x23, 0xf2, 4, 0xaa, 0x40, 0x01, 0xaa},
			};

			if (task->count == 12 || task->count == 8 || task->count == 4) {
				uint8_t const buffer_num = (task->count / 4) - 1;
				wrap_push_nt_buffer(attribute_buffers[buffer_num]);
			}

			// Reconstruct a raw from the zipped nametable
			--task->count;
			uint16_t const nametable_offset = 0x1c8 + 32 * task->count;
			character_selection_mem_buffer[16] = u16_msb(0x2000 + nametable_offset);
			character_selection_mem_buffer[17] = u16_lsb(nametable_offset);
			wrap_character_selection_get_unzipped_bytes(&char_selection_nametable, nametable_offset, 16);
			wrap_construct_nt_buffer(character_selection_mem_buffer + 16, character_selection_mem_buffer);

			if (task->count == 0) {
				++task->step;
			}
			break;
		}

		case FIX_SCREEN_STEP_PORTRAITS: {
			// Draw character portraits
			uint8_t* mem_buffer = character_selection_mem_buffer;
			uint8_t character_idx;
			for (character_idx = 0; character_idx < (uint16_t)(&CHARACTERS_NUMBER); ++character_idx) {
				// Place portrait on screen
				uint8_t const first_tile = tileset_menu_char_select + (4 * character_idx);
				uint16_t const screen_pos = portrait_screen_pos[character_idx];
				uint16_t const screen_pos_line2 = screen_pos + 32;
				mem_buffer[0] = u16_msb(screen_pos);
				mem_buffer[1] = u16_lsb(screen_pos);
				mem_buffer[2] = 2;
				if (character_idx & 1) {
					mem_buffer[3] = first_tile + 1;
					mem_buffer[4] = first_tile;
				}else {
					mem_buffer[3] = first_tile;
					mem_buffer[4] = first_tile + 1;
				}
				wrap_push_nt_buffer(mem_buffer);

				mem_buffer[0] = u16_msb(screen_pos_line2);
				mem_buffer[1] = u16_lsb(screen_pos_line2);
				mem_buffer[2] = 2;
				if (character_idx & 1) {
					mem_buffer[3] = first_tile + 3;
					mem_buffer[4] = first_tile + 2;
				}else {
					mem_buffer[3] = first_tile + 2;
					mem_buffer[4] = first_tile + 3;
				}
				wrap_push_nt_buffer(mem_buffer);
			}

			// Place random's portrait
			uint16_t const screen_pos = portrait_screen_pos[character_idx];
			uint16_t const screen_pos_line2 = screen_pos + 32;
			mem_buffer[0] = u16_msb(screen_pos);
			mem_buffer[1] = u16_lsb(screen_pos);
			mem_buffer[2] = 2;
			mem_buffer[3] = TILE_DICE_NW;
			mem_buffer[4] = TILE_DICE_NE;
			wrap_push_nt_buffer(mem_buffer);

			mem_buffer[0] = u16_msb(screen_pos_line2);
			mem_buffer[1] = u16_lsb(screen_pos_line2);
			mem_buffer[2] = 2;
			mem_buffer[3] = TILE_DICE_SW;
			mem_buffer[4] = TILE_DICE_SE;
			wrap_push_nt_buffer(mem_buffer);

			++task->step;
			break;
		}

		default:
			task->step = FIX_SCREEN_STEP_DEACTIVATED;
			break;
	}
}

static void tick_bg_task(struct BgTaskState* task) {
	uint8_t const STATUE_BYTES_PER_TICK = 4 * 16;
	uint8_t const STATUE_NB_TICKS = 12;

	uint8_t const CHAR_BYTES_PER_TICK = 4 * 16;
	uint8_t const CHAR_NB_TICKS = 24;

	uint8_t const SPACE_TILE = 0x40;

	static uint8_t const char_names_buffer_headers[2][3] = {
		{0x20, 0xab, 0x0a},
		{0x21, 0x4b, 0x0a},
	};

	static uint8_t const random_character_name[10] = {
		SPACE_TILE, SPACE_TILE,
		TILE_CHAR_R, TILE_CHAR_A, TILE_CHAR_N, TILE_CHAR_D, TILE_CHAR_O, TILE_CHAR_M,
		SPACE_TILE, SPACE_TILE,
	};

	switch (task->step) {
		// Inactive state
		case BG_STEP_DEACTIVATED:
			break;

		// Write character's name
		case BG_STEP_CHAR_NAME: {
			uint8_t const character = config_requested_player_a_character[task->player];
			if (character < (uint16_t)&CHARACTERS_NUMBER) {
				copy_character_property(
					character,
					CHARACTERS_PROPERTIES_CHAR_NAME_OFFSET,
					10
				);
				for (uint8_t i = 0; i < 10; ++i) {
					if (character_selection_mem_buffer[i] == 0x02) {
						character_selection_mem_buffer[i] = SPACE_TILE;
					}
				}
				wrap_construct_nt_buffer(char_names_buffer_headers[task->player], character_selection_mem_buffer);
			}else {
				wrap_construct_nt_buffer(char_names_buffer_headers[task->player], random_character_name);
			}
			++task->step;
			break;
		}

		// Copy character's statue tiles to VRAM
		case BG_STEP_STATUE_1: {
			// Reinitialize builders animation
			struct Animation* const builders_anim = Anim(character_selection_player_a_builder_anim + (task->player * ANIMATION_STATE_LENGTH));
			wrap_animation_state_change_animation(
				(uint8_t* const)builders_anim,
				&menu_character_selection_anim_builders
			);
			builders_anim->x = builder_anims_start_pos[task->player].x;
			builders_anim->y = builder_anims_start_pos[task->player].y;

			// Compute ppu_addr/prg_addr at the begining of the tileset
			task->ppu_addr = 0x1000 + 16 * (tileset_menu_char_select + (uint16_t)(&CHARACTERS_NUMBER) * 4 + task->player * 48);
			if (config_requested_player_a_character[task->player] < (uint16_t)&CHARACTERS_NUMBER) {
				// Normal character, get its large illustration address
				task->prg_addr = (uint8_t const*)wrap_character_selection_get_char_property(
					config_requested_player_a_character[task->player],
					CHARACTERS_PROPERTIES_ILLUSTRATIONS_ADDR_OFFSET
				);
				task->prg_addr += 16 * 5;
			}else {
				// Random character, get random's illustration address
				task->prg_addr = &tileset_menu_char_select_random_statue_tiles;
			}

			// place ppu_addr/prg_addr at the end of the tileset
			task->prg_addr += 16 * 48 - STATUE_BYTES_PER_TICK;
			task->ppu_addr += 16 * 48 - STATUE_BYTES_PER_TICK;

			task->count = 0;
			++task->step;
			__attribute__((fallthrough));
		}
		case BG_STEP_STATUE_2:
			copy_to_nt_buffer_from_char(config_requested_player_a_character[task->player], task->ppu_addr, STATUE_BYTES_PER_TICK, task->prg_addr);
			++task->count;
			if (task->count < STATUE_NB_TICKS) {
				Anim(character_selection_player_a_builder_anim + (task->player * ANIMATION_STATE_LENGTH))->y -= 4;
				task->ppu_addr -= STATUE_BYTES_PER_TICK;
				task->prg_addr -= STATUE_BYTES_PER_TICK;
			}else {
				// Hide builders
				wrap_animation_state_change_animation(
					character_selection_player_a_builder_anim + (task->player * ANIMATION_STATE_LENGTH),
					&anim_empty
				);

				// Change step (stop there if there is no actual character selected)
				if (config_requested_player_a_character[task->player] < (uint16_t)&CHARACTERS_NUMBER) {
					++task->step;
				}else {
					task->step = BG_STEP_DEACTIVATED;
				}
			}
			break;

		// Copy character's tileset to VRAM
		case BG_STEP_CHAR_TILESET_1: {
			task->count = 0;
			task->ppu_addr = task->player * (CHARACTERS_NUM_TILES_PER_CHAR * 16);
			uint8_t const prg_addr_lsb = (&characters_tiles_data_lsb)[config_requested_player_a_character[task->player]];
			uint8_t const prg_addr_msb = (&characters_tiles_data_msb)[config_requested_player_a_character[task->player]];
			task->prg_addr = ptr(prg_addr_lsb, prg_addr_msb);
			++task->step;
			__attribute__((fallthrough));
		}
		case BG_STEP_CHAR_TILESET_2:
			copy_to_nt_buffer_from_char(config_requested_player_a_character[task->player], task->ppu_addr, CHAR_BYTES_PER_TICK, task->prg_addr);
			++task->count;
			if (task->count < CHAR_NB_TICKS) {
				task->ppu_addr += CHAR_BYTES_PER_TICK;
				task->prg_addr += CHAR_BYTES_PER_TICK;
			}else {
				++task->step;
			}
			break;

		// Change avatar animation to "menus selection"
		case BG_STEP_ANIMATION: {
			// Change animation
			uint8_t const* anim_addr = (uint8_t const*)wrap_character_selection_get_char_property(
				config_requested_player_a_character[task->player],
				CHARACTERS_PROPERTIES_MENU_SELECT_ANIM_OFFSET
			);
			wrap_animation_state_change_animation(
				character_selection_player_a_char_anim + (task->player * ANIMATION_STATE_LENGTH),
				anim_addr
			);
			if (task->player == 0) {
				Anim(character_selection_player_a_char_anim)->direction = DIRECTION_RIGHT;
			}

			++task->step;
			__attribute__((fallthrough));
		}

		case BG_STEP_UPDATE_PALETTES: {
			// Set avatar's palettes
			uint8_t const character = config_requested_player_a_character[task->player];

			uint8_t const char_palette_lsb = *(&characters_palettes_lsb + character);
			uint8_t const char_palette_msb = *(&characters_palettes_msb + character);
			uint8_t const* char_palette = ptr(char_palette_lsb, char_palette_msb) + 3 * config_requested_player_a_palette[task->player];

			uint8_t const weapon_palette_lsb = *(&characters_weapon_palettes_lsb + character);
			uint8_t const weapon_palette_msb = *(&characters_weapon_palettes_msb + character);
			uint8_t const* weapon_palette = ptr(weapon_palette_lsb, weapon_palette_msb) + 3 * config_requested_player_a_palette[task->player];

			construct_sprite_palette_buffer(task->player, 0, char_palette);
			construct_sprite_palette_buffer(task->player, 1, weapon_palette);

			++task->step;
			break;
		}

		default:
			task->step = BG_STEP_DEACTIVATED;
			break;
	}
}

static void tick_bg_tasks() {
	// Fixing screen from stage selection leftovers, absolute priority
	if (FixScreen()->step != FIX_SCREEN_STEP_DEACTIVATED) {
		tick_fix_screen();
		return;
	}

	// Tick the background task that is late
	struct BgTaskState* const pa_task = Task(character_selection_player_a_bg_task);
	struct BgTaskState* const pb_task = Task(character_selection_player_b_bg_task);

	uint16_t const pa_task_priority = (((uint16_t)pa_task->step) << 8) + pa_task->count;
	uint16_t const pb_task_priority = (((uint16_t)pb_task->step) << 8) + pb_task->count;

	if (pa_task_priority < pb_task_priority) {
		tick_bg_task(pa_task);
	}else {
		tick_bg_task(pb_task);
	}
}

static void refresh_player_character(uint8_t player) {
	// Set inivisible animation for the character (don't risk ticking animation on the wrong character)
	wrap_animation_state_change_animation(
		character_selection_player_a_char_anim + (player * ANIMATION_STATE_LENGTH),
		&anim_empty
	);

	// Start animation change async job (which will copy tiles in CHR-RAM before changing animation)
	struct BgTaskState* const task = &(Task(character_selection_player_a_bg_task)[player]);
	task->step = BG_FIRST_STEP;
	task->player = player;
}

static void refresh_ready_effects(uint8_t player) {
	//TODO
	(void)player;
}

static void refresh_player_palettes(uint8_t player) {
	// Start async job directly at the "update palettes step"
	//  only if the job is innactive, or already passed the palettes step
	//  and if on an actual character (not random selector)
	if (config_requested_player_a_character[player] < (uint16_t)(&CHARACTERS_NUMBER)) {
		struct BgTaskState* const task = &(Task(character_selection_player_a_bg_task)[player]);
		if (task->step == BG_STEP_DEACTIVATED || task->step > BG_STEP_UPDATE_PALETTES) {
			task->step = BG_STEP_UPDATE_PALETTES;
			task->player = player;
		}
	}
}

static void take_input(uint8_t player_num, uint8_t controller_btns, uint8_t last_fame_btns) {
	if (controller_btns != last_fame_btns) {
		switch (controller_btns) {
			case CONTROLLER_BTN_DOWN:
				if (!character_selection_player_a_ready[player_num]) {
					audio_play_interface_click();
					++config_requested_player_a_character[player_num];
					if (config_requested_player_a_character[player_num] > (uint16_t)(&CHARACTERS_NUMBER)) {
						config_requested_player_a_character[player_num] = 0;
					}
					refresh_player_character(player_num);
				}
				break;
			case CONTROLLER_BTN_UP:
				if (!character_selection_player_a_ready[player_num]) {
					audio_play_interface_click();
					if (config_requested_player_a_character[player_num] > 0) {
						--config_requested_player_a_character[player_num];
					}else {
						config_requested_player_a_character[player_num] = (uint16_t)(&CHARACTERS_NUMBER);
					}
					refresh_player_character(player_num);
				}
				break;
			case CONTROLLER_BTN_SELECT:
				audio_play_interface_click();
				if (config_requested_player_a_palette[player_num] < NB_CHARACTER_PALETTES - 1) {
					++config_requested_player_a_palette[player_num];
				}else {
					config_requested_player_a_palette[player_num] = 0;
				}
				refresh_player_palettes(player_num);
				break;

			// Buttons that take effect on release
			case 0:
				switch (last_fame_btns) {
					case CONTROLLER_BTN_A:
					case CONTROLLER_BTN_START:
						audio_play_interface_click();
						character_selection_player_a_ready[player_num] = 1;
						if (*character_selection_player_a_ready && *character_selection_player_b_ready) {
							next_screen();
						}else {
							refresh_ready_effects(player_num);
						}
						break;
					case CONTROLLER_BTN_B:
						audio_play_interface_click();
						if (character_selection_player_a_ready[player_num]) {
							character_selection_player_a_ready[player_num] = 0;
							refresh_ready_effects(player_num);
						}else {
							previous_screen();
						}
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

/**
 * Initialization common to full init and reinit.
 *
 * Mainly memory of the gamestate,
 * also nametable buffers that need to wait next vblank.
 */
static void init_character_selection_screen_common() {
	// Initial palette
	wrap_construct_palettes_nt_buffer(&char_selection_palette);

	// Initialize players readiness
	*character_selection_player_a_ready = 0;
	*character_selection_player_b_ready = 0;

	// Initialize control scheme
	*character_selection_control_scheme = CONTROL_ONE_PLAYER;
	if (*config_game_mode == GAME_MODE_ONLINE) {
		*character_selection_control_scheme = CONTROL_ONE_CHARACTER;
	}else if (*config_ai_level == 0) {
		*character_selection_control_scheme = CONTROL_TWO_PLAYERS;
	}

	// Set initial selection
	if (*character_selection_control_scheme == CONTROL_ONE_CHARACTER) {
		*config_requested_player_b_character = (uint8_t)((uint16_t)(&CHARACTERS_NUMBER));
		*character_selection_player_b_ready = 1;
	}

	// Initialize Character animations
	wrap_animation_init_state(character_selection_player_a_char_anim, &anim_empty);
	Anim(character_selection_player_a_char_anim)->x = 108;
	Anim(character_selection_player_a_char_anim)->y = 114;
	Anim(character_selection_player_a_char_anim)->first_sprite_num = INGAME_PLAYER_A_FIRST_SPRITE;
	Anim(character_selection_player_a_char_anim)->last_sprite_num = INGAME_PLAYER_A_LAST_SPRITE;

	wrap_animation_init_state(character_selection_player_b_char_anim, &anim_empty);
	Anim(character_selection_player_b_char_anim)->x = 140;
	Anim(character_selection_player_b_char_anim)->y = 114;
	Anim(character_selection_player_b_char_anim)->first_sprite_num = INGAME_PLAYER_B_FIRST_SPRITE;
	Anim(character_selection_player_b_char_anim)->last_sprite_num = INGAME_PLAYER_B_LAST_SPRITE;

	// Initialize token animations
	wrap_animation_init_state(character_selection_player_a_cursor_anim, &menu_character_selection_anim_p1_token);
	Anim(character_selection_player_a_cursor_anim)->x = player_a_token_positions[*config_requested_player_a_character].x;
	Anim(character_selection_player_a_cursor_anim)->y = player_a_token_positions[*config_requested_player_a_character].y;
	Anim(character_selection_player_a_cursor_anim)->first_sprite_num = INGAME_PLAYER_B_LAST_SPRITE + 1;
	Anim(character_selection_player_a_cursor_anim)->last_sprite_num = INGAME_PLAYER_B_LAST_SPRITE + 2;

	wrap_animation_init_state(character_selection_player_b_cursor_anim, &menu_character_selection_anim_p2_token);
	Anim(character_selection_player_b_cursor_anim)->x = player_b_token_positions[*config_requested_player_b_character].x;
	Anim(character_selection_player_b_cursor_anim)->y = player_b_token_positions[*config_requested_player_b_character].y;
	Anim(character_selection_player_b_cursor_anim)->first_sprite_num = INGAME_PLAYER_B_LAST_SPRITE + 3;
	Anim(character_selection_player_b_cursor_anim)->last_sprite_num = INGAME_PLAYER_B_LAST_SPRITE + 4;

	// Initialize statue builder animations
	wrap_animation_init_state(character_selection_player_a_builder_anim, &anim_empty);
	Anim(character_selection_player_a_builder_anim)->x = 0;
	Anim(character_selection_player_a_builder_anim)->y = 0;
	Anim(character_selection_player_a_builder_anim)->first_sprite_num = INGAME_PLAYER_B_LAST_SPRITE + 5;
	Anim(character_selection_player_a_builder_anim)->last_sprite_num = INGAME_PLAYER_B_LAST_SPRITE + 8;

	wrap_animation_init_state(character_selection_player_b_builder_anim, &anim_empty);
	Anim(character_selection_player_b_builder_anim)->x = 0;
	Anim(character_selection_player_b_builder_anim)->y = 0;
	Anim(character_selection_player_b_builder_anim)->first_sprite_num = INGAME_PLAYER_B_LAST_SPRITE + 9;
	Anim(character_selection_player_b_builder_anim)->last_sprite_num = INGAME_PLAYER_B_LAST_SPRITE + 12;

	// Initialize background tasks
	refresh_player_character(0);
	refresh_player_character(1);
}

void init_character_selection_screen_extra() {
	// Draw static part of the screen
	wrap_draw_zipped_nametable(&char_selection_nametable);
	wrap_cpu_to_ppu_copy_tiles((&tileset_menu_char_select)+1, 0x1000, tileset_menu_char_select);
	long_cpu_to_ppu_copy_tileset(charset_bank(), &tileset_charset_alphanum_fg0_bg2,0x1dc0);

	// Draw character portraits
	uint8_t character_idx;
	for (character_idx = 0; character_idx < (uint16_t)(&CHARACTERS_NUMBER); ++character_idx) {
		// Copy portrait in RAM
		copy_character_portrait(character_idx);

		// Fix portrait color indexes
		for (uint8_t tile_idx = 0; tile_idx < 5; ++tile_idx) {
			uint8_t* byte = character_selection_mem_buffer + (16 * tile_idx);
			for (uint8_t line_idx = 0; line_idx < 8; ++line_idx) {
				*byte = ~*byte;
				++byte;
			}
		}

		// Flip portrait if on the right column
		if (character_idx & 1) {
			for (uint8_t tile_idx = 0; tile_idx < 5; ++tile_idx) {
				uint8_t* byte = character_selection_mem_buffer + (16 * tile_idx);
				for (uint8_t line_idx = 0; line_idx < 16; ++line_idx) {
					*byte = bitswap(*byte);
					++byte;
				}
			}
		}

		// Copy portrait's tiles to the VRAM
		uint16_t const ppu_addr = 0x1000 + 16 * (tileset_menu_char_select + 4 * character_idx);
		wrap_cpu_to_ppu_copy_tiles(character_selection_mem_buffer, ppu_addr, 4*16);

		// Place portrait on screen
		uint8_t const first_tile = tileset_menu_char_select + (4 * character_idx);
		uint16_t const screen_pos = portrait_screen_pos[character_idx];
		uint16_t const screen_pos_line2 = screen_pos + 32;
		*PPUSTATUS;
		*PPUADDR = u16_msb(screen_pos);
		*PPUADDR = u16_lsb(screen_pos);
		if (character_idx & 1) {
			*PPUDATA = first_tile + 1;
			*PPUDATA = first_tile;
		}else {
			*PPUDATA = first_tile;
			*PPUDATA = first_tile + 1;
		}
		*PPUADDR = u16_msb(screen_pos_line2);
		*PPUADDR = u16_lsb(screen_pos_line2);
		if (character_idx & 1) {
			*PPUDATA = first_tile + 3;
			*PPUDATA = first_tile + 2;
		}else {
			*PPUDATA = first_tile + 2;
			*PPUDATA = first_tile + 3;
		}
	}

	// Place random's portrait
	uint16_t const screen_pos = portrait_screen_pos[character_idx];
	uint16_t const screen_pos_line2 = screen_pos + 32;
	*PPUSTATUS;
	*PPUADDR = u16_msb(screen_pos);
	*PPUADDR = u16_lsb(screen_pos);
	*PPUDATA = TILE_DICE_NW;
	*PPUDATA = TILE_DICE_NE;
	*PPUADDR = u16_msb(screen_pos_line2);
	*PPUADDR = u16_lsb(screen_pos_line2);
	*PPUDATA = TILE_DICE_SW;
	*PPUDATA = TILE_DICE_SE;

	// Init empty statues tiles
	uint16_t const ppu_tiles_statues_addr = 0x1000 + 16 * (tileset_menu_char_select + 4*(uint16_t)(&CHARACTERS_NUMBER));
	*PPUSTATUS;
	*PPUADDR = u16_msb(ppu_tiles_statues_addr);
	*PPUADDR = u16_lsb(ppu_tiles_statues_addr);
	for (uint8_t tile_num = 0; tile_num < 96; ++tile_num) {
		for (uint8_t line_num = 0; line_num < 8; ++line_num) {
			*PPUDATA = 0xff;
		}
		for (uint8_t line_num = 0; line_num < 8; ++line_num) {
			*PPUDATA = 0x00;
		}
	}

	// Place tiles for sprites from the menu in VRAM
	wrap_cpu_to_ppu_copy_tiles((&tileset_menu_char_select_sprites)+1, CHARACTERS_END_TILES_OFFSET, tileset_menu_char_select_sprites);

	// Reset music if we come from a state with another music
	if (*previous_global_game_state == GAME_STATE_GAMEOVER) {
		character_selection_reset_music();
	}

	// Initialize state's memory
	FixScreen()->step = FIX_SCREEN_STEP_DEACTIVATED;
	init_character_selection_screen_common();
}

void character_selection_reinit() {
	// Initialize state's memory
	reset_nt_buffers();
	init_character_selection_screen_common();

	// Start special background task that redraw screen over stage selection's leftovers
	FixScreen()->step = FIX_SCREEN_FIRST_STEP;
}

void character_selection_screen_tick_extra() {
	// Update background tasks
	reset_nt_buffers();
	tick_bg_tasks();

	// Update random numbers (frame counter until a player is ready)
	for (uint8_t player_num = 0; player_num < 2; ++player_num) {
		if (!character_selection_player_a_ready[player_num]) {
			++character_selection_player_a_rnd[player_num];
		}
	}

	// Draw characters animations
	character_selection_tick_char_anims();

	// Draw token animations
	*player_number = 0;
	wrap_animation_draw(character_selection_player_a_cursor_anim, 0, 0);
	if (!*character_selection_player_a_ready) {
		wrap_animation_tick(character_selection_player_a_cursor_anim);
	}

	*player_number = 1;
	wrap_animation_draw(character_selection_player_b_cursor_anim, 0, 0);
	if (!*character_selection_player_b_ready) {
		wrap_animation_tick(character_selection_player_b_cursor_anim);
	}

	// Draw builders animations
	*player_number = 0;
	wrap_animation_draw(character_selection_player_a_builder_anim, 0, 0);
	wrap_animation_tick(character_selection_player_a_builder_anim);

	*player_number = 1;
	wrap_animation_draw(character_selection_player_b_builder_anim, 0, 0);
	wrap_animation_tick(character_selection_player_b_builder_anim);

	// Move tokens
	{
		int16_t const dest_x = player_a_token_positions[*config_requested_player_a_character].x;
		int16_t const diff_x = dest_x - (int16_t)Anim(character_selection_player_a_cursor_anim)->x;
		int16_t const move_x = max(-4, min(4, diff_x));
		Anim(character_selection_player_a_cursor_anim)->x += move_x;

		int16_t const dest_y = player_a_token_positions[*config_requested_player_a_character].y;
		int16_t const diff_y = dest_y - (int16_t)Anim(character_selection_player_a_cursor_anim)->y;
		int16_t const move_y = max(-4, min(4, diff_y));
		Anim(character_selection_player_a_cursor_anim)->y += move_y;
	}

	{
		int16_t const dest_x = player_b_token_positions[*config_requested_player_b_character].x;
		int16_t const diff_x = dest_x - (int16_t)Anim(character_selection_player_b_cursor_anim)->x;
		int16_t const move_x = max(-4, min(4, diff_x));
		Anim(character_selection_player_b_cursor_anim)->x += move_x;

		int16_t const dest_y = player_b_token_positions[*config_requested_player_b_character].y;
		int16_t const diff_y = dest_y - (int16_t)Anim(character_selection_player_b_cursor_anim)->y;
		int16_t const move_y = max(-4, min(4, diff_y));
		Anim(character_selection_player_b_cursor_anim)->y += move_y;
	}

	// Take inputs
	switch (*character_selection_control_scheme) {
		case CONTROL_TWO_PLAYERS: {
			for (uint8_t player_num = 0; player_num < 2; ++player_num) {
				uint8_t const controller_btns = controller_a_btns[player_num];
				uint8_t const last_fame_btns = controller_a_last_frame_btns[player_num];
				take_input(player_num, controller_btns, last_fame_btns);
			}
			break;
		}

		case CONTROL_ONE_PLAYER: {
			uint8_t const player_num = *character_selection_player_a_ready;
			take_input(player_num, *controller_a_btns, *controller_a_last_frame_btns);
			break;
		}

		case CONTROL_ONE_CHARACTER: {
			take_input(0, *controller_a_btns, *controller_a_last_frame_btns);
			break;
		}
	}
}

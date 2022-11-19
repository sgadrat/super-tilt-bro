#include <cstb.h>

///////////////////////////////////////
// Allocated memory layout
///////////////////////////////////////

typedef struct {
	uint8_t current_track;
} __attribute__((__packed__)) StateVars;

typedef struct {
	// Local variables (short lifespan, could be moved to memory not persisted between ticks)
	uint8_t nt_header[3];
	char track_num_str[3];

	// Screen state
	Animation cursor_anim;
	uint8_t last_sample_index;
} __attribute__((__packed__)) StateMem;

_Static_assert(0x40 + sizeof(StateVars) <= 0xb0, "State require more zp than allocated");
_Static_assert(sizeof(StateMem) <= 0x80, "State require more memory than allocated");

static StateVars* vars() {
    return (StateVars*)jukebox_zp_mem;
}

static StateMem* mem() {
    return (StateMem*)jukebox_mem;
}

///////////////////////////////////////
// Global labels from the ASM codebase
///////////////////////////////////////

extern uint8_t const charset_ascii;
extern char const jukebox_themes_title;
extern char const jukebox_themes_author;

extern uint8_t const menu_jukebox_cursor_anim;
extern uint8_t const menu_jukebox_nametable;
extern uint8_t const menu_jukebox_palette;
extern uint8_t const menu_jukebox_sprites_tileset;
extern uint8_t const menu_jukebox_tileset;

// Labels, use their address or the associtated *_bank() function
extern uint8_t const CHARSET_ASCII_BANK_NUMBER;
extern uint8_t const MENU_JUKEBOX_ANIMS_BANK;
extern uint8_t const MENU_JUKEBOX_SCREEN_BANK;
extern uint8_t const MENU_JUKEBOX_TILESET_BANK;

extern uint8_t const LAST_JUKEBOX_TRACK;
extern uint8_t const THEME_TITLE_LENGTH;
extern uint8_t const THEME_AUTHOR_LENGTH;

///////////////////////////////////////
// Constants specific to this file
///////////////////////////////////////

uint8_t const CURSOR_MAX_X = 208;
uint8_t const CURSOR_MIN_X = 40;
uint8_t const CURSOR_Y = 79;
uint8_t const CURSOR_FIRST_SPRITE = 0;
uint8_t const CURSOR_LAST_SPRITE = 0;

///////////////////////////////////////
// Utility functions
///////////////////////////////////////

static uint8_t anims_bank() {
	return ptr_lsb(&MENU_JUKEBOX_ANIMS_BANK);
}

static uint8_t charset_bank() {
	return ptr_lsb(&CHARSET_ASCII_BANK_NUMBER);
}

static uint8_t screen_bank() {
	return ptr_lsb(&MENU_JUKEBOX_SCREEN_BANK);
}

static uint8_t theme_author_len() {
	return ptr_lsb(&THEME_AUTHOR_LENGTH);
}

static uint8_t theme_title_len() {
	return ptr_lsb(&THEME_TITLE_LENGTH);
}

static uint8_t tileset_bank() {
	return ptr_lsb(&MENU_JUKEBOX_TILESET_BANK);
}

static uint8_t last_jukebox_track() {
	return ptr_lsb(&LAST_JUKEBOX_TRACK);
}

static void print(uint8_t col, uint8_t line, uint8_t size, char const* text) {
	uint16_t const ppu_addr = 0x2000 + line * 32 + col;
	mem()->nt_header[0] = u16_msb(ppu_addr);
	mem()->nt_header[1] = u16_lsb(ppu_addr);
	mem()->nt_header[2] = size;
	wrap_construct_nt_buffer(mem()->nt_header, (uint8_t const*)text);
}

///////////////////////////////////////
// State implementation
///////////////////////////////////////

void jukebox_play_music(); // Implemented in assembly

// Reads a pointer in audio bank
static uint8_t const* audio_read(uint8_t const* addr) {
	uint8_t const* res;
	long_memcpy((uint8_t*)&res, *audio_current_track_bank, addr, 2);
	return res;
}

static void change_track() {
	// Start playback
	*tmpfield1 = vars()->current_track;
	jukebox_play_music();

	// Compute music length
	mem()->last_sample_index = 0;

	uint8_t const* sample_ptr = audio_read(ptr(*audio_current_track_lsb, *audio_current_track_msb));
	while (audio_read(sample_ptr) != 0) { // 0 = MUSIC_END
		++mem()->last_sample_index;
		sample_ptr += 2;
	}
	--mem()->last_sample_index;

	// Update title info
	uint8_t const track_num = vars()->current_track + 1;
	mem()->track_num_str[0] = '0' + track_num / 10;
	mem()->track_num_str[1] = '0' + track_num % 10;
	mem()->track_num_str[2] = '.';
	print(5, 6, 3, mem()->track_num_str);

	char const* const title = (&jukebox_themes_title) + vars()->current_track * theme_title_len();
	print(9, 6, theme_title_len(), title);

	// Update author info
	print(5, 8, 2, "by");
	char const* const author = (&jukebox_themes_author) + vars()->current_track * theme_author_len();
	print(8, 8, theme_author_len(), author);

	// Reset cursor
	mem()->cursor_anim.x = CURSOR_MIN_X;
}

static void move_cursor() {
	// Compute cursor progress in 8.8 fixed point
	uint16_t const cursor_range = u16(0, CURSOR_MAX_X - CURSOR_MIN_X);
	uint16_t const nb_steps = mem()->last_sample_index;
	uint16_t const step_size = cursor_range / nb_steps;
	uint16_t const cursor_progress = step_size * (*audio_square1_sample_num);

	// Set cursor pos on the integral part of the progress
	uint8_t const cursor_pos = CURSOR_MIN_X + u16_msb(cursor_progress);

	// Smoothly move actualy cursor on screen
	if (mem()->cursor_anim.x < cursor_pos) {
		++mem()->cursor_anim.x;
	}else {
		uint8_t const CURSOR_BACKWARD_SPEED = 9;
		mem()->cursor_anim.x = max(cursor_pos, mem()->cursor_anim.x - CURSOR_BACKWARD_SPEED);
	}
}

static void previous_track() {
	vars()->current_track = capped_dec(vars()->current_track, last_jukebox_track());
	change_track();
}

static void next_track() {
	vars()->current_track = capped_inc(vars()->current_track, last_jukebox_track());
	change_track();
}

static void toggle_music() {
	if (*audio_music_enabled == 0) {
		audio_unmute_music();
	}else {
		audio_mute_music();
	}
}

static void previous_screen() {
	audio_play_interface_click();
	reset_bg_color();
	wrap_change_global_game_state(GAME_STATE_TITLE);
}

static uint8_t handle_input() {
	// Check if a button is released and trigger correct action
	uint8_t had_input = 0;
	for (uint8_t controller = 0; controller < 2; ++controller) {
		if (*(controller_a_btns + controller) == 0) {
			switch (*(controller_a_last_frame_btns + controller)) {
				case CONTROLLER_BTN_UP:
				case CONTROLLER_BTN_LEFT:
					had_input = 1;
					previous_track();
					break;
				case CONTROLLER_BTN_DOWN:
				case CONTROLLER_BTN_RIGHT:
				case CONTROLLER_BTN_A:
					had_input = 1;
					next_track();
					break;
				case CONTROLLER_BTN_START:
					toggle_music();
					break;
				case CONTROLLER_BTN_B:
					//had_input = 1; // Useless, previous_screen never returns
					previous_screen();
					break;
			}
		}
	}

	// Inform if something has been done
	return had_input;
}

static void tick_animations() {
	*player_number = 0;
	long_animation_draw(anims_bank(), (uint8_t*)&(mem()->cursor_anim));
	long_animation_tick(anims_bank(), (uint8_t*)&(mem()->cursor_anim));
}

void init_jukebox_screen_extra() {
	// Draw screen
	long_construct_palettes_nt_buffer(screen_bank(), &menu_jukebox_palette);
	long_draw_zipped_nametable(screen_bank(), &menu_jukebox_nametable);
	long_cpu_to_ppu_copy_tileset_background(tileset_bank(), &menu_jukebox_tileset);
	long_cpu_to_ppu_copy_charset(charset_bank(), &charset_ascii, 0x1200, 0, 2);
	long_cpu_to_ppu_copy_tileset(tileset_bank(), &menu_jukebox_sprites_tileset, 0x0000);

	// Initialize state
	vars()->current_track = 0;
	change_track(); //NOTE maybe we could avoid to reset the music if it was already playing

	// Init animations
	wrap_animation_init_state((uint8_t*)(&(mem()->cursor_anim)), &menu_jukebox_cursor_anim);
	mem()->cursor_anim.x = CURSOR_MIN_X;
	mem()->cursor_anim.y = CURSOR_Y;
	mem()->cursor_anim.first_sprite_num = CURSOR_FIRST_SPRITE;
	mem()->cursor_anim.last_sprite_num = CURSOR_LAST_SPRITE;
}

void jukebox_screen_tick_extra() {
	// Tick animations
	tick_animations();

	// Check if a button is released and trigger correct action
	handle_input();

	// Refresh display
	move_cursor();
}

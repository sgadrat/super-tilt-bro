#include <cstb.h>
#include <string.h>

///////////////////////////////////////
// C types for structured data
///////////////////////////////////////

struct SatelliteState {
	int16_t velocity_h;
	int16_t velocity_v;
	int16_t x;
	int16_t y;
} __attribute__((__packed__));

static struct SatelliteState* Satellite(uint8_t* raw) {
    return (struct SatelliteState*)raw;
}

///////////////////////////////////////
// Global labels from the ASM codebase
///////////////////////////////////////

extern uint8_t const menu_online_mode_anim_cursor;
extern uint8_t const menu_online_mode_anim_line_cursor;
extern uint8_t const menu_online_mode_anim_monster;
extern uint8_t const menu_online_mode_anim_satellite;
extern uint8_t const menu_online_mode_anim_ship;
extern uint8_t const menu_online_mode_check_update_window;
extern uint8_t const menu_online_mode_connexion_window;
extern uint8_t const menu_online_mode_game_password_window;
extern uint8_t const menu_online_mode_login_window;
extern uint8_t const menu_online_mode_nametable;
extern uint8_t const menu_online_mode_palette;
extern uint8_t const menu_online_mode_setting_select_window;
extern uint8_t const tileset_menu_online_mode;
extern uint8_t const tileset_menu_online_mode_sprites;

extern uint8_t const MENU_ONLINE_MODE_TILESET_BANK_NUMBER; // Actually a label, use its address or "tileset_bank()"
extern uint8_t const ONLINE_MODE_SCREEN_EXTRA_BANK_NUMBER; // Actually a label, use its address or "code_bank()"

static uint8_t const TILE_CHAR_0 = 219;
static uint8_t const TILE_CHAR_1 = TILE_CHAR_0 + ('1' - '0');
static uint8_t const TILE_CHAR_2 = TILE_CHAR_0 + ('2' - '0');
static uint8_t const TILE_CHAR_3 = TILE_CHAR_0 + ('3' - '0');
static uint8_t const TILE_CHAR_4 = TILE_CHAR_0 + ('4' - '0');
static uint8_t const TILE_CHAR_5 = TILE_CHAR_0 + ('5' - '0');
static uint8_t const TILE_CHAR_6 = TILE_CHAR_0 + ('6' - '0');
static uint8_t const TILE_CHAR_7 = TILE_CHAR_0 + ('7' - '0');
static uint8_t const TILE_CHAR_8 = TILE_CHAR_0 + ('8' - '0');
static uint8_t const TILE_CHAR_9 = TILE_CHAR_0 + ('9' - '0');

static uint8_t const TILE_CHAR_A = 230;
static uint8_t const TILE_CHAR_B = TILE_CHAR_A + ('B' - 'A');
static uint8_t const TILE_CHAR_C = TILE_CHAR_A + ('C' - 'A');
static uint8_t const TILE_CHAR_D = TILE_CHAR_A + ('D' - 'A');
static uint8_t const TILE_CHAR_E = TILE_CHAR_A + ('E' - 'A');
static uint8_t const TILE_CHAR_F = TILE_CHAR_A + ('F' - 'A');
static uint8_t const TILE_CHAR_G = TILE_CHAR_A + ('G' - 'A');
static uint8_t const TILE_CHAR_H = TILE_CHAR_A + ('H' - 'A');
static uint8_t const TILE_CHAR_I = TILE_CHAR_A + ('I' - 'A');
static uint8_t const TILE_CHAR_J = TILE_CHAR_A + ('J' - 'A');
static uint8_t const TILE_CHAR_K = TILE_CHAR_A + ('K' - 'A');
static uint8_t const TILE_CHAR_L = TILE_CHAR_A + ('L' - 'A');
static uint8_t const TILE_CHAR_M = TILE_CHAR_A + ('M' - 'A');
static uint8_t const TILE_CHAR_N = TILE_CHAR_A + ('N' - 'A');
static uint8_t const TILE_CHAR_O = TILE_CHAR_A + ('O' - 'A');
static uint8_t const TILE_CHAR_P = TILE_CHAR_A + ('P' - 'A');
static uint8_t const TILE_CHAR_Q = TILE_CHAR_A + ('Q' - 'A');
static uint8_t const TILE_CHAR_R = TILE_CHAR_A + ('R' - 'A');
static uint8_t const TILE_CHAR_S = TILE_CHAR_A + ('S' - 'A');
static uint8_t const TILE_CHAR_T = TILE_CHAR_A + ('T' - 'A');
static uint8_t const TILE_CHAR_U = TILE_CHAR_A + ('U' - 'A');
static uint8_t const TILE_CHAR_V = TILE_CHAR_A + ('V' - 'A');
static uint8_t const TILE_CHAR_W = TILE_CHAR_A + ('W' - 'A');
static uint8_t const TILE_CHAR_X = TILE_CHAR_A + ('X' - 'A');
static uint8_t const TILE_CHAR_Y = TILE_CHAR_A + ('Y' - 'A');
static uint8_t const TILE_CHAR_Z = TILE_CHAR_A + ('Z' - 'A');

///////////////////////////////////////
// Screen specific ASM functions
///////////////////////////////////////

void online_mode_screen_tick_music();

///////////////////////////////////////
// Screen specific ASM labels
///////////////////////////////////////

uint32_t* const rnd = (uint32_t*) online_mode_rnd;

///////////////////////////////////////
// Constants specific to this file
///////////////////////////////////////

static uint8_t const TILE_EMPTY_TEXT = 85;
static uint8_t const TILE_SPACE = 3;
static uint8_t const TILE_CHAR_HIDDEN = 94;

static uint8_t const NB_OPTIONS = 4;
static uint8_t const OPTION_CASUAL = 0;
static uint8_t const OPTION_RANKED = 1;
static uint8_t const OPTION_PRIVATE = 2;
static uint8_t const OPTION_SETTINGS = 3;

static uint8_t const NB_SETTINGS = 3;
static uint8_t const SETTING_CREATE_ACCOUNT = 0;
static uint8_t const SETTING_CONFIGURE_WIFI = 1;
static uint8_t const SETTING_UPDATE_GAME = 2;
static uint8_t const SETTING_INVALID = 255;

static uint8_t const CURSOR_ANIM_FIRST_SPRITE = 0;
static uint8_t const CURSOR_ANIM_LAST_SPRITE = 5;

// Animations displayed while earth sprites are placed, carfully pick sprite indexes to not collide with earth
static uint8_t const SHIP_ANIM_FIRST_SPRITE = 23;
static uint8_t const SHIP_ANIM_LAST_SPRITE = 23;
static uint8_t const MONSTER_ANIM_FIRST_SPRITE = 0;
static uint8_t const MONSTER_ANIM_LAST_SPRITE = 1;
static uint8_t const SATELLITE_ANIM_SPRITE_FG = 4;
static uint8_t const SATELLITE_ANIM_SPRITE_BG = 63;

int16_t const SATELLITE_MAX_VELOCITY = (1 << 8) + 32;

typedef enum {
	LOGIN_UNLOGGED = 0,
	LOGIN_ANONYMOUS,
	LOGIN_LOGGED
} LoginState;

//static uint8_t const NB_SPRITE_PER_OPTION = 16; // C forbids the use of constants in constant arrays size, so make it a macro :(
#define NB_SPRITE_PER_OPTION 16

static uint8_t const earth_sprite_per_option[][NB_SPRITE_PER_OPTION] = {
	{
		255, 255, 0, 1,
		255, 2, 3, 4,
		5, 6, 7, 8,
		9, 10, 11, 12
	},
	{
		13, 14, 255, 255,
		15, 16, 17, 255,
		18, 19, 20, 21,
		22, 23, 24, 25
	},
	{
		26, 27, 28, 29,
		30, 31, 32, 33,
		255, 34, 35, 36,
		255, 255, 37, 38
	},
	{
		39, 40, 41, 42,
		43, 44, 45, 46,
		47, 48, 49, 255,
		50, 51, 255, 255
	},
};

static uint8_t const set_protocol_cmd[] = {
	2, TOESP_MSG_SERVER_SET_PROTOCOL,
	ESP_PROTOCOL_UDP
};
static uint8_t const esp_clear_cmd[] = {1, TOESP_MSG_CLEAR_BUFFERS};
static uint8_t const connect_cmd[] = {1, TOESP_MSG_SERVER_CONNECT};

static uint8_t const set_server_cmd[] = {
#ifndef LOCAL_LOGIN_SERVER
	// ESP header
	23, TOESP_MSG_SERVER_SET_SETTINGS,
	// Port
	0x12, 0x34,
	// Address
	's', 't', 'b', '-', 'l', 'o', 'g', 'i', 'n', '.', 'w', 'o', 'n', 't', 'f', 'i', 'x', '.', 'i', 't',
#else
	// ESP header
	12, TOESP_MSG_SERVER_SET_SETTINGS,
	// Port
	0x12, 0x34,
	// Address
	'l', 'o', 'c', 'a', 'l', 'h', 'o', 's', 't',
#endif
};

struct Position16 {
    uint16_t x;
    uint16_t y;
};

static struct Position16 const first_earth_sprite_per_option[] = {
	{80, 79},
	{144, 79},
	{80, 143},
	{144, 143},
};

static struct Position16 const ship_east_waypoints[] = {
	{146, 135},
	{120, 112},
	{124, 123},
	{120, 119},
	{124, 126},
};

static struct Position16 const ship_west_waypoints[] = {
	{91, 120},
	{106, 127},
	{88, 112},
	{113, 131},
	{117, 134},
};

///////////////////////////////////////
// STNP login extension
//  Login is not described in STNP doc,
//  let define it as an extension here.
///////////////////////////////////////

// High number at the "message_type" position to avoid ambiguity with standard STNP messages
static uint8_t const STNP_LOGIN_MSG_TYPE = 255;

// Login method
static uint8_t const STNP_LOGIN_ANONYMOUS = 0;
static uint8_t const STNP_LOGIN_PASSWORD = 1;
static uint8_t const STNP_LOGIN_CREATE_ACCOUNT = 2;

// Server message types
static uint8_t const STNP_LOGIN_FROM_SERVER_LOGGED_IN = 0;
static uint8_t const STNP_LOGIN_FROM_SERVER_LOGIN_FAILED = 1;

// Charset
static uint8_t const STNP_LOGIN_CHARSET[] = {
	TILE_EMPTY_TEXT,

	TILE_CHAR_A, TILE_CHAR_B, TILE_CHAR_C, TILE_CHAR_D, TILE_CHAR_E, TILE_CHAR_F, TILE_CHAR_G, TILE_CHAR_H, TILE_CHAR_I, TILE_CHAR_J,
	TILE_CHAR_K, TILE_CHAR_L, TILE_CHAR_M, TILE_CHAR_N, TILE_CHAR_O, TILE_CHAR_P, TILE_CHAR_Q, TILE_CHAR_R, TILE_CHAR_S, TILE_CHAR_T,
	TILE_CHAR_U, TILE_CHAR_V, TILE_CHAR_W, TILE_CHAR_X, TILE_CHAR_Y, TILE_CHAR_Z,

	TILE_SPACE,

	TILE_CHAR_0, TILE_CHAR_1, TILE_CHAR_2, TILE_CHAR_3, TILE_CHAR_4, TILE_CHAR_5, TILE_CHAR_6, TILE_CHAR_7, TILE_CHAR_8, TILE_CHAR_9,
};
static uint8_t const STNP_LOGIN_CHARSET_SIZE = sizeof(STNP_LOGIN_CHARSET);

///////////////////////////////////////
// Utility functions
///////////////////////////////////////

static void place_earth_sprites();
static void highlight_option();

static uint8_t tileset_bank() {
	return ptr_lsb(&MENU_ONLINE_MODE_TILESET_BANK_NUMBER);
}

static uint8_t code_bank() {
	return ptr_lsb(&ONLINE_MODE_SCREEN_EXTRA_BANK_NUMBER);
}

static void long_cpu_to_ppu_copy_tileset(uint8_t bank, uint8_t const* tileset, uint16_t ppu_addr) {
	// Set cpu_to_ppu_copy_tileset parameters
	*tmpfield1 = ptr_lsb(tileset);
	*tmpfield2 = ptr_msb(tileset);

	// Set PPU ADDR to destination
	*PPUSTATUS;
	*PPUADDR = u16_msb(ppu_addr);
	*PPUADDR = u16_lsb(ppu_addr);

	// Call
	wrap_trampoline(bank, code_bank(), &cpu_to_ppu_copy_tileset);
}

/** Not a real yield, pass a frame "as if" it gone through main loop */
static void yield() {
	wait_next_frame();
	online_mode_screen_tick_music();
	fetch_controllers();
	reset_nt_buffers();
}

static void draw_dialog(uint16_t position, uint8_t const* window, uint8_t lines_per_frame) {
	uint8_t const width = window[0];
	uint8_t n_lines = window[1];
	uint8_t const* line = window + 2;

	while (n_lines > 0) {
		for (uint8_t i = 0; n_lines > 0 && i < lines_per_frame; ++i) {
			// Construct nt buffer's header
			online_mode_selection_mem_buffer[0] = u16_msb(position);
			online_mode_selection_mem_buffer[1] = u16_lsb(position);
			online_mode_selection_mem_buffer[2] = width;

			// Draw one line
			wrap_construct_nt_buffer(online_mode_selection_mem_buffer, line);

			// Prepare next line
			--n_lines;
			position += 32;
			line += width;
		}
		yield();
	}
}

static void hide_earth_sprites() {
	for (uint8_t sprite_num = 0; sprite_num < NB_OPTIONS * NB_SPRITE_PER_OPTION; ++sprite_num) {
		oam_mirror[sprite_num * 4] = 0xfe;
	}
}

static void hide_dialog(uint16_t position, uint8_t const* window, uint8_t lines_per_frame) {
	uint8_t const width = window[0];
	uint8_t n_lines = window[1];

	// Reconstruct nametable line by line
	while (n_lines > 0) {
		for (uint8_t i = 0; n_lines > 0 && i < lines_per_frame; ++i) {
			--n_lines;

			uint16_t line_pos = position + 32 * n_lines;

			online_mode_selection_mem_buffer[2] = u16_msb(line_pos);
			online_mode_selection_mem_buffer[3] = u16_lsb(line_pos);
			online_mode_selection_mem_buffer[4] = width;
			wrap_get_unzipped_bytes(online_mode_selection_mem_buffer+5, &menu_online_mode_nametable, line_pos - 0x2000, width);
			wrap_push_nt_buffer(online_mode_selection_mem_buffer+2);
		}

		yield();
	}

	// Place earth sprites, and fix nametable's attributes
	place_earth_sprites();
	highlight_option();
	yield();
}

///////////////////////////////////////
// State implementation
///////////////////////////////////////

void audio_play_parry();
static void sound_effect_click() {
	audio_play_parry();
}

static void draw_logged_name() {
	// nt buffer header: 16 characters in the tittle bar
	static uint8_t const buffer_header[] = {0x20, 0x6d, 16};

	// Compute nt buffer payload
	uint8_t const TILE_TITLE_SPACE = 0x03;
	if (*network_logged != LOGIN_LOGGED) {
		for (uint8_t char_num = 0; char_num < 16; ++char_num) {
			online_mode_selection_mem_buffer[char_num] = TILE_TITLE_SPACE;
		}
	}else {
		for (uint8_t char_num = 0; char_num < 16; ++char_num) {
			uint8_t const original_char = network_login[char_num];
			uint8_t const buffer_char = (original_char == 0 ? TILE_TITLE_SPACE : STNP_LOGIN_CHARSET[original_char]);
			online_mode_selection_mem_buffer[char_num] = buffer_char;
		}
	}

	// Construct nt buffer
	wrap_construct_nt_buffer(buffer_header, online_mode_selection_mem_buffer);
}

static void place_earth_sprites() {
	for (uint8_t option = 0; option < NB_OPTIONS; ++option) {
		struct Position16 const sprites_position = first_earth_sprite_per_option[option];
		for (uint8_t y = 0; y < 4; ++y) {
			uint8_t const pixel_y = sprites_position.y + 8 * y;
			for (uint8_t x = 0; x < 4; ++x) {
				uint8_t const tile_index = earth_sprite_per_option[option][y * 4 + x];
				if (tile_index != 255) {
					uint8_t const pixel_x = sprites_position.x + 8 * x;
					uint8_t const sprite_num = option * NB_SPRITE_PER_OPTION + y * 4 + x;
					uint8_t const sprite_offset = sprite_num * 4;
					oam_mirror[sprite_offset + 0] = pixel_y;
					oam_mirror[sprite_offset + 1] = tile_index;
					oam_mirror[sprite_offset + 2] = 0;
					oam_mirror[sprite_offset + 3] = pixel_x;
				}
			}
		}
	}
}

static void clear_form_cursor() {
	for (uint8_t sprite_num = Anim(online_mode_selection_cursor_anim)->first_sprite_num; sprite_num <= Anim(online_mode_selection_cursor_anim)->last_sprite_num; ++sprite_num) {
		oam_mirror[sprite_num * 4] = 0xfe;
	}
}

static void esp_read_file(uint8_t size) {
	// Send read command to ESP
	RAINBOW_DATA = 2;
	RAINBOW_DATA = TOESP_MSG_FILE_READ;
	RAINBOW_DATA = size;

	// Wait answer
	do{
		yield();
	}while ((RAINBOW_FLAGS & 0x80) == 0);

	// Burn response header
	//TODO check that response type is the good one
	//TODO check that read size match requested size
	RAINBOW_DATA; // Garbage byte
	RAINBOW_DATA; // Message size
	RAINBOW_DATA; // Message type
	RAINBOW_DATA; // Read size
}

static void update_game() {
	// Draw "checking updates"
	draw_dialog(0x2146, &menu_online_mode_check_update_window, 3);
	//TODO hide cursor
	// Note: no attribute update / earth hide, only path to this window already sets it correctly

	// Download update file
	uint8_t const UPDATE_ROM_FILE = 1;
	static uint8_t const cmd_download_update[] = {
		// Message header
		1+2+54, TOESP_MSG_FILE_DOWNLOAD,

		// Destination
		ESP_FILE_PATH_ROMS, UPDATE_ROM_FILE,

		// URL
		'h', 't', 't', 'p', ':', '/', '/', 'u', 'p', 'g', 'r', 'a', 'd', 'e', '.', 's', 'u', 'p', 'e', 'r', '-', 't', 'i', 'l', 't', '-', 'b', 'r', 'o', '.', 'c', 'o', 'm', '/', 'g', 'e', 't', '_', 'f', 'r', 'o', 'm', '/',
		'0'+CONST_HUNDREDS(GAME_VERSION_MAJOR), '0'+CONST_TENS(GAME_VERSION_MAJOR), '0'+CONST_UNITS(GAME_VERSION_MAJOR), '-',
		'0'+CONST_HUNDREDS(GAME_VERSION_TYPE),  '0'+CONST_TENS(GAME_VERSION_TYPE),  '0'+CONST_UNITS(GAME_VERSION_TYPE), '-',
		'0'+CONST_HUNDREDS(GAME_VERSION_MINOR), '0'+CONST_TENS(GAME_VERSION_MINOR), '0'+CONST_UNITS(GAME_VERSION_MINOR),
	};
	wrap_esp_send_cmd(cmd_download_update);

	while(
		wrap_esp_get_msg(online_mode_selection_mem_buffer) != 2 ||
		online_mode_selection_mem_buffer[1] != FROMESP_MSG_FILE_DOWNLOAD
	)
	{
		if (*controller_a_btns == 0 && *controller_a_last_frame_btns == CONTROLLER_BTN_B) {
			return;
		}
		yield();
	}

	uint8_t const success = (online_mode_selection_mem_buffer[2] == 0);
	if (!success) {
		//TODO Draw "no update available" message and wait for input before returning
		return;
	}

	// Parse ROM header
	static uint8_t const cmd_open_file[] = {3, TOESP_MSG_FILE_OPEN, ESP_FILE_PATH_ROMS, UPDATE_ROM_FILE};
	wrap_esp_send_cmd(cmd_open_file);

	esp_read_file(1);
	uint8_t header_len = RAINBOW_DATA;
	if (header_len < 1) {
		//TODO error message
		return;
	}

	esp_read_file(header_len);
	uint8_t const safe = RAINBOW_DATA; --header_len;

	// Burn unknown header bytes
	while (header_len != 0) {
		RAINBOW_DATA;
		--header_len;
	}

	// Show confirmation dialogue
	//TODO

	// Call flash routine
	*PPUCTRL = ((*ppuctrl_val) & 0x7f); // Disable NMI
	if (safe) {
		flash_safe_sectors();
	}else {
		flash_all_sectors();
	}
}

static uint8_t select_setting_input(uint8_t* current_setting, uint8_t controller_btns, uint8_t last_frame_btns) {
	if (controller_btns != last_frame_btns) {
		switch (controller_btns) {
			case CONTROLLER_BTN_DOWN:
				sound_effect_click();
				if (*current_setting == NB_SETTINGS - 1) {
					*current_setting = 0;
				}else {
					++*current_setting;
				}
				break;
			case CONTROLLER_BTN_UP:
				sound_effect_click();
				if (*current_setting == 0) {
					*current_setting = NB_SETTINGS - 1;
				}else {
					--*current_setting;
				}
				break;

			// Buttons that take effect on release
			case 0:
				switch (last_frame_btns) {
					case CONTROLLER_BTN_A:
					case CONTROLLER_BTN_START:
						sound_effect_click();
						return 1;
					case CONTROLLER_BTN_B:
						sound_effect_click();
						return 2;
				};
				break;
		}
	}
	return 0;
}

static uint8_t select_setting() {
	// Display selection window
	draw_dialog(0x2146, &menu_online_mode_setting_select_window, 3);
	hide_earth_sprites();

	static uint8_t const palette_buffer[] = {
			0x23, 0xd1, 22,
			/*.*/ 0xc0, 0xf0, 0xf0, 0xf0, 0xf0, 0x30, 0x00,
			0x00, 0xcc, 0xaa, 0xaa, 0xaa, 0xaa, 0x33, 0x00,
			0x00, 0xcc, 0xfa, 0xfa, 0xfa, 0xfa, 0x73
	};
	wrap_push_nt_buffer(palette_buffer);
	yield();

	// Initialize cursor animation
	int16_t const first_option_position = 104;
	wrap_animation_init_state(online_mode_selection_cursor_anim, &menu_online_mode_anim_line_cursor);
	Anim(online_mode_selection_cursor_anim)->x = 64;
	Anim(online_mode_selection_cursor_anim)->y = first_option_position;
	Anim(online_mode_selection_cursor_anim)->first_sprite_num = CURSOR_ANIM_FIRST_SPRITE;
	Anim(online_mode_selection_cursor_anim)->last_sprite_num = CURSOR_ANIM_LAST_SPRITE;

	// Process window logic until the player selects an option
	uint8_t stay_in_window = 0;
	uint8_t current_setting = 0;
	while (stay_in_window == 0) {
		// Handle inputs
		stay_in_window = select_setting_input(&current_setting, *controller_a_btns, *controller_a_last_frame_btns);

		// Pace cursor
		Anim(online_mode_selection_cursor_anim)->y = first_option_position + 8 * current_setting;
		wrap_animation_draw(online_mode_selection_cursor_anim, 0, 0);
		wrap_animation_tick(online_mode_selection_cursor_anim);

		// Wait next frame
		yield();
	}

	// Handle action selected by the player
	if (stay_in_window == 1) {
		// Choice validated
		return current_setting;
	}else {
		// Choice cancelled
		return SETTING_INVALID;
	}
}

static void anonymous_login_draw_connexion_window() {
	draw_dialog(0x2146, &menu_online_mode_connexion_window, 3);

	switch (*online_mode_selection_current_option) {
		case 0: {
			static uint8_t const palette_buffer_option0[] = {
				0x23, 0xd1, 22,
				/*.*/ 0xd5, 0xf5, 0xf5, 0xf0, 0xf0, 0x30, 0x00,
				0x55, 0xdd, 0xaa, 0xaa, 0xaa, 0xaa, 0x33, 0x00,
				0x00, 0xcc, 0xfa, 0xfa, 0xfa, 0xfa, 0x33
			};
			wrap_push_nt_buffer(palette_buffer_option0);
			hide_earth_sprites();
			break;
		}
		case 2: {
			static uint8_t const palette_buffer_option2[] = {
				0x23, 0xd1, 22,
				/*.*/ 0xc0, 0xf0, 0xf0, 0xf0, 0xf0, 0x30, 0x00,
				0x00, 0xcc, 0xaa, 0xaa, 0xaa, 0xaa, 0x33, 0x00,
				0x55, 0xdc, 0xfa, 0xfa, 0xfa, 0xfa, 0x33
			};
			wrap_push_nt_buffer(palette_buffer_option2);
			clear_form_cursor();
			break;
		}
	}
}

static uint8_t anonymous_login() {
	static uint8_t const login_msg_cmd[] = {
		// ESP header
		3, TOESP_MSG_SERVER_SEND_MESSAGE,
		// STNP message type
		STNP_LOGIN_MSG_TYPE,
		// Anonymous login
		STNP_LOGIN_ANONYMOUS
	};

	// Clear ESP messages queue (avoid the mem_buffer being overflowed by a big remaining message)
	wrap_esp_send_cmd(esp_clear_cmd);
	yield();

	// Contact login server to get an anonymous ID
	wrap_esp_send_cmd(set_protocol_cmd);
	wrap_esp_send_cmd(set_server_cmd);
	wrap_esp_send_cmd(connect_cmd);
	yield();

	wrap_esp_send_cmd(login_msg_cmd);
	yield();

	// Wait for server's response
	uint8_t const RESEND_PERIOD = 60;
	uint8_t resend_counter = RESEND_PERIOD;
	while(
		wrap_esp_get_msg(online_mode_selection_mem_buffer) != 8 ||
		online_mode_selection_mem_buffer[1] != FROMESP_MSG_MESSAGE_FROM_SERVER ||
		online_mode_selection_mem_buffer[2] != STNP_LOGIN_MSG_TYPE
	)
	{
		// Cancel everything if B is pressed
		if (*controller_a_last_frame_btns == CONTROLLER_BTN_B && *controller_a_btns == 0) {
			hide_dialog(0x2146, &menu_online_mode_connexion_window, 2);
			return 0;
		}

		// Reemit periodically
		--resend_counter;
		if (resend_counter == 0) {
			wrap_esp_send_cmd(login_msg_cmd);
			anonymous_login_draw_connexion_window();
			resend_counter = RESEND_PERIOD;
		}

		// Wait one more frame
		yield();
	}

	network_client_id_byte0[0] = online_mode_selection_mem_buffer[5];
	network_client_id_byte0[1] = online_mode_selection_mem_buffer[6];
	network_client_id_byte0[2] = online_mode_selection_mem_buffer[7];
	network_client_id_byte0[3] = online_mode_selection_mem_buffer[8];

	// Mark logged as anonymous
	*network_logged = LOGIN_ANONYMOUS;

	return 1;

#if 0
	// Local version, using a random ID generated by the ESP

	static uint8_t const rnd_cmd[] = {1, TOESP_MSG_GET_RND_WORD};

	// Request random number's lowest nibbles
	wrap_esp_send_cmd(rnd_cmd);
	yield();

	while(wrap_esp_get_msg(online_mode_selection_mem_buffer) != 3 || online_mode_selection_mem_buffer[1] != FROMESP_MSG_RND_WORD) {
		yield();
	}
	network_client_id_byte0[0] = online_mode_selection_mem_buffer[2];
	network_client_id_byte0[1] = online_mode_selection_mem_buffer[3];

	// Request random number's highest nibbles
	wrap_esp_send_cmd(rnd_cmd);
	yield();

	while(wrap_esp_get_msg(online_mode_selection_mem_buffer) != 3 || online_mode_selection_mem_buffer[1] != FROMESP_MSG_RND_WORD) {
		yield();
	}
	network_client_id_byte0[2] = online_mode_selection_mem_buffer[2];
	network_client_id_byte0[3] = online_mode_selection_mem_buffer[3];

	// Mark logged as anonymous
	*network_logged = LOGIN_ANONYMOUS;
#endif
}

static uint8_t check_login_message(uint8_t type) {
	return
		online_mode_selection_mem_buffer[0] >= 2 &&
		online_mode_selection_mem_buffer[1] == FROMESP_MSG_MESSAGE_FROM_SERVER &&
		online_mode_selection_mem_buffer[2] == STNP_LOGIN_MSG_TYPE &&
		online_mode_selection_mem_buffer[3] == type
	;
}

static void password_login_send_request(uint8_t create) {
	online_mode_selection_mem_buffer[0] = 35;
	online_mode_selection_mem_buffer[1] = TOESP_MSG_SERVER_SEND_MESSAGE;
	online_mode_selection_mem_buffer[2] = STNP_LOGIN_MSG_TYPE;
	online_mode_selection_mem_buffer[3] = (create == 0 ? STNP_LOGIN_PASSWORD : STNP_LOGIN_CREATE_ACCOUNT);
	memcpy(online_mode_selection_mem_buffer+4, network_login, 16);
	memcpy(online_mode_selection_mem_buffer+20, network_password, 16);
	wrap_esp_send_cmd(online_mode_selection_mem_buffer);
}

static void password_login_process(uint8_t create) {
	// Clear login fields
	clear_form_cursor();
	draw_dialog(0x2146, &menu_online_mode_connexion_window, 3);

	// Clear ESP messages queue (avoid the mem_buffer being overflowed by a big remaining message)
	wrap_esp_send_cmd(esp_clear_cmd);
	yield();

	// Point connection to the login server
	wrap_esp_send_cmd(set_protocol_cmd);
	wrap_esp_send_cmd(set_server_cmd);
	wrap_esp_send_cmd(connect_cmd);
	yield();

	// Send login request
	password_login_send_request(create);
	yield();

	// Wait answer
	uint8_t const RESEND_PERIOD = 60;
	uint8_t resend_counter = RESEND_PERIOD;
	while (1) {
		// Cancel everything if B is pressed
		if (*controller_a_last_frame_btns == CONTROLLER_BTN_B && *controller_a_btns == 0) {
			break;
		}

		// Handle incoming message
		if (wrap_esp_get_msg(online_mode_selection_mem_buffer) != 0) {
			uint8_t const msg_payload_offset = 4;

			if (check_login_message(STNP_LOGIN_FROM_SERVER_LOGGED_IN)) {
				//TODO check first payload byte which should be STNP_LOGIN_PASSWORD or STNP_LOGIN_CREATE_ACCOUNT (not anonymous login)
				// Store received ID
				network_client_id_byte0[0] = online_mode_selection_mem_buffer[msg_payload_offset + 1];
				network_client_id_byte0[1] = online_mode_selection_mem_buffer[msg_payload_offset + 2];
				network_client_id_byte0[2] = online_mode_selection_mem_buffer[msg_payload_offset + 3];
				network_client_id_byte0[3] = online_mode_selection_mem_buffer[msg_payload_offset + 4];

				// Mark logged as authentified
				*network_logged = LOGIN_LOGGED;

				// Stop waiting a message
				break;
			}else if (check_login_message(STNP_LOGIN_FROM_SERVER_LOGIN_FAILED)) {
				// Set invariable window content
				static uint8_t const title_buffer[][18] = {
					{
						0x21, 0x68, 15,
						TILE_SPACE, TILE_SPACE,
						TILE_CHAR_L, TILE_CHAR_O, TILE_CHAR_G, TILE_CHAR_I, TILE_CHAR_N,
						TILE_SPACE, TILE_CHAR_F, TILE_CHAR_A, TILE_CHAR_I, TILE_CHAR_L,
						TILE_CHAR_E, TILE_CHAR_D,
						TILE_SPACE
					},
					{
						0x21, 0x68, 15,
						TILE_CHAR_C, TILE_CHAR_R, TILE_CHAR_E, TILE_CHAR_A, TILE_CHAR_T,
						TILE_CHAR_I, TILE_CHAR_O, TILE_CHAR_N, TILE_SPACE, TILE_CHAR_F,
						TILE_CHAR_A, TILE_CHAR_I, TILE_CHAR_L, TILE_CHAR_E, TILE_CHAR_D
					},
				};
				static uint8_t const separator_buffer[] = {
					0x21, 0x88, 9,
					TILE_SPACE, TILE_SPACE, TILE_SPACE, TILE_SPACE, TILE_SPACE,
					TILE_SPACE, TILE_SPACE, TILE_SPACE, TILE_SPACE
				};
				wrap_push_nt_buffer(title_buffer[create]);
				wrap_push_nt_buffer(separator_buffer);
				yield();

				// Replace window content by server's message
				static uint8_t const msg_lines_headers[][3] = {
					{0x21, 0xa7, 18},
					{0x21, 0xc7, 18},
					{0x21, 0xe7, 18},
					{0x22, 0x07, 18},
				};
				for (uint8_t line_num = 0; line_num < 4; ++line_num) {
					// Convert line from STNP charset to tiles index
					uint8_t const line_offset = msg_payload_offset + (18 * line_num);
					for (uint8_t char_pos = line_offset; char_pos < line_offset + 18; ++char_pos) {
						online_mode_selection_mem_buffer[char_pos] = STNP_LOGIN_CHARSET[online_mode_selection_mem_buffer[char_pos]];
					}

					// Draw line on screen
					wrap_construct_nt_buffer(msg_lines_headers[line_num], online_mode_selection_mem_buffer + msg_payload_offset + (18 * line_num));
					yield();
				}

				// Wait user acknoledge
				while (
					*controller_a_btns != 0 ||
					(*controller_a_last_frame_btns != CONTROLLER_BTN_B && *controller_a_last_frame_btns != CONTROLLER_BTN_START)
				)
				{
					yield();
				}

				// Mark user as unlogged
				*network_logged = LOGIN_UNLOGGED;

				// Stop waiting a message
				break;
			}
		}

		// Reemit periodically
		--resend_counter;
		if (resend_counter == 0) {
			password_login_send_request(create);
			resend_counter = RESEND_PERIOD;
		}

		// Wait one more frame
		yield();
	}

	// Update login indicator
	draw_logged_name();
	yield();
}

static void init_cursor_anim(uint16_t x, uint16_t y) {
	wrap_animation_init_state(online_mode_selection_cursor_anim, &menu_online_mode_anim_cursor);
	Anim(online_mode_selection_cursor_anim)->x = x;
	Anim(online_mode_selection_cursor_anim)->y = y;
	Anim(online_mode_selection_cursor_anim)->first_sprite_num = CURSOR_ANIM_FIRST_SPRITE;
	Anim(online_mode_selection_cursor_anim)->last_sprite_num = CURSOR_ANIM_LAST_SPRITE;
}

static void password_login_input(uint8_t controller_btns, uint8_t last_frame_btns, uint8_t* current_field, uint8_t* char_cursor, uint8_t* stay_in_window, uint8_t* cursor_state, uint8_t create) {
	uint8_t const AUTOFIRE_THRESHOLD = 14;
	uint8_t const AUTOFIRE_TICK = AUTOFIRE_THRESHOLD + 10;
	if (controller_btns != last_frame_btns) {
		*cursor_state = 0;
	}else {
		if (*cursor_state == AUTOFIRE_TICK) {
			*cursor_state = AUTOFIRE_THRESHOLD;
		}
		++*cursor_state;
	}

	if (controller_btns != last_frame_btns || *cursor_state == AUTOFIRE_TICK) {
		uint8_t* field_value = (*current_field == 0 ? network_login : network_password);
		switch (controller_btns) {
			case CONTROLLER_BTN_DOWN:
				sound_effect_click();
				if (field_value[*char_cursor] == 0) {
					field_value[*char_cursor] = STNP_LOGIN_CHARSET_SIZE - 1;
				}else {
					--field_value[*char_cursor];
				}
				break;
			case CONTROLLER_BTN_UP:
				sound_effect_click();
				if (field_value[*char_cursor] == STNP_LOGIN_CHARSET_SIZE - 1) {
					field_value[*char_cursor] = 0;
				}else {
					++field_value[*char_cursor];
				}
				break;
			case CONTROLLER_BTN_LEFT:
				sound_effect_click();
				if (*char_cursor > 0) {
					field_value[*char_cursor] = 0;
					--*char_cursor;
				}
				break;
			case CONTROLLER_BTN_RIGHT:
				sound_effect_click();
				if (field_value[*char_cursor] != 0 && *char_cursor != 15) {
					++*char_cursor;
				}
				break;

			// Buttons that take effect on release
			case 0:
				switch (last_frame_btns) {
					case CONTROLLER_BTN_A:
					case CONTROLLER_BTN_START:
						sound_effect_click();
						if (*current_field == 0) {
							uint8_t last_char = 0;
							while (network_password[last_char] != 0 && last_char != 15) {
								++last_char;
							}
							*char_cursor = last_char;
							*current_field = 1;
						}else {
							password_login_process(create);
							*stay_in_window = 0;
						}
						break;
					case CONTROLLER_BTN_B:
						sound_effect_click();
						if (*current_field == 1) {
							uint8_t last_char = 0;
							while (network_login[last_char] != 0 && last_char != 15) {
								++last_char;
							}
							*char_cursor = last_char;
							*current_field = 0;
						}else {
							*stay_in_window = 0;
						}
						break;
					default:
						break;
				};
				break;
		}
	}
}

static void password_login(uint8_t create) {
	// Display login window
	draw_dialog(0x2146, &menu_online_mode_login_window, 3);
	hide_earth_sprites();

	static uint8_t const palette_buffer[][25] = {
		{
			0x23, 0xd1, 22,
			/*.*/ 0xc0, 0xf0, 0xf0, 0xf5, 0xf5, 0x75, 0x55,
			0x00, 0xcc, 0xaa, 0xaa, 0xaa, 0xaa, 0x37, 0x55,
			0x00, 0xcc, 0xfa, 0xfa, 0xfa, 0xfa, 0x33
		},
		{
			0x23, 0xd1, 22,
			/*.*/ 0xc0, 0xf0, 0xf0, 0xf0, 0xf0, 0x30, 0x00,
			0x00, 0xcc, 0xaa, 0xaa, 0xaa, 0xaa, 0x33, 0x00,
			0x00, 0xcc, 0xfa, 0xfa, 0xfa, 0xfa, 0x73
		},
	};
	wrap_push_nt_buffer(palette_buffer[create]);
	yield();

	// Initialize cursor animation
	uint8_t const fields_x = 64;
	uint8_t const login_field_y = 104;
	uint8_t const password_field_y = 128;
	init_cursor_anim(fields_x, login_field_y);

	// Let user enter its credentials
	static uint8_t const login_nt_header[] = {0x21, 0xa8, 16};
	static uint8_t const password_nt_header[] = {0x22, 0x08, 16};

	uint8_t current_field = 0;
	uint8_t char_cursor = 0;
	uint8_t stay_in_window = 1;
	uint8_t cursor_state = 0;
	while (stay_in_window) {
		// Place cursor
		uint8_t const dest_x = fields_x + 8 * char_cursor;
		int16_t const diff_x = dest_x - (int16_t)Anim(online_mode_selection_cursor_anim)->x;
		int16_t const max_move = (-16 < diff_x && diff_x < 16 ? 4 : 16);
		int16_t const move_x = max(-max_move, min(max_move, diff_x));
		Anim(online_mode_selection_cursor_anim)->x += move_x;

		uint8_t const dest_y = (current_field == 0 ? login_field_y : password_field_y);
		int16_t const diff_y = dest_y - (int16_t)Anim(online_mode_selection_cursor_anim)->y;
		int16_t const move_y = max(-4, min(4, diff_y));
		Anim(online_mode_selection_cursor_anim)->y += move_y;

		*player_number = 0;
		wrap_animation_draw(online_mode_selection_cursor_anim, 0, 0);
		wrap_animation_tick(online_mode_selection_cursor_anim);

		// Take input
		password_login_input(
			*controller_a_btns, *controller_a_last_frame_btns,
			&current_field,
			&char_cursor, &stay_in_window, &cursor_state,
			create
		);

		// Draw current login
		for (uint8_t char_num = 0; char_num < 16; ++char_num) {
			online_mode_selection_mem_buffer[char_num] = STNP_LOGIN_CHARSET[network_login[char_num]];
		}
		wrap_construct_nt_buffer(login_nt_header, online_mode_selection_mem_buffer);

		// Draw current password
		for (uint8_t char_num = 0; char_num < 16; ++char_num) {
			uint8_t const character = network_password[char_num];
			if (character == 0 || (current_field == 1 && char_cursor == char_num)) {
				online_mode_selection_mem_buffer[char_num] = STNP_LOGIN_CHARSET[character];
			}else {
				online_mode_selection_mem_buffer[char_num] = TILE_CHAR_HIDDEN;
			}
		}
		wrap_construct_nt_buffer(password_nt_header, online_mode_selection_mem_buffer);

		yield();
	}

	// Repair damages caused to the screen
	clear_form_cursor();
	hide_dialog(0x2146, &menu_online_mode_login_window, 2);
}

static void create_account() {
	password_login(1);
}

static void clear_game_password() {
	for (uint8_t i = 0; i < 16; ++i) {
		network_game_password[i] = 0;
	}
}

static void game_password_input(uint8_t controller_btns, uint8_t last_frame_btns, uint8_t* char_cursor, uint8_t* stay_in_window, uint8_t* cursor_state) {
	uint8_t const AUTOFIRE_THRESHOLD = 14;
	uint8_t const AUTOFIRE_TICK = AUTOFIRE_THRESHOLD + 10;
	if (controller_btns != last_frame_btns) {
		*cursor_state = 0;
	}else {
		if (*cursor_state == AUTOFIRE_TICK) {
			*cursor_state = AUTOFIRE_THRESHOLD;
		}
		++*cursor_state;
	}

	if (controller_btns != last_frame_btns || *cursor_state == AUTOFIRE_TICK) {
		uint8_t* field_value = network_game_password;
		switch (controller_btns) {
			case CONTROLLER_BTN_DOWN:
				sound_effect_click();
				if (field_value[*char_cursor] == 0) {
					field_value[*char_cursor] = STNP_LOGIN_CHARSET_SIZE - 1;
				}else {
					--field_value[*char_cursor];
				}
				break;
			case CONTROLLER_BTN_UP:
				sound_effect_click();
				if (field_value[*char_cursor] == STNP_LOGIN_CHARSET_SIZE - 1) {
					field_value[*char_cursor] = 0;
				}else {
					++field_value[*char_cursor];
				}
				break;
			case CONTROLLER_BTN_LEFT:
				sound_effect_click();
				if (*char_cursor > 0) {
					field_value[*char_cursor] = 0;
					--*char_cursor;
				}
				break;
			case CONTROLLER_BTN_RIGHT:
				sound_effect_click();
				if (field_value[*char_cursor] != 0 && *char_cursor != 15) {
					++*char_cursor;
				}
				break;

			// Buttons that take effect on release
			case 0:
				switch (last_frame_btns) {
					case CONTROLLER_BTN_A:
					case CONTROLLER_BTN_START:
						sound_effect_click();
						*stay_in_window = 1;
						break;
					case CONTROLLER_BTN_B:
						sound_effect_click();
						*stay_in_window = 2;
						break;
					default:
						break;
				};
				break;
		}
	}
}

static uint8_t enter_game_password() {
	// Display password window
	draw_dialog(0x2146, &menu_online_mode_game_password_window, 3);
	hide_earth_sprites();

	static uint8_t const palette_buffer[] = {
		0x23, 0xd1, 22,
		/*.*/ 0xc0, 0xf0, 0xf0, 0xf0, 0xf0, 0x30, 0x00,
		0x00, 0xcc, 0xaa, 0xaa, 0xaa, 0xaa, 0x33, 0x00,
		0x55, 0xdc, 0xfa, 0xfa, 0xfa, 0xfa, 0x33
	};
	wrap_push_nt_buffer(palette_buffer);
	yield();

	// Initialize cursor animation
	uint8_t const field_x = 64;
	uint8_t const field_y = 128;
	init_cursor_anim(field_x, field_y);

	// Let user enter its credentials
	static uint8_t const password_nt_header[] = {0x22, 0x08, 16};

	uint8_t char_cursor = 0;
	uint8_t stay_in_window = 0;
	uint8_t cursor_state = 0;
	while (stay_in_window == 0) {
		// Place cursor
		uint8_t const dest_x = field_x + 8 * char_cursor;
		int16_t const diff_x = dest_x - (int16_t)Anim(online_mode_selection_cursor_anim)->x;
		int16_t const max_move = 4;
		int16_t const move_x = max(-max_move, min(max_move, diff_x));
		Anim(online_mode_selection_cursor_anim)->x += move_x;

		*player_number = 0;
		wrap_animation_draw(online_mode_selection_cursor_anim, 0, 0);
		wrap_animation_tick(online_mode_selection_cursor_anim);

		// Take input
		game_password_input(
			*controller_a_btns, *controller_a_last_frame_btns,
			&char_cursor, &stay_in_window, &cursor_state
		);

		// Draw current password
		for (uint8_t char_num = 0; char_num < 16; ++char_num) {
			online_mode_selection_mem_buffer[char_num] = STNP_LOGIN_CHARSET[network_game_password[char_num]];
		}
		wrap_construct_nt_buffer(password_nt_header, online_mode_selection_mem_buffer);

		yield();
	}

	uint8_t const password_validated = (stay_in_window == 1);

	// Repair damages caused to the screen
	//  Only when cancelled, to avoid useless screen-redraw glitch before changing screen
	if (!password_validated) {
		clear_form_cursor();
		hide_dialog(0x2146, &menu_online_mode_login_window, 2);
	}

	// Return OK if passowrd is validated
	return password_validated;
}

static void next_screen() {
	switch (*online_mode_selection_current_option) {
		case OPTION_CASUAL:
			if (*network_logged == LOGIN_UNLOGGED) {
				if (!anonymous_login()) {
					break;
				}
			}
			*network_ranked = 0;
			wrap_change_global_game_state(GAME_STATE_CHARACTER_SELECTION);
			break;
		case OPTION_RANKED:
			if (*network_logged != LOGIN_LOGGED) {
				password_login(0);
			}
			if (*network_logged == LOGIN_LOGGED) {
				*network_ranked = 1;
				wrap_change_global_game_state(GAME_STATE_CHARACTER_SELECTION);
			}
			break;
		case OPTION_PRIVATE:
			if (enter_game_password()) {
				if (*network_logged == LOGIN_UNLOGGED) {
					if (!anonymous_login()) {
						break;
					}
				}
				*network_ranked = 0;
				wrap_change_global_game_state(GAME_STATE_CHARACTER_SELECTION);
			}
			break;
		case OPTION_SETTINGS:
			switch (select_setting()) {
				case SETTING_CREATE_ACCOUNT:
					create_account();
					break;
				case SETTING_CONFIGURE_WIFI:
					wrap_change_global_game_state(GAME_STATE_WIFI_SETTINGS);
					break;
				case SETTING_UPDATE_GAME:
					update_game();
					break;
			}
			hide_dialog(0x2146, &menu_online_mode_setting_select_window, 2);
			break;
	}
}

static void previous_screen() {
	wrap_change_global_game_state(GAME_STATE_MODE_SELECTION);
}

static void take_input(uint8_t controller_btns, uint8_t last_fame_btns) {
	if (controller_btns != last_fame_btns) {
		switch (controller_btns) {
			case CONTROLLER_BTN_DOWN:
			case CONTROLLER_BTN_UP:
				sound_effect_click();
				if (*online_mode_selection_current_option < 2) {
					*online_mode_selection_current_option += 2;
				}else {
					*online_mode_selection_current_option -= 2;
				}
				break;
			case CONTROLLER_BTN_LEFT:
				sound_effect_click();
				if (*online_mode_selection_current_option > 0) {
					--*online_mode_selection_current_option;
				}else {
					*online_mode_selection_current_option = NB_OPTIONS - 1;
				}
				break;
			case CONTROLLER_BTN_RIGHT:
				sound_effect_click();
				*online_mode_selection_current_option = (*online_mode_selection_current_option + 1) % NB_OPTIONS;
				break;

			// Buttons that take effect on release
			case 0:
				switch (last_fame_btns) {
					case CONTROLLER_BTN_A:
					case CONTROLLER_BTN_START:
						sound_effect_click();
						next_screen();
						break;
					case CONTROLLER_BTN_B:
						sound_effect_click();
						previous_screen();
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

static void highlight_option() {
	// Place earth sprites behind selected box, and above others
	for (uint8_t option = 0; option < NB_OPTIONS; ++option) {
		uint8_t const attributes = (option == *online_mode_selection_current_option ? 0x20 : 0x00);
		for (uint8_t y = 0; y < 4; ++y) {
			for (uint8_t x = 0; x < 4; ++x) {
				uint8_t const tile_index = earth_sprite_per_option[option][y * 4 + x];
				if (tile_index != 255) {
					uint8_t const sprite_num = option * NB_SPRITE_PER_OPTION + y * 4 + x;
					uint8_t const sprite_offset = sprite_num * 4;
					oam_mirror[sprite_offset + 2] = attributes;
				}
			}
		}
	}

	// Set boxes palette
	static uint8_t const buffers_header[][3+48] = {
		{
			0x23, 0xc8, 48,
			0x5f, 0x50, 0x50, 0x50, 0x00, 0x00, 0x00, 0x00,
			0x55, 0x55, 0x55, 0x11, 0x00, 0x00, 0x00, 0x00,
			0x05, 0x05, 0x05, 0x01, 0x00, 0x00, 0x00, 0x00,
			0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
			0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
			0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
		},
		{
			0x23, 0xc8, 48,
			0x0f, 0x00, 0x00, 0x00, 0x50, 0x50, 0x50, 0x50,
			0x00, 0x00, 0x00, 0x00, 0x44, 0x55, 0x55, 0x55,
			0x00, 0x00, 0x00, 0x00, 0x04, 0x05, 0x05, 0x05,
			0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
			0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
			0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
		},
		{
			0x23, 0xc8, 48,
			0x0f, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
			0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
			0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
			0x50, 0x50, 0x50, 0x10, 0x00, 0x00, 0x00, 0x00,
			0x55, 0x55, 0x55, 0x11, 0x00, 0x00, 0x00, 0x00,
			0x05, 0x05, 0x05, 0x05, 0x00, 0x00, 0x00, 0x00,
		},
		{
			0x23, 0xc8, 48,
			0x0f, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
			0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
			0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
			0x00, 0x00, 0x00, 0x00, 0x40, 0x50, 0x50, 0x50,
			0x00, 0x00, 0x00, 0x00, 0x44, 0x55, 0x55, 0x55,
			0x00, 0x00, 0x00, 0x00, 0x05, 0x05, 0x05, 0x05,
		},
	};
	wrap_push_nt_buffer(buffers_header[*online_mode_selection_current_option]);
}

static void init_ship_anim() {
	// Init ship path
	*online_mode_ship_dest_x = ship_west_waypoints[0].x;
	*online_mode_ship_dest_y = ship_west_waypoints[0].y;

	// Init ship animation
	wrap_animation_init_state(online_mode_selection_ship_anim, &menu_online_mode_anim_ship);
	Anim(online_mode_selection_ship_anim)->direction = DIRECTION_LEFT;
	Anim(online_mode_selection_ship_anim)->x = 128;
	Anim(online_mode_selection_ship_anim)->y = 128;
	Anim(online_mode_selection_ship_anim)->first_sprite_num = SHIP_ANIM_FIRST_SPRITE;
	Anim(online_mode_selection_ship_anim)->last_sprite_num = SHIP_ANIM_LAST_SPRITE;
}

static void tick_ship() {
	// Move ship animation
	struct Animation* ship = Anim(online_mode_selection_ship_anim);

	if (ship->x == *online_mode_ship_dest_x && ship->y == *online_mode_ship_dest_y) {
		*rnd = random(*rnd);
		uint8_t const waypoint_num = (*rnd & 0x3);

		ship->direction = (ship->direction == DIRECTION_LEFT ? DIRECTION_RIGHT : DIRECTION_LEFT);
		struct Position16 const* const waypoints = (ship->direction == DIRECTION_RIGHT ? ship_east_waypoints : ship_west_waypoints);
		*online_mode_ship_dest_x = waypoints[waypoint_num].x;
		*online_mode_ship_dest_y = waypoints[waypoint_num].y;
	}

	if ((*online_mode_frame_count & 0x07) == 0) {
		if (*online_mode_ship_dest_x < ship->x) --ship->x;
		if (*online_mode_ship_dest_x > ship->x) ++ship->x;
		if (*online_mode_ship_dest_x < ship->x) --ship->x;
		if (*online_mode_ship_dest_x > ship->x) ++ship->x;
		if (*online_mode_ship_dest_y < ship->y) --ship->y;
		if (*online_mode_ship_dest_y > ship->y) ++ship->y;
	}

	// Draw ship animation
	*player_number = 0;
	wrap_animation_draw(online_mode_selection_ship_anim, 0, 0);
	wrap_animation_tick(online_mode_selection_ship_anim);
}

static void init_monster_anim() {
	// Init monster animation
	wrap_animation_init_state(online_mode_selection_monster_anim, &menu_online_mode_anim_monster);
	Anim(online_mode_selection_monster_anim)->direction = DIRECTION_LEFT;
	Anim(online_mode_selection_monster_anim)->x = 127;
	Anim(online_mode_selection_monster_anim)->y = 159;
	Anim(online_mode_selection_monster_anim)->first_sprite_num = MONSTER_ANIM_FIRST_SPRITE;
	Anim(online_mode_selection_monster_anim)->last_sprite_num = MONSTER_ANIM_LAST_SPRITE;
}

static void tick_monster() {
	// Draw monster animation
	*player_number = 0;
	wrap_animation_draw(online_mode_selection_monster_anim, 0, 0);
	wrap_animation_tick(online_mode_selection_monster_anim);
}

static void init_satellite_anim() {
	// Init satellite animation
	wrap_animation_init_state(online_mode_selection_satellite_anim, &menu_online_mode_anim_satellite);
	Anim(online_mode_selection_satellite_anim)->direction = DIRECTION_LEFT;
	Anim(online_mode_selection_satellite_anim)->first_sprite_num = SATELLITE_ANIM_SPRITE_FG;
	Anim(online_mode_selection_satellite_anim)->last_sprite_num = SATELLITE_ANIM_SPRITE_FG;

	// Init satellite state
	struct SatelliteState* state = Satellite(online_mode_satellite_state);
	state->velocity_h = SATELLITE_MAX_VELOCITY;
	state->velocity_v = 0;
	state->x = (127 << 8);
	state->y = (114 << 8);
}

static void tick_satellite() {
	struct SatelliteState* state = Satellite(online_mode_satellite_state);

	// Compute new velocity
	int16_t const target_x = 127;
	int16_t const target_y = 124;

	int16_t const to_target_x = target_x - i16_msb(state->x);
	int16_t const to_target_y = target_y - i16_msb(state->y);

	state->velocity_h += to_target_x / 8;
	state->velocity_v += to_target_y / 8;

	state->velocity_h = min(SATELLITE_MAX_VELOCITY, state->velocity_h);
	state->velocity_v = min(SATELLITE_MAX_VELOCITY, state->velocity_v);
	state->velocity_h = max(-SATELLITE_MAX_VELOCITY, state->velocity_h);
	state->velocity_v = max(-SATELLITE_MAX_VELOCITY, state->velocity_v);

	// Update position
	state->x += state->velocity_h;
	state->y += state->velocity_v;

	// Place satellite animation
	Anim(online_mode_selection_satellite_anim)->x = i16_msb(state->x);
	Anim(online_mode_selection_satellite_anim)->y = i16_msb(state->y);
	if (state->velocity_h > 0) {
		// Change sprite for a higher numbered when if should be behind earth
		Anim(online_mode_selection_satellite_anim)->first_sprite_num = SATELLITE_ANIM_SPRITE_BG;
		Anim(online_mode_selection_satellite_anim)->last_sprite_num = SATELLITE_ANIM_SPRITE_BG;
		oam_mirror[SATELLITE_ANIM_SPRITE_FG * 4] = 0xfe;
	}else {
		Anim(online_mode_selection_satellite_anim)->first_sprite_num = SATELLITE_ANIM_SPRITE_FG;
		Anim(online_mode_selection_satellite_anim)->last_sprite_num = SATELLITE_ANIM_SPRITE_FG;
		oam_mirror[SATELLITE_ANIM_SPRITE_BG * 4] = 0xfe;
	}

	// Draw satellite animation
	*player_number = 0;
	wrap_animation_draw(online_mode_selection_satellite_anim, 0, 0);
	wrap_animation_tick(online_mode_selection_satellite_anim);

	// Hack sprite to have it behind background when is should be behind earth
	if (Anim(online_mode_selection_satellite_anim)->first_sprite_num == SATELLITE_ANIM_SPRITE_BG) {
		oam_mirror[SATELLITE_ANIM_SPRITE_BG * 4 + 2] = 0x21;
	}
}

void init_online_mode_screen_extra() {
	// Draw static part of the screen
	wrap_construct_palettes_nt_buffer(&menu_online_mode_palette);
	wrap_draw_zipped_nametable(&menu_online_mode_nametable);
	long_cpu_to_ppu_copy_tileset(tileset_bank(), &tileset_menu_online_mode, 0x1000);
	long_cpu_to_ppu_copy_tileset(tileset_bank(), &tileset_menu_online_mode_sprites, 0x0000);

	// Place earth sprites
	place_earth_sprites();

	// Initialize RNG
	*rnd = 0xdeadbeef;

	// Initialize earth animations
	*online_mode_frame_count = 0;
	init_ship_anim();
	init_monster_anim();
	init_satellite_anim();

	// Initialize state
	*online_mode_selection_current_option = 0;

	// Initialize State in WRAM
	if (*network_logged == LOGIN_UNLOGGED) {
		for (uint8_t i = 0; i < 16; ++i) {
			network_login[i] = 0;
			network_password[i] = 0;
		}
		for (uint8_t i = 0; i < 4; ++i) {
			network_client_id_byte0[i] = 0;
		}
	}

	clear_game_password();

	// Draw login indicator
	draw_logged_name();
}

void online_mode_screen_tick_extra() {
	reset_nt_buffers();
	++*online_mode_frame_count;

	tick_ship();
	tick_monster();
	tick_satellite();

	for (uint8_t player = 0; player < 2; ++player) {
		take_input(controller_a_btns[player], controller_a_last_frame_btns[player]);
	}

	highlight_option();
}

#include <cstb.h>

///////////////////////////////////////
// C types for structured data
///////////////////////////////////////

typedef struct {
	uint8_t refresh_timer;

	// HACK
	//  Used by net_list coroutine to block requests to ESP by wifi_status
	//  Prototype cart tends to mess-up when generating two responses at the same time
	// FIXME remove this variable and all reference to it once cartridges are fixed
	uint8_t blocked;
} __attribute__((__packed__)) WifiStatusCtx;

typedef struct {
	uint8_t step;
	uint8_t net_count;
	union {
		uint8_t net_id;
		uint8_t line;
	};
} __attribute__((__packed__)) NetListCtx;

typedef struct {
	uint8_t step;
	union {
		uint8_t window_line;
		uint8_t cursor_state;
	};
} __attribute__((__packed__)) PasswordWindowCtx;

///////////////////////////////////////
// Allocated memory layout
///////////////////////////////////////

typedef struct {
	// Coroutines contexts
	WifiStatusCtx wifi_status_ctx;
	NetListCtx net_list_ctx;
	PasswordWindowCtx password_window_ctx;

	uint8_t current_network; ///< ID of the selected network in the list of scanned networks
	uint8_t password_cursor; ///< Position of the active character in the password (for edition purpose)
	uint8_t global_input; ///< Set to 1 before a yield to prevent global input handling for this frame
} __attribute__((__packed__)) StateVars;

typedef struct {
	uint8_t msg_buf[64];
	char password[17];
	Animation cursor_anim;
} __attribute__((__packed__)) StateMem;

_Static_assert(sizeof(StateVars) <= 0x16, "State require more zp than allocated");
_Static_assert(sizeof(StateMem) <= 0x80, "State require more memory than allocated");

static StateVars* vars() {
	return (StateVars*)wifi_settings_zp_mem;
}

static StateMem* mem() {
	return (StateMem*)wifi_settings_mem;
}

///////////////////////////////////////
// Global labels from the ASM codebase
///////////////////////////////////////

extern uint8_t const TILESET_ASCII_BANK_NUMBER; // Actually a label, use its address or "tileset_ascii_bank()"
extern uint8_t const TILE_MENU_WIFI_SETTINGS_DIALOGS_CHAR_HIDDEN; // Actually a label, use its address or "hidden_char()"
extern uint8_t const TILE_MENU_WIFI_SETTINGS_DIALOGS_CHAR_EMPTY; // Actually a label, use its address or "empty_char()"

extern uint8_t const tileset_ascii;

///////////////////////////////////////
// Screen specific ASM functions
///////////////////////////////////////

///////////////////////////////////////
// Screen specific ASM labels
///////////////////////////////////////

extern uint8_t const menu_wifi_settings_anim_cursor;
extern uint8_t const menu_wifi_settings_anim_line_cursor;
extern uint8_t const menu_wifi_settings_nametable;
extern uint8_t const menu_wifi_settings_palette;
extern uint8_t const menu_wifi_settings_password_window;
extern uint8_t const tileset_menu_wifi_settings;
extern uint8_t const tileset_menu_wifi_settings_high;
extern uint8_t const tileset_menu_wifi_settings_sprites;

///////////////////////////////////////
// Constants specific to this file
///////////////////////////////////////

static uint8_t const MSG_NETWORK_SSID_OFFSET = 9;

static uint8_t const CURSOR_ANIM_FIRST_SPRITE = 0;
static uint8_t const CURSOR_ANIM_LAST_SPRITE = 5;

static uint8_t const NO_PASSWORD_CURSOR = 255;

///////////////////////////////////////
// Utility functions
///////////////////////////////////////

#define COROUTINE_BEGIN uint16_t const coroutine_origin_line = __LINE__; switch (ctx->step) { case 0:
#define COROUTINE_END }
#define yield() ctx->step = (__LINE__ - coroutine_origin_line); return; case (__LINE__ - coroutine_origin_line):
#define yield_val(val) ctx->step = (__LINE__ - coroutine_origin_line); return (val); case (__LINE__ - coroutine_origin_line):

static uint8_t tileset_ascii_bank() {
	return ptr_lsb(&TILESET_ASCII_BANK_NUMBER);
}

static uint8_t hidden_char() {
	return ptr_lsb(&TILE_MENU_WIFI_SETTINGS_DIALOGS_CHAR_HIDDEN);
}

static uint8_t empty_char() {
	return ptr_lsb(&TILE_MENU_WIFI_SETTINGS_DIALOGS_CHAR_EMPTY);
}

static void draw_window_line(uint8_t const* window, uint8_t line, uint16_t position) {
	uint16_t const line_pos = position + line * 32;
	uint8_t const width = window[0];
	uint8_t const * const line_data = window + 2 + width * line;

	uint8_t nt_buff_header[3];
	nt_buff_header[0] = u16_msb(line_pos);
	nt_buff_header[1] = u16_lsb(line_pos);
	nt_buff_header[2] = width;

	wrap_construct_nt_buffer(nt_buff_header, line_data);
}

///////////////////////////////////////
// State implementation
///////////////////////////////////////

static void init_cursor_line_anim() {
	Animation* anim = &mem()->cursor_anim;
	wrap_animation_init_state((uint8_t*)anim, &menu_wifi_settings_anim_line_cursor);
	anim->first_sprite_num = CURSOR_ANIM_FIRST_SPRITE;
	anim->last_sprite_num = CURSOR_ANIM_LAST_SPRITE;
}

static void init_cursor_char_anim() {
	Animation* anim = &mem()->cursor_anim;
	wrap_animation_init_state((uint8_t*)anim, &menu_wifi_settings_anim_cursor);
	anim->first_sprite_num = CURSOR_ANIM_FIRST_SPRITE;
	anim->last_sprite_num = CURSOR_ANIM_LAST_SPRITE;
}

static void update_cursor() {
	Animation* anim = &mem()->cursor_anim;

	// Place cursor
	if (vars()->password_cursor == NO_PASSWORD_CURSOR) {
		anim->x = 48;
		anim->y = 80 + vars()->current_network * 8; // tricky: voluntarily hides animation on high values (by putting it off-screen)
	}else {
		anim->x = 64 + vars()->password_cursor * 8;
		anim->y = 120;
	}

	// Draw cursor
	*player_number = 0;
	wrap_animation_draw((uint8_t*)anim);
	wrap_animation_tick((uint8_t*)anim);
}

static void display_wifi_status() {
	static uint8_t const buffer_header[] = {0x20, 0x6a, 14};
	static uint8_t const wifi_status_strings[][14] = {
		{'i', 'd', 'l', 'e', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' '},
		{'n', 'o', ' ', 's', 's', 'i', 'd', ' ', ' ', ' ', ' ', ' ', ' ', ' '},
		{'s', 'c', 'a', 'n', ' ', 'c', 'o', 'm', 'p', 'l', 'e', 't', 'e', ' '},
		{'c', 'o', 'n', 'n', 'e', 'c', 't', 'e', 'd', ' ', ' ', ' ', ' ', ' '},
		{'c', 'o', 'n', 'n', 'e', 'c', 't', ' ', 'f', 'a', 'i', 'l', 'e', 'd'},
		{'c', 'o', 'n', 'n', 'e', 'c', 't', ' ', 'l', 'o', 's', 't', ' ', ' '},
		{'d', 'i', 's', 'c', 'o', 'n', 'n', 'e', 'c', 't', 'e', 'd', ' ', ' '},
	};
	static uint8_t const error_string[] =
		{'e', 'r', 'r', 'o', 'r', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' '}
	;

	// Refresh displayed status
	uint8_t const* msg = mem()->msg_buf;
	if (msg[ESP_MSG_SIZE] == 2 && msg[ESP_MSG_TYPE] == FROMESP_MSG_WIFI_STATUS) {
		uint8_t const status = msg[ESP_MSG_PAYLOAD];
		if (status < sizeof(wifi_status_strings) / sizeof(*wifi_status_strings)) {
			wrap_construct_nt_buffer(buffer_header, wifi_status_strings[status]);
		}else {
			wrap_construct_nt_buffer(buffer_header, error_string);
		}
	}

	// Request status info
	if (vars()->wifi_status_ctx.refresh_timer == 50) {
		vars()->wifi_status_ctx.refresh_timer = 0;

		if (vars()->wifi_status_ctx.blocked == 0) {
			static uint8_t const cmd_get_wifi_status[] = {1, TOESP_MSG_WIFI_GET_STATUS};
			wrap_esp_send_cmd(cmd_get_wifi_status);
		}
	}
	++vars()->wifi_status_ctx.refresh_timer;
}

static void send_cmd_get_network_details(uint8_t network_id) {
	esp_wait_tx();
	(&esp_tx_buffer)[0] = 2;
	(&esp_tx_buffer)[1] = TOESP_MSG_NETWORK_GET_SCANNED_DETAILS;
	(&esp_tx_buffer)[2] = network_id;
	RAINBOW_WIFI_TX = 0;
}

static void refresh_password_window() {
	static uint8_t const nt_buffer_header[] = {0x21, 0xe8, 16};
	uint8_t tiles[16];
	for (uint8_t i = 0; i < 16; ++i) {
		if (i < vars()->password_cursor) {
			tiles[i] = hidden_char();
		}else {
			if (mem()->password[i] == 0) {
				tiles[i] = empty_char();
			}else {
				tiles[i] = mem()->password[i];
			}
		}
	}
	wrap_construct_nt_buffer(nt_buffer_header, tiles);
}

static uint8_t password_window() {
	PasswordWindowCtx* const ctx = &vars()->password_window_ctx;
	uint8_t const * const window = &menu_wifi_settings_password_window;
	uint16_t position = 0x2146;

	COROUTINE_BEGIN
		// Draw window
		for (ctx->window_line = 0; ctx->window_line < window[1]; ++ctx->window_line) {
			draw_window_line(window, ctx->window_line, position);
			yield_val(1);
		}

		// Clear password
		for (uint8_t i = 0; i < sizeof(mem()->password); ++i) {
			mem()->password[i] = 0;
		}

		// Init cursor
		vars()->password_cursor = 0;
		init_cursor_char_anim();

		// Take inputs
		ctx->cursor_state = 0;
		while (1) {
			uint8_t const AUTOFIRE_THRESHOLD = 14;
			uint8_t const AUTOFIRE_TICK = AUTOFIRE_THRESHOLD + 5;
			if (*controller_a_btns != *controller_a_last_frame_btns) {
				ctx->cursor_state = 0;
			}else {
				if (ctx->cursor_state == AUTOFIRE_TICK) {
					ctx->cursor_state = AUTOFIRE_THRESHOLD;
				}
				++ctx->cursor_state;
			}

			if (*controller_a_btns != *controller_a_last_frame_btns || ctx->cursor_state == AUTOFIRE_TICK) {
				if (*controller_a_btns == CONTROLLER_BTN_UP) {
					audio_play_interface_click();
					char* c = &mem()->password[vars()->password_cursor];
					if (*c == 0) {
						*c = ' ';
					}else if (*c == 0x7e) {
						*c = 0;
					}else {
						++*c;
					}
				}else if (*controller_a_btns == CONTROLLER_BTN_DOWN) {
					audio_play_interface_click();
					char* c = &mem()->password[vars()->password_cursor];
					if (*c == 0) {
						*c = 0x7e;
					}else if (*c == ' ') {
						*c = 0;
					}else {
						--*c;
					}
				}else if (*controller_a_btns == CONTROLLER_BTN_LEFT) {
					audio_play_interface_click();
					if (vars()->password_cursor > 0) {
						mem()->password[vars()->password_cursor] = 0;
						--vars()->password_cursor;
					}
				}else if (*controller_a_btns == CONTROLLER_BTN_RIGHT) {
					audio_play_interface_click();
					if (vars()->password_cursor < sizeof(mem()->password) - 2 && mem()->password[vars()->password_cursor] != 0) {
						++vars()->password_cursor;
						mem()->password[vars()->password_cursor] = mem()->password[vars()->password_cursor - 1];
					}
				}else if (*controller_a_btns == 0) {
					if (
						*controller_a_last_frame_btns == CONTROLLER_BTN_A ||
						*controller_a_last_frame_btns == CONTROLLER_BTN_START
					)
					{
						audio_play_interface_click();
						vars()->password_cursor = NO_PASSWORD_CURSOR;
						init_cursor_line_anim();
						ctx->step = 0;
						return 0;
					}else if (*controller_a_last_frame_btns == CONTROLLER_BTN_B) {
						mem()->password[0] = 255;
						audio_play_interface_click();
						vars()->password_cursor = NO_PASSWORD_CURSOR;
						init_cursor_line_anim();
						ctx->step = 0;
						return 0;
					}
				}
			}

			// Draw password
			refresh_password_window();
			yield_val(1);
		};
	COROUTINE_END

	// Should not happen (invalid value in ctx->step)
	return 1;
}

static void register_network_in_msg() {
	uint8_t const * const msg = mem()->msg_buf;
	uint8_t const ssid_len = msg[MSG_NETWORK_SSID_OFFSET];
	uint8_t const password_len = strnlen8(mem()->password, 16);

	// Wait mapper to be ready to send a message
	esp_wait_tx();

	// Message header
	(&esp_tx_buffer)[0] = 2 + 1 + ssid_len + 1 + password_len;
	(&esp_tx_buffer)[1] = TOESP_MSG_NETWORK_REGISTER;

	// Network ID
	(&esp_tx_buffer)[2] = 0;

	// SSID
	(&esp_tx_buffer)[3] = ssid_len;
	for (uint8_t i = 1; i <= ssid_len; ++i) {
		(&esp_tx_buffer)[3+i] = msg[MSG_NETWORK_SSID_OFFSET + i];
	}

	// Password
	uint8_t const msg_network_password_offset = 3 + 1 + ssid_len;
	(&esp_tx_buffer)[msg_network_password_offset] = password_len;
	for (uint8_t i = 0; i < password_len; ++i) {
		(&esp_tx_buffer)[msg_network_password_offset+1+i] = mem()->password[i];
	}

	// Send message
	RAINBOW_WIFI_TX = 0;
}

static void update_net_list() {
	NetListCtx* const ctx = &vars()->net_list_ctx;
	uint8_t* const msg = mem()->msg_buf;

	static uint8_t const cmd_net_scan[] = {1, TOESP_MSG_NETWORK_SCAN};
	static uint8_t const empty_line[] = {' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' '};
	static uint8_t const scanning_line[] = {' ', ' ', ' ', ' ', 'S', 'c', 'a', 'n', 'n', 'i', 'n', 'g', ' ', '.', '.', '.', ' ', ' ', ' ', ' '};
	uint16_t const first_net_line_addr = 0x2146;
	uint8_t const MAX_NETWORKS = 14;
	uint8_t const MAX_DISPLAYED_CHARS = 20;
	_Static_assert(sizeof(empty_line) == MAX_DISPLAYED_CHARS, "empty line has bad size");

	COROUTINE_BEGIN
		// Block other requests
		vars()->wifi_status_ctx.blocked = 1;

		// Set current network to invalid
		vars()->current_network = 255;

		// Show "scanning"
		for (ctx->line = 0; ctx->line < MAX_NETWORKS; ++ctx->line) {
			uint16_t const line_addr = first_net_line_addr + ctx->line * 32;
			uint8_t nt_buf_header[3];
			nt_buf_header[0] = u16_msb(line_addr);
			nt_buf_header[1] = u16_lsb(line_addr);
			nt_buf_header[2] = MAX_DISPLAYED_CHARS;
			wrap_construct_nt_buffer(nt_buf_header, ctx->line == 6 ? scanning_line : empty_line);
			yield();
		}

		// Make ESP scan networks
		wrap_esp_send_cmd(cmd_net_scan);
		while (msg[ESP_MSG_SIZE] != 2 || msg[ESP_MSG_TYPE] != FROMESP_MSG_NETWORK_COUNT) {
			yield();
		}
		ctx->net_count = min(msg[ESP_MSG_PAYLOAD], MAX_NETWORKS);

		// Hide "scanning"
		static uint8_t scanning_buf_header[] = {0x22, 0x06, MAX_DISPLAYED_CHARS};
		wrap_construct_nt_buffer(scanning_buf_header, empty_line);

		// Display scanned networks
		for (ctx->net_id = 0; ctx->net_id < ctx->net_count; ++ctx->net_id) {
			// Retrieve network details
			send_cmd_get_network_details(ctx->net_id);
			while (msg[ESP_MSG_SIZE] == 0 || msg[ESP_MSG_TYPE] != FROMESP_MSG_NETWORK_SCANNED_DETAILS) {
				yield();
			}

			// Display network name
			uint16_t const line_addr = first_net_line_addr + ctx->net_id * 32;
			msg[MSG_NETWORK_SSID_OFFSET-2] = u16_msb(line_addr);
			msg[MSG_NETWORK_SSID_OFFSET-1] = u16_lsb(line_addr);
			msg[MSG_NETWORK_SSID_OFFSET] = min(msg[MSG_NETWORK_SSID_OFFSET], MAX_DISPLAYED_CHARS);
			wrap_push_nt_buffer(&msg[MSG_NETWORK_SSID_OFFSET-2]);

			// Wait next frame (to refresh "msg" contents)
			yield();
		}

		// Unblock other requests
		vars()->wifi_status_ctx.blocked = 0;

		// Set current network
		if (ctx->net_count != 0) {
			vars()->current_network = 0;
		}else {
			vars()->current_network = 255;
		}

		// Take inputs
		while (1) {
			if (vars()->current_network < MAX_NETWORKS && *controller_a_btns != *controller_a_last_frame_btns) {
				if (*controller_a_btns == CONTROLLER_BTN_DOWN) {
					audio_play_interface_click();
					++vars()->current_network;
					if (vars()->current_network >= ctx->net_count) {
						vars()->current_network = 0;
					}
				}else if (*controller_a_btns == CONTROLLER_BTN_UP) {
					audio_play_interface_click();
					if (vars()->current_network == 0) {
						vars()->current_network = ctx->net_count - 1;
					}else {
						--vars()->current_network;
					}
				}else if (*controller_a_btns == 0) {
					// Buttons that take effect on release
					if (
						*controller_a_last_frame_btns == CONTROLLER_BTN_A ||
						*controller_a_last_frame_btns == CONTROLLER_BTN_START
					)
					{
						audio_play_interface_click();

						// Ask password to the user
						while (password_window()) {
							vars()->global_input = 0;
							yield();
						}
						vars()->global_input = 0;

						if (mem()->password[0] != 255) {
							// Request selected network details, use it to register
							send_cmd_get_network_details(vars()->current_network);
							while (msg[ESP_MSG_SIZE] == 0 || msg[ESP_MSG_TYPE] != FROMESP_MSG_NETWORK_SCANNED_DETAILS) {
								yield();
							}
							register_network_in_msg();
						}

						// Reset coroutine
						ctx->step = 0;
						return;
					}
				}
			}

			yield();
		}
	COROUTINE_END
}

void init_wifi_settings_screen_extra() {
	// Draw static part of the screen
	wrap_construct_palettes_nt_buffer(&menu_wifi_settings_palette);
	wrap_draw_zipped_nametable(&menu_wifi_settings_nametable);
	wrap_cpu_to_ppu_copy_tileset(&tileset_menu_wifi_settings_sprites, 0x0000);
	wrap_cpu_to_ppu_copy_tileset(&tileset_menu_wifi_settings, 0x1000);
	wrap_cpu_to_ppu_copy_tileset(&tileset_menu_wifi_settings_high, 0x1800);
	long_cpu_to_ppu_copy_tileset(tileset_ascii_bank(), &tileset_ascii, 0x1200);

	// Init state
	vars()->wifi_status_ctx.refresh_timer = 0;
	vars()->wifi_status_ctx.blocked = 0;
	vars()->net_list_ctx.step = 0;
	vars()->password_window_ctx.step = 0;
	vars()->current_network = 255;
	vars()->password_cursor = NO_PASSWORD_CURSOR;

	// Init animations
	init_cursor_line_anim();
}

void wifi_settings_screen_tick_extra() {
	vars()->global_input = 1;

	// Get a message from ESP
	wrap_esp_get_msg(mem()->msg_buf);

	// Update state
	display_wifi_status();
	update_net_list();

	// Update animations
	update_cursor();

	// Handle global inputs
	if (vars()->global_input != 0 && *controller_a_btns == 0 && *controller_a_last_frame_btns == CONTROLLER_BTN_B) {
		audio_play_interface_click();
		wrap_change_global_game_state(GAME_STATE_ONLINE_MODE_SELECTION);
	}
}

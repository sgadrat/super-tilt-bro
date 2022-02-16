#include <cstb.h>

///////////////////////////////////////
// C types for structured data
///////////////////////////////////////

struct TaskState {
	uint8_t step;
	uint8_t count;
} __attribute__((__packed__));

///////////////////////////////////////
// Global labels from the ASM codebase
///////////////////////////////////////

extern uint8_t const esp_cmd_clear_buffers;
extern uint8_t const esp_cmd_connect;
extern uint8_t const init_stage_selection_screen;
extern uint8_t const menu_netplay_launch_selector_anim;

extern uint8_t const TILE_MENU_NETPLAY_LAUNCH_SPRITE_SERVER; // Actually a label, use its address or "server_tile()"
extern uint8_t const TILE_MENU_NETPLAY_LAUNCH_WIFI_ICON; // Actually a label, use its address or "wifi_icon_tile()"

///////////////////////////////////////
// Netplay launch's ASM functions
///////////////////////////////////////

extern uint8_t const menu_netplay_launch_illustration_map;

///////////////////////////////////////
// Constants specific to this file
///////////////////////////////////////

static uint8_t const TILE_SPACE = 0;
static uint8_t const TILE_ZERO = 220;

static uint8_t const BG_STEP_INIT_WIFI_SCREEN = 0;
static uint8_t const BG_STEP_MAP_SCREEN = 1;
static uint8_t const BG_STEP_DRAW_MAP = 2;
static uint8_t const BG_STEP_DRAW_MAP_2 = 3;
static uint8_t const BG_STEP_DRAW_MAP_SERVERS = 4;
static uint8_t const BG_STEP_SHOW_SERVER = 5;
static uint8_t const BG_STEP_PING_SCREEN = 6;
static uint8_t const BG_STEP_PING_SCREEN_CLEAR = 7;
static uint8_t const BG_STEP_PING_SCREEN_DECORATE_LOCAL = 8;
static uint8_t const BG_STEP_PING_SCREEN_DISPLAY_LOCAL = 9;
static uint8_t const BG_STEP_PING_SCREEN_LOCAL_CONNECTION = 10;
static uint8_t const BG_STEP_MATCHMAKING = 11;
static uint8_t const BG_STEP_MATCHMAKING_STATUS = 12;
static uint8_t const BG_STEP_COUNTDOWN = 13;
static uint8_t const BG_STEP_DEACTIVATED = 255;

static uint8_t const NB_KNOWN_SERVERS = 2;
static uint8_t const CUSTOM_SERVER_IDX = NB_KNOWN_SERVERS;
static uint8_t const server_position_x[] = {102, 131, 115};
static uint8_t const server_position_y[] = {164, 158, 175};
static char const server_name[][16] = {
	" n america east ",
	"     europe     ",
	"     custom     ",
};
static char const server_host[][19] = {
	"stb-nae.wontfix.it",
	"stb-euw.wontfix.it",
};

static uint8_t const CURSOR_SPRITE = 0;
static uint8_t const SERVER_SPRITES_BEGIN = 1;

static uint8_t const FIRST_ERROR_STATE = 250;
static uint8_t const ERROR_STATE_NO_CONTACT = FIRST_ERROR_STATE;
static uint8_t const ERROR_STATE_BAD_PING = FIRST_ERROR_STATE + 1;
static uint8_t const ERROR_STATE_CRAZY_MESSAGE = FIRST_ERROR_STATE + 2;
static uint8_t const ERROR_STATE_DISCONNECTED = FIRST_ERROR_STATE + 3;

static uint8_t const COUNTDOWN_DEACTIVATED = 255;
static uint8_t const FADEOUT_DURATION = 15;
static uint8_t const NETPLAY_LAUNCH_REEMISSION_TIMER = 60; // Time before reemiting a packet, in frames
static uint8_t const NB_PINGS = 3;
static uint8_t const PING_QUALITY_UNKNOWN = 255;

///////////////////////////////////////
// Utility functions
///////////////////////////////////////

static struct TaskState* Task(uint8_t* raw) {
	return (struct TaskState*)raw;
}

static uint8_t server_tile() {
	return ptr_lsb(&TILE_MENU_NETPLAY_LAUNCH_SPRITE_SERVER);
}

static uint8_t wifi_icon_tile() {
	return ptr_lsb(&TILE_MENU_NETPLAY_LAUNCH_WIFI_ICON);
}

static uint8_t alpha_tile(char c) {
	uint8_t const TILE_A = 230;
	if (c == ' ') {
		return 0;
	}
	return TILE_A + (c - 'a');
}

///////////////////////////////////////
// State implementation
///////////////////////////////////////

static void tick_bg_task();

static void skip_frame() {
	long_sleep_frame();
	fetch_controllers();
	reset_nt_buffers();
	tick_bg_task();
}

static void fade_out() {
	static uint8_t const nt_palette_header[] = {0x3f, 0x00, 0x20};
	static uint8_t const step_palettes[][0x20] = {
		{
			0x01,0x21,0x11,0x31, 0x01,0x31,0x31,0x31, 0x01,0x21,0x31,0x31, 0x01,0x01,0x21,0x11,
			0x01,0x01,0x31,0x01, 0x01,0x21,0x21,0x21, 0x01,0x01,0x31,0x01, 0x01,0x21,0x21,0x21,
		},
		{
			0x11,0x21,0x21,0x21, 0x11,0x21,0x21,0x21, 0x11,0x21,0x21,0x21, 0x11,0x11,0x21,0x21,
			0x11,0x11,0x21,0x11, 0x11,0x21,0x21,0x21, 0x11,0x11,0x21,0x11, 0x11,0x21,0x21,0x21,
		},
		{
			0x21,0x21,0x21,0x21, 0x21,0x21,0x21,0x21, 0x21,0x21,0x21,0x21, 0x21,0x21,0x21,0x21,
			0x21,0x21,0x21,0x21, 0x21,0x21,0x21,0x21, 0x21,0x21,0x21,0x21, 0x21,0x21,0x21,0x21,
		},
	};

	for (uint8_t fade_step = 0; fade_step < 3; ++fade_step) {
		wrap_construct_nt_buffer(nt_palette_header, step_palettes[fade_step]);
		for (uint8_t delay = 5; delay > 0; --delay) {
			skip_frame();
		}
	}
}

static void set_line_tiles(uint8_t const* tiles, uint8_t line_num) {
	uint16_t const ppu_addr = 0x21c8 + line_num * 32;
	uint8_t const size = 16;
	netplay_launch_bg_mem_buffer[0] = u16_msb(ppu_addr);
	netplay_launch_bg_mem_buffer[1] = u16_lsb(ppu_addr);
	netplay_launch_bg_mem_buffer[2] = size;
	wrap_fixed_memcpy(netplay_launch_bg_mem_buffer+3, tiles, size);
	wrap_push_nt_buffer(netplay_launch_bg_mem_buffer);
}

static void set_text(char const* text, uint8_t line, uint8_t col) {
	uint16_t const ppu_addr = 0x21c8 + line * 32 + col;
	uint16_t const size = strnlen8(text, 16);;
	netplay_launch_bg_mem_buffer[0] = u16_msb(ppu_addr);
	netplay_launch_bg_mem_buffer[1] = u16_lsb(ppu_addr);
	netplay_launch_bg_mem_buffer[2] = size;
	for (uint8_t tile = 0; tile < size; ++tile) {
		netplay_launch_bg_mem_buffer[3+tile] = alpha_tile(text[tile]);
	}
	wrap_push_nt_buffer(netplay_launch_bg_mem_buffer);
}

static void set_line_text(char const* text, uint8_t line_num) {
	set_text(text, line_num, 0);
}

static void set_selection_bar_title(char const* title) {
	set_line_text(title, 0);
}

static void display_ping(uint8_t player, uint8_t line, uint8_t col) {
	uint8_t const ping_count = (player == 0 ? *netplay_launch_local_ping_count : *netplay_launch_rival_ping_count);
	uint8_t const* ping_values = (player == 0 ? netplay_launch_local_ping_values : netplay_launch_rival_ping_values);

	for (uint8_t val_idx = 0; val_idx < ping_count; ++val_idx) {
		uint16_t const ppu_addr = 0x21c8 + line * 32 + col + 4 * val_idx;
		netplay_launch_bg_mem_buffer[0] = u16_msb(ppu_addr);
		netplay_launch_bg_mem_buffer[1] = u16_lsb(ppu_addr);
		netplay_launch_bg_mem_buffer[2] = 3;
		if (ping_values[val_idx] == PING_QUALITY_UNKNOWN) {
			netplay_launch_bg_mem_buffer[3] = alpha_tile('x');
			netplay_launch_bg_mem_buffer[4] = alpha_tile('x');
			netplay_launch_bg_mem_buffer[5] = alpha_tile('x');
		}else {
			uint16_t const val_ms = ping_values[val_idx] * 4;
			uint8_t const hundreds = val_ms / 100; //NOTE: rainbow never gives values over 1 second (considers it lost)
			uint8_t const tens = (val_ms % 100) / 10;
			uint8_t const units = val_ms % 10;
			netplay_launch_bg_mem_buffer[3] = (hundreds == 0 ? TILE_SPACE : TILE_ZERO + hundreds);
			netplay_launch_bg_mem_buffer[4] = ((hundreds == 0 && tens == 0) ? TILE_SPACE : TILE_ZERO + tens);
			netplay_launch_bg_mem_buffer[5] = TILE_ZERO + units;
		}
		wrap_push_nt_buffer(netplay_launch_bg_mem_buffer);
	}
}

static void display_ping_quality(uint8_t quality, uint8_t line, uint8_t col) {
	static char const quality_str[][12] = {
		" excellent ",
		"   good    ",
		"   poor    ",
	};
	set_text(quality_str[quality], line, col);
}

static void tick_bg_task() {
	// Map illustration info
	uint8_t const* const map_illustration = &menu_netplay_launch_illustration_map;
	static uint8_t const draw_order[] = {4, 3, 5, 2, 6, 1, 7, 0, 8, 9};
	uint8_t const N_LINES = 10;
	uint8_t const LINE_SIZE = 16;
	_Static_assert(sizeof(draw_order) == N_LINES, "bad draw_order size");
	uint16_t const map_illustration_screen_pos = 0x2248;

	// Logic
	struct TaskState* task = Task(netplay_launch_bg_task);
	switch (task->step) {

		//////////////////////////////////////////////////
		// Deactivated state: do nothing
		//////////////////////////////////////////////////

		case BG_STEP_DEACTIVATED:
			break;

		//////////////////////////////////////////////////
		// Initialization screen
		//////////////////////////////////////////////////

		// Hide the selection bar
		case BG_STEP_INIT_WIFI_SCREEN: {
			set_selection_bar_title(" initialize wifi");
			task->step = BG_STEP_DEACTIVATED;
			break;
		}

		//////////////////////////////////////////////////
		// Server selection screen
		//////////////////////////////////////////////////

		// Replace the selection bar
		case BG_STEP_MAP_SCREEN: {
			set_selection_bar_title("     server     ");
			++task->step;
			break;
		}

		// Prepare map drawing
		case BG_STEP_DRAW_MAP: {
			// Prepare NT buffer header
			netplay_launch_bg_mem_buffer[2] = LINE_SIZE;

			// Fall through to map drawing step
			task->count = 0;
			++task->step;
			__attribute__((fallthrough));
		}

		// Draw map
		case BG_STEP_DRAW_MAP_2: {
			for (uint8_t sub_step = 0; sub_step < 4; ++sub_step) {
				uint8_t const line_num = draw_order[task->count];
				uint16_t const ppu_addr = map_illustration_screen_pos + line_num * 32;

				// Draw line
				netplay_launch_bg_mem_buffer[0] = u16_msb(ppu_addr);
				netplay_launch_bg_mem_buffer[1] = u16_lsb(ppu_addr);
				wrap_fixed_memcpy(netplay_launch_bg_mem_buffer + 3, map_illustration + line_num * LINE_SIZE, LINE_SIZE);
				wrap_push_nt_buffer(netplay_launch_bg_mem_buffer);

				// Update task
				++task->count;
				if (task->count == N_LINES) {
					++task->step;
					break;
				}
			}
			break;
		}

		// Place server sprites
		case BG_STEP_DRAW_MAP_SERVERS: {
			for (uint8_t server_num = 0; server_num < *netplay_launch_nb_servers; ++server_num) {
				uint8_t const sprite_index = SERVER_SPRITES_BEGIN + server_num;
				uint8_t const sprite_offset = sprite_index * 4;
				oam_mirror[sprite_offset+0] = server_position_y[server_num];
				oam_mirror[sprite_offset+1] = server_tile();
				oam_mirror[sprite_offset+2] = 0;
				oam_mirror[sprite_offset+3] = server_position_x[server_num];
			}

			++task->step;
			__attribute__((fallthrough));
		}

		// Display currently selected server's name
		case BG_STEP_SHOW_SERVER: {
			uint16_t const ppu_add = 0x2208;
			netplay_launch_bg_mem_buffer[0] = u16_msb(ppu_add);
			netplay_launch_bg_mem_buffer[1] = u16_lsb(ppu_add);
			netplay_launch_bg_mem_buffer[2] = 16;
			for (uint8_t tile = 0; tile < 16; ++tile) {
				netplay_launch_bg_mem_buffer[3+tile] = alpha_tile(server_name[*netplay_launch_server][tile]);
			}
			wrap_push_nt_buffer(netplay_launch_bg_mem_buffer);
			task->step = BG_STEP_DEACTIVATED;
			break;
		}

		//////////////////////////////////////////////////
		// Connection and Matchmaking screen
		//////////////////////////////////////////////////

		// Clear title, and prepare screen drawing
		case BG_STEP_PING_SCREEN: {
			set_selection_bar_title("                ");
			set_line_text("   measuring    ", 2);
			set_line_text("    your ping   ", 3);
			task->count = 0;
			++task->step;
			break;
		}

		// Clear map from server selection
		case BG_STEP_PING_SCREEN_CLEAR: {
			// Clear sprites
			for (uint8_t sprite_num = 0; sprite_num < 64; ++sprite_num) {
				oam_mirror[sprite_num+0] = 0xfe;
			}

			// Clear map
			for (uint8_t sub_step = 0; sub_step < 4; ++sub_step) {
				// Draw line
				uint8_t const line_num = draw_order[task->count];
				set_line_tiles((uint8_t[]){0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}, 4+line_num);

				// Update task
				++task->count;
				if (task->count == N_LINES) {
					++task->step;
					break;
				}
			}
			break;
		}

		case BG_STEP_PING_SCREEN_DECORATE_LOCAL: {
			uint8_t const wifi = wifi_icon_tile();
			set_line_tiles((uint8_t[]){0,0,wifi+0,wifi+1,0,0,0,0,0,0,0,0,0,0,0,0}, 6);
			set_line_tiles((uint8_t[]){0,0,wifi+2,wifi+3,0,0,0,0,0,0,0,0,0,0,0,0}, 7);
			++task->step;
			break;
		}

		case BG_STEP_PING_SCREEN_DISPLAY_LOCAL: {
			display_ping(0, 6, 4);
			if (*netplay_launch_local_ping_count == NB_PINGS) {
				++task->step;
			}
			break;
		}

		case BG_STEP_PING_SCREEN_LOCAL_CONNECTION: {
			if (*netplay_launch_local_ping_quality == PING_QUALITY_UNKNOWN) {
				set_line_text("   connecting   ", 2);
				set_line_text("                ", 3);
				set_text("connecting", 7, 5);
			}else {
				set_line_text("   matchmaking  ", 2);
				display_ping_quality(*netplay_launch_local_ping_quality, 7, 4);
				++task->step;
			}
			break;
		}

		// Draw opponent connection's icon
		case BG_STEP_MATCHMAKING: {
			uint8_t const wifi = wifi_icon_tile();
			set_line_tiles((uint8_t[]){0,0,wifi+0,wifi+1,0,0,0,0,0,0,0,0,0,0,0,0}, 9);
			set_line_tiles((uint8_t[]){0,0,wifi+2,wifi+3,0,0,0,0,0,0,0,0,0,0,0,0}, 10);
			++task->step;
			break;
		}

		case BG_STEP_MATCHMAKING_STATUS: {
			if (*netplay_launch_rival_ping_count == 0) {
				set_text("searching", 9, 5);
				set_text("a rival", 10, 6);
			}else {
				set_text("         ", 9, 5);
				display_ping(1, 9, 4);
				display_ping_quality(*netplay_launch_rival_ping_quality, 10, 4);
				++task->step;
			}
			break;
		}

		case BG_STEP_COUNTDOWN: {
			if (*netplay_launch_countdown != COUNTDOWN_DEACTIVATED) {
				uint8_t const seconds_left = ((*netplay_launch_countdown + FADEOUT_DURATION) / (*system_index ? 50 : 60));
				set_text("start in ", 12, 3);

				// Write only one tile, no ease of use function for that, and not sure there will ever be another usage, so craft the buffer by hand
				uint8_t const line = 12;
				uint8_t const col = 13;
				uint16_t const ppu_addr = 0x21c8 + line * 32 + col;
				uint8_t const size = 1;
				netplay_launch_bg_mem_buffer[0] = u16_msb(ppu_addr);
				netplay_launch_bg_mem_buffer[1] = u16_lsb(ppu_addr);
				netplay_launch_bg_mem_buffer[2] = size;
				netplay_launch_bg_mem_buffer[3] = TILE_ZERO + seconds_left;
				wrap_push_nt_buffer(netplay_launch_bg_mem_buffer);
			}
			break;
		}

		//////////////////////////////////////////////////
		// Default handler: return to deactivated state
		//////////////////////////////////////////////////

		default:
			task->step = BG_STEP_DEACTIVATED;
			break;
	};
}

static void set_bg_state(uint8_t step) {
	Task(netplay_launch_bg_task)->step = step;
	Task(netplay_launch_bg_task)->count = 0;
}

static void back_on_b() {
	if (*controller_a_btns != *controller_a_last_frame_btns && *controller_a_last_frame_btns == CONTROLLER_BTN_B) {
		wrap_change_global_game_state_lite(GAME_STATE_STAGE_SELECTION, &init_stage_selection_screen);
	}
}

static void got_start_game_msg() {
	uint8_t const* msg = &esp_rx_buffer + ESP_MSG_PAYLOAD;

	// Set config as sent by the server
	*config_ai_level = 0;
	*config_selected_stage = msg[STNP_START_GAME_FIELD_STAGE];
	*config_initial_stocks = msg[STNP_START_GAME_FIELD_STOCK];
	*network_local_player_number = msg[STNP_START_GAME_FIELD_PLAYER_NUMBER];
	*config_player_a_character = msg[STNP_START_GAME_FIELD_PA_CHARACTER];
	*config_player_b_character = msg[STNP_START_GAME_FIELD_PB_CHARACTER];
	*config_player_a_character_palette = msg[STNP_START_GAME_FIELD_PA_PALETTE];
	*config_player_a_weapon_palette = *config_player_a_character_palette;
	*config_player_b_character_palette = msg[STNP_START_GAME_FIELD_PB_PALETTE];
	*config_player_b_weapon_palette = *config_player_b_character_palette;

	// Store opponent's connection info (for display)
	//TODO update STNP to have ping values
	*netplay_launch_rival_ping_quality = msg[STNP_START_GAME_FIELD_PLAYER_CONNECTIONS + *network_local_player_number];
	for (uint8_t ping_idx = 0; ping_idx < NB_PINGS; ++ping_idx) {
		netplay_launch_rival_ping_values[ping_idx] = PING_QUALITY_UNKNOWN;
	}
	*netplay_launch_rival_ping_count = NB_PINGS;

	// Wait some frames
	*netplay_launch_countdown = 200 - FADEOUT_DURATION;
	while (*netplay_launch_countdown > 0) {
		skip_frame();
		--*netplay_launch_countdown;
	}
	fade_out();

	// Go ingame
	wrap_change_global_game_state(GAME_STATE_INGAME);
}

static void got_disconnected_msg() {
	// Stop background processings, and write error title
	set_bg_state(BG_STEP_DEACTIVATED);
	skip_frame();
	back_on_b();
	set_selection_bar_title("  disconnected  ");

	// Write error message from server, one line per frame
	for (uint8_t line_num = 0; line_num < 12; ++line_num) {
		set_line_text((char*)(&esp_rx_buffer) + ESP_MSG_PAYLOAD + STNP_DISCONNECTED_FIELD_REASON + line_num * 16, 2+line_num);
		skip_frame();
		back_on_b();
	}

	// Set active task to disconnected
	Task(netplay_launch_fg_task)->step = ERROR_STATE_DISCONNECTED;
}

static void the_purge() {
	set_bg_state(BG_STEP_INIT_WIFI_SCREEN);
	wrap_esp_send_cmd(&esp_cmd_clear_buffers);
	esp_rx_message_acknowledge();
	++Task(netplay_launch_fg_task)->step;
}

static void connecting_wifi_query() {
	static uint8_t const cmd_get_wifi_status[] = {1, TOESP_MSG_WIFI_GET_STATUS};
	wrap_esp_send_cmd(cmd_get_wifi_status);
	++Task(netplay_launch_fg_task)->step;
}

static void connecting_wifi_wait() {
	if (esp_rx_message_ready()) {
		//TODO check message type, and just wait for the next if it is not a wifi status message (may happen if a message from login server took very long)

		// Read Wi-Fi status and adapt step accordingly
		switch((&esp_rx_buffer)[ESP_MSG_PAYLOAD]) {
			case ESP_WIFI_STATUS_IDLE_STATUS:
			case ESP_WIFI_STATUS_NO_SSID_AVAIL:
			case ESP_WIFI_STATUS_SCAN_COMPLETED:
				--Task(netplay_launch_fg_task)->step;
				break;

			case ESP_WIFI_STATUS_CONNECTED:
				++Task(netplay_launch_fg_task)->step;
				break;

			case ESP_WIFI_STATUS_CONNECT_FAILED:
			case ESP_WIFI_STATUS_CONNECTION_LOST:
			case ESP_WIFI_STATUS_DISCONNECTED:
				Task(netplay_launch_fg_task)->step = ERROR_STATE_NO_CONTACT;
				break;

			default:
				Task(netplay_launch_fg_task)->step = ERROR_STATE_CRAZY_MESSAGE;
				break;
		}

		// Acknowledge message reception
		esp_rx_message_acknowledge();
	}
}

static void select_server_query_settings() {
	set_selection_bar_title("read server conf"); //FIXME should find an acceptable way to put it in bg task (valable for other calls to set_selection_bar_title in fg tasks

	wrap_esp_send_cmd((uint8_t[]){1, TOESP_MSG_SERVER_GET_CONFIG_SETTINGS});
	++Task(netplay_launch_fg_task)->step;
}

static void select_server_draw() {
	// Wait for server settings
	if (esp_rx_message_ready()) {
		// Compute number of servers to display
		if ((&esp_rx_buffer)[ESP_MSG_SIZE] == 1) {
			*netplay_launch_nb_servers = NB_KNOWN_SERVERS;
			*netplay_launch_server = 0;
		}else {
			*netplay_launch_nb_servers = NB_KNOWN_SERVERS + 1;
			*netplay_launch_server = CUSTOM_SERVER_IDX;
		}

		// Acknowledge message reception
		esp_rx_message_acknowledge();

		// Draw map
		set_bg_state(BG_STEP_MAP_SCREEN);

		// Initialize selector animation
		wrap_animation_init_state(netplay_launch_cursor_anim, &menu_netplay_launch_selector_anim);
		Anim(netplay_launch_cursor_anim)->x = server_position_x[*netplay_launch_server];
		Anim(netplay_launch_cursor_anim)->y = server_position_y[*netplay_launch_server];
		Anim(netplay_launch_cursor_anim)->first_sprite_num = CURSOR_SPRITE;
		Anim(netplay_launch_cursor_anim)->last_sprite_num = CURSOR_SPRITE;

		// End task
		++Task(netplay_launch_fg_task)->step;
	}
}

static uint8_t servers_distance(uint8_t server_a, uint8_t server_b) {
	uint8_t const ax = server_position_x[server_a];
	uint8_t const bx = server_position_x[server_b];
	uint8_t const ay = server_position_y[server_a];
	uint8_t const by = server_position_y[server_b];
	uint8_t const dist_x = (ax < bx ? bx - ax : ax - bx);
	uint8_t const dist_y = (ay < by ? by - ay : ay - by);
	return dist_x + dist_y; // Goodenough ¯\_(ツ)_/¯
}

/** Returns the index of the nearest server, higher on selected axis */
static uint8_t next_server(uint8_t const* axis, bool inverted) {
	uint8_t const current_server_pos = (inverted ? 255 - axis[*netplay_launch_server] : axis[*netplay_launch_server]);

	uint8_t lower_server = 0;
	uint8_t lower_server_pos = (inverted ? 255 - axis[lower_server]: axis[lower_server]);
	uint8_t best_server = 255;
	uint8_t best_distance = 255;

	for (uint8_t server_num = 0; server_num < *netplay_launch_nb_servers; ++server_num) {
		uint8_t const server_pos = (inverted ? 255 - axis[server_num] : axis[server_num]);

		if (server_pos < lower_server_pos) {
			lower_server = server_num;
			lower_server_pos = server_pos;
		}

		uint8_t const current_distance = servers_distance(*netplay_launch_server, server_num);
		if (server_pos > current_server_pos && current_distance <= best_distance) {
			best_server = server_num;
			best_distance = current_distance;
		}
	}

	if (best_server != 255) {
		return best_server;
	}else {
		return lower_server;
	}
}

static void select_server() {
	// Handle inputs
	bool moved = false;
	uint8_t const controller_btns = controller_a_btns[0];
	uint8_t const last_frame_btns = controller_a_last_frame_btns[0];
	if (controller_btns != last_frame_btns) {
		switch (controller_btns) {
			case CONTROLLER_BTN_LEFT:
				audio_play_interface_click();
				moved = true;
				*netplay_launch_server = next_server(server_position_x, true);
				break;
			case CONTROLLER_BTN_RIGHT:
				audio_play_interface_click();
				moved = true;
				*netplay_launch_server = next_server(server_position_x, false);
				break;
			case CONTROLLER_BTN_UP:
				audio_play_interface_click();
				moved = true;
				*netplay_launch_server = next_server(server_position_y, true);
				break;
			case CONTROLLER_BTN_DOWN:
				audio_play_interface_click();
				moved = true;
				*netplay_launch_server = next_server(server_position_y, false);
				break;

			// Buttons that take effect on release
			case 0:
				switch (last_frame_btns){
					case CONTROLLER_BTN_A:
					case CONTROLLER_BTN_START:
						audio_play_interface_click();

						if (*netplay_launch_server == CUSTOM_SERVER_IDX) {
							wrap_esp_send_cmd((uint8_t[]){1, TOESP_MSG_SERVER_RESTORE_SETTINGS});
						}else {
							esp_set_server_settings(3000, server_host[*netplay_launch_server]);
						}
						wrap_esp_send_cmd(&esp_cmd_connect);

						++Task(netplay_launch_fg_task)->step;
						break;
				}
				break;

			default:
				break;
		}
	}

	// Update cursor position, and reset animation to force it to be on the visible frame
	if (moved) {
		wrap_animation_state_change_animation(netplay_launch_cursor_anim, &menu_netplay_launch_selector_anim);
		Anim(netplay_launch_cursor_anim)->x = server_position_x[*netplay_launch_server];
		Anim(netplay_launch_cursor_anim)->y = server_position_y[*netplay_launch_server];
		if (Task(netplay_launch_bg_task)->step == BG_STEP_SHOW_SERVER || Task(netplay_launch_bg_task)->step == BG_STEP_DEACTIVATED) {
			set_bg_state(BG_STEP_SHOW_SERVER);
		}
	}

	// Draw animations
	*player_number = 0;
	wrap_animation_draw(netplay_launch_cursor_anim);
	wrap_animation_tick(netplay_launch_cursor_anim);
}

static void estimate_latency_prepare() {
	set_bg_state(BG_STEP_PING_SCREEN);
	*netplay_launch_local_ping_count = 0;
	*netplay_launch_rival_ping_count = 0;
	*netplay_launch_local_ping_quality = PING_QUALITY_UNKNOWN;
	*netplay_launch_rival_ping_quality = PING_QUALITY_UNKNOWN;

	++Task(netplay_launch_fg_task)->step;
}

static void estimate_latency_request() {
	wrap_esp_send_cmd((uint8_t[]){2, TOESP_MSG_SERVER_PING, 1});
	++Task(netplay_launch_fg_task)->step;
}

static void estimate_latency_wait() {
	if (esp_rx_message_ready()) {
		// Read message
		if ((&esp_rx_buffer)[ESP_MSG_SIZE] != 5) {
			// Empty message means "unable to resolve host"
			Task(netplay_launch_fg_task)->step = ERROR_STATE_NO_CONTACT;
		}else {
			// Store ping information
			if ((&esp_rx_buffer)[ESP_MSG_PAYLOAD+3] != 0) {
				// Lost ping, store it as 255
				netplay_launch_local_ping_values[*netplay_launch_local_ping_count] = 255;
			}else {
				// Store max returned ping (we ask for only one anyway)
				netplay_launch_local_ping_values[*netplay_launch_local_ping_count] = (&esp_rx_buffer)[ESP_MSG_PAYLOAD+1];
			}
			++*netplay_launch_local_ping_count;
		}

		// Acknowledge message
		esp_rx_message_acknowledge();

		// Advance step
		++Task(netplay_launch_fg_task)->step;
		Task(netplay_launch_fg_task)->count = (*system_index ? 50 : 60);
	}
}

static void estimate_latency_next() {
	// Advance step if we have all pings, else wait a little and request a new ping
	if (*netplay_launch_local_ping_count == NB_PINGS) {
		++Task(netplay_launch_fg_task)->step;
	}else if (Task(netplay_launch_fg_task)->count != 0) {
		--Task(netplay_launch_fg_task)->count;
	}else {
		Task(netplay_launch_fg_task)->step -= 2;
	}
}

static bool outrageous_ping() {
	uint8_t const OUTRAGEOUS_PING = 800 / 4;

	//NOTE: lost pings are stored as 255 and will trigger "outrageous ping"
	for (uint8_t ping_idx = 0; ping_idx < *netplay_launch_local_ping_count; ++ping_idx) {
		if (netplay_launch_local_ping_values[ping_idx] > OUTRAGEOUS_PING) {
			return true;
		}
	}
	return false;
}

static void connection_prepare() {
	if (outrageous_ping()) {
		Task(netplay_launch_fg_task)->step = ERROR_STATE_BAD_PING;
		return;
	}

	*netplay_launch_countdown = COUNTDOWN_DEACTIVATED;

	++Task(netplay_launch_fg_task)->step;
}

static void connection_send_msg() {
	// Compute message info
	uint8_t ping_min = 255;
	uint8_t ping_max = 0;
	for (uint8_t ping_idx = 0; ping_idx < *netplay_launch_local_ping_count; ++ping_idx) {
		uint8_t ping_val = netplay_launch_local_ping_values[ping_idx];
		if (ping_val > ping_max) {
			ping_max = ping_val;
		}
		if (ping_val < ping_min) {
			ping_min = ping_val;
		}
	}

	// Send connection message
	esp_wait_tx();
	uint8_t * buff = &esp_tx_buffer;

	buff[0] = 31; // ESP header
	buff[1] = TOESP_MSG_SERVER_SEND_MESSAGE;

	buff[2] = STNP_CLI_MSG_TYPE_CONNECTION; // message_type
	buff[3] = *network_client_id_byte0; // client_id
	buff[4] = *network_client_id_byte1;
	buff[5] = *network_client_id_byte2;
	buff[6] = *network_client_id_byte3;
	buff[7] = ping_min; // min ping
	buff[8] = 5; // protocol_version
	buff[9] = ping_max; // max ping

	uint8_t flags_byte = (*system_index == 0 ? 0x00 : 0x80); // framerate
	flags_byte |= (RAINBOW_MAPPER_VERSION & 0x60); // support
	buff[10] = (flags_byte | u16_msb(GAME_VERSION)); // release_type + version_major
	buff[11] = u16_lsb(GAME_VERSION); // version_minor

	buff[12] = *config_player_a_character; // selected_character
	buff[13] = *config_player_a_character_palette; // selected_palette
	buff[14] = *config_selected_stage; // selected_stage

	buff[15] = *network_ranked; // ranked_play

	wrap_fixed_memcpy(buff+16, network_game_password, 16);

	esp_tx_message_send();

	// Next step - wait for a response
	Task(netplay_launch_fg_task)->count = NETPLAY_LAUNCH_REEMISSION_TIMER;
	++Task(netplay_launch_fg_task)->step;
}

static void connection_wait_msg() {
	// While no message received, wait a frame, or reemit connection message after some time
	if (!esp_rx_message_ready()) {
		--Task(netplay_launch_fg_task)->count;
		if (Task(netplay_launch_fg_task)->count == 0) {
			--Task(netplay_launch_fg_task)->step;
		}
		return;
	}

	// Not a message from server, go in error mode
	if ((&esp_rx_buffer)[ESP_MSG_TYPE] != FROMESP_MSG_MESSAGE_FROM_SERVER) {
		Task(netplay_launch_fg_task)->step = ERROR_STATE_CRAZY_MESSAGE;
		goto message_processed;
	}

	// Check STNP message type
	switch ((&esp_rx_buffer)[ESP_MSG_PAYLOAD+0]) {
		case STNP_SRV_MSG_TYPE_CONNECTED: {
			// Display connection quality
			//TODO update STNP to find the info in the packet
			*netplay_launch_local_ping_quality = 1;

			// Next step
			++Task(netplay_launch_fg_task)->step;
			break;
		}

		case STNP_SRV_MSG_TYPE_START_GAME:
			got_start_game_msg();
			break;

		case STNP_SRV_MSG_TYPE_DISCONNECTED:
			got_disconnected_msg();
			break;

		default:
			Task(netplay_launch_fg_task)->step = ERROR_STATE_CRAZY_MESSAGE;
			break;
	}

	// Acknowledge message reception
	message_processed:
	esp_rx_message_acknowledge();
}

static void wait_game() {
	// Actually come back to connection_wait_msg state which waits for
	//  - reemission time, we want it to keep the connection alive
	//  - connected message, we should not receive it (but nothing bad in handling it)
	//  - start game message, our job
	Task(netplay_launch_fg_task)->count = NETPLAY_LAUNCH_REEMISSION_TIMER;
	--Task(netplay_launch_fg_task)->step;
}

static void no_contact() {
	set_bg_state(BG_STEP_DEACTIVATED);
	skip_frame();
	back_on_b();
	set_selection_bar_title("error no contact");
}

static void bad_ping() {
	set_bg_state(BG_STEP_DEACTIVATED);
	skip_frame();
	back_on_b();
	set_selection_bar_title("error bad ping  ");
}

static void crazy_msg() {
	set_bg_state(BG_STEP_DEACTIVATED);
	skip_frame();
	back_on_b();
	set_selection_bar_title("error crazy msg ");
}

static void disconnected() {
	// Nothing to do, everything shall have been done by got_disconnected_message()
	// It is important as it draws text before changing FG task state, allowing to properly acknowledge the message.
}

static void tick_fg_task() {
	// State functions
	static void (*state_functions[])() = {
		the_purge,
		connecting_wifi_query, connecting_wifi_wait,
		select_server_query_settings, select_server_draw, select_server,
		estimate_latency_prepare, estimate_latency_request, estimate_latency_wait, estimate_latency_next,
		connection_prepare, connection_send_msg, connection_wait_msg,
		wait_game,
	};

	static void (*error_state_functions[])() = {
		no_contact, bad_ping, crazy_msg, disconnected
	};

	// Logic
	struct TaskState* task = Task(netplay_launch_fg_task);
	if (task->step < FIRST_ERROR_STATE) {
		(state_functions[task->step])();
	}else {
		(error_state_functions[task->step - FIRST_ERROR_STATE])();
	}
	back_on_b();
}

void init_netplay_launch_screen_extra() {
	// Init tasks
	set_bg_state(BG_STEP_DEACTIVATED);
	Task(netplay_launch_fg_task)->step = 0;
}

void netplay_launch_screen_tick_extra() {
	reset_nt_buffers();
	tick_bg_task(); // Passive task, like drawing things on the nametable
	tick_fg_task(); // Active task, controling what should happen and reacting to user inputs
}

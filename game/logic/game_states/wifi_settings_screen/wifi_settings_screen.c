#include <cstb.h>

///////////////////////////////////////
// C types for structured data
///////////////////////////////////////

typedef struct {
	uint8_t refresh_timer;
} __attribute__((__packed__)) WifiStatusCtx;

///////////////////////////////////////
// Allocated memory layout
///////////////////////////////////////

typedef struct {
	WifiStatusCtx wifi_status_ctx;
} __attribute__((__packed__)) StateVars;

typedef struct {
	uint8_t msg_buf[64];
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

extern uint8_t const CURRENT_BANK_NUMBER; // Actually an ASM macro, use its address or "code_bank()"
extern uint8_t const TILESET_ASCII_BANK_NUMBER; // Actually a label, use its address or "tileset_ascii_bank()"

extern uint8_t const tileset_ascii;

///////////////////////////////////////
// Screen specific ASM functions
///////////////////////////////////////

///////////////////////////////////////
// Screen specific ASM labels
///////////////////////////////////////

extern uint8_t const menu_wifi_settings_nametable;
extern uint8_t const menu_wifi_settings_palette;
extern uint8_t const tileset_menu_wifi_settings;

///////////////////////////////////////
// Constants specific to this file
///////////////////////////////////////

///////////////////////////////////////
// Utility functions
///////////////////////////////////////

#define COROUTINE_BEGIN uint16_t const coroutine_origin_line = __LINE__; switch (ctx->step) { case 0:
#define COROUTINE_END }
#define yield() ctx->step = (__LINE__ - coroutine_origin_line); return; case (__LINE__ - coroutine_origin_line):

static uint8_t tileset_ascii_bank() {
	return ptr_lsb(&TILESET_ASCII_BANK_NUMBER);
}

static uint8_t code_bank() {
	return ptr_lsb(&CURRENT_BANK_NUMBER);
}

//TODO Share code with menu_online_mode
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

///////////////////////////////////////
// State implementation
///////////////////////////////////////

#if 0
void audio_play_parry();
static void sound_effect_click() {
	audio_play_parry();
}
#endif

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

		static uint8_t const cmd_get_wifi_status[] = {1, TOESP_MSG_GET_WIFI_STATUS};
		wrap_esp_send_cmd(cmd_get_wifi_status);
	}
	++vars()->wifi_status_ctx.refresh_timer;
}

void init_wifi_settings_screen_extra() {
	// Draw static part of the screen
	wrap_construct_palettes_nt_buffer(&menu_wifi_settings_palette);
	wrap_draw_zipped_nametable(&menu_wifi_settings_nametable);
	wrap_cpu_to_ppu_copy_tileset(&tileset_menu_wifi_settings, 0x1000);
	long_cpu_to_ppu_copy_tileset(tileset_ascii_bank(), &tileset_ascii, 0x1200);

	// Init coroutines
	vars()->wifi_status_ctx.refresh_timer = 0;
}

void wifi_settings_screen_tick_extra() {
	reset_nt_buffers();

	// Get a message from ESP
	wrap_esp_get_msg(mem()->msg_buf);

	// Display wifi status
	display_wifi_status();
}

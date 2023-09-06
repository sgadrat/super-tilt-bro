#include <cstb.h>

// -----------------------------------
// Global labels from the ASM codebase
// -----------------------------------

extern uint8_t const charset_ascii;
extern uint8_t const tileset_update_segments;

void update_screen_prepare_flash_code();
void update_screen_flash_game();

// -----------------------------------------
// Access to labels containing useful values
// -----------------------------------------

extern uint8_t const CHARSET_ASCII_BANK_NUMBER;
static uint8_t charset_bank() {
	return ptr_lsb(&CHARSET_ASCII_BANK_NUMBER);
}

extern uint8_t const TILESET_UPDATE_SEGMENTS_BANK_NUMBER;
static uint8_t tileset_bank() {
	return ptr_lsb(&TILESET_UPDATE_SEGMENTS_BANK_NUMBER);
}

// -----------------------
// Constants for this file
// -----------------------

static uint8_t const sector_tile_none = 0;
static uint8_t const sector_tile_unchanged = 1;
#if 0
static uint8_t const sector_tile_erased = 2;
static uint8_t const sector_tile_writing = 3;
static uint8_t const sector_tile_ok = 4;
static uint8_t const sector_tile_error = 5;
#endif

//
// Vocabulary:
//  sector:     64 KB. A flash sector, the unit that can be erased at once
//  bank:       16 KB. A bank of the ROM (both bootcode and game use 16 KB banks)
//  segment:    1 KB.  The unit shown on screen while flashing
//  chunk:      256 B. A block encoded by huffmunch (rescue image's banks each contain an integer number of chunks)
//  flash page: 256 B. A page of the flash chip, unit that can be flashed in one go and provides ECC.
//  6502 page:  256 B. Incidentally the same as flash page, the code may hardcode it.

static uint16_t const bg_patterns = 0x0000;
static uint16_t const sprites_patterns = 0x0000;

static uint32_t const flash_rom_size = 524288; // 512 KB - Total size of the ROM to be flashed

static uint32_t const sector_size = 65536; // 64 KB - Size of a flash sector (we must erase by sector)
static uint8_t const first_game_sector = 1;

static uint16_t const bank_size = 16384; // 16 KB - Size of a bank in the ROM (game and bootcode both use 16 KB banks)

static uint16_t const segment_size = 1024; // 1 KB - Size of a segment shown in screen
static uint16_t const flash_nb_segments = flash_rom_size / segment_size;

static uint16_t const page_size = 256; // We program the flash page per page

// --------------
// Syntax helpers
// --------------

#define erase_sector_result (*update_screen_erase_sector_result)
#define log_position (*update_screen_log_position)
#define program_page_result_count (*update_screen_program_page_result_count)
#define program_page_result_flags (*update_screen_program_page_result_flags)
#define scroll_state (*update_screen_scroll_state)
#define txtx (*update_screen_txtx)
#define txty (*update_screen_txty)

// -----------------
// Utility functions
// -----------------

static uint8_t make_ppuctrl_val(bool nmi, bool sprites_8x16, bool bg_table_at_1000, bool sprites_table_at_1000, bool write_columns, uint8_t scroll_table) {
	bool const ppu_master = 0; // Force it to zero, 1 is to be used only with compatible device on extension port (and dangerous without)
	return
		((nmi?1:0) << 7) +
		((ppu_master?1:0) << 6) +
		((sprites_8x16?1:0) << 5) +
		((bg_table_at_1000?1:0) << 4) +
		((sprites_table_at_1000?1:0) << 3) +
		((write_columns?1:0) << 2) +
		scroll_table
	;
}

static uint8_t ppumask_val(bool emphasis_blue, bool emphasis_green, bool emphasis_red, bool show_sprites, bool show_bg, bool show_left_sprites, bool show_left_bg, bool greyscale) {
	return
		((emphasis_blue) << 7) +
		((emphasis_green) << 6) +
		((emphasis_red) << 5) +
		((show_sprites) << 4) +
		((show_bg) << 3) +
		((show_left_sprites) << 2) +
		((show_left_bg) << 1) +
		(greyscale?1:0)
	;
}

static void cpu_to_ppu(uint8_t const* cpu_data, uint16_t ppu_address, uint16_t count) {
	*PPUSTATUS;
	*PPUADDR = u16_msb(ppu_address);
	*PPUADDR = u16_lsb(ppu_address);
	while (count > 0) {
		*PPUDATA = *cpu_data;
		++cpu_data;
		--count;
	}
}

static void clear_nt(uint16_t address) {
	*PPUSTATUS;
	*PPUADDR = u16_msb(address);
	*PPUADDR = u16_lsb(address);
	for (uint16_t offset = 0; offset < 0x400; ++offset) {
		*PPUDATA = 0;
	}
}

// ---------------------
// Rescue implementation
// ---------------------

static uint8_t strlen8(char const* s) {
	uint8_t len = 0;
	while (s[len] != 0) {
		++len;
	}
	return len;
}

/**
 * Sets the scrolling registers from logical 16 bits values.
 *
 * Note: Don't wrap but produce weird positionment if camera is outside nametables
 */
static void scroll(uint16_t x, uint16_t y) {
	*PPUSTATUS;
	*PPUSCROLL = u16_lsb(x);
	*PPUSCROLL = (uint8_t)(y >= 240 ? y - 240 : y);

	uint8_t const ppuctrl = (*ppuctrl_val) & 0xfc; // 1111 1100 - set scroll bits to zero
	*PPUCTRL = ppuctrl | (y >= 240 ? 2 : 0) | (x >= 256 ? 1 : 0);
}

static void set_scroll(bool locked, uint16_t y) {
	scroll_state = ((locked?0x80:0x00) | (y / 8));
}

static uint16_t scroll_pos() {
	return ((uint16_t)(scroll_state & 0x7f)) * 8;
}

static void post_vbi() {
	fetch_controllers();

	bool const scroll_lock = (scroll_state & 0x80);
	if (!scroll_lock) {
		if (*controller_a_btns == CONTROLLER_BTN_UP) {
			set_scroll(false, 0);
		}else if (*controller_a_btns == CONTROLLER_BTN_DOWN) {
			set_scroll(false, 240);
		}
	}

	scroll(0, scroll_pos());
}

static void set_attribute(uint8_t nametable, uint8_t x, uint8_t y, uint8_t value) {
	uint16_t const nametable_ppu_addr = 0x2000 + (0x400 * nametable);
	uint16_t const attribute_addr = nametable_ppu_addr + 0x03c0 + (8 * (y / 2)) + (x / 2);
	uint8_t const attribute_index = (y%2)*2 + (x%2);
	uint8_t const attribute_mask = ~(3 << (attribute_index*2));
	uint8_t const attribute_value = value << (attribute_index*2);

	*PPUSTATUS;
	*PPUADDR = u16_msb(attribute_addr);
	*PPUADDR = u16_lsb(attribute_addr);
	*PPUDATA; // Did you know: reading PPUDATA updates a cache and return cached value, after seeking we must trash old cache value
	uint8_t const original_value = *PPUDATA;

	*PPUADDR = u16_msb(attribute_addr);
	*PPUADDR = u16_lsb(attribute_addr);
	*PPUDATA = (original_value & attribute_mask) | attribute_value;
}

static void print(char const* message, uint8_t col, uint8_t line) {
	uint8_t const len = strlen8(message);
	cpu_to_ppu((uint8_t const*)message, 0x2000 + line * 32 + col, len);
}

// Reprogram the flash memory, reading from an open file
void update_game() {
	// Check sizes match
	_Static_assert(flash_rom_size % sector_size == 0, "non integer number of sectors in the ROM");
	_Static_assert(flash_rom_size / sector_size < 256 - first_game_sector, "too many sectors to fit in uint8");

	_Static_assert(sector_size % bank_size == 0, "non integer number of banks in a sector");

	_Static_assert(flash_rom_size % segment_size == 0, "non integer number of segments in the ROM");
	_Static_assert(sector_size % segment_size == 0, "non integer number of segments in a sector");
	_Static_assert(bank_size % segment_size == 0, "non integer number of segments in a bank");

	_Static_assert(flash_rom_size % page_size == 0, "non integer number of pages in the ROM");
	_Static_assert(sector_size % page_size == 0, "non integer number of pages in a sector");
	_Static_assert(segment_size % page_size == 0, "non integer number of pages in a segment");

	// Prepare flash code
	update_screen_prepare_flash_code();

	// Initialize global variables
	log_position = 0;
	scroll_state = 0;

	// Stop sound engine
	audio_cut_sfx();
	audio_mute_music();

	// Disable NMI
	set_scroll(false, 0);
	wait_vbi();
	*ppuctrl_val = make_ppuctrl_val(false, false, bg_patterns == 0x1000, sprites_patterns == 0x1000, false, 0);
	*PPUCTRL = *ppuctrl_val;
	*PPUMASK = ppumask_val(false, false, false, false, false, true, true, false);
	post_vbi();

	// Clear nametables
	clear_nt(0x2000);
	clear_nt(0x2800);

	// Load tilesets
	long_cpu_to_ppu_copy_charset(charset_bank(), &charset_ascii, bg_patterns + 16 * ' ', 3, 1);
	long_cpu_to_ppu_copy_tileset(tileset_bank(), &tileset_update_segments, bg_patterns);

	// Write palete
	uint16_t const ppu_palettes = 0x3f00;
	*PPUSTATUS;
	*PPUADDR = u16_msb(ppu_palettes);
	*PPUADDR = u16_lsb(ppu_palettes);

	*PPUDATA = 0x21;
	*PPUDATA = 0x20;
	*PPUDATA = 0x29;
	*PPUDATA = 0x0f;

	*PPUDATA = 0x21;
	*PPUDATA = 0x21;
	*PPUDATA = 0x10;
	*PPUDATA = 0x0f;

	*PPUDATA = 0x21;
	*PPUDATA = 0x20;
	*PPUDATA = 0x10;
	*PPUDATA = 0x00;

	*PPUDATA = 0x21;
	*PPUDATA = 0x20;
	*PPUDATA = 0x10;
	*PPUDATA = 0x00;

	// Draw ROM visualisation frame
	uint8_t const frame_col = 3;
	uint8_t const frame_line = 3;
	uint8_t const frame_width = 26;
	uint8_t const frame_height = ((100 * flash_rom_size / segment_size / frame_width) + 99) / 100;

	print(".--------------------------.", frame_col-1, frame_line-1);
	for (uint8_t line = 0; line < frame_height; ++line) {
		print("|                          |", frame_col-1, frame_line+line);
	}
	print("`--------------------------'", frame_col-1, frame_line+frame_height);

	// Compute text position
	txtx = frame_col;
	txty = frame_line + frame_height + 1;

	// Set attributes
	{
		for (uint8_t x = 0; x < 16; ++x) {
			set_attribute(0, x, 0, 1);
		}
		for (uint8_t y = (frame_line + frame_height + 1) / 2; y < 15; ++y) {
			for (uint8_t x = 0; x < 16; ++x) {
				set_attribute(0, x, y, 1);
			}
		}

		uint16_t segment_index = 0;
		*PPUSTATUS;
		for (uint8_t line = 0; line < frame_height; ++line) {
			uint16_t const line_addr = 0x2000 + (frame_line + line) * 32 + frame_col;
			*PPUADDR = u16_msb(line_addr);
			*PPUADDR = u16_lsb(line_addr);
			for (uint8_t col = 0; col < frame_width; ++col) {
				*PPUDATA = (segment_index < flash_nb_segments ? sector_tile_unchanged : sector_tile_none);
				++segment_index;
			}
		}
	}

	// Enable display
	wait_vbi();
	*PPUMASK = ppumask_val(false, false, false, false, true, true, true, false);
	post_vbi();

	// Flash game region
	update_screen_flash_game();
}

#include <stdbool.h>
#include <stdint.h>

// -------------
// NES registers
// -------------

extern uint8_t volatile PPUADDR;
extern uint8_t volatile PPUCTRL;
extern uint8_t volatile PPUDATA;
extern uint8_t volatile PPUMASK;
extern uint8_t volatile PPUSCROLL;
extern uint8_t volatile PPUSTATUS;

// -----------------
// Rainbow registers
// -----------------

extern uint8_t volatile RAINBOW_CHR_CONTROL;
extern uint8_t volatile RAINBOW_PRG_BANK_8000_MODE_1_HI;
extern uint8_t volatile RAINBOW_PRG_BANK_8000_MODE_1_LO;
extern uint8_t volatile RAINBOW_PRG_BANK_C000_MODE_1_HI;
extern uint8_t volatile RAINBOW_PRG_BANK_C000_MODE_1_LO;
extern uint8_t volatile RAINBOW_PRG_BANKING_MODE;
extern uint8_t volatile RAINBOW_PULSE_CHANNEL_1_FREQ_HIGH;
extern uint8_t volatile RAINBOW_PULSE_CHANNEL_2_FREQ_HIGH;
extern uint8_t volatile RAINBOW_SAW_CHANNEL_FREQ_HIGH;
extern uint8_t volatile RAINBOW_WIFI_CONF;

// ------------------------
// Rainbow boot ROM symbols
// ------------------------

extern uint32_t crc32_value;
extern uint8_t* crc32_address;
extern uint8_t erase_sector_result;
extern uint8_t log_position;
extern uint8_t rescue_controller_a_btns;
extern uint8_t scroll_state;
extern uint8_t const tileset_rainbow_rescue;
extern uint8_t const tileset_rainbow_segments;
extern uint8_t txtx;
extern uint8_t txty;

void crc32_init();
void crc32_add_page();
void crc32_finalize();

void prepare_flash_code();
void erase_sector();

void rescue_fetch_controllers();

// -----------------------
// Constants for this file
// -----------------------

static uint8_t const sector_tile_none = 0;
static uint8_t const sector_tile_unchanged = 1;
static uint8_t const sector_tile_erased = 2;
static uint8_t const sector_tile_writing = 3;
static uint8_t const sector_tile_ok = 4;
static uint8_t const sector_tile_error = 5;

#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wunused-const-variable"
static uint8_t const btn_start = 0x10;
static uint8_t const btn_select = 0x20;
static uint8_t const btn_b = 0x40;
static uint8_t const btn_a = 0x80;
static uint8_t const btn_right = 0x01;
static uint8_t const btn_left = 0x02;
static uint8_t const btn_down = 0x04;
static uint8_t const btn_up = 0x08;
#pragma GCC diagnostic pop

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
static uint8_t const nb_sectors = flash_rom_size / sector_size;
static uint8_t const first_game_sector = 1;

static uint32_t const bank_size = 16384; // 16 KB - Size of a bank in the ROM (game and bootcode both use 16 KB banks)

static uint32_t const segment_size = 1024; // 1 KB - Size of a segment shown in screen
static uint32_t const flash_nb_segments = flash_rom_size / segment_size;

static uint32_t const page_size = 256; // We program the flash page per page
static uint32_t const nb_pages = flash_rom_size / page_size;
static uint8_t const nb_pages_per_segment = segment_size / page_size;

// -----------------------
// Syntax helper functions
// -----------------------

static uint8_t u16_lsb(uint16_t val) {
	return ((int)val) & 0x00ff;
}

static uint8_t u16_msb(uint16_t val) {
	return (((int)val) >> 8) & 0x00ff;
}

static uint8_t ptr_lsb(void const* ptr) {
	return u16_lsb((uint16_t)ptr);
}

#if 0
static uint8_t ptr_msb(void const* ptr) {
	return u16_msb((uint16_t)ptr);
}
#endif

// -----------------------------------------
// Access to labels containing useful values
// -----------------------------------------

extern uint8_t const TILESET_RAINBOW_RESCUE_BANK_NUMBER;
static uint8_t charset_bank() {
	return ptr_lsb(&TILESET_RAINBOW_RESCUE_BANK_NUMBER);
}

extern uint8_t const TILESET_RAINBOW_SEGMENTS_BANK_NUMBER;
static uint8_t tileset_segments_bank() {
	return ptr_lsb(&TILESET_RAINBOW_SEGMENTS_BANK_NUMBER);
}

// -----------------
// Utility functions
// -----------------

static void wait_vbi() {
	asm(
		"bit PPUSTATUS\n\t"
		"vblankwait:\n\t"
		"bit PPUSTATUS\n\t"
		"bpl vblankwait\n\t"
	);
}

static uint8_t ppuctrl_val(bool nmi, bool sprites_8x16, bool bg_table_at_1000, bool sprites_table_at_1000, bool write_columns, uint8_t scroll_table) {
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
	PPUSTATUS;
	PPUADDR = u16_msb(ppu_address);
	PPUADDR = u16_lsb(ppu_address);
	while (count > 0) {
		PPUDATA = *cpu_data;
		++cpu_data;
		--count;
	}
}

static void clear_nt(uint16_t address) {
	PPUSTATUS;
	PPUADDR = u16_msb(address);
	PPUADDR = u16_lsb(address);
	for (uint16_t offset = 0; offset < 0x400; ++offset) {
		PPUDATA = 0;
	}
}

static void switch_bank(uint8_t bank_number) {
	RAINBOW_PRG_BANK_8000_MODE_1_LO = bank_number;
}

// ---------------------
// Rescue implementation
// ---------------------

static void warmup() {
	// Wait a two vblank to make sure PPU is ready
	wait_vbi();
	wait_vbi();
}

static void rainbow_mapper_init() {
	// Disable ESP
	RAINBOW_WIFI_CONF = 0;

	// Set PRG ROM banking
	const uint8_t RAINBOW_FIXED_BANK_NUMBER = 1;
	RAINBOW_PRG_BANK_C000_MODE_1_HI = 0; // CUUUUUUU - PRG-ROM, fixed bank
	RAINBOW_PRG_BANK_C000_MODE_1_LO = RAINBOW_FIXED_BANK_NUMBER; // LLLLLLLL - fixed bank
	RAINBOW_PRG_BANKING_MODE = 1; // A....OOO - PRG-RAM 8K, PRG-ROM 16K+16K

	RAINBOW_PRG_BANK_8000_MODE_1_HI = 0; // CUUUUUUU - PRG-ROM, first bank
	RAINBOW_PRG_BANK_8000_MODE_1_LO = 0; // LLLLLLLL - first bank

    // Set CHR-RAM
	RAINBOW_CHR_CONTROL = 0x40; // CCE..BBB - CHR-RAM, Disable Sprite extension, 8K CHR banking

	// Select CHR bank
    //  Disabled - matches reset value of the register, and ultimately we don't care we are not using CHR RAM banking
    //lda #0
    //sta RAINBOW_CHR_BANKING_1_HI
    //sta RAINBOW_CHR_BANKING_1_LO

    // Set Horizontal mirroring
    // Nothing, reset values are fine

	// Disable sound extension
	RAINBOW_PULSE_CHANNEL_1_FREQ_HIGH = 0;
	RAINBOW_PULSE_CHANNEL_2_FREQ_HIGH = 0;
	RAINBOW_SAW_CHANNEL_FREQ_HIGH = 0;
}

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
	PPUSTATUS;
	PPUSCROLL = u16_lsb(x);
	PPUSCROLL = 0; //(y >= 240 ? y - 240 : y);

	uint8_t const ppuctrl = PPUCTRL & 0xfc; // 1111 1100 - set scroll bits to zero
	PPUCTRL = ppuctrl | (y >= 240 ? 2 : 0) | (x >= 256 ? 1 : 0);
}

static void post_vbi() {
	rescue_fetch_controllers();
	if (rescue_controller_a_btns == btn_up) {
		scroll_state = 0;
	}else if (rescue_controller_a_btns == btn_down) {
		scroll_state = 1;
	}
	scroll(0, scroll_state ? 240 : 0);
}

static void set_attribute(uint8_t nametable, uint8_t x, uint8_t y, uint8_t value) {
	uint16_t const nametable_ppu_addr = 0x2000 + (0x400 * nametable);
	uint16_t const attribute_addr = nametable_ppu_addr + 0x03c0 + (8 * (y / 2)) + (x / 2);
	uint8_t const attribute_index = (y%2)*2 + (x%2);
	uint8_t const attribute_mask = ~(3 << (attribute_index*2));
	uint8_t const attribute_value = value << (attribute_index*2);

	PPUSTATUS;
	PPUADDR = u16_msb(attribute_addr);
	PPUADDR = u16_lsb(attribute_addr);
	PPUDATA; // Did you know: reading PPUDATA updates a cache and return cached value, after seeking we must trash old cache value
	uint8_t const original_value = PPUDATA;

	PPUADDR = u16_msb(attribute_addr);
	PPUADDR = u16_lsb(attribute_addr);
	PPUDATA = (original_value & attribute_mask) | attribute_value;
}

static void print(char const* message, uint8_t col, uint8_t line) {
	uint8_t const len = strlen8(message);
	cpu_to_ppu((uint8_t const*)message, 0x2000 + line * 32 + col, len);
}

static void say(char const* message) {
	wait_vbi();
	print(message, txtx, txty);
	post_vbi();
}

static void error_log(char const* message) {
	uint8_t const len = strlen8(message);
	uint8_t const col = 2;
	uint8_t const line = 3 + log_position;
	log_position += 1;
	if (log_position > 24) {
		log_position = 0;
	}

	wait_vbi();
	cpu_to_ppu((uint8_t const*)message, 0x2800 + line * 32 + col, len);
	post_vbi();
}

static char hex_digit(uint8_t value) {
	if (value < 10) {
		return '0' + value;
	}
	return 'a' - 10 + value;
}

static char* uint_to_hex32(char* dest, uint32_t value) {
	*(dest++) = hex_digit((value >> 28) & 0x0000000f);
	*(dest++) = hex_digit((value >> 24) & 0x0000000f);
	*(dest++) = hex_digit((value >> 20) & 0x0000000f);
	*(dest++) = hex_digit((value >> 16) & 0x0000000f);
	*(dest++) = hex_digit((value >> 12) & 0x0000000f);
	*(dest++) = hex_digit((value >> 8) & 0x0000000f);
	*(dest++) = hex_digit((value >> 4) & 0x0000000f);
	*(dest++) = hex_digit((value >> 0) & 0x0000000f);
	return dest;
}

static char* uint_to_hex8(char* dest, uint8_t value) {
	*(dest++) = hex_digit((value >> 4) & 0x0000000f);
	*(dest++) = hex_digit((value >> 0) & 0x0000000f);
	return dest;
}

static char* uint_to_str(char* dest, uint32_t value) {
	bool print = false;

	uint32_t v;

#define P(u) do { \
	v = 0; \
	while (value >= u) { \
		value -= u; \
		++v; \
	} \
	if (v != 0 || print) { \
		*dest = '0' + v; \
		++dest; \
		print = true; \
	} \
}while(0)

	P(10000);
	P(1000);
	P(100);
	P(10);
	*dest = '0' + value;
	return dest+1;
}

static char* strcpy8(char* dest, char const* src) {
	while (*src != 0) {
		*dest = *src;
		++dest;
		++src;
	}
	return dest;
}

static void progress(char* dest, char const* prefix, uint32_t value, char const* link, uint32_t max, uint8_t fill) {
	char* const end = dest + fill;
	dest = strcpy8(dest, prefix);
	dest = uint_to_str(dest, value);
	dest = strcpy8(dest, link);
	dest = uint_to_str(dest, max);
	while (dest < end) {
		*dest = ' ';
		++dest;
	}
	*dest = 0;
}

static void erase_game_sector(uint8_t sector_index) {
	uint8_t const rainbow_sector_index = first_game_sector + sector_index;
	uint8_t const banks_per_sector = sector_size / bank_size;
	uint8_t const bank_index = rainbow_sector_index * banks_per_sector;

	switch_bank(bank_index);
	erase_sector();

	if (erase_sector_result == 0) {
		return;
	}

	bool const fatal = (erase_sector_result & 0x80);

	char msg[25];
	char* dest = msg;
	dest = strcpy8(dest, "erase "); // 6
	dest = uint_to_hex8(dest, sector_index); // 6+2=8
	dest = strcpy8(dest, " fail="); // 8+6=14
	dest = uint_to_hex8(dest, erase_sector_result); // 14+2=16
	if (fatal) {
		dest = strcpy8(dest, " chip=KO"); // 16+8=24
	}
	*dest = 0; //24+1=25

	error_log(msg);
	say(msg);

	if (fatal) {
		// Tell the user it failed badly
		wait_vbi();
		print("FATAL ERROR.", txtx, txty+1);
		post_vbi();

		wait_vbi();
		print("Please shutdown, and retry.", txtx, txty+2);
		post_vbi();

		// Wait for the system being reboot, or the user to press the secret key combinaison to try to ignore the error
		while(true) {
			wait_vbi();
			post_vbi();
			if (rescue_controller_a_btns == (btn_select|btn_b)) { // Secret is SELECT+B
				break;
			}
		}

		// Clear our error messages
		wait_vbi();
		print("            ", txtx, txty+1);
		post_vbi();

		wait_vbi();
		print("                           ", txtx, txty+2);
		post_vbi();

		// Let a mark of ignoring error
		dest = msg;
		dest = strcpy8(dest, "Ignored erase fail "); //19
		dest = uint_to_hex8(dest, sector_index); //19+2=21
		*dest = 0; //21+1=22
		wait_vbi();
		print(msg, txtx, txty+3);
	}
}

static void program_page(uint32_t page_index) {
	//TODO
	(void)page_index;
}

static bool check_segment(uint32_t segment_index) {
	uint32_t const rainbow_segment_index = segment_index + first_game_sector * (sector_size / segment_size);
	uint32_t const segments_per_bank = bank_size / segment_size;
	uint8_t const bank_index = rainbow_segment_index / segments_per_bank;
	uint8_t* const segment_addr = (uint8_t*)0x8000 + (rainbow_segment_index % segments_per_bank) * segment_size;

	// Compute page's CRC-32
#if 0
	//Preferable, but needs a fix for https://github.com/itszor/gcc-6502/issues/10
	switch_bank(bank_index);
	crc32_init();
	crc32_address = segment_addr;
	for (uint8_t page = 0; page < nb_pages_per_segment; ++page) {
		crc32_add_page();
		crc32_address += page_size;
	}
	crc32_finalize();
#else
	switch_bank(bank_index);
	crc32_init();
	for (uint8_t page = 0; page < nb_pages_per_segment; ++page) {
		crc32_address = segment_addr + ((uint16_t)page * page_size);
		crc32_add_page();
	}
	crc32_finalize();
#endif

	// Load reference CRC value
	uint8_t const rescue_img_index_bank = 63;
	uint32_t const* const reference_crc_table = (uint32_t const*)0x8000;
	switch_bank(rescue_img_index_bank);
	uint32_t const reference_crc = reference_crc_table[segment_index];

	// Check match
	if (crc32_value == reference_crc) {
		return true;
	}

	// Log error details
	char msg[27];

	char* dest = msg;
	dest = strcpy8(dest, "CRC "); // 4
	dest = uint_to_str(dest, segment_index); //4+3=7
	*(dest++) = ' '; //7+1=8
	dest = uint_to_hex32(dest, crc32_value); // 8+8=16
	*(dest++) = '!'; //16+1=17
	*(dest++) = '='; //17+1=18
	dest = uint_to_hex32(dest, reference_crc); // 18+8 = 26
	*dest = 0; //16+1=27
	error_log(msg);

	dest = msg;
	dest = strcpy8(dest, "  bank "); // 7
	dest = uint_to_str(dest, bank_index); //7+2=9
	dest = strcpy8(dest, " addr "); //9+6=15
	dest = uint_to_hex32(dest, (uint16_t)segment_addr); //15+8=23
	*dest = 0; // 23+1=24
	error_log(msg);

	return false;
}

void rainbow_rescue() {
	// Reprogram the flash memory with rescue image (while printing fancy things on screen)

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

	// Wait for the system to be fully usable
	warmup();

	// Initialize mapper state
	rainbow_mapper_init();

	// Initialize global variables
	log_position = 0;
	scroll_state = 0;

	// Clear nametables
	clear_nt(0x2000);
	clear_nt(0x2800);

	// Load tilesets
	{
		switch_bank(charset_bank());
		uint16_t const num_chars = 96; //tileset_rainbow_rescue;
		cpu_to_ppu((&tileset_rainbow_rescue)+1, bg_patterns + 16 * ' ', num_chars * 16);

		switch_bank(tileset_segments_bank());
		uint16_t const size = tileset_rainbow_segments;
		cpu_to_ppu((&tileset_rainbow_segments)+1, bg_patterns, size * 16);
	}

	// Write palete
	uint16_t const ppu_palettes = 0x3f00;
	PPUSTATUS;
	PPUADDR = u16_msb(ppu_palettes);
	PPUADDR = u16_lsb(ppu_palettes);

	PPUDATA = 0x21;
	PPUDATA = 0x20;
	PPUDATA = 0x29;
	PPUDATA = 0x0f;

	PPUDATA = 0x21;
	PPUDATA = 0x21;
	PPUDATA = 0x10;
	PPUDATA = 0x0f;

	PPUDATA = 0x21;
	PPUDATA = 0x20;
	PPUDATA = 0x10;
	PPUDATA = 0x00;

	PPUDATA = 0x21;
	PPUDATA = 0x20;
	PPUDATA = 0x10;
	PPUDATA = 0x00;

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
		PPUSTATUS;
		for (uint8_t line = 0; line < frame_height; ++line) {
			uint16_t const line_addr = 0x2000 + (frame_line + line) * 32 + frame_col;
			PPUADDR = u16_msb(line_addr);
			PPUADDR = u16_lsb(line_addr);
			for (uint8_t col = 0; col < frame_width; ++col) {
				PPUDATA = (segment_index < flash_nb_segments ? sector_tile_unchanged : sector_tile_none);
				++segment_index;
			}
		}
	}

	// Reactivate display
	wait_vbi();
	PPUCTRL = ppuctrl_val(false, false, bg_patterns == 0x1000, sprites_patterns == 0x1000, false, 0);
	PPUMASK = ppumask_val(false, false, false, false, true, true, true, false);
	post_vbi();

	// Add an entry in error log to explain what it is
	error_log("Error journal:");
	error_log("");

	// Prepare flash code
	prepare_flash_code();

	// Flash all sectors
	char msg[frame_width+1];
	uint32_t page_index = 0;
	uint16_t segment_index = 0;
	uint16_t nb_errors = 0;
	for (uint8_t sector_index = 0; sector_index < nb_sectors; ++sector_index) {
		// Erase sector
		progress(msg, "Erase sector ", sector_index+1, " / ", nb_sectors, frame_width);
		say(msg);

		erase_game_sector(sector_index);

		// Update visualization frame
		uint16_t erased_segment_index = segment_index;
		uint32_t const sector_segments_end = segment_index + (sector_size / segment_size);
		while (erased_segment_index < sector_segments_end) {
			uint16_t const frame_ppu_addr = 0x2000 + frame_line * 32 + frame_col;
			uint16_t const segment_ppu_addr = frame_ppu_addr + (erased_segment_index / frame_width) * 32 + erased_segment_index % frame_width;
			wait_vbi();
			PPUSTATUS;
			PPUADDR = u16_msb(segment_ppu_addr);
			PPUADDR = u16_lsb(segment_ppu_addr);
			PPUDATA = sector_tile_erased;
			post_vbi();
			++erased_segment_index;
		}

		// Display segments
		while (segment_index < sector_segments_end) {
			// Display programing segment
			uint16_t const frame_ppu_addr = 0x2000 + frame_line * 32 + frame_col;
			uint16_t const segment_ppu_addr = frame_ppu_addr + (segment_index / frame_width) * 32 + segment_index % frame_width;
			wait_vbi();
			PPUSTATUS;
			PPUADDR = u16_msb(segment_ppu_addr);
			PPUADDR = u16_lsb(segment_ppu_addr);
			PPUDATA = sector_tile_writing;
			post_vbi();

			// Program pages
			uint32_t const segment_pages_end = page_index + (segment_size / page_size);
			while (page_index < segment_pages_end) {
				progress(msg, "Write page ", page_index+1, " / ", nb_pages, frame_width);
				say(msg);

				program_page(page_index);
				++page_index;
			}

			bool const success = check_segment(segment_index);
			if (!success) {
				++nb_errors;
			}

			// Display programmed segment
			wait_vbi();
			PPUSTATUS;
			PPUADDR = u16_msb(segment_ppu_addr);
			PPUADDR = u16_lsb(segment_ppu_addr);
			PPUDATA = success ? sector_tile_ok : sector_tile_error;
			post_vbi();

			// Next
			++segment_index;
		}
	}

	// Display end message
	for (uint8_t i = 0; i < frame_width; ++i) {
		msg[i] = ' ';
	}
	msg[frame_width] = 0;
	say(msg);

	if (nb_errors == 0) {
		wait_vbi();
		print("Success", txtx, txty);
		print("You can reboot now", txtx, txty+1);
		post_vbi();
	}else {
		char* dest = msg;
		dest = uint_to_str(dest, nb_errors);
		dest = strcpy8(dest, " verification fails");
		*dest = 0;

		wait_vbi();
		print("Error", txtx, txty);
		print(msg, txtx, txty+1);
		post_vbi();
	}

	// Loop endlessely
	while (true) {
		wait_vbi();
		post_vbi();
	}
}

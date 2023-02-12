#include <cstb.h>

///////////////////////////////////////
// Global labels from the ASM codebase
///////////////////////////////////////

extern uint8_t const charset_ascii;
extern uint8_t const menu_credits_bubble_anim;
extern uint8_t const menu_credits_cursor_anim;
extern uint8_t const menu_credits_nametable;
extern uint8_t const menu_credits_pages_illustration_lsb;
extern uint8_t const menu_credits_pages_illustration_msb;
extern uint8_t const menu_credits_pages_illustration_bank;
extern uint8_t const menu_credits_pages_text_lsb;
extern uint8_t const menu_credits_pages_text_msb;
extern uint8_t const menu_credits_palette;
extern uint8_t const menu_credits_sprites_tileset;
extern uint8_t const menu_credits_tileset;

// Labels, use their address or the associtated *_bank() function
extern uint8_t const CHARSET_ASCII_BANK_NUMBER;
extern uint8_t const MENU_CREDITS_ANIMS_BANK;
extern uint8_t const MENU_CREDITS_CREDITS_BANK;
extern uint8_t const MENU_CREDITS_SCREEN_BANK;
extern uint8_t const MENU_CREDITS_TILESET_BANK;

extern uint8_t const MENU_CREDITS_NB_PAGES;
extern uint8_t const MENU_CREDITS_NAVIGATION_DOT;
extern uint8_t const TILE_MENU_CREDITS_BUBBLE;

///////////////////////////////////////
// Constants specific to this file
///////////////////////////////////////

// Bubbles related constants
const uint8_t n_bubbles = 4;
const uint8_t bubbles_first_sprite = 1;
const uint8_t bubble_anim_n_sprites = 3;
Animation* const bubble_anims = (Animation*)credits_bubble_anims;

///////////////////////////////////////
// Utility functions
///////////////////////////////////////

static void tick_animations();

// Nametable's attribute byte
#define ATT(br, bl, tr, tl) ((br << 6) + (bl << 4) + (tr << 2) + tl)

static uint8_t anims_bank() {
	return ptr_lsb(&MENU_CREDITS_ANIMS_BANK);
}

static uint8_t charset_bank() {
	return ptr_lsb(&CHARSET_ASCII_BANK_NUMBER);
}

static uint8_t credits_bank() {
	return ptr_lsb(&MENU_CREDITS_CREDITS_BANK);
}

static uint8_t nb_pages() {
	return ptr_lsb(&MENU_CREDITS_NB_PAGES);
}

static uint8_t screen_bank() {
	return ptr_lsb(&MENU_CREDITS_SCREEN_BANK);
}

static uint8_t tileset_bank() {
	return ptr_lsb(&MENU_CREDITS_TILESET_BANK);
}

/** Not a real yield, pass a frame "as if" it gone through main loop */
static void yield() {
	wrap_trampoline(code_bank(), code_bank(), &sleep_frame);
	fetch_controllers();
	tick_animations();
}

///////////////////////////////////////
// State implementation
///////////////////////////////////////

static void change_page() {
	// Play SFX
	audio_play_interface_click();

	// Mark displayed page as dirty
	*credits_page_dirty = 1;

	// Place cursor
	Anim(credits_cursor_anim)->x = (128 - 8 * (nb_pages() / 2)) + 8 * *credits_current_page;
}

static void previous_page() {
	// Select previous page
	if (*credits_current_page == 0) {
		*credits_current_page = nb_pages() - 1;
	}else {
		--*credits_current_page;
	}

	// Apply change
	change_page();
}

static void next_page() {
	// Select next page
	++*credits_current_page;
	if (*credits_current_page >= nb_pages()) {
		*credits_current_page = 0;
	}

	// Apply change
	change_page();
}

static void previous_screen() {
	audio_play_interface_click();
	reset_bg_color();
	wrap_change_global_game_state(GAME_STATE_MODE_SELECTION);
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
					previous_page();
					break;
				case CONTROLLER_BTN_DOWN:
				case CONTROLLER_BTN_RIGHT:
				case CONTROLLER_BTN_START:
				case CONTROLLER_BTN_A:
					had_input = 1;
					next_page();
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

static void forget_last_illustration() {
	*credits_last_illustration_bank = 0xff;
	*credits_last_illustration_msb = 0xff;
	*credits_last_illustration_lsb = 0xff;
}

static uint8_t is_last_illustration(uint8_t const* illustration, uint8_t illustration_bank) {
	return
		illustration == ptr(*credits_last_illustration_lsb, *credits_last_illustration_msb) &&
		illustration_bank == *credits_last_illustration_bank
	;
}

static void reset_bubble(uint8_t bubble_num, uint16_t x, uint16_t y) {
	Animation* anim = &(bubble_anims[bubble_num]);
	wrap_animation_init_state((uint8_t*)anim, &menu_credits_bubble_anim);
	anim->y = y;
	anim->x = x;
	anim->first_sprite_num = bubbles_first_sprite + (bubble_num * bubble_anim_n_sprites);
	anim->last_sprite_num = anim->first_sprite_num + bubble_anim_n_sprites - 1;
}

static void show_current_page() {
	// Text related constants
	uint8_t const line_size = 16;
	uint8_t const n_lines = 13;

	uint8_t const* text = ptr((&menu_credits_pages_text_lsb)[*credits_current_page], (&menu_credits_pages_text_msb)[*credits_current_page]); //FIXME bug if table is in another bank

	// Illustration related constants
	uint8_t const n_tiles = 90;
	uint8_t const tile_size = 16;
	uint8_t const tiles_per_chunk = 3;
	uint8_t const chunks_per_line = 3;
	uint8_t const tiles_per_line = chunks_per_line * tiles_per_chunk;
	uint8_t const chunk_size = tiles_per_chunk * tile_size;
	uint8_t const n_chunks = n_tiles / tiles_per_chunk;
	uint8_t const illustration_n_lines = (n_chunks + chunks_per_line - 1) / chunks_per_line;

	uint8_t const* const illustration = ptr((&menu_credits_pages_illustration_lsb)[*credits_current_page], (&menu_credits_pages_illustration_msb)[*credits_current_page]); //FIXME bug if table is in another bank
	uint8_t const illustration_bank = (&menu_credits_pages_illustration_bank)[*credits_current_page];
	uint8_t const illustration_screen_pos_col = 4;
	uint8_t const illustration_screen_pos_line = 11;
	uint8_t const illustration_screen_pos_x = illustration_screen_pos_col * 8;
	uint8_t const illustration_screen_pos_y = illustration_screen_pos_line * 8;
	uint16_t const illustration_screen_pos = 0x2000 + illustration_screen_pos_line * 32 + illustration_screen_pos_col;

	// Order in which tiles chunks are drawn
	static uint8_t const chunks_order[] = {
		16, 20, 17, 15, 19, 13, 10, 12, 14,
		18, 11,  9, 23,  7, 21,  6,  8, 25,
		22,  3, 26,  5,  1, 24,  4, 28,  0,
		27,  2, 29,
	};
	_Static_assert(sizeof(chunks_order) == n_chunks, "Chunks order table mismatch number of chunks");

	// Order in which nametable attributes are updated
	//  NOTE - Animated independently of chunks drawing
	uint8_t const attributes_delay = 6; // Start animating attributes n steps after chunks

	static uint8_t const attributes_order_bytes[] = {
		// Center attributes
		0xd9, 0xe2, 0xe1, 0xda,
		0xd9, 0xe2, 0xe1, 0xda, 0xdb, 0xe3,
		0xd9, 0xe2, 0xe1, 0xda,
		0xd9, 0xe2, 0xe1, 0xda, 0xdb, 0xe3,

		// Bottom/top attributes
		0xd1, 0xea, 0xe9, 0xd2,
		0xd1, 0xea, 0xe9, 0xd2, 0xd3, 0xeb,
		0xd1, 0xea, 0xe9, 0xd2,
		0xd1, 0xea, 0xe9, 0xd2, 0xd3, 0xeb,
	};

	static uint8_t const attributes_order_bits[] = {
		// Center attributes
		ATT(2,1,1,1), ATT(1,1,1,2), ATT(1,1,2,1), ATT(1,2,1,1),
		ATT(2,2,1,1), ATT(1,1,2,2), ATT(1,1,2,2), ATT(2,2,1,1), ATT(0,2,0,1), ATT(0,1,0,2),
		ATT(2,2,2,1), ATT(1,2,2,2), ATT(1,2,2,2), ATT(2,2,1,2),
		ATT(2,2,2,2), ATT(2,2,2,2), ATT(2,2,2,2), ATT(2,2,2,2), ATT(0,2,0,2), ATT(0,2,0,2),

		// Bottom/top attributes
		ATT(2,1,1,1), ATT(1,1,1,2), ATT(1,1,2,1), ATT(1,2,1,1),
		ATT(2,2,1,1), ATT(1,1,2,2), ATT(1,1,2,2), ATT(2,2,1,1), ATT(0,2,0,1), ATT(0,1,0,2),
		ATT(2,2,2,1), ATT(1,2,2,2), ATT(1,2,2,2), ATT(2,2,1,2),
		ATT(2,2,2,2), ATT(2,2,2,2), ATT(2,2,2,2), ATT(2,2,2,2), ATT(0,2,0,2), ATT(0,2,0,2),
	};

	// Init all bubbles offscreen
	for (uint8_t bubble_num = 0; bubble_num < n_bubbles; ++bubble_num) {
		reset_bubble(bubble_num, 0, 0x01ff);
	}

	// Prepare illustration's screen region
	if (!is_last_illustration(illustration, illustration_bank)) {
		// Ensure we will not consider dirty illustration as the drawn one
		forget_last_illustration();

		// Clear illustration
		uint8_t const n_illustration_lines_per_step = 5;
		credits_mem_buffer[2] = tiles_per_line;
		for (uint8_t tile_num = 0; tile_num < tiles_per_line; ++tile_num) {
			credits_mem_buffer[3+tile_num] = ' ';
		}
		for (uint8_t first_line = 0; first_line < illustration_n_lines; first_line += n_illustration_lines_per_step) {
			// Construct nt buffers
			for (uint8_t line_num = first_line; line_num < first_line + n_illustration_lines_per_step && line_num < illustration_n_lines; ++line_num) {
				credits_mem_buffer[0] = u16_msb(illustration_screen_pos + 32 * line_num);
				credits_mem_buffer[1] = u16_lsb(illustration_screen_pos + 32 * line_num);
				wrap_push_nt_buffer(credits_mem_buffer);
			}

			// Draw buffers, abort on input (screen has to be redrawn)
			yield();
			if (handle_input()) {
				return;
			}
		}

		// Set fade-in palette on illustration tiles
		for (uint8_t attribute_pos = 0xd1; attribute_pos < 0xf1; attribute_pos += 8) {
			credits_mem_buffer[0] = 0x23;
			credits_mem_buffer[1] = attribute_pos;
			credits_mem_buffer[2] = 3;
			credits_mem_buffer[3] = 0x55;
			credits_mem_buffer[4] = 0x55;
			credits_mem_buffer[5] = 0x11;
			wrap_push_nt_buffer(credits_mem_buffer);
		}

		yield();
		if (handle_input()) {
			return;
		}
	}

	// Construct page
	uint8_t attributes_step = 0;
	for (uint8_t step = 0; step < n_chunks; ++step) {
		// Copy a line of text
		if (step < n_lines) {
			uint8_t const line_num = step;
			uint8_t const* line = text + (line_num * line_size);

			credits_mem_buffer[0] = u16_msb(0x212e + 32 * line_num);
			credits_mem_buffer[1] = u16_lsb(0x212e + 32 * line_num);
			credits_mem_buffer[2] = line_size;
			long_memcpy(credits_mem_buffer+3, credits_bank(), line, line_size);
			wrap_push_nt_buffer(credits_mem_buffer);
		}

		// Construct illustration
		if (!is_last_illustration(illustration, illustration_bank)) {
			// Copy chunk in VRAM
			uint8_t const chunk_num = chunks_order[step];
			uint8_t const illustration_line = chunk_num / chunks_per_line;
			uint8_t const chunk_pos_in_line = chunk_num % chunks_per_line;
			uint8_t const* chunk = illustration + (chunk_num * chunk_size);
			uint16_t const ppu_addr = 0x1800 + (chunk_num * chunk_size);
			credits_mem_buffer[0] = u16_msb(ppu_addr);
			credits_mem_buffer[1] = u16_lsb(ppu_addr);
			credits_mem_buffer[2] = chunk_size;
			long_memcpy(credits_mem_buffer+3, illustration_bank, chunk, chunk_size);
			wrap_push_nt_buffer(credits_mem_buffer);

			// Display chunk
			uint16_t const screen_addr = illustration_screen_pos + illustration_line * 32 + chunk_pos_in_line * tiles_per_chunk;
			uint8_t const first_tile_num = 0x80 + chunk_num * tiles_per_chunk;
			credits_mem_buffer[0] = u16_msb(screen_addr);
			credits_mem_buffer[1] = u16_lsb(screen_addr);
			credits_mem_buffer[2] = 3;
			for (uint8_t tile = 0; tile < tiles_per_chunk; ++tile) {
				credits_mem_buffer[3+tile] = first_tile_num + tile;
			}
			wrap_push_nt_buffer(credits_mem_buffer);

			// Place bubble animation over chunk
			reset_bubble(
				step & 0x03,
				illustration_screen_pos_x + chunk_pos_in_line * tiles_per_chunk * 8,
				illustration_screen_pos_y - 1 + illustration_line * 8
			);

			// Change illustration attributes
			if (step >= attributes_delay && attributes_step < sizeof(attributes_order_bytes)) {
				credits_mem_buffer[0] = 0x23;
				credits_mem_buffer[1] = attributes_order_bytes[attributes_step];
				credits_mem_buffer[2] = 1;
				credits_mem_buffer[3] = attributes_order_bits[attributes_step];
				wrap_push_nt_buffer(credits_mem_buffer);
				++attributes_step;
			}

			// Tick bubble animations
			*player_number = 0;
			for (uint8_t bubble_num = 0; bubble_num < n_bubbles; ++bubble_num) {
				long_animation_draw(anims_bank(), credits_bubble_anims + bubble_num * sizeof(Animation));
				long_animation_tick(anims_bank(), credits_bubble_anims + bubble_num * sizeof(Animation));
			}
		}

		// Draw nt buffers
		yield();

		// Check there is no new inputs, meaning the page should be redrawn from the begining
		if (handle_input()) {
			return;
		}
	}

	// Clear remaining bubbles
	for (uint8_t tile_num = bubbles_first_sprite; tile_num < bubbles_first_sprite + bubble_anim_n_sprites * n_bubbles; ++tile_num) {
		oam_mirror[tile_num*4+0] = 0xfe;
	}

	// Finish changing attributes
	if (!is_last_illustration(illustration, illustration_bank)) {
		while (attributes_step < sizeof(attributes_order_bytes)) {
			credits_mem_buffer[0] = 0x23;
			credits_mem_buffer[1] = attributes_order_bytes[attributes_step];
			credits_mem_buffer[2] = 1;
			credits_mem_buffer[3] = attributes_order_bits[attributes_step];
			wrap_push_nt_buffer(credits_mem_buffer);
			++attributes_step;
		}

		yield();
		if (handle_input()) {
			return;
		}
	}

	// Mark page as fully drawed
	*credits_page_dirty = 0;
	*credits_last_illustration_bank = illustration_bank;
    *credits_last_illustration_msb = ptr_msb(illustration);
    *credits_last_illustration_lsb = ptr_lsb(illustration);
}

static void tick_animations() {
	*player_number = 0;
	long_animation_draw(anims_bank(), credits_cursor_anim);
	long_animation_tick(anims_bank(), credits_cursor_anim);
}

void init_credits_screen_extra() {
	// Draw screen
	long_construct_palettes_nt_buffer(screen_bank(), &menu_credits_palette);
	long_draw_zipped_nametable(screen_bank(), &menu_credits_nametable);
	long_cpu_to_ppu_copy_tileset_background(tileset_bank(), &menu_credits_tileset);
	long_cpu_to_ppu_copy_charset(charset_bank(), &charset_ascii, 0x1200, 1, 0);
	long_cpu_to_ppu_copy_tileset(tileset_bank(), &menu_credits_sprites_tileset, 0x0000);

	// Draw navigation bar
	uint8_t const dot_tile = ptr_lsb(&MENU_CREDITS_NAVIGATION_DOT);
	uint16_t const bar_addr = 0x2350 - nb_pages() / 2;
	*PPUADDR = u16_msb(bar_addr);
	*PPUADDR = u16_lsb(bar_addr);
	for (uint8_t page_num = 0; page_num < nb_pages(); ++page_num) {
		*PPUDATA = dot_tile;
	}

	// Init animations
	wrap_animation_init_state(credits_cursor_anim, &menu_credits_cursor_anim);
	Anim(credits_cursor_anim)->x = 128 - 8 * (nb_pages() / 2);
	Anim(credits_cursor_anim)->y = 207;
	Anim(credits_cursor_anim)->first_sprite_num = 0;
	Anim(credits_cursor_anim)->last_sprite_num = 0;

	// Initialize state
	*credits_current_page = 0;
	*credits_page_dirty = 1;
	forget_last_illustration();
}

void credits_screen_tick_extra() {
	// Tick animations
	tick_animations();

	// Check if a button is released and trigger correct action
	handle_input();

	// Refresh display
	if (*credits_page_dirty) {
		show_current_page();
	}
}

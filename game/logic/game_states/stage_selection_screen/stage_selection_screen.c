#include <cstb.h>

///////////////////////////////////////
// C types for structured data
///////////////////////////////////////

struct BgTaskState {
	uint8_t step;
	uint8_t count;
} __attribute__((__packed__));

///////////////////////////////////////
// Global labels from the ASM codebase
///////////////////////////////////////

extern uint8_t const menu_stage_selection_selector_anim;
extern uint8_t const stage_selection_palette;
extern uint8_t const stages_bank;
extern uint8_t const stages_illustration;

void audio_play_interface_click();

///////////////////////////////////////
// Stage selection's ASM functions
///////////////////////////////////////

void stage_selection_back_to_char_select();
void stage_selection_screen_long_memcopy();

void wrap_stage_selection_screen_long_memcopy(uint8_t* dest, uint8_t src_bank, uint8_t const* src) {
	*tmpfield1 = ptr_lsb(dest);
	*tmpfield2 = ptr_msb(dest);
	*tmpfield3 = src_bank;
	*tmpfield4 = ptr_lsb(src);
	*tmpfield5 = ptr_msb(src);
	stage_selection_screen_long_memcopy();
}

///////////////////////////////////////
// Constants specific to this file
///////////////////////////////////////

static uint8_t const BG_STEP_SET_PALETTES = 0;
static uint8_t const BG_STEP_DRAW_GENERIC_BACKGROUND = 1;
static uint8_t const BG_STEP_STAGE_PICTURE_INIT = 2;
static uint8_t const BG_STEP_STAGE_PICTURE = 3;
static uint8_t const BG_STEP_DEACTIVATED = 255;
static uint8_t const TILE_MENU_CHAR_SELECT_STAGE_SELECTOR = 0x41;

static uint16_t const selector_position_x[] = {112, 120, 128, 136};

///////////////////////////////////////
// Utility functions
///////////////////////////////////////

static struct BgTaskState* Task(uint8_t* raw) {
	return (struct BgTaskState*)raw;
}

/** Set nt buffer writes in horizontal mode
 *
 * Note: it will not take effect until the next frame
 */
static void nt_buffers_horizontal() {
	*ppuctrl_val = ((*ppuctrl_val) & 0xfb);
}

/** Set nt buffer writes in vertical mode
 *
 * Note: it will not take effect until the next frame
 */
static void nt_buffers_vertical() {
	*ppuctrl_val = ((*ppuctrl_val) | 0x04);
}

///////////////////////////////////////
// State implementation
///////////////////////////////////////

static void change_screen_cleaning() {
	// Copy selected values in actual values
	*config_selected_stage = *config_requested_stage;
}

static void skip_frame() {
	wrap_trampoline(code_bank(), code_bank(), &sleep_frame);
	reset_nt_buffers();
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

	// Set nt buffer writes in horizontal mode
	//  note: it will not take effect until the next frame, so skip it
	nt_buffers_horizontal();
	skip_frame();

	for (uint8_t fade_step = 0; fade_step < 3; ++fade_step) {
		wrap_construct_nt_buffer(nt_palette_header, step_palettes[fade_step]);
		for (uint8_t delay = 5; delay > 0; --delay) {
			skip_frame();
		}
	}
}

static void tick_bg_task() {
	// Shorthand for tiles numbers
	static uint8_t const tsel = TILE_MENU_CHAR_SELECT_STAGE_SELECTOR;

	// Nametable buffers to construct the frame
	static uint8_t const frame_border[] = {0x21, 0x22, 0x21, 0x21, 0x22, 0x22, 0x21, 0x22, 0x21, 0x22, 0x21, 0x22, 0x21, 0x22, 0x21, 0x22};
	static uint8_t const upper_frame_border_header[] = {0x21, 0xe8, 16};
	static uint8_t const lower_frame_border_header[] = {0x23, 0x88, 16};
	static uint8_t const frame_clear_bot[] = {0x23, 0xa8, 16, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00};
	static uint8_t const frame_selector[] = {0x21, 0xcb, 10, 0x00, 0x00, 0x00, tsel, tsel, tsel, tsel, 0x00, 0x00, 0x00};

	// Screen init nametable buffers
	static uint8_t const nt_palette_header[] = {0x3f, 0x00, 0x20};
	static uint8_t const nt_attributes_body[] = {0xff, 0xff, 0xff, 0xff};
	static uint8_t const nt_attributes_headers[][3] = {
		{0x23, 0xe2, 4},
		{0x23, 0xea, 4},
		{0x23, 0xf2, 4},
	};

	// Stage picture
	static uint16_t const stage_graphic_first_row = 0x2208;

	// Logic
	struct BgTaskState* task = Task(stage_selection_bg_task);
	switch (task->step) {
		case BG_STEP_DEACTIVATED:
			break;

		case BG_STEP_SET_PALETTES: {
			wrap_construct_nt_buffer(nt_palette_header, &stage_selection_palette);
			for (uint8_t i = 0; i < 3; ++i) {
				wrap_construct_nt_buffer(nt_attributes_headers[i], nt_attributes_body);
			}
			++task->step;
			break;
		}

		case BG_STEP_DRAW_GENERIC_BACKGROUND:
			wrap_construct_nt_buffer(upper_frame_border_header, frame_border);
			wrap_construct_nt_buffer(lower_frame_border_header, frame_border);
			wrap_push_nt_buffer(frame_clear_bot);
			wrap_push_nt_buffer(frame_selector);

			// Set nt buffer writes in vertical mode
			//  note: it will not take effect until the next frame (buffers pushed above are horizontal)
			nt_buffers_vertical();

			++task->step;
			break;

		case BG_STEP_STAGE_PICTURE_INIT:
			// Move selector, and reset it to its first frame (forcing it to be visible)
			Anim(stage_selection_cursor_anim)->x = selector_position_x[*config_requested_stage];
			wrap_animation_state_change_animation(stage_selection_cursor_anim, &menu_stage_selection_selector_anim);

			task->count = 0;
			stage_selection_mem_buffer[0] = (uint8_t)(stage_graphic_first_row >> 8);
			stage_selection_mem_buffer[2] = 12;
			++task->step;
			__attribute__((fallthrough));

		case BG_STEP_STAGE_PICTURE: {
			uint8_t const stage_bank = (&stages_bank)[*config_requested_stage];
			uint8_t const* const stage_illustration = ((uint8_t const**)(&stages_illustration))[*config_requested_stage];
			for (uint8_t i = 0; i < 4; ++ i) {
				stage_selection_mem_buffer[1] = (uint8_t)(stage_graphic_first_row & 0xff) + task->count;
				wrap_stage_selection_screen_long_memcopy(stage_selection_mem_buffer + 3, stage_bank, stage_illustration + 12 * task->count);
				wrap_push_nt_buffer(stage_selection_mem_buffer);

				++task->count;
				if (task->count >= 16) {
					++task->step;
					break;
				}
			}
			break;
		}

		default:
			task->step = BG_STEP_DEACTIVATED;
			break;
	};
}

void init_stage_selection_screen_extra() {
	// Init bg task
	Task(stage_selection_bg_task)->step = BG_STEP_SET_PALETTES;
	Task(stage_selection_bg_task)->count = 0;

	// Initialize selector animation
	wrap_animation_init_state(stage_selection_cursor_anim, &menu_stage_selection_selector_anim);
	Anim(stage_selection_cursor_anim)->x = selector_position_x[*config_requested_stage];
	Anim(stage_selection_cursor_anim)->y = 111;
	Anim(stage_selection_cursor_anim)->first_sprite_num = 0;
	Anim(stage_selection_cursor_anim)->last_sprite_num = 1;
}

void stage_selection_screen_tick_extra() {
	// Tick BG task
	reset_nt_buffers();
	tick_bg_task();

	// Draw animations
	*player_number = 0;
	wrap_animation_draw(stage_selection_cursor_anim, 0, 0);
	wrap_animation_tick(stage_selection_cursor_anim);

	// Take inputs
	for (uint8_t player_num = 0; player_num < 2; ++player_num) {
		uint8_t const controller_btns = controller_a_btns[player_num];
		uint8_t const last_fame_btns = controller_a_last_frame_btns[player_num];
		if (controller_btns != last_fame_btns) {
			switch (controller_btns) {
				case CONTROLLER_BTN_RIGHT:
					audio_play_interface_click();
					if (*config_requested_stage < 3) {
						++*config_requested_stage;
					}else {
						*config_requested_stage = 0;
					}
					if (Task(stage_selection_bg_task)->step >= BG_STEP_STAGE_PICTURE_INIT) {
						Task(stage_selection_bg_task)->step = BG_STEP_STAGE_PICTURE_INIT;
						Task(stage_selection_bg_task)->count = 0;
					}
					break;

				case CONTROLLER_BTN_LEFT:
					audio_play_interface_click();
					if (*config_requested_stage > 0) {
						--*config_requested_stage;
					}else {
						*config_requested_stage = 3;
					}
					if (Task(stage_selection_bg_task)->step >= BG_STEP_STAGE_PICTURE_INIT) {
						Task(stage_selection_bg_task)->step = BG_STEP_STAGE_PICTURE_INIT;
						Task(stage_selection_bg_task)->count = 0;
					}
					break;

				// Buttons that take effect on release
				case 0:
					switch (last_fame_btns){
						case CONTROLLER_BTN_A:
						case CONTROLLER_BTN_START:
							audio_play_interface_click();
							change_screen_cleaning();
							fade_out();
							wrap_change_global_game_state(*config_game_mode == GAME_MODE_ONLINE ? GAME_STATE_NETPLAY_LAUNCH : GAME_STATE_INGAME);
							break;

						case CONTROLLER_BTN_B:
							audio_play_interface_click();
							change_screen_cleaning();
							nt_buffers_horizontal();
							skip_frame();
							stage_selection_back_to_char_select();
							break;
					}
					break;

				default:
					break;
			}
		}
	}
}

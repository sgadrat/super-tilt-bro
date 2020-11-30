////////////////////////////////////
// Routines without arguments
//  simply declare it as extern
////////////////////////////////////

void audio_mute_music();
void audio_unmute_music();
void process_nt_buffers();
void reset_nt_buffers();
void re_init_menu();
void tick_menu();

////////////////////////////////////
// Routines that need some glue code
//  implement the glue
////////////////////////////////////

void change_global_game_state();
static void wrap_change_global_game_state(uint8_t new_state) {
	asm(
		"lda %0\n\t"
		"jsr change_global_game_state"
		:
		: "r"(new_state)
		:
	);
}

void construct_nt_buffer();
static void wrap_construct_nt_buffer(uint8_t const* header, uint8_t const* payload) {
	*tmpfield1 = ((int)header) & 0x00ff;
	*tmpfield2 = (((int)header) >> 8) & 0x00ff;
	*tmpfield3 = ((int)payload) & 0x00ff;
	*tmpfield4 = (((int)payload) >> 8) & 0x00ff;
	construct_nt_buffer();
}

void push_nt_buffer();
static void wrap_push_nt_buffer(uint8_t const* buffer) {
	uint8_t const msb = (uint8_t)((int)(buffer) >> 8);
	uint8_t const lsb = (uint8_t)((int)(buffer) & 0x00ff);
	asm(
		"ldy %0\n\t"
		"lda %1\n\t"
		"jsr push_nt_buffer"
		:
		: "r"(msb), "r"(lsb)
		: "a", "x", "y"
	);
}

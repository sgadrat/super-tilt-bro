#pragma once
#include <stdint.h>

//
// Common STB structures
//

typedef struct Animation {
	uint16_t x;
	uint16_t y;
	uint8_t const* data;
	uint8_t direction;
	uint8_t clock;
	uint8_t first_sprite_num;
	uint8_t last_sprite_num;
	uint8_t const* frame_vector;
} __attribute__((__packed__)) Animation;

//
// Easy casts from pointers in mem_labels
//

#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wunused-function"

static struct Animation* Anim(uint8_t* raw) {
	return (struct Animation*)raw;
}

#pragma GCC diagnostic pop

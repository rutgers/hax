#include <hax.h>
#include <stdbool.h>
#include <stdint.h>

#include "encoder.h"

static bool intenc[6] = {};

/* Mapping between logical "encoder index" and interrupt pins indexes. */
static volatile index_t encmap[6];

/* Store ticks in each direction in different memory locations to avoid
 * corruption from small oscillations.
 */
static volatile uint32_t counts[6];

/* FIXME: digital_get is not necissarily reading the right pin, depending on
 * mapping.
 */
#define ENCODER(_flip_, _other_, _num_)      \
    do {                                     \
        bool other = digital_get(_other_);   \
        if (_flip_) {                        \
            if (other)                       \
                ++counts[2 *(_num_) + 1];    \
            else                             \
                ++counts[2 *(_num_)];        \
        } else {                             \
            if (other)                       \
                ++counts[2 *(_num_)];        \
            else                             \
                ++counts[2 *(_num_) + 1];    \
        }                                    \
    } while (0)

void encoder_init(uint8_t id, index_t int1, index_t int2) {
	encmap[2 * id + 0] = int1;
	encmap[2 * id + 1] = int2;

	/* Note that interrupts are enabled. */
	intenc[2 * id + 0] = true;
	intenc[2 * id + 1] = true;

	switch (id) {
	case 0:
		interrupt_init(int1, encoder_0a);
		interrupt_init(int2, encoder_0b);
		break;
	
	case 1:
		interrupt_init(int1, encoder_1a);
		interrupt_init(int2, encoder_1b);
		break;
	
	case 2:
		interrupt_init(int1, encoder_2a);
		interrupt_init(int2, encoder_2b);
		break;
	}
	
	/* Enable interrupts for both encoder connections. */
	interrupt_set(int1, true);
	interrupt_set(int2, true);
}

void encoder_update(void) {
}

int32_t encoder_get(uint8_t id) {
	return counts[2 * id] - counts[2 * id + 1];
}

void encoder_reset(uint8_t id) {
	counts[id + 0] = 0;
	counts[id + 1] = 0;
}

void encoder_reset_all(void) {
	uint8_t i;
	for (i = 0; i < 6; ++i) {
		counts[i] = 0;
	}
}

void encoder_0a(int8_t l) {
	ENCODER(l, encmap[1], encmap[0]);
}

void encoder_0b(int8_t l) {
	ENCODER(!l, encmap[0], encmap[1]);
}

void encoder_1a(int8_t l) {
	ENCODER(l, encmap[3], encmap[2]);
}

void encoder_1b(int8_t l) {
	ENCODER(!l, encmap[2], encmap[3]);
}

void encoder_2a(int8_t l) {
	ENCODER(l, encmap[5], encmap[4]);
}

void encoder_2b(int8_t l) {
	ENCODER(!l, encmap[4], encmap[5]);
}

#ifndef GRAPHICS_H_
#define GRAPHICS_H_

#include "types.h"

#define FILLER_CTRL (*((volatile uint32_t*)0x8000001C) & 0x01)
#define FILLER_COLOR (*((volatile uint32_t*)0x80000018))
#define LE_CTRL (*((volatile uint32_t*) 0x80000030) & 0x01)
#define LE_COLOR (*((volatile uint32_t*) 0x80000034))
#define LE_X0 (*((volatile uint32_t*) 0x80000040))
#define LE_Y0 (*((volatile uint32_t*) 0x80000044))
#define LE_X1 (*((volatile uint32_t*) 0x80000048))
#define LE_Y1 (*((volatile uint32_t*) 0x8000004C))
#define LE_X0TRIG (*((volatile uint32_t*) 0x80000050))
#define LE_Y0TRIG (*((volatile uint32_t*) 0x80000054))
#define LE_X1TRIG (*((volatile uint32_t*) 0x80000058))
#define LE_Y1TRIG (*((volatile uint32_t*) 0x8000005C))

void fill(uint32_t color);
void line(uint32_t color, uint16_t x0, uint16_t y0, uint16_t x1, uint16_t y1);

#endif

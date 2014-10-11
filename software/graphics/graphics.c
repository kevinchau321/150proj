#include "graphics.h"

void fill(uint32_t color)
{
  while (!(FILLER_CTRL & LE_CTRL)) ;
  FILLER_COLOR = color;
}

void line(uint32_t color, uint16_t x0, uint16_t y0, uint16_t x1, uint16_t y1)
{
  while (!(FILLER_CTRL & LE_CTRL));
  LE_COLOR = color;
  LE_X0 = x0;
  LE_Y0 = y0;
  LE_X1 = x1;
  LE_Y1TRIG = y1;
}

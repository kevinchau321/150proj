.section .start
.global _start

_start:
  lui $t0, 0x8000
  ori $t0, 0x0018
  # Add a few data values to alternate between
  addiu $t1, $0, 0x7F
  addiu $t2, $0, 0xFF
  addiu $t3, $0, 0xC0
  # FILLER_COLOR
  sw  $t1, 0($t0)
  # LE_COLOR
  sw  $t2, 28($t0)
  # LE_X0
  sw  $t3, 40($t0)
  # LE_Y0
  sw  $t1, 44($t0)
  # LE_X1
  sw  $t2, 48($t0)
  # LE_Y1
  sw  $t3, 52($t0)
  # LE_X0TRIG
  sw  $t1, 56($t0)
  # LE_Y0TRIG
  sw  $t2, 60($t0)
  # LE_X1TRIG
  sw  $t3, 64($t0)
  # LE_Y1TRIG
  sw  $t1, 68($t0)

.section    .start
.global     _start

_start:
li   $s0,      0x00000020
addi $t0, $t0, 20
bne  $t0, $s0, End
End:

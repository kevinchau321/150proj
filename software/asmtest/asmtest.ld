OUTPUT_ARCH( "riscv" )
ENTRY( _start )

SECTIONS
{
    . = 0x40000000;
    .text : {
        * (.start);
        * (.text);
    }

.data :
{
*(.data)
}
/* End of uninitalized data segement */
_end = .;
}

start EchoTestbench
file copy -force ../../../software/echo/echo.mif imem_blk_ram.mif
file copy -force ../../../software/echo/echo.mif dmem_blk_ram.mif
file copy -force ../../../software/echo/echo.mif bios_mem.mif
add wave EchoTestbench/*
add wave EchoTestbench/mem_arch/*
add wave EchoTestbench/mem_arch/dcache/*
add wave EchoTestbench/mem_arch/icache/*
add wave EchoTestbench/DUT/dpath/*
add wave EchoTestbench/DUT/ctrl/*
add wave EchoTestbench/DUT/dpath/ua/*
add wave EchoTestbench/DUT/dpath/regfile/*
run 1000us

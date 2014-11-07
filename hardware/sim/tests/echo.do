start EchoTestbench
file copy -force ../../../software/echo/echo.mif imem_blk_ram.mif
file copy -force ../../../software/echo/echo.mif dmem_blk_ram.mif
add wave EchoTestbench/*
add wave EchoTestbench/cpu/*
add wave EchoTestbench/cpu/control/*
add wave EchoTestbench/cpu/dmem/*
add wave EchoTestbench/cpu/imem/*
add wave EchoTestbench/cpu/datapath/*
add wave EchoTestbench/cpu/uart/*
run 10000us

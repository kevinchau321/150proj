/**
 * Top-level module for the RISCV processor.
 * This should contain instantiations of your datapath and control unit.
 * For CP1, the imem and dmem should be instantiated in this top-level module.
 * For CP2 and CP3, the memories are moved to a different module (Memory150),
 * and connected to the datapath via memory ports in the RISC I/O interface.
 *
 * CS150 Fall 14. Template written by Simon Scott.
 */
module Riscv150(
    input clk,
    input rst,
    input stall,

    // Ports for UART that go off-chip to UART level shifter
    input FPGA_SERIAL_RX,
    output FPGA_SERIAL_TX

    // Memory system ports
    // Only used for checkpoint 2 and 3
`ifdef CS150_CHKPNT_2_OR_3
    ,
    output [31:0] dcache_addr,
    output [31:0] icache_addr,
    output [3:0] dcache_we,
    output [3:0] icache_we,
    output dcache_re,
    output icache_re,
    output [31:0] dcache_din,
    output [31:0] icache_din,
    input [31:0] dcache_dout,
    input [31:0] instruction
`endif

    // Graphics ports
    // Only used for checkpoint 3
`ifdef CS150_CHKPNT_3
    ,
    output [31:0]  bypass_addr,
    output [31:0]  bypass_din,
    output [3:0]   bypass_we,

    input          filler_ready,
    input          line_ready,
    output  [23:0] filler_color,
    output         filler_valid,
    output  [31:0] line_color,
    output  [9:0]  line_point,
    output         line_color_valid,
    output         line_x0_valid,
    output         line_y0_valid,
    output         line_x1_valid,
    output         line_y1_valid,
    output         line_trigger
`endif
);


    wire [7:0] UARTtoWB;
    wire [11:0] inst_addra; // Instruction address wire from IMEM_BLK_RAM to DATAPATH
    wire [1:0] PC_sel;
    wire [31:0] imem_dout;

    // Instantiate the instruction memory here (checkpoint 1 only)
    imem_blk_ram(.clka(clk),
		.ena(0),
		.wea(0),
		.addra(inst_addra),
		.dina(0),
		.clkb(0),
		.addrb(0),
		.doutb(imem_dout));

    // Instantiate the data memory here (checkpoint 1 only)
    dmem_blk_ram(.clka(clk), 
		.ena(0),
		.wea(0),
		.addra(0),
		.dina(0),
		.douta(0));
    // Instantiate your control unit here
   ControlUnit control(.clk(clk),
	.opcode(0),
	.funct3(0),
	.funct7(0),
	.branch_taken(0),
	.rs1(0),
	.rs2(0),
	.rd(0),
	.ALUopX(0),
	.PCsrcM(PC_sel),
	.ALUsrcAX(0),
	.ALUsrcBX(0),
	.wbsrcM(0),
	.StallD(0),
	.RegWrM(0));

    // Instantiate your datapath here
   Datapath datapath (.Clock(clk),
	.Reset(rst),
	.RegWr(0),
	.inst_doutb(imem_dout),
	.inst_addra(inst_addra),
	.dina(0),
	.branch_taken(0),
	.data_forward_ALU1(0),
	.data_forward_ALU2(0),
	.PC_sel(PC_sel),
	.dmem_out(0),
	.UART_out(UARTtoWD));

   // Instantiate UART module
   UART uart(.Clock(clk),
	.Reset(rst),
	.DataInValid(0),
	.DataInReady(0),
	.SIn(FPGA_SERIAL_RX),
	.SOut(FPGA_SERIAL_TX),	
	.DataOut(UARTtoWB),
	.DataOutValid(0));
   
   
endmodule

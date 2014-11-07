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


    wire [31:0] UARTtoWB;
    wire [11:0] addra;
    wire [1:0] PC_sel;
    wire [31:0] imem_dout;
    wire branch_taken;
    wire [3:0] op;
    wire [31:0] PC;
    wire [31:0] dina;
    wire [31:0] dmem_out;
    wire [1:0] ALUsrcA;
    wire [2:0] ALUsrcB;
    wire RegWrite;
    wire [1:0] wbsrc;
    wire [31:0] instruction;
    wire [31:0] memaddr;
    wire [3:0] ibitmask, dbitmask;
    wire ien;
    wire den;
    wire ctrl_stall;
    wire UARTReady, UARTValid;
    wire [7:0] UART_DataIn;

   reg [31:0] UARTtoWBReg;
   reg [7:0] UART_DataInReg;
   
    assign UARTtoWB = UARTtoWBReg;
    assign UART_DataIn = UART_DataInReg;
    assign instruction = ctrl_stall ? 32'b00000000000000000000000000010011 : imem_dout;


    // Instantiate the instruction memory here (checkpoint 1 only)
    imem_blk_ram imem (.clka(clk),
		.ena(ien),		//ENABLES READS AND WRITES FOR IMEM
		.wea(ibitmask),
		.addra(addra),
		.dina(dina),
		.clkb(clk),
		.addrb(PC[11:0]),
		.doutb(imem_dout));

    // Instantiate the data memory here (checkpoint 1 only)
    dmem_blk_ram dmem (.clka(clk), 
		.ena(den),
		.wea(dbitmask),
		.addra(addra),
		.dina(dina),
		.douta(dmem_out));
    // Instantiate your control unit here
   ControlUnit control(.clk(clk),
	.opcode(imem_dout[6:0]),
	.funct3(imem_dout[14:12]),
	.funct7(imem_dout[31:25]),
	.branch_taken(branch_taken),
	.rs1(imem_dout[19:5]),
	.rs2(imem_dout[24:20]),
	.rd(imem_dout[11:7]),
	.ALUopX(op),
	.PCsrcM(PC_sel),
	.ALUsrcAX(ALUsrcA),
	.ALUsrcBX(ALUsrcB),
	.wbsrcM(wbsrc),
	.Stall(ctrl_stall),
	.RegWrM(RegWrite),
	.memaddr(memaddr),
	.ibitmask(ibitmask),
	.dbitmask(dbitmask),
	.imem_en(ien),
	.dmem_en(den),
	.UARTDataInReady(UARTReady),
	.UARTDataOutValid(UARTValid));

    // Instantiate your datapath here
   Datapath datapath (.Clock(clk),
	.Reset(rst),
	.RegWr(RegWrite),
	.inst_doutb(instruction),
	.mem_addra(addra),
	.dina(dina),
	.branch_taken(branch_taken),
	.data_forward_ALU1(ALUsrcA),
	.data_forward_ALU2(ALUsrcB),
	.wbsrc(wbsrc),
	.PC_sel(PC_sel),
	.dmem_out(dmem_out),
	.UART_out(UARTtoWB),
	.ALUop(op),
	.PCout(PC),
	.memaddrD(memaddr));

   // Instantiate UART module
   UART uart(.Clock(clk),
	.Reset(rst),
	.DataInValid(UARTInputValid),
	.DataInReady(UARTReady),
	.DataIn (UART_DataIn),
	.SIn(FPGA_SERIAL_RX),
	.SOut(FPGA_SERIAL_TX),	
	.DataOut(UART_DataOut),
	.DataOutValid(UARTValid));

	always @(*) begin
	   if (32'h80000000 == addra) 
		UARTtoWBReg = {30'b0, UARTValid, UARTReady};
	   else if (addra == 32'h80000008)
	     UART_DataInReg = dina & 32'h0000000F;
	   else if (32'h80000004 == addra)
		UARTtoWBReg = {24'b0, UART_DataOut}; 
   	end
   
endmodule

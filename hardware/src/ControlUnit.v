`include "ALUdec.v";

module ControlUnit(
	input clk,
	input [6:0] opcode,
	input [2:0] funct3,
	input [6:0] funct7,
	input branch_taken,
	output [3:0] ALUctrl,
	output [1:0] PCctrl,
	output ALUsrcA,
	output ALUsrcB,
	output wbsrc,
	output Stall,
	output RegWr;)
	
	
	wire [3:0] ALUctrl;

        ALUdec ALUdec(.opcode(opcode),
	  .funct(funct3),
	  .add_rshift_type(funct7 != 0), // add_rshift_type decides whether ADD or SUB
	  .ALUop(ALUctrl));

	always @ (posedge clk) begin
		if (branch_taken || opcode == 7'b1101111 || opcode == 7'b1100111) begin
			PCctrl <= 3;	//target address for branch
			Stall <= 1;
		end else begin
			case (opcode)
				7'b0110011: 	//R-Type
					RegWr <= 1;
					ALUsrcA <= 4;	//rd1 from reg
					ALUsrcB <= 0;	//rd2 from reg
					

			endcase
		end

endmodule

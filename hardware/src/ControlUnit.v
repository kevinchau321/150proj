`include "ALUdec.v";

module ControlUnit(
	input clk,
	input [6:0] opcode,
	input [2:0] funct3,
	input [6:0] funct7,
	output [3:0] ALUctl,
	output [1:0] PCctrl,
	output ALUsrcA,
	output ALUsrcB,
	output wbsrc;)
	
	always @ (posedge clk) begin
		case (opcode)







		endcase
	end

endmodule

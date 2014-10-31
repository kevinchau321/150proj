// UC Berkeley CS150
// Lab 4, Fall 2014
// Module: ALU.v
// Desc:   32-bit ALU for the MIPS150 Processor
// Inputs: 
//    A: 32-bit value
//    B: 32-bit value
//    ALUop: Selects the ALU's operation 
// 						
// Outputs:
//    Out: The chosen function mapped to A and B.

`include "Opcode.vh"
`include "ALUop.vh"

module ALU(
    input [31:0] A,B,
    input [3:0] ALUop,
    output reg [31:0] Out
);

   reg [31:0] bitmask = 32'b11111111111111111111111111111111;
   reg signed [31:0] signed_A, signed_B;

   always @(*) begin

      case (ALUop)
	`ALU_ADD:
	  Out = bitmask & (A + B);
	`ALU_SUB:
	  Out = bitmask & (A - B);
	`ALU_SLL:
	  Out = bitmask & (A << B);
	`ALU_SLT: begin
	   signed_A = A;
	   signed_B = B;
	   if (signed_A < signed_B)
	     Out = bitmask & (1'b1);
	   else
	     Out = 0;
	end 
	`ALU_SLTU: 	  
	  if (A < B)
	    Out = bitmask & (1'b1);
	  else
	    Out = 0;
	`ALU_XOR:
	  Out = A ^ B;
	`ALU_SRL:
	  Out = bitmask & (A >> B);
	`ALU_SRA: begin
	   signed_A = A;
	   signed_B = B;
	  Out = bitmask & (signed_A >>> signed_B);
	   end
	`ALU_OR:
	  Out = A | B;
	`ALU_AND:
	  Out = A & B;
	`ALU_COPY_B:
	  Out = B;
	`ALU_XXX:
	  Out = bitmask & (A + B);
	default:
	  Out = 0;
      endcase
   end
   

endmodule

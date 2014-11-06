// UC Berkeley CS150
// Lab 3, Fall 2014
// Module: ALUdecoder
// Desc:   Sets the ALU operation
// Inputs: opcode: the top 6 bits of the instruction
//         funct: the funct, in the case of r-type instructions
//         add_rshift_type: selects whether an ADD vs SUB, or an SRA vs SRL
// Outputs: ALUop: Selects the ALU's operation
//

`include "Opcode.vh"
`include "ALUop.vh"

module ALUdec(
  input [6:0]       opcode,
  input [2:0]       funct,
  input             add_rshift_type,
  output reg [3:0]  ALUop,
	      output itype
);

   reg 		     itypeReg;

   assign itype = itypeReg;
   
  always @(*) begin
     itypeReg = 1'b0;
     case (opcode)
       7'b0110111: // LUI
	 ALUop = `ALU_COPY_B;
       7'b0010111: // APUIPC
	 ALUop = `ALU_XXX;
       7'b1101111: // JAL
	 ALUop = `ALU_XXX;
       7'b1100111: // JALR
	 ALUop = `ALU_XXX;
       7'b1100011: // Branch
	 ALUop = `ALU_XXX;
       7'b0000011: // Load
	 ALUop = `ALU_XXX;
       7'b0100011: // Store
	 ALUop = `ALU_XXX;
       7'b0010011: begin // I-Type 
	  case (funct)
	   3'b000:
	     //if (add_rshift_type)
	       //ALUop = `ALU_SUB;
	     //else
	       ALUop = `ALU_ADD;
	   3'b001:
	     ALUop = `ALU_SLL;
	   3'b010:
	     ALUop = `ALU_SLT;
	   3'b011:
	     ALUop = `ALU_SLTU;
	   3'b100:
	     ALUop = `ALU_XOR;
	   3'b101:
	     if (add_rshift_type)
	       ALUop = `ALU_SRA;
	     else
	       ALUop = `ALU_SRL;
	   3'b110:
	     ALUop = `ALU_OR;
	   3'b111:
	     ALUop = `ALU_AND;
	 endcase // case (funct)
	itypeReg = 1'b1;
       end
       7'b0110011:
	 case (funct)
	   3'b000:
	     //if (add_rshift_type)
	       //ALUop = `ALU_SUB;
	     //else
	       ALUop = `ALU_ADD;
	   3'b001:
	     ALUop = `ALU_SLL;
	   3'b010:
	     ALUop = `ALU_SLT;
	   3'b011:
	     ALUop = `ALU_SLTU;
	   3'b100:
	     ALUop = `ALU_XOR;
	   3'b101:
	     if (add_rshift_type)
	       ALUop = `ALU_SRA;
	     else
	       ALUop = `ALU_SRL;
	   3'b110:
	     ALUop = `ALU_OR;
	   3'b111:
	     ALUop = `ALU_AND;
	 endcase // case (funct)
       //7'b0010011:
	 //case (funct)
	   //3'b000:
	    // ALUop = `ALU_ADD;
	  // 3'b001:
	   //  ALUop = `ALU_SLL;
	   //3'b010:
	   //  ALUop = `ALU_SLT;
	  // 3'b011:
	  //   ALUop = `ALU_SLTU;
	  // 3'b100:
	 //    ALUop = `ALU_XOR;
	  // 3'b101:
	 //    if (add_rshift_type)
	//       ALUop = `ALU_SRA;
	//     else
	//      ALUop = `ALU_SRL;
	//   3'b110:
	 //    ALUop = `ALU_OR;
	//   3'b111:
	//     ALUop = `ALU_AND;
	// endcase // case (funct)
       default:
	 ALUop = `ALU_XXX;
       
     endcase // case (opcode)


  end
   
endmodule

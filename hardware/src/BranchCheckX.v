module BranchCheckX (
		branch_taken,
		funct3,
		rs1,
		rs2);
	input [2:0] funct3;
	input[31:0] rs1, rs2; //From reg file outputs
	output reg branch_taken;
	always @ (rs1, rs2) begin
		case (funct3)
			3'b000: //BEQ
				branch_taken = (rs1==rs2);
			3'b001:	//BNE
				branch_taken = (rs1!=rs2);
			3'b100: //BLT rs1 < rs2
				branch_taken = ($signed(rs1) < $signed(rs2));
			3'b101: //BGE rs1 >= rs2
				branch_taken = ($signed(rs1) >= $signed(rs2));
			3'b110: //BLTU rs1 < rs2
				branch_taken = ($unsigned(rs1) < $unsigned(rs2));
			3'b111: //BGEU rs1 >= rs2
				branch_taken = ($unsigned(rs1) >= $unsigned(rs2));
		endcase

endmodule

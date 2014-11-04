/**
 * Calculates the data memory address from a 32 bit address plus a 12-bit offset.
 */

module LoadOffsetToAddr (input [31:0] addr, 
			input [11:0] offset, 
			 output [31:0] load_addr);

	wire signed_offset = {offset[11],offset[11],offset[11],offset[11],offset[11],offset[11],offset[11],offset[11],offset[11],offset[11],offset[11],offset[11],offset[11],offset[11],offset[11],offset[11],offset[11],offset[11],offset[11],offset[11],offset};
	assign load_addr = addr + offset;

endmodule

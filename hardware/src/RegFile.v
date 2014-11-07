//-----------------------------------------------------------------------------
//  Module: RegFile
//  Desc: An array of 32 32-bit registers
//  Inputs Interface:
//    clk: Clock signal
//    ra1: first read address (asynchronous)
//    ra2: second read address (asynchronous)
//    wa: write address (synchronous)
//    we: write enable (synchronous)
//    wd: data to write (synchronous)
//  Output Interface:
//    rd1: data stored at address ra1
//    rd2: data stored at address ra2
//-----------------------------------------------------------------------------

module RegFile(input clk,
               input we,
               input  [4:0] ra1, ra2, wa,
               input  [31:0] wd,
               output [31:0] rd1, rd2);

   reg [31:0] rd1reg, rd2reg;
   assign rd1 = rd1reg;
   assign rd2 = rd2reg;
   reg [31:0] 		     r[0:31];
   reg 			     wr_enable; 
   integer i;
   
   initial begin
   	for (i=0; i<32; i=i+1) begin 
		r[i] = 32'b0;
   	end 
   end 

   always @(ra1 or ra2) begin
     if (!wr_enable) begin
	rd1reg = r[ra1];
	rd2reg = r[ra2];
     end 
     else if (r[wa] == wd) begin // Write enable is true, so check if the write destination has been written, if so, then allow read
	rd1reg = r[ra1];
	rd2reg = r[ra2];
     end
   end  
    always @(posedge clk) begin
       if (we && wa != 0) begin
	  wr_enable <= 1'b1;
	  r[wa] <= wd; // Read is disabled during writes
	  wr_enable <= 1'b0;
       end
    end  

endmodule

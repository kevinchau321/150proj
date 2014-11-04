module RegFileTestBench();

	reg clk, wr_en;
	
	reg [4:0] read_addr1, read_addr2, write_addr;

	reg [31:0] write_data;

	wire [31:0] read_data1, read_data2;

	reg [31:0] DUTout, REFout;

	`ifdef RISCV_CLK_50
        	parameter HalfCycle = 10;
    	`endif `ifdef RISCV_CLK_100
        	parameter HalfCycle = 5;
    	`endif
    		parameter Cycle = 2*HalfCycle;

   	initial clk = 0;
   	always #(HalfCycle) clk <= ~clk;

	RegFile reg_file( 	.clk(clk),
				.we(wr_en),
				.ra1(read_addr1),
				.ra2(read_addr2),
				.wa(write_addr),
				.wd(write_data),
				.rd1(read_data1),
				.rd2(read_data2)	);
	

    // Task for checking output
    task checkOutput;
	input [4:0] read_addr1;
	input [4:0] read_addr2;
	input [4:0] write_addr;
	input [31:0] write_data;
	input wr_en;
	if ( REFout !== DUTout ) begin
	    $display("FAIL: Incorrect result for ra1: %b, ra2: %b, wa: %b, we: %b", read_addr1, read_addr2, write_addr, wr_en);
	    $display("\tDUTout: 0x%h, REFout: 0x%h, read_data1: 0x%h, read_data2: 0x%h", DUTout, REFout, read_data1, read_data2);
	    $finish();
	end
	else begin
	    $display("PASS: ra1: %b, ra2: %b, wa: %b, we: %b", read_addr1, read_addr2, write_addr, wr_en);
	    $display("\tDUTout: 0x%h, REFout: 0x%h, read_data1: 0x%h, read_data2: 0x%h", DUTout, REFout, read_data1, read_data2);
	end
    endtask


	initial begin
		//reset
		//write first reg value and read first value

		wr_en = 1;
		read_addr1 = 0;
		read_addr2 = 1;
		write_addr = 2;
		write_data = 32'h10838234;
		#(Cycle);


		wr_en = 1;
		read_addr1 = 1;
		read_addr2 = 2;
		write_addr = 3;
		write_data = 32'hFEEDABBA;
		#(Cycle);
		wr_en = 0;
		read_addr1 = 3;
		read_addr2 = 2;
		#(Cycle);
		DUTout = read_data1;
		REFout = write_data;
		#1;
		checkOutput(read_addr1, read_addr2, write_addr, write_data, wr_en);

		
		//WRITE TO ZERO REG CASE
		wr_en = 1;
		read_addr1 = 1;
		read_addr2 = 2;
		write_addr = 5'b00000;
		write_data = 32'hFFFFFFFF;
		#(Cycle);
		wr_en = 0;
		read_addr1 = 0;
		read_addr2 = 2;
		#(Cycle);
		DUTout = read_data1;
		REFout = 0;
		#1;
		checkOutput(read_addr1, read_addr2, write_addr, write_data, wr_en);
	end

endmodule

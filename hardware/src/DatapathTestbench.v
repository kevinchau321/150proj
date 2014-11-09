module DatapathTestbench();
	reg clk;
	
	wire wb_val;

	`ifdef RISV_CLK_50
		parameter HalfCycle = 10;
	`endif `ifdef RISCV_CLK_100
		parameter HalfCycle = 5;
	`endif
		parameter Cycle = 2*HalfCycle;

	initial clk = 0;
	always #(HalfCycle) clk <= ~clk;
	
	
endmodule


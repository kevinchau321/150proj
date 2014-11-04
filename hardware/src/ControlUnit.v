`include "ALUdec.v"

module ControlUnit(
	input clk,
	input [6:0] opcode,
	input [2:0] funct3,
	input [6:0] funct7,
	input branch_taken,
	input [4:0] rs1,
	input [4:0] rs2,
	input [4:0] rd,
	output [3:0] ALUopX,
	output [1:0] PCsrcM,
	output [2:0] ALUsrcAX,
	output [1:0] ALUsrcBX,
	output wbsrcM,
	output Stall,
        output RegWrM);
   

	//HAZARD CONTROL
	reg [6:0] prevOpcode;
	reg [4:0] prevrs1, prevrs2, prevrd;

        
	reg [3:0] ALUopDreg;
	reg [3:0] ALUopXreg;
	reg [3:0] ALUopMreg;

	reg [2:0] ALUsrcADreg;
	reg [2:0] ALUsrcAXreg;
	reg [2:0] ALUsrcAMreg;

	reg [2:0] ALUsrcBDreg;
	reg [2:0] ALUsrcBXreg;
	reg [2:0] ALUsrcBMreg;

	reg [1:0] PCsrcDreg;
	reg [1:0] PCsrcXreg;
	reg [1:0] PCsrcMreg;

	reg wbsrcDreg;
	reg wbsrcXreg;
	reg wbsrcMreg;

	reg StallReg;
	
	reg RegWrDreg;
	reg RegWrXreg;
	reg RegWrMreg;
   
	always @(posedge clk) begin
		prevOpcode <= opcode;
		prevrs1 <= rs1;
		prevrs2 <= rs2;	
		prevrd <= rd;
	end

	assign ALUopX = ALUopXreg;
	assign ALUsrcAX = ALUsrcAXreg;
	assign ALUsrcBX = ALUsrcBXreg;
	assign PCsrcM = PCsrcMreg;
	assign wbsrcM = wbsrcMreg;
	assign Stall = StallReg;
	assign RegWrM = RegWrMreg;


	//pipline registers
	always @(posedge clk) begin
		ALUopXreg <= ALUopDreg;
		ALUopMreg <= ALUopXreg;
		
		ALUsrcAXreg <= ALUsrcADreg;
		ALUsrcAMreg <= ALUsrcAXreg;

		ALUsrcBXreg <= ALUsrcBDreg;
		ALUsrcBMreg <= ALUsrcBXreg;

		PCsrcXreg <= PCsrcDreg;
		PCsrcMreg <= PCsrcXreg;
		
		wbsrcXreg <= wbsrcDreg;
		wbsrcMreg <= wbsrcXreg;

		RegWrXreg <= RegWrDreg;
		RegWrMreg <= RegWrXreg;	
	end

	
	  ALUdec ALUdec(.opcode(opcode),
	  .funct(funct3),
	  .add_rshift_type(funct7 != 0), // add_rshift_type decides whether ADD or SUB
	  .ALUop(ALUopD));


	always @ (posedge clk) begin
		if (branch_taken || opcode == 7'b1101111 || opcode == 7'b1100111) begin			//jump or branch
			PCsrcDreg <= 3;	//target address for branch
			StallReg <= 1;
		end else begin
				if ((prevrd==rs1 || prevrd==rs2)&&(prevOpcode==0110011 && opcode == 0110011)) begin	//DATA HAZARD
					if (rs1 == prevrd) begin
						ALUsrcADreg <= 3; //FWDX FROM ALU RESULT OF PREVIIOUS INSTRUCTION
						ALUsrcBDreg <= 0;
					end else if (rs2 == prevrd) begin
						ALUsrcADreg <= 4;
						ALUsrcBDreg <= 1; //FWDX FROM ALU
					end
					RegWrDreg <= 1;
					PCsrcDreg <= 1;
					StallReg <= 0;
					wbsrcDreg <= 1; //ALU RESULTS
				end else if (prevOpcode==0000011) begin //LOAD HAZARD
					StallReg <= 1;			//stall in a NOP for the current instruction
					PCsrcDreg <= 0;			//reuses the instruction after load
					RegWrDreg <= 0;
				end else begin				//NO HAZARDS
				   case (opcode)
					7'b0110011: begin	//R-Type 
						RegWrDreg <= 1; 
						ALUsrcADreg <= 4;	//rd1 from reg
						ALUsrcBDreg <= 0;	//rd2 from reg
						PCsrcDreg <= 1;     //PC + 4;
						wbsrcDreg <= 1;     //ALUresult
						StallReg <= 0;	    //no stall
					   end
					7'b0010011: begin 	//shift
						RegWrDreg <= 1 ; 
						ALUsrcADreg <= 1;	//shamt	
						ALUsrcBDreg <= 0;	
						PCsrcDreg <= 1; 
						wbsrcDreg <= 1;  
						RegWrDreg <= 1;	   
						StallReg <= 0;
					   end
					7'b0000011: begin	//LOAD			NEEDS TO STALL NEXT INSTRUCTION
						RegWrDreg <= 1;
						ALUsrcADreg <= 4;
						ALUsrcBDreg <= 0;
						PCsrcDreg <= 1;
						wbsrcDreg <= 2;  
						RegWrDreg <= 1;	   
						StallReg <= 0;	
					   end
					7'b1100011: begin //Branch
						RegWrDreg <= 0;
						ALUsrcADreg <= 4;
						ALUsrcBDreg <= 0;
						PCsrcDreg <= 1;
						wbsrcDreg <= 0; //doesn't matter
						StallReg <= 0;
					end
				   endcase
				end // else: !if(prevOpcode==0000011)
		end // else: !if(branch_taken || opcode == 7'b1101111 || opcode == 7'b1100111)
	   
	end // always @ (posedge clk)
   
endmodule

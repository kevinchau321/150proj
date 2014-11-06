
module ControlUnit(
	input clk,
	input [6:0] opcode,
	input [2:0] funct3,
	input [6:0] funct7,
	input branch_taken,
	input [4:0] rs1,
	input [4:0] rs2,
	input [4:0] rd,
	input [31:0] memaddr,
	output [3:0] ALUopX,
	output [1:0] PCsrcM,
	output [2:0] ALUsrcAX,
	output [1:0] ALUsrcBX,
	output wbsrcM,
	output Stall,
        output RegWrM,
	output wire imem_en,
	output wire dmem_en,
	output wire [3:0] ibitmask,
	output wire [3:0] dbitmask);
   

	//HAZARD CONTROL
	reg [6:0] prevOpcode;
	reg [4:0] prevrs1, prevrs2, prevrd;

	//
        wire [3:0] ALUopD;
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

	reg ienD;
	reg ienX;
	reg ienM;

	reg denD;
	reg denX;
	reg denM;

	reg [3:0] ibitmaskregD;
	reg [3:0] ibitmaskregX;
	reg [3:0] ibitmaskregM;

	reg [3:0] dbitmaskregD;
	reg [3:0] dbitmaskregX;
	reg [3:0] dbitmaskregM;

	ALUdec ALUdec(.opcode(opcode),
	  .funct(funct3),
	  .add_rshift_type(funct7 != 0), // add_rshift_type decides whether ADD or SUB
	  .ALUop(ALUopD));


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
	assign ibitmask = ibitmaskregM;
	assign dbitmask = dbitmaskregM;
	assign imem_en = ienM;
	assign dmem_en = denM;


	//pipline registers
	always @(posedge clk) begin
		ALUopXreg <= ALUopD;
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
	
		ibitmaskregX <= ibitmaskregD;
		ibitmaskregM <= ibitmaskregX;

		dbitmaskregX <= dbitmaskregD;
		dbitmaskregM <= dbitmaskregX;

		ienX <= ienD;
		ienM <= ienX;
			
		denX <= denD;
		denM <= denX;
	end
		

	always @ (posedge clk) begin
		if (branch_taken || opcode == 7'b1101111 || opcode == 7'b1100111) begin			//jump or branch
			PCsrcDreg <= 3;	//target address for branch
			StallReg <= 1;
			ibitmaskregD <= 4'b0000; //disables writes imem
						dbitmaskregD <= 4'b0000; //disables writes dmem
						ienD <= 1;	//enables reads on imem
						denD <= 1;	//enables reads on dmem	
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
					ibitmaskregD <= 4'b0000; //disables writes imem
						dbitmaskregD <= 4'b0000; //disables writes dmem
						ienD <= 1;	//enables reads on imem
						denD <= 1;	//enables reads on dmem	
				end else if (prevOpcode==0000011) begin //LOAD HAZARD (DELAYS NEXT INSTRUCTION WITH NOP AND PC-->PC)
					StallReg <= 1;			//stall in a NOP for the current instruction
					PCsrcDreg <= 0;			//reuses the instruction after load
					RegWrDreg <= 0;
					ibitmaskregD <= 4'b0000; //disables writes imem
						dbitmaskregD <= 4'b0000; //disables writes dmem
						ienD <= 1;	//enables reads on imem
						denD <= 1;	//enables reads on dmem	
				end else begin				//NO HAZARDS
				   case (opcode)
					7'b0110011: begin	//R-Type 
						RegWrDreg <= 1; 
						ALUsrcADreg <= 0;	//rd1 from reg
						ALUsrcBDreg <= 0;	//rd2 from reg
						PCsrcDreg <= 1;     //PC + 4;
						wbsrcDreg <= 1;     //ALUresult
						StallReg <= 0;	    //no stall
						ibitmaskregD <= 4'b0000; //disables writes imem
						dbitmaskregD <= 4'b0000; //disables writes dmem
						ienD <= 1;	//enables reads on imem
						denD <= 1;	//enables reads on dmem	
					   end
					7'b0010011: begin 	//shift
						RegWrDreg <= 1 ; 
						ALUsrcADreg <= 0;	//rd1	
						ALUsrcBDreg <= 4;	//shamt
						PCsrcDreg <= 1; 
						wbsrcDreg <= 1;  
						RegWrDreg <= 1;	   
						StallReg <= 0;
						ibitmaskregD <= 4'b0000; //disables writes imem
						dbitmaskregD <= 4'b0000; //disables writes dmem
						ienD <= 1;	//enables reads on imem
						denD <= 1;	//enables reads on dmem	
					   end
					7'b0000011: begin	//LOAD			NEEDS TO STALL NEXT INSTRUCTION
						RegWrDreg <= 1;
						ALUsrcADreg <= 0;
						ALUsrcBDreg <= 0;
						PCsrcDreg <= 1;
						wbsrcDreg <= 2;  
						RegWrDreg <= 1;	   
						StallReg <= 0;	
						ibitmaskregD <= 4'b0000; //disables writes imem
						dbitmaskregD <= 4'b0000; //disables writes dmem
						ienD <= 1;	//enables reads on imem
						denD <= 1;	//enables reads on dmem	
					   end
					7'b1100011: begin //Branch
						RegWrDreg <= 0;
						ALUsrcADreg <= 0;	//rd1
						ALUsrcBDreg <= 0;	//rd2
						PCsrcDreg <= 1;
						wbsrcDreg <= 0; //doesn't matter
						StallReg <= 0;
						ibitmaskregD <= 4'b0000; //disables writes imem
						dbitmaskregD <= 4'b0000; //disables writes dmem
						ienD <= 1;	//enables reads on imem
						denD <= 1;	//enables reads on dmem	
					   end
					7'b0000011: begin		//I-TYPE;
						RegWrDreg <= 1;	//regfile write enabled
						ALUsrcADreg <= 0;	//rs1;
						ALUsrcBDreg <= 3; //sign extended I type immediate
						PCsrcDreg <= 1; //PC + 4;
						wbsrcDreg <= 1; //ALU results;
						StallReg <=0;
						ibitmaskregD <= 4'b0000; //disables writes imem
						dbitmaskregD <= 4'b0000; //disables writes dmem
						ienD <= 1;	//enables reads on imem
						denD <= 1;	//enables reads on dmem	
					   end
					7'b0100011: begin		//STORE
						ibitmaskregD <= 4'b0000; //disables writes imem
						dbitmaskregD <= 4'b0000; //disables writes dmem
						ienD <=0;
						denD <=0;
						if (memaddr[31]==0 && memaddr[28]==1) begin
							denD <= 1;
							case (funct3)
								3'b000:
									dbitmaskregD <= 4'b0001;
								3'b001:
									dbitmaskregD <= 4'b0011;
								3'b010:
									dbitmaskregD <= 4'b1111;
								endcase
						end
						if (memaddr[31]==0 && memaddr[29]==1) begin
							ienD <= 0;	//write only
							case (funct3)
								3'b000:
									ibitmaskregD <= 4'b0001;
								3'b001:
									ibitmaskregD <= 4'b0011;
								3'b010:
									ibitmaskregD <= 4'b1111;
							endcase
						end
						ALUsrcBDreg <= 0; 	///rs2 is the data written
						StallReg <=0;
						PCsrcDreg <= 1;
						RegWrDreg <= 0;	//dont write register on store
					   end
					
				   endcase
				end // else: !if(prevOpcode==0000011)
		end // else: !if(branch_taken || opcode == 7'b1101111 || opcode == 7'b1100111)
	   
	end // always @ (posedge clk)
   
endmodule

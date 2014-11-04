

/**
 * INST_DOUTB is the data out from the instruction memory block ram
 * INST_ADDRA is the input address to the instruction memory block ram
 * BRANCH_TAKEN is a 1 bit control signal if the Branch instruction is passed
 */

module Datapath ( input Clock, 
		  input Reset, 
		  input RegWr, 
		  input [31:0] inst_doutb, 
		  output [31:0] inst_addra, 
		  output dina, 
		  output branch_taken, 
		  input data_forward_ALU1, 
		  input data_forward_ALU2, 
		  input PC_sel, 
		  input dmem_out, 
		  input UART_out,
		  input wbsrc);

   wire       RegWrite; // Write enable  for RegFile.v
   wire [4:0] rs1, rs2, rd;
   wire [31:0] rd1, rd2; // Read Data from RegFile.v
   wire [31:0] fwd_x1,fwd_x2,fwd_m1,fwd_m2; // Data forwarding wires - x means from ALU Execute stage, m means from Memory stage
   wire [3:0] bitmask, op;
   wire [31:0] writeback_wire;
   wire [31:0]      ALUout;
   wire [11:0]	    itype_imm;
   

   reg [11:0] 	    target_addr;  
   reg [31:0] 	    PC;
   reg [31:0] wd;
   reg [31:0] wb_val;
   wire is_branch_inst;
   wire [1:0] PC_muxselect;
   wire [31:0] load_addr;
   reg [31:0] pipeline1_sign_ext;
   reg [31:0] pipeline1_ALUinputA;
   reg [31:0] pipeline1_ALUinputB;
   reg [31:0] pipeline1_npc;
   reg [31:0] pipeline2_npc;
   reg [31:0] pipeline2_ALUout; 
   reg [31:0] pipeline2_dmem_in;
   reg [31:0] pipeline2_dmem_data;
   reg [31:0] pipeline1_loadoffsetaddr;
   
   reg [4:0] rdX;
   reg [4:0] rdM;

   assign RegWrite = RegWr;
   assign is_branch_inst = branch_taken;
   assign PC_muxselect = PC_sel;

   // Instruction De-Mux
   assign rtype_funct7 = inst_doutb[31:25];
   assign funct = inst_doutb[14:12];
   assign opcode = inst_doutb[6:0];
   assign utype_imm = inst_doutb[31:12];
   assign itype_imm = inst_doutb[31:20];
   assign shamt = inst_doutb[24:20];
   assign stype_imm = {inst_doutb[31:25],inst_doutb[11:7]};
   
   // Register Wires
   assign rs1 = inst_doutb[19:15];
   assign rs2 = inst_doutb[24:20];
   assign rd = inst_doutb[11:7];

   assign ALUout = dina;
   assign signed_itype_imm = {itype_imm[11],itype_imm[11],itype_imm[11],itype_imm[11],itype_imm[11],itype_imm[11],itype_imm[11],itype_imm[11],itype_imm[11],itype_imm[11],itype_imm[11],itype_imm[11],itype_imm[11],itype_imm[11],itype_imm[11],itype_imm[11],itype_imm[11],itype_imm[11],itype_imm[11],itype_imm[11],itype_imm};
   assign zero_ext_shamt = {27'b0,shamt};

   ALU alu(.A(rs1out),
	   .B(rs2out),
	   .ALUop(op),
	   .Out(ALUout));

   RegFile register_file (.clk(Clock), 
	.we(RegWrite), 
	.ra1(rs1), 
	.ra2(rs2), 
	.wa(rdM), 
	.wd(writeback_wire), 
	.rd1(rd1), 
	.rd2(rd2));	

   LoadOffsetToAddr lota (.addr(rd1),
			.offset((opcode == 7'b0000011)? itype_imm: {rtype_funct7, rd}),
			.load_addr(load_addr));
 BranchCheckX branch_check(is_branch_inst, funct, rs1, rs2);
   
   always @(posedge Clock) begin
   	case (PC_muxselect)
     		0: PC <= PC;
     		1: PC <= PC + 4;
     		2: PC <= target_addr;
     		3: PC <= 0;
   	endcase
      
      case (opcode)  
	7'b1101111: begin // JAL instruction
	 target_addr <= {inst_doutb[31], inst_doutb[31], inst_doutb[31], inst_doutb[31],inst_doutb[31:12], 8'b0};
	 wb_val <= PC + 4;
	end
	7'b1100111: begin // JALR instruction
	 target_addr <= (rd1 + itype_imm) & 32'hFFFFFFFE;
	 wb_val <= PC + 4; 
	end
      endcase
       
   

      case (data_forward_ALU1)
	0: pipeline1_ALUinputA <= rd1;
	1: pipeline1_ALUinputA <= fwd_x1;
	2: pipeline1_ALUinputA <= fwd_m1;
      endcase // case (data_forward_ALU1)

      case (data_forward_ALU2)
	0: pipeline1_ALUinputB <= rd2;
	1: pipeline1_ALUinputB <= fwd_x2;
	2: pipeline1_ALUinputB <= fwd_m2;
	endcase	

      case (wbsrc)
	0: wb_val <= PC+4;	//from Execute Stage
	1: wb_val <= ALUout;
	2: wb_val <= dmem_out;
	3: wb_val <= UART_out;
      endcase

	// Pipelining Stage 1
	pipeline1_sign_ext <= signed_itype_imm;
	pipeline1_npc <= PC + 4;
	pipeline1_loadoffsetaddr <= load_addr;
	rdX <= rd;


	// Pipelining Stage 2
	pipeline2_npc <= pipeline1_npc;
	pipeline2_ALUout <= ALUout;
	pipeline2_dmem_in <= pipeline1_loadoffsetaddr;
	pipeline2_dmem_data <= pipeline1_ALUinputB;
	rdM <= rdX;
   end
endmodule   

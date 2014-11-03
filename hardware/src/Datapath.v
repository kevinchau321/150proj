/**
 * INST_DOUTB is the data out from the instruction memory block ram
 * INST_ADDRA is the input address to the instruction memory block ram
 * BRANCH_TAKEN is a 1 bit control signal if the Branch instruction is passed
 */

module Datapath ( input Clock, input Reset, input RegWr, input [31:0] inst_doutb, output [31:0] inst_addra, output dina, output branch_taken, input data_forward_ALU1, input data_forward_ALU2, input PC_sel, input dmem_out, input UART_out);

   wire       RegWr; // Write enable  for RegFile.v
   wire [4:0] rs1, rs2, wa;
   wire [31:0] rd1, rd2; // Read Data from RegFile.v
   wire [31:0] fwd_x1,fwd_x2,fwd_m1,fwd_m2; // Data forwarding wires - x means from ALU Execute stage, m means from Memory stage
   wire [3:0] bitmask, op;
   wire [11:0] target_addr;
   reg [31:0] PC;
   reg [31:0] wd; 
   reg branch_taken;
   wire [1:0] PC_sel;
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
   
   // Instruction De-Mux
   assign rtype_funct7 = inst_doutb[31:25];
   assign funct = inst_doutb[14:12];
   assign opcode = inst_doutb[6:0];
   assign utype_imm = inst_doutb[31:12];
   assign itype_imm = inst_doutb[31:20];
   assign shamt = inst_doutb[24:20];
   assign stype_imm = {inst_doutb[31:25],inst_doutb[11:7]};
   
   // Register Wires
   assign rs1 = imem_mem[19:15];
   assign rs2 = imem_mem[24:20];
   assign wa = imem_mem[11:7];

   assign dina = ALUout;
   assign signed_itype_imm = {itype_imm[11],itype_imm[11],itype_imm[11],itype_imm[11],itype_imm[11],itype_imm[11],itype_imm[11],itype_imm[11],itype_imm[11],itype_imm[11],itype_imm[11],itype_imm[11],itype_imm[11],itype_imm[11],itype_imm[11],itype_imm[11],itype_imm[11],itype_imm[11],itype_imm[11],itype_imm[11],itype_imm};
   assign zero_ext_shamt = {27'b0,shamt};

   ALU alu(.A(rs1out),
	   .B(rs2out),
	   .ALUop(op),
	   .Out(ALUout);

   RegFile register_file (.clk(Clock), 
	.we(RegWr), 
	.ra1(rs1), 
	.ra2(rs2), 
	.wa(wa), 
	.wd(wb_val), 
	.rd1(rd1), 
	.rd2(rd2));	

   LoadOffsetToAddr lota (.addr(rd1),
			.offset((opcode == 7'b0000011)? itype_imm: {rtype_funct7, wa}),
			.load_addr(load_addr));

   
   always @(posedge Clock) begin
   	case (PC_sel)
     		0: PC <= PC;
     		1: PC <= PC + 4;
     		2: PC <= 0;
     		3: PC <= target_addr;
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
	7'b0000011: begin // Load instruction
	   dmem_offset <= itype_imm;
	end
	7'b0100011: begin // Store instruction
	   dmem_offset <= stype_imm;
	end
      endcase
       
      BranchCheckX branch_check (branch_taken, funct, rs1, rs2);

      case (data_forward_ALU1)
	0: ALU_inputA <= rs1;
	1: ALU_inputA <= fwd_x1;
	2: ALU_inputA <= fwd_m1;
      endcase // case (data_forward_ALU1)

      case (data_forward_ALU2)
	0: ALU_inputB <= rs2;
	1: ALU_inputB <= fwd_x2;
	2: ALU_inputB <= fwd_m2;
	endcase	

      case (MemToReg)
	0: wb_val <= PC+4;	//from Execute Stage
	1: wb_val <= ALUout;
	2: wb_val <= dmem_out;
	3: wb_val <= UART_out;
      endcase

	// Pipelining Stage 1
	pipeline1_sign_ext <= signed_itype_imm;
	pipeline1_ALUinputA <= ALU_inputA;
	pipeline1_ALUinputB <= ALU_inputB;
	pipeline1_npc <= PC + 4;
	pipeline1_loadoffsetaddr <= load_addr;

	// Pipelining Stage 2
	pipeline2_npc <= pipeline1_npc;
	pipeline2_ALUout <= ALUout;
	pipeline2_dmem_in <= pipeline1_loadoffsetaddr;
	pipeline2_dmem_data <= pipeline1_ALUinputB;

   end
endmodule   

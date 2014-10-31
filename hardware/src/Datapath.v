module Datapath ( input Clock, input Reset, input PC_sel);

   reg [31:0] PC;

   wire       wr_en, rd_en;
   wire [4:0] rs1, rs2, rd;
   

//   imem_blk_ram inst_memory ();

//   dmem_blk_ram inst_memory();

   
   assign funct = imem_mem[11:7];
   assign opcode = imem_mem[6:0];
   assign utype_imm = imem_mem[31:12];
   assign itype_imm = imem_mem[31:20];
   

   assign rs1 = imem_mem[19:15];
   assign rs2 = imem_mem[24:20];
   
   RegFile register_file ();
   
   always @(posedge Clock) begin
   case (PC_sel)
     0: PC <= PC;
     1: PC <= PC + 4;
     2: PC <= 0;
     3: PC <= br_addr;
   endcase

      opcode <= imem_dout[6:0];
      
      case (opcode)  
	7'b1101111: begin // JAL instruction
	 br_addr <= imem_dout[31:12];
	 rd <= PC + 4;
      end

      
      
      
   end
endmodule   

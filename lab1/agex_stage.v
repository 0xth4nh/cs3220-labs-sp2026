`include "define.vh" 

module AGEX_STAGE(
  input wire clk,
  input wire reset,
  input wire [`from_MEM_to_AGEX_WIDTH-1:0] from_MEM_to_AGEX,    
  input wire [`from_WB_to_AGEX_WIDTH-1:0] from_WB_to_AGEX,   
  input wire [`DE_latch_WIDTH-1:0] from_DE_latch,
  output wire [`AGEX_latch_WIDTH-1:0] AGEX_latch_out,
  output wire [`from_AGEX_to_FE_WIDTH-1:0] from_AGEX_to_FE,
  output wire [`from_AGEX_to_DE_WIDTH-1:0] from_AGEX_to_DE
);

  `UNUSED_VAR (from_MEM_to_AGEX)
  `UNUSED_VAR (from_WB_to_AGEX)

  reg [`AGEX_latch_WIDTH-1:0] AGEX_latch; 
  // wire to send the AGEX latch contents to other pipeline stages 
  assign AGEX_latch_out = AGEX_latch;
  
  wire[`AGEX_latch_WIDTH-1:0] AGEX_latch_contents; 
  
  wire valid_AGEX; 
  wire [`INSTBITS-1:0]inst_AGEX; 
  wire [`DBITS-1:0]PC_AGEX;
  wire [`DBITS-1:0] inst_count_AGEX; 
  wire [`DBITS-1:0] pcplus_AGEX; 
  wire [`IOPBITS-1:0] op_I_AGEX;
  reg br_cond_AGEX; // 1 means a branch condition is satisified. 0 means a branch condition is not satisifed
 
  /////////////////////////////////////////////////////////////////////////////
  // TODO: Complete remaining code logic here!

  wire is_br_AGEX;
  wire wr_reg_AGEX;
  wire [`REGNOBITS-1:0] wregno_AGEX;

  wire [`DBITS-1:0] regval1_AGEX;
  wire [`DBITS-1:0] regval2_AGEX;
  wire [`DBITS-1:0] sxt_imm_AGEX;
  
  wire is_load_AGEX;   // is load instruction
  wire is_store_AGEX;  // is store instruction

  reg [`DBITS-1:0] br_target_AGEX;
  wire br_mispred_AGEX;

  reg [`DBITS-1:0] aluout_AGEX;
  
  // Calculate branch condition
  // Signed comparison wires
  wire signed [`DBITS-1:0] s_regval1_AGEX;
  wire signed [`DBITS-1:0] s_regval2_AGEX;
  assign s_regval1_AGEX = regval1_AGEX;
  assign s_regval2_AGEX = regval2_AGEX;
  
  always @ (*) begin
    case (op_I_AGEX)
      `BEQ_I  : br_cond_AGEX = (regval1_AGEX == regval2_AGEX);           // Branch if equal
      `BNE_I  : br_cond_AGEX = (regval1_AGEX != regval2_AGEX);           // Branch if not equal
      `BLT_I  : br_cond_AGEX = (s_regval1_AGEX < s_regval2_AGEX);        // Branch if less than (signed)
      `BGE_I  : br_cond_AGEX = (s_regval1_AGEX >= s_regval2_AGEX);       // Branch if greater or equal (signed)
      `BLTU_I : br_cond_AGEX = (regval1_AGEX < regval2_AGEX);            // Branch if less than (unsigned)
      `BGEU_I : br_cond_AGEX = (regval1_AGEX >= regval2_AGEX);           // Branch if greater or equal (unsigned)
      default : br_cond_AGEX = 1'b0;
    endcase
  end

  // Compute ALU operations  (alu out or memory addresses)
  // Signed wires for signed operations
  wire signed [`DBITS-1:0] s_regval1_ALU;
  wire signed [`DBITS-1:0] s_sxt_imm;
  assign s_regval1_ALU = regval1_AGEX;
  assign s_sxt_imm = sxt_imm_AGEX;
  
  always @ (*) begin
    case (op_I_AGEX)
      // Arithmetic
      `ADD_I:   aluout_AGEX = regval1_AGEX + regval2_AGEX;                    // ADD: rd = rs1 + rs2
      `SUB_I:   aluout_AGEX = regval1_AGEX - regval2_AGEX;                    // SUB: rd = rs1 - rs2
      `ADDI_I:  aluout_AGEX = regval1_AGEX + sxt_imm_AGEX;                    // ADDI: rd = rs1 + imm
      
      // Logic operations
      `AND_I:   aluout_AGEX = regval1_AGEX & regval2_AGEX;                    // AND: rd = rs1 & rs2
      `ANDI_I:  aluout_AGEX = regval1_AGEX & sxt_imm_AGEX;                    // ANDI: rd = rs1 & imm
      `OR_I:    aluout_AGEX = regval1_AGEX | regval2_AGEX;                    // OR: rd = rs1 | rs2
      `ORI_I:   aluout_AGEX = regval1_AGEX | sxt_imm_AGEX;                    // ORI: rd = rs1 | imm
      `XOR_I:   aluout_AGEX = regval1_AGEX ^ regval2_AGEX;                    // XOR: rd = rs1 ^ rs2
      `XORI_I:  aluout_AGEX = regval1_AGEX ^ sxt_imm_AGEX;                    // XORI: rd = rs1 ^ imm
      
      // Shifts
      `SLL_I:   aluout_AGEX = regval1_AGEX << regval2_AGEX[4:0];              // SLL: rd = rs1 << rs2[4:0]
      `SLLI_I:  aluout_AGEX = regval1_AGEX << sxt_imm_AGEX[4:0];              // SLLI: rd = rs1 << imm[4:0]
      `SRL_I:   aluout_AGEX = regval1_AGEX >> regval2_AGEX[4:0];              // SRL: rd = rs1 >> rs2[4:0] (logical)
      `SRLI_I:  aluout_AGEX = regval1_AGEX >> sxt_imm_AGEX[4:0];              // SRLI: rd = rs1 >> imm[4:0] (logical)
      `SRA_I:   aluout_AGEX = s_regval1_ALU >>> regval2_AGEX[4:0];            // SRA: rd = rs1 >>> rs2[4:0] (arithmetic)
      `SRAI_I:  aluout_AGEX = s_regval1_ALU >>> sxt_imm_AGEX[4:0];            // SRAI: rd = rs1 >>> imm[4:0] (arithmetic)
      
      // Set less than
      `SLT_I:   aluout_AGEX = (s_regval1_AGEX < s_regval2_AGEX) ? 1 : 0;      // SLT: rd = (rs1 < rs2) signed
      `SLTI_I:  aluout_AGEX = (s_regval1_ALU < s_sxt_imm) ? 1 : 0;            // SLTI: rd = (rs1 < imm) signed
      `SLTU_I:  aluout_AGEX = (regval1_AGEX < regval2_AGEX) ? 1 : 0;          // SLTU: rd = (rs1 < rs2) unsigned
      `SLTIU_I: aluout_AGEX = (regval1_AGEX < sxt_imm_AGEX) ? 1 : 0;          // SLTIU: rd = (rs1 < imm) unsigned
      
      // Upper immediate
      `AUIPC_I: aluout_AGEX = PC_AGEX + sxt_imm_AGEX;                         // AUIPC: rd = PC + (imm << 12)
      `LUI_I:   aluout_AGEX = sxt_imm_AGEX;                                   // LUI: rd = imm << 12 (already shifted)
      
      // Jump
      `JAL_I:   aluout_AGEX = pcplus_AGEX;                                    // JAL: rd = PC + 4 (return address)
      `JALR_I:  aluout_AGEX = pcplus_AGEX;                                    // JALR: rd = PC + 4 (return address)
      
      // Memory (address calculation)
      `LW_I:    aluout_AGEX = regval1_AGEX + sxt_imm_AGEX;                    // LW: addr = rs1 + offset
      `SW_I:    aluout_AGEX = regval1_AGEX + sxt_imm_AGEX;                    // SW: addr = rs1 + offset
      
      default: begin
        aluout_AGEX  = '0;
      end
    endcase
  end 

  // branch target needs to be computed here 
  // computed branch target needs to send to other pipeline stages (br_target_AGEX)
  // TODO: complete the code
  wire is_jmp_AGEX;  // JAL or JALR are unconditional jumps
  assign is_jmp_AGEX = (op_I_AGEX == `JAL_I) || (op_I_AGEX == `JALR_I);
  
  always @(*)begin
    if (op_I_AGEX == `JAL_I) 
      br_target_AGEX = PC_AGEX + sxt_imm_AGEX;                    // JAL: target = PC + offset
    else if (op_I_AGEX == `JALR_I)
      br_target_AGEX = (regval1_AGEX + sxt_imm_AGEX) & ~32'h1;   // JALR: target = (rs1 + imm) & ~1
    else if (is_br_AGEX && br_cond_AGEX) 
      br_target_AGEX = PC_AGEX + sxt_imm_AGEX;                    // Branch target = PC + offset
    else
      br_target_AGEX = pcplus_AGEX;                               // No branch, continue to next instruction
  end

  // Branch misprediction occurs when:
  // 1. Branch is taken (since we predict not-taken)
  // 2. JAL or JALR (always mispredicted since we predict not-taken)
  assign br_mispred_AGEX = ((is_br_AGEX && br_cond_AGEX) || is_jmp_AGEX) ? 1 : 0;

    assign  {                     
                                  valid_AGEX,
                                  inst_AGEX,
                                  PC_AGEX,
                                  pcplus_AGEX,
                                  op_I_AGEX,
                                  inst_count_AGEX,
                                  //  TODO: more signals might needed
                                  regval1_AGEX,
                                  regval2_AGEX,
                                  sxt_imm_AGEX,
                                  is_br_AGEX,
                                  wr_reg_AGEX,
                                  wregno_AGEX,
                                  is_load_AGEX,
                                  is_store_AGEX
                                  } = from_DE_latch; 
    
 
  assign AGEX_latch_contents = {
                                valid_AGEX,
                                inst_AGEX,
                                PC_AGEX,
                                op_I_AGEX,
                                inst_count_AGEX,
                                // TODO: more signals might needed
                                aluout_AGEX,
                                wr_reg_AGEX,
                                wregno_AGEX,
                                is_load_AGEX,
                                is_store_AGEX,
                                regval2_AGEX  // for SW: data to write
                                 }; 
 
  always @ (posedge clk ) begin
    if(reset) begin
      AGEX_latch <= {`AGEX_latch_WIDTH{1'b0}};
        end 
    else 
        begin
            AGEX_latch <= AGEX_latch_contents ;
        end 
  end


  // forward signals to FE stage
  assign from_AGEX_to_FE = { 
      //  TODO: more signals might needed
      br_mispred_AGEX,
      br_target_AGEX
  };

  // forward signals to DE stage
  assign from_AGEX_to_DE = { 
    //  TODO: more signals might needed
    br_mispred_AGEX
  };

endmodule

 `include "define.vh" 


module FE_STAGE(
  input wire clk,
  input wire reset,
  input wire [`from_DE_to_FE_WIDTH-1:0] from_DE_to_FE,
  input wire [`from_AGEX_to_FE_WIDTH-1:0] from_AGEX_to_FE,   
  input wire [`from_MEM_to_FE_WIDTH-1:0] from_MEM_to_FE,   
  input wire [`from_WB_to_FE_WIDTH-1:0] from_WB_to_FE, 
  output wire [`FE_latch_WIDTH-1:0] FE_latch_out
);

  `UNUSED_VAR (from_MEM_to_FE)
  `UNUSED_VAR (from_WB_to_FE)

  // I-MEM
  (* ram_init_file = `IDMEMINITFILE *)
  reg [`DBITS-1:0] imem [`IMEMWORDS-1:0];
 
  initial begin
      $readmemh(`IDMEMINITFILE , imem);
  end

  /* pipeline latch */ 
  reg [`FE_latch_WIDTH-1:0] FE_latch;
  wire valid_FE;
  assign valid_FE = 1'b1;

  reg [`DBITS-1:0] PC_FE_latch;
  
  reg [`DBITS-1:0] inst_count_FE;

  wire [`INSTBITS-1:0] inst_FE;
  wire [`DBITS-1:0] pcplus_FE;
  wire stall_pipe_FE;
  
  wire [`FE_latch_WIDTH-1:0] FE_latch_contents;
  
  assign inst_FE = imem[PC_FE_latch[`IMEMADDRBITS-1:`IMEMWORDBITS]];
  
  assign FE_latch_out = FE_latch; 

  assign pcplus_FE = PC_FE_latch + `INSTSIZE;

  // ============ Branch Predictor Structures ============

  // Branch History Register (8 bits)
  reg [7:0] BHR;

  // Pattern History Table: 256 entries of 2-bit saturating counters
  reg [1:0] PHT [0:255];

  // Branch Target Buffer: 16 entries (valid, tag[25:0], target[31:0])
  reg btb_valid [0:15];
  reg [25:0] btb_tag [0:15];
  reg [`DBITS-1:0] btb_target [0:15];

  // PHT index = PC[9:2] XOR BHR
  wire [7:0] pht_index_FE;
  assign pht_index_FE = PC_FE_latch[9:2] ^ BHR;

  // BTB lookup using PC[5:2]
  wire [3:0] btb_index_FE;
  assign btb_index_FE = PC_FE_latch[5:2];

  wire btb_hit_FE;
  assign btb_hit_FE = btb_valid[btb_index_FE] && (btb_tag[btb_index_FE] == PC_FE_latch[31:6]);

  // PHT prediction: taken if counter >= 2 (i.e., MSB is 1)
  wire pht_taken_FE;
  assign pht_taken_FE = PHT[pht_index_FE][1];

  // Predicted next PC: BTB target if hit and predicted taken, else PC+4
  wire [`DBITS-1:0] predicted_next_pc_FE;
  assign predicted_next_pc_FE = (btb_hit_FE && pht_taken_FE) ? btb_target[btb_index_FE] : pcplus_FE;

  // ============ Signals from AGEX for BP Updates ============

  wire br_mispred_AGEX;
  wire [`DBITS-1:0] br_target_AGEX;
  wire update_bp_AGEX;
  wire [`DBITS-1:0] btb_write_pc_AGEX;
  wire [`DBITS-1:0] btb_write_target_AGEX;
  wire [7:0] pht_update_index_AGEX;
  wire br_taken_AGEX;

  assign {
    stall_pipe_FE
  } = from_DE_to_FE[0]; 

  assign {
    br_mispred_AGEX,
    br_target_AGEX,
    update_bp_AGEX,
    btb_write_pc_AGEX,
    btb_write_target_AGEX,
    pht_update_index_AGEX,
    br_taken_AGEX
  } = from_AGEX_to_FE;

  // ============ FE Latch Contents ============

  assign FE_latch_contents = {
    valid_FE, 
    inst_FE, 
    PC_FE_latch, 
    pcplus_FE,
    inst_count_FE,
    pht_index_FE,
    predicted_next_pc_FE
  };

  // ============ PC Update Logic ============

  always @ (posedge clk) begin
    if (reset) begin 
      PC_FE_latch <= `STARTPC;
      inst_count_FE <= 1;
    end 
    else if (br_mispred_AGEX)
      PC_FE_latch <= br_target_AGEX;
    else if (stall_pipe_FE) 
      PC_FE_latch <= PC_FE_latch; 
    else begin 
      PC_FE_latch <= predicted_next_pc_FE;
      inst_count_FE <= inst_count_FE + 1; 
    end 
  end

  // ============ FE Latch Update ============

  always @ (posedge clk) begin
    if (reset) begin 
      FE_latch <= '0; 
    end else begin 
      if (br_mispred_AGEX)
        FE_latch <= '0;
      else if (stall_pipe_FE)
        FE_latch <= FE_latch; 
      else 
        FE_latch <= FE_latch_contents; 
    end  
  end

  // ============ BTB / PHT / BHR Updates from AGEX ============

  integer i;
  always @ (posedge clk) begin
    if (reset) begin
      BHR <= 8'b0;
      for (i = 0; i < 256; i = i + 1)
        PHT[i] = 2'b01;
      for (i = 0; i < 16; i = i + 1) begin
        btb_valid[i] = 1'b0;
        btb_tag[i] = 26'b0;
        btb_target[i] = 32'b0;
      end
    end else if (update_bp_AGEX) begin
      // BTB update
      btb_valid[btb_write_pc_AGEX[5:2]] <= 1'b1;
      btb_tag[btb_write_pc_AGEX[5:2]] <= btb_write_pc_AGEX[31:6];
      btb_target[btb_write_pc_AGEX[5:2]] <= btb_write_target_AGEX;

      // PHT update (2-bit saturating counter)
      if (br_taken_AGEX) begin
        if (PHT[pht_update_index_AGEX] < 2'b11)
          PHT[pht_update_index_AGEX] <= PHT[pht_update_index_AGEX] + 1;
      end else begin
        if (PHT[pht_update_index_AGEX] > 2'b00)
          PHT[pht_update_index_AGEX] <= PHT[pht_update_index_AGEX] - 1;
      end

      // BHR update (left shift, insert outcome in LSB)
      BHR <= {BHR[6:0], br_taken_AGEX};
    end
  end

endmodule

module Pipe_ID_EX (
    input clk,
    input rst_n, 
    input clr,
    
    // =================================================
    // INPUTS (Coming from Decode Stage) suffix: _D
    // =================================================
    
    // Control Signals
    input RegWrite_D,
    input [1:0] ResultSrc_D,
    input MemWrite_D,
    input Jump_D,
    input Branch_D,
    input [2:0] ALUControl_D,
    input ALUSrc_D,
    
    // Data Signals
    input [31:0] RD1_D,
    input [31:0] RD2_D,
    input [31:0] PC_D,
    input [31:0] ImmExt_D,
    input [31:0] PCPlus4_D,
    
    // Addresses
    input [4:0]  Rd_D,
    input [4:0]  Rs1_D, // Fixed name (was Rs1D)
    input [4:0]  Rs2_D, // Fixed name (was Rs2D)
    
    // =================================================
    // OUTPUTS (Going to Execute Stage) suffix: _E
    // =================================================
    
    output reg         RegWrite_E,
    output reg [1:0]   ResultSrc_E,
    output reg         MemWrite_E,
    output reg         Jump_E,
    output reg         Branch_E,
    output reg [2:0]   ALUControl_E,
    output reg         ALUSrc_E,
    
    output reg [31:0]  RD1_E,
    output reg [31:0]  RD2_E,
    output reg [31:0]  PC_E,
    output reg [31:0]  ImmExt_E,
    output reg [31:0]  PCPlus4_E,
    output reg [4:0]   Rd_E,
    output reg [4:0]   Rs1_E,
    output reg [4:0]   Rs2_E
);

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            // Async Reset
            RegWrite_E   <= 1'b0;
            ResultSrc_E  <= 2'b0;
            MemWrite_E   <= 1'b0;
            Jump_E       <= 1'b0;
            Branch_E     <= 1'b0;
            ALUControl_E <= 3'b0;
            ALUSrc_E     <= 1'b0;
            RD1_E        <= 32'b0;
            RD2_E        <= 32'b0;
            PC_E         <= 32'b0;
            ImmExt_E     <= 32'b0;
            PCPlus4_E    <= 32'b0;
            Rd_E         <= 5'b0;
            Rs1_E        <= 5'b0;
            Rs2_E        <= 5'b0;
        end 
        else if (clr) begin
            // Synchronous Flush (Bubble)
            RegWrite_E   <= 1'b0;
            ResultSrc_E  <= 2'b0;
            MemWrite_E   <= 1'b0;
            Jump_E       <= 1'b0;
            Branch_E     <= 1'b0;
            ALUControl_E <= 3'b0;
            ALUSrc_E     <= 1'b0;
            // Note: Data signals don't strictly need clearing, 
            // but Control signals MUST be 0 to prevent accidental writes.
            RD1_E        <= 32'b0;
            RD2_E        <= 32'b0;
            PC_E         <= 32'b0;
            ImmExt_E     <= 32'b0;
            PCPlus4_E    <= 32'b0;
            Rd_E         <= 5'b0;
            Rs1_E        <= 5'b0;
            Rs2_E        <= 5'b0;
        end 
        else begin
            // Normal Operation
            RegWrite_E   <= RegWrite_D;
            ResultSrc_E  <= ResultSrc_D;
            MemWrite_E   <= MemWrite_D;
            Jump_E       <= Jump_D;
            Branch_E     <= Branch_D;
            ALUControl_E <= ALUControl_D;
            ALUSrc_E     <= ALUSrc_D;
            RD1_E        <= RD1_D;
            RD2_E        <= RD2_D;
            PC_E         <= PC_D;
            ImmExt_E     <= ImmExt_D;
            PCPlus4_E    <= PCPlus4_D;
            Rd_E         <= Rd_D;
            Rs1_E        <= Rs1_D;
            Rs2_E        <= Rs2_D;
        end
    end

endmodule
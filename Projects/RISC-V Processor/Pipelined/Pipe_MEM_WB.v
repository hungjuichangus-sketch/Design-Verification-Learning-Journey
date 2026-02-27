module Pipe_MEM_WB (
    input  wire        clk,
    input  wire        rst_n,

    // =================================================
    // INPUTS (Coming from Memory Stage) suffix: _M
    // =================================================

    // Control Signals (Only those needed for Writeback)
    input  wire        RegWrite_M,
    input  wire [1:0]  ResultSrc_M,
    
    // Data Signals
    input  wire [31:0] ALUResult_M,
    input  wire [31:0] ReadData_M,  // Data read from Memory
    input  wire [4:0]  Rd_M,        // Destination Register
    input  wire [31:0] PCPlus4_M,   // Passed down for JAL/JALR writeback

    // =================================================
    // OUTPUTS (Going to Writeback Stage) suffix: _W
    // =================================================

    output reg         RegWrite_W,
    output reg [1:0]   ResultSrc_W,

    output reg [31:0]  ALUResult_W,
    output reg [31:0]  ReadData_W,
    output reg [4:0]   Rd_W,
    output reg [31:0]  PCPlus4_W
);

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            RegWrite_W  <= 1'b0;
            ResultSrc_W <= 2'b0;
            ALUResult_W <= 32'b0;
            ReadData_W  <= 32'b0;
            Rd_W        <= 5'b0;
            PCPlus4_W   <= 32'b0;
        end else begin
            RegWrite_W  <= RegWrite_M;
            ResultSrc_W <= ResultSrc_M;
            ALUResult_W <= ALUResult_M;
            ReadData_W  <= ReadData_M;
            Rd_W        <= Rd_M;
            PCPlus4_W   <= PCPlus4_M;
        end
    end

endmodule
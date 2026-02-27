module Pipe_EX_MEM (
    input  wire        clk,
    input  wire        rst_n,

    // =================================================
    // INPUTS (Coming from Execute Stage) suffix: _E
    // =================================================

    // Control Signals (Only those needed for MEM and WB stages)
    input  wire        RegWrite_E,
    input  wire [1:0]  ResultSrc_E,
    input  wire        MemWrite_E,
    
    // Data Signals
    input  wire [31:0] ALUResult_E,
    input  wire [31:0] WriteData_E, // This is RD2_E (data to be written to memory)
    input  wire [4:0]  Rd_E,        // Destination Register
    input  wire [31:0] PCPlus4_E,   // Passed down for JAL/JALR writeback

    // =================================================
    // OUTPUTS (Going to Memory Stage) suffix: _M
    // =================================================

    output reg         RegWrite_M,
    output reg [1:0]   ResultSrc_M,
    output reg         MemWrite_M,

    output reg [31:0]  ALUResult_M,
    output reg [31:0]  WriteData_M,
    output reg [4:0]   Rd_M,
    output reg [31:0]  PCPlus4_M
);

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            RegWrite_M  <= 1'b0;
            ResultSrc_M <= 2'b0;
            MemWrite_M  <= 1'b0;
            ALUResult_M <= 32'b0;
            WriteData_M <= 32'b0;
            Rd_M        <= 5'b0;
            PCPlus4_M   <= 32'b0;
        end else begin
            RegWrite_M  <= RegWrite_E;
            ResultSrc_M <= ResultSrc_E;
            MemWrite_M  <= MemWrite_E;
            ALUResult_M <= ALUResult_E;
            WriteData_M <= WriteData_E;
            Rd_M        <= Rd_E;
            PCPlus4_M   <= PCPlus4_E;
        end
    end

endmodule
module DataMemory(
    input         clk,
    input         WE,      // Write Enable
    input  [31:0] A,       // Address (from ALU)
    input  [31:0] WD,      // Write Data (from Register File RD2)
    output [31:0] RD       // Read Data
);

    // 64 words of data memory
    reg [31:0] RAM [63:0];

    // Combinational Read
    // Again, ignore bottom 2 bits for word alignment
    assign RD = RAM[A[31:2]];

    // Synchronous Write
    always @(posedge clk) begin
        if (WE) begin
            RAM[A[31:2]] <= WD;
        end
    end

endmodule
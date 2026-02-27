module Pipe_IF_ID (
    input clk,
    input rst_n,
    input en, 
    input clr,
    
    // INPUTS (From Fetch)
    input [31:0] PC_F,
    input [31:0] Instr_F,
    input [31:0] PCPlus4_F,
    
    // OUTPUTS (To Decode)
    output reg [31:0]  PC_D,
    output reg [31:0]  Instr_D,
    output reg [31:0]  PCPlus4_D
);

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            // Async Reset
            PC_D      <= 32'd0;
            Instr_D   <= 32'd0;
            PCPlus4_D <= 32'd0;
        end 
        else if (clr) begin
            // Synchronous Flush (Clear on Branch/Jump)
            PC_D      <= 32'd0;
            Instr_D   <= 32'd0;
            PCPlus4_D <= 32'd0;
        end 
        else if (en) begin
            // Normal Update (Enable is High)
            PC_D      <= PC_F;
            Instr_D   <= Instr_F;
            PCPlus4_D <= PCPlus4_F;
        end
        // If !en (Stall), do nothing -> hold previous value
    end

endmodule
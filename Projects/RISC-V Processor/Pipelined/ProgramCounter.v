module ProgramCounter (
	input clk, rst_n, en,
	input [31:0] PCNext,
	output reg [31:0] PC
);

	always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            PC <= 32'd0;
        end 
        else if (en) begin // Only update if enabled
            PC <= PCNext;
        end
        // If !en, keep old value (Stall)
    end

endmodule
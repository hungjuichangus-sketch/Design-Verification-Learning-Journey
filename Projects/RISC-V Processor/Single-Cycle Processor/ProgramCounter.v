module ProgramCounter (
	input clk, rst_n,
	input [31:0] PCNext,
	output reg [31:0] PC
);

	always @(posedge clk or negedge rst_n)begin
		if(!rst_n) begin
			PC <= 32'd0;
		end else begin
			PC <= PCNext;
		end
	end

endmodule
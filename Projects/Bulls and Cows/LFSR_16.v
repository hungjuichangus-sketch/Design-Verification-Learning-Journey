module LFSR_16(
	input clk,
	input rst_n,
	output [15:0] lfsr_out
);
	reg [15:0] shift_reg;
	
	wire feedback = shift_reg[15] ^ shift_reg[14] ^ shift_reg[12] ^ shift_reg[3];
	always @(posedge clk or negedge rst_n)begin
		if (!rst_n)begin
			shift_reg <= 16'hACE1;
		end else begin
			shift_reg <= {shift_reg[14:0], feedback};
		end
	end
	assign lfsr_out = shift_reg;
endmodule
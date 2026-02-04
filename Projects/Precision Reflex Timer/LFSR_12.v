module LFSR_12(
	input clk,
	input rst_n,
	output [11:0] lfsr_out
);
	reg [11:0] shift_reg;
	
	wire feedback = shift_reg[11] ^ shift_reg[10] ^ shift_reg[9] ^ shift_reg[3];
	always @(posedge clk or negedge rst_n)begin
		if (!rst_n)begin
			shift_reg <= 12'hACE;
		end else begin
			shift_reg <= {shift_reg[10:0], feedback};
		end
	end
	assign lfsr_out = shift_reg;
endmodule

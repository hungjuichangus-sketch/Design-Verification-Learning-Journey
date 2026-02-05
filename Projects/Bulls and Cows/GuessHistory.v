module GuessHistory(
	input clk, rst_n, WE,
	input [3:0] write_addr, read_addr,
	input [21:0] guess,
	output [21:0] history_out
);
	reg [21:0] mem [0:8];
	integer i;
	always @(posedge clk or negedge rst_n)begin
		if(!rst_n)begin
			for(i = 0; i < 9; i = i + 1)begin
				mem[i] = 22'd0;
			end
		end else begin
			if(WE) mem[write_addr] <= guess;
		end
	end
	assign history_out = mem[read_addr];
endmodule
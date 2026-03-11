module Binary_To_BCD(
	input [15:0] bin,
	output reg [3:0] bcd4, bcd3, bcd2, bcd1, bcd0
);
	integer i;
	always @(*) begin
		bcd4 = 4'd0; bcd3 = 4'd0; bcd2 = 4'd0; bcd1 = 4'd0; bcd0 = 4'd0;

		for (i = 15; i >= 0; i = i - 1) begin
			if (bcd4 >= 5) bcd4 = bcd4 + 3;
			if (bcd3 >= 5) bcd3 = bcd3 + 3;
			if (bcd2 >= 5) bcd2 = bcd2 + 3;
			if (bcd1 >= 5) bcd1 = bcd1 + 3;
			if (bcd0 >= 5) bcd0 = bcd0 + 3;

			bcd4 = {bcd4[2:0], bcd3[3]};
			bcd3 = {bcd3[2:0], bcd2[3]};
			bcd2 = {bcd2[2:0], bcd1[3]};
			bcd1 = {bcd1[2:0], bcd0[3]};
			bcd0 = {bcd0[2:0], bin[i]};
		end
	end
endmodule
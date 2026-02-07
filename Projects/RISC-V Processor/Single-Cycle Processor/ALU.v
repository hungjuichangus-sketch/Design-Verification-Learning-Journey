module ALU(
	input [31:0] SrcA, SrcB,
	input [2:0] ALUControl,
	output reg [31:0] ALUResult,
	output Zero
);

	always @(*)begin
		case(ALUControl)
			3'b000: ALUResult = SrcA & SrcB; // AND
			3'b001: ALUResult = SrcA | SrcB; // OR
			3'b010: ALUResult = SrcA + SrcB; // ADD
			3'b110: ALUResult = SrcA - SrcB; // SUB
			3'b111: begin
				// Use $signed() to ensure negative numbers are handled correctly
				if($signed(SrcA) < $signed(SrcB)) ALUResult = 32'd1; // SLT Result = 1 if A < B
				else ALUResult = 32'd0;
			end
		endcase
	end
	assign Zero = (ALUResult == 32'd0);
endmodule

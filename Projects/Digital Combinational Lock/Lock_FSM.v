module Lock_FSM(
	input clk, rst_n, enter,
	input [3:0] digit_in,
	output reg[3:0] d0, d1, d2, d3,
	output reg unlocked
);
	reg[3:0] current_state, next_state;
	reg enter_prev;
	wire pressed;
	assign pressed = (enter == 1'b1 && enter_prev == 1'b0)? 1'b1 : 1'b0;
	localparam S_WAIT_D0 = 3'd0;
	localparam S_WAIT_D1 = 3'd1;
	localparam S_WAIT_D2 = 3'd2;
	localparam S_WAIT_D3 = 3'd3;
	localparam S_CHECK = 3'd4;
	localparam S_PASS = 3'd5;
	localparam S_FAIL = 3'd6;
	
	localparam passward = 16'h1234;
	
	always @(posedge clk or negedge rst_n)begin
		if(!rst_n)begin
			current_state <= S_WAIT_D0;
			enter_prev <= 1'b0;
		end else begin
			current_state <= next_state;
			enter_prev <= enter;
		end
	end
	
	always @(*)begin
		next_state = current_state;
		case(current_state)
			S_WAIT_D0: if(pressed) next_state = S_WAIT_D1;
			S_WAIT_D1: if(pressed) next_state = S_WAIT_D2;
			S_WAIT_D2: if(pressed) next_state = S_WAIT_D3;
			S_WAIT_D3: if(pressed) next_state = S_CHECK;
			S_CHECK: begin
					if({d0, d1, d2, d3} == passward) next_state = S_PASS;
					else next_state = S_FAIL;
				end
			S_PASS: next_state = S_PASS;
			S_FAIL: next_state = S_WAIT_D0;
		endcase
	end
	
	always @(posedge clk or negedge rst_n)begin
		if(!rst_n)begin
			d0 <= 4'hf; d1 <= 4'hf; d2 <= 4'hf; d3 <= 4'hf; unlocked <= 1'b0;
		end else begin
			case(current_state)
				S_WAIT_D0: if(pressed) d0 <= digit_in;
				S_WAIT_D1: if(pressed) d1 <= digit_in;
				S_WAIT_D2: if(pressed) d2 <= digit_in;
				S_WAIT_D3: if(pressed) d3 <= digit_in;
				S_PASS: unlocked <= 1'b1;
				S_FAIL: begin
					d0 <= 4'hf; d1 <= 4'hf; d2 <= 4'hf; d3 <= 4'hf; unlocked <= 1'b0;
				end
			endcase
		end
	end

endmodule

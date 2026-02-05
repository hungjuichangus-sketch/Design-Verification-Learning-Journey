module AnswerGenerator(
	input clk, rst_n, btn_in,
	input [3:0]lfsr_in,
	output reg[15:0] answer,
	output reg ready
);
	reg btn_prev;
	wire pressed;
	assign pressed = (btn_in == 1'b1 && btn_prev == 1'b0)? 1'b1 : 1'b0;
	
	reg[2:0] current_state, next_state;
	
	localparam S_IDLE = 3'd0;
	localparam S_WAIT_D0 = 3'd1;
	localparam S_WAIT_D1 = 3'd2;
	localparam S_WAIT_D2 = 3'd3;
	localparam S_WAIT_D3 = 3'd4;
	localparam S_GENERATED = 3'd5;
	
	always @(posedge clk or negedge rst_n)begin
		if(!rst_n)begin
			current_state <= S_IDLE;
		end else begin
			btn_prev <= btn_in;
			current_state <= next_state;
		end
	end
	
	always @(*)begin
		next_state = current_state;
		case(current_state)
			S_IDLE: if(pressed) next_state = S_WAIT_D0;
			S_WAIT_D0: if(lfsr_in <= 9) next_state = S_WAIT_D1;
			S_WAIT_D1: if(lfsr_in <= 9 && lfsr_in != answer[3:0]) next_state = S_WAIT_D2;
			S_WAIT_D2: if(lfsr_in <= 9 && lfsr_in != answer[3:0] && lfsr_in != answer[7:4]) next_state = S_WAIT_D3;
			S_WAIT_D3: if(lfsr_in <= 9 && lfsr_in != answer[3:0] && lfsr_in != answer[7:4] && lfsr_in != answer[11:8]) next_state = S_GENERATED;
			S_GENERATED: next_state = S_GENERATED;
		endcase
	end
	
	
	always @(posedge clk or negedge rst_n)begin
		if(!rst_n)begin
			answer <= 16'd0;
			ready <= 1'b0;
		end else begin
			case(current_state)
				S_IDLE: ready <= 1'b0;
				S_WAIT_D0: if(lfsr_in <= 9) answer[3:0] <= lfsr_in;
				S_WAIT_D1: if(lfsr_in <= 9 && lfsr_in != answer[3:0]) answer[7:4] <= lfsr_in;
				S_WAIT_D2: if(lfsr_in <= 9 && lfsr_in != answer[3:0] && lfsr_in != answer[7:4]) answer[11:8] <= lfsr_in;
				S_WAIT_D3: if(lfsr_in <= 9 && lfsr_in != answer[3:0] && lfsr_in != answer[7:4] && lfsr_in != answer[11:8]) answer[15:12] <= lfsr_in;
				S_GENERATED: ready <= 1'b1;
			endcase
		end
		
	end
endmodule
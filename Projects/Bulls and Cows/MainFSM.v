module MainFSM(
	input clk, rst_n, btn_in,
	input [15:0] answer,
	input [3:0] digit_in,
	input ans_ready,
	input clear_sw,
	output reg [2:0] As, Bs,
	output reg [8:0] guess_counter,
	output reg guessed,
	output reg [3:0] d0, d1, d2, d3,
	output reg [3:0] round_counter,
	output reg WE
);

	reg btn_prev, sw_prev;
	wire pressed;
	assign pressed = (btn_in == 1'b1 && btn_prev == 1'b0)? 1'b1 : 1'b0;
	assign clear = (clear_sw == 1'b1 && sw_prev == 1'b0)? 1'b1 : 1'b0;
	reg [2:0] current_state, next_state;
	localparam S_WAIT_ANS = 3'd0;
	localparam S_WAIT_D0 = 3'd1;
	localparam S_WAIT_D1 = 3'd2;
	localparam S_WAIT_D2 = 3'd3;
	localparam S_WAIT_D3 = 3'd4;
	localparam S_CHECK = 3'd5;
	localparam S_PASS = 3'd6;
	localparam S_FAIL = 3'd7;
	
	always @(posedge clk or negedge rst_n)begin
		if(!rst_n)begin
			current_state <= S_WAIT_ANS;
		end else begin
			current_state <= next_state;
			btn_prev <= btn_in;
			sw_prev <= clear_sw;
		end
	end
	
	always @(*)begin
		next_state = current_state;
		case(current_state)
			S_WAIT_ANS: if(ans_ready) next_state = S_WAIT_D0;
			S_WAIT_D0: if(pressed) next_state = S_WAIT_D1;
			S_WAIT_D1: begin
					if(pressed) next_state = S_WAIT_D2;
					else if(clear) next_state = S_WAIT_D0;
				end
			S_WAIT_D2: begin
					if(pressed) next_state = S_WAIT_D3;
					else if(clear) next_state = S_WAIT_D0;
				end
			S_WAIT_D3: begin
					if(pressed) next_state = S_CHECK;
					else if(clear) next_state = S_WAIT_D0;
				end
			S_CHECK: begin
				if({d3, d2, d1, d0} == answer) next_state = S_PASS;
				else next_state = S_FAIL;
			end
			S_FAIL: next_state = S_WAIT_D0;
		endcase
	end
	
	always @(posedge clk or negedge rst_n)begin
		if(!rst_n)begin
			d0 <= 4'hf; d1 <= 4'hf; d2 <= 4'hf; d3 <= 4'hf; guess_counter <= 4'd0;
			As <= 3'd0; Bs <= 3'd0; guessed <= 1'b0; round_counter <= 4'd0; WE <= 1'b0;
		end else begin
			case(current_state)
				S_WAIT_D0: begin
					WE = 1'b0;
					if(clear) begin
						d0 <= 4'hf; d1 <= 4'hf; d2 <= 4'hf; d3 <= 4'hf;
					end
					else if(pressed) d0 <= digit_in;
				end
				S_WAIT_D1: begin
					d1 <= 4'hf; d2 <= 4'hf; d3 <= 4'hf;
					if(clear) begin
							d0 <= 4'hf; d1 <= 4'hf; d2 <= 4'hf; d3 <= 4'hf;
						end
					else if(pressed) d1 <= digit_in;
				end
				S_WAIT_D2: begin 
					if(clear) begin 
						d0 <= 4'hf; d1 <= 4'hf; d2 <= 4'hf; d3 <= 4'hf;
					end
					else if(pressed) d2 <= digit_in;
				end
				S_WAIT_D3: begin
					if(clear) begin 
						d0 <= 4'hf; d1 <= 4'hf; d2 <= 4'hf; d3 <= 4'hf;
					end
					else if(pressed) d3 <= digit_in;
				end
				S_CHECK: begin
					As <= 3'd0;
					Bs <= 3'd0;
					As <= (d0 == answer[3:0]) + (d1 == answer[7:4]) +( d2 == answer[11:8]) + (d3 == answer[15:12]);
					Bs <= (d0 == answer[7:4] || d0 == answer[11:8] || d0 == answer[15:12]) + 
							(d1 == answer[3:0] || d1 == answer[11:8] || d1 == answer[15:12]) +
							(d2 == answer[3:0] || d2 == answer[7:4] || d2 == answer[15:12]) +
							(d3 == answer[3:0] || d3 == answer[7:4] || d3 == answer[11:8]);
				end
				S_PASS: begin 
					guessed <= 1'b1;
					if(!guessed) guess_counter <= guess_counter << 1;
				end
				S_FAIL: begin
					WE = 1'b1;
					if(guess_counter == 0) begin 
						guess_counter = 1'b1;
						round_counter <= round_counter + 1'b1;
					end
					else begin 
						guess_counter <= guess_counter << 1;
						round_counter <= round_counter + 1'b1;
					end
				end
			endcase
		end
	end
endmodule
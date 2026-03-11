module I2CController(
	input clk, rst_n,
	input enable, rw,
	input [6:0] device_addr,
	input [7:0] reg_addr,
	input [7:0] data_in,
	
	output reg busy, done,
	inout SDA, 
	output reg SCL,
	output reg [7:0] data_out
);
	localparam COUNT_TARGET = 124;
	reg [6:0] count;
	reg [3:0] state, next_state;
	reg [1:0] phase;
	reg tick;
	
	reg sda_enable, sda_out;
	
	reg [7:0] tx_shift_reg, rx_shift_reg;
	reg [2:0] bit_counter;
	
	localparam IDLE = 4'd0;
	localparam START = 4'd1;
	localparam SEND_DEV_ADDR = 4'd2;
	localparam ACK_DEV_ADDR = 4'd3;
	localparam SEND_REG_ADDR = 4'd4;
	localparam ACK_REG_ADDR = 4'd5;
	localparam DATA_TRANSFER = 4'd6;
	localparam ACK_DATA = 4'd7;
	localparam STOP = 4'd8;
	localparam WAIT = 4'd9;
	localparam REP_START = 4'd10;
	localparam SEND_DEV_ADDR_READ = 4'd11;
	localparam ACK_DEV_ADDR_READ = 4'd12;
	
	assign SDA = (sda_enable) ? sda_out : 1'bz;
	
	always @(posedge clk or negedge rst_n)begin
		if(!rst_n)begin
			state <= IDLE;
		end else begin
			state <= next_state;
		end
	end
	
	always @(*)begin	
		case(state)
			IDLE:begin
				if(enable) next_state = START;
				else next_state = IDLE;
			end
			
			START:begin
				if(tick && phase == 2'd3) next_state = SEND_DEV_ADDR;
				else next_state = START;
			end
			
			REP_START:begin
				if(tick && phase == 2'd3) next_state = SEND_DEV_ADDR_READ;
				else next_state = REP_START;
			end
			
			SEND_DEV_ADDR:begin
				if(phase == 2'd3 && tick && bit_counter == 3'd7) next_state = ACK_DEV_ADDR;
				else next_state = SEND_DEV_ADDR;
			end
			
			SEND_DEV_ADDR_READ:begin
				if(phase == 2'd3 && tick && bit_counter == 3'd7) next_state = ACK_DEV_ADDR_READ;
				else next_state = SEND_DEV_ADDR_READ;
			end
			
			ACK_DEV_ADDR:begin
				if(tick && phase == 2'd3)begin
					if(SDA == 1'b0)begin
						next_state = SEND_REG_ADDR;
					end else begin
						next_state = STOP;
					end
				end
				else next_state = ACK_DEV_ADDR;
			end
			
			ACK_DEV_ADDR_READ:begin
				if(tick && phase == 2'd3)begin
					if(SDA == 1'b0)begin
						next_state = DATA_TRANSFER;
					end else begin
						next_state = STOP;
					end
				end
				else next_state = ACK_DEV_ADDR_READ;
			end
			
			SEND_REG_ADDR:begin
				if(phase == 2'd3 && tick && bit_counter == 3'd7) next_state = ACK_REG_ADDR;
				else next_state = SEND_REG_ADDR;
			end
			
			ACK_REG_ADDR:begin
				if(tick && phase == 2'd3)begin
					if(SDA == 1'b0)begin
						if(!rw) next_state = DATA_TRANSFER;
						else next_state = REP_START;
					end else begin
						next_state = STOP;
					end
				end
				else next_state = ACK_REG_ADDR;
			end
			
			DATA_TRANSFER:begin
				if(phase == 2'd3 && tick && bit_counter == 3'd7) next_state = ACK_DATA;
				else next_state = DATA_TRANSFER;
			end
			
			ACK_DATA:begin
				if(tick && phase == 2'd3)begin
					if(SDA == 1'b0)begin
						next_state = STOP;
					end else begin
						next_state = STOP;
					end
				end
				else next_state = ACK_DATA;
			end
			
			STOP:begin
				if(tick && phase == 2'd3) next_state = WAIT;
				else next_state = STOP;
			end
			
			WAIT:begin
				if(tick) next_state = IDLE;
				else next_state = WAIT;
			end
			default: next_state <= IDLE;
			
		endcase
	end
	
	always @(posedge clk or negedge rst_n)begin
		if(!rst_n)begin
			busy <= 1'b0;
			done <= 1'b0;
			SCL <= 1'b1;
			sda_enable <= 1'b0;
			sda_out <= 1'b0;
			bit_counter <= 3'd0;
			tx_shift_reg <= 8'b0;
			rx_shift_reg <= 8'b0;
			data_out <= 8'b0;
		end else begin
			case(state)
				IDLE:begin
					busy <= 1'b0;
					done <= 1'b0;
					sda_enable <= 1'b0;
					sda_out <= 1'b0;
					SCL <= 1'b1;
					tx_shift_reg <= {device_addr, 1'b0};
					rx_shift_reg <= 8'd0;
					bit_counter <= 3'd0;
				end
			
				START:begin
					busy <= 1'b1;
					done <= 1'b0;
					if(tick)begin
						sda_enable <= 1'b1;
						case(phase)
							0:begin SCL <= 1'b1; sda_out <= 1'b1; end
							1:begin SCL <= 1'b1; sda_out <= 1'b1; end 
							2:begin SCL <= 1'b1; sda_out <= 1'b0; end
							3:begin SCL <= 1'b0; sda_out <= 1'b0; end
						endcase
					end	
				end
				
				REP_START:begin
					busy <= 1'b1;
					done <= 1'b0;
					if(tick)begin
						sda_enable <= 1'b1;
						case(phase)
							0:begin SCL <= 1'b0; sda_out <= 1'b1; end
							1:begin SCL <= 1'b1; sda_out <= 1'b1; end
							2:begin SCL <= 1'b1; sda_out <= 1'b0; end
							3:begin SCL <= 1'b0; sda_out <= 1'b0; end
						endcase
					end	
				end
				
				SEND_DEV_ADDR:begin
					if(tick)begin
						busy <= 1'b1;
						done <= 1'b0;
						case(phase)
							0:begin
								SCL <= 1'b0;
								sda_out <= tx_shift_reg[7];
							end
							1: SCL <= 1'b1;
							2: SCL <= 1'b1;
							3:begin
								SCL <= 1'b0;
								tx_shift_reg <= tx_shift_reg << 1;
								bit_counter <= bit_counter + 1'b1;
							end
						endcase
					end
				end
				
				SEND_DEV_ADDR_READ:begin
					if(tick)begin
						busy <= 1'b1;
						done <= 1'b0;
						case(phase)
							0:begin
								SCL <= 1'b0;
								sda_out <= tx_shift_reg[7];
							end
							1: SCL <= 1'b1;
							2: SCL <= 1'b1;
							3:begin
								SCL <= 1'b0;
								tx_shift_reg <= tx_shift_reg << 1;
								bit_counter <= bit_counter + 1'b1;
							end
						endcase
					end
				end
				
				ACK_DEV_ADDR:begin
					sda_enable <= 1'b0;
					if(tick)begin
						busy <= 1'b1;
						done <= 1'b0;
						case(phase)
							0: SCL <= 1'b0;
							1: SCL <= 1'b1;
							2: SCL <= 1'b1;
							3:begin
								SCL <= 1'b0;
								tx_shift_reg <= reg_addr;
							end
						endcase
					end
				end
				
				ACK_DEV_ADDR_READ:begin
					sda_enable <= 1'b0;
					if(tick)begin
						busy <= 1'b1;
						done <= 1'b0;
						case(phase)
							0: SCL <= 1'b0;
							1: SCL <= 1'b1;
							2: SCL <= 1'b1;
							3: SCL <= 1'b0;
						endcase
					end
				end
				
				SEND_REG_ADDR:begin
					if(tick)begin
						busy <= 1'b1;
						done <= 1'b0;
						sda_enable <= 1'b1;
						case(phase)
							0:begin
								SCL <= 1'b0;
								sda_out <= tx_shift_reg[7];
							end
							1: SCL <= 1'b1;
							2: SCL <= 1'b1;
							3:begin
								SCL <= 1'b0;
								tx_shift_reg <= tx_shift_reg << 1;
								bit_counter <= bit_counter + 1'b1;
							end
						endcase
					end
				end
				
				ACK_REG_ADDR:begin
					if(tick)begin
						busy <= 1'b1;
						done <= 1'b0;
						sda_enable <= 1'b0;
						case(phase)
							0: SCL <= 1'b0;
							1: SCL <= 1'b1;
							2: SCL <= 1'b1;
							3:begin
								SCL <= 1'b0;
								if(rw == 1'b1) tx_shift_reg <= {device_addr, 1'b1};
								else tx_shift_reg <= data_in;
							end
						endcase
					end
				end
				
				DATA_TRANSFER:begin
					if(tick)begin
						busy <= 1'b1;
						done <= 1'b0;
						if(rw == 1'b0)begin // Write mode
							sda_enable <= 1'b1;
							case(phase)
								0: begin
									SCL <= 1'b0;
									sda_out <= tx_shift_reg[7];
								end
								1: SCL <= 1'b1;
								2: SCL <= 1'b1;
								3:begin
									SCL <= 1'b0;
									tx_shift_reg <= tx_shift_reg << 1;
									bit_counter <= bit_counter + 1'b1;
								end
							endcase
						end else begin // Read mode
							sda_enable <= 1'b0;
							case(phase)
								0: SCL <= 1'b0;
								1: SCL <= 1'b1;
								2:begin
									SCL <= 1'b1;
									rx_shift_reg <= {rx_shift_reg[6:0], SDA};
								end
								3:begin
									SCL <= 1'b0;
									bit_counter <= bit_counter + 1'b1;
								end
							endcase
						end
					end
				end
				
				ACK_DATA:begin
					if(tick)begin
						busy <= 1'b1;
						done <= 1'b0;
						if(rw == 0)begin // Write mode, wait for ACK
							sda_enable <= 1'b0;
							case(phase)
								0: SCL <= 1'b0;
								1: SCL <= 1'b1;
								2: SCL <= 1'b1;
								3: SCL <= 1'b0;
							endcase
						end else begin // Read mode, send NACK
							sda_enable <= 1'b1;
							case(phase)
								0:begin
									SCL <= 1'b0;
									sda_out <= 1'b1; // SDA HIGH => NACK
								end
								1: SCL <= 1'b1;
								2: SCL <= 1'b1;
								3:begin
									SCL <= 1'b0;
									data_out <= rx_shift_reg;
								end
							endcase
						end
					end
				end
				
				STOP:begin
					if(tick)begin
						sda_enable <= 1'b1;
						case(phase)
							0:begin
								SCL <= 1'b0;
								sda_out <= 1'b0;
							end
							1: SCL <= 1'b1;
							2: SCL <= 1'b1;
							3:begin
								SCL <= 1'b1;
								sda_out <= 1'b1;
							end
						endcase
					end
				end
				
				WAIT:begin
					sda_enable <= 1'b0;
					if(tick)begin
						busy <= 1'b0;
						done <= 1'b1;
					end
				end
			endcase
		end
		
	end
	
	// For the internal SCL
	always @(posedge clk or negedge rst_n)begin
		if(!rst_n)begin
			count <= 0;
			tick <= 1'b0;
			phase <= 2'b0;
		end else if(enable || state != IDLE)begin
			if(count < COUNT_TARGET)begin
				count <= count + 1'b1;
				tick <= 1'b0;
			end else begin
				count <= 0;
				tick <= 1'b1;
				phase <= phase + 1'b1;
			end
		end else begin
			phase <= 2'b0;
		end
	end
	
endmodule
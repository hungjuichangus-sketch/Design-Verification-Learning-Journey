module UartRx (
    input  wire       clk,        // 50MHz System Clock
    input  wire       rst_n,      // Reset (Active Low)
    input  wire       rx,         // Serial Input (Connect to Arduino TX)
    output reg [7:0]  rx_data,    // The received byte
    output reg        rx_ready    // Pulse High for 1 cycle when data is valid
);

	// ==========================================
	// 1. Baud Rate & Parameters
	// ==========================================
	parameter CLK_FREQ  = 50_000_000;
	parameter BAUD_RATE = 9_600;
	localparam CLKS_PER_BIT = CLK_FREQ / BAUD_RATE;      // 5208
	localparam CLKS_HALF_BIT = CLKS_PER_BIT / 2;         // 2604
	
	localparam S_IDLE  = 2'd0;
	localparam S_START = 2'd1;
	localparam S_DATA  = 2'd2;
	localparam S_STOP  = 2'd3;
	
	reg [1:0]  state;
	reg [12:0] clk_count;
	reg [2:0]  bit_index;
	reg [7:0]  scratch_pad; // Temporary shift register
	
	// ==========================================
	// 2. Double-Flop Synchronizer
	// Purpose: Clean the 'rx' signal from outside noise/timing issues
	// ==========================================
	reg rx_sync1, rx_sync2;
	wire rx_clean = rx_sync2;
	
	always @(posedge clk or negedge rst_n) begin
		if (!rst_n) begin
			rx_sync1 <= 1'b1;
			rx_sync2 <= 1'b1;
		end else begin
			rx_sync1 <= rx;
			rx_sync2 <= rx_sync1;
		end
	end
	
	// ==========================================
	// 3. Receiver State Machine
	// ==========================================
	always @(posedge clk or negedge rst_n) begin
		if (!rst_n) begin
			state       <= S_IDLE;
			clk_count   <= 13'd0;
			bit_index   <= 3'd0;
			rx_ready    <= 1'b0;
			rx_data     <= 8'd0;
			scratch_pad <= 8'd0;
		end else begin
			// Default: rx_ready is a pulse, so it should be 0 unless we finish
			rx_ready <= 1'b0;
		
			case (state)
				// -------------------------------------------------------------
				// IDLE: Wait for Falling Edge (Start Bit)
				// 1. Look at 'rx_clean'. Is it 0?
				// 2. If yes: Reset counter and move to S_START.
				// -------------------------------------------------------------
				S_IDLE: begin
					if (rx_clean == 1'b0) begin
						clk_count <= 13'd0;
						state     <= S_START;
					end
				end
				
				// -------------------------------------------------------------
				// START BIT: Check validity
				// 1. Wait until clk_count == CLKS_HALF_BIT (Middle of the pulse).
				// 2. Check 'rx_clean':
				//    - If 0: It's valid. Reset counter, move to S_DATA.
				//    - If 1: It was noise. Go back to S_IDLE.
				// -------------------------------------------------------------
				S_START: begin
					if (clk_count == CLKS_HALF_BIT) begin
						if (rx_clean == 1'b0) begin
							clk_count <= 13'd0;
							state     <= S_DATA;
						end else begin
							state     <= S_IDLE;
						end
					end else begin
						clk_count <= clk_count + 1'b1;
					end
				end
				
				// -------------------------------------------------------------
				// DATA BITS: Sample 8 bits
				// 1. Wait until clk_count == CLKS_PER_BIT (Full bit width).
				// 2. Sample: scratch_pad[bit_index] <= rx_clean;
				// 3. Increment bit_index.
				// 4. Handle loop (0 to 7) -> Move to S_STOP when done.
				// -------------------------------------------------------------
				S_DATA: begin
					if (clk_count < CLKS_PER_BIT - 1) begin
						clk_count <= clk_count + 1'b1;
					end else begin
						clk_count <= 13'd0;
						// Always sample the bit when the timer expires!
						scratch_pad[bit_index] <= rx_clean;
				
						if (bit_index < 7) begin
							bit_index <= bit_index + 1'b1;
						end else begin
							bit_index <= 3'd0;
							state     <= S_STOP;
						end
					end
				end
				
				// -------------------------------------------------------------
				// STOP BIT: Finish up
				// 1. Wait until clk_count == CLKS_PER_BIT.
				// 2. Move data: rx_data <= scratch_pad;
				// 3. Signal CPU: rx_ready <= 1'b1;
				// 4. Go back to S_IDLE.
				// -------------------------------------------------------------
				S_STOP: begin
					if (clk_count < CLKS_PER_BIT - 1) begin
						clk_count <= clk_count + 1'b1;
					end else begin
						rx_data   <= scratch_pad;
						rx_ready  <= 1'b1;
						clk_count <= 13'd0;
						state     <= S_IDLE;
					end
				end
				default: state <= S_IDLE;
			endcase
		end
	end

endmodule
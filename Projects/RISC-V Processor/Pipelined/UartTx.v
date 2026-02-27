module UartTx (
    input  wire       clk,        // Must be 50MHz System Clock
    input  wire       rst_n,      // Reset (Active Low)
    input  wire       start,      // Signal to start sending (from CPU MemWrite)
    input  wire [7:0] data,       // Byte to send
    output reg        tx,         // Serial Output (Connect to Arduino RX)
    output reg        ready       // 1 = Idle/Ready, 0 = Busy sending
);

	// ==========================================
	// 1. Baud Rate Generator
	// ==========================================
	parameter CLK_FREQ  = 50_000_000;
	parameter BAUD_RATE = 9600;
	localparam CLKS_PER_BIT = CLK_FREQ / BAUD_RATE; // 5208
	
	// State Encoding
	localparam S_IDLE  = 3'd0;
	localparam S_START = 3'd1;
	localparam S_DATA  = 3'd2;
	localparam S_STOP  = 3'd3;
	
	reg [2:0]  state;
	reg [12:0] clk_count; // Timer for baud rate
	reg [2:0]  bit_index; // 0-7 to track bits
	reg [7:0]  tx_data;   // Register to hold the data safely
	
	// Edge Detection Logic
	reg start_prev;
	wire start_pulse;
	assign start_pulse = (start == 1'b1 && start_prev == 1'b0);
	
	always @(posedge clk or negedge rst_n) begin
		if (!rst_n) begin
			state      <= S_IDLE;
			tx         <= 1'b1; // Idle High
			ready      <= 1'b1;
			clk_count  <= 13'd0;
			bit_index  <= 3'd0;
			tx_data    <= 8'd0;
			start_prev <= 1'b0;
		end else begin
			// Track previous start signal for edge detection
			start_prev <= start;
		
		case (state)
			// --------------------------------------
			// STATE: IDLE
			// --------------------------------------
			S_IDLE: begin
				tx        <= 1'b1; // Idle line is High
				ready     <= 1'b1;
				clk_count <= 13'd0;
				bit_index <= 3'd0;
				if (start_pulse) begin
					tx_data <= data;  // Latch the data
					state   <= S_START;
					ready   <= 1'b0;  // Busy
				end
			end
			
			// --------------------------------------
			// STATE: START BIT
			// --------------------------------------
			S_START: begin
				tx <= 1'b0; // Start Bit is 0
			
				if (clk_count < CLKS_PER_BIT - 1) begin
					clk_count <= clk_count + 1'b1;
				end else begin
					clk_count <= 13'd0;
					state     <= S_DATA;
				end
			end
			
			// --------------------------------------
			// STATE: DATA BITS
			// --------------------------------------
			S_DATA: begin
				tx <= tx_data[bit_index]; // Send LSB first
			
				if (clk_count < CLKS_PER_BIT - 1) begin
					clk_count <= clk_count + 1'b1;
				end else begin
					clk_count <= 13'd0;
					if (bit_index < 7) begin
						bit_index <= bit_index + 1'b1;
					end else begin
						bit_index <= 3'd0;
						state     <= S_STOP;
					end
				end
			end
			
			// --------------------------------------
			// STATE: STOP BIT
			// --------------------------------------
			S_STOP: begin
				tx <= 1'b1; // Stop Bit is 1
			
				if (clk_count < CLKS_PER_BIT - 1) begin
					clk_count <= clk_count + 1'b1;
				end else begin
					clk_count <= 13'd0;
					state     <= S_IDLE; // Done
				end
			end
			
			default: state <= S_IDLE;
			endcase
		end
	end
	
endmodule
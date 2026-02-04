module Reflex_FSM(
    input clk_50M,
    input rst_n,
    input tick_1ms,    // This is the "Permission Slip"
    input btn_in,      // Debounced button
	 input [11:0] lfsr_12,
    output reg [9:0] leds,
    output reg [3:0] ms_ones, ms_tens, s_ones
);

    // State Definitions
    localparam IDLE = 2'b00, DELAY = 2'b01, COUNTING = 2'b10, RESULT = 2'b11;
	 reg [1:0] current_state, next_state;
    
    // Timer registers
    reg [11:0] delay_timer;
	 reg [11:0] target_delay;
	 reg [3:0] target_led;

    // Edge Detection Logic (Internal)
    reg btn_reg;
    wire btn_pressed = (btn_reg == 1'b1 && btn_in == 1'b0); // Falling edge

    // --- 1. State Transition (Sequential) ---
    always @(posedge clk_50M or negedge rst_n) begin
        if (!rst_n) begin
            current_state <= IDLE;
            btn_reg <= 1'b1;
        end else begin
            current_state <= next_state;
            btn_reg <= btn_in; // Update button history
				
				if (current_state == IDLE && btn_pressed)begin
					target_delay <= lfsr_12[10:0] + lfsr_12[9:0] + 11'd2000;
					if (lfsr_12[3:0] > 4'd9)
						target_led <= lfsr_12[3:0] - 4'd6;
					else
						target_led <= lfsr_12[3:0];
				end
        end
    end

    // --- 2. Next State Logic (Combinational) ---
    always @(*) begin
        next_state = current_state;
        leds = 10'd0; // Default LED Off
        case (current_state)
            IDLE:     if (btn_pressed)
					next_state = DELAY;
            DELAY:    if (delay_timer >= target_delay) next_state = COUNTING;
            COUNTING: begin
                leds[target_led] = 1'b1; // LED On!
                if (btn_pressed) next_state = RESULT;
            end
            RESULT:   if (btn_pressed) next_state = IDLE;
            default:  next_state = IDLE;
        endcase
    end

    // --- 3. Counters (The Tick Method) ---
    always @(posedge clk_50M or negedge rst_n) begin
        if (!rst_n) begin
            delay_timer <= 0;
            {s_ones, ms_tens, ms_ones} <= 12'h000;
        end else begin
            // Clear everything in IDLE so game starts fresh
            if (current_state == IDLE) begin
                delay_timer <= 0;
                {s_ones, ms_tens, ms_ones} <= 12'h000;
            end 
            // Handle Delay Counter
            else if (current_state == DELAY && tick_1ms) begin
                delay_timer <= delay_timer + 1'b1;
            end
            // Handle BCD Reaction Counter
            else if (current_state == COUNTING && tick_1ms) begin
                if (ms_ones < 4'd9) ms_ones <= ms_ones + 1'b1;
                else begin
                    ms_ones <= 0;
                    if (ms_tens < 4'd9) ms_tens <= ms_tens + 1'b1;
                    else begin
                        ms_tens <= 0;
                        if (s_ones < 4'd9) s_ones <= s_ones + 1'b1;
                        else s_ones <= 0;
                    end
                end
            end
        end
    end
endmodule
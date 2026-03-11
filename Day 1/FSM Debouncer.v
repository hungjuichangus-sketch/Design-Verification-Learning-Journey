// Purpose: 3-Always Block FSM Debouncer for mechanical buttons
module Debouncer (
    input      clk,
    input      rst_n,
    input      btn_in,     // Raw input (Active-Low)
    output reg btn_out     // Cleaned output (Active-High)
);

    // State Encoding
    localparam IDLE    = 2'b00;
    localparam WAIT    = 2'b01;
    localparam PRESSED = 2'b10;
    localparam RELEASE = 2'b11;

    reg [1:0]  curr_state, next_state;
    reg [19:0] timer;

    // BLOCK 1: State Register (Sequential)
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) curr_state <= IDLE;
        else        curr_state <= next_state;
    end

    // BLOCK 2: Next State Logic (Combinational)
    always @(*) begin
        case (curr_state)
            IDLE:    next_state = (btn_in == 1'b0) ? WAIT : IDLE;
            WAIT:    next_state = (timer == 20'd1_000_000) ? PRESSED : WAIT;
            PRESSED: next_state = (btn_in == 1'b1) ? RELEASE : PRESSED;
            RELEASE: next_state = IDLE;
            default: next_state = IDLE;
        endcase
    end

    // BLOCK 3: Datapath (Timer) & Output
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            timer <= 20'd0;
        end else begin
            if (curr_state == WAIT)
                timer <= timer + 1'b1;
            else
                timer <= 20'd0;
        end
    end

    // Combinational Output
    always @(*) begin
        btn_out = (curr_state == PRESSED);
    end

endmodule

// Purpose: Slow down 50MHz clock to 1Hz
module ClockDivider(
    input        clk,     // 50MHz internal clock
    input        rst_n,   // Active-low reset
    output reg   led      // 1Hz signal (or blinky LED)
);

    // Constant for 1Hz: (50MHz / 2) - 1
    localparam TARGET_COUNT = 25_000_000 - 1; 

    reg [25:0] counter;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            counter <= 26'd0;
            led     <= 1'b0;
        end else begin
            if (counter == TARGET_COUNT) begin
                counter <= 26'd0;
                led     <= ~led;
            end else begin
                counter <= counter + 1'b1;
            end
        end
    end

endmodule

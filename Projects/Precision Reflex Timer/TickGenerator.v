module TickGenerator (
    input clk,
    input rst_n,
    output reg tick_1ms
);
    // 50MHz / 1kHz = 50,000 cycles
    localparam TARGET = 50_000 - 1;
    reg [15:0] count;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            count <= 0;
            tick_1ms <= 1'b0;
        end else begin
            if (count == TARGET) begin
                count <= 0;
                tick_1ms <= 1'b1; // Pulse high for exactly one 50MHz cycle
            end else begin
                count <= count + 1'b1;
                tick_1ms <= 1'b0; // Stay low otherwise
            end
        end
    end
endmodule
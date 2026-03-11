// Purpose: Cascaded BCD Counter for a Digital Clock (00-59)
module Counter_00_59(
    input            clk,     // Should be a 1Hz clock or pulse
    input            rst_n,   
    output reg [3:0] sec_ones,
    output reg [3:0] sec_tens
);

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            sec_ones <= 4'd0;
            sec_tens <= 4'd0;
        end else begin
            if (sec_ones < 4'd9) begin
                sec_ones <= sec_ones + 1'b1;
            end else begin
                sec_ones <= 4'd0;
                if (sec_tens < 4'd5) begin
                    sec_tens <= sec_tens + 1'b1;
                end else begin
                    sec_tens <= 4'd0;
                end
            end
        end
    end

endmodule

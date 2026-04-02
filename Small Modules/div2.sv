module div2(
    input clk,
    input rst_n,

    output clk_out
);

    always_ff @(posedge clk or negedge rst_n)begin
        if(!rst_n)begin
            clk_out <= 1'b0;
        end else begin
            clk_out <= ~clk_out;
        end
    end

endmodule
